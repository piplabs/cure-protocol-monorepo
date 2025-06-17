"use client";

import { useState } from "react";
import Link from "next/link";
import { useWalletContext } from "../providers/WalletProvider";

export default function WalletHeader() {
  const {
    isConnected,
    account,
    balance,
    loading,
    connectWallet,
    disconnectWallet,
  } = useWalletContext();

  const [showDropdown, setShowDropdown] = useState(false);

  const handleConnect = async () => {
    try {
      await connectWallet();
    } catch (error) {
      console.error("Failed to connect wallet:", error);
    }
  };

  const handleDisconnect = () => {
    disconnectWallet();
    setShowDropdown(false);
  };

  return (
    <header className="border-b border-gray-800/50 bg-black/50 backdrop-blur-sm sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-8">
            <Link href="/" className="flex items-center gap-2">
              <div className="w-8 h-8 bg-gradient-to-br from-green-500 to-blue-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-sm">D</span>
              </div>
              <span className="text-white text-xl font-bold">DeSci</span>
            </Link>

            <div className="flex items-center gap-6">
              <Link
                href="/"
                className="text-gray-400 hover:text-white transition-colors"
              >
                Dashboard
              </Link>
              <Link href="/" className="text-white font-medium">
                Launchpad
              </Link>
              <Link
                href="/data"
                className="text-gray-400 hover:text-white transition-colors"
              >
                Data
              </Link>
            </div>
          </div>

          {!isConnected ? (
            <button
              onClick={handleConnect}
              disabled={loading}
              className="px-4 py-2 bg-green-500 hover:bg-green-600 disabled:bg-gray-600 disabled:cursor-not-allowed text-black font-medium rounded-lg transition-colors flex items-center gap-2"
            >
              {loading && (
                <div className="animate-spin rounded-full border-2 border-gray-300 border-t-black w-4 h-4" />
              )}
              {loading ? "Connecting..." : "Connect Wallet"}
            </button>
          ) : (
            <div className="flex items-center gap-4">
              <div className="text-right">
                <div className="text-sm text-gray-400">$IP Balance</div>
                <div className="">{parseFloat(balance).toFixed(4)}</div>
              </div>

              <div className="relative">
                <button
                  onClick={() => setShowDropdown(!showDropdown)}
                  className="text-right hover:bg-gray-800 px-3 py-2 rounded transition-colors"
                >
                  <div className="text-sm text-gray-400">Address</div>
                  <div className="text-sm">
                    {account.slice(0, 6)}...{account.slice(-4)}
                  </div>
                </button>

                {showDropdown && (
                  <div className="absolute right-0 mt-2 w-48 bg-gray-900 border border-gray-700 rounded shadow-lg z-10">
                    <div className="py-1">
                      <div className="px-4 py-2 text-xs text-gray-400 border-b border-gray-700">
                        <div className=" break-all">{account}</div>
                      </div>

                      <button
                        onClick={handleDisconnect}
                        className="w-full text-left px-4 py-2 text-sm hover:bg-gray-800 transition-colors flex items-center gap-2"
                      >
                        <span>🔌</span>
                        Disconnect Wallet
                      </button>

                      <button
                        onClick={() => setShowDropdown(false)}
                        className="w-full text-left px-4 py-2 text-sm hover:bg-gray-800 transition-colors text-gray-400"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
