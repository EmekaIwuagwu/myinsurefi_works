use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};

// Define types locally to avoid import issues
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

#[derive(Drop, Serde, starknet::Store)]
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

#[starknet::interface]
pub trait IMyInsurFiToken<TContractState> {
    // ERC20 Functions
    fn name(self: @TContractState) -> ByteArray;
    fn symbol(self: @TContractState) -> ByteArray;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, to: ContractAddress, amount: u256) -> bool;
    fn transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;

    // Insurance Functions
    fn create_health_policy(ref self: TContractState, coverage_amount: u256, premium_amount: u256, duration: u64) -> u256;
    fn create_travel_policy(ref self: TContractState, destination: felt252, coverage_amount: u256, premium_amount: u256, duration: u64) -> u256;
    fn create_schengen_policy(ref self: TContractState, coverage_amount: u256, premium_amount: u256, duration: u64) -> u256;
    fn create_house_policy(ref self: TContractState, property_value: felt252, coverage_amount: u256, premium_amount: u256, duration: u64) -> u256;
    fn pay_premium(ref self: TContractState, policy_id: u256) -> bool;
    fn get_policy_details(self: @TContractState, policy_id: u256) -> InsurancePolicy;
    fn cancel_policy(ref self: TContractState, policy_id: u256) -> bool;

    // Claims Functions
    fn submit_claim(ref self: TContractState, policy_id: u256, claim_amount: u256, evidence_hash: felt252) -> u256;
    fn approve_claim(ref self: TContractState, claim_id: u256) -> bool;
    fn reject_claim(ref self: TContractState, claim_id: u256, reason: felt252) -> bool;
    fn process_claim_payment(ref self: TContractState, claim_id: u256) -> bool;
    fn get_claim_details(self: @TContractState, claim_id: u256) -> Claim;

    // Paymaster Functions
    fn validate_and_pay_for_transaction(ref self: TContractState, transaction_hash: felt252, max_fee: u256) -> bool;
    fn estimate_transaction_fee(self: @TContractState, transaction_type: felt252) -> u256;
    fn is_transaction_sponsored(self: @TContractState, user_address: ContractAddress, transaction_type: felt252) -> bool;
    fn get_sponsorship_balance(self: @TContractState, user_address: ContractAddress) -> u256;

    // Administrative Functions
    fn set_admin(ref self: TContractState, new_admin: ContractAddress);
    fn add_authorized_agent(ref self: TContractState, agent_address: ContractAddress);
    fn mint_tokens(ref self: TContractState, to: ContractAddress, amount: u256) -> bool;

    // View Functions
    fn get_total_policies(self: @TContractState) -> u256;
    fn get_total_claims(self: @TContractState) -> u256;
    fn is_authorized_agent(self: @TContractState, agent_address: ContractAddress) -> bool;
}

#[starknet::contract]
pub mod MyInsurFiToken {
    use super::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};
    use super::{InsurancePolicy, Claim};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, Map};

    const ZERO_ADDRESS: felt252 = 0;

    #[storage]
    struct Storage {
        // ERC20 Storage
        name: ByteArray,
        symbol: ByteArray,
        decimals: u8,
        total_supply: u256,
        balances: Map<ContractAddress, u256>,
        allowances: Map<(ContractAddress, ContractAddress), u256>,

        // Contract Management
        owner: ContractAddress,
        admin: ContractAddress,
        paused: bool,
        authorized_agents: Map<ContractAddress, bool>,

        // Insurance Storage
        policies: Map<u256, InsurancePolicy>,
        policy_counter: u256,

        // Claims Storage
        claims: Map<u256, Claim>,
        claim_counter: u256,

        // Paymaster Storage
        sponsorship_balances: Map<ContractAddress, u256>,
        transaction_fees: Map<felt252, u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
        Approval: Approval,
        PolicyCreated: PolicyCreated,
        PremiumPaid: PremiumPaid,
        ClaimSubmitted: ClaimSubmitted,
        ClaimApproved: ClaimApproved,
        TransactionSponsored: TransactionSponsored,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Transfer {
        pub from: ContractAddress,
        pub to: ContractAddress,
        pub value: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Approval {
        pub owner: ContractAddress,
        pub spender: ContractAddress,
        pub value: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct PolicyCreated {
        pub policy_id: u256,
        pub user: ContractAddress,
        pub insurance_type: u8,
        pub coverage_amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct PremiumPaid {
        pub policy_id: u256,
        pub user: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ClaimSubmitted {
        pub claim_id: u256,
        pub policy_id: u256,
        pub user: ContractAddress,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ClaimApproved {
        pub claim_id: u256,
        pub amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct TransactionSponsored {
        pub user: ContractAddress,
        pub transaction_hash: felt252,
        pub fee_amount: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        // Initialize ERC20 token
        self.name.write("MY Insurance Token");
        self.symbol.write("MYSU");
        self.decimals.write(18);
        self.total_supply.write(40_000_000_000_000_000_000_000_000); // 40 million with 18 decimals

        // Set owner and admin
        self.owner.write(owner);
        self.admin.write(owner);
        self.paused.write(false);

        // Initialize counters
        self.policy_counter.write(0);
        self.claim_counter.write(0);

        // Set initial transaction fees for paymaster
        self.transaction_fees.write('policy_creation', 50_000_000_000_000_000); // 0.05 token
        self.transaction_fees.write('premium_payment', 10_000_000_000_000_000); // 0.01 token
        self.transaction_fees.write('claim_submission', 30_000_000_000_000_000); // 0.03 token

        // Mint initial supply to owner
        self.balances.write(owner, 40_000_000_000_000_000_000_000_000);

        // Emit initial transfer event
        self.emit(Transfer { 
            from: starknet::contract_address_try_from_felt252(ZERO_ADDRESS).unwrap(), 
            to: owner, 
            value: 40_000_000_000_000_000_000_000_000 
        });
    }

    #[abi(embed_v0)]
    impl MyInsurFiImpl of super::IMyInsurFiToken<ContractState> {
        // ERC20 Implementation
        fn name(self: @ContractState) -> ByteArray {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> ByteArray {
            self.symbol.read()
        }

        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self.allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            self._transfer(caller, to, amount);
            true
        }

        fn transfer_from(ref self: ContractState, from: ContractAddress, to: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            let current_allowance = self.allowances.read((from, caller));
            assert(current_allowance >= amount, 'Insufficient allowance');
            
            self.allowances.write((from, caller), current_allowance - amount);
            self._transfer(from, to, amount);
            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            self.allowances.write((caller, spender), amount);
            self.emit(Approval { owner: caller, spender, value: amount });
            true
        }

        // Insurance Policy Functions
        fn create_health_policy(ref self: ContractState, coverage_amount: u256, premium_amount: u256, duration: u64) -> u256 {
            assert(!self.paused.read(), 'Contract is paused');
            self._create_policy(0, coverage_amount, premium_amount, duration, 0) // 0 = Health
        }

        fn create_travel_policy(ref self: ContractState, destination: felt252, coverage_amount: u256, premium_amount: u256, duration: u64) -> u256 {
            assert(!self.paused.read(), 'Contract is paused');
            self._create_policy(1, coverage_amount, premium_amount, duration, destination) // 1 = Travel
        }

        fn create_schengen_policy(ref self: ContractState, coverage_amount: u256, premium_amount: u256, duration: u64) -> u256 {
            assert(!self.paused.read(), 'Contract is paused');
            self._create_policy(2, coverage_amount, premium_amount, duration, 0) // 2 = Schengen
        }

        fn create_house_policy(ref self: ContractState, property_value: felt252, coverage_amount: u256, premium_amount: u256, duration: u64) -> u256 {
            assert(!self.paused.read(), 'Contract is paused');
            self._create_policy(3, coverage_amount, premium_amount, duration, property_value) // 3 = House
        }

        fn pay_premium(ref self: ContractState, policy_id: u256) -> bool {
            assert(!self.paused.read(), 'Contract is paused');
            let caller = get_caller_address();
            let policy = self.policies.read(policy_id);
            
            assert(policy.policy_holder == caller, 'Not policy holder');
            assert(policy.is_active, 'Policy not active');
            assert(get_block_timestamp() <= policy.end_date, 'Policy expired');

            // Transfer premium from user to contract
            self._transfer(caller, get_contract_address(), policy.premium_amount);

            self.emit(PremiumPaid { policy_id, user: caller, amount: policy.premium_amount });
            true
        }

        fn get_policy_details(self: @ContractState, policy_id: u256) -> InsurancePolicy {
            self.policies.read(policy_id)
        }

        fn cancel_policy(ref self: ContractState, policy_id: u256) -> bool {
            let caller = get_caller_address();
            let mut policy = self.policies.read(policy_id);
            
            assert(policy.policy_holder == caller, 'Not policy holder');
            assert(policy.is_active, 'Policy already inactive');

            policy.is_active = false;
            self.policies.write(policy_id, policy);
            true
        }

        // Claims Functions
        fn submit_claim(ref self: ContractState, policy_id: u256, claim_amount: u256, evidence_hash: felt252) -> u256 {
            assert(!self.paused.read(), 'Contract is paused');
            let caller = get_caller_address();
            let policy = self.policies.read(policy_id);
            
            assert(policy.policy_holder == caller, 'Not policy holder');
            assert(policy.is_active, 'Policy not active');
            assert(claim_amount <= policy.coverage_amount, 'Claim exceeds coverage');

            let claim_id = self.claim_counter.read() + 1;
            self.claim_counter.write(claim_id);

            let claim = Claim {
                id: claim_id,
                policy_id,
                claimant: caller,
                claim_amount,
                evidence_hash,
                status: 0, // 0 = Pending
                submission_date: get_block_timestamp(),
                processing_date: 0,
            };

            self.claims.write(claim_id, claim);

            self.emit(ClaimSubmitted { claim_id, policy_id, user: caller, amount: claim_amount });
            claim_id
        }

        fn approve_claim(ref self: ContractState, claim_id: u256) -> bool {
            let caller = get_caller_address();
            let admin = self.admin.read();
            assert(caller == admin, 'Only admin allowed');
            
            let mut claim = self.claims.read(claim_id);
            assert(claim.status == 0, 'Claim not pending'); // 0 = Pending
            
            claim.status = 1; // 1 = Approved
            claim.processing_date = get_block_timestamp();
            self.claims.write(claim_id, claim);

            self.emit(ClaimApproved { claim_id, amount: claim.claim_amount });
            true
        }

        fn reject_claim(ref self: ContractState, claim_id: u256, reason: felt252) -> bool {
            let caller = get_caller_address();
            let admin = self.admin.read();
            assert(caller == admin, 'Only admin allowed');
            
            let mut claim = self.claims.read(claim_id);
            assert(claim.status == 0, 'Claim not pending'); // 0 = Pending
            
            claim.status = 2; // 2 = Rejected
            claim.processing_date = get_block_timestamp();
            self.claims.write(claim_id, claim);

            true
        }

        fn process_claim_payment(ref self: ContractState, claim_id: u256) -> bool {
            let caller = get_caller_address();
            let admin = self.admin.read();
            assert(caller == admin, 'Only admin allowed');
            
            let mut claim = self.claims.read(claim_id);
            assert(claim.status == 1, 'Claim not approved'); // 1 = Approved
            
            // Transfer claim amount to claimant
            self._transfer(get_contract_address(), claim.claimant, claim.claim_amount);
            
            claim.status = 3; // 3 = Paid
            self.claims.write(claim_id, claim);
            
            true
        }

        fn get_claim_details(self: @ContractState, claim_id: u256) -> Claim {
            self.claims.read(claim_id)
        }

        // Paymaster Functions
        fn validate_and_pay_for_transaction(ref self: ContractState, transaction_hash: felt252, max_fee: u256) -> bool {
            let caller = get_caller_address();
            let sponsorship_balance = self.sponsorship_balances.read(caller);
            
            assert(sponsorship_balance >= max_fee, 'Insufficient balance');
            
            self.sponsorship_balances.write(caller, sponsorship_balance - max_fee);
            
            self.emit(TransactionSponsored { user: caller, transaction_hash, fee_amount: max_fee });
            true
        }

        fn estimate_transaction_fee(self: @ContractState, transaction_type: felt252) -> u256 {
            self.transaction_fees.read(transaction_type)
        }

        fn is_transaction_sponsored(self: @ContractState, user_address: ContractAddress, transaction_type: felt252) -> bool {
            let balance = self.sponsorship_balances.read(user_address);
            let fee = self.transaction_fees.read(transaction_type);
            balance >= fee
        }

        fn get_sponsorship_balance(self: @ContractState, user_address: ContractAddress) -> u256 {
            self.sponsorship_balances.read(user_address)
        }

        // Administrative Functions
        fn set_admin(ref self: ContractState, new_admin: ContractAddress) {
            let caller = get_caller_address();
            let admin = self.admin.read();
            assert(caller == admin, 'Only admin allowed');
            self.admin.write(new_admin);
        }

        fn add_authorized_agent(ref self: ContractState, agent_address: ContractAddress) {
            let caller = get_caller_address();
            let admin = self.admin.read();
            assert(caller == admin, 'Only admin allowed');
            self.authorized_agents.write(agent_address, true);
        }

        fn mint_tokens(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            let admin = self.admin.read();
            assert(caller == admin, 'Only admin allowed');
            
            let current_supply = self.total_supply.read();
            let new_supply = current_supply + amount;
            
            self.total_supply.write(new_supply);
            let current_balance = self.balances.read(to);
            self.balances.write(to, current_balance + amount);
            
            self.emit(Transfer { 
                from: starknet::contract_address_try_from_felt252(ZERO_ADDRESS).unwrap(), 
                to, 
                value: amount 
            });
            true
        }

        // View Functions
        fn get_total_policies(self: @ContractState) -> u256 {
            self.policy_counter.read()
        }

        fn get_total_claims(self: @ContractState) -> u256 {
            self.claim_counter.read()
        }

        fn is_authorized_agent(self: @ContractState, agent_address: ContractAddress) -> bool {
            self.authorized_agents.read(agent_address)
        }
    }

    // Internal Functions
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _transfer(ref self: ContractState, from: ContractAddress, to: ContractAddress, amount: u256) {
            let from_balance = self.balances.read(from);
            assert(from_balance >= amount, 'Insufficient balance');
            
            self.balances.write(from, from_balance - amount);
            let to_balance = self.balances.read(to);
            self.balances.write(to, to_balance + amount);
            
            self.emit(Transfer { from, to, value: amount });
        }

        fn _create_policy(ref self: ContractState, insurance_type: u8, coverage_amount: u256, premium_amount: u256, duration: u64, metadata: felt252) -> u256 {
            let caller = get_caller_address();
            let policy_id = self.policy_counter.read() + 1;
            self.policy_counter.write(policy_id);

            let start_date = get_block_timestamp();
            let end_date = start_date + duration;

            let policy = InsurancePolicy {
                id: policy_id,
                policy_holder: caller,
                insurance_type,
                coverage_amount,
                premium_amount,
                start_date,
                end_date,
                is_active: true,
                metadata,
            };

            self.policies.write(policy_id, policy);

            self.emit(PolicyCreated { policy_id, user: caller, insurance_type, coverage_amount });
            policy_id
        }
    }
}