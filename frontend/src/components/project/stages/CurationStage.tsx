import { Project } from "@/lib/types";
import { projectDetails } from "@/lib/data/projectDetails";

interface CurationStageProps {
  project: Project;
}

export default function CurationStage({ project }: CurationStageProps) {
  const details = projectDetails[project.id]?.curationDetails;

  if (!details) return <div>Curation details not available</div>;

  return (
    <div className="space-y-8">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse" />
              <span className="text-green-400 font-medium">Live</span>
            </div>
            <h3 className="text-xl font-bold text-white mb-4">Curation</h3>

            <div className="grid grid-cols-2 gap-6 mb-6">
              <div>
                <div className="text-3xl font-bold text-green-400 mb-2">
                  {details.bioCommitted}
                  <span className="text-lg text-gray-400 ml-2">BIO</span>
                </div>
                <div className="text-gray-400 text-sm">BIO committed</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-white mb-2">
                  {details.curationLimit}
                  <span className="text-lg text-gray-400 ml-2">BIO</span>
                </div>
                <div className="text-gray-400 text-sm">Curation Limit</div>
              </div>
            </div>

            <div className="grid grid-cols-4 gap-4 p-4 bg-gray-800/30 rounded-xl border border-gray-700/50">
              <div className="text-center">
                <div className="text-lg font-bold text-white">
                  {details.totalSupply}
                </div>
                <div className="text-xs text-gray-400">Total Supply</div>
              </div>
              <div className="text-center">
                <div className="text-lg font-bold text-white">
                  {details.curatorAllocation}
                </div>
                <div className="text-xs text-gray-400">Curator Allocation</div>
              </div>
              <div className="text-center">
                <div className="text-lg font-bold text-white">
                  {details.curationFDV}
                </div>
                <div className="text-xs text-gray-400">Curation FDV</div>
              </div>
              <div className="text-center">
                <div className="text-lg font-bold text-white">
                  {details.numCurators}
                </div>
                <div className="text-xs text-gray-400">Number of Curators</div>
              </div>
            </div>
          </div>

          <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
            <h3 className="text-xl font-bold text-white mb-4">
              Curation Details
            </h3>
            <p className="text-gray-300 mb-6">
              Signal support for a BioDAO by committing BIO tokens in exchange
              for BioDAO tokens if the DAO raises successfully. This curation
              stage filters which projects advance to launch via the BIO
              launchpad, rewarding participants with vesting BioDAO tokens.
            </p>

            <div className="space-y-4">
              <div className="flex justify-between">
                <span className="text-gray-400">Vesting Period + Cliff</span>
                <span className="text-white">{details.vestingPeriod}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">
                  Token supply available for curators
                </span>
                <span className="text-white">{details.tokenSupply}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Curator Lockup</span>
                <span className="text-white">{details.curatorLockup}</span>
              </div>
            </div>

            <button className="w-full mt-6 px-4 py-2 bg-gray-800/50 hover:bg-gray-700/50 border border-gray-700 rounded-lg text-gray-300 transition-colors">
              📄 Read Curation Docs
            </button>
          </div>
        </div>

        <div className="space-y-6">
          <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm">
            <h3 className="text-lg font-bold text-white mb-4">
              Commit / Withdraw
            </h3>

            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-gray-400">1 BIO = </span>
                <span className="text-white">22.22 vREFLEX</span>
              </div>

              <div className="space-y-2">
                <label className="text-gray-400 text-sm">
                  You've committed
                </label>
                <div className="text-right text-gray-400">0 BIO</div>
              </div>

              <div className="space-y-2">
                <label className="text-gray-400 text-sm">Commit</label>
                <div className="relative">
                  <input
                    type="text"
                    placeholder="0.00"
                    className="w-full bg-gray-800/50 border border-gray-700 rounded-xl px-4 py-3 text-white text-right pr-16"
                  />
                  <div className="absolute right-3 top-1/2 -translate-y-1/2 text-white font-medium">
                    BIO
                  </div>
                </div>
                <div className="text-right text-xs text-gray-500">
                  Base Balance: 0 BIO
                </div>
              </div>

              <div className="flex items-center gap-2 text-xs">
                <input type="checkbox" className="rounded border-gray-600" />
                <span className="text-gray-400">
                  I accept the terms and conditions of this curation
                </span>
              </div>

              <button className="w-full bg-green-500 hover:bg-green-600 text-black font-bold py-3 rounded-xl transition-colors">
                Connect
              </button>

              <div className="text-xs text-gray-500 p-3 bg-gray-800/30 rounded-lg border border-gray-700/50">
                A 5% fee applies if you withdraw before the curation phase ends.
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
