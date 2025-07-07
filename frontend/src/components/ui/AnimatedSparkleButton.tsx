"use client";

import { motion } from "framer-motion";
import { cn } from "@/lib/utils/cn";

interface AnimatedSparkleButtonProps {
  className?: string;
}

export function AnimatedSparkleButton({ className }: AnimatedSparkleButtonProps) {
  return (
    <svg
      className={cn("w-full h-full", className)}
      viewBox="0 0 110 29"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <linearGradient id="paint0_linear_98_31_new_btn" x1="1" y1="13" x2="100" y2="13" gradientUnits="userSpaceOnUse">
            <stop stopColor="#00BBFF" stopOpacity="0.71"/>
            <stop offset="1" stopColor="#3E59C3" stopOpacity="0.34"/>
        </linearGradient>
        <radialGradient id="paint1_radial_98_31_new_btn" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(99.5 13.5) rotate(90) scale(7.5)">
            <stop stopColor="#E4FCFF"/>
            <stop offset="0.807584" stopColor="#E4FCFF" stopOpacity="0"/>
        </radialGradient>
      </defs>
      
      {/* Button Body */}
      <rect x="1" y="4" width="99" height="18" rx="3" fill="url(#paint0_linear_98_31_new_btn)" stroke="#60ECFF" strokeWidth="0.7"/>

      {/* Static gradient circle and sparkle */}
      <g>
        <circle cx="99.5" cy="13.5" r="7.5" fill="url(#paint1_radial_98_31_new_btn)"/>
        <path d="M92.5 13.1372C92.5 13.1372 96.3285 13.1056 97.9104 11.5509C99.5179 9.97108 99.5711 6.06611 99.5711 6.06611C99.5711 6.06611 99.7288 9.84522 101.247 11.3892C102.79 12.9585 106.642 13.1372 106.642 13.1372C106.642 13.1372 102.796 13.2767 101.229 14.87C99.6884 16.4375 99.5711 20.2082 99.5711 20.2082C99.5711 20.2082 99.3488 16.3874 97.7858 14.8503C96.2484 13.3382 92.5 13.1372 92.5 13.1372Z" fill="white"/>
      </g>

      {/* Rotating dashed circle */}
      <motion.g
        animate={{ rotate: 360 }}
        transition={{ repeat: Infinity, duration: 10, ease: "linear" }}
        style={{ transformOrigin: '99.5px 13.5px' }}
      >
        <circle cx="99.5" cy="13.5" r="9.5" stroke="white" strokeWidth="0.7" strokeLinecap="round" strokeDasharray="0.01 3"/>
      </motion.g>
    </svg>
  );
} 