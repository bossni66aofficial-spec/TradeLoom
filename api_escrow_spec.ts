
// /api/escrow/create.ts - Next.js API Route
// Implements Separate Charges & Transfers from research page 9

import Stripe from 'stripe'
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function createEscrowAllocation({projectId, sovId, amount, contractorId, homeownerId, jobCountTogether}: any) {
  // De-escalating fee logic from research
  let feeRate = 0.08
  if (jobCountTogether === 1) feeRate = 0.04
  if (jobCountTogether >= 2) feeRate = 0.015

  const feeAmount = Math.round(amount * feeRate * 100) / 100
  const netToContractor = amount - feeAmount

  // Step 1: Create PaymentIntent with manual capture hold (or immediate capture for long jobs)
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(amount * 100),
    currency: 'cad',
    capture_method: 'automatic', // Immediate capture to platform balance for long construction holds
    metadata: { projectId, sovId, contractorId, feeRate: String(feeRate) }
  })

  // Step 2: Save to escrow_allocations table (status = pending_funding)
  // ... supabase insert ...

  return { paymentIntent, feeRate, feeAmount, netToContractor }
}

// /api/escrow/release.ts
export async function releaseEscrow(escrowId: string) {
  // Verify milestone inspected or 14-day auto-release timeout passed
  // Generate unconditional lien waiver
  // Trigger Stripe Transfer to contractor Connect account
  
  // const transfer = await stripe.transfers.create({
  //   amount: netToContractor * 100,
  //   currency: 'cad',
  //   destination: contractorStripeAccountId,
  //   source_transaction: paymentIntentId
  // })
}
