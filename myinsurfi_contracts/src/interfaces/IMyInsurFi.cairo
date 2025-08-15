/*use starknet::ContractAddress;
use crate::types::insurance_types::{InsurancePolicy, InsuranceType, Claim};

#[starknet::interface]
pub trait IMyInsurFi<TContractState> {
    // Insurance Management Functions
    fn create_health_policy(
        ref self: TContractState, 
        coverage_amount: u256, 
        premium_amount: u256, 
        duration: u64
    ) -> u256;
    
    fn create_travel_policy(
        ref self: TContractState, 
        destination: felt252, 
        coverage_amount: u256, 
        premium_amount: u256, 
        duration: u64
    ) -> u256;
    
    fn create_schengen_policy(
        ref self: TContractState, 
        coverage_amount: u256, 
        premium_amount: u256, 
        duration: u64
    ) -> u256;
    
    fn create_house_policy(
        ref self: TContractState, 
        property_value: felt252, 
        coverage_amount: u256, 
        premium_amount: u256, 
        duration: u64
    ) -> u256;
    
    fn pay_premium(ref self: TContractState, policy_id: u256) -> bool;
    
    fn get_policy_details(self: @TContractState, policy_id: u256) -> InsurancePolicy;
    
    fn get_user_policies(self: @TContractState, user_address: ContractAddress) -> Array<u256>;
    
    fn is_policy_active(self: @TContractState, policy_id: u256) -> bool;
    
    fn cancel_policy(ref self: TContractState, policy_id: u256) -> bool;
    
    // Claims Management Functions
    fn submit_claim(
        ref self: TContractState, 
        policy_id: u256, 
        claim_amount: u256, 
        evidence_hash: felt252
    ) -> u256;
    
    fn approve_claim(ref self: TContractState, claim_id: u256) -> bool;
    
    fn reject_claim(ref self: TContractState, claim_id: u256, reason: felt252) -> bool;
    
    fn process_claim_payment(ref self: TContractState, claim_id: u256) -> bool;
    
    fn get_claim_details(self: @TContractState, claim_id: u256) -> Claim;
    
    fn get_user_claims(self: @TContractState, user_address: ContractAddress) -> Array<u256>;
    
    // View Functions
    fn get_total_policies(self: @TContractState) -> u256;
    
    fn get_total_claims(self: @TContractState) -> u256;
    
    fn get_premium_rate(self: @TContractState, insurance_type: InsuranceType) -> u256;
    
    fn is_authorized_agent(self: @TContractState, agent_address: ContractAddress) -> bool;
}

*/