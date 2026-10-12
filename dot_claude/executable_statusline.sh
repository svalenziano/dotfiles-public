#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Get token count (sum of input + cache tokens), default to 0 before first API call
TOKENS=$(echo "$input" | jq -r '
  .context_window.current_usage //  {} |
  ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))
')
TOKENS=${TOKENS:-0}

# Format tokens as Xk
TOKENS_K=$(( TOKENS / 1000 ))

# Use just the folder name to avoid overflowing on long paths
BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
DIR=$(basename "$DIR")

if [ -n "$BRANCH" ]; then
  printf "%s \033[91m(%s)\033[0m | %s | %sk (%s%%)\n" "$DIR" "$BRANCH" "$MODEL" "$TOKENS_K" "$PCT"
else
  printf "%s | %s | %sk (%s%%)\n" "$DIR" "$MODEL" "$TOKENS_K" "$PCT"
fi
