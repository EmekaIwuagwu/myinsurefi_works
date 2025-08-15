/*use starknet::ContractAddress;
use crate::types::paymaster_types::{TransactionSponsorshipRecord, SponsorshipLimit};

#[starknet::interface]
pub trait IPaymaster<TContractState> {
    // Core Paymaster Functions
    fn validate_and_pay_for_transaction(
        ref self: TContractState, 
        transaction_hash: felt252, 
        max_fee: u256
    ) -> bool;
    
    fn estimate_transaction_fee(
        self: @TContractState, 
        transaction_type: felt252
    ) -> u256;
    
    fn is_transaction_sponsored(
        self: @TContractState, 
        user_address: ContractAddress, 
        transaction_type: felt252
    ) -> bool;
    
    // Sponsorship Management
    fn get_sponsorship_balance(self: @TContractState, user_address: ContractAddress) -> u256;
    
    fn add_sponsorship_balance(
        ref self: TContractState, 
        user_address: ContractAddress, 
        amount: u256
    ) -> bool;
    
    fn deduct_sponsorship_balance(
        ref self: TContractState, 
        user_address: ContractAddress, 
        amount: u256
    ) -> bool;
    
    // Transaction Fee Management
    fn set_transaction_fee(
        ref self: TContractState, 
        transaction_type: felt252, 
        fee_amount: u256
    );
    
    fn get_transaction_fee(
        self: @TContractState, 
        transaction_type: felt252
    ) -> u256;
    
    // Sponsorship Limits
    fn set_daily_sponsorship_limit(
        ref self: TContractState, 
        user_address: ContractAddress, 
        daily_limit: u256
    );
    
    fn get_daily_sponsorship_limit(
        self: @TContractState, 
        user_address: ContractAddress
    ) -> u256;
    
    fn get_daily_sponsorship_used(
        self: @TContractState, 
        user_address: ContractAddress, 
        day: u64
    ) -> u256;
    
    fn set_sponsorship_limit_for_transaction_type(
        ref self: TContractState, 
        transaction_type: felt252, 
        limit: SponsorshipLimit
    );
    
    fn get_sponsorship_limit_for_transaction_type(
        self: @TContractState, 
        transaction_type: felt252
    ) -> SponsorshipLimit;
    
    // Sponsorship Records
    fn get_sponsorship_record(
        self: @TContractState, 
        record_id: u256
    ) -> TransactionSponsorshipRecord;
    
    fn get_user_sponsorship_records(
        self: @TContractState, 
        user_address: ContractAddress
    ) -> Array<u256>;
    
    // Administrative Functions
    fn pause_sponsorship(ref self: TContractState);
    
    fn unpause_sponsorship(ref self: TContractState);
    
    fn is_sponsorship_paused(self: @TContractState) -> bool;
    
    fn withdraw_sponsorship_funds(ref self: TContractState, amount: u256) -> bool;
    
    fn get_total_sponsorship_balance(self: @TContractState) -> u256;
}

*/