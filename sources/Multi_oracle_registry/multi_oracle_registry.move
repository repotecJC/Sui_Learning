module sui_learning::multi_oracle_registry;

use std::string;
use sui::dynamic_object_field as dof;
use sui_learning::price_oracle as po;
use sui::event;

// Error code
const EPairExists: u64 = 1; // for register_oracle
const EPairNotFound: u64 = 2; // for get_oracle and get_oracle_mut

// Struct
public struct OracleRegistry has key, store {
    id: UID,
    name: string::String,
}

/// Event struct
public struct OracleRegisteredEvent has copy, drop, store {
    registry_id: ID,
    oracle_id: ID,
    pair: vector<u8>,
    timestamp: u64,
}
public struct OracleRemovedEvent has copy, drop, store {
    registry_id: ID,
    oracle_id: ID,
    pair: vector<u8>,
    timestamp: u64,
}

// Create Registry and put the oracle on it
/// Create the OracleRegistry
public fun create_registry(name: string::String, ctx: &mut TxContext) {
    let registry = OracleRegistry {
        name,
        id: object::new(ctx),
    };
    transfer::share_object(registry);
}

/// Combine the base and quote like base: BTC, quote: USDT
public fun make_pair_key(base: vector<u8>, quote: vector<u8>): vector<u8> {
    let mut key = vector::empty<u8>();
    vector::append(&mut key, base); // append is for vector
    vector::push_back(&mut key, 47); // ASCII code for '/', push_back is for an element like in this case is "u8"
    vector::append(&mut key, quote);
    key
}

/// Create a new oracle and register it to the OracleRegistry
public fun register_oracle(
    registry: &mut OracleRegistry,
    base: vector<u8>,
    quote: vector<u8>,
    initial_price: u64,
    decimals: u8,
    admin_limit: u64,
    ctx: &mut TxContext,
) {
    // Pair key
    let pair_key = make_pair_key(base, quote);
    // Copy pair keys for different uses
    let pair_key_check = copy pair_key; // Existence check
    let pair_key_event = copy pair_key; // Event emission
    let pair_string = string::utf8(copy pair_key); // For oracle creation

    // Check if the pair already exists
    assert!(
        !dof::exists_<vector<u8>>(&registry.id, pair_key_check), EPairExists
    );
    // Create new oracle
    let (oracle, super_admin_cap, admin_cap) = po::new_oracle(
        pair_string,
        initial_price,
        decimals,
        admin_limit,
        ctx,
    );
    // Transfer the admin cap to the sender
    transfer::public_transfer(super_admin_cap, tx_context::sender(ctx));
    transfer::public_transfer(admin_cap, tx_context::sender(ctx));
    // Borrow ids for event
    let oracle_id = object::id(&oracle);
    let registry_id = object::id(registry); // registry is a reference, no need to use &

    // Insert the oracle into the registry
    dof::add(&mut registry.id, pair_key, oracle);

    // Emit the oracle registeredevent
    event::emit(OracleRegisteredEvent{
        registry_id,
        oracle_id,
        pair: pair_key_event,
        timestamp: tx_context::epoch(ctx),
    });
}
/// Remove an oracle from the registry
public fun remove_oracle(
    _super_admin_cap: &po::SuperAdminCap,
    registry: &mut OracleRegistry,
    base: vector<u8>,
    quote: vector<u8>,
    ctx: &mut TxContext,
) {
    let pair_key = make_pair_key(base, quote);

    // Check existence
    assert!(
        dof::exists_(vector<u8>)(&registry.id, pair_key), EPairNotFound
    );
    dof::remove<vector<u8>>(&mut registry.id, pair_key)

}

// Function for GET the information about oracle in the registry
/// Oracle (Not allow to use CLI to get an Oracle object)
public fun get_oracle(registry: &OracleRegistry, base: vector<u8>, quote: vector<u8>): &po::Oracle {
    let pair_key = make_pair_key(base, quote);
    assert!(
        dof::exists_<vector<u8>>(&registry.id, pair_key), EPairNotFound
    );

    dof::borrow<vector<u8>, po::Oracle>(&registry.id, pair_key)
    // <vector<u8>, po::Oracle> is to tell borrow that the type of key (get access to the target) is vector<u8> and value (the return value of target) is po::Oracle
    // Note: because borrow is a generic function so there are many types that can use borrow, tell it what type is using is neccessary
}

/// Price
public fun get_oracle_price(registry: &OracleRegistry, base: vector<u8>, quote: vector<u8>): u64 {
    let oracle = get_oracle(registry, base, quote);
    po::get_price(oracle)
}

// Function for UPDATE the information about oracle in the registry
/// Helper function
public fun get_oracle_mut(
    registry: &mut OracleRegistry,
    base: vector<u8>,
    quote: vector<u8>,
): &mut po::Oracle {
    let pair_key = make_pair_key(base, quote);
    assert!(
        dof::exists_<vector<u8>>(&registry.id, pair_key), EPairNotFound
    );
    dof::borrow_mut<vector<u8>, po::Oracle>(&mut registry.id, pair_key)
}

public fun update_oracle_price(
    registry: &mut OracleRegistry,
    admin_cap: &po::AdminCap,
    base: vector<u8>,
    quote: vector<u8>,
    new_price: u64,
    ctx: &mut TxContext,
) {
    let oracle = get_oracle_mut(registry, base, quote);
    po::update_price(
        admin_cap,
        oracle,
        new_price,
        ctx,
    )
}
