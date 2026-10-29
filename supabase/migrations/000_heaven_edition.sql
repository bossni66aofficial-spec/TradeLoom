
-- =============================================================
-- EDMONTON TRADES MARKETPLACE - Production PostgreSQL Schema
-- Based on Blueprint Research: Hybrid SaaS + Escrow Model
-- PostGIS enabled, Double-Entry Ledger, Lien Waiver Automation
-- =============================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. USERS & AUTH (Multi-role)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role TEXT NOT NULL CHECK (role IN ('homeowner','contractor','admin','subtrade')),
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  kyc_status TEXT DEFAULT 'pending' CHECK (kyc_status IN ('pending','verified','failed')),
  kyb_data JSONB -- Checkr/Persona response
);

-- 2. CONTRACTOR PROFILES (Trust Stack from Research)
CREATE TABLE contractor_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  ab_number TEXT, -- Alberta business number
  trade_type TEXT NOT NULL, -- plumbing, electrical, hvac, roofing, etc
  license_number TEXT,
  license_status TEXT DEFAULT 'pending' CHECK (license_status IN ('pending','active','expired','disciplinary')),
  license_verified_at TIMESTAMPTZ,
  insurance_policy_number TEXT,
  insurance_status TEXT DEFAULT 'pending',
  insurance_expires_at DATE,
  insurance_limits JSONB, -- {per_occurrence: 1000000, aggregate: 2000000}
  is_additional_insured BOOLEAN DEFAULT FALSE,
  service_radius_km INT DEFAULT 25,
  service_area GEOGRAPHY(Polygon, 4326), -- PostGIS for Edmonton zones
  saas_tier TEXT DEFAULT 'basic' CHECK (saas_tier IN ('basic','pro','enterprise')),
  saas_status TEXT DEFAULT 'active',
  rating_avg DECIMAL(3,2) DEFAULT 0,
  total_jobs INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PROJECTS & PARAMETRIC SCOPING WIZARD
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  homeowner_id UUID REFERENCES users(id),
  title TEXT NOT NULL,
  trade_discipline TEXT NOT NULL,
  classification TEXT CHECK (classification IN ('repair','replacement','new_build','emergency')),
  -- Parametric fields from research
  dimensions JSONB, -- {sq_ft, ceiling_height, linear_ft}
  site_conditions JSONB, -- {structure_age, subfloor, electrical_capacity, access}
  material_preference TEXT CHECK (material_preference IN ('owner_supplied','contractor_furnished','hybrid')),
  permit_required BOOLEAN DEFAULT FALSE,
  permit_status TEXT DEFAULT 'not_started',
  location GEOGRAPHY(Point, 4326), -- Edmonton lat/lng
  address TEXT NOT NULL,
  city TEXT DEFAULT 'Edmonton',
  photos JSONB, -- geotagged array
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft','bidding','awarded','in_progress','disputed','completed','cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. BIDS & SCHEDULE OF VALUES (SOV) - Anti Low-Ball Matrix
CREATE TABLE bids (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  contractor_id UUID REFERENCES contractor_profiles(id),
  total_amount DECIMAL(12,2) NOT NULL,
  labor_allocation DECIMAL(12,2),
  material_allowance DECIMAL(12,2),
  timeline_days INT,
  proposal_pdf_url TEXT,
  status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted','viewed','accepted','rejected','expired')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, contractor_id)
);

CREATE TABLE schedule_of_values (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bid_id UUID REFERENCES bids(id) ON DELETE CASCADE,
  milestone_name TEXT NOT NULL, -- e.g. 'Foundation', 'Rough-in', 'Drywall', 'Punch-list'
  description TEXT,
  amount DECIMAL(12,2) NOT NULL,
  disbursement_order INT NOT NULL,
  requires_inspection BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. ESCROW LEDGER - Double-Entry (Separate Charges & Transfers model)
CREATE TABLE escrow_allocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id),
  sov_id UUID REFERENCES schedule_of_values(id),
  homeowner_id UUID REFERENCES users(id),
  contractor_id UUID REFERENCES contractor_profiles(id),
  stripe_payment_intent_id TEXT UNIQUE,
  amount_total DECIMAL(12,2) NOT NULL,
  platform_fee_rate DECIMAL(5,4) NOT NULL, -- 0.08, 0.04, 0.015 de-escalating
  platform_fee_amount DECIMAL(12,2) NOT NULL,
  net_to_contractor DECIMAL(12,2) NOT NULL,
  status TEXT DEFAULT 'pending_funding' CHECK (status IN ('pending_funding','active_hold','work_in_progress','pending_inspection','pending_release','released','frozen_dispute','refunded')),
  funded_at TIMESTAMPTZ,
  work_completed_at TIMESTAMPTZ,
  inspection_due_at TIMESTAMPTZ, -- auto-release after 14 days per research
  released_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Escrow internal double-entry audit
CREATE TABLE escrow_ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  allocation_id UUID REFERENCES escrow_allocations(id),
  entry_type TEXT CHECK (entry_type IN ('debit_homeowner','credit_platform_hold','debit_platform_hold','credit_contractor','credit_platform_fee','refund')),
  amount DECIMAL(12,2) NOT NULL,
  stripe_balance_transaction_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. LIEN WAIVER AUTOMATION - Alberta Builder's Lien Act
CREATE TABLE lien_waivers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  escrow_id UUID REFERENCES escrow_allocations(id),
  contractor_id UUID REFERENCES contractor_profiles(id),
  type TEXT CHECK (type IN ('conditional_progress','unconditional_progress','conditional_final','unconditional_final')),
  amount DECIMAL(12,2),
  signed_by_contractor BOOLEAN DEFAULT FALSE,
  signed_at TIMESTAMPTZ,
  document_url TEXT,
  affidavit_subs_paid BOOLEAN DEFAULT FALSE, -- sworn all subs paid
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. CHANGE ORDERS - Mobile Field Workflow
CREATE TABLE change_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id),
  contractor_id UUID REFERENCES contractor_profiles(id),
  title TEXT NOT NULL,
  reason TEXT, -- e.g. 'deteriorated framing behind drywall'
  cost_adjustment DECIMAL(12,2) NOT NULL,
  schedule_adjustment_days INT DEFAULT 0,
  photo_evidence JSONB,
  status TEXT DEFAULT 'pending_approval' CHECK (status IN ('pending_approval','approved','rejected','funded')),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. DISPUTES - 72h Cure + Evidence Audit
CREATE TABLE disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id),
  escrow_id UUID REFERENCES escrow_allocations(id),
  raised_by UUID REFERENCES users(id),
  reason TEXT NOT NULL,
  deficiency_details JSONB,
  photo_evidence JSONB,
  proposed_adjustment DECIMAL(12,2),
  status TEXT DEFAULT 'informal_negotiation' CHECK (status IN ('informal_negotiation','evidence_audit','arbitration','resolved','closed')),
  cure_period_ends_at TIMESTAMPTZ, -- 72h per research
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. REVENUE & SUBSCRIPTIONS
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contractor_id UUID REFERENCES contractor_profiles(id),
  tier TEXT CHECK (tier IN ('basic','pro','enterprise')),
  stripe_subscription_id TEXT,
  mrr DECIMAL(8,2),
  status TEXT DEFAULT 'active',
  current_period_end TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. DE-ESCALATING TAKE RATE LOGIC (View for calculation)
CREATE OR REPLACE VIEW contractor_homeowner_history AS
SELECT 
  cp.id as contractor_id,
  p.homeowner_id,
  COUNT(DISTINCT b.id) FILTER (WHERE b.status='accepted') as completed_jobs_together,
  CASE 
    WHEN COUNT(DISTINCT b.id) FILTER (WHERE b.status='accepted') = 0 THEN 0.08
    WHEN COUNT(DISTINCT b.id) FILTER (WHERE b.status='accepted') = 1 THEN 0.04
    ELSE 0.015
  END as n