import { Project } from "../types";

export const mockProjects: Project[] = [
  {
    id: "reflexdao",
    name: "ReflexDAO",
    category: "Longevity",
    status: "curating",
    description:
      "Advancing chronic disease prevention through wearable technology and autonomic nervous system (ANS) tracking.",
    raised: "663.9K",
    target: "2.3M",
    progress: 28,
    image: "/api/placeholder/400/200",
    tags: ["Brain Longevity", "Chronic Diseases"],
  },
  {
    id: "curetopia",
    name: "Curetopia",
    category: "Rare Diseases",
    status: "fundraising",
    description:
      "Curing the 10,000 rare genetic diseases. We are uniting patient groups and populations to tackle the $1T rare disease market.",
    raised: "14.21K",
    target: "94.72K",
    progress: 15,
    image: "/api/placeholder/400/200",
    tags: ["Rare Diseases"],
  },
  {
    id: "cerebrumdao",
    name: "Cerebrum DAO",
    category: "Brain Longevity",
    status: "amm",
    description:
      "Building the world's largest engaged community focused on enabling scientific breakthroughs that prevent neurodegeneration.",
    raised: "2.5M",
    target: "2.5M",
    progress: 100,
    image: "/api/placeholder/400/200",
    tags: ["Brain Longevity", "Neurodegeneration"],
  },
  {
    id: "sleepdao",
    name: "SleepDAO",
    category: "Metabolic Health",
    status: "staking",
    description: "Improving sleep health through research and innovation",
    raised: "0",
    target: "1.5M",
    progress: 0,
    image: "/api/placeholder/400/200",
    tags: ["Sleep Health", "Metabolic Health"],
  },
  {
    id: "kidneydao",
    name: "KidneyDAO",
    category: "Chronic Diseases",
    status: "upcoming",
    description: "Advancing kidney disease research and treatment",
    raised: "0",
    target: "2.1M",
    progress: 0,
    image: "/api/placeholder/400/200",
    tags: ["Chronic Diseases"],
  },
  {
    id: "microbiome",
    name: "microbiomeDAO",
    category: "Gut Health",
    status: "upcoming",
    description: "Microbiome research for better health outcomes",
    raised: "0",
    target: "1.8M",
    progress: 0,
    image: "/api/placeholder/400/200",
    tags: ["Gut Health"],
  },
];

export function getProjectById(id: string): Project | undefined {
  return mockProjects.find((project) => project.id === id);
}

export function getProjectsByCategory(category: string): Project[] {
  if (category === "All") return mockProjects;
  return mockProjects.filter((project) => project.category === category);
}

export function searchProjects(query: string): Project[] {
  const lowercaseQuery = query.toLowerCase();
  return mockProjects.filter(
    (project) =>
      project.name.toLowerCase().includes(lowercaseQuery) ||
      project.description.toLowerCase().includes(lowercaseQuery) ||
      project.tags.some((tag) => tag.toLowerCase().includes(lowercaseQuery))
  );
}
