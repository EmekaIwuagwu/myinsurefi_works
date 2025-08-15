use starknet::ContractAddress;

// Simple access control helpers
pub mod AccessControl {
    use super::ContractAddress;
    use starknet::get_caller_address;

    // Simple admin check function
    pub fn assert_only_admin(admin: ContractAddress) {
        let caller = get_caller_address();
        assert(caller == admin, 'Only admin allowed');
    }

    // Role constants
    pub const ADMIN_ROLE: felt252 = 'ADMIN';
    pub const AGENT_ROLE: felt252 = 'AGENT';
    pub const PROCESSOR_ROLE: felt252 = 'PROCESSOR';
}