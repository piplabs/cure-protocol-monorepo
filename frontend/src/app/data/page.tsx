"use client";

import { useState } from "react";
import { Database } from "lucide-react";
import DatasetCard from "@/components/ui/DatasetCard";
import DatasetDetailModal from "@/components/ui/DatasetDetailModal";
import {
  mockDatasets,
  projectNames,
  searchDatasets,
} from "@/lib/data/datasets";
import { Dataset } from "@/lib/types/index";

export default function DataMarketplacePage() {
  const [selectedProject, setSelectedProject] = useState("reflexdao");
  const [selectedDataset, setSelectedDataset] = useState<Dataset | null>(null);
  const [searchTerm, setSearchTerm] = useState("");

  const handleDownload = (dataset: Dataset) => {
    if (!dataset.isAccessible) {
      alert(
        "You need to meet the access requirements to download this dataset. Please stake tokens or participate in curation."
      );
      return;
    }

    // For MVP, we'll just show a success message
    // In production, this would trigger actual download from Poseidon
    alert(`Downloading ${dataset.name}... (${dataset.fileSize})`);
  };

  const filteredDatasets = searchDatasets(selectedProject, searchTerm);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-900">
      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-white mb-4">
            Research Data Marketplace
          </h1>
          <p className="text-gray-300 text-lg">
            Access high-quality research datasets from DeSci projects. Powered
            by Poseidon decentralized storage.
          </p>
        </div>

        {/* Project Selection */}
        <div className="mb-8">
          <div className="flex flex-wrap gap-4">
            {Object.keys(mockDatasets).map((projectId) => (
              <button
                key={projectId}
                onClick={() => setSelectedProject(projectId)}
                className={`px-6 py-3 rounded-xl font-medium transition-colors ${
                  selectedProject === projectId
                    ? "bg-green-500 text-black"
                    : "bg-gray-800/50 text-gray-300 hover:bg-gray-700/50 border border-gray-700"
                }`}
              >
                {projectNames[projectId as keyof typeof projectNames]}
                <span className="ml-2 text-sm opacity-75">
                  ({mockDatasets[projectId].length} datasets)
                </span>
              </button>
            ))}
          </div>
        </div>

        {/* Search */}
        <div className="mb-8">
          <div className="relative max-w-md">
            <input
              type="text"
              placeholder="Search datasets..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-4 pr-4 py-3 bg-gray-900/50 border border-gray-800 rounded-xl text-white placeholder-gray-500 focus:border-green-500 focus:outline-none transition-colors"
            />
          </div>
        </div>

        {/* Datasets Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6 mb-8">
          {filteredDatasets.map((dataset) => (
            <DatasetCard
              key={dataset.id}
              dataset={dataset}
              onViewDetails={setSelectedDataset}
              onDownload={handleDownload}
            />
          ))}
        </div>

        {filteredDatasets.length === 0 && (
          <div className="text-center py-12">
            <Database className="w-16 h-16 text-gray-600 mx-auto mb-4" />
            <h3 className="text-xl font-bold text-gray-400 mb-2">
              No datasets found
            </h3>
            <p className="text-gray-500">
              Try adjusting your search terms or select a different project.
            </p>
          </div>
        )}

        {/* Dataset Detail Modal */}
        {selectedDataset && (
          <DatasetDetailModal
            dataset={selectedDataset}
            onClose={() => setSelectedDataset(null)}
            onDownload={handleDownload}
          />
        )}
      </div>
    </div>
  );
}
