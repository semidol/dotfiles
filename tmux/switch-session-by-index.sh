#!/usr/bin/env bash

INDEX=$1
SESSION=$(tmux list-sessions -F '#{session_name}' | sed -n "${INDEX}p")

[ -n "$SESSION" ] && tmux switch-client -t "$SESSION"
