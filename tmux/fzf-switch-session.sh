#!/usr/bin/env bash

session=$(tmux list-sessions -F '#{session_name}' | fzf --height=40% --reverse)

[ -n "$session" ] && tmux switch-client -t "$session"
