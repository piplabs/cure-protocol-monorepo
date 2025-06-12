"use client";

import Link from "next/link";
import { Project } from "../../lib/types";
import { getStatusColor, getStatusLabel } from "../../lib/utils/formatters";

interface ProjectCardProps {
  project: Project;
}

export default function ProjectCard({ project }: ProjectCardProps) {
  return (
    <Link href={`/project/${project.id}`}>
      <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 hover:border-green-500/30 transition-all duration-300 cursor-pointer backdrop-blur-sm group">
        <div className="aspect-video bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl mb-4 relative overflow-hidden">
          <div className="absolute inset-0 bg-gradient-to-br from-green-500/10 to-blue-500/10" />
          <div className="absolute top-4 left-4">
            <span
              className={`px-3 py-1 rounded-full text-xs font-medium border ${getStatusColor(
                project.status
              )}`}
            >
              {getStatusLabel(project.status)}
            </span>
          </div>
          <div className="absolute bottom-4 right-4">
            <span className="px-2 py-1 bg-gray-800/80 backdrop-blur-sm rounded-lg text-xs text-gray-300 border border-gray-700/50">
              {project.category}
            </span>
          </div>
        </div>

        <h3 className="text-xl font-bold text-white mb-2 group-hover:text-green-400 transition-colors">
          {project.name}
        </h3>

        <p className="text-gray-400 text-sm mb-4 line-clamp-3">
          {project.description}
        </p>

        <div className="flex flex-wrap gap-2 mb-4">
          {project.tags.map((tag, idx) => (
            <span
              key={idx}
              className="px-2 py-1 bg-gray-800/50 text-gray-300 text-xs rounded-lg border border-gray-700/50"
            >
              {tag}
            </span>
          ))}
        </div>

        {project.status !== "upcoming" && (
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-400">Raised</span>
              <span className="text-white font-medium">
                {project.raised} BIO
              </span>
            </div>
            <div className="w-full bg-gray-800 rounded-full h-2">
              <div
                className="bg-gradient-to-r from-green-500 to-blue-500 h-2 rounded-full transition-all duration-300"
                style={{ width: `${project.progress}%` }}
              />
            </div>
            <div className="flex justify-between text-xs text-gray-500">
              <span>{project.progress}% Complete</span>
              <span>Target: {project.target} BIO</span>
            </div>
          </div>
        )}
      </div>
    </Link>
  );
}
