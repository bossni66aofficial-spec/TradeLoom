
// TradeLoom™ Escrow Engine - SCALABLE
// Stripe Connect Separate Charges and Transfers (NOT Destination)
// Supports: Multi-month holds, split payouts, retainage, de-escalating fees

export const ESCROW_FEE_SCHEDULE = {
  JOB_1: 0.08, // 8%
  JOB_2: 0.04, // 4%
  JOB_3_PLUS: 0.015 // 1.5% + processing
}

export function getFeeRate(priorJobs: number): number {
  if (priorJobs === 0) return ESCROW_FEE_SCHEDULE.JOB_1
  if (priorJobs === 1) return ESCROW_FEE_SCHEDULE.JOB_2
  return ESCROW_FEE_SCHEDULE.JOB_3_PLUS
}

// All escrow money movement goes through this - never direct transfers
// 1. Homeowner pays -> Charge on platform (held)
// 2. Create escrow_allocations (labor vs material split)
// 3. On approval -> Transfer to contractor Connect account (minus fee + retainage)
// 4. Retainage held for 45 days (Alberta lien period)
