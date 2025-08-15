// Main contract module
mod myinsurfi_token;

// Interface modules (simplified to avoid import issues)
mod interfaces {
    mod IERC20;
}

// Utility modules
mod utils {
    mod access_control;
    mod reentrancy_guard;
}

// Type definition modules
mod types {
    mod insurance_types;
    mod paymaster_types;
}