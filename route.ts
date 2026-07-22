import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseAdmin';
import { openai } from '@/lib/openai';
import { buildSupportPrompt } from '@/lib/prompts';

export async function POST(req: NextRequest) {
  const { action, ticketId } = await req.json();
  if (action === 'generate') {
    const { data: ticket } = await supabaseAdmin.from('tickets').select('*').eq('id', ticketId).single();
    if (!ticket) return NextResponse.json({ error: 'no ticket' }, { status: 404 });
    const { data: order } = await supabaseAdmin.from('orders_cache').select('*').eq('email', ticket.email_from).order('created_at', { ascending: false }).limit(1).single();
    const prompt = buildSupportPrompt('Your Store', ticket.body, order || {});

    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.4,
    });

    const draft = completion.choices[0].message.content;
    await supabaseAdmin.from('tickets').update({ drafted_reply: draft, status: 'drafted' }).eq('id', ticketId);
    return NextResponse.json({ draft });
  }
  if (action === 'send') {
    // In production, send via Gmail API here
    await supabaseAdmin.from('tickets').update({ status: 'sent' }).eq('id', ticketId);
    return NextResponse.json({ ok: true, mock: true, message: 'In production, call Gmail API to send' });
  }
  return NextResponse.json({ error: 'invalid action' }, { status: 400 });
}
