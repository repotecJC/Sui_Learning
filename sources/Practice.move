module learning_project::Practice;

use sui::coin::{Self, Coin};
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};

struct CoinStore has key {
    id: UID,
    coin: Coin<SUI>
    // coin: Coin<SUI>
}