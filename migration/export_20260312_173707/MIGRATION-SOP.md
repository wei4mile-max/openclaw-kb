# Claude Code 搬遷 SOP
> 本文件供 Claude Code 在新機器上執行搬遷任務使用
> 觸發指令：「執行搬遷 SOP，package 在 [路徑]」

---

## 0. 前置確認

Claude 收到搬遷指令後，請依序執行以下步驟。每步驟完成後輸出狀態。

**必備條件（開始前確認）：**
- [ ] Claude Code 已安裝在新機器（`claude --version` 可執行）
- [ ] 用戶已提供 migration package 路徑
- [ ] Node.js 已安裝（`node --version`）

---

## 1. 讀取 Manifest

```bash
cat "[package路徑]/MANIFEST.json"
```

記錄：
- `source_user`：舊機用戶名
- `source_project_key`：舊機 project key（格式：`C--Users-<user>`）
- 新機當前用戶名：`whoami`
- 新機 project key：`C--Users-<新用戶名>`

---

## 2. 建立目錄結構

```bash
NEW_USER=$(whoami)
mkdir -p "$HOME/.claude/projects/C--Users-$NEW_USER/memory"
mkdir -p "$HOME/.claude/commands"
```

---

## 3. 複製 Memory

```bash
cp -r "[package路徑]/memory/." "$HOME/.claude/projects/C--Users-$NEW_USER/memory/"
```

**驗證：**
```bash
ls "$HOME/.claude/projects/C--Users-$NEW_USER/memory/"
```
應看到 `MEMORY.md` 及其他記憶檔。

---

## 4. 複製 Commands（Skills）

```bash
cp -r "[package路徑]/commands/." "$HOME/.claude/commands/"
```

**驗證：**
```bash
ls "$HOME/.claude/commands/"
```
應看到 `weekly-report.md` 等檔案。

---

## 5. 複製 Settings

```bash
cp "[package路徑]/settings.json" "$HOME/.claude/settings.json"
```

如果有 settings.local.json：
```bash
cp "[package路徑]/settings.local.json" "$HOME/.claude/settings.local.json" 2>/dev/null || true
```

---

## 6. 設定 MCP Server（Notion）

執行以下指令加入 Notion MCP：

```bash
claude mcp add notion -s user -- npx -y @notionhq/notion-mcp-server
```

然後設定 Notion Token（直接寫入 .claude.json）：

**Notion MCP 完整設定：**
```json
{
  "notion": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@notionhq/notion-mcp-server"],
    "env": {
      "OPENAPI_MCP_HEADERS": "{\"Authorization\":\"Bearer ntn_V51405102402mWQCA8M0awnIcD0MT5vC43u46WXaCyzfZK\",\"Notion-Version\":\"2022-06-28\"}"
    }
  }
}
```

使用 Python 寫入：
```bash
python3 -c "
import json
path = '$HOME/.claude.json'
try:
    d = json.load(open(path))
except:
    d = {}
import os
project_key = 'C:/Users/' + os.environ.get('USERNAME', os.environ.get('USER', 'user'))
if 'projects' not in d:
    d['projects'] = {}
if project_key not in d['projects']:
    d['projects'][project_key] = {}
d['projects'][project_key]['mcpServers'] = {
    'notion': {
        'type': 'stdio',
        'command': 'npx',
        'args': ['-y', '@notionhq/notion-mcp-server'],
        'env': {
            'OPENAPI_MCP_HEADERS': '{\"Authorization\":\"Bearer ntn_V51405102402mWQCA8M0awnIcD0MT5vC43u46WXaCyzfZK\",\"Notion-Version\":\"2022-06-28\"}'
        }
    }
}
json.dump(d, open(path, 'w'), indent=2)
print('MCP config written successfully')
"
```

---

## 7. 安裝 Gemini CLI

```bash
npm install -g @google/gemini-cli
gemini --version
```

登入 Gemini CLI：
```bash
gemini
```
（首次執行會要求 Google 帳號授權）

---

## 8. 驗證整體設定

執行以下驗證指令：

```bash
# 驗證 Memory
echo "=== Memory ===" && ls "$HOME/.claude/projects/C--Users-$(whoami)/memory/"

# 驗證 Commands
echo "=== Commands ===" && ls "$HOME/.claude/commands/"

# 驗證 Settings
echo "=== Settings ===" && cat "$HOME/.claude/settings.json"

# 驗證 Claude Code
echo "=== Claude Code ===" && claude --version

# 驗證 Gemini CLI
echo "=== Gemini CLI ===" && gemini --version

# 驗證 Gemini 回應
echo "=== Gemini 測試 ===" && gemini -p "回覆一句話確認你已就緒" --output-format text -y
```

---

## 9. 搬遷完成確認

完成後向用戶回報：
```
✅ 搬遷完成！

已還原項目：
- Memory: [N] 個記憶檔
- Commands/Skills: [N] 個自訂指令
- Settings: 權限設定
- MCP: Notion 已連接
- Gemini CLI: v[version]

工作區：David Chang's Openclaw
建議執行：`claude mcp list` 確認 Notion MCP 已啟用
```

---

## 附錄：重要資訊

### Notion 工作區
- **工作區**：David Chang's Openclaw
- **Bot**：OpenClaw Workspace
- **工作區 ID**：e8613265-f620-8124-8324-00034eee04df
- **Token**：`ntn_V51405102402mWQCA8M0awnIcD0MT5vC43u46WXaCyzfZK`

### 主要資料庫 ID
- 任務管理 (Actions)：`ef7f6162-d192-402b-9aaa-a017527909ac`
- 每日新聞日報：`79566e1d-4e56-4c47-b982-a2436851cb01`

### 重要頁面 ID
- 工作控制台：`2fd13265-f620-801c-a672-c6d91778cc1b`
- AMR 市場調查：`31a13265-f620-800e-930f-ea71bbddfa21`
- 深度模式測試區：`2ff13265-f620-818b-a6ea-dfbc686b50f4`
- 每日淬鍊日誌：`32013265-f620-8130-beb1-de81ac5bdf2f`

### 本地路徑
- 每日淬鍊輸出：`C:\Users\<用戶名>\Documents\Claude\Dailydigest\`
