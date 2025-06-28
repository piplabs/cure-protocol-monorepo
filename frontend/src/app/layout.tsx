import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import TubelightHeader from "@/components/layout/TubelightHeader";
import Footer from "@/components/layout/Footer";
import { WalletProvider } from "@/components/providers/WalletProvider";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Cure Protocol",
  description: "Curate & Fund Decentralized Science",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link href="https://fonts.googleapis.com/css2?family=Host+Grotesk:ital,wght@0,300..800;1,300..800&display=swap" rel="stylesheet" />
      </head>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
        style={{ fontFamily: '"Host Grotesk", sans-serif' }}
      >
        <WalletProvider>
          <TubelightHeader />
          <main className="pt-20">{children}</main>
          <Footer />
        </WalletProvider>
      </body>
    </html>
  );
}
