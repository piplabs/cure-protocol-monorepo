export const CURATE_ABI = [
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
    name: "launchProject",
    inputs: [
      {
        name: "fractionalTokenTemplate",
        type: "address",
        internalType: "address",
      },
      {
        name: "distributionContractTemplate",
        type: "address",
        internalType: "address",
      },
      {
        name: "initData",
        type: "tuple",
        internalType: "struct IAscCurate.InitData",
        components: [
          {
            name: "admin",
            type: "address",
            internalType: "address",
          },
          {
            name: "rewardToken",
            type: "address",
            internalType: "address",
          },
        ],
      },
    ],
    outputs: [
      {
        name: "licenseTermsId",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "fractionalToken",
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
    name: "withdraw",
    inputs: [],
    outputs: [
      {
        name: "withdrawnAmounts",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "payable",
  },
];
