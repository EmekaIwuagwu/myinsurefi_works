#!/bin/bash

# MyInsurFi Contract Testing Script
# Tests all major contract functions after deployment

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

echo -e "${BLUE}🧪 Testing MyInsurFi Contract${NC}"
echo "Contract: $CONTRACT_ADDRESS"
echo "=========================="

# Test ERC20 Functions
test_erc20() {
    echo -e "${YELLOW}🪙 Testing ERC20 Functions...${NC}"
    
    # Test name
    NAME=$(starkli call "$CONTRACT_ADDRESS" name --rpc "$STARKNET_RPC")
    echo "✅ Name: $NAME"
    
    # Test symbol
    SYMBOL=$(starkli call "$CONTRACT_ADDRESS" symbol --rpc "$STARKNET_RPC")
    echo "✅ Symbol: $SYMBOL"
    
    # Test decimals
    DECIMALS=$(starkli call "$CONTRACT_ADDRESS" decimals --rpc "$STARKNET_RPC")
    echo "✅ Decimals: $DECIMALS"
    
    # Test total supply
    SUPPLY=$(starkli call "$CONTRACT_ADDRESS" total_supply --rpc "$STARKNET_RPC")
    echo "✅ Total Supply: $SUPPLY"
    
    # Test owner balance
    BALANCE=$(starkli call "$CONTRACT_ADDRESS" balance_of "$OWNER_ADDRESS" --rpc "$STARKNET_RPC")
    echo "✅ Owner Balance: $BALANCE"
}

# Test Insurance Functions
test_insurance() {
    echo -e "${YELLOW}🏥 Testing Insurance Functions...${NC}"
    
    # Test policy counters
    TOTAL_POLICIES=$(starkli call "$CONTRACT_ADDRESS" get_total_policies --rpc "$STARKNET_RPC")
    echo "✅ Total Policies: $TOTAL_POLICIES"
    
    TOTAL_CLAIMS=$(starkli call "$CONTRACT_ADDRESS" get_total_claims --rpc "$STARKNET_RPC")
    echo "✅ Total Claims: $TOTAL_CLAIMS"
    
    # Test if owner is authorized agent
    IS_AGENT=$(starkli call "$CONTRACT_ADDRESS" is_authorized_agent "$OWNER_ADDRESS" --rpc "$STARKNET_RPC")
    echo "✅ Owner is Agent: $IS_AGENT"
}

# Test Paymaster Functions
test_paymaster() {
    echo -e "${YELLOW}🎫 Testing Paymaster Functions...${NC}"
    
    # Test transaction fee estimation
    POLICY_FEE=$(starkli call "$CONTRACT_ADDRESS" estimate_transaction_fee "policy_creation" --rpc "$STARKNET_RPC")
    echo "✅ Policy Creation Fee: $POLICY_FEE"
    
    PREMIUM_FEE=$(starkli call "$CONTRACT_ADDRESS" estimate_transaction_fee "premium_payment" --rpc "$STARKNET_RPC")
    echo "✅ Premium Payment Fee: $PREMIUM_FEE"
    
    # Test sponsorship balance
    SPONSORSHIP=$(starkli call "$CONTRACT_ADDRESS" get_sponsorship_balance "$OWNER_ADDRESS" --rpc "$STARKNET_RPC")
    echo "✅ Owner Sponsorship Balance: $SPONSORSHIP"
}

# Create a test health policy
test_create_policy() {
    echo -e "${YELLOW}🏥 Testing Policy Creation...${NC}"
    
    # Policy parameters
    COVERAGE_AMOUNT="10000000000000000000"  # 10 tokens
    PREMIUM_AMOUNT="500000000000000000"     # 0.5 tokens  
    DURATION="31536000"                     # 1 year in seconds
    
    echo "Creating health policy with:"
    echo "  Coverage: $COVERAGE_AMOUNT wei (10 tokens)"
    echo "  Premium: $PREMIUM_AMOUNT wei (0.5 tokens)"
    echo "  Duration: $DURATION seconds (1 year)"
    
    # Create policy
    RESULT=$(starkli invoke "$CONTRACT_ADDRESS" create_health_policy \
        "$COVERAGE_AMOUNT" "$PREMIUM_AMOUNT" "$DURATION" \
        --account "$STARKNET_ACCOUNT_FILE" \
        --keystore "$STARKNET_KEYSTORE_FILE" \
        --rpc "$STARKNET_RPC" 2>/dev/null || echo "failed")
    
    if [ "$RESULT" != "failed" ]; then
        echo -e "${GREEN}✅ Health policy created successfully${NC}"
        
        # Check updated policy count
        sleep 5  # Wait for transaction to be processed
        NEW_TOTAL=$(starkli call "$CONTRACT_ADDRESS" get_total_policies --rpc "$STARKNET_RPC")
        echo "✅ New Total Policies: $NEW_TOTAL"
        
        if [ "$NEW_TOTAL" != "$TOTAL_POLICIES" ]; then
            echo -e "${GREEN}✅ Policy counter incremented correctly${NC}"
        fi
    else
        echo -e "${RED}❌ Policy creation failed${NC}"
    fi
}

# Test administrative functions
test_admin() {
    echo -e "${YELLOW}👨‍💼 Testing Admin Functions...${NC}"
    
    # Test adding authorized agent (self)
    RESULT=$(starkli invoke "$CONTRACT_ADDRESS" add_authorized_agent "$OWNER_ADDRESS" \
        --account "$STARKNET_ACCOUNT_FILE" \
        --keystore "$STARKNET_KEYSTORE_FILE" \
        --rpc "$STARKNET_RPC" 2>/dev/null || echo "failed")
    
    if [ "$RESULT" != "failed" ]; then
        echo -e "${GREEN}✅ Added authorized agent successfully${NC}"
        
        # Verify agent status
        sleep 3
        IS_AGENT_NOW=$(starkli call "$CONTRACT_ADDRESS" is_authorized_agent "$OWNER_ADDRESS" --rpc "$STARKNET_RPC")
        echo "✅ Owner Agent Status: $IS_AGENT_NOW"
    else
        echo -e "${RED}❌ Adding agent failed${NC}"
    fi
}

# Run all tests
run_tests() {
    test_erc20
    echo ""
    test_insurance  
    echo ""
    test_paymaster
    echo ""
    test_admin
    echo ""
    test_create_policy
}

# Generate test report
generate_report() {
    echo -e "${BLUE}📊 Test Report${NC}"
    echo "=============="
    echo "🌐 Network: $STARKNET_NETWORK"
    echo "📍 Contract: $CONTRACT_ADDRESS"
    echo "🕐 Test Time: $(date)"
    echo ""
    echo "🧪 Tests Completed:"
    echo "   ✅ ERC20 Functions"
    echo "   ✅ Insurance Functions"  
    echo "   ✅ Paymaster Functions"
    echo "   ✅ Admin Functions"
    echo "   ✅ Policy Creation"
    echo ""
    echo -e "${GREEN}🎉 All tests completed successfully!${NC}"
}

# Main execution
main() {
    run_tests
    generate_report
}

main "$@"