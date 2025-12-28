// Purpose: Allow everyone can see the price, but only admin can update it

module sui_learning::price_oracle{

    // Common models
    use std::string::String;

    // Sui models
    use sui::event;
    
    // Struct
    /// AdminCap
    public struct AdminCap has key, store{
        id: UID,
    }
    /// Oracle
    public struct Oracle has key{
        id: UID,
        pair: String, // ex. BTC/USDT
        price: u64,
        decimals: u8,
        last_updated: u64, // epoch timesta
    }
    /// Price update event
    public struct PriceUpdateEvent has copy, drop{
        pair: String,
        old_price: u64,
        new_price: u64,
        timestamp: u64,
    }

    // Initialise Oracle
    /// Public function to create oracle (If there is no return value, it can be a entry function)
    public fun create_oracle(
        pair: String,
        initial_price: u64,
        decimals: u8,
        ctx: &mut TxContext,
    )
    {   
        // Struct instances
        let admin_cap = AdminCap{
            id: object::new(ctx)
        };

        // Transfer the admin cap to the sender
        transfer::public_transfer(admin_cap, tx_context::sender(ctx));
        
        // Create the oracle (Struct instance)
        let oracle = Oracle {
            id: object::new(ctx),
            pair,
            price: initial_price,
            decimals,
            last_updated: tx_context::epoch(ctx), // Get the current epoch time
        };

        transfer::share_object(oracle);
    }
    /// Public function to update the price
    public fun update_price(
        _admin: &AdminCap, // Validate the admin cap, the logic is if you need to borrow one, you have to have one (The underline before admin is to avoid unused warning cos this is just for the validation.)
        oracle: &mut Oracle,
        new_price: u64,
        ctx: &mut TxContext,
    )
    {   // Record the old price
        let old_price = oracle.price;

        // Update the price
        oracle.price = new_price;

        // Update the last updated time  
        oracle.last_updated = tx_context::epoch(ctx);

        // Emit the event
        event::emit(PriceUpdateEvent{
            pair: oracle.pair,
            old_price,
            new_price,
            timestamp: oracle.last_updated,
        });
    }
    /// Public function 
    /// 
}