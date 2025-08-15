#!/bin/bash

# MyInsurFi Master Deployment Script
# Complete end-to-end deployment and configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                    🏥 MyInsurFi Deployment 🏥                ║
║                                                               ║
║            Complete Insurance Smart Contract Platform         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if we're in the right directory
if [ ! -f "Scarb.toml" ]; then
    echo -e "${RED}❌ Must be run from myinsurfi_contracts directory${NC}"
    exit 1
fi

# Make scripts executable
chmod +x scripts/*.sh

# Step 1: Environment Setup
echo -e "${BLUE}Step 1: Environment Setup${NC}"
echo "========================="
if [ ! -f ".env" ]; then
    ./scripts/setup_env.sh
    echo ""
    echo -e "${YELLOW}⚠️  Please update .env file with your values and run again${NC}"
    echo "Required updates:"
    echo "  - STARKNET_RPC: Your Alchemy/Infura RPC URL"
    echo "  - OWNER_ADDRESS: Your wallet address"
    exit 0
else
    echo -e "${GREEN}✅ Environment already configured${NC}"
fi

echo ""

# Step 2: Pre-deployment checks
echo -e "${BLUE}Step 2: Pre-deployment Checks${NC}"
echo "============================="

# Load environment
export $(cat .env | grep -v '^#' | xargs)

# Check account balance
echo "💰 Checking account balance..."
BALANCE=$(starkli balance "$OWNER_ADDRESS" --rpc "$STARKNET_RPC" 2>/dev/null || echo "0")
if [ "$BALANCE" = "0" ]; then
    echo -e "${RED}❌ Account has no balance. Please fund your account:${NC}"
    echo "   Address: $OWNER_ADDRESS"
    echo "   Faucet: https://faucet.goerli.starknet.io/"
    exit 1
fi
echo -e "${GREEN}✅ Account funded: $BALANCE ETH${NC}"

echo ""

# Step 3: Contract Deployment
echo -e "${BLUE}Step 3: Contract Deployment${NC}"
echo "=========================="
if [ -f "contract_address.txt" ]; then
    echo -e "${YELLOW}⚠️  Contract already deployed. Skipping...${NC}"
    CONTRACT_ADDRESS=$(cat contract_address.txt)
    echo "Existing contract: $CONTRACT_ADDRESS"
else
    ./scripts/deploy.sh
fi

echo ""

# Step 4: Contract Testing
echo -e "${BLUE}Step 4: Contract Testing${NC}"
echo "======================="
./scripts/test_contract.sh

echo ""

# Step 5: Contract Configuration
echo -e "${BLUE}Step 5: Contract Configuration${NC}"
echo "============================="
./scripts/configure_contract.sh

echo ""

# Step 6: Final Summary
echo -e "${BLUE}Step 6: Deployment Summary${NC}"
echo "========================="

# Load deployment config
if [ -f "deployment_config.json" ]; then
    CONTRACT_ADDRESS=$(jq -r '.contractAddress' deployment_config.json)
    CLASS_HASH=$(jq -r '.classHash' deployment_config.json)
    NETWORK=$(jq -r '.network' deployment_config.json)
    TOKEN_SYMBOL=$(jq -r '.token.symbol' deployment_config.json)
    TOKEN_NAME=$(jq -r '.token.name' deployment_config.json)
fi

echo ""
echo -e "${GREEN}🎉 MyInsurFi Deployment Completed Successfully! 🎉${NC}"
echo ""
echo "📊 Deployment Details:"
echo "======================"
echo "🌐 Network: $NETWORK"
echo "👤 Owner: $OWNER_ADDRESS"
echo "📋 Class Hash: $CLASS_HASH"
echo "📍 Contract Address: $CONTRACT_ADDRESS"
echo "🪙 Token: $TOKEN_SYMBOL ($TOKEN_NAME)"
echo ""
echo "🔗 Useful Links:"
echo "================"
echo "📱 Contract Explorer: https://testnet.starkscan.co/contract/$CONTRACT_ADDRESS"
echo "💰 StarkNet Faucet: https://faucet.goerli.starknet.io/"
echo "📚 StarkNet Docs: https://docs.starknet.io/"
echo ""
echo "📄 Generated Files:"
echo "=================="
echo "✅ deployment_config.json - Complete deployment configuration"
echo "✅ MyInsurFiABI.json - Contract ABI for frontend"
echo "✅ contractConfig.ts - TypeScript configuration"
echo "✅ useMyInsurFi.ts - React hook template"
echo "✅ class_hash.txt - Contract class hash"
echo "✅ contract_address.txt - Contract address"
echo ""
echo "🚀 Next Steps:"
echo "=============="
echo "1. 💻 Frontend Development:"
echo "   - Copy contractConfig.ts and MyInsurFiABI.json to your React project"
echo "   - Install @starknet-react/core for wallet integration"
echo "   - Use the provided React hook template"
echo ""
echo "2. 🧪 Testing:"
echo "   - Create test insurance policies"
echo "   - Test premium payments"
echo "   - Test claims submission and processing"
echo ""
echo "3. 👥 Team Setup:"
echo "   - Add insurance agents using add_authorized_agent function"
echo "   - Set up proper access controls"
echo "   - Configure operational parameters"
echo ""
echo "4. 🔐 Security:"
echo "   - Audit smart contract code"
echo "   - Test edge cases thoroughly"
echo "   - Set up monitoring and alerts"
echo ""
echo "5. 🌐 Production:"
echo "   - Deploy to StarkNet mainnet when ready"
echo "   - Set up proper infrastructure"
echo "   - Launch your insurance platform!"
echo ""

# Create quick reference guide
cat > DEPLOYMENT_GUIDE.md << EOL
# MyInsurFi Deployment Quick Reference

## Contract Information
- **Network**: $NETWORK
- **Contract Address**: $CONTRACT_ADDRESS
- **Class Hash**: $CLASS_HASH
- **Owner**: $OWNER_ADDRESS

## Token Details
- **Name**: $TOKEN_NAME
- **Symbol**: $TOKEN_SYMBOL
- **Total Supply**: 40,000,000 tokens
- **Decimals**: 18

## Key Features
- ✅ ERC20 Token (MYSU)
- ✅ Health Insurance Policies
- ✅ Travel Insurance Policies
- ✅ Schengen Insurance Policies
- ✅ House Insurance Policies
- ✅ Claims Processing System
- ✅ Paymaster Functionality
- ✅ Administrative Controls

## Quick Commands

### Check Contract Status
\`\`\`bash
starkli call $CONTRACT_ADDRESS name --rpc $STARKNET_RPC
starkli call $CONTRACT_ADDRESS total_supply --rpc $STARKNET_RPC
\`\`\`

### Create Health Policy
\`\`\`bash
starkli invoke $CONTRACT_ADDRESS create_health_policy \\
  "10000000000000000000" "500000000000000000" "31536000" \\
  --account $STARKNET_ACCOUNT_FILE --keystore $STARKNET_KEYSTORE_FILE --rpc $STARKNET_RPC
\`\`\`

### Check Policy Count
\`\`\`bash
starkli call $CONTRACT_ADDRESS get_total_policies --rpc $STARKNET_RPC
\`\`\`

## Frontend Integration
1. Copy \`contractConfig.ts\` and \`MyInsurFiABI.json\` to your React project
2. Install StarkNet React: \`npm install @starknet-react/core\`
3. Use the provided React hook in \`useMyInsurFi.ts\`

## Support
- 🔗 Contract Explorer: https://testnet.starkscan.co/contract/$CONTRACT_ADDRESS
- 📚 StarkNet Documentation: https://docs.starknet.io/
- 💰 Testnet Faucet: https://faucet.goerli.starknet.io/

Generated on: $(date)
EOL

echo "📋 Quick reference guide created: DEPLOYMENT_GUIDE.md"
echo ""
echo -e "${PURPLE}Thank you for using MyInsurFi! 🚀${NC}"