use starknet::ContractAddress;

// Insurance policy structure
#[derive(Drop, Serde, starknet::Store)]
pub struct InsurancePolicy {
    pub id: u256,
    pub policy_holder: ContractAddress,
    pub insurance_type: u8, // 0=Health, 1=Travel, 2=Schengen, 3=House
    pub coverage_amount: u256,
    pub premium_amount: u256,
    pub start_date: u64,
    pub end_date: u64,
    pub is_active: bool,
    pub metadata: felt252,
}

// Claims structure
#[derive(Drop, Serde, starknet::Store, Copy)]
pub struct Claim {
    pub id: u256,
    pub policy_id: u256,
    pub claimant: ContractAddress,
    pub claim_amount: u256,
    pub evidence_hash: felt252,
    pub status: u8, // 0=Pending, 1=Approved, 2=Rejected, 3=Paid
    pub submission_date: u64,
    pub processing_date: u64,
}

// Insurance type enum - Fixed warning
#[derive(Drop, Serde, starknet::Store, PartialEq, Copy)]
#[allow(starknet::store_no_default_variant)]
pub enum InsuranceType {
    Health,
    Travel,
    Schengen,
    House,
}

// Insurance type constants
pub mod InsuranceTypes {
    pub const HEALTH: u8 = 0;
    pub const TRAVEL: u8 = 1; 
    pub const SCHENGEN: u8 = 2;
    pub const HOUSE: u8 = 3;
}

// Claim status constants
pub mod ClaimStatus {
    pub const PENDING: u8 = 0;
    pub const APPROVED: u8 = 1;
    pub const REJECTED: u8 = 2;
    pub const PAID: u8 = 3;
}