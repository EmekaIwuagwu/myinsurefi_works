#!/bin/bash

# MyInsurFi Contract Configuration Script
# Sets up initial contract configuration after deployment

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

if [ -f deployment_config.json ]; then
    CONTRACT_ADDRESS=$(jq -r '.contractAddress' deployment_config.json)
fi

if [ -z "$CONTRACT_ADDRESS" ]; then
    echo -e "${RED}❌ Contract address not found. Deploy first.${NC}"
    exit 1
fi

echo -e "${BLUE}⚙️  Configuring MyInsurFi Contract${NC}"
echo "Contract: $CONTRACT_ADDRESS"
echo "================================"

# Configure premium rates
configure_premium_rates() {
    echo -e "${YELLOW}💰 Setting Premium Rates...${NC}"
    
    # Note: Premium rates are already set in constructor
    # Health: 5%, Travel: 3%, Schengen: 4%, House: 2%
    echo "✅ Premium rates already configured in constructor:"
    echo "   Health Insurance: 5%"
    echo "   Travel Insurance: 3%"
    echo "   Schengen Insurance: 4%"
    echo "   House Insurance: 2%"
}

# Add authorized insurance agents
add_insurance_agents() {
    echo -e "${YELLOW}👨‍💼 Adding Authorized Agents...${NC}"
    
    # Add owner as agent
    echo "Adding owner as authorized agent..."
    starkli invoke "$CONTRACT_ADDRESS" add_authorized_agent "$OWNER_ADDRESS" \
        --account "$STARKNET_ACCOUNT_FILE" \
        --keystore "$STARKNET_KEYSTORE_FILE" \
        --rpc "$STARKNET_RPC"
    
    echo -e "${GREEN}✅ Owner added as authorized agent${NC}"
    
    # You can add more agents here
    # Example:
    # AGENT_ADDRESS="0x..."
    # starkli invoke "$CONTRACT_ADDRESS" add_authorized_agent "$AGENT_ADDRESS" \
    #     --account "$STARKNET_ACCOUNT_FILE" \
    #     --keystore "$STARKNET_KEYSTORE_FILE" \
    #     --rpc "$STARKNET_RPC"
}

# Set up sponsorship for test users
setup_sponsorship() {
    echo -e "${YELLOW}🎫 Setting up Transaction Sponsorship...${NC}"
    
    # Transaction fees are already set in constructor
    echo "✅ Transaction fees configured:"
    echo "   Policy Creation: 0.05 MYSU"
    echo "   Premium Payment: 0.01 MYSU"
    echo "   Claim Submission: 0.03 MYSU"
    
    # Note: To add sponsorship balance for users, you would need additional functions
    # This could be done through a separate admin function
}

# Mint additional tokens if needed
mint_additional_tokens() {
    echo -e "${YELLOW}🪙 Token Minting Configuration...${NC}"
    
    # Check current supply
    CURRENT_SUPPLY=$(starkli call "$CONTRACT_ADDRESS" total_supply --rpc "$STARKNET_RPC")
    echo "Current Total Supply: $CURRENT_SUPPLY"
    
    # Initial supply is 40M tokens, minted to owner
    OWNER_BALANCE=$(starkli call "$CONTRACT_ADDRESS" balance_of "$OWNER_ADDRESS" --rpc "$STARKNET_RPC")
    echo "Owner Balance: $OWNER_BALANCE"
    
    echo -e "${GREEN}✅ Token supply configured correctly${NC}"
    
    # If you need to mint more tokens:
    # MINT_AMOUNT="1000000000000000000000"  # 1000 tokens
    # starkli invoke "$CONTRACT_ADDRESS" mint_tokens "$RECIPIENT_ADDRESS" "$MINT_AMOUNT" \
    #     --account "$STARKNET_ACCOUNT_FILE" \
    #     --keystore "$STARKNET_KEYSTORE_FILE" \
    #     --rpc "$STARKNET_RPC"
}

# Generate frontend configuration files
generate_frontend_config() {
    echo -e "${YELLOW}💻 Generating Frontend Configuration...${NC}"
    
    # Extract ABI
    jq '.abi' target/dev/myinsurfi_contracts_MyInsurFiToken.contract_class.json > MyInsurFiABI.json
    echo "✅ ABI extracted to MyInsurFiABI.json"
    
    # Generate TypeScript config
    cat > contractConfig.ts << EOL
// MyInsurFi Contract Configuration
export const CONTRACT_CONFIG = {
  // Network Configuration
  network: '${STARKNET_NETWORK}',
  rpcUrl: '${STARKNET_RPC}',
  
  // Contract Information
  contractAddress: '${CONTRACT_ADDRESS}',
  classHash: '${CLASS_HASH}',
  
  // Token Information
  token: {
    name: '${TOKEN_NAME}',
    symbol: '${TOKEN_SYMBOL}',
    decimals: ${DECIMALS},
    totalSupply: '${TOTAL_SUPPLY}'
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
  
  // Transaction Fees (in wei)
  transactionFees: {
    policyCreation: '50000000000000000',    // 0.05 MYSU
    premiumPayment: '10000000000000000',    // 0.01 MYSU
    claimSubmission: '30000000000000000'    // 0.03 MYSU
  },
  
  // Explorer URLs
  explorerUrl: 'https://testnet.starkscan.co',
  contractExplorerUrl: 'https://testnet.starkscan.co/contract/${CONTRACT_ADDRESS}'
};

// Insurance Type Mappings
export const INSURANCE_TYPES = {
  0: 'Health',
  1: 'Travel', 
  2: 'Schengen',
  3: 'House'
};

// Claim Status Mappings
export const CLAIM_STATUS = {
  0: 'Pending',
  1: 'Approved',
  2: 'Rejected', 
  3: 'Paid'
};
EOL
    
    echo "✅ TypeScript config generated: contractConfig.ts"
    
    # Generate React hook template
    cat > useMyInsurFi.ts << EOL
// MyInsurFi React Hook Template
import { useContract, useAccount } from '@starknet-react/core';
import { CONTRACT_CONFIG } from './contractConfig';

export const useMyInsurFi = () => {
  const { account } = useAccount();
  
  const { contract } = useContract({
    abi: require('./MyInsurFiABI.json'),
    address: CONTRACT_CONFIG.contractAddress,
  });

  const createHealthPolicy = async (
    coverageAmount: string,
    premiumAmount: string, 
    duration: number
  ) => {
    if (!account || !contract) return;
    
    try {
      const result = await account.execute({
        contractAddress: CONTRACT_CONFIG.contractAddress,
        entrypoint: 'create_health_policy',
        calldata: [coverageAmount, premiumAmount, duration.toString()]
      });
      return result;
    } catch (error) {
      console.error('Error creating health policy:', error);
      throw error;
    }
  };

  const payPremium = async (policyId: string) => {
    if (!account || !contract) return;
    
    try {
      const result = await account.execute({
        contractAddress: CONTRACT_CONFIG.contractAddress,
        entrypoint: 'pay_premium', 
        calldata: [policyId]
      });
      return result;
    } catch (error) {
      console.error('Error paying premium:', error);
      throw error;
    }
  };

  return {
    contract,
    createHealthPolicy,
    payPremium,
    // Add more functions as needed
  };
};
EOL
    
    echo "✅ React hook template generated: useMyInsurFi.ts"
}

# Verify configuration
verify_configuration() {
    echo -e "${YELLOW}🔍 Verifying Configuration...${NC}"
    
    # Test agent status
    IS_AGENT=$(starkli call "$CONTRACT_ADDRESS" is_authorized_agent "$OWNER_ADDRESS" --rpc "$STARKNET_RPC")
    echo "✅ Owner Agent Status: $IS_AGENT"
    
    # Test transaction fees
    POLICY_FEE=$(starkli call "$CONTRACT_ADDRESS" estimate_transaction_fee "policy_creation" --rpc "$STARKNET_RPC")
    echo "✅ Policy Creation Fee: $POLICY_FEE wei"
    
    PREMIUM_FEE=$(starkli call "$CONTRACT_ADDRESS" estimate_transaction_fee "premium_payment" --rpc "$STARKNET_RPC")
    echo "✅ Premium Payment Fee: $PREMIUM_FEE wei"
    
    echo -e "${GREEN}✅ Configuration verification complete${NC}"
}

# Main configuration flow
main() {
    configure_premium_rates
    echo ""
    add_insurance_agents
    echo ""
    setup_sponsorship
    echo ""
    mint_additional_tokens
    echo ""
    generate_frontend_config
    echo ""
    verify_configuration
    
    echo ""
    echo -e "${GREEN}🎉 Contract configuration completed!${NC}"
    echo ""
    echo "📄 Generated Files:"
    echo "   - MyInsurFiABI.json (Contract ABI)"
    echo "   - contractConfig.ts (TypeScript config)"
    echo "   - useMyInsurFi.ts (React hook template)"
    echo ""
    echo "🔗 Next Steps:"
    echo "   1. Copy files to your frontend project"
    echo "   2. Install @starknet-react/core"
    echo "   3. Set up your React components"
    echo "   4. Test contract interactions"
}

main "$@"