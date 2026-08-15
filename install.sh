#!/usr/bin/env bash
#
# Althyn-x11 installer
#
# Builds HomeScreen, StatusBar, and WelcomeScreen (release mode) and installs:
#   /usr/local/bin/althyn            session launcher (openbox + feh + picom + panels)
#   /usr/bin/vamora-homescreen
#   /usr/bin/vamora-statusbar
#   /usr/bin/vamora-welcome
#   /usr/share/xsessions/vamora.desktop   X11 session entry for display managers
#   /etc/VamoraSys/wallpapers/*           wallpapers, copied from branding/wallpapers/
#
# NOTE: this X11 build is a compat track. The prioritized target is Althyn (Wayland):
#       https://github.com/TheVamoraProject/Althyn/
#
# Assumes a Debian/Ubuntu-based system (uses apt). If you're on another distro,
# skip --deps and install the equivalent packages yourself, see README for the list.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_DEPS=0

for arg in "$@"; do
  case "$arg" in
    --skip-deps) SKIP_DEPS=1 ;;
    -h|--help)
      echo "Usage: sudo ./install.sh [--skip-deps]"
      echo "  --skip-deps   don't apt-install system dependencies, just build + install"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to write to /usr, /usr/local, and /etc — run it with sudo." >&2
  exit 1
fi

# Building as root pollutes cargo's cache for the real user; build as the
# invoking (non-root) user when run via sudo, install as root.
BUILD_USER="${SUDO_USER:-$(id -un)}"
run_as_build_user() {
  if [ "$BUILD_USER" != "root" ]; then
    sudo -u "$BUILD_USER" "$@"
  else
    "$@"
  fi
}

log() { printf '\n==> %s\n' "$1"; }

# ---------------------------------------------------------------------------
# 1. System dependencies
# ---------------------------------------------------------------------------
if [ "$SKIP_DEPS" -eq 0 ]; then
  if command -v apt-get >/dev/null 2>&1; then
    log "Installing system dependencies (apt)"
    apt-get update
    apt-get install -y \
      build-essential pkg-config curl \
      qt6-base-dev qt6-declarative-dev qml6-module-qtquick-controls2 \
      qt6-5compat-dev libxcb1-dev libx11-dev \
      openbox feh picom
  else
    echo "No apt-get found — skipping system dependency install." >&2
    echo "Install the Qt6 (Core/Gui/Qml/Quick/QuickControls2 + Qt5Compat), a C++" >&2
    echo "toolchain, pkg-config, openbox, feh, and picom for your distro, then" >&2
    echo "re-run with --skip-deps." >&2
  fi

  if ! run_as_build_user command -v cargo >/dev/null 2>&1; then
    echo "cargo/rustup not found for user '$BUILD_USER'." >&2
    echo "Install Rust (https://rustup.rs) as that user, then re-run this script." >&2
    exit 1
  fi
else
  log "Skipping system dependency install (--skip-deps)"
fi

# ---------------------------------------------------------------------------
# 2. Build + install each component
# ---------------------------------------------------------------------------
# args: <source dir relative to repo root> <cargo package/binary name> <install path>
build_and_install() {
  local src_dir="$1" bin_name="$2" dest="$3"
  log "Building $bin_name ($src_dir)"
  run_as_build_user bash -c "cd '$SCRIPT_DIR/$src_dir' && cargo build --release"
  install -Dm755 "$SCRIPT_DIR/$src_dir/target/release/$bin_name" "$dest"
  echo "  installed -> $dest"
}

build_and_install "HomeScreen"           "vamora-homescreen" "/usr/bin/vamora-homescreen"
build_and_install "StatusBar"            "vamora-statusbar"  "/usr/bin/vamora-statusbar"
build_and_install "WelcomeScreen/Live"   "vamora-welcome"    "/usr/bin/vamora-welcome"

# ---------------------------------------------------------------------------
# 3. Session launcher: /usr/local/bin/althyn
# ---------------------------------------------------------------------------
log "Installing session launcher -> /usr/local/bin/althyn"
install -d /usr/local/bin
cat > /usr/local/bin/althyn <<'EOF'
#!/bin/sh

# Window manager first — everything else
# depends on it being up, so it can't be the last thing exec'd.
openbox-session &
WM_PID=$!

# Wallpaper
feh --bg-fill /etc/VamoraSys/wallpapers/background.jpg &

# Status bar
vamora-homescreen &
picom &
vamora-statusbar &
vamora-welcome &

# Session ends when the WM exits
wait "$WM_PID"
EOF
chmod 755 /usr/local/bin/althyn

# ---------------------------------------------------------------------------
# 4. X11 session entry for display managers: /usr/share/xsessions/vamora.desktop
# ---------------------------------------------------------------------------
log "Installing xsession entry -> /usr/share/xsessions/vamora.desktop"
install -d /usr/share/xsessions
cat > /usr/share/xsessions/vamora.desktop <<'EOF'
[Desktop Entry]
Name=Vamora Althyn
Comment=Althyn
Exec=/usr/local/bin/althyn
Type=Application
DesktopNames=Vamora
EOF

# ---------------------------------------------------------------------------
# 5. Wallpapers: branding/wallpapers/* -> /etc/VamoraSys/wallpapers/
# ---------------------------------------------------------------------------
log "Installing wallpapers -> /etc/VamoraSys/wallpapers/"
install -d /etc/VamoraSys/wallpapers
for f in "$SCRIPT_DIR"/branding/wallpapers/*; do
  [ -f "$f" ] || continue
  install -Dm644 "$f" "/etc/VamoraSys/wallpapers/$(basename "$f")"
  echo "  installed -> /etc/VamoraSys/wallpapers/$(basename "$f")"
done

log "Done. Log out and pick 'Vamora Althyn' from your display manager's session list."
