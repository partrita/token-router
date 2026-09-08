#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/partrita/token-router.git"
INSTALL_DIR="${TOKEN_ROUTER_INSTALL_DIR:-${HOME}/.local/share/token-router}"
CODEX_DIR="${HOME}/.codex/skills/token-router"
OPENCODE_DIR="${HOME}/.agents/skills/token-router"
ANTIGRAVITY_DIR="${HOME}/.gemini/antigravity-cli/skills/token-router"

usage() {
  cat <<'EOF'
Usage: install.sh [--codex] [--opencode] [--antigravity] [--all] [--help]

Install token-router as a shared skill for Codex, OpenCode, and/or Antigravity CLI.

Options:
  --codex        Install to ~/.codex/skills/token-router
  --opencode     Install to ~/.agents/skills/token-router
  --antigravity  Install to ~/.gemini/antigravity-cli/skills/token-router
  --all          Install for all supported clients
  --help         Show this help

Environment:
  TOKEN_ROUTER_INSTALL_DIR  Source checkout/cache directory
EOF
}

copy_skill() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  rm -rf "$target"
  mkdir -p "$target"
  cp -R "${INSTALL_DIR}/.agents/skills/token-router/." "$target/"
  echo "Installed: $target"
}

need_source() {
  if [[ -f "${INSTALL_DIR}/.agents/skills/token-router/SKILL.md" ]]; then
    return
  fi

  if command -v git >/dev/null 2>&1; then
    mkdir -p "$(dirname "$INSTALL_DIR")"
    rm -rf "$INSTALL_DIR"
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
  else
    echo "error: git is required when token-router is not already checked out" >&2
    exit 1
  fi
}

if [[ $# -eq 0 ]]; then
  set -- --all
fi

install_codex=false
install_opencode=false
install_antigravity=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex) install_codex=true ;;
    --opencode) install_opencode=true ;;
    --antigravity) install_antigravity=true ;;
    --all) install_codex=true; install_opencode=true; install_antigravity=true ;;
    --help|-h) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

need_source

$install_codex && copy_skill "$CODEX_DIR"
$install_opencode && copy_skill "$OPENCODE_DIR"
$install_antigravity && copy_skill "$ANTIGRAVITY_DIR"

echo
cat <<'EOF'
Done. The skill is available as `token-router` in the selected clients.
Make sure Ollama is installed and the routing model is available, for example:

  ollama pull gemma4:e2b-it-q4_K_M
EOF
