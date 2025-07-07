"use client";
import { SparklesCore } from "./sparkles";
import { AnimatedSparkleButton } from "./AnimatedSparkleButton";
import { TextShimmer } from "./text-shimmer";
import { motion } from "framer-motion";

export default function HeroSection() {
  return (
    <div className="relative py-20 px-6 overflow-hidden z-2">
      <div className="absolute inset-0" />  {/* bg-gradient-to-r from-[#00d4ff]/10 via-blue-500/5 to-purple-500/10 */}
      
      {/* Sparkle decoration */}
      <div className="absolute opacity-60" style={{ 
        top: '60%', 
        left: '50%',
        transform: 'translate(-50%, -50%)',
        width: '100px',
        height: '103px'
      }}>
        <img 
          src="/art/home page/sparkle.svg" 
          alt="" 
          style={{ 
            width: '100%',
            height: '100%',
            flexShrink: 0,
            transform: 'rotate(-10deg)'
          }}
        />
      </div>
      
      {/* Second sparkle decoration */}
      <div className="absolute bottom-0 right-0 opacity-60">
        <img 
          src="/art/home page/sparkle.svg" 
          alt="" 
          style={{ 
            width: '200px',
            height: '195px',
            flexShrink: 0,
            transform: 'rotate(-62.318deg)'
          }}
        />
      </div>
      
      {/* Wave decoration */}
      <div className="absolute bottom-0 right-0 opacity-60">
        <img 
          src="/art/home page/wave.svg" 
          alt="" 
          style={{ 
            width: '1000px',
            height: '517px',
            flexShrink: 0
          }}
        />
      </div>

      {/* Contained SparklesCore */}
      <div className="absolute inset-0 w-full h-full">
        <div className="w-full h-full relative">
          {/* Core component */}
          <SparklesCore
            background="transparent"
            minSize={0.4}
            maxSize={1}
            particleDensity={100}
            className="w-full h-full"
            particleColor="#00d4ff"
          />

          {/* Linear Gradient mask to create sharp edge at bottom */}
          <div className="absolute inset-0 w-full h-full [mask-image:linear-gradient(to_top,transparent_0%,white_20%)]"></div>
        </div>
      </div>
      <motion.div
        initial={{ opacity: 0.0, y: 40 }}
        whileInView={{ opacity: 1, y: 0 }}
        transition={{
          delay: 0.1,
          duration: 0.8,
          ease: "easeInOut",
        }}
        className="relative"
      >
        <div className="max-w-7xl mx-auto relative">
          <div className="w-full max-w-4xl">
            <div>
              <h1 className="text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
                Curate & Fund
                <br />
                <TextShimmer
                  as="span"
                  shimmerBackground="linear-gradient(to right, #00d4ff, #60a5fa)"
                  className="[--base-gradient-color:rgba(255,255,255,0.5)]"
                >
                  Decentralized Science
                </TextShimmer>
              </h1>

              <p className="text-xl text-gray-300 mb-8 leading-relaxed">
                Cure Protocol enables the community to launch new BioDAOs
                through a 3-phase process: Curation, Fundraising, and Liquidity
                Provisioning.
              </p>

              <div className="flex items-center gap-6 mb-8">
                <div className="text-center">
                  <div className="text-3xl font-bold text-[#00d4ff]">
                    12 BioDAOs
                  </div>
                  <div className="text-white text-sm">Launched & Funded</div>
                </div>

                <div className="text-center">
                  <div className="text-3xl font-bold text-blue-400">$24.3M</div>
                  <div className="text-white text-sm">Raised for Research</div>
                </div>
                <div className="text-center">
                  <div className="text-3xl font-bold text-purple-400">$15M</div>
                  <div className="text-gray-100 text-sm">
                    Deployed in Research
                  </div>
                </div>
              </div>

              <button className="relative px-10 py-10 transition-all transform hover:scale-105 focus:outline-none">
                
                <AnimatedSparkleButton className="absolute inset-0" />
                <img
                  src="/art/home page/button.svg"
                  alt=""
                  className="absolute inset-0 w-full h-full object-fill"
                  aria-hidden="true"
                />
                {/* Button label */}
                <span className="relative z-10 text-white font-bold right-6.5 bottom-1">
                  Learn more about the mechanics
                </span>
              </button>
            </div>
            

            {/* <div className="relative">
              <div className="absolute inset-0 bg-gradient-to-br from-[#00d4ff]/20 to-blue-500/20 rounded-3xl blur-3xl" />
              <div className="relative bg-gray-900/50 border border-gray-800/50 rounded-3xl p-8 backdrop-blur-sm">
                <div className="grid grid-cols-2 gap-6">
                  {[
                    "Longevity",
                    "Men's Health",
                    "Metabolic Health",
                    "Oncology",
                    "Chronic Diseases",
                    "Gut Health",
                    "Rare Diseases",
                    "Brain Longevity",
                  ].map((category, idx) => (
                    <div
                      key={idx}
                      className="px-4 py-3 bg-gray-800/50 rounded-xl border border-gray-700/50 text-center"
                    >
                      <span className="text-gray-300 text-sm">{category}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div> */}
          </div>
        </div>
      </motion.div>
    </div>
  );
}
