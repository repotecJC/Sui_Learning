module sui_learning::price_oracle{
    
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
}