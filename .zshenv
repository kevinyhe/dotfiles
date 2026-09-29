# Keep Linux tools authoritative. The only Windows executable path retained is
# VS Code, which is intentionally host-managed and WSL-aware.
typeset -U path PATH
path=(
  "$HOME/.local/share/mise/shims"
  "$HOME/.local/bin"
  /usr/local/sbin
  /usr/local/bin
  /usr/sbin
  /usr/bin
  /sbin
  /bin
  /usr/games
  /usr/local/games
  /usr/lib/wsl/lib
  "/mnt/c/Program Files/Microsoft VS Code/bin"
)
export PATH
export UV_NO_MANAGED_PYTHON="1"
export UV_PYTHON_DOWNLOADS="never"
export NEXT_TELEMETRY_DISABLED="1"
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"
