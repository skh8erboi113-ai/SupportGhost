"use client";

import { useState } from 'react';

export default function TicketRow({ ticket }: { ticket: any }) {
  const [draft, setDraft] = useState(ticket.drafted_reply || '');
  const [isGenerating, setIsGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleGenerateDraft = async () => {
    setIsGenerating(true);
    setError(null);

    try {
      const response = await fetch('/api/draft', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'generate', ticketId: ticket.id }),
      });

      const payload = await response.json();

      if (!response.ok) {
        throw new Error(payload.error || 'Unable to generate draft');
      }

      setDraft(payload.draft || '');
    } catch (err: any) {
      setError(err.message || 'Unable to generate draft');
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <div className="border border-zinc-800 rounded-xl p-4 bg-zinc-950">
      <div className="flex justify-between text-xs text-zinc-500">
        <span>{ticket.email_from}</span>
        <span>{ticket.status}</span>
      </div>
      <p className="mt-2 text-sm font-bold">{ticket.subject}</p>
      <p className="mt-1 text-sm text-zinc-400">{ticket.body?.slice(0, 120)}</p>
      <div className="mt-3 bg-black border border-zinc-800 p-3 rounded-lg text-sm">
        {draft || 'No draft'}
      </div>

      {error ? (
        <p className="mt-2 text-xs text-red-300">{error}</p>
      ) : null}

      <button
        onClick={handleGenerateDraft}
        disabled={isGenerating}
        className="mt-3 bg-white text-black px-3 py-1.5 rounded-full text-xs font-bold disabled:opacity-60"
      >
        {isGenerating ? 'Generating…' : 'Generate Draft'}
      </button>
    </div>
  );
}
