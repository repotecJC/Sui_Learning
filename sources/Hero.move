module sui_learning::hero{

    // Common models
    use std::vector;
    use std::string::String;
    use std::option::{Self, Option};

    // Sui models
    use sui::random::{Self, Random};
    // Implicitly imported(import by default) but write it down to remind myself
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext}; // Transaction context, all kind of the information about the transaction
    use sui::transfer;

    // Errors
    const EAlreadyHasSword:u64 = 0;
    const ENoSword:u64 = 1;

    // Struct   
    public struct Hero has key, store{
        id: UID,
        name: String,
        hp: u64,
        sword: Option<Sword>,
        backpack: vector<String>,
    }
    public struct Sword has key, store {
        id: UID,
        name: String,
        durability: u64,
        damage: u64,
    }

    // Functions
    public fun new_hero(name: String, ctx: &mut TxContext): Hero {
        let id = object::new(ctx);
        let hp = 100;
        let sword = option::none<Sword>();
        let backpack = vector::empty<String>();

        Hero{
            id,
            name,
            hp,
            sword,
            backpack
        }
    }

    public fun new_sword(name: String, ctx: &mut TxContext): Sword {
        let id = object::new(ctx);
        let durability = 100;
        let damage = 100;
        
        Sword {
            id,
            name,
            durability,
            damage,
        }
    }

    // Entry functions
    public entry fun create_hero(name: String, ctx: &mut TxContext){
        let hero = new_hero(name, ctx);
        transfer::public_transfer(hero, tx_context::sender(ctx));
    }

    public entry fun create_sword(name: String, ctx: &mut TxContext){
        let sword = new_sword(name, ctx);
        transfer::public_transfer(sword, tx_context::sender(ctx));
    }

    public entry fun equip_sword(hero: &mut Hero, sword: Sword){
        // Check if the hero already has a sword
        assert! (option::is_none(&hero.sword), EAlreadyHasSword); // assert is for quick precondition check
        option::fill(&mut hero.sword, sword);
    }

    public entry fun uneqip_sword(hero: &mut Hero, ctx: &mut TxContext){
        // Check if the hero not has a sword
        assert! (option::is_some(&hero.sword), ENoSword);
        let extracted_sword = option::extract(&mut hero.sword);
        transfer::public_transfer(extracted_sword, tx_context::sender(ctx))
    }
}