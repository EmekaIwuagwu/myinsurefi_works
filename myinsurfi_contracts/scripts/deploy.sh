#!/bin/bash

# MyInsurFi Contract Deployment Script
# Handles complete deployment process: build -> declare -> deploy -> verify

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${RED}❌ .env file not found. Run ./scripts/setup_env.sh first${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Starting MyInsurFi Contract Deployment${NC}"
echo "=================================="

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"
    
    # Check if account file exists
    if [ ! -f "$STARKNET_ACCOUNT_FILE" ]; then
        echo -e "${RED}❌ Account file not found: $STARKNET_ACCOUNT_FILE${NC}"
        echo "Run ./scripts/setup_env.sh first"
        exit 1
    fi
    
    # Check account balance
    echo "💰 Checking account balance..."
    BALANCE=$(starkli balance "$OWNER_ADDRESS" --rpc "$STARKNET_RPC" 2>/dev/null || echo "0")
    if [ "$BALANCE" = "0" ]; then
        echo -e "${RED}❌ Account has no balance. Please fund your account:${NC}"
        echo "   Address: $OWNER_ADDRESS"
        echo "   Faucet: https://faucet.goerli.starknet.io/"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
}

# Build the contract
build_contract() {
    echo -e "${YELLOW}🔨 Building contract...${NC}"
    scarb build
    
    if [ ! -f "target/dev/myinsurfi_contracts_MyInsurFiToken.contract_class.json" ]; then
        echo -e "${RED}❌ Contract build failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Contract built successfully${NC}"
}

# Declare the contract class
declare_contract() {
    echo -e "${YELLOW}📋 Declaring contract class...${NC}"
    
    CLASS_HASH=$(starkli declare target/dev/myinsurfi_contracts_MyInsurFiToken.contract_class.json \
        --account "$STARKNET_ACCOUNT_FILE" \
        --keystore "$STARKNET_KEYSTORE_FILE" \
        --rpc "$STARKNET_RPC" \
        2>/dev/null | grep -o '0x[a-fA-F0-9]*' | head -1)
    
    if [ -z "$CLASS_HASH" ]; then
        echo -e "${RED}❌ Contract declaration failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Contract declared successfully${NC}"
    echo "📝 Class Hash: $CLASS_HASH"
    
    # Save class hash to file
    echo "CLASS_HASH=$CLASS_HASH" >> .env
    echo "$CLASS_HASH" > class_hash.txt
}

# Deploy the contract instance
deploy_contract() {
    echo -e "${YELLOW}🚀 Deploying contract instance...${NC}"
    
    CONTRACT_ADDRESS=$(starkli deploy "$CLASS_HASH" \
        --account "$STARKNET_ACCOUNT_FILE" \
        --keystore "$STARKNET_KEYSTORE_FILE" \
        --rpc "$STARKNET_RPC" \
        "$OWNER_ADDRESS" \
        2>/dev/null | grep -o '0x[a-fA-F0-9]*' | head -1)
    
    if [ -z "$CONTRACT_ADDRESS" ]; then
        echo -e "${RED}❌ Contract deployment failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Contract deployed successfully${NC}"
    echo "📍 Contract Address: $CONTRACT_ADDRESS"
    
    # Save contract address to file  
    echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS" >> .env
    echo "$CONTRACT_ADDRESS" > contract_address.txt
}

# Verify deployment
verify_deployment() {
    echo -e "${YELLOW}🔍 Verifying deployment...${NC}"
    
    # Test basic contract calls
    echo "Testing contract calls..."
    
    # Test token name
    NAME=$(starkli call "$CONTRACT_ADDRESS" name --rpc "$STARKNET_RPC" 2>/dev/null || echo "")
    if [ -n "$NAME" ]; then
        echo "✅ Token Name: $NAME"
    fi
    
    # Test token symbol  
    SYMBOL=$(starkli call "$CONTRACT_ADDRESS" symbol --rpc "$STARKNET_RPC" 2>/dev/null || echo "")
    if [ -n "$SYMBOL" ]; then
        echo "✅ Token Symbol: $SYMBOL"
    fi
    
    # Test total supply
    SUPPLY=$(starkli call "$CONTRACT_ADDRESS" total_supply --rpc "$STARKNET_RPC" 2>/dev/null || echo "")
    if [ -n "$SUPPLY" ]; then
        echo "✅ Total Supply: $SUPPLY"
    fi
    
    # Test owner balance
    BALANCE=$(starkli call "$CONTRACT_ADDRESS" balance_of "$OWNER_ADDRESS" --rpc "$STARKNET_RPC" 2>/dev/null || echo "")
    if [ -n "$BALANCE" ]; then
        echo "✅ Owner Balance: $BALANCE"
    fi
    
    echo -e "${GREEN}✅ Deployment verification complete${NC}"
}

# Generate deployment summary
generate_summary() {
    echo -e "${BLUE}📊 Deployment Summary${NC}"
    echo "===================="
    echo "🌐 Network: $STARKNET_NETWORK"
    echo "👤 Owner: $OWNER_ADDRESS"  
    echo "📋 Class Hash: $CLASS_HASH"
    echo "📍 Contract Address: $CONTRACT_ADDRESS"
    echo "🪙 Token: $TOKEN_SYMBOL ($TOKEN_NAME)"
    echo "📦 Total Supply: $TOTAL_SUPPLY"
    echo ""
    echo "🔗 Contract Explorer:"
    echo "   https://testnet.starkscan.co/contract/$CONTRACT_ADDRESS"
    echo ""
    echo "📄 Files Generated:"
    echo "   - class_hash.txt"
    echo "   - contract_address.txt"
    echo "   - deployment_config.json"
    
    # Generate deployment config JSON
    cat > deployment_config.json << EOL
{
    "network": "$STARKNET_NETWORK",
    "owner": "$OWNER_ADDRESS",
    "classHash": "$CLASS_HASH",
    "contractAddress": "$CONTRACT_ADDRESS",
    "token": {
        "name": "$TOKEN_NAME",
        "symbol": "$TOKEN_SYMBOL",
        "decimals": $DECIMALS,
        "totalSupply": "$TOTAL_SUPPLY"
    },
    "deploymentDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "explorerUrl": "https://testnet.starkscan.co/contract/$CONTRACT_ADDRESS"
}
EOL
}

# Main deployment flow
main() {
    check_prerequisites
    build_contract
    declare_contract
    deploy_contract
    verify_deployment
    generate_summary
    
    echo -e "${GREEN}🎉 MyInsurFi deployment completed successfully!${NC}"
    echo ""
    echo "🔗 Next steps:"
    echo "   1. Test your contract functions"
    echo "   2. Set up frontend integration"
    echo "   3. Add authorized insurance agents"
    echo "   4. Configure premium rates"
}

# Run main function
main "$@"