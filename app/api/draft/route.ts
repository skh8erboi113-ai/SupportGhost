import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseAdmin';
import { openai } from '@/lib/openai';
import { buildSupportPrompt } from '@/lib/prompts';

export async function POST(req: NextRequest) {
  try {
    const { action, ticketId } = await req.json();

    if (action !== 'generate' || !ticketId) {
      return NextResponse.json({ error: 'Invalid request' }, { status: 400 });
    }

    const { data: ticket, error: ticketError } = await supabaseAdmin
      .from('tickets')
      .select('*')
      .eq('id', ticketId)
      .maybeSingle();

    if (ticketError || !ticket) {
      return NextResponse.json({ error: 'Ticket not found' }, { status: 404 });
    }

    const { data: order } = await supabaseAdmin
      .from('orders_cache')
      .select('*')
      .eq('email', ticket.email_from)
      .limit(1)
      .maybeSingle();

    const prompt = buildSupportPrompt('Your Store', ticket.body || '', order || {});
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.4,
    });

    const draft = completion.choices[0]?.message?.content || 'Unable to generate a draft right now.';

    const { error: updateError } = await supabaseAdmin
      .from('tickets')
      .update({ drafted_reply: draft, status: 'drafted' })
      .eq('id', ticketId);

    if (updateError) {
      return NextResponse.json({ error: 'Draft generated but ticket could not be updated' }, { status: 500 });
    }

    return NextResponse.json({ draft });
  } catch (error: any) {
    return NextResponse.json({ error: error.message || 'Failed to generate draft' }, { status: 500 });
  }
}
