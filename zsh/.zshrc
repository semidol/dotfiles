# ── Oh My Zsh ────────────────────────────────────────────────────────────────
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
# zsh-syntax-highlighting wraps ZLE widgets, so it must stay last.
plugins=(git zsh-autosuggestions rust docker fzf nvm zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ── PATH ─────────────────────────────────────────────────────────────────────
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/utils:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ── Linux dev VM ─────────────────────────────────────────────────────────────
# The VM provisions node through fnm and foundry into ~/.foundry, neither of
# which matches the macOS setup.
if [[ "$OSTYPE" == linux* ]]; then
  export PATH="$HOME/.foundry/bin:$PATH"

  if [[ -x "$HOME/.local/share/fnm/fnm" ]]; then
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd --shell zsh)"
  fi
fi

# ── Environment ──────────────────────────────────────────────────────────────
export JQ_COLORS="0;36:0;36:0;36:0;33:0;92:0;35:0;34:0;31"

# ── Aliases ───────────────────────────────────────────────────────────────────
alias gac="git-ai-commit"
alias gs="git status"

# limactl defaults to bash regardless of the guest's login shell.
alias devsh="limactl shell --shell /usr/bin/zsh dev"

# ── Keybindings ───────────────────────────────────────────────────────────────
# Bind F12 (triggered by Cmd+Shift+N) to run tmux-pick
bindkey -s '^[[24~' 'tmux-pick\n'

bindkey '\e[1;3D' vi-backward-word
bindkey '\e[1;3C' vi-forward-word

# ── Tools ─────────────────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"
