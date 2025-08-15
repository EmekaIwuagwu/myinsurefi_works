use starknet::ContractAddress;

// Simple access control helpers - no components for now
pub mod AccessControl {
    use super::ContractAddress;
    use starknet::get_caller_address;

    // Simple admin check function
    pub fn assert_only_admin(admin: ContractAddress) {
        let caller = get_caller_address();
        assert(caller == admin, 'Only admin allowed');
    }

    // Simple agent check function  
    pub fn assert_authorized_agent(admin: ContractAddress, agents: @starknet::storage::Map<ContractAddress, bool>) {
        let caller = get_caller_address();
        let is_admin = caller == admin;
        let is_agent = agents.read(caller);
        assert(is_admin || is_agent, 'Not authorized');
    }

    // Role constants
    pub const ADMIN_ROLE: felt252 = 'ADMIN';
    pub const AGENT_ROLE: felt252 = 'AGENT';
    pub const PROCESSOR_ROLE: felt252 = 'PROCESSOR';
}