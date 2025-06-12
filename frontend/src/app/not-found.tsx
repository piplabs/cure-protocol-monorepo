import Link from "next/link";
import { ChevronRight } from "lucide-react";

export default function NotFound() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-900 flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-6xl font-bold text-white mb-4">404</h1>
        <h2 className="text-2xl font-bold text-gray-300 mb-6">
          Project Not Found
        </h2>
        <p className="text-gray-400 mb-8 max-w-md">
          The project you're looking for doesn't exist or has been moved.
        </p>
        <Link
          href="/"
          className="inline-flex items-center gap-2 px-6 py-3 bg-green-500 hover:bg-green-600 text-black font-medium rounded-lg transition-colors"
        >
          <ChevronRight className="w-4 h-4 rotate-180" />
          Back to Launchpad
        </Link>
      </div>
    </div>
  );
}
