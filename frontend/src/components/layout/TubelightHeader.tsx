"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { motion } from "framer-motion";
import { LucideIcon, Home, LayoutDashboard, Database } from "lucide-react";
import { useWalletContext } from "../providers/WalletProvider";
import { cn } from "@/lib/utils/cn";

interface NavItem {
  name: string;
  url: string;
  icon: LucideIcon;
}

interface TubelightHeaderProps {
  className?: string;
}

export default function TubelightHeader({ className }: TubelightHeaderProps) {
  const {
    isConnected,
    account,
    balance,
    loading,
    connectWallet,
    disconnectWallet,
  } = useWalletContext();

  const [showDropdown, setShowDropdown] = useState(false);
  
  const [activeTab, setActiveTab] = useState("Home");
  // const [isMobile, setIsMobile] = useState(false);

  const navItems: NavItem[] = [
    { name: "Home", url: "/", icon: Home },
    { name: "Projects", url: "/#projects", icon: LayoutDashboard },
    { name: "Data", url: "/data", icon: Database },
  ];

  // useEffect(() => {
  //   const handleResize = () => {
  //     setIsMobile(window.innerWidth < 768);
  //   };

  //   handleResize();
  //   window.addEventListener("resize", handleResize);
  //   return () => window.removeEventListener("resize", handleResize);
  // }, []);

  useEffect(() => {
    const handleScroll = () => {
      const projectsSection = document.getElementById("projects");

      if (projectsSection) {
        const rect = projectsSection.getBoundingClientRect();
        const screenHeight = window.innerHeight;

        // Check if the projects section is centered in the viewport
        if (rect.top < screenHeight / 2 && rect.bottom > screenHeight / 2) {
          setActiveTab("Projects");
        } else {
          // If not centered, check if we are at the top of the page for 'Home'
          if (window.scrollY < 200) {
            setActiveTab("Home");
          }
        }
      }
    };

    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  // const handleScrollTo = (e: React.MouseEvent<HTMLAnchorElement, MouseEvent>, url: string) => {
  //   e.preventDefault();
  //   const targetId = url.substring(1); // remove '#'
  //   const targetElement = document.getElementById(targetId);
  //   if (targetElement) {
  //     targetElement.scrollIntoView({ behavior: 'smooth' });
  //   }
  // };

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
    <header
      className={cn(
        "fixed top-0 left-0 right-0 bg-gradient-to-r from-[#86C7E8]/30 to-[#106793]/30 backdrop-blur-sm z-50",
        className
      )}
    >
      <div className="max-w-7xl mx-auto px-6 py-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <Image
              src="/art/homepage/c-logo.svg"
              alt="Cure Protocol Logo"
              width={32}
              height={32}
            />
            <span className="hidden md:inline text-white text-xl font-bold">cure protocol</span>
          </Link>

          {/* Tubelight Navigation */}
          <div className="flex items-center gap-3 bg-gray-900/20 border border-gray-700/50 backdrop-blur-lg py-1 px-1 rounded-full shadow-lg">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive = activeTab === item.name;

              return (
                <Link
                  key={item.name}
                  href={item.url}
                  onClick={() => setActiveTab(item.name)}
                  className={cn(
                    "relative cursor-pointer text-sm font-semibold px-6 py-2 rounded-full transition-colors",
                    "text-gray-300 hover:text-white",
                    isActive && "bg-[#00d4ff]/20 text-[#00d4ff]"
                  )}
                >
                  <span className="hidden md:inline">{item.name}</span>
                  <span className="md:hidden">
                    <Icon size={18} strokeWidth={2.5} />
                  </span>
                  {isActive && (
                    <motion.div
                      layoutId="lamp"
                      className="absolute inset-0 w-full bg-[#00d4ff]/10 rounded-full -z-10"
                      initial={false}
                      transition={{
                        type: "spring",
                        stiffness: 300,
                        damping: 30,
                      }}
                    >
                      <div className="absolute -top-2 left-1/2 -translate-x-1/2 w-8 h-1 bg-white rounded-t-full">
                        <div className="absolute w-12 h-6 bg-[#00d4ff]/20 rounded-full blur-md -top-2 -left-2" />
                        <div className="absolute w-8 h-6 bg-[#00d4ff]/20 rounded-full blur-md -top-1" />
                        <div className="absolute w-4 h-4 bg-[#00d4ff]/20 rounded-full blur-sm top-0 left-2" />
                      </div>
                    </motion.div>
                  )}
                </Link>
              );
            })}
          </div>

          {/* Wallet Section */}
          {!isConnected ? (
            <button
              onClick={handleConnect}
              disabled={loading}
              className="px-4 py-2 bg-[#00d4ff] hover:bg-[#00b8e6] disabled:bg-gray-600 disabled:cursor-not-allowed text-black font-medium rounded-lg transition-colors flex items-center gap-2"
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
                <div className="text-white">
                  {parseFloat(balance).toFixed(4)}
                </div>
              </div>

              <div className="relative">
                <button
                  onClick={() => setShowDropdown(!showDropdown)}
                  className="text-right hover:bg-gray-800 px-3 py-2 rounded transition-colors"
                >
                  <div className="text-sm text-gray-400">Address</div>
                  <div className="text-sm text-white">
                    {account.slice(0, 6)}...{account.slice(-4)}
                  </div>
                </button>

                {showDropdown && (
                  <div className="absolute right-0 mt-2 w-48 bg-gray-900 border border-gray-700 rounded shadow-lg z-10">
                    <div className="py-1">
                      <div className="px-4 py-2 text-xs text-gray-400 border-b border-gray-700">
                        <div className="break-all">{account}</div>
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
