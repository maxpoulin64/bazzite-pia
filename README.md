# Private Internet Access installer for Bazzite

This downloads and patches the official Private Internet Access installer so that it installs and runs mostly correctly on Bazzite and probably other Universal Blue distributions.

## One-liner Install

This will install the current version of PIA at the time of this writing, end to end.

```sh
curl https://raw.githubusercontent.com/maxpoulin64/bazzite-pia/refs/heads/main/curl.pipe.sh | sh
```

## Normal Installation

1. Clone this repository
   ```sh
   git clone https://github.com/maxpoulin64/bazzite-pia.git
   cd bazzite-pia
	```
2. Download the official PIA installer from https://www.privateinternetaccess.com/download
3. Run the patcher
   ```sh
   ./install.sh "path_to_pia-linux-xxxx.run" /tmp/piainstall
   ```
4. PIA should now be installed.
5. Log into the app
6. Open Settings -> Protocols, and select WireGuard. OpenVPN does **not** work.
7. Enjoy!

## Manual Installation

All this really does is manually unpack the .run file with the `--noexec --target /tmp/pia` argument to extract the self-unpacking installer without running its scripts. Then `installer.patch` is applied to the original `install.sh` script to modify some paths so they work on Bazzite. Fortunately that's really just patching `/usr/share`to the user's `~/.local/share` to store the .desktop file, and skipping dependency checks because the system is immutable

I also disabled the dependency check because it will otherwise try to install it with `yum` and fail because it's immutable. Currently the only dependency it's missing is `xterm`, which it uses for running the updaters. Those would fail anyway because we need to patch the installer, so who cares.

Lastly, we need to fix some SELinux contexts to the PIA daemon can actually run. It will otherwise just crash. The client will run but show a spinner forever. This is easy, we just need to mark the binaries as system binaries and the libraries as system libraries.

```sh
sudo semanage fcontext -a -t bin_t -s system_u "/opt/piavpn/bin/.*"
sudo semanage fcontext -a -t lib_t -s system_u "/opt/piavpn/lib/.*"
```

And we reapply the contexts after installation to fix them up:

```sh
sudo restorecon -RFv /opt/piavpn/
```

OpenVPN currently doesn't work, it probably needs additional SELinux contexts and capabilities to open the tuntap device. But the WireGuard protocol works just fine, and it runs much better anyway. If you need OpenVPN, you can just import the profiles into NetworkManager and skip the app entirely.

Contributions welcome is someone cares enough to fix it.
