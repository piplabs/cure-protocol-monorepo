export const STAKING_ABI = [
  {
    type: "function",
    name: "addStakingPool",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        internalType: "address",
      },
      {
        name: "allocPoints",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "claimAllRewards",
    inputs: [
      {
        name: "claimer",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "collectRoyalties",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "deposit",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        internalType: "address",
      },
      {
        name: "amount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "getAdmin",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getCurrentDistributionEndBlock",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getIpId",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getPendingRewardsForStaker",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        internalType: "address",
      },
      {
        name: "staker",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getPoolAllocPoints",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getPoolTotalStakedBalance",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getRewardDistributionPeriod",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getRewardPerBlock",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getRewardToken",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getTotalAllocPoints",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getUpgradeableBeacon",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getUserStakedBalance",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        internalType: "address",
      },
      {
        name: "staker",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "initialize",
    inputs: [
      {
        name: "bioToken",
        type: "address",
        internalType: "address",
      },
      {
        name: "initData",
        type: "tuple",
        internalType: "struct IAscStaking.InitData",
        components: [
          {
            name: "admin",
            type: "address",
            internalType: "address",
          },
          {
            name: "ipId",
            type: "address",
            internalType: "address",
          },
          {
            name: "rewardDistributionPeriod",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "rewardToken",
            type: "address",
            internalType: "address",
          },
          {
            name: "bioTokenAllocPoints",
            type: "uint256",
            internalType: "uint256",
          },
        ],
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "setPoolAllocPoints",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        internalType: "address",
      },
      {
        name: "allocPoints",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "setRewardDistributionPeriod",
    inputs: [
      {
        name: "numberOfBlocks",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "withdraw",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        internalType: "address",
      },
      {
        name: "amount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "event",
    name: "Deposited",
    inputs: [
      {
        name: "staker",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "stakingToken",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "depositedAmount",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "PoolAllocPointsUpdated",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "oldAllocPoints",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
      {
        name: "newAllocPoints",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "RewardDistributionPeriodUpdated",
    inputs: [
      {
        name: "oldPeriod",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
      {
        name: "newPeriod",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "RewardsClaimed",
    inputs: [
      {
        name: "staker",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "totalRewards",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "RoyaltiesCollected",
    inputs: [
      {
        name: "ipId",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "totalRoyaltiesCollected",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
      {
        name: "distributionEndBlock",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "StakingPoolAdded",
    inputs: [
      {
        name: "stakingToken",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "allocPoints",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "Withdrawn",
    inputs: [
      {
        name: "staker",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "stakingToken",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "withdrawnAmount",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
];
