#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# install-offline.sh
# Extracts a framework's node_modules into your project directory
#
# Usage:
#   ./install-offline.sh <framework> <target-path>
#
# Examples:
#   ./install-offline.sh typescript-vite /home/user/myapp
#   ./install-offline.sh nextjs /var/www/mysite
#   ./install-offline.sh all /home/user/   # extracts each to its own subfolder
#
# Frameworks:
#   react-vite, nextjs, vuejs-vite, nuxt,
#   angular, svelte, remix, astro, gatsby, nodejs-backend, all
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

FRAMEWORKS=(
  react-vite
  nextjs
  vuejs-vite
  nuxt
  angular
  svelte
  remix
  astro
  gatsby
  nodejs-backend
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header() {
  echo ""
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  NPM Offline Package Installer${NC}"
  echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════${NC}"
  echo ""
}

print_usage() {
  echo -e "${BOLD}Usage:${NC}"
  echo "  $0 <framework> <target-path>"
  echo ""
  echo -e "${BOLD}Frameworks:${NC}"
  for fw in "${FRAMEWORKS[@]}"; do
    echo "  - $fw"
  done
  echo "  - all  (installs each into <target-path>/<framework>/)"
  echo ""
  echo -e "${BOLD}Examples:${NC}"
  echo "  $0 typescript-vite /home/user/myapp"
  echo "  $0 all /home/user/projects"
}

check_deps() {
  if ! command -v tar &>/dev/null; then
    echo -e "${RED}Error: 'tar' is required but not installed.${NC}"
    exit 1
  fi
}

find_tarball() {
  local fw="$1"
  local tarball="${SCRIPT_DIR}/node_modules_by_framework/${fw}-node_modules.tar.gz"
  if [ -f "$tarball" ]; then
    echo "$tarball"
  else
    echo ""
  fi
}

install_framework() {
  local fw="$1"
  local target="$2"

  local tarball
  tarball=$(find_tarball "$fw")

  if [ -z "$tarball" ]; then
    echo -e "${RED}  ✗ Tarball not found for '$fw'${NC}"
    echo -e "    Expected: ${SCRIPT_DIR}/node_modules_by_framework/${fw}-node_modules.tar.gz"
    return 1
  fi

  echo -e "${CYAN}  → Installing ${BOLD}$fw${NC}${CYAN} into ${target}...${NC}"

  # Create target directory
  mkdir -p "$target"

  # Copy package.json
  local pkg_json="${SCRIPT_DIR}/package_jsons/${fw}/package.json"
  if [ -f "$pkg_json" ]; then
    cp "$pkg_json" "${target}/package.json"
    echo -e "    ${GREEN}✓ Copied package.json${NC}"
  fi

  # Extract node_modules
  local start_time=$SECONDS
  tar -xzf "$tarball" -C "$target"
  local elapsed=$((SECONDS - start_time))

  local size
  size=$(du -sh "${target}/node_modules" 2>/dev/null | cut -f1 || echo "unknown")

  echo -e "    ${GREEN}✓ Extracted node_modules (${size}, ${elapsed}s)${NC}"

  # Create .npmrc for offline use
  cat > "${target}/.npmrc" << 'NPMRC'
prefer-offline=true
legacy-peer-deps=true
NPMRC

  echo -e "    ${GREEN}✓ Created .npmrc (prefer-offline mode)${NC}"
  echo ""
}

main() {
  print_header
  check_deps

  if [ $# -lt 2 ]; then
    print_usage
    exit 1
  fi

  local framework="$1"
  local target="$2"

  if [ "$framework" = "all" ]; then
    echo -e "${BOLD}Installing all frameworks...${NC}"
    echo ""
    local success=0
    local failed=0
    for fw in "${FRAMEWORKS[@]}"; do
      if install_framework "$fw" "${target}/${fw}"; then
        ((success++))
      else
        ((failed++))
      fi
    done
    echo -e "${BOLD}════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Success: ${success}${NC}"
    if [ $failed -gt 0 ]; then
      echo -e "${RED}  ✗ Failed:  ${failed}${NC}"
    fi
  else
    # Validate framework name
    local valid=false
    for fw in "${FRAMEWORKS[@]}"; do
      if [ "$fw" = "$framework" ]; then
        valid=true
        break
      fi
    done

    if [ "$valid" = false ]; then
      echo -e "${RED}Error: Unknown framework '${framework}'${NC}"
      echo ""
      print_usage
      exit 1
    fi

    install_framework "$framework" "$target"
  fi

  echo -e "${BOLD}${GREEN}Done! Your offline packages are ready.${NC}"
  echo ""
  echo -e "${YELLOW}Tip: Run 'npm install --prefer-offline --legacy-peer-deps'${NC}"
  echo -e "${YELLOW}     inside your project if you need to resolve lockfiles.${NC}"
  echo ""
}

main "$@"
