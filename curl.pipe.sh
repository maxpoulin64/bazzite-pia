#!/bin/sh
set -e
repo=https://github.com/maxpoulin64/bazzite-pia.git
pia_installer=https://installers.privateinternetaccess.com/download/pia-linux-3.7.2-08420.run
tmp_repo=/tmp/bazzite-pia

cleanup() {
    rm -rf "$tmp_repo"
}

function install_pia {
	trap cleanup EXIT

	if test -e "$tmp_repo"
	then
		echo "=> Removing previous temp directory"
		rm -rf "$tmp_repo"
	fi

	git clone "$repo" "$tmp_repo"
	cd "$tmp_repo"
	mkdir tmp
	curl -Lo tmp/pia-linux.run "$pia_installer"
	./install.sh tmp/pia-linux.run tmp/pia-linux
}

install_pia
