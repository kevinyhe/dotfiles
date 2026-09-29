# Managed WSL development shell configuration.
# Backup: ~/wsl-dev-runbook/backups/pre-setup-20260711-050940

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-FRX"
export UV_NO_MANAGED_PYTHON="1"
export UV_PYTHON_DOWNLOADS="never"
export NEXT_TELEMETRY_DISABLED="1"
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INTERACTIVE_COMMENTS

# Type a directory name to cd into it. `cd -<Tab>` lists recent directories.
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

autoload -Uz compinit
mkdir -p "$HOME/.cache/zsh"
compinit -d "$HOME/.cache/zsh/zcompdump"
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'

# fzf: list files with fd, preview with bat.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"

[[ -r /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
[[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
# Tab opens a list of every match. Type to narrow it, Enter to pick.
# Folders preview their contents, files preview their first 100 lines.
# Must load after compinit and before zsh-autosuggestions.
if [[ -r "$HOME/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
  zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border --color=bg+:#262626,hl:#61afef,hl+:#61afef,pointer:#61afef
  zstyle ':fzf-tab:*' fzf-min-height 12
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then out=$(eza -1a --color=always --icons=auto --group-directories-first $realpath); print -r -- ${out:-"(empty folder)"}; elif [[ -f $realpath ]]; then bat --color=always --style=numbers --line-range=:100 $realpath; fi'
  zstyle ':fzf-tab:complete:(kill|ps):*' fzf-preview ''
fi

[[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Up/down search history by what is already typed.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search
bindkey '^[[1;5C' forward-word        # Ctrl+Right
bindkey '^[[1;5D' backward-word       # Ctrl+Left
bindkey '^[[H' beginning-of-line      # Home
bindkey '^[[F' end-of-line            # End
bindkey '^[[3~' delete-char           # Delete
bindkey '^?' backward-delete-char     # Backspace

eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

alias ll='eza -lah --group-directories-first --git'
alias la='eza -a --group-directories-first'
alias cproj='cd ~/projects'
alias cwork='cd ~/worktrees'
alias reload='exec zsh'
alias lt='eza --tree --level=2 --group-directories-first'
alias ..='cd ..'
alias ...='cd ../..'
alias v='nvim'
alias g='git'
alias gst='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias t='tmux new-session -A -s main'
alias tl='tmux list-sessions'
alias zshrc='nvim ~/.zshrc'

# Make Windows executables available inside WSL.
typeset -U path PATH
path+=(
  /mnt/c/Windows/System32
  /mnt/c/Windows/System32/WindowsPowerShell/v1.0
)
export PATH

# ARM embedded toolchain (UTFR firmware)
export PATH="$HOME/.local/opt/arm-gnu-toolchain/bin:$PATH"

# System summary when a new terminal window opens.
# Skipped inside tmux, VS Code and Claude Code.
if [[ -o interactive && $SHLVL -eq 1 && -z "$TMUX" && -z "$CLAUDECODE" && "$TERM_PROGRAM" != "vscode" ]] && (( $+commands[neofetch] )); then
  neofetch
fi

# Syntax highlighting. Must stay the last line.
[[ -r "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
