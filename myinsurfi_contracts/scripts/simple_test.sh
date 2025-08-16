#!/bin/bash

# File: scripts/simple_test.sh
# Simple working version of the interactive tester

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Load environment
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

CONTRACT_ADDRESS="0x062d864e1f0a9539ff12b280376a6da4ae9e3fa6362b31ec669c3199ddc17edc"

clear
echo -e "${PURPLE}🧪 MyInsurFi Simple Tester${NC}"
echo -e "${CYAN}Contract: $CONTRACT_ADDRESS${NC}"
echo "=================================="

# Helper functions
call_contract() {
    starkli call "$CONTRACT_ADDRESS" "$@" --rpc "$STARKNET_RPC" 2>/dev/null || echo "ERROR"
}

invoke_contract() {
    starkli invoke "$CONTRACT_ADDRESS" "$@" \
        --account "$STARKNET_ACCOUNT_FILE" \
        --keystore "$STARKNET_KEYSTORE_FILE" \
        --rpc "$STARKNET_RPC"
}

# Main menu
while true; do
    clear
    echo -e "${PURPLE}🧪 MyInsurFi Simple Tester${NC}"
    echo -e "${CYAN}Contract: $CONTRACT_ADDRESS${NC}"
    echo "=================================="
    echo ""
    echo "📊 Basic Tests:"
    echo "  1. Check token info"
    echo "  2. Check your balance"
    echo "  3. Transfer tokens"
    echo ""
    echo "🏥 Insurance Tests:"
    echo "  4. Create health policy"
    echo "  5. Pay premium"
    echo "  6. View policy details"
    echo ""
    echo "📋 Claims Tests:"
    echo "  7. Submit claim"
    echo "  8. View claim details"
    echo ""
    echo "🔧 Quick Tests:"
    echo "  9. Test contract basics"
    echo ""
    echo "  0. Exit"
    echo ""
    read -p "Choose option [0-9]: " choice
    
    case $choice in
        1)
            echo -e "${BLUE}🪙 TOKEN INFO${NC}"
            echo "============="
            echo "Name: $(call_contract name)"
            echo "Symbol: $(call_contract symbol)"
            echo "Total Supply: $(call_contract total_supply)"
            read -p "Press Enter to continue..."
            ;;
        2)
            echo -e "${BLUE}💰 YOUR BALANCE${NC}"
            echo "==============="
            balance=$(call_contract balance_of "$OWNER_ADDRESS")
            echo "Balance: $balance wei"
            if [ "$balance" != "ERROR" ] && [ "$balance" != "0" ]; then
                readable=$(echo "scale=4; $balance / 1000000000000000000" | bc 2>/dev/null || echo "calc_error")
                echo "Readable: $readable MYSU tokens"
            fi
            read -p "Press Enter to continue..."
            ;;
        3)
            echo -e "${BLUE}💸 TRANSFER TOKENS${NC}"
            echo "=================="
            read -p "Recipient address: " to_address
            read -p "Amount (MYSU tokens): " amount
            amount_wei=$(echo "$amount * 1000000000000000000" | bc | cut -d. -f1)
            echo "Transferring $amount MYSU ($amount_wei wei)..."
            invoke_contract transfer "$to_address" "$amount_wei"
            read -p "Press Enter to continue..."
            ;;
        4)
            echo -e "${BLUE}🏥 CREATE HEALTH POLICY${NC}"
            echo "======================="
            read -p "Coverage (MYSU tokens): " coverage
            read -p "Premium (MYSU tokens): " premium  
            read -p "Duration (days): " days
            
            coverage_wei=$(echo "$coverage * 1000000000000000000" | bc | cut -d. -f1)
            premium_wei=$(echo "$premium * 1000000000000000000" | bc | cut -d. -f1)
            duration_seconds=$((days * 24 * 60 * 60))
            
            echo "Creating policy..."
            echo "Coverage: $coverage MYSU"
            echo "Premium: $premium MYSU"
            echo "Duration: $days days"
            
            invoke_contract create_health_policy "$coverage_wei" "$premium_wei" "$duration_seconds"
            
            echo ""
            echo "Checking total policies..."
            total=$(call_contract get_total_policies)
            echo "Total policies: $total"
            read -p "Press Enter to continue..."
            ;;
        5)
            echo -e "${BLUE}💳 PAY PREMIUM${NC}"
            echo "=============="
            total=$(call_contract get_total_policies)
            echo "Total policies: $total"
            read -p "Policy ID to pay: " policy_id
            echo "Paying premium for policy $policy_id..."
            invoke_contract pay_premium "$policy_id"
            read -p "Press Enter to continue..."
            ;;
        6)
            echo -e "${BLUE}👁️ VIEW POLICY${NC}"
            echo "=============="
            read -p "Policy ID: " policy_id
            echo "Policy details:"
            call_contract get_policy_details "$policy_id"
            read -p "Press Enter to continue..."
            ;;
        7)
            echo -e "${BLUE}📋 SUBMIT CLAIM${NC}"
            echo "==============="
            read -p "Policy ID: " policy_id
            read -p "Claim amount (MYSU): " claim_amount
            read -p "Evidence description: " evidence
            
            claim_wei=$(echo "$claim_amount * 1000000000000000000" | bc | cut -d. -f1)
            echo "Submitting claim..."
            invoke_contract submit_claim "$policy_id" "$claim_wei" "'$evidence'"
            
            echo ""
            total_claims=$(call_contract get_total_claims)
            echo "Total claims: $total_claims"
            read -p "Press Enter to continue..."
            ;;
        8)
            echo -e "${BLUE}👁️ VIEW CLAIM${NC}"
            echo "=============="
            read -p "Claim ID: " claim_id
            echo "Claim details:"
            call_contract get_claim_details "$claim_id"
            read -p "Press Enter to continue..."
            ;;
        9)
            echo -e "${BLUE}🔧 QUICK CONTRACT TEST${NC}"
            echo "======================"
            echo "Testing basic functions..."
            echo ""
            echo "1. Token name: $(call_contract name)"
            echo "2. Your balance: $(call_contract balance_of $OWNER_ADDRESS)"
            echo "3. Total policies: $(call_contract get_total_policies)"
            echo "4. Total claims: $(call_contract get_total_claims)"
            echo ""
            echo "If all show proper values (not ERROR), contract is working!"
            read -p "Press Enter to continue..."
            ;;
        0)
            echo -e "${GREEN}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            sleep 1
            ;;
    esac
done