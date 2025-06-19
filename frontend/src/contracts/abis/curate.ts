export const CURATE_ABI = [
  {
    type: "function",
    name: "cancel",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "claimBioTokens",
    inputs: [
      {
        name: "claimer",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "bioToken",
        type: "address",
        internalType: "address",
      },
      {
        name: "amountClaimed",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "claimRefund",
    inputs: [],
    outputs: [
      {
        name: "amount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "close",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "deposit",
    inputs: [
      {
        name: "amount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "getAdmin",
    inputs: [],
    outputs: [
      {
        name: "admin",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getBioName",
    inputs: [],
    outputs: [
      {
        name: "bioName",
        type: "string",
        internalType: "string",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getBioToken",
    inputs: [],
    outputs: [
      {
        name: "bioToken",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getBioTokenName",
    inputs: [],
    outputs: [
      {
        name: "bioTokenName",
        type: "string",
        internalType: "string",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getBioTokenSymbol",
    inputs: [],
    outputs: [
      {
        name: "bioTokenSymbol",
        type: "string",
        internalType: "string",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getDepositedAmount",
    inputs: [
      {
        name: "user",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "amount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getExpirationTime",
    inputs: [],
    outputs: [
      {
        name: "expirationTime",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getFundReceiver",
    inputs: [],
    outputs: [
      {
        name: "fundReceiver",
        type: "address",
        internalType: "address",
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
        name: "ipId",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getStakingContract",
    inputs: [],
    outputs: [
      {
        name: "stakingContract",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getState",
    inputs: [],
    outputs: [
      {
        name: "state",
        type: "uint8",
        internalType: "enum IAscCurate.State",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getTotalDeposited",
    inputs: [],
    outputs: [
      {
        name: "totalDeposited",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getTotalSupplyOfBioToken",
    inputs: [],
    outputs: [
      {
        name: "totalSupplyOfBioToken",
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
        name: "upgradeableBeacon",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "initialize",
    inputs: [
      {
        name: "initData",
        type: "tuple",
        internalType: "struct IAscCurate.CurateInitData",
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
            name: "ipNft",
            type: "address",
            internalType: "address",
          },
          {
            name: "ipNftTokenId",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "expirationTime",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "fundReceiver",
            type: "address",
            internalType: "address",
          },
          {
            name: "bioName",
            type: "string",
            internalType: "string",
          },
          {
            name: "bioTokenName",
            type: "string",
            internalType: "string",
          },
          {
            name: "bioTokenSymbol",
            type: "string",
            internalType: "string",
          },
          {
            name: "minimalIpTokenForLaunch",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "rewardToken",
            type: "address",
            internalType: "address",
          },
        ],
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "launchProject",
    inputs: [
      {
        name: "bioTokenTemplate",
        type: "address",
        internalType: "address",
      },
      {
        name: "stakingContractTemplate",
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
    outputs: [
      {
        name: "bioToken",
        type: "address",
        internalType: "address",
      },
      {
        name: "stakingContract",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "transferAdminRole",
    inputs: [
      {
        name: "newAdmin",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "withdraw",
    inputs: [],
    outputs: [
      {
        name: "withdrawnAmount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "withdrawIp",
    inputs: [
      {
        name: "recipient",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "event",
    name: "AdminRoleTransferred",
    inputs: [
      {
        name: "previousAdmin",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "newAdmin",
        type: "address",
        indexed: true,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "BioTokenClaimed",
    inputs: [
      {
        name: "claimer",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "amountClaimed",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "CurateCanceled",
    inputs: [],
    anonymous: false,
  },
  {
    type: "event",
    name: "CurateClosed",
    inputs: [],
    anonymous: false,
  },
  {
    type: "event",
    name: "DepositReceived",
    inputs: [
      {
        name: "depositor",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "amount",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "IpWithdrawn",
    inputs: [
      {
        name: "recipient",
        type: "address",
        indexed: true,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "ProjectLaunched",
    inputs: [
      {
        name: "ipId",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "bioToken",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "stakingContract",
        type: "address",
        indexed: true,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "RefundClaimed",
    inputs: [
      {
        name: "claimer",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "amount",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "TokensWithdrawn",
    inputs: [
      {
        name: "receiver",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "amount",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
];
