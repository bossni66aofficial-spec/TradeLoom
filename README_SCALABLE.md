
# TradeLoom™ Scalable OS - Heaven Edition

## WHY THIS IS SCALABLE (No Rebuild Needed)

### 1. Modular Monolith (Start) -> Microservices (Later) without rewrite
- app/(marketing) -> landing, SEO, waitlist
- app/(dashboard)/homeowner -> project wizard, bid compare, escrow
- app/(dashboard)/contractor -> bids, schedule_of_values, payouts
- app/api/* -> All business logic via APIs, not in UI

Adding a feature = Add a new folder in app/(dashboard), NOT rebuild.

### 2. Database Scalable by Design
- PostGIS for location: Edmonton radius now, Calgary later just change query
- contractor_homeowner_history VIEW for de-escalating fees: auto-calculates prior jobs
- escrow_ledger_entries: Double-entry accounting, same as Stripe uses
- RLS enabled: Security scales to 10k users with zero code change

### 3. Payments Scalable
- Stripe Connect Separate Charges & Transfers
- Why not Destination? Destination can't hold funds > 90 days, can't split.
- Our way: Charge held on platform, then Transfer. Supports retainage for 45-day Alberta lien period.

### 4. City Expansion Scalable
- lib/edmonton-data/permits.ts interface
- Day 2: Add lib/calgary-data/permits.ts with SAME function signature
- App doesn't know city, just calls getRecentPermits() -> returns city data

### 5. Add Features Like LEGO
- Want material markup? Add lib/materials/ + app/api/materials
- Want financing? Add lib/financing/ + Stripe Capital
- Want Flutter field app? Already specced in mobile_field_spec.md, just connect to same Supabase

### Folder Map
- lib/supabase/admin.ts -> ONLY place that bypasses RLS (API routes)
- lib/stripe/escrow.ts -> Single source of truth for fee schedule
- components/* -> Reusable UI, never duplicate
- supabase/migrations/* -> Every DB change versioned, can rollback

### How to Scale to Calgary
1. Add Calgary PostGIS polygon in contractor_profiles
2. Add lib/calgary-data
3. Change default map center
NO DB REBUILD, NO ESCROW REWRITE

This is generational. Mama proud architecture.
