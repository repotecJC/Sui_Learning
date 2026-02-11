# Sui Move Learning Project 🚀

A comprehensive Sui Move practice project featuring **Price Oracle System**, **Oracle Registry with Payment**, and **Custom Coin Implementation**.

**Learning Focus**: Objects, Capabilities, Events, Shared Objects, Dynamic Object Fields, Price Staleness Checks, Hierarchical Permission Management, Multi-Oracle Registration with Fee System, One-Time Witness Pattern, Coin Standard, Balance Management, and Unit Testing.

[![Sui Testnet](https://img.shields.io/badge/Sui-Testnet-blue.svg)](https://suivision.xyz/testnet)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone [https://github.com/repotecJC/Sui_Learning.git](https://github.com/repotecJC/Sui_Learning.git)
cd Sui_Learning
```

### 2. Environment Setup

```bash
sui client active-env  # Confirm testnet
sui client faucet      # Request testnet SUI tokens
```

### 3. Build & Deploy

```bash
sui move build
sui move test                        # Run unit tests
sui client publish --gas-budget 100000000
```

## 📦 Deployed Packages

| Environment | Package ID | Machine | Explorer | Status |
| :--- | :--- | :--- | :--- | :--- |
| **testnet** | `0x42c67a54264a111fe2a865d9e34ead1855a12888a50303b6bf9a4007e2853f93` | Windows PC | [View](https://suivision.xyz/testnet/object/0x42c67a54264a111fe2a865d9e34ead1855a12888a50303b6bf9a4007e2853f93) | ✅ Active |
| **testnet** | `0x278e8056d479540c934ce4ded717b2cad166855fdb1aaca742742d7329dd1c72` | MacBook | [View](https://suivision.xyz/testnet/object/0x278e8056d479540c934ce4ded717b2cad166855fdb1aaca742742d7329dd1c72) | ✅ Active |

### Helper Commands

**Find Package ID on Mac/Linux:**
```bash
sui client objects | grep package
```

**Find Package ID on Windows:**
```powershell
sui client objects | Select-String "package"
```

## 🏗️ Project Architecture

```text
Sui_Learning/
├── sources/
│   ├── Price_Oracle/
│   │   └── price_oracle.move       # Single Oracle with tiered permissions
│   ├── Multi_oracle_registry/
│   │   └── multi_oracle_registry.move  # Registry with payment system
│   └── Coin/
│       └── oracle_coin.move        # Custom ERC20-like token (OC)
├── tests/
│   └── oracle_coin_tests.move      # Comprehensive unit tests
├── _archive/                        # Deprecated code
├── Move.toml                        # Package manifest
└── README.md
```

## Module Breakdown

### 1️⃣ Price Oracle (`price_oracle.move`)
A single price feed with hierarchical admin system.

**Key Structs:**
* `Oracle` (Shared Object): Stores price data
    * `price`: u64 - Current price
    * `pair`: String - Trading pair (e.g., "BTC/USDT")
    * `decimals`: u8 - Price precision
    * `last_updated`: u64 - Epoch timestamp
    * `admin_minted`: u64 - Current admin count
    * `admin_limit`: u64 - Maximum admins allowed
* `SuperAdminCap` (Owned Object): Root permission
* `AdminCap` (Owned Object): Price update permission

**Core Functions:**

| Function | Permission | Description |
| :--- | :--- | :--- |
| `create_oracle` | Anyone | Initialize Oracle with both admin caps |
| `add_admin` | SuperAdminCap | Mint new AdminCap (respects limit) |
| `increase_admin_limit` | SuperAdminCap | Raise admin cap ceiling |
| `update_price` | AdminCap | Update price + emit event |
| `get_price` | Read-only | Public price query |
| `is_fresh` | Read-only | Staleness check (防 manipulation) |

---

### 2️⃣ Oracle Registry (`multi_oracle_registry.move`)
Manages multiple oracles with paid registration system.

**Key Structs:**
* `OracleRegistry` (Shared Object):
    * `id`: UID - Registry identifier
    * `name`: String - Registry name
    * `treasury`: Balance<ORACLE_COIN> - Fee accumulator
* **Events:** `OracleRegisteredEvent`, `OracleRemovedEvent`

**Core Functions:**

| Function | Permission | Fee Required | Description |
| :--- | :--- | :--- | :--- |
| `create_registry` | Anyone | No | Initialize empty registry |
| `register_oracle` | Payment: 0.1 OC | Yes | Create Oracle under registry + charge fee |
| `remove_oracle` | SuperAdminCap | No | Delete Oracle from registry |
| `get_oracle_price` | Read-only | No | Query price by pair (e.g., BTC/USDT) |
| `update_oracle_price` | AdminCap | No | Update specific Oracle's price |
| `withdraw_fees` | SuperAdminCap | No | Withdraw accumulated fees |

**Technical Highlights:**
* Uses **Dynamic Object Fields** to store Oracles with pair keys.
* Payment handling: `Coin` → `Balance` conversion via `coin::into_balance`.
* Leftover payment automatically refunded to sender.

---

### 3️⃣ Oracle Coin (`oracle_coin.move`)
Custom fungible token following Sui Coin Standard.

**Key Features:**
* **Symbol:** OC (Oracle Coin)
* **Decimals:** 9 (like SUI)
* **Supply Cap:** 100,000,000,000 (100 billion)
* **One-Time Witness Pattern** for unique token creation

**Core Functions:**

| Function | Permission | Description |
| :--- | :--- | :--- |
| `init` | Auto (deploy-time) | Create coin + mint TreasuryCap |
| `mint` | TreasuryCap | Mint new tokens (respects supply cap) |
| `burn` | TreasuryCap | Burn tokens (partial or full) |

**Security Features:**
* `ECoinOverLimit`: Prevents minting beyond 100B supply.
* `ECoinNotEnough`: Validates burn amount.
* Automatic change return in burn function.

## 🧪 Testing

### Run Tests

```bash
# All tests
sui move test

# Specific test
sui move test test_mint_basic

# With coverage report
sui move test --coverage

# Gas profiling
sui move test --gas-report
```

### Test Coverage
Current tests in `tests/oracle_coin_tests.move`:

* ✅ `test_mint_basic`: Mint tokens to recipient
* ✅ `test_mint_over_limit`: Verify supply cap enforcement
* ✅ `test_burn_partial`: Burn portion of coins
* ✅ `test_burn_all`: Burn entire balance

**Testing Philosophy:**
* Uses `test_scenario` to simulate multi-transaction flows.
* Tests both success and failure cases (`expected_failure`).
* Validates object ownership transfers.
* Checks balance changes.

## 💻 Usage Examples

### 1. Query Oracle Price (CLI)

```bash
sui client call \
  --package $PACKAGE_ID \
  --module multi_oracle_registry \
  --function get_oracle_price \
  --args $REGISTRY_ID "0x42544300" "0x55534454"  # BTC, USDT in ASCII hex
```

### 2. Register New Oracle (with Payment)

```bash
# First mint some OC tokens
sui client call \
  --package $PACKAGE_ID \
  --module oracle_coin \
  --function mint \
  --args $TREASURY_CAP_ID 100000000 $YOUR_ADDRESS  # 0.1 OC

# Then register oracle (will consume 0.1 OC)
sui client call \
  --package $PACKAGE_ID \
  --module multi_oracle_registry \
  --function register_oracle \
  --args $REGISTRY_ID $COIN_OBJECT_ID "0x455448" "0x555344" 300000 8 5  # ETH/USD, $3000, 8 decimals, 5 admin limit
```

### 3. DeFi Integration Example (Move Code)

```move
public fun safe_swap(oracle: &Oracle, ctx: &TxContext) {
    // Prevent stale price manipulation
    assert!(price_oracle::is_fresh(oracle, 300, ctx), E_STALE_PRICE);
    
    let price = price_oracle::get_price(oracle);
    let decimals = price_oracle::get_decimals(oracle);
    
    // Calculate swap amount using fresh price
    // ... swap logic
}
```

## 🔑 Key Sui Move Concepts Demonstrated

### 1. Coin vs Balance
```move
// Coin: On-chain object with ID (like physical cash)
public struct Coin<T> has key, store {
    id: UID,
    balance: Balance<T>
}

// Balance: Pure value (like wallet amount)
public struct Balance<T> has store {
    value: u64
}
```
*Why separate? Contracts use `Balance` for efficient math; users transfer `Coin` objects.*

### 2. One-Time Witness (OTW)
```move
public struct ORACLE_COIN has drop {}  // Must match module name in UPPERCASE

fun init(witness: ORACLE_COIN, ctx: &mut TxContext) {
    // Only runs once at deployment
    coin::create_currency(witness, ...);
}
```
*Why? Guarantees token uniqueness - only one `ORACLE_COIN` type can ever exist.*

### 3. Dynamic Object Fields
```move
// Store Oracles using pair as key
dof::add(&mut registry.id, b"BTC/USDT", oracle);

let oracle = dof::borrow<vector<u8>, Oracle>(&registry.id, b"BTC/USDT");
```
*Why? Allows registry to store unlimited Oracles without pre-defining struct fields.*

### 4. Shared vs Owned Objects
* `Oracle`, `OracleRegistry`: **Shared** (many can read/write with locks)
* `AdminCap`, `TreasuryCap`: **Owned** (exclusive control)

## 🔄 Multi-Machine Workflow

**Sync Latest Code**
```bash
git pull origin main
```

**Independent Deployment**
Each machine gets a unique Package ID:
```bash
sui move build
sui client publish --gas-budget 100000000
# Copy Package ID from output
```

**Update Docs**
```bash
git add README.md
git commit -m "docs: add [Machine Name] package deployment"
git push
```

## 📚 Learning Resources

* [Sui Move Book](https://examples.sui.io/)
* [Sui Documentation](https://docs.sui.io/)
* [Suivision Explorer](https://suivision.xyz/)
* [Sui Move by Example](https://examples.sui.io/)
* [Coin Standard](https://docs.sui.io/standards/coin)

## 🔧 Development Commands

**Environment Check**
```bash
sui client active-env  # Should be "testnet"
sui client gas         # Check SUI balance
```

**Build & Test Cycle**
```bash
sui move build         # Compile
sui move test          # Run tests
sui client publish     # Deploy to chain
```

**Git Workflow**
```bash
git status
git add .
git commit -m "feat: describe changes"
git push origin main
```

## 🎯 Roadmap

- [x] Basic Oracle with admin system
- [x] Multi-Oracle Registry
- [x] Custom Coin (OC) implementation
- [x] Payment-gated registration
- [x] Unit tests for coin module
- [ ] Staking Pool for OC holders
- [ ] Frontend dApp (React + dApp Kit)
- [ ] AMM DEX implementation
- [ ] Security audit simulation

## 🤝 Contributing

Learning in public! Feel free to:
* Open issues for questions
* Submit PRs for improvements
* Fork for your own learning

## ⭐ Support This Project

If you're learning Sui Move or building on Sui, star this repo to show support!

---
*Last Updated: February 11, 2026*
*Author: RepotecJC*
*Status: Active Development 🚀*