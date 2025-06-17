import { Project } from "@/lib/types";

interface FundraisingStageProps {
  project: Project;
}

export default function FundraisingStage({}: FundraisingStageProps) {
  return (
    <div className="space-y-8">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-xl font-bold text-white">Fundraise</h3>
            <span className="px-3 py-1 bg-red-500/20 text-red-400 border border-red-500/30 rounded-full text-sm">
              Closed
            </span>
          </div>

          <div className="space-y-6">
            <div className="aspect-video bg-gradient-to-br from-purple-900/20 to-blue-900/20 rounded-xl relative overflow-hidden">
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="text-center">
                  <div className="text-6xl font-bold text-green-400 mb-2">
                    14.21K
                  </div>
                  <div className="text-gray-400">Total Contributions</div>
                  <div className="text-sm text-gray-500 mt-2">FDV: 158.73K</div>
                </div>
              </div>
              <div className="absolute bottom-4 left-4 right-4">
                <div className="bg-gray-800/80 backdrop-blur-sm rounded-lg p-3 border border-gray-700/50">
                  <div className="flex justify-between items-center">
                    <div>
                      <div className="text-lg font-bold text-white">1090</div>
                      <div className="text-xs text-gray-400">Contributors</div>
                    </div>
                    <div>
                      <div className="text-lg font-bold text-white">
                        94.72K SOL
                      </div>
                      <div className="text-xs text-gray-400">
                        Auction FDV ($10.95M)
                      </div>
                    </div>
                    <div>
                      <div className="text-lg font-bold text-white">
                        0.00095 SOL
                      </div>
                      <div className="text-xs text-gray-400">
                        Token Price ($0.15)
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50">
              <h4 className="text-white font-medium mb-3">Auction Details</h4>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-400">Auction Supply</span>
                  <span className="text-white">
                    15M CURES (15.00005751405272%)
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Minimum Raise</span>
                  <span className="text-white">2.98K SOL ($469.22K)</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Maximum Raise</span>
                  <span className="text-white">23.81K SOL ($3.75M)</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Auction Start Date</span>
                  <span className="text-white">02/18/2025 9:20 PM</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Auction End Date</span>
                  <span className="text-white">03/11/2025 9:00 AM</span>
                </div>
              </div>
            </div>

            <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50">
              <h4 className="text-white font-medium mb-3">How it works</h4>
              <div className="space-y-3 text-sm text-gray-300">
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 bg-green-500 text-black rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                    ✓
                  </div>
                  <span>Same price for all buyers</span>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 bg-green-500 text-black rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5">
                    ✓
                  </div>
                  <span>Price determined at the end of the auction</span>
                </div>
              </div>
            </div>

            <button className="w-full px-4 py-2 bg-gray-800/50 hover:bg-gray-700/50 border border-gray-700 rounded-lg text-gray-300 transition-colors">
              📄 Read Auction Docs
            </button>
          </div>
        </div>

        <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
          <h3 className="text-lg font-bold text-white mb-4">
            Settlement Price
          </h3>

          <div className="text-center mb-6">
            <div className="text-2xl font-bold text-white mb-2">
              1 <span className="text-green-400">SOL</span> = 1.06K{" "}
              <span className="text-purple-400">CURES</span>
            </div>
            <div className="text-gray-400 text-sm">$10/06</div>
          </div>

          <button className="w-full bg-green-500 hover:bg-green-600 text-black font-bold py-3 rounded-xl transition-colors mb-6">
            Connect Wallet
          </button>

          <div className="text-center text-gray-400 text-sm">
            <a
              href="#"
              className="text-green-400 hover:text-green-300 transition-colors"
            >
              View on Solscan
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
