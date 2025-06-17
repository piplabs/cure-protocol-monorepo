"use client";

import {
  Download,
  Database,
  Lock,
  CheckCircle,
  Eye,
  Calendar,
  User,
  HardDrive,
} from "lucide-react";
import { Dataset } from "@/lib/types/index";

interface DatasetCardProps {
  dataset: Dataset;
  onViewDetails: (dataset: Dataset) => void;
  onDownload: (dataset: Dataset) => void;
}

export default function DatasetCard({
  dataset,
  onViewDetails,
  onDownload,
}: DatasetCardProps) {
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
    <div className="bg-gray-900/50 border border-gray-800/50 rounded-2xl p-6 backdrop-blur-sm hover:border-green-500/30 transition-all">
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-2">
          <Database className="w-5 h-5 text-blue-400" />
          <span className="text-sm text-blue-400">{dataset.format}</span>
        </div>
        <div className="flex items-center gap-1">
          {getAccessIcon(dataset.accessLevel, dataset.isAccessible)}
          <span
            className={`text-xs ${
              dataset.isAccessible ? "text-green-400" : "text-red-400"
            }`}
          >
            {getAccessLabel(dataset.accessLevel, dataset.isAccessible)}
          </span>
        </div>
      </div>

      <h3 className="text-lg font-bold text-white mb-2">{dataset.name}</h3>
      <p className="text-gray-400 text-sm mb-4 line-clamp-2">
        {dataset.description}
      </p>

      <div className="grid grid-cols-2 gap-4 mb-4 text-xs">
        <div className="flex items-center gap-1 text-gray-500">
          <HardDrive className="w-3 h-3" />
          {dataset.fileSize}
        </div>
        <div className="flex items-center gap-1 text-gray-500">
          <Download className="w-3 h-3" />
          {dataset.downloadCount} downloads
        </div>
        <div className="flex items-center gap-1 text-gray-500">
          <Calendar className="w-3 h-3" />
          {new Date(dataset.uploadDate).toLocaleDateString()}
        </div>
        <div className="flex items-center gap-1 text-gray-500">
          <User className="w-3 h-3" />
          {dataset.uploader.split(" ")[0]}...
        </div>
      </div>

      <div className="flex gap-2">
        <button
          onClick={() => onViewDetails(dataset)}
          className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-gray-800/50 hover:bg-gray-700/50 border border-gray-700 rounded-lg text-gray-300 transition-colors"
        >
          <Eye className="w-4 h-4" />
          View Details
        </button>
        <button
          onClick={() => onDownload(dataset)}
          disabled={!dataset.isAccessible}
          className={`px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2 ${
            dataset.isAccessible
              ? "bg-green-500 hover:bg-green-600 text-black"
              : "bg-gray-600 text-gray-400 cursor-not-allowed"
          }`}
        >
          <Download className="w-4 h-4" />
          Download
        </button>
      </div>
    </div>
  );
}
