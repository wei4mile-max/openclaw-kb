# 科技週報自動生成

參數：`$ARGUMENTS`（格式：`W12` 或 `W12 2026-03-16~2026-03-22`）

你是一位科技產業分析師，負責自動搜尋新聞、撰寫趨勢分析，並直接發佈到 Notion。**不需要給使用者看草稿，直接建立。**

---

## Step 1 — 解析參數

從 `$ARGUMENTS` 取得週次（如 W12）。若未提供日期範圍，根據週次自動推算當週一到週日（ISO 週）。

確認本週日期範圍，格式：`YYYY-MM-DD ~ YYYY-MM-DD`

---

## Step 2 — 七大領域新聞搜尋

針對以下七個領域，**逐一**呼叫 Gemini CLI 搜尋新聞：

```
領域列表：
1. 📡 CSP／資料中心
2. 🤖 人工智慧
3. 🦾 具身智能（人形機器人）
4. 🚁 無人機（國防／商業／eVTOL）
5. 🏭 倉儲物流自動化
6. 🛰️ 低軌衛星
7. 🚗 電動車
```

每個領域的 Gemini 搜尋指令格式：

```bash
gemini -p "請搜尋 [領域關鍵字] 在 [起始日期] 到 [結束日期] 之間的最新新聞。
要求：
1. 只收錄發布時間在 [起始日期]~[結束日期] 之間的新聞，絕對不可引用更早的新聞
2. 回傳 5~8 條最重要的新聞
3. 每條格式：標題 | 媒體來源名稱 | 原文URL | 發布日期(YYYY/MM/DD) | 一句話摘要(20字內)
4. 並提供本週該領域的趨勢總結：一句話核心訊號 + 3~4個趨勢主題（每個主題含2~3條條列說明）
5. 回應使用繁體中文
請確保所有新聞都有真實可驗證的URL" --output-format text -y
```

各領域搜尋關鍵字：
- CSP／資料中心：`CSP cloud data center hyperscaler capital expenditure AI infrastructure`
- 人工智慧：`artificial intelligence AI model LLM agent GenAI`
- 具身智能：`humanoid robot embodied AI Boston Dynamics Tesla Optimus Figure`
- 無人機：`drone UAV eVTOL defense commercial urban air mobility`
- 倉儲物流自動化：`warehouse automation logistics robot AMR AGV fulfillment`
- 低軌衛星：`LEO satellite SpaceX Starlink OneWeb Amazon Kuiper`
- 電動車：`electric vehicle EV BYD Tesla Rivian battery charging`

⚠️ **日期嚴格管控**：Gemini 回傳的每條新聞，必須確認發布日期在當週範圍內。若日期不符，捨棄該條，補搜其他新聞。

---

## Step 3 — 建立 Notion 頁面

使用 `mcp__notion__API-post-page` 建立新頁面：

```json
{
  "parent": { "database_id": "ef7f6162-d192-402b-9aaa-a017527909ac" },
  "icon": { "type": "emoji", "emoji": "📡" },
  "properties": {
    "任務名稱": { "title": [{ "text": { "content": "[W{N}] 科技週報" } }] },
    "狀態": { "status": { "name": "待處理" } },
    "標籤": { "multi_select": [{ "name": "Action (Task)" }] },
    "優先級": { "select": { "name": "🟡 中" } },
    "截止日期": { "date": { "start": "{本週日期}" } }
  }
}
```

取得頁面 ID 後進行下一步。

---

## Step 4 — 寫入頁面內容（⚠️ 嚴格遵守 API 限制）

### 🚨 關鍵技術限制（違反將導致 400 錯誤）

1. **children array 大小限制**：每次 `API-patch-block-children` 呼叫，children 的 JSON 序列化大小若過大（超過約 2000 字元）會被當成字串而非 array，導致 `body.children should be an array` 錯誤。解法：**每次最多 12-14 個純文字區塊**。

2. **table 必須帶 children**：建立 table 時 children 不可省略也不可為空，否則報 `table.children should be defined` 錯誤。**解法：建立 table 時只放 header row，之後再追加新聞列。**

3. **table 新聞列分批追加**：將 table block ID 當作 block_id，每次最多追加 **4 列**。

4. **rich_text annotations 必須完整**：每個 rich_text item 的 annotations 必須包含所有欄位：
   ```json
   {"bold": false, "italic": false, "strikethrough": false, "underline": false, "code": false, "color": "default"}
   ```

### 每個領域的 API 呼叫順序（4 次呼叫）

#### 呼叫 A — 趨勢分析區塊（頁面 ID）
一次呼叫，包含以下區塊（約 12 個）：
```
heading_2    {emoji} {領域名稱}
heading_3    📌 本週趨勢總結
callout      {核心訊號}  [bold:true, icon:💡, color:gray_background]
paragraph    {趨勢主題 1}  [bold:true]
bulleted_list_item  {細節 1}
bulleted_list_item  {細節 2}
paragraph    {趨勢主題 2}  [bold:true]
bulleted_list_item  {細節 1}
bulleted_list_item  {細節 2}
paragraph    {趨勢主題 3}  [bold:true]
bulleted_list_item  {細節 1}
bulleted_list_item  {細節 2}
```

#### 呼叫 B — 新聞表格標頭（頁面 ID）
```
heading_3    📰 關鍵新聞
table        [table_width:4, has_column_header:true, children: [header_row]]
```
header_row cells: ["新聞標題"(bold), "資料來源"(bold), "發布時間"(bold), "新聞總結"(bold)]

**→ 從回應取得 table block ID**

#### 呼叫 C — 新聞列 1-4（table block ID）
4 列 table_row，每列 4 個 cell：
- cell 1: 新聞標題（純文字）
- cell 2: 媒體名稱（帶 link.url 超連結）
- cell 3: 日期 YYYY/MM/DD（純文字）
- cell 4: 摘要（純文字）

#### 呼叫 D — 新聞列 5-8（table block ID）+ 分隔線
若有 5 條以上新聞，繼續追加剩餘列。
最後對**頁面 ID** 追加 `{"type":"divider","divider":{}}` 作為分隔線。

### 頁面開頭（第一個領域前）
```
paragraph    本報告涵蓋七大科技領域，採用「趨勢分析 + 關鍵新聞」格式...
             （"趨勢分析 + 關鍵新聞" 使用 bold:true）
quote        資料檢索期間：{YYYY}年{M}月{D}日 — {YYYY}年{M}月{D}日
divider
```

---

## Step 5 — 完成確認

建立成功後，輸出：
```
✅ [W{N}] 科技週報 已建立
📄 Notion 頁面：{page URL}
📅 資料期間：{起始日} — {結束日}
📊 領域覆蓋：7 個（CSP、AI、具身智能、無人機、倉儲物流、低軌衛星、電動車）
📰 新聞總計：{N} 條
⏳ 狀態：待處理
```

---

## 注意事項

1. **日期嚴格管控**：所有新聞發布日期必須落在當週範圍，不接受上週或更早的內容
2. **新聞數量**：每個領域最少 5 條、最多 8 條
3. **超連結必填**：每條新聞的資料來源欄位必須有真實 URL（link 物件）
4. **API 呼叫大小**：每次 children 陣列保持緊湊，純文字區塊不超過 14 個/次
5. **Table 建立流程**：先建含 header row 的空表 → 記錄 table block ID → 再分批加列（每批 ≤4 列）
6. **不顯示草稿**：直接執行到底，不中途詢問使用者確認
7. **領域可擴充**：若未來新增領域，按相同格式繼續追加即可
