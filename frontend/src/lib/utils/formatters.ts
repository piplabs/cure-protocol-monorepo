export const formatNumber = (num: number | string): string => {
  const numValue =
    typeof num === "string" ? parseFloat(num.replace(/[^\d.-]/g, "")) : num;

  if (numValue >= 1000000) return (numValue / 1000000).toFixed(1) + "M";
  if (numValue >= 1000) return (numValue / 1000).toFixed(1) + "K";
  return numValue.toString();
};

export const getStatusColor = (status: string): string => {
  switch (status) {
    case "curating":
      return "bg-blue-500/20 text-blue-400 border-blue-500/30";
    case "fundraising":
      return "bg-green-500/20 text-green-400 border-green-500/30";
    case "amm":
      return "bg-purple-500/20 text-purple-400 border-purple-500/30";
    case "staking":
      return "bg-yellow-500/20 text-yellow-400 border-yellow-500/30";
    default:
      return "bg-gray-500/20 text-gray-400 border-gray-500/30";
  }
};

export const getStatusLabel = (status: string): string => {
  switch (status) {
    case "curating":
      return "Curating";
    case "upcoming":
      return "Upcoming";
    case "fundraising":
      return "Fundraising";
    case "amm":
      return "AMM";
    case "staking":
      return "Staking";
    default:
      return status;
  }
};
