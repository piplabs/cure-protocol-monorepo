"use client";

import { useState } from "react";
import { Search, Filter } from "lucide-react";
import { CATEGORIES, FILTER_TABS } from "@/lib/utils/constants";

interface SearchFiltersProps {
  onSearchChange?: (term: string) => void;
  onCategoryChange?: (category: string) => void;
  onTabChange?: (tab: string) => void;
}

export default function SearchFilters({
  onSearchChange,
  onCategoryChange,
  onTabChange,
}: SearchFiltersProps) {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");
  const [activeTab, setActiveTab] = useState("All");

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setSearchTerm(value);
    onSearchChange?.(value);
  };

  const handleCategoryChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const value = e.target.value;
    setSelectedCategory(value);
    onCategoryChange?.(value);
  };

  const handleTabChange = (tab: string) => {
    setActiveTab(tab);
    onTabChange?.(tab);
  };

  return (
    <div className="flex flex-col lg:flex-row gap-6 mb-8">
      <div className="flex-1">
        <div className="relative">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search by name"
            value={searchTerm}
            onChange={handleSearchChange}
            className="w-full pl-12 pr-4 py-3 bg-gray-900/50 border border-gray-800 rounded-xl text-white placeholder-gray-500 focus:border-green-500 focus:outline-none transition-colors"
          />
        </div>
      </div>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2 px-4 py-2 bg-gray-900/50 border border-gray-800 rounded-xl">
          <Filter className="w-4 h-4 text-gray-400" />
          <select
            value={selectedCategory}
            onChange={handleCategoryChange}
            className="bg-transparent text-white outline-none"
          >
            {CATEGORIES.map((cat: any) => (
              <option key={cat} value={cat} className="bg-gray-900">
                {cat}
              </option>
            ))}
          </select>
        </div>

        <div className="flex bg-gray-900/50 border border-gray-800 rounded-xl p-1">
          {FILTER_TABS.map((tab: any) => (
            <button
              key={tab}
              onClick={() => handleTabChange(tab)}
              className={`px-4 py-2 rounded-lg text-sm transition-colors ${
                activeTab === tab
                  ? "bg-green-500 text-black"
                  : "text-gray-400 hover:text-white"
              }`}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
