import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseAdmin';
export async function POST(req: NextRequest){
  const body=await req.json();
  await supabaseAdmin.from('orders_cache').upsert({shopify_order_id:body.id?.toString()||body.name,email:body.email||body.customer?.email,status:body.fulfillment_status||'unfulfilled',tracking:body.fulfillments?.[0]?.tracking_number||''});
  return NextResponse.json({ok:true});
}
