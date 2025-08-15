// Simple reentrancy guard without components
pub mod ReentrancyGuard {
    // Constants for reentrancy status
    pub const NOT_ENTERED: u8 = 1;
    pub const ENTERED: u8 = 2;

    // Simple assertion function
    pub fn assert_not_entered(status: u8) {
        assert(status == NOT_ENTERED, 'ReentrancyGuard: reentrant call');
    }

    // Helper to check if entered
    pub fn is_entered(status: u8) -> bool {
        status == ENTERED
    }
}