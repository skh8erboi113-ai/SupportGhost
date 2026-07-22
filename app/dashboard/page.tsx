import { supabaseAdmin } from '@/lib/supabaseAdmin';
import TicketRow from '@/components/TicketRow';
import Header from '@/components/Header';

export const dynamic = 'force-dynamic';

export default async function Dashboard() {
  const { data, error } = await supabaseAdmin
    .from('tickets')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(20);

  const tickets = data || [];

  return (
    <div className="min-h-screen bg-black text-white">
      <Header />
      <div className="max-w-5xl mx-auto p-6">
        <h1 className="text-3xl font-bold">Inbox</h1>

        {error ? (
          <div className="mt-6 rounded-xl border border-red-900 bg-red-950/40 p-4 text-sm text-red-200">
            Unable to load tickets right now.
          </div>
        ) : tickets.length === 0 ? (
          <div className="mt-6 rounded-xl border border-zinc-800 bg-zinc-950 p-4 text-sm text-zinc-400">
            No tickets yet. New support emails will show up here.
          </div>
        ) : (
          <div className="mt-6 grid gap-3">
            {tickets.map((ticket: any) => (
              <TicketRow key={ticket.id} ticket={ticket} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
