import Link from "next/link";
export default function Home() {
  return (
    <main className="min-h-screen bg-black text-white p-6">
      <div className="max-w-5xl mx-auto">
        <nav className="flex justify-between py-6"><span className="font-bold text-xl">👻 SupportGhost</span><Link href="/dashboard" className="bg-white text-black px-4 py-2 rounded-full text-sm font-bold">Dashboard</Link></nav>
        <div className="mt-20">
          <div className="inline-block border border-zinc-800 rounded-full px-3 py-1 text-xs text-zinc-400 mb-4">SHOPIFY APP • LIVE</div>
          <h1 className="text-5xl md:text-7xl font-bold leading-[0.9]">Stop answering<br/><span className="text-zinc-500">"Where is my order?"</span></h1>
          <p className="mt-6 text-xl text-zinc-400 max-w-xl">Plugs into Shopify + Gmail. Reads order status, auto-drafts 80% of support replies. Approve in 1 click.</p>
          <div className="mt-8 flex gap-3">
            <Link href="/dashboard" className="bg-white text-black px-6 py-3 rounded-full font-bold">Start Free Trial</Link>
            <span className="px-6 py-3 rounded-full border border-zinc-800 text-zinc-400">$49/mo after trial</span>
          </div>
        </div>
      </div>
    </main>
  );
}
