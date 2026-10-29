
export type UserRole = 'homeowner' | 'contractor' | 'admin'
export type ProjectStatus = 'draft' | 'bidding' | 'funded' | 'in_progress' | 'completed' | 'disputed'
export type EscrowStatus = 'held' | 'released' | 'retainage' | 'refunded'
// All types import from supabase.ts after you run db:types
