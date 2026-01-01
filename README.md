# Sui Move Learning Project 🚀

A comprehensive Sui Move practice project, featuring the **Hero Example** + a custom **Price Oracle**.

**Learning Focus**: Objects, Capabilities, Events, Shared Objects, Price Freshness Checks, Multi-level Permission Management.

[![Sui Testnet](https://img.shields.io/badge/Sui-Testnet-blue.svg)](https://suivision.xyz/testnet)

## 🚀 Quick Start

1. **Clone the Repository**
git clone https://github.com/repotecJC/Sui_Learning.git
cd Sui_Learning
2. **Verify Testnet + Request SUI**
sui client active-env # Confirm testnet environment
sui client faucet # Request testnet SUI
3. **Build + Publish**
sui move build
sui client publish --gas-budget 100000000 # Note the Package ID displayed!

## 📦 Deployed Package IDs

| Environment | Package ID | Deployment Machine | Suivision Link | Status |
| :--- | :--- | :--- | :--- | :--- |
| **testnet** | `0x42c67a54264a111fe2a865d9e34ead1855a12888a50303b6bf9a4007e2853f93` | **Windows PC** | [View](https://suivision.xyz/testnet/object/0x42c67a54264a111fe2a865d9e34ead1855a12888a50303b6bf9a4007e2853f93) | ✅ Verified |
| **testnet** | `[PASTE_MACBOOK_PACKAGE_ID_HERE]` | **MacBook** | [View](https://suivision.xyz/testnet/object/[PASTE_MACBOOK_PACKAGE_ID_HERE]) | ⏳ Pending |

**How to find the MacBook Package ID**:

*   Mac/Linux:
 ```
 sui client objects | grep package
 ```
*   Windows:
 ```
 sui client objects | Select-String "package"
 ```

## 🏗️ Project Structure
sources/
├── hero.move # Official Sui Hero example
└── price_oracle.move # Custom Price Oracle (Tiered Permissions)
├── Oracle (Shared Object)
│ ├── price: u64 # Current price
│ ├── pair: String # e.g., "BTC/USD"
│ ├── admin_minted: u64 # Count of issued AdminCaps
│ ├── admin_limit: u64 # Maximum AdminCap limit
│ └── last_updated: u64 # Last update timestamp (epoch)
├── SuperAdminCap (Owned) # Super Admin capability (Can add Admins)
└── AdminCap (Owned) # Regular Admin capability (Can update price)

### 🛠️ Core Functions

| Function | Purpose | Permission Required | Description |
| :--- | :--- | :--- | :--- |
| `create_oracle` | Create Oracle | Anyone | Initialises Oracle, SuperAdminCap, and AdminCap |
| `add_admin` | Add New Admin | `SuperAdminCap` | Issues a new AdminCap to a specified address |
| `increase_limit`| Increase Admin Limit | `SuperAdminCap` | Adjusts the maximum limit for AdminCaps |
| `update_price` | Update Price | `AdminCap` | Updates the Oracle price and emits an Event |
| `get_price` | Query Price | Read-only `&Oracle` | Public access for reading price |
| `is_fresh` | Check Freshness | Read-only `&Oracle` | Verifies if the price is stale (Defensive programming) |

## 💻 Usage Examples

### 1. Query Price (CLI)
sui client call
--package [PACKAGE_ID]
--module price_oracle
--function get_price
--args [ORACLE_OBJECT_ID]
### 2. DeFi Integration Example (Move Contract)
public fun safe_liquidate(oracle: &Oracle, ctx: &TxContext) {
    // ✅ Prevent stale price attacks
    // Check if the price was updated within the last 300 seconds (5 mins)
    assert!(price_oracle::is_fresh(oracle, 300, ctx), E_STALE_PRICE);
    let price = price_oracle::get_price(oracle);
    // Execute safe liquidation logic...
}

## 🔄 Multi-Machine Development Workflow

1.  **Sync Code**
    ```
    git pull origin main
    ```
2.  **Publish Independently on Each Machine**
    ```
    sui move build
    sui client publish --gas-budget 100000000
    ```
3.  **Update README + Push**
    ```
    git add README.md
    git commit -m "docs: update [Machine Name] Package ID"
    git push
    ```

## 🧪 Local Development Commands

*   **Environment Check**
    ```
    sui client active-env # Should be testnet
    sui client gas        # Balance > 0.1 SUI
    ```
*   **Development Cycle**
    ```
    sui move build    # Compile
    sui move test     # Run tests
    sui client publish # Deploy
    ```
*   **Git Sync**
    ```
    git status
    git add .
    git commit -m "feat: Describe new features..."
    git push
    ```

## 📚 Learning Resources

*   [Sui Move Book](https://move-language.github.io/move/)
*   [Official Sui Documentation](https://docs.sui.io/)
*   [Suivision Explorer](https://suivision.xyz/testnet)
*   Reference: [Perplexity AI Sui Move Tutorials](https://www.perplexity.ai/)

## 🔧 System Requirements

*   **Sui CLI**: Latest version
*   **Network**: testnet
*   **Dependencies**: Sui Framework (framework/testnet)
*   **Move.toml + Move.lock**: Committed ✓

## 📈 Commit History
*(Full history: `git log --oneline -10`)*

## 🙋‍♂️ Issues & Contributions

*   🐛 Found a bug? [Open an Issue](https://github.com/repotecJC/Sui_Learning/issues)
*   💡 Have suggestions? Pull Requests are welcome
*   🤝 Want to collaborate? Contact **repotecJC**

## ⭐ Support This Project

Learning Sui Move / Web3 and growing every day!  
**Star this repo** or **share with friends** to show your support!

---

**Last Updated**: 31 Dec 2025  
**TODO**: `[PASTE_MACBOOK_PACKAGE_ID_HERE]` ← **Run `sui client objects | grep package` on MacBook and fill in**
