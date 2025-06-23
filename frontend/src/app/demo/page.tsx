"use client"

import { NavBarDemo } from "@/components/ui/tubelight-navbar-demo"

export default function DemoPage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-[#121B3D] to-[#142175] relative">
      {/* Content to demonstrate the navbar */}
      <div className="container mx-auto px-6 py-20 text-center">
        <h1 className="text-4xl font-bold text-white mb-8">
          Tubelight Navbar Demo
        </h1>
        <p className="text-gray-300 text-lg mb-12 max-w-2xl mx-auto">
          This is a demonstration of the tubelight navbar component. 
          The navbar is positioned at the bottom on mobile devices and at the top on desktop.
          Try clicking on different navigation items to see the tubelight effect!
        </p>
        
        {/* Sample content sections */}
        <div className="space-y-16">
          <section className="bg-white/5 backdrop-blur-sm rounded-2xl p-8 border border-white/10">
            <h2 className="text-2xl font-semibold text-white mb-4">Home Section</h2>
            <p className="text-gray-300">
              This is the home section content. The navbar will show "Home" as active when you're here.
            </p>
          </section>
          
          <section className="bg-white/5 backdrop-blur-sm rounded-2xl p-8 border border-white/10">
            <h2 className="text-2xl font-semibold text-white mb-4">About Section</h2>
            <p className="text-gray-300">
              This is the about section content. The navbar will show "About" as active when you're here.
            </p>
          </section>
          
          <section className="bg-white/5 backdrop-blur-sm rounded-2xl p-8 border border-white/10">
            <h2 className="text-2xl font-semibold text-white mb-4">Projects Section</h2>
            <p className="text-gray-300">
              This is the projects section content. The navbar will show "Projects" as active when you're here.
            </p>
          </section>
          
          <section className="bg-white/5 backdrop-blur-sm rounded-2xl p-8 border border-white/10">
            <h2 className="text-2xl font-semibold text-white mb-4">Resume Section</h2>
            <p className="text-gray-300">
              This is the resume section content. The navbar will show "Resume" as active when you're here.
            </p>
          </section>
        </div>
      </div>
      
      {/* The tubelight navbar */}
      <NavBarDemo />
    </div>
  )
} 