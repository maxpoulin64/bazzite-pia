#!/bin/bash
set -eu
REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if [ $# -lt 2 ]; then
    echo "Usage: $(basename "$0") <pia_installer> <installer_tmp>"
    echo
    echo "  pia_installer   Path to the original pia-linux.run script"
    echo "  installer_tmp   Path to store the unpacked installer"
    exit 1
fi

PIA_INSTALLER="$1"
INSTALLER_TMP="$2"

if test -e "$INSTALLER_TMP"
then
	echo "=> Removing previous installer files"
	rm -rf "$INSTALLER_TMP"
fi

echo "=> Extracting PIA"
bash "$PIA_INSTALLER" --noexec --target "$INSTALLER_TMP"

echo "=> Set up SELinux Context"
sudo semanage fcontext -a -t bin_t -s system_u "/opt/piavpn/bin/.*"
sudo semanage fcontext -a -t lib_t -s system_u "/opt/piavpn/lib/.*"

if not command -v patch >/dev/null 2>&1
then
	echo "=> Install patch utility from Homebrew"
	brew install gpatch
fi

echo "=> Patching installer for Bazzite"
patch -d "$INSTALLER_TMP" < "$REPO_ROOT/installer.patch"

echo "=> Running patched installer"
bash "$INSTALLER_TMP/install.sh"

echo "=> Reloading SELinux contexts"
sudo restorecon -RFv /opt/piavpn/bin/

echo "=> All done!"
