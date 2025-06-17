import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import WalletHeader from "@/components/layout/WalletHeader";
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
  title: "DeSci Launchpad",
  description: "Curate & Fund Decentralized Science",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        <WalletProvider>
          <WalletHeader />
          <main>{children}</main>
          <Footer />
        </WalletProvider>
      </body>
    </html>
  );
}
