"use client";

import Link from "next/link";

export default function Navigation() {
  return (
    <nav className="border-b border-gray-800/50 bg-black/50 backdrop-blur-sm sticky top-0 z-50">
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
              <button className="text-gray-400 hover:text-white transition-colors">
                Dashboard
              </button>
              <button className="text-white font-medium">Launchpad</button>
              <button className="text-gray-400 hover:text-white transition-colors">
                Portfolio
              </button>
              <button className="text-gray-400 hover:text-white transition-colors">
                Bridge
              </button>
            </div>
          </div>

          <button className="px-4 py-2 bg-green-500 hover:bg-green-600 text-black font-medium rounded-lg transition-colors">
            Login
          </button>
        </div>
      </div>
    </nav>
  );
}
