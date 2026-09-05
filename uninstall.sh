#!/usr/bin/env bash
#
# Althyn-x11 uninstaller — removes everything install.sh puts down.

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to remove things from /usr, /usr/local, and /etc — run it with sudo." >&2
  exit 1
fi

rm -fv \
  /usr/local/bin/althyn \
  /usr/bin/vamora-homescreen \
  /usr/bin/vamora-dock \
  /usr/bin/vamora-statusbar \
  /usr/bin/vamora-welcome \
  /usr/share/xsessions/vamora.desktop \
  /usr/local/bin/vamora-powermenu


echo "Done."
