
# TradeLoom™ — Heaven Edition
### Weaving Trust Into Every Build
**Domain:** tradeloom.ca | **Email:** hello@tradeloom.ca (via Google Workspace) | **City:** Edmonton, AB

This is the generational system — from research to SaaS.

## What You Own
- tradeloom.ca (registered)
- TradeLoom™ brand + logo (T+L woven house)
- Full PostgreSQL + PostGIS schema (11 tables)
- Escrow engine (Stripe Connect Separate Charges & Transfers)
- SaaS billing tiers: Basic Free, Pro $79/mo, Enterprise $299/mo
- De-escalating fee: Job1 8%, Job2 4%, Job3+ 1.5%

## Quick Start - Hosted SaaS Stack

### 1. Database - Supabase
- Create Organization: TradeLoom
- Create Project: tradeloom-heaven (Region: US West)
- SQL Editor -> Paste schema.sql -> Run
- You get: users, contractor_profiles, projects, bids, schedule_of_values, escrow_allocations, escrow_ledger_entries, lien_waivers, change_orders, disputes, subscriptions

### 2. Email - Google Workspace (In Progress)
- Domain verified via TXT: google-site-verification=yUvTgEKiC8Ka9kEE9RPtYKxcNPylwITqwfhllyCBjivk
- Admin: admin@tradeloom.ca
- Aliases: hello@, support@, info@ -> all to admin

### 3. Website - Vercel
- Push this folder to GitHub: tradeloom
- Import to Vercel -> Deploy -> tradeloom.vercel.app
- Add custom domain tradeloom.ca (Vercel shows 2 DNS records to add in Namecheap Advanced DNS)

### 4. Payments - Stripe
- Products: TradeLoom Pro $79/mo, Enterprise $299/mo
- Webhook: https://tradeloom.ca/api/stripe/webhook
- Connect: Enable for contractor payouts

## Brand Kit
- Logo: TradeLoom_Logo.png
- Colors: Navy #0A1931, Copper #C67A3E
- Tagline: Weaving Trust Into Every Build
- Font: Inter / Satoshi for SaaS

## Next Steps
1. Verify Google Workspace (click Confirm every 10 mins)
2. Run schema.sql in Supabase
3. Deploy to Vercel
4. Create Stripe products

One Love - Bossmano + Brother - Edmonton Heaven
