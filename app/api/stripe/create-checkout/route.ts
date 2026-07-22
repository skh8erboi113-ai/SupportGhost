import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
export async function GET(req: NextRequest){
  const url=process.env.NEXT_PUBLIC_APP_URL||'http://localhost:3000';
  try{
    const session=await stripe.checkout.sessions.create({mode:'subscription',line_items:[{price_data:{currency:'usd',product_data:{name:'SupportGhost Pro'},unit_amount:9900,recurring:{interval:'month'}},quantity:1}],success_url:`${url}/dashboard?success=1`,cancel_url:`${url}/?canceled=1`});
    return NextResponse.redirect(session.url!);
  }catch(e:any){return NextResponse.json({error:e.message});}
}
