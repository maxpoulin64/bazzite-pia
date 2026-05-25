#!/bin/sh
set -e
repo=https://github.com/maxpoulin64/bazzite-pia.git
pia_installer=https://installers.privateinternetaccess.com/download/pia-linux-3.7.2-08420.run
tmp_repo=/tmp/bazzite-pia

function install-pia {
	git clone "$repo" "$tmp_repo"
	cd "$tmp_repo"
	mkdir tmp
	wget -O tmp/pia-linux.run "$pia_installer"
	./install.sh tmp/pia-linux.run tmp/pia-linux

	rm -r "$tmp_repo"
}

install-pia
