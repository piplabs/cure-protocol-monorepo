// src/lib/data/projectDetails.ts
import { ProjectDetails } from "../types";

export const projectDetails: Record<string, ProjectDetails> = {
  reflexdao: {
    fullDescription:
      "Advancing chronic disease prevention through wearable technology and autonomic nervous system (ANS) tracking. ReflexDAO empowers individuals to own their health data and fuel ANS research and innovation through a token-powered, decentralized network.",
    curationDetails: {
      bioCommitted: "663.88K",
      curationLimit: "2.25M",
      totalSupply: "1B REFLEX",
      curatorAllocation: "50M REFLEX",
      curationFDV: "$0",
      numCurators: 50,
      vestingPeriod: "6 months + 3 months",
      tokenSupply: "5%",
      curatorLockup: "60 days",
    },
    marketHypothesis: {
      stats: [
        {
          value: "38 Million",
          label: "People currently living with Alzheimer's disease",
        },
        {
          value: "$20 Billion",
          label: "Neurodegenerative disease market by 2027",
        },
        {
          value: "$1.3 Trillion",
          label: "Cost burden for dementia care in 2024",
        },
      ],
      description:
        "The human brain is the final frontier in healthcare. With populations aging in many nations across the world and health interventions extending lifespan, we now face the challenge of our bodies outliving our brains.",
      focusAreas: [
        {
          title: "Neuroinflammation",
          description:
            "Neuroinflammatory changes in Alzheimer's Disease (AD) and other dementias are characterized by the activation of glial cells, particularly microglia and astrocytes, and the release of inflammatory mediators, which contribute to disease progression and severity. The continued release of pro-inflammatory cytokines and associated neurotoxins from microglia serves to exacerbate the neuroinflammation and contribute to neurodegeneration, leading to the activation of yet more microglia. We seek to fund projects that search for inhibitors of neuroinflammation and novel biomarkers specific to neuroinflammation.",
        },
        {
          title:
            "Metabolic alterations, reactive oxygen species, and mitochondrial dysfunction",
          description:
            "Hundreds of metabolites are altered in the brain affected by AD. Metabolic alterations, Reactive Oxygen Species (ROS), and mitochondrial dysfunction are interconnected processes that occur early and play a significant role in neurodegeneration. Altered bioenergetic pathways, including glycolysis, branched-chain amino acid metabolism, cholesterol, mitochondrial oxidation, and osmotic alterations are closely correlated with cognitive decline. An imbalance between the production of ROS and the ability of cells to detoxify them can lead to increased inflammatory responses and promote aging-related neurodegeneration. We are seeking proposals targeting early metabolic alterations, with a specific interest in mitochondrial dysfunction.",
        },
        {
          title: "Blood-Brain Barrier (BBB)",
          description:
            "The BBB is a highly selective, semipermeable structural and chemical barrier that ensures a stable environment for the brain. However, in AD, the BBB becomes dysfunctional, leading to the failure of Amyloid-Beta (Aβ) transport from the brain to the peripheral circulation. This dysfunction is associated with decreased levels of low-density Lipoprotein Receptor-related Protein 1 (LRP-1) and increased levels of the Receptor for Advanced Glycation End-products (RAGE), which are involved in Aβ transport across the BBB. Aβ deposition in the vasculature leads to pro-inflammatory, cytotoxic events and is associated with cerebral blood flow reductions and impaired hemodynamic responses. We seek proposals targeting early BBB changes and novel BBB disruption biomarkers.",
        },
      ],
    },
    // Add staking contract info for ReflexDAO
    stakingContract: {
      address: "0x1234567890123456789012345678901234567890", // Replace with actual contract address
      stakingToken: {
        address: "0x1111111111111111111111111111111111111111", // Replace with actual REFLEX token address
        symbol: "REFLEX",
        decimals: 18,
      },
      rewardToken: {
        address: "0x1111111111111111111111111111111111111111", // Could be same as staking token
        symbol: "REFLEX",
        decimals: 18,
      },
    },
  },
  cerebrumdao: {
    fullDescription:
      "Building the world's largest engaged community focused on enabling scientific breakthroughs that prevent the onset of neurodegeneration and extend our healthy brain years.",
    tokenomics: {
      price: "$2.7376",
      marketCap: "$20,058,143.27",
      volume24h: "$514,734",
      holders: 1205,
      totalSupply: "20,058,944.057 NEURON",
    },
    staking: {
      apr: "4.50%",
      totalStaked: "60,846,596",
      userStaked: "0.00",
      rewards: "0.000",
    },
    // Add staking contract info for CerebrumDAO
    stakingContract: {
      address: "0x2345678901234567890123456789012345678901", // Replace with actual contract address
      stakingToken: {
        address: "0x2222222222222222222222222222222222222222", // Replace with actual NEURON token address
        symbol: "NEURON",
        decimals: 18,
      },
      rewardToken: {
        address: "0x2222222222222222222222222222222222222222", // Could be same as staking token
        symbol: "NEURON",
        decimals: 18,
      },
    },
  },
  curetopia: {
    fullDescription:
      "Curing the 10,000 rare genetic diseases. We are uniting patient groups and populations to tackle the $1T rare disease market. We're going directly to patients, turning them into research scientists, and making them the center of focus.",
    // Add staking contract info for Curetopia
    stakingContract: {
      address: "0x3456789012345678901234567890123456789012", // Replace with actual contract address
      stakingToken: {
        address: "0x3333333333333333333333333333333333333333", // Replace with actual CURES token address
        symbol: "CURES",
        decimals: 18,
      },
      rewardToken: {
        address: "0x3333333333333333333333333333333333333333", // Could be same as staking token
        symbol: "CURES",
        decimals: 18,
      },
    },
  },
  // Add entries for remaining projects from mockProjects
  sleepdao: {
    fullDescription:
      "Improving sleep health through research and innovation. SleepDAO focuses on understanding sleep patterns, disorders, and developing innovative solutions for better sleep quality.",
    stakingContract: {
      address: "0x4567890123456789012345678901234567890123", // Replace with actual contract address
      stakingToken: {
        address: "0x4444444444444444444444444444444444444444", // Replace with actual SLEEP token address
        symbol: "SLEEP",
        decimals: 18,
      },
      rewardToken: {
        address: "0x4444444444444444444444444444444444444444",
        symbol: "SLEEP",
        decimals: 18,
      },
    },
    staking: {
      apr: "3.75%",
      totalStaked: "0",
      userStaked: "0.00",
      rewards: "0.000",
    },
  },
  kidneydao: {
    fullDescription:
      "Advancing kidney disease research and treatment through decentralized science. KidneyDAO focuses on chronic kidney disease prevention, treatment innovations, and patient care improvements.",
    stakingContract: {
      address: "0x5678901234567890123456789012345678901234", // Replace with actual contract address
      stakingToken: {
        address: "0x5555555555555555555555555555555555555555", // Replace with actual KIDNEY token address
        symbol: "KIDNEY",
        decimals: 18,
      },
      rewardToken: {
        address: "0x5555555555555555555555555555555555555555",
        symbol: "KIDNEY",
        decimals: 18,
      },
    },
    staking: {
      apr: "4.25%",
      totalStaked: "0",
      userStaked: "0.00",
      rewards: "0.000",
    },
  },
  microbiome: {
    fullDescription:
      "Microbiome research for better health outcomes. MicrobiomeDAO investigates the role of gut microbiota in human health, developing personalized microbiome therapies and treatments.",
    stakingContract: {
      address: "0x6789012345678901234567890123456789012345", // Replace with actual contract address
      stakingToken: {
        address: "0x6666666666666666666666666666666666666666", // Replace with actual MICRO token address
        symbol: "MICRO",
        decimals: 18,
      },
      rewardToken: {
        address: "0x6666666666666666666666666666666666666666",
        symbol: "MICRO",
        decimals: 18,
      },
    },
    staking: {
      apr: "5.00%",
      totalStaked: "0",
      userStaked: "0.00",
      rewards: "0.000",
    },
  },
};
