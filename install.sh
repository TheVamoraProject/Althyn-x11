#!/usr/bin/env bash
#
# Althyn-x11 installer — run this as your normal user, NOT with sudo.
# It'll prompt for your password (via sudo) only for the parts that need root.
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
# use --skip-deps and install the equivalent packages yourself, see README for the list.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_DEPS=0

for arg in "$@"; do
  case "$arg" in
    --skip-deps) SKIP_DEPS=1 ;;
    -h|--help)
      echo "Usage: ./install.sh [--skip-deps]"
      echo "  --skip-deps   don't apt-install system dependencies, just build + install"
      echo "Run this as your normal user, not with sudo — it'll ask for your"
      echo "password itself for the parts that need root."
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

if [ "$(id -u)" -eq 0 ]; then
  echo "Don't run this with sudo — run it as your normal user." >&2
  echo "It'll ask for your password itself when it needs root." >&2
  exit 1
fi

log() { printf '\n==> %s\n' "$1"; }

# Ask for the sudo password once up front so it doesn't interrupt mid-build.
sudo -v

# ---------------------------------------------------------------------------
# 1. System dependencies
# ---------------------------------------------------------------------------
if [ "$SKIP_DEPS" -eq 0 ]; then
  if command -v apt-get >/dev/null 2>&1; then
    log "Installing system dependencies (apt)"
    sudo apt-get update
    # Installed one-by-one instead of a single apt-get call: Qt6 QML module
    # package names drift between Debian/Ubuntu releases, so one unknown
    # package name shouldn't abort the whole install. Anything that fails
    # to install is reported at the end instead of killing the script.
    DEP_PACKAGES=(
      build-essential pkg-config curl
      qt6-base-dev qt6-declarative-dev qt6-5compat-dev
      qml6-module-qtquick-controls qml6-module-qtquick-templates
      qml6-module-qtquick-layouts qml6-module-qtquick-window
      qml6-module-qtqml-workerscript
      libxcb1-dev libx11-dev
      openbox feh picom
    )
    FAILED_PACKAGES=()
    for pkg in "${DEP_PACKAGES[@]}"; do
      if ! sudo apt-get install -y "$pkg"; then
        FAILED_PACKAGES+=("$pkg")
      fi
    done
    if [ "${#FAILED_PACKAGES[@]}" -gt 0 ]; then
      echo "Warning: couldn't install: ${FAILED_PACKAGES[*]}" >&2
      echo "Package names drift between Debian/Ubuntu versions — check" >&2
      echo "'apt-cache search qtquick' / 'apt-cache search qt6' for the" >&2
      echo "equivalents on your release and install them by hand, then" >&2
      echo "re-run this script (with --skip-deps once deps are sorted)." >&2
    fi
  else
    echo "No apt-get found — skipping system dependency install." >&2
    echo "Install the Qt6 (Core/Gui/Qml/Quick/QuickControls2 + Qt5Compat), a C++" >&2
    echo "toolchain, pkg-config, openbox, feh, and picom for your distro, then" >&2
    echo "re-run with --skip-deps." >&2
  fi

  if ! command -v cargo >/dev/null 2>&1; then
    echo "cargo/rustup not found." >&2
    echo "Install Rust (https://rustup.rs), then re-run this script." >&2
    exit 1
  fi
else
  log "Skipping system dependency install (--skip-deps)"
fi

# ---------------------------------------------------------------------------
# 2. Build (as you, no sudo) + install (needs sudo) each component
# ---------------------------------------------------------------------------
# args: <source dir relative to repo root> <cargo package/binary name> <install path>
build_and_install() {
  local src_dir="$1" bin_name="$2" dest="$3"
  log "Building $bin_name ($src_dir)"
  (cd "$SCRIPT_DIR/$src_dir" && cargo build --release)
  sudo install -Dm755 "$SCRIPT_DIR/$src_dir/target/release/$bin_name" "$dest"
  echo "  installed -> $dest"
}

build_and_install "HomeScreen"           "vamora-homescreen" "/usr/bin/vamora-homescreen"
build_and_install "StatusBar"            "vamora-statusbar"  "/usr/bin/vamora-statusbar"
build_and_install "WelcomeScreen/Live"   "vamora-welcome"    "/usr/bin/vamora-welcome"

# ---------------------------------------------------------------------------
# 3. Session launcher: /usr/local/bin/althyn
# ---------------------------------------------------------------------------
log "Installing session launcher -> /usr/local/bin/althyn"
sudo install -d /usr/local/bin
sudo tee /usr/local/bin/althyn > /dev/null <<'EOF'
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
sudo chmod 755 /usr/local/bin/althyn

# ---------------------------------------------------------------------------
# 4. X11 session entry for display managers: /usr/share/xsessions/vamora.desktop
# ---------------------------------------------------------------------------
log "Installing xsession entry -> /usr/share/xsessions/vamora.desktop"
sudo install -d /usr/share/xsessions
sudo tee /usr/share/xsessions/vamora.desktop > /dev/null <<'EOF'
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
sudo install -d /etc/VamoraSys/wallpapers
for f in "$SCRIPT_DIR"/branding/wallpapers/*; do
  [ -f "$f" ] || continue
  sudo install -Dm644 "$f" "/etc/VamoraSys/wallpapers/$(basename "$f")"
  echo "  installed -> /etc/VamoraSys/wallpapers/$(basename "$f")"
done

log "Done. Log out and pick 'Vamora Althyn' from your display manager's session list."