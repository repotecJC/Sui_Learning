module sui_learning::oracle_coin;

// ---------- Common Import ----------
use sui::coin::{Self, TreasuryCap, Coin};

// ---------- Struct ----------
/// OTW
public struct ORACLE_COIN has drop{}

// ---------- Const ----------
const COIN_LIMITATION: u64 = 100_000_000_000;

/// Error Code
const ECoinOverLimit: u64 = 1;
const ECoinNotEnough: u64 = 2;


// ============================================================================================================
// Oracle Coin
// - Mint & Burn
// - 
// ============================================================================================================

// ---------- Create Coin ----------
fun init(witness: ORACLE_COIN, ctx: &mut TxContext) {
    // create coin
    let (treasury_cap, metadata) =
    coin::create_currency(
        witness,
        9, // 1 OC = 1000000000
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

public fun mint(
    cap: &mut TreasuryCap<ORACLE_COIN>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    assert!(coin::total_supply(cap) + amount <= COIN_LIMITATION, ECoinOverLimit);
    coin::mint_and_transfer(
        cap,
        amount,
        recipient,
        ctx
    );
}

public fun burn(
    cap: &mut TreasuryCap<ORACLE_COIN>,
    mut coin: Coin<ORACLE_COIN>,
    amount: u64,
    ctx: &mut TxContext,
) {
    assert!(coin::value(&coin) >= amount, ECoinNotEnough);
    // If it still has coin, return it to the caller
    if (coin::value(&coin) == amount) {
        coin::burn(cap, coin);
    } else{
        // Split the part that need to be burned
        let burn_coin = coin::split(&mut coin, amount, ctx);
        coin::burn(cap, burn_coin);
        transfer::public_transfer(coin, tx_context::sender(ctx));
    }
}