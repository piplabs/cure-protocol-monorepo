"use client";

import { Download, Lock, CheckCircle } from "lucide-react";
import { Dataset } from "@/lib/types/index";

interface DatasetDetailModalProps {
  dataset: Dataset;
  onClose: () => void;
  onDownload: (dataset: Dataset) => void;
}

export default function DatasetDetailModal({
  dataset,
  onClose,
  onDownload,
}: DatasetDetailModalProps) {
  const getAccessIcon = (accessLevel: string, isAccessible: boolean) => {
    if (!isAccessible) {
      return <Lock className="w-4 h-4 text-red-400" />;
    }
    return <CheckCircle className="w-4 h-4 text-green-400" />;
  };

  const getAccessLabel = (accessLevel: string, isAccessible: boolean) => {
    if (!isAccessible) {
      return "Access Restricted";
    }
    switch (accessLevel) {
      case "staking_required":
        return "Staking Required";
      case "token_holder":
        return "Token Holder";
      case "curator":
        return "Curator Access";
      case "public":
        return "Public Access";
      default:
        return "Public Access";
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-gray-900 border border-gray-800 rounded-2xl p-6 max-w-2xl w-full max-h-[80vh] overflow-y-auto">
        <div className="flex items-start justify-between mb-6">
          <div>
            <h2 className="text-2xl font-bold text-white mb-2">
              {dataset.name}
            </h2>
            <div className="flex items-center gap-2">
              {getAccessIcon(dataset.accessLevel, dataset.isAccessible)}
              <span
                className={`text-sm ${
                  dataset.isAccessible ? "text-green-400" : "text-red-400"
                }`}
              >
                {getAccessLabel(dataset.accessLevel, dataset.isAccessible)}
              </span>
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white transition-colors"
          >
            ✕
          </button>
        </div>

        <div className="space-y-6">
          <div>
            <h3 className="text-lg font-bold text-white mb-2">Description</h3>
            <p className="text-gray-300">{dataset.description}</p>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">
                File Size
              </h4>
              <p className="text-white">{dataset.fileSize}</p>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">Format</h4>
              <p className="text-white">{dataset.format}</p>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">
                Upload Date
              </h4>
              <p className="text-white">
                {new Date(dataset.uploadDate).toLocaleDateString()}
              </p>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">
                Uploader
              </h4>
              <p className="text-white">{dataset.uploader}</p>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">
                Downloads
              </h4>
              <p className="text-white">{dataset.downloadCount}</p>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">
                Access Level
              </h4>
              <p className="text-white">
                {getAccessLabel(dataset.accessLevel, dataset.isAccessible)}
              </p>
            </div>
          </div>

          <div>
            <h3 className="text-lg font-bold text-white mb-4">
              Dataset Metadata
            </h3>
            <div className="bg-gray-800/30 rounded-xl p-4 border border-gray-700/50">
              <div className="grid grid-cols-2 gap-4">
                {Object.entries(dataset.metadata).map(([key, value]) => (
                  <div key={key}>
                    <h4 className="text-sm font-medium text-gray-400 mb-1 capitalize">
                      {key.replace(/([A-Z])/g, " $1").trim()}
                    </h4>
                    <p className="text-white">{value}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {!dataset.isAccessible && (
            <div className="bg-red-900/20 border border-red-500/30 rounded-xl p-4">
              <h4 className="text-red-400 font-medium mb-2">
                Access Requirements
              </h4>
              <p className="text-red-300 text-sm">
                {dataset.accessLevel === "staking_required" &&
                  "You need to stake tokens to access this dataset."}
                {dataset.accessLevel === "token_holder" &&
                  "You need to hold project tokens to access this dataset."}
                {dataset.accessLevel === "curator" &&
                  "You need to participate in curation to access this dataset."}
              </p>
            </div>
          )}

          <div className="flex gap-4 pt-4">
            <button
              onClick={onClose}
              className="flex-1 px-4 py-3 bg-gray-800/50 hover:bg-gray-700/50 border border-gray-700 rounded-xl text-gray-300 transition-colors"
            >
              Close
            </button>
            <button
              onClick={() => onDownload(dataset)}
              disabled={!dataset.isAccessible}
              className={`flex-1 px-4 py-3 rounded-xl font-medium transition-colors flex items-center justify-center gap-2 ${
                dataset.isAccessible
                  ? "bg-green-500 hover:bg-green-600 text-black"
                  : "bg-gray-600 text-gray-400 cursor-not-allowed"
              }`}
            >
              <Download className="w-4 h-4" />
              Download Dataset
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
