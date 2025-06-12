import { ChevronRight, Brain, ArrowUpRight, Shield } from "lucide-react";
import { Project } from "@/lib/types";
import { projectDetails } from "@/lib/data/projectDetails";

interface AMMStageProps {
  project: Project;
}

export default function AMMStage({ project }: AMMStageProps) {
  const tokenomics = projectDetails[project.id]?.tokenomics;

  return (
    <div className="space-y-8">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2">
          <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl font-bold text-white">AMM</h3>
              <div className="flex items-center gap-4">
                <button className="px-3 py-1 bg-gray-800/50 text-gray-300 rounded-lg border border-gray-700/50 hover:bg-gray-700/50 transition-colors">
                  Swap
                </button>
                <span className="text-green-400 font-medium">
                  Bonding Curve
                </span>
              </div>
            </div>

            <div className="aspect-[4/3] bg-gray-800/30 rounded-xl p-4 border border-gray-700/50 mb-6">
              <div className="h-full relative">
                <div className="absolute top-4 left-4 text-sm">
                  <div className="text-white">
                    NEURON/USD • 15 • Uniswap V3 | GeckoTerminal.com
                  </div>
                  <div className="text-red-400">
                    O: 0.0001401 H: 0.0001401 L: 0.0001364 C: 0.0001364
                    -0.0000037 (-2.66%)
                  </div>
                  <div className="text-gray-400">Volume 51M 734</div>
                </div>

                <div className="absolute bottom-0 left-0 right-0 h-2/3">
                  <svg className="w-full h-full" viewBox="0 0 400 200">
                    <defs>
                      <linearGradient
                        id="priceGradient"
                        x1="0%"
                        y1="0%"
                        x2="0%"
                        y2="100%"
                      >
                        <stop
                          offset="0%"
                          stopColor="#10b981"
                          stopOpacity="0.3"
                        />
                        <stop
                          offset="100%"
                          stopColor="#10b981"
                          stopOpacity="0"
                        />
                      </linearGradient>
                    </defs>
                    <path
                      d="M 20 180 Q 80 160 120 140 T 200 120 T 280 100 T 360 80"
                      stroke="#10b981"
                      strokeWidth="2"
                      fill="none"
                    />
                    <path
                      d="M 20 180 Q 80 160 120 140 T 200 120 T 280 100 T 360 80 L 360 200 L 20 200 Z"
                      fill="url(#priceGradient)"
                    />
                  </svg>
                </div>

                <div className="absolute bottom-4 left-4 right-4 flex justify-between text-xs text-gray-400">
                  <span>27</span>
                  <span>29</span>
                  <span>31</span>
                  <span>Jun</span>
                  <span>01</span>
                  <span>7</span>
                  <span>10</span>
                </div>
              </div>
            </div>

            {tokenomics && (
              <div className="grid grid-cols-4 gap-4 text-center">
                <div>
                  <div className="text-xs text-gray-400 mb-1">Price</div>
                  <div className="text-white font-medium">
                    {tokenomics.price}
                  </div>
                </div>
                <div>
                  <div className="text-xs text-gray-400 mb-1">24h Volume</div>
                  <div className="text-white font-medium">
                    {tokenomics.volume24h}
                  </div>
                </div>
                <div>
                  <div className="text-xs text-gray-400 mb-1">Market Cap</div>
                  <div className="text-white font-medium">
                    {tokenomics.marketCap}
                  </div>
                </div>
                <div>
                  <div className="text-xs text-gray-400 mb-1">Holders</div>
                  <div className="text-white font-medium">
                    {tokenomics.holders}
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        <div className="space-y-6">
          <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
            <h3 className="text-lg font-bold text-white mb-4">Swap</h3>

            <div className="space-y-4">
              <div className="bg-gray-800/50 border border-gray-700 rounded-xl p-4">
                <div className="flex justify-between items-center mb-3">
                  <span className="text-gray-400 text-sm">From</span>
                  <span className="text-gray-400 text-sm">Balance: 0</span>
                </div>
                <div className="flex items-center justify-between">
                  <input
                    type="text"
                    placeholder="0"
                    className="bg-transparent text-2xl font-bold text-white w-full outline-none"
                  />
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-sm font-bold">E</span>
                    </div>
                    <span className="text-white font-medium">ETH</span>
                    <ChevronRight className="w-4 h-4 text-gray-400" />
                  </div>
                </div>
                <div className="text-right text-gray-400 text-sm mt-2">
                  ≈ $2,737.6
                </div>
              </div>

              <div className="flex justify-center">
                <button className="p-2 bg-gray-800 hover:bg-gray-700 rounded-full border border-gray-600 transition-colors">
                  <ArrowUpRight className="w-4 h-4 text-gray-400 rotate-90" />
                </button>
              </div>

              <div className="bg-gray-800/50 border border-gray-700 rounded-xl p-4">
                <div className="flex justify-between items-center mb-3">
                  <span className="text-gray-400 text-sm">To</span>
                  <span className="text-gray-400 text-sm">Balance: 0</span>
                </div>
                <div className="flex items-center justify-between">
                  <input
                    type="text"
                    placeholder="20058..."
                    className="bg-transparent text-2xl font-bold text-white w-full outline-none"
                  />
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 bg-purple-500 rounded-full flex items-center justify-center">
                      <Brain className="w-4 h-4 text-white" />
                    </div>
                    <span className="text-white font-medium">NEURON</span>
                    <ChevronRight className="w-4 h-4 text-gray-400" />
                  </div>
                </div>
                <div className="text-right text-gray-400 text-sm mt-2">
                  ≈ $2,728.31 (-0.34%)
                </div>
              </div>

              <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50">
                <div className="text-center">
                  <div className="text-white font-medium mb-2">
                    Receive (incl. costs)
                  </div>
                  <div className="text-2xl font-bold text-white">
                    20,034,944.057
                  </div>
                  <div className="text-sm text-gray-400 mt-1">
                    1 ETH = 20,058,143.27
                    <br />
                    NEURON (≈ $2,728.31)
                  </div>
                </div>
              </div>

              <button className="w-full bg-green-500 hover:bg-green-600 text-black font-bold py-4 rounded-xl transition-colors">
                Connect Wallet
              </button>

              <div className="text-center text-xs text-gray-500">
                <span className="flex items-center justify-center gap-1">
                  <Shield className="w-3 h-3" />
                  Powered by CoW Protocol
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
