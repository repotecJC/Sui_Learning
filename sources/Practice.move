module sources::Practice;


use std::vector;
use std::string;
use std::option;
use std::integer;
use std::random;


struct Hero has key, store{
    id: UID,
    name: string::String,
    hp: u8,
    sword: Option<UID>,
    backpack: vector<Item>,
}


struct Sword has key, store {
    id: UID,
    durability: u8,
    damage: u8,
}


struct Item has store, drop {
    name: string::String,
    function: string::String,
    price: u8,
}


fun new_hero(name: String, ctx: &mut TxContext): Hero {
    let id = object::new(ctx);
    let hp = 100;
    let sword = option::none<UID>();
    let backpack = vector::empty<Item>();

    Hero{
        id,
        hp,
        sword,
        backpack
    }
}


fun new_sword(name: string::String, ctx: &mut TxContext): Sword {
    let id = object::new(ctx)
    let durability = random::generate_u8_in_range(g:&mut sui::random::RandomGenerator, min:50, max:500),
    let damage = random::generate_u8_in_range(g:&mut sui::random::RandomGenerator, min:1, max:1000),
}


fun equip_sword(hero: Hero, sword: Sword){
    
}
