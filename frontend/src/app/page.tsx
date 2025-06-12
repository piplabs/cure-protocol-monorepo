import HeroSection from "@/components/ui/HeroSection";
import ProjectsGrid from "@/components/ui/ProjectsGrid";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-900">
      <HeroSection />
      <div className="max-w-7xl mx-auto px-6 py-12">
        <ProjectsGrid />
      </div>
    </div>
  );
}
