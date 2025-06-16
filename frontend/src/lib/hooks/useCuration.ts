import { useState, useEffect } from "react";
import { formatEther, parseEther } from "viem";
import { useWallet } from "./useWallet";
import { CONTRACTS, CURATE_ABI } from "@/contracts";
import type { LoadingStates, CurationData } from "@/lib/types/index";

export function useCuration(projectId: string) {
  const { account, isConnected, publicClient, walletClient } = useWallet();
  const [loading, setLoading] = useState<LoadingStates>({});
  const [curationData, setCurationData] = useState<CurationData | null>(null);
  const [ipBalance, setIpBalance] = useState<string>("0");
  const [statusMessage, setStatusMessage] = useState<string>("");

  const showStatus = (message: string) => {
    setStatusMessage(message);
    setTimeout(() => setStatusMessage(""), 5000);
  };

  const setLoadingState = (key: string, value: boolean) => {
    setLoading((prev) => ({ ...prev, [key]: value }));
  };

  useEffect(() => {
    if (isConnected && account && publicClient) {
      loadCurationData();
      loadIpBalance();
    }
  }, [isConnected, account, publicClient, projectId]);

  const loadIpBalance = async () => {
    if (!publicClient || !account) return;

    try {
      // Get native $IP token balance
      const balance = await publicClient.getBalance({
        address: account,
      });
      setIpBalance(formatEther(balance));
    } catch (error) {
      console.error("Failed to load $IP balance:", error);
    }
  };

  const loadCurationData = async () => {
    if (!publicClient || !account) return;

    try {
      // TODO: load real curation data from the contract

      setCurationData({
        totalCommitted: "663.88K",
        userCommitted: "0",
        curationLimit: "2.25M",
        isActive: true,
        canClaim: false,
      });
    } catch (error) {
      console.error("Failed to load curation data:", error);
    }
  };

  const commitToCuration = async (amount: string) => {
    if (!walletClient || !account) return;

    setLoadingState("commit", true);
    try {
      const amountWei = parseEther(amount);

      // Since we're using native $IP token, we send it as value in the transaction
      const hash = await walletClient.writeContract({
        account,
        address: CONTRACTS.AscCurate,
        abi: CURATE_ABI,
        functionName: "deposit",
        args: [amountWei],
        value: amountWei, // Send $IP as native token value
      });

      console.log("Curation commitment hash:", hash);
      showStatus("Successfully committed to curation! Updating data...");

      // Refresh data
      await Promise.all([loadCurationData(), loadIpBalance()]);
      showStatus("Curation commitment successful!");
    } catch (error: any) {
      console.error("Failed to commit to curation:", error);
      showStatus(`Failed to commit: ${error.message || "Unknown error"}`);
    } finally {
      setLoadingState("commit", false);
    }
  };

  const withdrawFromCuration = async () => {
    if (!walletClient || !account) return;

    setLoadingState("withdraw", true);
    try {
      const hash = await walletClient.writeContract({
        account,
        address: CONTRACTS.AscCurate,
        abi: CURATE_ABI,
        functionName: "withdraw",
        args: [],
      });

      console.log("Withdrawal hash:", hash);
      showStatus("Withdrawal successful! Updating data...");

      // Refresh data
      await Promise.all([loadCurationData(), loadIpBalance()]);
      showStatus("Withdrawal completed!");
    } catch (error: any) {
      console.error("Failed to withdraw:", error);
      showStatus(`Failed to withdraw: ${error.message || "Unknown error"}`);
    } finally {
      setLoadingState("withdraw", false);
    }
  };

  const claimRefund = async () => {
    if (!walletClient || !account) return;

    setLoadingState("claim", true);
    try {
      const hash = await walletClient.writeContract({
        account,
        address: CONTRACTS.AscCurate,
        abi: CURATE_ABI,
        functionName: "claimRefund",
        args: [],
      });

      console.log("Claim refund hash:", hash);
      showStatus("Refund claimed successfully! Updating data...");

      // Refresh data
      await Promise.all([loadCurationData(), loadIpBalance()]);
      showStatus("Refund claimed!");
    } catch (error: any) {
      console.error("Failed to claim refund:", error);
      showStatus(`Failed to claim refund: ${error.message || "Unknown error"}`);
    } finally {
      setLoadingState("claim", false);
    }
  };

  return {
    // State
    loading,
    curationData,
    ipBalance,
    statusMessage,

    // Actions
    commitToCuration,
    withdrawFromCuration,
    claimRefund,
    loadCurationData,
    loadIpBalance,
    showStatus,
  };
}
