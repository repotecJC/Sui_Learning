module sui_learning::oracle_coin;

use sui::coin::{Self, TreasuryCap};

// ---------- Struct ----------
/// OTW
public struct ORACLE_COIN has drop{}

// ---------- function ----------
fun init(witness: ORACLE_COIN, ctx: &mut TxContext) {
    // create coin
    let (treasury_cap, metadata) =
    coin::create_currency(
        witness,
        9,
        b"OC",
        b"Oracle Coin",
        b"Coin for Oracle Registry Payment",
        option::none(),
        ctx
    );
    
    // Freeze the metadata (Turn it to immutable shared object)
    transfer::public_freeze_object(metadata);

    // Transfer the treasury cap to caller
    transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
}