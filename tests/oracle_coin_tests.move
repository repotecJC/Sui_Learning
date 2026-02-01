#[test_only]
module sui_learning::oracl_coin_tests;

// ---------- Common Import ----------
use sui_learning::oracle_coin::{Self, ORACLE_COIN};
use sui::test_scenario::{Self as ts};
use sui::coin::{Self, TreasuryCap, Coin};

// ============================================================================================================
// Mint
// - Mint testing
// - Over limit testing
// ============================================================================================================

// ---------- Mint Testing ----------
#[test]
fun test_mint(){
    // Create admin and user for testing
    let admin = @0xAD;
    let user = @0x0;
    // Create test environment
    let mut scenario = ts::begin(admin);

    // 1st transaction, init
    {
        oracle_coin::init_for_testing(ts::ctx(&mut scenario))
    };
    // 2nd transaction, mint
    ts::next_tx(&mut scenario, admin);
    {
        let mut treasury = ts::take_from_sender<TreasuryCap<ORACLE_COIN>>(&scenario);
        oracle_coin::mint(
            &mut treasury,
            1_000_000_000, // 1 OC
            user,
            ts::ctx(&mut scenario)
        );
        ts::return_to_sender(&scenario, treasury);
    };
    // 3rd transaction, validate
    ts::next_tx(&mut scenario, user);
    {
        let coin = ts::take_from_sender<Coin<ORACLE_COIN>>(&scenario);
        assert!(coin::value(&coin) == 1_000_000_000, 0);
        ts::return_to_sender(&scenario, coin);
    };
    ts::end(scenario);
}

// ---------- Mint over limit Testing ----------
#[test]
#[expected_failure(abort_code = oracle_coin::ECoinOverLimit)]
fun test_mint_over_limit() {
    // Create admin and user for testing
    let admin = @0xAD;
    // Create test environment
    let mut scenario = ts::begin(admin);

    // 1st transaction, init
    {
        oracle_coin::init_for_testing(ts::ctx(&mut scenario))
    };
    // 2nd transaction, mint
    ts::next_tx(&mut scenario, admin);
    {
        let mut treasury = ts::take_from_sender<TreasuryCap<ORACLE_COIN>>(&scenario);
        oracle_coin::mint(
            &mut treasury,
            1_000_000_000_000, // 1000 OC
            admin,
            ts::ctx(&mut scenario)
        );
        ts::return_to_sender(&scenario, treasury);
    };
    ts::end(scenario);
}

// ============================================================================================================
// Burn
// - 
// - 
// ============================================================================================================

// ---------- Burn Testing ----------
#[test]
fun test_burn() {
    // Create admin and user for testing
    let admin = @0xAD;
    // Create test environment
    let mut scenario = ts::begin(admin);

    // 1st transaction, init
    {
        oracle_coin::init_for_testing(ts::ctx(&mut scenario))
    };
    // 2nd transaction, mint
    ts::next_tx(&mut scenario, admin);
    {
        let mut treasury = ts::take_from_sender<TreasuryCap<ORACLE_COIN>>(&scenario);
        oracle_coin::mint(
            &mut treasury,
            1_000_000_000, // 1 OC
            admin,
            ts::ctx(&mut scenario)
        );
        ts::return_to_sender(&scenario, treasury);
    };
    // 3rd transaction, burn
    ts::next_tx(&mut scenario, admin);
    {
        let mut treasury = ts::take_from_sender<TreasuryCap<ORACLE_COIN>>(&scenario);
        let coin = ts::take_from_sender<Coin<ORACLE_COIN>>(&scenario);
        oracle_coin::burn(
            &mut treasury,
            coin,
            100_000_000,
            ts::ctx(&mut scenario)
        );
        ts::return_to_sender(&scenario, treasury);
    };
    // 4th transaction, validate
    ts::next_tx(&mut scenario, admin);
    {
        let coin = ts::take_from_sender<Coin<ORACLE_COIN>>(&scenario);
        assert!(coin::value(&coin) == 900_000_000, 0);
        ts::return_to_sender(&scenario, coin);
    };
    ts::end(scenario);
}

// ---------- Burn but not enough to burn Testing ----------
#[test]
#[expected_failure(abort_code = oracle_coin::ECoinNotEnough)]
fun test_burn_not_enough() {
    let admin = @0xAD;
    let mut scenario = ts::begin(admin);

    // 1. init
    {
        oracle_coin::init_for_testing(ts::ctx(&mut scenario))
    };
    // 2. mint
    ts::next_tx(&mut scenario, admin);
    {
        let mut treasury = ts::take_from_sender<TreasuryCap<ORACLE_COIN>>(&scenario);
        oracle_coin::mint(
            &mut treasury,
            1_000_000_000,
            admin,
            ts::ctx(&mut scenario)
        );
        ts::return_to_sender(&scenario, treasury);
    };
    // 3. burn
    ts::next_tx(&mut scenario, admin);
    {
        let mut treasury = ts::take_from_sender<TreasuryCap<ORACLE_COIN>>(&scenario);
        let coin = ts::take_from_sender<Coin<ORACLE_COIN>>(&scenario);
        oracle_coin::burn(
            &mut treasury,
            coin,
            10_000_000_000,
            ts::ctx(&mut scenario)
        );
        ts::return_to_sender(&scenario, treasury);
    };
    ts::end(scenario);
}