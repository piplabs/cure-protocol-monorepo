"use client";

import { useState } from "react";
import ProjectHeader from "@/components/project/ProjectHeader";
import StageNavigation from "@/components/project/StageNavigation";
import MarketHypothesis from "@/components/project/MarketHypothesis";
import CurationStage from "@/components/project/stages/CurationStage";
import FundraisingStage from "@/components/project/stages/FundraisingStage";
import AMMStage from "@/components/project/stages/AMMStage";
import StakingStage from "@/components/project/stages/StakingStage";

import { Project } from "@/lib/types";
import { PROJECT_STAGES } from "@/lib/utils/constants";

interface ProjectDetailProps {
  project: Project;
}

export default function ProjectDetail({ project }: ProjectDetailProps) {
  const [projectStage, setProjectStage] = useState(project.status);

  const renderStage = () => {
    switch (projectStage) {
      case "curating":
        return <CurationStage project={project} />;
      case "fundraising":
        return <FundraisingStage project={project} />;
      case "amm":
        return <AMMStage project={project} />;
      case "staking":
        return <StakingStage project={project} />;
      default:
        return <CurationStage project={project} />;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-900">
      <div className="max-w-7xl mx-auto px-6 py-8">
        <ProjectHeader project={project} />
        {/* Data Marketplace Link */}
        {["reflexdao", "cerebrumdao", "curetopia"].includes(project.id) && (
          <div className="mb-6">
            <a
              href={`/data?project=${project.id}`}
              className="inline-block px-6 py-3 rounded-xl font-semibold bg-green-500 text-black hover:bg-green-400 transition-colors shadow-lg"
            >
              View Project Datasets
            </a>
          </div>
        )}
        <StageNavigation
          stages={PROJECT_STAGES}
          currentStage={projectStage}
          onStageChange={(stage) =>
            setProjectStage(stage as typeof projectStage)
          }
        />

        {/* Stage Content */}
        {renderStage()}

        {/* Market Hypothesis */}
        {projectStage === "curating" && <MarketHypothesis project={project} />}
      </div>
    </div>
  );
}
