import { useState, useEffect } from "react";
import {
  createPublicClient,
  createWalletClient,
  custom,
  http,
  formatEther,
} from "viem";
import { storyTestnet } from "../../contracts/constants";

export function useWallet() {
  const [account, setAccount] = useState<string>("");
  const [isConnected, setIsConnected] = useState(false);
  const [chainId, setChainId] = useState<number | null>(null);
  const [balance, setBalance] = useState<string>("0");
  const [publicClient, setPublicClient] = useState<any>(null);
  const [walletClient, setWalletClient] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Initialize public client
    if (typeof window !== "undefined") {
      const client = createPublicClient({
        chain: storyTestnet,
        transport: http(),
      });
      setPublicClient(client);

      // Check if wallet is already connected
      checkWalletConnection();
    }
  }, []);

  useEffect(() => {
    if (isConnected && account && publicClient) {
      loadUserBalance();
    }
  }, [isConnected, account, publicClient, chainId]);

  const checkWalletConnection = async () => {
    const { ethereum } = window as any;
    if (typeof ethereum !== "undefined") {
      try {
        const accounts = await ethereum.request({ method: "eth_accounts" });
        const currentChainId = await ethereum.request({
          method: "eth_chainId",
        });

        if (accounts.length > 0) {
          setAccount(accounts[0]);
          setChainId(parseInt(currentChainId, 16));
          setIsConnected(true);

          const walletClient = createWalletClient({
            chain: storyTestnet,
            transport: custom(ethereum),
          });
          setWalletClient(walletClient);
        }
      } catch (error) {
        console.error("Failed to check wallet connection:", error);
      }
    }
  };

  const connectWallet = async () => {
    setLoading(true);
    try {
      const { ethereum } = window as any;
      if (typeof ethereum !== "undefined") {
        const walletClient = createWalletClient({
          chain: storyTestnet,
          transport: custom(ethereum),
        });

        const accounts = await walletClient.requestAddresses();
        const currentChainId = await ethereum.request({
          method: "eth_chainId",
        });

        setAccount(accounts[0]);
        setChainId(parseInt(currentChainId, 16));
        setWalletClient(walletClient);
        setIsConnected(true);
      } else {
        alert("Please install MetaMask to continue");
        throw new Error("Please install MetaMask to continue");
      }
    } catch (error) {
      console.error("Failed to connect wallet:", error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const disconnectWallet = () => {
    setAccount("");
    setWalletClient(null);
    setIsConnected(false);
    setBalance("0");
    setChainId(null);
  };

  const loadUserBalance = async () => {
    if (!publicClient || !account) return;

    try {
      const balance = await publicClient.getBalance({
        address: account,
      });
      setBalance(formatEther(balance));
    } catch (error) {
      console.error("Failed to load user balance:", error);
    }
  };

  const switchNetwork = async (targetChainId: number) => {
    const { ethereum } = window as any;
    if (typeof ethereum !== "undefined") {
      try {
        await ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: `0x${targetChainId.toString(16)}` }],
        });
        setChainId(targetChainId);
      } catch (error: any) {
        // If the chain hasn't been added to MetaMask, add it
        if (error.code === 4902) {
          // Add network logic here if needed
          throw new Error("Please add the network to your wallet");
        }
        throw error;
      }
    }
  };

  return {
    // State
    account,
    isConnected,
    chainId,
    balance,
    publicClient,
    walletClient,
    loading,

    // Actions
    connectWallet,
    disconnectWallet,
    switchNetwork,
    loadUserBalance,
  };
}
