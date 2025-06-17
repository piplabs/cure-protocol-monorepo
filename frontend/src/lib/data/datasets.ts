import { Dataset, ProjectDatasets } from "@/lib/types/index";

export const mockDatasets: ProjectDatasets = {
  reflexdao: [
    {
      id: "reflex-001",
      name: "ANS Tracking Dataset - Cohort A",
      description:
        "Autonomic nervous system tracking data from wearable devices over 6 months",
      fileSize: "2.4 GB",
      format: "CSV, JSON",
      uploadDate: "2024-03-15",
      uploader: "Dr. Sarah Chen",
      downloadCount: 127,
      accessLevel: "staking_required",
      isAccessible: true, // For MVP, we'll make this true
      metadata: {
        participants: 250,
        duration: "6 months",
        devices: "Heart rate monitors, sleep trackers",
        dataPoints: "1.2M measurements",
      },
    },
    {
      id: "reflex-002",
      name: "Chronic Disease Prevention - Biomarkers",
      description:
        "Blood biomarker analysis correlated with ANS patterns in pre-diabetic patients",
      fileSize: "856 MB",
      format: "XLSX, CSV",
      uploadDate: "2024-02-28",
      uploader: "ReflexDAO Research Team",
      downloadCount: 89,
      accessLevel: "token_holder",
      isAccessible: true,
      metadata: {
        participants: 150,
        duration: "3 months",
        biomarkers: "24 different markers",
        dataPoints: "850K measurements",
      },
    },
    {
      id: "reflex-003",
      name: "Stress Response Patterns",
      description:
        "Real-time stress response data collected during controlled laboratory conditions",
      fileSize: "1.8 GB",
      format: "Parquet, JSON",
      uploadDate: "2024-01-20",
      uploader: "Dr. Michael Torres",
      downloadCount: 203,
      accessLevel: "curator",
      isAccessible: false, // This one requires curation participation
      metadata: {
        participants: 75,
        duration: "2 weeks",
        sessions: "300 stress tests",
        dataPoints: "2.1M measurements",
      },
    },
  ],
  cerebrumdao: [
    {
      id: "cerebrum-001",
      name: "Neurodegeneration Biomarkers - Longitudinal Study",
      description:
        "Comprehensive biomarker tracking in early-stage neurodegeneration patients",
      fileSize: "3.2 GB",
      format: "HDF5, CSV",
      uploadDate: "2024-03-10",
      uploader: "Cerebrum Research Consortium",
      downloadCount: 156,
      accessLevel: "staking_required",
      isAccessible: true,
      metadata: {
        participants: 300,
        duration: "12 months",
        biomarkers: "40 neural markers",
        dataPoints: "3.5M measurements",
      },
    },
    {
      id: "cerebrum-002",
      name: "Brain Imaging - MRI Progression Data",
      description:
        "Anonymized MRI scans showing progression patterns in neurodegenerative diseases",
      fileSize: "15.7 GB",
      format: "DICOM, NIfTI",
      uploadDate: "2024-02-15",
      uploader: "Dr. Elena Vasquez",
      downloadCount: 67,
      accessLevel: "token_holder",
      isAccessible: true,
      metadata: {
        participants: 120,
        duration: "18 months",
        scans: "720 MRI sessions",
        dataPoints: "2.8M voxels per scan",
      },
    },
  ],
  curetopia: [
    {
      id: "cure-001",
      name: "Rare Disease Genomics - Variant Analysis",
      description:
        "Genomic sequencing data from patients with rare genetic diseases",
      fileSize: "8.9 GB",
      format: "VCF, FASTA",
      uploadDate: "2024-03-05",
      uploader: "Curetopia Genomics Lab",
      downloadCount: 234,
      accessLevel: "staking_required",
      isAccessible: true,
      metadata: {
        participants: 500,
        duration: "Ongoing",
        variants: "150K genetic variants",
        dataPoints: "50M base pairs",
      },
    },
  ],
};

export const projectNames = {
  reflexdao: "ReflexDAO",
  cerebrumdao: "Cerebrum DAO",
  curetopia: "Curetopia",
};

// Helper functions for dataset operations
export function getDatasetsByProject(projectId: string): Dataset[] {
  return mockDatasets[projectId] || [];
}

export function searchDatasets(
  projectId: string,
  searchTerm: string
): Dataset[] {
  const datasets = getDatasetsByProject(projectId);
  if (!searchTerm) return datasets;

  const lowercaseQuery = searchTerm.toLowerCase();
  return datasets.filter(
    (dataset) =>
      dataset.name.toLowerCase().includes(lowercaseQuery) ||
      dataset.description.toLowerCase().includes(lowercaseQuery) ||
      dataset.uploader.toLowerCase().includes(lowercaseQuery)
  );
}

export function getDatasetById(datasetId: string): Dataset | undefined {
  for (const projectDatasets of Object.values(mockDatasets)) {
    const dataset = projectDatasets.find((d) => d.id === datasetId);
    if (dataset) return dataset;
  }
  return undefined;
}
