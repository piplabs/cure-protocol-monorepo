import HeroSection from "@/components/ui/HeroSection";
import ProjectsGrid from "@/components/ui/ProjectsGrid";
import { SparklesCore } from "@/components/ui/sparkles";
import { LavaLamp } from "@/components/ui/fluid-blob";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-[#121B3D] to-[#142175] -mt-20 pt-20 relative overflow-hidden">
      
      <HeroSection />
      
      {/* Gradient transition from hero to blobs */}
      <div className="relative">
        <div className="absolute top-0 left-0 right-0 h-48 bg-gradient-to-b from-[#121B3D] via-[#121B3D]/80 to-transparent pointer-events-none z-10" />
      </div>
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
        <div className="absolute inset-0 h-screen*2 opacity-30">
          <LavaLamp />
        </div>
        <div className="relative z-10 max-w-7xl mx-auto px-6 py-12">
          <ProjectsGrid />
        </div>
      </div>
    </div>
  );
}
