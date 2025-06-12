export default function HeroSection() {
  return (
    <div className="relative py-20 px-6 overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-r from-green-500/10 via-blue-500/5 to-purple-500/10" />

      <div className="max-w-7xl mx-auto relative">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <div>
            <h1 className="text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
              Curate & Fund
              <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-green-400 to-blue-400">
                Decentralized Science
              </span>
            </h1>

            <p className="text-xl text-gray-300 mb-8 leading-relaxed">
              The DeSci Launchpad enables the community to launch new BioDAOs
              through a 3-phase process: Curation, Fundraising, and Liquidity
              Provisioning.
            </p>

            <div className="flex items-center gap-6 mb-8">
              <div className="text-center">
                <div className="text-3xl font-bold text-green-400">
                  12 BioDAOs
                </div>
                <div className="text-gray-400 text-sm">Launched & Funded</div>
              </div>

              <div className="text-center">
                <div className="text-3xl font-bold text-blue-400">$24.3M</div>
                <div className="text-gray-400 text-sm">Raised for Research</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-purple-400">$15M</div>
                <div className="text-gray-400 text-sm">
                  Deployed in Research
                </div>
              </div>
            </div>

            <button className="px-8 py-4 bg-gradient-to-r from-green-500 to-blue-500 hover:from-green-600 hover:to-blue-600 text-white font-bold rounded-xl transition-all transform hover:scale-105">
              Learn more about the mechanics
            </button>
          </div>

          <div className="relative">
            <div className="absolute inset-0 bg-gradient-to-br from-green-500/20 to-blue-500/20 rounded-3xl blur-3xl" />
            <div className="relative bg-gray-900/50 border border-gray-800/50 rounded-3xl p-8 backdrop-blur-sm">
              <div className="grid grid-cols-2 gap-6">
                {[
                  "Longevity",
                  "Men's Health",
                  "Metabolic Health",
                  "Oncology",
                  "Chronic Diseases",
                  "Gut Health",
                  "Rare Diseases",
                  "Brain Longevity",
                ].map((category, idx) => (
                  <div
                    key={idx}
                    className="px-4 py-3 bg-gray-800/50 rounded-xl border border-gray-700/50 text-center"
                  >
                    <span className="text-gray-300 text-sm">{category}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
