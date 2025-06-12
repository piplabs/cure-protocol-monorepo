import { Brain } from "lucide-react";
import { Project } from "@/lib/types";
import { getStatusColor } from "@/lib/utils/formatters";
import { projectDetails } from "@/lib/data/projectDetails";

interface ProjectHeaderProps {
  project: Project;
}

export default function ProjectHeader({ project }: ProjectHeaderProps) {
  const details = projectDetails[project.id];

  return (
    <div className="flex items-start gap-8 mb-8">
      <div className="w-32 h-32 bg-gradient-to-br from-gray-800 to-gray-900 rounded-2xl flex items-center justify-center border border-gray-700/50">
        <div className="w-16 h-16 bg-gradient-to-br from-green-500 to-blue-500 rounded-xl flex items-center justify-center">
          <Brain className="w-8 h-8 text-white" />
        </div>
      </div>

      <div className="flex-1">
        <div className="flex items-center gap-3 mb-2">
          <h1 className="text-4xl font-bold text-white">{project.name}</h1>
          <span
            className={`px-3 py-1 rounded-full text-sm font-medium border ${getStatusColor(
              project.status
            )}`}
          >
            {project.category}
          </span>
        </div>
        <p className="text-gray-300 text-lg mb-4">
          {details?.fullDescription || project.description}
        </p>
        <div className="flex flex-wrap gap-2">
          {project.tags.map((tag, idx) => (
            <span
              key={idx}
              className="px-3 py-1 bg-gray-800/50 text-gray-300 text-sm rounded-lg border border-gray-700/50"
            >
              {tag}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}
