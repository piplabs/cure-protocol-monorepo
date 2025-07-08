// Utility function to get project-specific token symbols
export const getProjectTokenSymbol = (projectId: string): string => {
  const tokenMap: Record<string, string> = {
    reflexdao: "REFLEX",
    cerebrumdao: "CERE", // Note: in projectDetails.ts it shows NEURON, but based on user request it should be CERE
    curetopia: "CURE",
    sleepdao: "SLEEP",
    kidneydao: "KIDNEY",
    microbiome: "MICRO",
  };

  return tokenMap[projectId] || "CURE"; // Default to CURE if project not found
};

// Get project token symbol with $ prefix for display
export const getProjectTokenDisplay = (projectId: string): string => {
  const symbol = getProjectTokenSymbol(projectId);
  return `$${symbol}`;
};
