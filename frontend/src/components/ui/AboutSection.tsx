'use client';

import React, { useEffect, useRef, useState } from 'react';

interface Step {
  title: string;
  description: string;
}

const aboutContent = {
  title: 'What is Cure Protocol?',
  description: "Cure Protocol is a decentralized science (DeSci) platform dedicated to accelerating innovation and democratizing research. We provide a transparent, community-driven ecosystem where researchers can secure funding, share data, and collaborate on the next wave of scientific breakthroughs. Our mission is to build a future where science is open, equitable, and accessible to all.",
};

const AboutSection = () => {
  const processSteps: Step[] = [
    {
      title: 'Curation',
      description: "Researchers submit their project proposals to the Cure Protocol platform. Our community of experts and token holders then review, discuss, and vote on the proposals. This decentralized peer-review process ensures that only the most promising and viable research projects move forward.",
    },
    {
      title: 'Fundraising',
      description: "Once a project passes the curation stage, it can launch a fundraising campaign. Backers from around the world can contribute funds directly to the research, receiving project-specific tokens in return. This democratizes funding and gives creators full autonomy.",
    },
    {
      title: 'AMM Launch',
      description: "Upon successful fundraising, a portion of the raised capital is used to create an Automated Market Maker (AMM) liquidity pool. This provides immediate liquidity for the project's tokens, allowing backers to trade and enabling market-driven price discovery.",
    },
    {
      title: 'Staking & Governance',
      description: "Token holders can stake their tokens to earn rewards and actively participate in the project's ongoing governance. Staking helps secure the network and aligns the incentives of all participants, fostering a collaborative ecosystem for long-term success.",
    },
  ];

  const allContentForSidebar = [
    { title: aboutContent.title }, 
    ...processSteps
  ];

  const [visibleStep, setVisibleStep] = useState(0);
  const stepRefs = useRef<(HTMLDivElement | null)[]>([]);
  const scrollTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const isClickScrollingRef = useRef(false);

  useEffect(() => {
    const observerOptions = {
      root: null,
      rootMargin: '-40% 0px -60% 0px',
      threshold: 0,
    };

    const observer = new IntersectionObserver((entries) => {
      if (isClickScrollingRef.current) return;
      
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const index = parseInt(entry.target.getAttribute('data-step-index') || '0', 10);
          setVisibleStep(index);
        }
      });
    }, observerOptions);

    const currentRefs = stepRefs.current;
    currentRefs.forEach((ref) => {
      if (ref) observer.observe(ref);
    });

    return () => {
      currentRefs.forEach((ref) => {
        if (ref) observer.unobserve(ref);
      });
      if (scrollTimeoutRef.current) {
        clearTimeout(scrollTimeoutRef.current);
      }
    };
  }, []);

  const handleStepClick = (index: number) => {
    isClickScrollingRef.current = true;
    setVisibleStep(index);

    stepRefs.current[index]?.scrollIntoView({
      behavior: 'smooth',
      block: 'start',
    });

    if (scrollTimeoutRef.current) {
      clearTimeout(scrollTimeoutRef.current);
    }

    scrollTimeoutRef.current = setTimeout(() => {
      isClickScrollingRef.current = false;
    }, 1000); // A safe timeout for the scroll animation to finish
  };
  
  return (
    <div id="about" className="relative z-10 py-24">
      {/* Sparkle decorations */}
      <div className="absolute top-[10%] left-[15%] w-[80px] h-[80px] opacity-50 pointer-events-none">
        <img src="/art/homepage/sparkle.svg" alt="" className="w-full h-full select-none" style={{ transform: 'rotate(15deg)' }} />
      </div>
      <div className="absolute top-[20%] right-[10%] w-[120px] h-[120px] opacity-30 pointer-events-none">
        <img src="/art/homepage/sparkle.svg" alt="" className="w-full h-full select-none" style={{ transform: 'rotate(-20deg)' }} />
      </div>
      <div className="absolute top-[50%] left-[5%] w-[60px] h-[60px] opacity-60 pointer-events-none">
        <img src="/art/homepage/sparkle.svg" alt="" className="w-full h-full select-none" style={{ transform: 'rotate(45deg)' }} />
      </div>
      <div className="absolute top-[70%] right-[20%] w-[90px] h-[90px] opacity-40 pointer-events-none">
        <img src="/art/homepage/sparkle.svg" alt="" className="w-full h-full select-none" style={{ transform: 'rotate(-10deg)' }} />
      </div>
      <div className="absolute top-[85%] left-[25%] w-[70px] h-[70px] opacity-55 pointer-events-none">
        <img src="/art/homepage/sparkle.svg" alt="" className="w-full h-full select-none" style={{ transform: 'rotate(5deg)' }} />
      </div>
      <div className="absolute top-[95%] right-[5%] w-[110px] h-[110px] opacity-25 pointer-events-none">
        <img src="/art/homepage/sparkle.svg" alt="" className="w-full h-full select-none" style={{ transform: 'rotate(-30deg)' }} />
      </div>

      {/* REALLY BIG SPARKLE */}
      <div className="absolute top-[40%] left-1/2 -translate-x-1/2 -translate-y-1/2 w-[250px] h-[250px] opacity-20 pointer-events-none">
        <img src="/art/homepage/sparkle.svg" alt="" className="w-full h-full select-none" style={{ transform: 'rotate(-5deg)' }} />
      </div>

      <div className="max-w-7xl mx-auto px-6 flex flex-col md:flex-row gap-24">
        {/* LEFT STICKY COLUMN */}
        <div className="md:w-1/3">
          <ul className="sticky top-28 space-y-4">
            {allContentForSidebar.map((step, index) => (
              <li key={index}>
                <button
                  onClick={() => handleStepClick(index)}
                  className={`w-full text-left px-4 py-3 rounded-lg transition-all duration-300 border border-transparent hover:bg-slate-700/50 ${
                    visibleStep === index
                      ? 'bg-blue-500/20 text-cyan-200 border-cyan-400/50'
                      : 'text-slate-400'
                  }`}
                >
                  <span className="font-bold text-lg mr-3">{`0${index + 1}`}</span>
                  {step.title}
                </button>
              </li>
            ))}
          </ul>
        </div>

        {/* RIGHT CONTENT COLUMN */}
        <div className="md:w-2/3">
          <div 
            className="mb-20 min-h-[150px] flex flex-col justify-center scroll-mt-28"
            ref={(el) => { stepRefs.current[0] = el; }}
            data-step-index={0}
          >
            <h2 className="text-4xl md:text-5xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-cyan-200">
              {aboutContent.title}
            </h2>
            <p className="text-lg md:text-xl text-slate-300 leading-relaxed">
              {aboutContent.description}
            </p>
          </div>
          
          <div>
            <h3 className="text-3xl md:text-4xl font-bold mb-8 text-transparent bg-clip-text bg-gradient-to-r from-blue-300 to-cyan-100">
              How It Works
            </h3>
            <div className="space-y-10">
              {processSteps.map((step, index) => (
                <div
                  key={index}
                  ref={(el) => {stepRefs.current[index + 1] = el}}
                  data-step-index={index + 1}
                  className="min-h-[150px] flex flex-col justify-center scroll-mt-28"
                >
                  <h4 className="text-2xl font-bold mb-4 text-cyan-300">{step.title}</h4>
                  <p className="text-slate-300 leading-relaxed">{step.description}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AboutSection; 