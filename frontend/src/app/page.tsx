import HeroSection from "@/components/ui/HeroSection";
import ProjectsGrid from "@/components/ui/ProjectsGrid";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-[#121B3D] to-[#142175] -mt-20 pt-20 relative">
      {/* Sparkles in random locations across the background */}
      <div className="absolute top-40 left-16 opacity-40">
        <img 
          src="/art/home page/sparkle.svg" 
          alt="" 
          style={{ 
            width: '50px',
            height: '52px',
            flexShrink: 0,
            transform: 'rotate(-15deg)'
          }}
        />
      </div>
      
      <div className="absolute top-60 right-24 opacity-30">
        <img 
          src="/art/home page/sparkle.svg" 
          alt="" 
          style={{ 
            width: '35px',
            height: '36px',
            flexShrink: 0,
            transform: 'rotate(45deg)'
          }}
        />
      </div>
      
      <div className="absolute top-80 left-1/3 opacity-50">
        <img 
          src="/art/home page/sparkle.svg" 
          alt="" 
          style={{ 
            width: '40px',
            height: '41px',
            flexShrink: 0,
            transform: 'rotate(-30deg)'
          }}
        />
      </div>
      
      <div className="absolute top-96 right-1/4 opacity-35">
        <img 
          src="/art/home page/sparkle.svg" 
          alt="" 
          style={{ 
            width: '30px',
            height: '31px',
            flexShrink: 0,
            transform: 'rotate(60deg)'
          }}
        />
      </div>
      
      <div className="absolute top-[500px] left-20 opacity-45">
        <img 
          src="/art/home page/sparkle.svg" 
          alt="" 
          style={{ 
            width: '45px',
            height: '46px',
            flexShrink: 0,
            transform: 'rotate(-45deg)'
          }}
        />
      </div>
      
      <div className="absolute top-[600px] right-16 opacity-40">
        <img 
          src="/art/home page/sparkle.svg" 
          alt="" 
          style={{ 
            width: '38px',
            height: '39px',
            flexShrink: 0,
            transform: 'rotate(25deg)'
          }}
        />
      </div>
      
      <div className="absolute top-[700px] left-1/2 opacity-30">
        <img 
          src="/art/home page/sparkle.svg" 
          alt="" 
          style={{ 
            width: '32px',
            height: '33px',
            flexShrink: 0,
            transform: 'rotate(-60deg)'
          }}
        />
      </div>
      
      <HeroSection />
      <div className="max-w-7xl mx-auto px-6 py-12">
        <ProjectsGrid />
      </div>
    </div>
  );
}
