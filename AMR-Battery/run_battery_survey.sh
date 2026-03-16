#!/usr/bin/env bash
OUTPUT="/c/Users/user/Documents/Claude/AMR-Battery"
TS=$(date +"%Y%m%d_%H%M%S")
PROMPTS="/c/Users/user/.claude/amr-battery-prompts"

echo "[START] $TS — 6 agents launching in parallel"

gemini -p "$(cat $PROMPTS/s1_warehouse_picking.txt)"   --output-format text -y > "$OUTPUT/s1_$TS.md" 2>&1 &
gemini -p "$(cat $PROMPTS/s2_pallet_amr.txt)"          --output-format text -y > "$OUTPUT/s2_$TS.md" 2>&1 &
gemini -p "$(cat $PROMPTS/s3_coldchain_outdoor.txt)"   --output-format text -y > "$OUTPUT/s3_$TS.md" 2>&1 &
gemini -p "$(cat $PROMPTS/s4_medical_gmp.txt)"         --output-format text -y > "$OUTPUT/s4_$TS.md" 2>&1 &
gemini -p "$(cat $PROMPTS/s5_delivery_patrol.txt)"     --output-format text -y > "$OUTPUT/s5_$TS.md" 2>&1 &
gemini -p "$(cat $PROMPTS/s6_port_heavyindustry.txt)"  --output-format text -y > "$OUTPUT/s6_$TS.md" 2>&1 &

wait
echo "[DONE] Wave 1 complete"

# 合併
cat "$OUTPUT"/s1_"$TS".md "$OUTPUT"/s2_"$TS".md "$OUTPUT"/s3_"$TS".md "$OUTPUT"/s4_"$TS".md "$OUTPUT"/s5_"$TS".md "$OUTPUT"/s6_"$TS".md > "$OUTPUT/merged_$TS.md"
echo "[MERGED] $OUTPUT/merged_$TS.md — 請 Claude 執行 Wave 2 整合"
