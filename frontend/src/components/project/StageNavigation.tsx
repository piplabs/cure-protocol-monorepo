import { Stage } from "@/lib/types";

interface StageNavigationProps {
  stages: Stage[];
  currentStage: string;
  onStageChange: (stage: string) => void;
}

export default function StageNavigation({
  stages,
  currentStage,
  onStageChange,
}: StageNavigationProps) {
  return (
    <div className="flex items-center gap-8 mb-8 border-b border-gray-800/50">
      {stages.map((stage) => (
        <button
          key={stage.id}
          onClick={() => onStageChange(stage.id)}
          className={`flex items-center gap-3 pb-4 px-2 relative transition-colors ${
            currentStage === stage.id
              ? "text-white border-b-2 border-green-500"
              : "text-gray-400 hover:text-gray-300"
          }`}
        >
          <div
            className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold ${
              currentStage === stage.id
                ? "bg-green-500 text-black"
                : "bg-gray-800 text-gray-400"
            }`}
          >
            {stage.number}
          </div>
          <span className="font-medium">{stage.label}</span>
        </button>
      ))}
    </div>
  );
}
