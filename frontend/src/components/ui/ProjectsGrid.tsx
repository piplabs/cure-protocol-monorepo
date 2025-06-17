"use client";

import { useState, useMemo } from "react";
import ProjectCard from "./ProjectCard";
import SearchFilters from "./SearchFilters";
import { mockProjects } from "@/lib/data/projects";
import { searchProjects } from "@/lib/data/projects";

export default function ProjectsGrid() {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [activeTab, setActiveTab] = useState("All");

  const filteredProjects = useMemo(() => {
    let projects = mockProjects;

    // Filter by search term
    if (searchTerm) {
      projects = searchProjects(searchTerm);
    }

    // Filter by category
    if (selectedCategory !== "All") {
      projects = projects.filter(
        (project) => project.category === selectedCategory
      );
    }

    // Filter by tab
    if (activeTab !== "All") {
      const statusMap: { [key: string]: string[] } = {
        Curating: ["curating"],
        Upcoming: ["upcoming"],
        Live: ["fundraising", "amm", "staking"],
      };

      if (statusMap[activeTab]) {
        projects = projects.filter((project) =>
          statusMap[activeTab].includes(project.status)
        );
      }
    }

    return projects;
  }, [searchTerm, selectedCategory, activeTab]);

  return (
    <>
      <SearchFilters
        onSearchChange={setSearchTerm}
        onCategoryChange={setSelectedCategory}
        onTabChange={setActiveTab}
      />

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {filteredProjects.map((project) => (
          <ProjectCard key={project.id} project={project} />
        ))}
      </div>

      {filteredProjects.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-400 text-lg mb-2">No projects found</div>
          <div className="text-gray-500 text-sm">
            Try adjusting your search criteria
          </div>
        </div>
      )}
    </>
  );
}
