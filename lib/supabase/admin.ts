
// ADMIN CLIENT - Bypasses RLS - Use ONLY in API routes / server actions
// This is why we enabled RLS - anon can't read escrow, but this can.
import { createClient } from '@supabase/supabase-js'
export const createAdminClient = () => createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!)
