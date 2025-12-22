module learning_project::Practice;

use sui::object::{self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use sui::vector;
use sui::string;
use sui::option;
use sui::integer;

struct Hero has key, store (Name: String){
    id: UID,
    name: Name,
    hp: u128,
    sword: Option<Sword>,
    backpack: vector<Item>,
}

struct sword has key, store, drop {
    id: UID,
    durability: u128,
    damage: u128,
}

struct item has store, drop {
    name: String,
    function: String,
    price: u128,
}

fun new_hero(name: String, ctx: &mut TxContext): Hero {}