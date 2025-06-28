"use client";

import { useState, useEffect } from "react";
import { Database } from "lucide-react";
import DatasetCard from "@/components/ui/DatasetCard";
import DatasetDetailModal from "@/components/ui/DatasetDetailModal";
import {
  mockDatasets,
  projectNames,
  searchDatasets,
} from "@/lib/data/datasets";
import { Dataset } from "@/lib/types/index";
import { useSearchParams } from "next/navigation";
import LoadingSpinner from "@/components/ui/LoadingSpinner";
import { useWallet } from "@/lib/hooks/useWallet";
import { DATA_DOWNLOAD_WHITELIST } from "@/lib/utils/constants";

export default function DataMarketplacePage() {
  const searchParams = useSearchParams();
  const initialProject = searchParams.get("project") || "reflexdao";
  const [selectedProject, setSelectedProject] = useState(initialProject);
  const [selectedDataset, setSelectedDataset] = useState<Dataset | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [downloadProgress, setDownloadProgress] = useState<number | null>(null);
  const [downloadStatus, setDownloadStatus] = useState<
    "idle" | "downloading" | "success" | "error"
  >("idle");
  const [downloadFileName, setDownloadFileName] = useState<string>("");
  const [permissionError, setPermissionError] = useState<string | null>(null);
  const { account, isConnected, connectWallet } = useWallet();

  useEffect(() => {
    setPermissionError(null);
  }, [account, isConnected]);

  const canDownload =
    !!isConnected &&
    !!account &&
    DATA_DOWNLOAD_WHITELIST.includes(account.toLowerCase());

  const handleDownload = async (dataset: Dataset) => {
    if (!dataset.isAccessible) {
      alert(
        "You need to meet the access requirements to download this dataset. Please stake tokens or participate in curation."
      );
      return;
    }
    if (!isConnected) {
      setPermissionError("connect");
      return;
    }
    if (!account || !DATA_DOWNLOAD_WHITELIST.includes(account.toLowerCase())) {
      setPermissionError(
        "Your wallet is not whitelisted to download datasets. Please contact the project admin to request access."
      );
      return;
    }
    if (!dataset.downloadUrl) {
      alert("No download available for this dataset.");
      return;
    }
    setDownloadProgress(0);
    setDownloadStatus("downloading");
    setDownloadFileName(dataset.name);
    try {
      const response = await fetch(dataset.downloadUrl);
      if (!response.ok || !response.body) throw new Error("Network error");
      const contentLength = response.headers.get("content-length");
      const total = contentLength ? parseInt(contentLength, 10) : 0;
      let loaded = 0;
      const reader = response.body.getReader();
      const chunks = [];
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        if (value) {
          chunks.push(value);
          loaded += value.length;
          if (total) {
            setDownloadProgress(Math.round((loaded / total) * 100));
          }
        }
      }
      const blob = new Blob(chunks);
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = dataset.downloadUrl.split("/").pop() || dataset.name;
      document.body.appendChild(a);
      a.click();
      a.remove();
      window.URL.revokeObjectURL(url);
      setDownloadProgress(100);
      setDownloadStatus("success");
      setTimeout(() => {
        setDownloadProgress(null);
        setDownloadStatus("idle");
        setDownloadFileName("");
      }, 2000);
    } catch (e) {
      console.error("Download error:", e);
      setDownloadStatus("error");
      setTimeout(() => {
        setDownloadProgress(null);
        setDownloadStatus("idle");
        setDownloadFileName("");
      }, 2000);
    }
  };

  const filteredDatasets = searchDatasets(selectedProject, searchTerm);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-900 -mt-20 pt-20">
      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-white mb-4">
            Research Data Marketplace
          </h1>
          <p className="text-gray-300 text-lg">
            Access high-quality research datasets from cure protocol projects. Powered
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
                    ? "bg-[#00d4ff] text-black"
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
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-500 focus:border-[#00d4ff] focus:outline-none transition-colors"
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
              canDownload={canDownload}
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
            canDownload={canDownload}
          />
        )}

        {/* Download Progress Modal */}
        {downloadProgress !== null && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
            <div className="bg-gray-900 border border-gray-800 rounded-2xl p-8 max-w-sm w-full flex flex-col items-center">
              <h3 className="text-lg font-bold text-white mb-4">
                {downloadStatus === "downloading" &&
                  `Downloading ${downloadFileName}...`}
                {downloadStatus === "success" && "Download Complete!"}
                {downloadStatus === "error" && "Download Failed"}
              </h3>
              <div className="w-full mb-4">
                <div className="w-full bg-gray-800 rounded-full h-4">
                  <div
                    className={`h-4 rounded-full transition-all duration-300 ${
                      downloadStatus === "error"
                        ? "bg-red-500"
                        : downloadStatus === "success"
                        ? "bg-green-500"
                        : "bg-blue-500"
                    }`}
                    style={{ width: `${downloadProgress}%` }}
                  />
                </div>
                <div className="text-center text-sm text-gray-300 mt-2">
                  {downloadStatus === "downloading" && `${downloadProgress}%`}
                  {downloadStatus === "success" && "File saved to your device."}
                  {downloadStatus === "error" &&
                    "There was a problem downloading the file."}
                </div>
              </div>
              {downloadStatus === "downloading" && <LoadingSpinner size="md" />}
            </div>
          </div>
        )}

        {/* Permission/Connect Modal */}
        {permissionError && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
            <div className="bg-gray-900 border border-red-700 rounded-2xl p-8 max-w-sm w-full flex flex-col items-center">
              {permissionError === "connect" ? (
                <>
                  <h3 className="text-lg font-bold text-yellow-400 mb-4">
                    Connect Wallet Required
                  </h3>
                  <div className="text-gray-300 mb-4 text-center">
                    You must connect your wallet to download datasets.
                  </div>
                  <button
                    className="px-6 py-2 rounded-xl font-semibold bg-green-500 text-black hover:bg-green-400 transition-colors mt-2"
                    onClick={async () => {
                      await connectWallet();
                      setPermissionError(null);
                    }}
                  >
                    Connect Wallet
                  </button>
                  <button
                    className="px-6 py-2 rounded-xl font-semibold bg-gray-700 text-white hover:bg-gray-600 transition-colors mt-2"
                    onClick={() => setPermissionError(null)}
                  >
                    Cancel
                  </button>
                </>
              ) : (
                <>
                  <h3 className="text-lg font-bold text-red-400 mb-4">
                    Download Not Permitted
                  </h3>
                  <div className="text-gray-300 mb-4 text-center">
                    {permissionError}
                  </div>
                  <button
                    className="px-6 py-2 rounded-xl font-semibold bg-red-500 text-white hover:bg-red-400 transition-colors mt-2"
                    onClick={() => setPermissionError(null)}
                  >
                    Close
                  </button>
                </>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
