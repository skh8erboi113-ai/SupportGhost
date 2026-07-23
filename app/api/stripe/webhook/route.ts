import { NextRequest, NextResponse } from 'next/server';
export async function POST(req: NextRequest) {
  return NextResponse.json({ received: true, note: 'Add STRIPE_SECRET_KEY to enable' });
}
