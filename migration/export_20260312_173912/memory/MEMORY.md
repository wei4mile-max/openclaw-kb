# Claude Code Memory — David Chang's Openclaw

## Notion 工作區
- **工作區名稱**: David Chang's Openclaw
- **Bot**: OpenClaw Workspace
- **工作區 ID**: e8613265-f620-8124-8324-00034eee04df
- **Notion MCP**: 已連接，可完整讀寫
- **主要資料庫**:
  - 任務管理 (Actions) — ID: `ef7f6162-d192-402b-9aaa-a017527909ac`
  - 每日新聞日報 — ID: `79566e1d-4e56-4c47-b982-a2436851cb01`
- **重要頁面**:
  - 工作控制台 (Work Dashboard) — ID: `2fd13265-f620-801c-a672-c6d91778cc1b`
  - AMR 市場調查 — ID: `31a13265-f620-800e-930f-ea71bbddfa21`
  - 深度模式測試區 (Deep Mode Sandbox) — ID: `2ff13265-f620-818b-a6ea-dfbc686b50f4`

## 可用 Skills（Skill tool 觸發）
| Skill | 用途 |
|---|---|
| `keybindings-help` | 自訂鍵盤快捷鍵、修改 ~/.claude/keybindings.json |
| `simplify` | 審查已修改的程式碼，找出可重用/改善之處 |
| `loop` | 設定重複執行的任務（如 `/loop 5m /foo`，預設 10m）|
| `claude-api` | 使用 Claude API / Anthropic SDK 建構應用 |

## 可用 Notion MCP 工具
- 搜尋：`API-post-search`
- 頁面：`API-retrieve-a-page`, `API-post-page`, `API-patch-page`, `API-move-page`
- 區塊：`API-get-block-children`, `API-patch-block-children`, `API-retrieve-a-block`, `API-update-a-block`, `API-delete-a-block`
- 資料庫：`API-retrieve-a-database`, `API-query-data-source`
- 評論：`API-create-a-comment`, `API-retrieve-a-comment`
- 用戶：`API-get-self`, `API-get-user`, `API-get-users`

## 每日淬鍊工作流程 (Daily Digest)
- **Notion 頁面**：每日淬鍊日誌 (Daily Digest) — ID: `32013265-f620-8130-beb1-de81ac5bdf2f`
- **位置**：工作控制台 (Work Dashboard) 子頁面
- **觸發**：用戶說「幫我整理今天」或類似指令
- **資料來源**：Notion 任務管理資料庫（查詢當天有異動的任務）+ 用戶補充
- **輸出**：
  1. 附加一筆日誌到上述 Notion 頁面
  2. 儲存為本地 .md 檔（路徑待用戶確認）
- **本地路徑**：`C:\Users\user\Documents\Claude\Dailydigest\`
- **格式**：日期標題 + 完成事項 + 進行中事項 + 反思/重點摘要

## 團隊編組格式規範
未來所有團隊編組一律以下表格式呈現：

| 角色 | 執行者 | 模型 | 狀態 |
|---|---|---|---|
| 角色名稱 | 工具/Agent 名稱 | 實際使用模型 ID | ✅/⏳/❌ |

- 模型欄位需填入實際模型 ID（非自稱名稱，透過 JSON output 確認）
- 狀態：✅ 就緒 / ⏳ 待命 / ❌ 離線

## AMR/AGV 市場調查專家團隊
| 角色 | 執行者 | 模型 | 狀態 |
|---|---|---|---|
| **專案總指揮** | Claude Code | claude-sonnet-4-6 | ✅ 就緒 |
| **首席市場研究員** | Gemini CLI | gemini-3-flash-preview | ✅ 就緒 |
| **任務路由器** | Gemini CLI（內建） | gemini-2.5-flash-lite | ✅ 就緒 |

- Gemini CLI 版本：v0.32.1
- 呼叫方式：`gemini -p "prompt" --output-format text -y`
- 模型確認方式：`gemini -p "..." --output-format json` 查看 stats.models
- **研究目標**：AMR/AGV 全球市場 2025–2030（市場規模、存量、增量）
- **研究框架**：Phase 1 市場規模 → Phase 2 存量 → Phase 3 增量 → Phase 4 競品矩陣
- **狀態**：編組完成，待命中

## 用戶偏好
- 語言：繁體中文溝通
- 工作重心：AMR/AGV 市場研究、歐洲出差規劃（LogiMAT 2026）
