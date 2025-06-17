import { notFound } from "next/navigation";
import ProjectDetail from "@/components/project/ProjectDetail";
import { getProjectById } from "@/lib/data/projects";

interface ProjectPageProps {
  params: Promise<{
    id: string;
  }>;
}

export default async function ProjectPage({ params }: ProjectPageProps) {
  const { id } = await params;
  const project = getProjectById(id);

  if (!project) {
    notFound();
  }

  return <ProjectDetail project={project} />;
}

export async function generateStaticParams() {
  const projects = await import("@/lib/data/projects");

  return projects.mockProjects.map((project) => ({
    id: project.id,
  }));
}
