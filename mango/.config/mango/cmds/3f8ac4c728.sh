#!/bin/sh
# Mod+Ctrl+Alt+Shift+I
$NIRI_TERMINAL_RUN codex --dangerously-bypass-approvals-and-sandbox -c 'tui.status_line=["model-with-reasoning", "current-dir", "git-branch", "context-used", "used-tokens", "total-input-tokens", "total-output-tokens", "five-hour-limit", "weekly-limit", "estimated-thread-cost", "fast-mode", "approval-mode"]'
