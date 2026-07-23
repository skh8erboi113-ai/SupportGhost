import { NextRequest, NextResponse } from 'next/server';
export async function GET(req: NextRequest) {
  const url = process.env.NEXT_PUBLIC_APP_URL || new URL(req.url).origin.toString();
  if (!process.env.STRIPE_SECRET_KEY || process.env.STRIPE_SECRET_KEY.includes('xxx') || process.env.STRIPE_SECRET_KEY.includes('placeholder')) {
    return NextResponse.redirect(`${url}/dashboard?demo=1`);
  }
  try {
    const Stripe = (await import('stripe')).default;
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: '2024-06-20' as any });
    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      line_items: [{ price_data: { currency: 'usd', product_data: { name: 'SupportGhost Pro' }, unit_amount: 9900, recurring: { interval: 'month' } }, quantity: 1 }],
      success_url: `${url}/dashboard?success=1`,
      cancel_url: `${url}/?canceled=1`,
    });
    return NextResponse.redirect(session.url!);
  } catch (e: any) {
    return NextResponse.redirect(`${url}/dashboard?error=${encodeURIComponent(e.message)}`);
  }
}
