use starknet::ContractAddress;

// Transaction sponsorship record
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct TransactionSponsorshipRecord {
    pub id: u256,
    pub user: ContractAddress,
    pub transaction_hash: felt252,
    pub fee_amount: u256,
    pub timestamp: u64,
}

// Simple sponsorship configuration
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct SponsorshipConfig {
    pub daily_limit: u256,
    pub is_active: bool,
}

// Sponsorship limit structure - ADDED THIS!
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct SponsorshipLimit {
    pub daily_limit: u256,
    pub transaction_type_limit: u256,
    pub is_active: bool,
}

// Transaction type constants
pub mod TransactionTypes {
    pub const POLICY_CREATION: felt252 = 'policy_creation';
    pub const PREMIUM_PAYMENT: felt252 = 'premium_payment';
    pub const CLAIM_SUBMISSION: felt252 = 'claim_submission';
    pub const TOKEN_TRANSFER: felt252 = 'token_transfer';
}

// Default fee amounts (in wei)
pub mod DefaultFees {
    pub const POLICY_CREATION_FEE: u256 = 50000000000000000; // 0.05 token
    pub const PREMIUM_PAYMENT_FEE: u256 = 10000000000000000; // 0.01 token  
    pub const CLAIM_SUBMISSION_FEE: u256 = 30000000000000000; // 0.03 token
    pub const TOKEN_TRANSFER_FEE: u256 = 5000000000000000; // 0.005 token
}