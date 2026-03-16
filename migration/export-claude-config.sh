#!/bin/bash
# ============================================================
# Claude Code 設定匯出腳本
# 用途：在舊機器上執行，打包所有設定供搬遷使用
# 使用方式：bash export-claude-config.sh
# ============================================================

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EXPORT_DIR="$HOME/Documents/Claude/migration/export_$TIMESTAMP"
CLAUDE_DIR="$HOME/.claude"
# Windows: .claude.json 在 C:/Users/<user>，非 bash $HOME
WIN_HOME=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r\n')
CLAUDE_JSON_WIN="${WIN_HOME}/.claude.json"
CLAUDE_JSON="${WIN_HOME//\\//}/.claude.json"
# Fallback for non-Windows
[ ! -f "$CLAUDE_JSON" ] && CLAUDE_JSON="$HOME/.claude.json"

echo "======================================"
echo " Claude Code 設定匯出工具"
echo " 目標資料夾：$EXPORT_DIR"
echo "======================================"

mkdir -p "$EXPORT_DIR"

# --- 1. Memory ---
echo "[1/5] 匯出 Memory..."
if [ -d "$CLAUDE_DIR/projects/C--Users-user/memory" ]; then
    cp -r "$CLAUDE_DIR/projects/C--Users-user/memory" "$EXPORT_DIR/memory"
    echo "  ✅ Memory 匯出完成 ($(ls "$EXPORT_DIR/memory" | wc -l) 個檔案)"
else
    echo "  ⚠️  Memory 資料夾不存在，跳過"
fi

# --- 2. Custom Commands / Skills ---
echo "[2/5] 匯出 Commands/Skills..."
if [ -d "$CLAUDE_DIR/commands" ]; then
    cp -r "$CLAUDE_DIR/commands" "$EXPORT_DIR/commands"
    echo "  ✅ Commands 匯出完成 ($(ls "$EXPORT_DIR/commands" | wc -l) 個檔案)"
else
    echo "  ⚠️  Commands 資料夾不存在，跳過"
fi

# --- 3. Settings ---
echo "[3/5] 匯出 Settings..."
cp "$CLAUDE_DIR/settings.json" "$EXPORT_DIR/settings.json" 2>/dev/null && echo "  ✅ settings.json" || echo "  ⚠️  settings.json 不存在"
cp "$CLAUDE_DIR/settings.local.json" "$EXPORT_DIR/settings.local.json" 2>/dev/null && echo "  ✅ settings.local.json" || echo "  ℹ️  settings.local.json 不存在（可選）"

# --- 4. MCP Config ---
echo "[4/5] 匯出 MCP 設定..."
# 將 bash 路徑轉換為 Windows 路徑供 Python 使用
EXPORT_DIR_WIN=$(cygpath -w "$EXPORT_DIR" 2>/dev/null || echo "$EXPORT_DIR" | sed 's|^/c/|C:/|')
export MCP_OUT_PATH="${EXPORT_DIR_WIN}/mcp-config.json"
python3 << PYEOF
import json, sys, os, getpass
uname = getpass.getuser()
src_paths = ['C:/Users/' + uname + '/.claude.json']
d = None
for p in src_paths:
    try:
        d = json.load(open(p))
        break
    except:
        pass
if d is None:
    print('  ⚠️  找不到 .claude.json')
    sys.exit(0)
try:
    projects = d.get('projects', {})
    mcp_export = {}
    for k, v in projects.items():
        if isinstance(v, dict) and 'mcpServers' in v:
            mcp_export[k] = v['mcpServers']
    out_path = os.environ.get('MCP_OUT_PATH', '')
    if mcp_export:
        json.dump(mcp_export, open(out_path, 'w', encoding='utf-8'), indent=2)
        print('  [OK] MCP config exported')
    else:
        print('  [WARN] no mcpServers found')
except Exception as e:
    import sys; print(f'  [ERR] {e}', file=sys.stderr)
PYEOF

# --- 5. 寫入 Manifest ---
echo "[5/5] 產生搬遷清單..."
USERNAME=$(whoami)
HOSTNAME=$(hostname)
cat > "$EXPORT_DIR/MANIFEST.json" << EOF
{
  "exported_at": "$TIMESTAMP",
  "source_machine": "$HOSTNAME",
  "source_user": "$USERNAME",
  "source_home": "$HOME",
  "source_project_key": "C--Users-$USERNAME",
  "claude_code_version": "$(claude --version 2>/dev/null || echo 'unknown')",
  "files": {
    "memory": "memory/",
    "commands": "commands/",
    "settings": "settings.json",
    "settings_local": "settings.local.json",
    "mcp_config": "mcp-config.json"
  }
}
EOF
echo "  ✅ MANIFEST.json 產生完成"

# --- 複製 SOP ---
SOP_PATH="$HOME/Documents/Claude/migration/MIGRATION-SOP.md"
if [ -f "$SOP_PATH" ]; then
    cp "$SOP_PATH" "$EXPORT_DIR/MIGRATION-SOP.md"
    echo "  ✅ SOP 已包含在 export 包內"
fi

echo ""
echo "======================================"
echo " 匯出完成！"
echo " 路徑：$EXPORT_DIR"
echo ""
echo " 下一步："
echo " 1. 將整個資料夾複製到新機器"
echo " 2. 在新機器安裝 Claude Code"
echo " 3. 告訴 Claude：「執行搬遷 SOP，package 在 [路徑]」"
echo "======================================"
