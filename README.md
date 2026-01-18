# Sui Move Learning Project 🚀

一個完整的 Sui Move 練習專案，包含官方的 **Hero 範例** + 自製的 **多幣別價格 Oracle Registry**。

**學習重點**：Objects、Capabilities、Events、Shared Objects、動態物件欄位 (Dynamic Object Fields)、價格新鮮度檢查、分層權限管理、多 Oracle 註冊與移除流程。

[![Sui Testnet](https://img.shields.io/badge/Sui-Testnet-blue.svg)](https://suivision.xyz/testnet)

## 🚀 快速開始

1.  **Clone 專案**
    ```bash
    git clone https://github.com/repotecJC/Sui_Learning.git
    cd Sui_Learning
    ```
2.  **確認 Testnet + 領取測試幣**
    ```bash
    sui client active-env # 確認目前環境為 testnet
    sui client faucet # 向水龍頭請求 testnet SUI
    ```
3.  **建置與發布套件**
    ```bash
    sui move build
    sui client publish --gas-budget 100000000 # 請記下輸出的 Package ID
    ```

## 📦 已部署套件資訊

| Environment | Package ID | Deployment Machine | Suivision Link | Status |
| :--- | :--- | :--- | :--- | :--- |
| **testnet** | `0x42c67a54264a111fe2a865d9e34ead1855a12888a50303b6bf9a4007e2853f93` | **Windows PC** | [View](https://suivision.xyz/testnet/object/0x42c67a54264a111fe2a865d9e34ead1855a12888a50303b6bf9a4007e2853f93) | ✅ Verified |
| **testnet** | `0x278e8056d479540c934ce4ded717b2cad166855fdb1aaca742742d7329dd1c72` | **MacBook** | [View](https://suivision.xyz/testnet/object/0x278e8056d479540c934ce4ded717b2cad166855fdb1aaca742742d7329dd1c72) | ✅ Verified |

**如何在 MacBook 上找到 Package ID**：

*   Mac/Linux:
    ```bash
    sui client objects | grep package
    ```
*   Windows:
    ```powershell
    sui client objects | Select-String "package"
    ```

## 🏗️ 專案結構
```bash
sources/
├── hero.move                  # 官方 Sui Hero 範例
├── price_oracle.move          # 單一 Price Oracle (分層權限管理)
│   ├── Oracle (Shared Object)
│   │   ├── price: u64         # 目前價格
│   │   ├── pair: String       # 交易對，如 "BTC/USD"
│   │   ├── admin_minted: u64  # 已發行 AdminCap 數量
│   │   ├── admin_limit: u64   # AdminCap 最大上限
│   │   └── last_updated: u64  # 最後更新時間（epoch）
│   ├── SuperAdminCap (Owned)  # 超級管理員權限（可新增 Admin）
│   └── AdminCap (Owned)       # 一般管理員權限（可更新價格）
└── multi_oracle_registry.move # 多 Oracle Registry 系統
    └── OracleRegistry (Shared Object) # 管理多個 Oracle
```

## 🛠️ 核心功能

1. Price Oracle (單一預言機)

| Function       | Purpose     | Permission Required | Description                         |
| -------------- | ----------- | ------------------- | ----------------------------------- |
| create_oracle  | 建立 Oracle   | 任何人                 | 初始化 Oracle、SuperAdminCap 和 AdminCap |
| add_admin      | 新增 Admin    | SuperAdminCap       | 發行新的 AdminCap 給指定地址                 |
| increase_limit | 提高 Admin 上限 | SuperAdminCap       | 調整 AdminCap 的最大發行量                  |
| update_price   | 更新價格        | AdminCap            | 更新 Oracle 價格並發出事件                   |
| get_price      | 查詢價格        | Read-only &Oracle   | 公開讀取目前價格                            |
| is_fresh       | 檢查新鮮度       | Read-only &Oracle   | 驗證價格是否過期 (防禦性程式設計)                  |

2. Multi Oracle Registry (預言機註冊表)

| Function            | Purpose        | Permission Required | Description                     |
| ------------------- | -------------- | ------------------- | ------------------------------- |
| create_registry     | 建立 Registry    | 任何人                 | 初始化並分享 OracleRegistry           |
| register_oracle     | 註冊 Oracle      | &mut OracleRegistry | 建立新 Oracle 並存入 Registry，權限轉給發送者 |
| remove_oracle       | 移除 Oracle      | SuperAdminCap       | 從 Registry 移除 Oracle 並將所有權轉給發送者 |
| get_oracle_price    | 透過 Registry 查價 | &OracleRegistry     | 根據交易對 (Base/Quote) 查詢價格         |
| update_oracle_price | 透過 Registry 更新 | AdminCap            | 透過 Registry 介面更新特定 Oracle 的價格   |

## 💻 使用範例

1. 透過 CLI 查詢價格 (Registry 模式)
```bash
sui client call \
--package [PACKAGE_ID] \
--module multi_oracle_registry \
--function get_oracle_price \
--args [REGISTRY_ID] "" "" # ASCII for BTC, USDT
```

2. DeFi 整合範例 (Move Contract)

```bash
public fun safe_liquidate(oracle: &Oracle, ctx: &TxContext) {
    // ✅ 防止過期價格攻擊
    // 檢查價格是否在過去 300 秒 (5 分鐘) 內更新
    assert!(price_oracle::is_fresh(oracle, 300, ctx), E_STALE_PRICE);
    let price = price_oracle::get_price(oracle);
    // 執行安全清算邏輯...
}
```
## 🔄 多機開發流程 (Multi-Machine Workflow)

### 同步程式碼

```bash
git pull origin main
獨立發布
```
```bash
sui move build
sui client publish --gas-budget 100000000
更新 README 並推送
```
```bash
git add README.md
git commit -m "docs: update [Machine Name] Package ID"
git push
```

## 🧪 本地開發指令
## 環境檢查

```bash
sui client active-env # 應為 testnet
sui client gas        # 餘額需 > 0.1 SUI
開發循環
```
```bash
sui move build    # 編譯
sui move test     # 執行測試
sui client publish # 部署
Git 同步
```
```bash
git status
git add .
git commit -m "feat: Describe new features..."
git push
```

## 📚 學習資源
Sui Move Book

Official Sui Documentation

Suivision Explorer

Reference: Perplexity AI Sui Move Tutorials

## 🔧 系統需求
Sui CLI: 最新版本

Network: testnet

Dependencies: Sui Framework (framework/testnet)

Move.toml + Move.lock: 已提交 ✓

## 📈 Commit History
(Full history: git log --oneline -10)

## ⭐ 支持本專案
正在學習 Sui Move / Web3 並持續成長中！
幫這個 repo 按個 Star 或 分享給朋友 以示支持！

Last Updated: 17 Jan 2026