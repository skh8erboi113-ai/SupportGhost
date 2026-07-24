import "./globals.css";
import { Analytics } from '@vercel/analytics/next';
import { SpeedInsights } from '@vercel/speed-insights/next';

export const metadata = { title: "SupportGhost - AI Support for Shopify", description: "Auto-draft 80% of WISMO tickets" };
export default function RootLayout({ children }: { children: React.ReactNode }) { 
  return (
    <html lang="en">
      <body>
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  ); 
}
