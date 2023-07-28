#!/bin/bash

function clone() {
	local repo=$(getRepoName $1)
	
	if [ -d $PWD/$repo ]
	then
		echo "$repo already cloned"
		return
	fi
	
	echo "cloning repo $repo"
	for value in {1..25}
	do
		echo "attempt number: $value"
		git clone $1
		if [ $? -eq 0 ]
		then
			return
		fi
	done
}

function getRepoName() {
	readarray -d / -t repoarr <<< $1
	local index=$((${#repoarr[@]} -1))
	local repo=${repoarr[$index]}
	local repoName=$(echo $repo | cut -d '.' -f 1)
	echo $repoName
}

xcberrors="https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git"
waylandprotocols="https://gitlab.freedesktop.org/wayland/wayland-protocols.git"
liftoff="https://gitlab.freedesktop.org/emersion/libliftoff.git"
hyprland="https://github.com/hyprwm/Hyprland.git"
sndio="https://caoua.org/git/sndio"
Waybar="https://github.com/Alexays/Waybar.git"

#disabling ipv6 seems to help with network timeouts
sudo nmcli connection modify "Wired connection 1" ipv6.method "disabled"
sudo nmcli connection up "Wired connection 1"

#network optimizations
echo 'max_parallel_downloads=20' | sudo tee -a /etc/dnf/dnf.conf
echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
echo 'retries=25' | sudo tee -a /etc/dnf/dnf.conf
echo '147.75.198.156 gitlab.freedesktop.org' | sudo tee -a /etc/hosts
echo '131.252.210.161 anongit.freedesktop.org' | sudo tee -a /etc/hosts
echo '140.82.113.4 github.com' | sudo tee -a /etc/hosts
echo '185.82.219.62 caoua.org' | sudo tee -a /etc/hosts

mkdir Source && cd $_

#install build tools & other apps
sudo dnf install -y git ninja-build cmake meson gcc-c++ m4 strace neovim wofi lshw htop jetbrains-mono-fonts-all chromium

#install xcb-errors dependencies
sudo dnf install -y dh-autoreconf xorg-x11-util-macros xcb-proto libxcb-devel

clone $xcberrors
cd $(getRepoName $xcberrors)
git submodule update --init
./autogen.sh
make && sudo make install
sudo cp /usr/local/lib/pkgconfig/xcb-errors.pc /usr/lib64/pkgconfig/
sudo ln -s /usr/local/lib/libxcb-errors.so.0.0.0 /usr/lib64/libxcb-errors.so.0
cd ..

#install hyprland dependencies
sudo dnf install -y libX11-devel pixman-devel wayland-protocols-devel cairo-devel pango-devel wayland-devel libdrm-devel \
libxkbcommon-devel libinput-devel libudev-devel mesa-libEGL-devel mesa-libgbm-devel vulkan-loader-devel systemd-devel \
libseat-devel hwdata-devel libdisplay-info-devel libinput-devel xorg-x11-server-Xwayland-devel xcb-util-renderutil-devel \
xcb-util-devel xcb-util-wm-devel xcb-util-image-devel libwayland-server udis86-devel wlroots-devel glslang

clone $waylandprotocols
cd $(getRepoName $waylandprotocols)
meson setup build
ninja -C build
sudo ninja -C build install
cd ..

clone $hyprland
cd $(getRepoName $hyprland)/subprojects
clone $liftoff
cd ..
meson setup build
cd build
meson configure -Dwlroots:xcb-errors=enabled
cd ..
ninja -C build
sudo ninja -C build install
cd ..

#install sndio dependency
sudo dnf install -y alsa-lib-devel

clone $sndio
cd $(getRepoName $sndio)
./configure
make && sudo make install
MAJ=$(grep libsndio/Makefile -e "MAJ =" | cut -d = -f 2 | xargs)
MIN=$(grep libsndio/Makefile -e "MIN =" | cut -d = -f 2 | xargs)
sudo ln -s /usr/local/lib/libsndio.so.$MAJ.$MIN /usr/lib64/libsndio.so.$MAJ
cd ..

#install waybar dependencies
sudo dnf install -y gtkmm3.0-devel jsoncpp-devel libsigc++20-devel fmt-devel gobject-introspection-devel catch2-devel \
iniparser-devel date-devel spdlog-devel libdbusmenu-gtk3-devel libnl3-devel upower-devel playerctl-devel libevdev-devel \
libmpdclient-devel wireplumber-devel pipewire-jack-audio-connection-kit-devel gtk-layer-shell-devel fftw-devel \
pulseaudio-libs-devel SDL2-devel SAASound-devel portaudio-devel ncurses-devel cava scdoc clang-tools-extra

clone $Waybar
cd $(getRepoName $Waybar)
meson build
cd build
meson configure -Dexperimental=true
cd ..
ninja -C build
sudo ninja -C build install
sudo cp build/subprojects/cava-*/libcava.so /usr/lib64/
cd ../..

cp -r /vagrant/configs/* /home/vagrant/.config/
sudo chown -R vagrant:vagrant Source/ .config/

sudo sed -i 's/chromium-browser/& --enable-features=UseOzonePlatform --ozone-platform=wayland/' /usr/share/applications/chromium-browser.desktop

sudo sed -i '$d' /var/lib/sddm/state.conf
echo 'Session=/usr/local/share/wayland-sessions/hyprland.desktop' | sudo tee -a /var/lib/sddm/state.conf

#cleanup hosts file for github.com, caoua.org, and *.freedesktop.org
for i in {1..4}
do
	sudo sed -i '$d' /etc/hosts
done
