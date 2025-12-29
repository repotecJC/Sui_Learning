# Sui Move 學習專案 🚀

一個完整的 Sui Move 練習專案，包含 **Hero 範例** + 自製 **Price Oracle**（價格預言機）。

**學習重點**：Object、Capability、Event、Shared Object、價格新鮮度檢查。

[![Sui Testnet](https://img.shields.io/badge/Sui-Testnet-blue.svg)](https://suivision.xyz/testnet)

## 🚀 快速啟動
1. Clone 專案
git clone https://github.com/repotecJC/Sui_Learning.git
cd Sui_Learning

2. 確認 testnet + 領 SUI
sui client active-env # 確認 testnet
sui client faucet # 領 testnet SUI

3. 編譯 + 部署
sui move build
sui client publish # 記下顯示的 Package ID！


## 📦 已部署 Package ID

| 環境 | Package ID | 部署電腦 | Suivision 連結 | 狀態 |
|------|------------|----------|---------------|------|
| **testnet** | `0x42c67a54264a111fe2a865d9e34ead1855a12888a50303b6bf9a4007e2853f93` | **Windows PC** | [查看](https://suivision.xyz/testnet/object/0x42c67a54264a111fe2a865d9e34ead1855a12888a50303b6bf9a4007e2853f93) | ✅ 已確認 |
| **testnet** | `[MACBOOK_PACKAGE_ID_請貼這裡]` | **MacBook** | [查看](https://suivision.xyz/testnet/object/[MACBOOK_PACKAGE_ID_請貼這裡]) | ⏳ 待確認 |

**填入 MacBook Package ID 方法**：
Mac/Linux
sui client objects | grep package

Windows
sui client objects | Select-String "package"


## 🏗️ 專案架構
sources/
├── hero.move # Sui 官方 Hero 範例
└── price_oracle.move # 自製價格預言機
├── Oracle (Shared Object)
│ ├── price: u64 # 當前價格
│ ├── pair: String # "BTC/USD"
│ └── last_updated: u64 # 上次更新時間 (epoch)
└── AdminCap (Capability) # 管理權限


### 🛠️ 核心功能

| 函式 | 用途 | 權限要求 |
|------|------|----------|
| `create_oracle` | 建立預言機 | 任何人 |
| `update_price` | 更新價格 | 需要 `AdminCap` |
| `get_price` | 查詢價格 | 唯讀 `&Oracle` |
| `is_price_fresh` | 檢查新鮮度 | 唯讀 `&Oracle` + `&TxContext` |

## 💻 使用範例

### 1. 查詢價格
sui client call
--package 0x42c67a54264a111fe2a865d9e34ead1855a12888a50303b6bf9a4007e2853f93
--module price_oracle
--function get_price
--args [ORACLE_OBJECT_ID]

### 2. DeFi 整合範例（其他合約）
public fun safe_liquidate(oracle: &Oracle, ctx: &TxContext) {
// ✅ 防 stale price 攻擊
assert!(price_oracle::is_price_fresh(oracle, 300, ctx), E_STALE_PRICE);
let price = price_oracle::get_price(oracle);
// 安全清算...
}


## 🔄 多台電腦開發流程
1. 同步程式碼
git pull origin main

2. 每台電腦獨立 publish
sui move build
sui client publish # 產生獨立 Package ID

3. 更新 README + push
git add README.md
git commit -m "docs: update [電腦名] Package ID"
git push


## 🧪 本地開發指令
環境檢查
sui client active-env # testnet
sui client gas # 餘額 > 0.1 SUI

開發循環
sui move build # 編譯
sui move test # 測試
sui client publish # 部署

Git 同步
git status
git add .
git commit -m "feat: ..."
git push


## 📚 學習資源

- [Sui Move Book](https://move-language.github.io/move/)
- [Sui 官方文件](https://docs.sui.io/)
- [Suivision 瀏覽器](https://suivision.xyz/testnet)
- 參考：[Perplexity AI Sui Move 教學](https://www.perplexity.ai/)

## 🔧 環境需求
Sui CLI: 最新版
Network: testnet
Dependencies: Sui Framework (framework/testnet)
Move.toml + Move.lock 已 commit ✓


## 📈 Commit 歷史
a823041 feat(oracle): add update_price + is_fresh
ce60ecf feat(oracle): create_oracle + structs
34c4155 docs: add price_oracle.move
baca886 feat(oracle): module structure

完整歷史：`git log --oneline -10`

## 🙋‍♂️ 問題回報 & 貢獻

- 🐛 發現 bug？[開 Issue](https://github.com/repotecJC/Sui_Learning/issues)
- 💡 有建議？歡迎 Pull Request
- 🤝 想合作？聯絡 repotecJC

## ⭐ 支援專案

正在學習 Sui Move / Web3，一起進步！  
**Star 支持** 或 **分享給朋友**～

---

**最後更新**：2025-12-29  
**TODO**: `[MACBOOK_PACKAGE_ID_請貼這裡]` ← **回家 MacBook 執行 `sui client objects | grep package` 填入**
