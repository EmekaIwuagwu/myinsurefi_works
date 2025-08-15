#!/bin/bash

# MyInsurFi Contract Deployment Environment Setup
# Run this first to set up your environment

set -e

echo "🔧 Setting up MyInsurFi deployment environment..."

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    cat > .env << EOL
# StarkNet Network Configuration
STARKNET_NETWORK=goerli-alpha
STARKNET_RPC=https://starknet-goerli.g.alchemy.com/v2/YOUR_API_KEY

# Account Configuration  
STARKNET_ACCOUNT_FILE=~/.starkli-wallets/deployer
STARKNET_KEYSTORE_FILE=~/.starkli-wallets/deployer

# Contract Configuration
OWNER_ADDRESS=0x1234567890abcdef1234567890abcdef12345678
CONTRACT_NAME=MyInsurFiToken

# Deployment Configuration
MAX_FEE=0.01
WAIT_FOR_CONFIRMATION=true

# Token Configuration
TOKEN_NAME="MY Insurance Token"
TOKEN_SYMBOL="MYSU"
TOTAL_SUPPLY=40000000000000000000000000
DECIMALS=18
EOL

    echo "✅ Created .env file. Please update with your values:"
    echo "   - STARKNET_RPC: Your Alchemy/Infura RPC URL"
    echo "   - OWNER_ADDRESS: Your wallet address"
    echo ""
fi

# Check if starkli is installed
if ! command -v starkli &> /dev/null; then
    echo "❌ Starkli not found. Installing..."
    curl https://get.starkli.sh | sh
    starkliup
fi

# Check if scarb is installed  
if ! command -v scarb &> /dev/null; then
    echo "❌ Scarb not found. Please install Scarb first:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh"
    exit 1
fi

# Source environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Create account if it doesn't exist
if [ ! -f "$STARKNET_ACCOUNT_FILE" ]; then
    echo "🔐 Creating StarkNet account..."
    starkli account oz init "$STARKNET_ACCOUNT_FILE"
    echo "⚠️  Please fund your account with testnet ETH before deployment"
    echo "   Address: $OWNER_ADDRESS"
    echo "   Faucet: https://faucet.goerli.starknet.io/"
fi

echo "✅ Environment setup complete!"
echo "📋 Next steps:"
echo "   1. Update .env with your values"
echo "   2. Fund your account with testnet ETH"  
echo "   3. Run: ./scripts/deploy.sh"