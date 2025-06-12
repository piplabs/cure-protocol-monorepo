import { DollarSign, Coins, ArrowUpRight, ExternalLink } from "lucide-react";
import { Project } from "@/lib/types";
import { projectDetails } from "@/lib/data/projectDetails";

interface StakingStageProps {
  project: Project;
}

export default function StakingStage({ project }: StakingStageProps) {
  const stakingData = projectDetails[project.id]?.staking;

  return (
    <div className="space-y-8">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-xl font-bold text-white">Stake FRAX</h3>
            <button className="p-2 hover:bg-gray-800 rounded-lg transition-colors">
              <div className="w-5 h-5 border border-gray-400 rounded"></div>
            </button>
          </div>

          <div className="space-y-6">
            <div className="flex items-center justify-between p-4 bg-gray-800/50 rounded-xl border border-gray-700/50">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                  <DollarSign className="w-4 h-4 text-white" />
                </div>
                <span className="text-white font-medium">FRAX</span>
              </div>
              <div className="text-right">
                <div className="text-white font-bold">0</div>
                <div className="text-gray-400 text-sm">MAX: 0</div>
              </div>
            </div>

            <div className="flex items-center justify-center">
              <div className="flex items-center gap-2 p-2 bg-gray-800/50 rounded-lg border border-gray-700/50">
                <ArrowUpRight className="w-4 h-4 text-gray-400" />
                <ArrowUpRight className="w-4 h-4 text-gray-400 rotate-180" />
              </div>
            </div>

            <div className="flex items-center justify-between p-4 bg-gray-800/50 rounded-xl border border-gray-700/50">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                  <Coins className="w-4 h-4 text-white" />
                </div>
                <span className="text-white font-medium">sFRAX</span>
              </div>
              <div className="text-right">
                <div className="text-white font-bold">0</div>
              </div>
            </div>

            <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50">
              <div className="flex justify-between items-center mb-2">
                <span className="text-gray-400 text-sm">SWAP FEE</span>
                <span className="text-gray-400 text-sm">0.00%</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-400 text-sm">(0.00 FRAX)</span>
              </div>
              <div className="border-t border-gray-700 my-3"></div>
              <div className="flex justify-between items-center">
                <span className="text-white font-medium">MIN. RECEIVED</span>
                <span className="text-white font-bold">0.000 sFRAX</span>
              </div>
            </div>

            <button className="w-full bg-white hover:bg-gray-100 text-black font-bold py-4 rounded-xl transition-colors">
              Connect wallet
            </button>
          </div>
        </div>

        <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
          <h3 className="text-lg font-bold text-white mb-6">Current Stake</h3>

          <div className="space-y-6">
            {stakingData && (
              <>
                <div className="text-center">
                  <div className="text-gray-400 text-sm mb-1">SFRAX SUPPLY</div>
                  <div className="text-2xl font-bold text-white">
                    {stakingData.totalStaked}
                  </div>
                </div>

                <div className="text-center">
                  <div className="text-gray-400 text-sm mb-1">
                    EST. CURRENT APY
                  </div>
                  <div className="text-2xl font-bold text-green-400">
                    {stakingData.apr}
                  </div>
                </div>

                <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50 space-y-4">
                  <div>
                    <div className="text-gray-400 text-sm mb-1">
                      Your staked amount
                    </div>
                    <div className="text-white font-medium">
                      {stakingData.userStaked} sFRAX ({stakingData.userStaked}{" "}
                      FRAX)
                    </div>
                  </div>

                  <div>
                    <div className="text-gray-400 text-sm mb-1">
                      Your FRAX balance
                    </div>
                    <div className="text-white font-medium">0.00 FRAX</div>
                  </div>

                  <div>
                    <div className="text-gray-400 text-sm mb-1">
                      Your share of the pool
                    </div>
                    <div className="text-white font-medium">0.00%</div>
                  </div>

                  <div>
                    <div className="text-gray-400 text-sm mb-1">
                      FRAX per sFRAX
                    </div>
                    <div className="text-white font-medium">1.1313 FRAX</div>
                  </div>
                </div>
              </>
            )}

            <div className="text-right">
              <div className="text-gray-400 text-xs mb-2">CONTRACTS</div>
              <div className="space-y-1">
                <div className="flex items-center justify-end gap-2">
                  <span className="text-blue-400 text-sm">FRAX</span>
                  <ExternalLink className="w-3 h-3 text-gray-400" />
                </div>
                <div className="flex items-center justify-end gap-2">
                  <span className="text-green-400 text-sm">sFRAX</span>
                  <ExternalLink className="w-3 h-3 text-gray-400" />
                </div>
                <div className="flex items-center justify-end gap-2">
                  <span className="text-gray-400 text-sm">Docs</span>
                  <ExternalLink className="w-3 h-3 text-gray-400" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-xl font-bold text-white">Reward History</h3>
        </div>

        <div className="text-center mb-6">
          <div className="text-gray-400 text-sm mb-2">
            Track your sFRAX earnings over time.
          </div>

          <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50 mb-4 max-w-md mx-auto">
            <input
              type="text"
              placeholder="Enter address"
              className="w-full bg-transparent text-white placeholder-gray-500 outline-none text-center"
            />
          </div>
        </div>

        <div className="grid grid-cols-4 gap-4 mb-4 text-xs text-gray-400 uppercase tracking-wider">
          <div>SFRAX BALANCE</div>
          <div>SFRAX REWARDED</div>
          <div>AVERAGE APY</div>
          <div>SFRAX PRICE</div>
        </div>

        <div className="grid grid-cols-4 gap-4 mb-6 text-sm">
          <div className="text-white">—</div>
          <div className="text-white">—</div>
          <div className="text-blue-400">More info</div>
          <div className="text-white">
            $1.13
            <br />
            <span className="text-xs text-gray-400">🗓 1.131284</span>
          </div>
        </div>

        <div className="text-center text-gray-500 py-8">
          <div className="text-lg mb-2">Enter address(es) to track above.</div>
        </div>

        <div className="grid grid-cols-4 gap-4 mb-4 text-xs text-gray-400 uppercase tracking-wider border-t border-gray-700 pt-6">
          <div>Date</div>
          <div>Earnings (FRAX)</div>
          <div>APY</div>
          <div>sFRAX Balance</div>
        </div>

        <div className="text-center text-gray-500 py-8">
          <div className="text-lg">No records</div>
        </div>
      </div>
    </div>
  );
}
