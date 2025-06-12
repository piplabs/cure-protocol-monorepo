import { Globe, Play } from "lucide-react";
import { Project } from "@/lib/types";
import { projectDetails } from "@/lib/data/projectDetails";

interface MarketHypothesisProps {
  project: Project;
}

export default function MarketHypothesis({ project }: MarketHypothesisProps) {
  const data = projectDetails[project.id]?.marketHypothesis;

  if (!data) return null;

  return (
    <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-8 backdrop-blur-sm mt-8">
      <h2 className="text-2xl font-bold text-white mb-8">Market Hypothesis</h2>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {data.stats.map((stat, idx) => (
          <div key={idx} className="text-center">
            <div className="text-3xl font-bold text-green-400 mb-2">
              {stat.value}
            </div>
            <div className="text-gray-400 text-sm">{stat.label}</div>
          </div>
        ))}
      </div>

      <div className="mb-8">
        <p className="text-gray-300 text-lg leading-relaxed mb-6">
          {data.description}
        </p>
      </div>

      <div className="space-y-8">
        {data.focusAreas.map((area, idx) => (
          <div key={idx}>
            <h3 className="text-xl font-bold text-white mb-4">
              {idx + 1}. {area.title}
            </h3>
            <p className="text-gray-300 leading-relaxed">{area.description}</p>
          </div>
        ))}
      </div>

      <div className="mt-8 flex gap-4">
        <button className="flex items-center gap-2 px-4 py-2 bg-gray-800/50 hover:bg-gray-700/50 border border-gray-700 rounded-lg text-gray-300 transition-colors">
          <Globe className="w-4 h-4" />
          Download litepaper
        </button>
        <button className="flex items-center gap-2 px-4 py-2 bg-gray-800/50 hover:bg-gray-700/50 border border-gray-700 rounded-lg text-gray-300 transition-colors">
          <Play className="w-4 h-4" />
          View pitch deck
        </button>
      </div>
    </div>
  );
}
