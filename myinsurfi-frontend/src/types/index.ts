export interface InsurancePolicy {
  id: string;
  policyHolder: string;
  insuranceType: number;
  coverageAmount: string;
  premiumAmount: string;
  startDate: number;
  endDate: number;
  isActive: boolean;
  metadata: string;
}

export interface Claim {
  id: string;
  policyId: string;
  claimant: string;
  claimAmount: string;
  evidenceHash: string;
  status: number;
  submissionDate: number;
  processingDate: number;
}

export interface WalletState {
  isConnected: boolean;
  address: string;
  chainId?: string;
}

export interface PolicyFormData {
  coverageAmount: string;
  premiumAmount: string;
  duration: string;
  destination?: string;
  propertyValue?: string;
}

export interface ClaimFormData {
  policyId: string;
  claimAmount: string;
  description: string;
}

export interface ContractStats {
  userBalance: string;
  totalSupply: string;
  totalPolicies: string;
  totalClaims: string;
}
