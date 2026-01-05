module sui_learning::multi_oracle_registry{

    // Common models
    use std::string;
    
    // Sui models
    use sui::dynamic_object_field as dof;

    // sui_learning models
    use sui_learning::price_oracle as po;

    // Struct
    public struct OracleRegistry has key{
        id: UID,
    }

    // Public functions
    /// Create an OracleRegistry
    public fun create_registry has key, store(
        ctx: &mut TxContext,
    ): OracleRegistry{
        let registry = OracleRegistry{
            id = object::new(ctx)
        };
        transfer::share_object(regustry);
    }

    /// Combine the base and quote like base: BTC, quote: USDT
    public fun make_pair_key(
        base: vector<u8>,
        quote: vector<u8>,
    ): vector<u8>
    {
        let mut key = vector::empty<u8>();
        vector::append(&mut key, base); // append is for vector
        vector::push_back(&mut key, 47); // ASCII code for '/', push_back is for an element like in this case is "u8"
        vector::append(&mut key, quote);
        key
    }
    /// Register the oracle under OracleRegistry
    public fun register_oracle(
        registry: &mut OracleRegistry,
        base: vector<u8>,
        quote: vector<u8>,
        initial_price: u64,
        decimals: u8,
        admin_limit: u64,
        ctx: &mut TxContext,
    )
    {
        let pair_key = make_pair_key(base, quote);
        let pair_string = string::utf8(copy pair_key);
        let (oracle, super_admin_cap, admin_cap) = po::new_oracle(
            pair_string,
            initial_price,
            decimals,
            admin_limit,
            ctx,
        );

        dof::add(&mut registry.id, pair_key, oracle);
        
        // Transfer the admin cap to the sender
        transfer::public_transfer(super_admin_cap, tx_context::sender(ctx));
        transfer::public_transfer(admin_cap, tx_context::sender(ctx));
    }
}