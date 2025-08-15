// Main contract module
mod myinsurfi_token;

// Interface modules
mod interfaces {
    mod IERC20;
    mod IMyInsurFi;
    mod IPaymaster;
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