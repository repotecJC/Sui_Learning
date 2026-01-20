module sui_learning::oracle_coin;

use sui::coin::{Self, TreasuryCap};

// ---------- Struct ----------
/// OTW
public struct ORACLE_COIN has drop{}

fun init(witness: ORACLE_COIN, ctx: &mut TxContext) {
    // create coin
    let (treasury_cap, metadata) =
    coin::create_currency(
        witness: witness,
        decimals: 9,
        symbol: b"OC",
        name: b"Oracle Coin",
        description: b"Coin for Oracle Registry Payment",
        icon_url: option::none(),
        ctx: ctx
    );
}