"use client";

import React, { createContext, useContext, ReactNode } from "react";
import { useWallet } from "@/lib/hooks/useWallet";

interface WalletContextType {
  account: string;
  isConnected: boolean;
  chainId: number | null;
  balance: string;
  publicClient: any;
  walletClient: any;
  loading: boolean;
  connectWallet: () => Promise<void>;
  disconnectWallet: () => void;
  switchNetwork: (chainId: number) => Promise<void>;
  loadUserBalance: () => Promise<void>;
}

const WalletContext = createContext<WalletContextType | undefined>(undefined);

export function WalletProvider({ children }: { children: ReactNode }) {
  const wallet = useWallet();

  return (
    <WalletContext.Provider value={wallet}>{children}</WalletContext.Provider>
  );
}

export function useWalletContext() {
  const context = useContext(WalletContext);
  if (context === undefined) {
    throw new Error("useWalletContext must be used within a WalletProvider");
  }
  return context;
}
