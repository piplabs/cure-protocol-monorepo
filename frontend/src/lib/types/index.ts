export interface Project {
  id: string;
  name: string;
  category: string;
  status: "curating" | "upcoming" | "fundraising" | "amm" | "staking";
  description: string;
  raised: string;
  target: string;
  progress: number;
  image: string;
  tags: string[];
}

export interface ProjectDetails {
  fullDescription?: string;
  curationDetails?: {
    bioCommitted: string;
    curationLimit: string;
    totalSupply: string;
    curatorAllocation: string;
    curationFDV: string;
    numCurators: number;
    vestingPeriod: string;
    tokenSupply: string;
    curatorLockup: string;
  };
  marketHypothesis?: {
    stats: Array<{
      value: string;
      label: string;
    }>;
    description: string;
    focusAreas: Array<{
      title: string;
      description: string;
    }>;
  };
  tokenomics?: {
    price: string;
    marketCap: string;
    volume24h: string;
    holders: number;
    totalSupply: string;
  };
  staking?: {
    apr: string;
    totalStaked: string;
    userStaked: string;
    rewards: string;
  };
}

export interface Stage {
  id: string;
  label: string;
  number: number;
}

// Contract interaction types
export interface LoadingStates {
  [key: string]: boolean;
}

export interface CurationData {
  totalCommitted: string;
  userCommitted: string;
  curationLimit: string;
  isActive: boolean;
  canClaim: boolean;
}

export interface StakingData {
  userStaked: string;
  totalStaked: string;
  pendingRewards: string;
  stakingToken: string;
  rewardToken: string;
  apr: string;
}

export interface ProjectData {
  id: string;
  fractionalTokenAddress?: string;
  stakingContractAddress?: string;
  licenseTermsId?: string;
  isLaunched: boolean;
}
