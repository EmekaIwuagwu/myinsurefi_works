// MyInsurFi Contract Configuration
export const CONTRACT_CONFIG = {
  // Network Configuration
  network: 'sepolia-alpha',
  rpcUrl: 'https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_8/vA9vMquzKkv6Kq_cA9B8njZlD_NGjqBX',
  
  // Contract Information
  contractAddress: '0x061765eefef928d59c553fae712b677b7a832e9362259731ce1b57f6849773b2',
  classHash: '0x01c751e058e8ed440adf4308d7613c3346f84a519285ba48863c0f052047a6d3',
  
  // Owner Information
  owner: '0x01c63f0d7ea35151700589c39f94552e8f4ee12df5266f7ab27b3ba670699b18',
  
  // Token Information
  token: {
    name: 'MY InsurFi Token',
    symbol: 'MYSU',
    decimals: 18,
    totalSupply: '40000000000000000000000000'
  },
  
  // Insurance Types
  insuranceTypes: {
    HEALTH: 0,
    TRAVEL: 1,
    SCHENGEN: 2,
    HOUSE: 3
  },
  
  // Claim Status
  claimStatus: {
    PENDING: 0,
    APPROVED: 1,
    REJECTED: 2,
    PAID: 3
  },
  
  // Explorer URLs
  explorerUrl: 'https://sepolia.starkscan.co',
  contractExplorerUrl: 'https://sepolia.starkscan.co/contract/0x061765eefef928d59c553fae712b677b7a832e9362259731ce1b57f6849773b2'
} as const;

// Insurance Type Mappings
export const INSURANCE_TYPES = {
  0: 'Health',
  1: 'Travel', 
  2: 'Schengen',
  3: 'House'
} as const;

// Claim Status Mappings
export const CLAIM_STATUS = {
  0: 'Pending',
  1: 'Approved',
  2: 'Rejected', 
  3: 'Paid'
} as const;

// Utility Functions
export const formatToken = (amount: string | number, decimals: number = 18): string => {
  const divisor = Math.pow(10, decimals);
  return (Number(amount) / divisor).toFixed(4);
};

export const parseToken = (amount: string | number, decimals: number = 18): string => {
  const multiplier = Math.pow(10, decimals);
  return Math.floor(Number(amount) * multiplier).toString();
};

export const formatAddress = (address: string): string => {
  if (!address) return '';
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
};
