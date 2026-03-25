module sui_learning::staking_pool;

// ---------- Imports ----------
use sui_learning::oracle_coin::ORACLE_COIN;
use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::event;
use onchain_invoice::invoice;
// Dof and df
// use sui::dynamic_object_field as dof; // with ID
use sui::dynamic_field as df; // without ID
// ---------- Constants ----------
const REWARD_PRECISION: u64 = 1_000_000_000;
// ---------- Error Codes ----------
const EInvalidRewardRate: u64 = 1;
const EInvalidStakeAmount: u64 = 2;
const EInvalidWithdrawAmount: u64 = 3;
const ENoStakeFound: u64 = 4;
const EAdminsOverLimit: u64 = 5;


// ---------- Structs ----------
// Core structs
public struct StakingPool has key{
    id: UID,
    total_staked: u64, // Total staked amount in the pool
    reward_per_token_stored: u64, // Accumulated reward per token in the pool (scaled by 1e9 for precision)
    last_update_epoch: u64, // epoch timestamp
    reward_rate: u64, // reward per second
    stake_balance: Balance<ORACLE_COIN>, // Total staked balance in the pool
    reward_balance: Balance<ORACLE_COIN>, // Total reward balance in the pool
    admin_minted: u64,
    admin_limit: u64,
}
public struct StakeRecord has store {
    amount: u64,    // Amount staked by the user
    reward_per_token_paid: u64, // Reward per token value at the time of user's last stake/withdraw
    rewards: u64, // Rewards earned but not yet claimed
    stake_timestamp: u64, // epoch timestamp of the last stake action
}

// Administration structs
public struct PoolAdminCap has key, store {
    id: UID,
}

// Events
public struct StakeEvent has copy, drop {
    user: address,
    amount: u64,
    timestamp: u64,
}
public struct WithdrawEvent has copy, drop {
    user: address,
    amount: u64,
    timestamp: u64,
}
public struct ClaimRewardEvent has copy, drop {
    user: address,
    amount: u64,
    timestamp: u64,
}

// ============================================================================================================
// Staking Pool Core Functions (For users)
// - Create
// - Stake, Withdraw, Claim Reward
// ============================================================================================================
public fun create_pool(
    reward_rate: u64,
    admin_limit: u64,
    ctx: &mut TxContext
): PoolAdminCap {
    // reward_rate is the amount of rewards distributed per second to the stakers, so it should not be too high (otherwise the pool will run out of rewards soon) or too low (otherwise the reward will be too small to attract stakers)
    assert!(reward_rate > 0 && reward_rate <= 10_000, EInvalidRewardRate);
    // Create the pool
    let pool = StakingPool {
        id: object::new(ctx),
        total_staked: 0,
        reward_per_token_stored: 0,
        last_update_epoch: tx_context::epoch(ctx),
        reward_rate,
        stake_balance: balance::zero(),
        reward_balance: balance::zero(),
        admin_minted: 1, // Founder has 1
        admin_limit,
    };
    // Create the admin cap for the pool
    let admin_cap = PoolAdminCap {
        id: object::new(ctx),
    };
    // Share the pool and transfer the admin cap to the creator
    transfer::share_object(pool);
    admin_cap
}

public fun stake(
    pool: &mut StakingPool,
    stake_coin: Coin<ORACLE_COIN>,
    ctx: &mut TxContext
) {
    let amount = coin::value(&stake_coin);
    assert!(amount > 0, EInvalidStakeAmount);
    
    // Update pool rewards before changing the stake amount
    update_rewards(pool, ctx);
    
    // Check if user already has a stake record, if not create one
    let user = tx_context::sender(ctx);
    let current_epoch = tx_context::epoch(ctx);

    // If user stake for the first time, create a new stake record for the user with amount 0 and reward_per_token_paid as current reward_per_token_stored
    if (!df::exists_(&pool.id, user)) {
        let record = StakeRecord {
            amount,
            reward_per_token_paid: pool.reward_per_token_stored,
            rewards: 0,
            stake_timestamp: current_epoch,
        };
        // Create a new stake record for the user
        df::add(&mut pool.id, user, record); // df::add(object_id, key, value) to create a new stake record for the user (DF) under StakingPool
    } else {
    
        // 1. Get reward_per_token_stored from the pool
        let rpt = pool.reward_per_token_stored;
        // 2. Get the user's stake record
        let record = df::borrow_mut<address, StakeRecord>(&mut pool.id, user); // df::borrow_mut<KeyType, ValueType>(&mut object_id, key) to get user address's StakeRecord(DF) under StakingPool
        // 3.1 Count current rewards (rewards per token in the pool - record.rewards per token user already gained)
        // 3.2 Count how much rewards user earned from last time (reward_delta * user stake amount)
        // 3.3 Update the user's stake record
        record.rewards = earned(record, rpt); // Update the user's rewards before changing the stake amount
        record.amount = record.amount + amount; // Update the user's stake amount
        record.reward_per_token_paid = pool.reward_per_token_stored; // Update the user's reward_per_token_paid to the current reward_per_token_stored
        record.stake_timestamp = current_epoch; // Update the user's stake timestamp to the current epoch time   
    };

    // Update the pool's total staked amount
    pool.total_staked = pool.total_staked + amount;
    // Transfer the staked coins to the pool (join the coin to the pool's reward balance)
    let stake_balance = coin::into_balance(stake_coin);
    balance::join(&mut pool.stake_balance, stake_balance);

    // Emit a stake event
    event::emit(StakeEvent {
        user,
        amount,
        timestamp: current_epoch,
    });
}

public fun withdraw(
    pool: &mut StakingPool,
    amount: u64,
    ctx: &mut TxContext
) {
    let user = tx_context::sender(ctx);
    let current_epoch = tx_context::epoch(ctx);

    // Validation
    assert!(amount > 0, EInvalidWithdrawAmount);
    assert!(df::exists_(&pool.id, tx_context::sender(ctx)), ENoStakeFound);

    // Update pool rewards before changing the stake amount
    update_rewards(pool, ctx);

    // Get the user's stake record and reward per token stored in the pool
    let record = df::borrow_mut<address, StakeRecord>(&mut pool.id, user);
    let rpt = pool.reward_per_token_stored;

    // Check if user has enough stake to withdraw
    assert!(record.amount >= amount, EInvalidWithdrawAmount);

    
    
}

public fun claim_reward(
    pool: &mut StakingPool,
    ctx: &mut TxContext
) {
    
}
// ============================================================================================================
// Staking Pool Core Functions (Administration)
// - fund_reward
// - add_admin
// ============================================================================================================
public fun fund_reward(
    _admin_cap: &PoolAdminCap,
    pool: &mut StakingPool,
    reward_coin: Coin<ORACLE_COIN>,
    _ctx: &mut TxContext
) {
    let reward_amount = coin::value(&reward_coin);
    assert!(reward_amount > 0, EInvalidStakeAmount);

    let reward_balance = coin::into_balance(reward_coin);
    // Update the pool's reward balance
    balance::join(&mut pool.reward_balance, reward_balance);
}

public fun add_admin(
    _admin_cap: &PoolAdminCap,
    pool: &mut StakingPool,
    receiver: address,
    ctx: &mut TxContext,
) {
    assert!(pool.admin_minted < pool.admin_limit, EAdminsOverLimit);
    // If not over limit
    pool.admin_minted = pool.admin_minted + 1;
    let new_admin_cap = PoolAdminCap { id: object::new(ctx) };
    transfer::public_transfer(new_admin_cap, receiver);
}

// ============================================================================================================
// Helper functions
// - update_rewards (count how much rewards in the pool from last time)
// - earned (count how much rewards each user earned)
// ============================================================================================================
// 2 things update_rewards do
// 1. Count how much rewards occured from last time update (total_new_rewards = reward_rate × epochs_passed)
// 2. Spread these rewards evenly to total_staked, count how much rewards each token get (reward_per_token_delta = total_new_rewards × REWARD_PRECISION / total_staked)
fun update_rewards(
    pool: &mut StakingPool,
    ctx: &TxContext
) {
    let current_epoch = tx_context::epoch(ctx);
    // only update epoch if there is no one stakeing
    if (pool.total_staked == 0) {
        pool.last_update_epoch = current_epoch;
        return
    };
    
    // count rewards
    let epochs_passed = current_epoch - pool.last_update_epoch;
    if (epochs_passed > 0) {
        // total rewards
        let total_new_rewards = pool.reward_rate * epochs_passed;
        // reward per token (variation)
        let reward_per_token_delta = (total_new_rewards * REWARD_PRECISION) / pool.total_staked;
        // The reason why times the REWARD_PRECISION is to prevent to lost decimal of the reward
        // e.g. total_new_rewards = 3, total_staked = 100, reward_per_token_delta should be 0.03, but if only use 3/100 then the reward will be gone.

        // Update the pool's reward per token and last update epoch
        pool.reward_per_token_stored = pool.reward_per_token_stored + reward_per_token_delta;
        pool.last_update_epoch = current_epoch;
    };
}

fun earned(record: &StakeRecord, rpt: u64): u64 {
    let reward_delta = rpt - record.reward_per_token_paid;
    (record.amount * reward_delta) / REWARD_PRECISION + record.rewards
}

// ============================================================================================================
// Read-Only functions
// - get_stake_amount
// - get_pending_rewards
// - get_total_staked
// ============================================================================================================

// ===================================================
// NOTE: How to get user stake record: DF (Dynamic Field)
// - StakeRecord is stored under StakingPool as DF, with user address as key
// - So you have to &StakingPool first, then use DF to get user address's StakeRecord
// - &StakingPool -> df::borrow<KeyType, ValueType>(object_id, key) -> &StakeRecord -> get amount, reward, etc
// ===================================================
// Get how much user staked in the pool
public fun get_stake_amount(
    pool: &StakingPool,
    user: address
): u64 {
    if(!df::exists_(&pool.id, user)) {
        return 0;
    };
    let record = df::borrow<address, StakeRecord>(&pool.id, user); // df::borrow<KeyType, ValueType>(object_id, key) to get user address's StakeRecord(DF) under StakingPool
    record.amount
}
// Get how much rewards user can claim in the pool
public fun get_pending_rewards(
    pool: &StakingPool,
    user: address
): u64 {
    if(!df::exists_(&pool.id, user)) {
        return 0;
    };

    let rpt = pool.reward_per_token_stored;
    let record = df::borrow<address, StakeRecord>(&pool.id, user);

    earned(record, rpt)
}
// Get how much total staked in the pool
public fun get_total_staked(
    pool: &StakingPool
): u64 {
    pool.total_staked
}