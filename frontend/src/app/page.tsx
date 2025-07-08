import HeroSection from "@/components/ui/HeroSection";
import ProjectsGrid from "@/components/ui/ProjectsGrid";
import { SparklesCore } from "@/components/ui/sparkles";
import { LavaLamp } from "@/components/ui/fluid-blob";
import AboutSection from "@/components/ui/AboutSection";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-[#121B3D] to-[#142175] -mt-20 pt-20 relative">
      
      <HeroSection />
      
      <AboutSection />

      {/* Dynamic sparkles background */}
      <div className="absolute inset-0 w-full h-full z-1">
        <SparklesCore
          id="homepage-sparkles"
          background="transparent"
          minSize={0.6}
          maxSize={1.4}
          particleDensity={20}
          className="w-full h-full"
          particleColor="#9DD6EE"
          speed={0.8}
        />
      </div>
      {/* Lava lamp background for projects section */}
      <div className="relative">
        <div className="absolute inset-0 h-full opacity-30">
          <LavaLamp />
        </div>
        <div id="projects" className="relative z-10 max-w-7xl mx-auto px-6 py-12">
          <ProjectsGrid />
        </div>
      </div>
    </div>
  );
}
