import { defineChain } from "viem";

export const CONTRACTS = {
  AscCurate: "0x0000000000000000000000000000000000000000" as const, // Replace with actual address
  AscStaking: "0x0000000000000000000000000000000000000000" as const, // Replace with actual address
  BioToken: "0x0000000000000000000000000000000000000000" as const, // Replace with actual token address
} as const;

export const storyTestnet = defineChain({
  id: 1315,
  name: "Story Testnet",
  nativeCurrency: {
    decimals: 18,
    name: "IP",
    symbol: "IP",
  },
  rpcUrls: {
    default: { http: ["https://testnet.storyrpc.io"] },
  },
  blockExplorers: {
    default: {
      name: "Story Testnet Explorer",
      url: "https://testnet.storyscan.xyz",
    },
  },
  testnet: true,
});
