#!/bin/bash
set -e
echo "👻 Building SupportGhost..."
# Clean wrong files you uploaded to root
rm -f route.ts README.md
rm -rf app lib components supabase
echo "Cleaned old files"

mkdir -p app/api/shopify/webhook app/api/gmail/webhook app/api/draft app/api/stripe/webhook app/api/stripe/create-checkout app/dashboard lib components supabase

cat > package.json << 'JSON'
{
  "name": "supportghost",
  "version": "0.1.0",
  "private": true,
  "scripts": { "dev": "next dev", "build": "next build", "start": "next start" },
  "dependencies": {
    "@supabase/supabase-js": "^2.45.0",
    "next": "14.2.5",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "openai": "^4.52.0",
    "stripe": "^15.9.0",
    "@stripe/stripe-js": "^2.4.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "@types/node": "^20.12.0",
    "@types/react": "^18.3.0",
    "tailwindcss": "^3.4.1",
    "postcss": "^8.4.33",
    "autoprefixer": "^10.4.19"
  }
}
JSON

cat > .env.example << 'ENV'
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
OPENAI_API_KEY=sk-proj-xxxx
STRIPE_SECRET_KEY=sk_test_xxx
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
NEXT_PUBLIC_APP_URL=http://localhost:3000
ENV

cat > tailwind.config.js << 'JS'
/** @type {import('tailwindcss').Config} */
module.exports = { content: ["./app/**/*.{js,ts,jsx,tsx}", "./components/**/*.{js,ts,jsx,tsx}"], theme: { extend: {} }, plugins: [] }
JS

cat > postcss.config.js << 'JS'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } }
JS

cat > next.config.mjs << 'JS'
const nextConfig = {}; export default nextConfig;
JS

cat > tsconfig.json << 'JSON'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"], "allowJs": true, "skipLibCheck": true, "strict": true, "noEmit": true, "esModuleInterop": true,
    "module": "esnext", "moduleResolution": "bundler", "resolveJsonModule": true, "isolatedModules": true, "jsx": "preserve",
    "incremental": true, "plugins": [{ "name": "next" }], "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"], "exclude": ["node_modules"]
}
JSON

cat > app/globals.css << 'CSS'
@tailwind base; @tailwind components; @tailwind utilities;
body { background: #0a0a0a; color: white; }
CSS

cat > app/layout.tsx << 'TSX'
import "./globals.css";
export const metadata = { title: "SupportGhost - AI Support for Shopify", description: "Auto-draft 80% of WISMO tickets" };
export default function RootLayout({ children }: { children: React.ReactNode }) { return <html lang="en"><body>{children}</body></html>; }
TSX

cat > app/page.tsx << 'TSX'
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
TSX

cat > lib/supabase.ts << 'TS'
import { createClient } from '@supabase/supabase-js';
export const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!);
TS

cat > lib/supabaseAdmin.ts << 'TS'
import { createClient } from '@supabase/supabase-js';
export const supabaseAdmin = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!);
TS

cat > lib/openai.ts << 'TS'
import OpenAI from 'openai';
export const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
TS

cat > lib/stripe.ts << 'TS'
import Stripe from 'stripe';
export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: '2024-06-20' as any });
TS

cat > lib/prompts.ts << 'TS'
export function buildSupportPrompt(storeName: string, ticketBody: string, order: any) {
  return `You are support for ${storeName}. Customer: ${ticketBody}. Order: ${order?.shopify_order_id} Status: ${order?.status} Tracking: ${order?.tracking}. Draft 3 sentence helpful reply with tracking link.`;
}
TS

cat > components/Header.tsx << 'TSX'
export default function Header(){return <div className="border-b border-zinc-900 p-4 flex justify-between"><b>👻 SupportGhost</b><span className="text-xs text-zinc-500">$49/mo • 432 tickets</span></div>}
TSX

cat > components/TicketRow.tsx << 'TSX'
"use client";
export default function TicketRow({ ticket }: { ticket: any }) {
  return (
    <div className="border border-zinc-800 rounded-xl p-4 bg-zinc-950">
      <div className="flex justify-between text-xs text-zinc-500"><span>{ticket.email_from}</span><span>{ticket.status}</span></div>
      <p className="mt-2 text-sm font-bold">{ticket.subject}</p>
      <p className="mt-1 text-sm text-zinc-400">{ticket.body?.slice(0,120)}</p>
      <div className="mt-3 bg-black border border-zinc-800 p-3 rounded-lg text-sm">{ticket.drafted_reply || 'No draft'}</div>
      <button onClick={async()=>{await fetch('/api/draft',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({action:'generate',ticketId:ticket.id})});location.reload();}} className="mt-3 bg-white text-black px-3 py-1.5 rounded-full text-xs font-bold">Generate Draft</button>
    </div>
  );
}
TSX

cat > app/dashboard/page.tsx << 'TSX'
import { supabaseAdmin } from '@/lib/supabaseAdmin';
import TicketRow from '@/components/TicketRow';
import Header from '@/components/Header';
export const dynamic='force-dynamic';
export default async function Dashboard(){
  const {data} = await supabaseAdmin.from('tickets').select('*').order('created_at',{ascending:false}).limit(20);
  const tickets=data||[{id:'1',email_from:'sarah@gmail.com',subject:'Where is order #1024?',body:'Hey where is order #1024??',drafted_reply:'Hi Sarah! Order #1024 shipped UPS 1Z999... Track: ups.com',status:'open'}];
  return (<div className="min-h-screen bg-black text-white"><Header/><div className="max-w-5xl mx-auto p-6"><h1 className="text-3xl font-bold">Inbox</h1><div className="mt-6 grid gap-3">{tickets.map((t:any)=><TicketRow key={t.id} ticket={t}/>)}</div></div></div>);
}
TSX

cat > app/api/draft/route.ts << 'TS'
import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseAdmin';
import { openai } from '@/lib/openai';
import { buildSupportPrompt } from '@/lib/prompts';
export async function POST(req: NextRequest){
  const {action,ticketId}=await req.json();
  if(action==='generate'){
    const {data:ticket}=await supabaseAdmin.from('tickets').select('*').eq('id',ticketId).single();
    const {data:order}=await supabaseAdmin.from('orders_cache').select('*').eq('email',ticket.email_from).limit(1).single();
    const prompt=buildSupportPrompt('Your Store',ticket.body,order||{});
    const completion=await openai.chat.completions.create({model:'gpt-4o-mini',messages:[{role:'user',content:prompt}],temperature:0.4});
    const draft=completion.choices[0].message.content;
    await supabaseAdmin.from('tickets').update({drafted_reply:draft,status:'drafted'}).eq('id',ticketId);
    return NextResponse.json({draft});
  }
  return NextResponse.json({error:'bad'}, {status:400});
}
TS

cat > app/api/shopify/webhook/route.ts << 'TS'
import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseAdmin';
export async function POST(req: NextRequest){
  const body=await req.json();
  await supabaseAdmin.from('orders_cache').upsert({shopify_order_id:body.id?.toString()||body.name,email:body.email||body.customer?.email,status:body.fulfillment_status||'unfulfilled',tracking:body.fulfillments?.[0]?.tracking_number||''});
  return NextResponse.json({ok:true});
}
TS

cat > app/api/gmail/webhook/route.ts << 'TS'
import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseAdmin';
export async function POST(req: NextRequest){
  const {email_from,subject,body}=await req.json();
  await supabaseAdmin.from('tickets').insert({email_from,subject,body,status:'open'});
  return NextResponse.json({ok:true});
}
TS

cat > app/api/stripe/create-checkout/route.ts << 'TS'
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
export async function GET(req: NextRequest){
  const url=process.env.NEXT_PUBLIC_APP_URL||'http://localhost:3000';
  try{
    const session=await stripe.checkout.sessions.create({mode:'subscription',line_items:[{price_data:{currency:'usd',product_data:{name:'SupportGhost Pro'},unit_amount:9900,recurring:{interval:'month'}},quantity:1}],success_url:`${url}/dashboard?success=1`,cancel_url:`${url}/?canceled=1`});
    return NextResponse.redirect(session.url!);
  }catch(e:any){return NextResponse.json({error:e.message});}
}
TS

cat > app/api/stripe/webhook/route.ts << 'TS'
import { NextRequest, NextResponse } from 'next/server';
export async function POST(req: NextRequest){return NextResponse.json({received:true});}
TS

cat > supabase/schema.sql << 'SQL'
enable extension if not exists pgcrypto;
create table if not exists stores (id uuid primary key default gen_random_uuid(), user_id uuid, shopify_domain text, access_token text, created_at timestamp default now());
create table if not exists orders_cache (id uuid primary key default gen_random_uuid(), shopify_order_id text, email text, status text, tracking text, created_at timestamp default now());
create index on orders_cache (email);
create table if not exists tickets (id uuid primary key default gen_random_uuid(), store_id uuid, email_from text, subject text, body text, drafted_reply text, status text default 'open', created_at timestamp default now());
alter table stores enable row level security; alter table tickets enable row level security; alter table orders_cache enable row level security;
create policy "allow all" on stores for all using (true) with check (true);
create policy "allow all" on tickets for all using (true) with check (true);
create policy "allow all" on orders_cache for all using (true) with check (true);
SQL

echo "✅ Files created! Now run: rm -f route.ts README.md && ls && npm install"
