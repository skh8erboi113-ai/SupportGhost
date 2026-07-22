import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseAdmin';
export async function POST(req: NextRequest){
  const {email_from,subject,body}=await req.json();
  await supabaseAdmin.from('tickets').insert({email_from,subject,body,status:'open'});
  return NextResponse.json({ok:true});
}
