#!/bin/bash
set -e

USERNAME=$(find /home/* -maxdepth 0 -printf "%f" -type d)

check_is_sudo() {
    if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit
    fi
}

setup_sources() {
    apt-get update
    apt-get install -y \
	    apt-transport-https \
	    --no-install-recommends

    cat <<-EOF > /etc/apt/sources.list
    deb http://httpredir.debian.org/debian stretch main contrib non-free
    deb-src http://httpredir.debian.org/debian/ stretch main contrib non-free

    deb http://httpredir.debian.org/debian/ stretch-updates main contrib non-free
    deb-src http://httpredir.debian.org/debian/ stretch-updates main contrib non-free

    deb http://security.debian.org/ stretch/updates main contrib non-free
    deb-src http://security.debian.org/ stretch/updates main contrib non-free

    deb http://httpredir.debian.org/debian experimental main contrib non-free
    deb-src http://httpredir.debian.org/debian experimental main contrib non-free

    deb http://ppa.launchpad.net/git-core/ppa/ubuntu wily main
    deb-src http://ppa.launchpad.net/git-core/ppa/ubuntu wily main

    deb http://ppa.launchpad.net/neovim-ppa/unstable/ubuntu wily main
    deb-src http://ppa.launchpad.net/neovim-ppa/unstable/ubuntu wily main
EOF

    cat <<-EOF > /etc/apt/sources.list.d/docker.list
    deb https://apt.dockerproject.org/repo debian-stretch main
    deb https://apt.dockerproject.org/repo debian-stretch testing
    deb https://apt.dockerproject.org/repo debian-stretch experimental
EOF

    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys E1DD270288B4E6030699E45FA1715D88E1DF1F24
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 9DBB0BE9366964F134855E2255F96FCF8231B6DD
    apt-key adv --keyserver pool.sks-keyservers.net --recv-keys CD4E8809

    mkdir -p /etc/apt/apt.conf.d
    echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/99translations
}

base() {
    apt-get update
    apt-get -y upgrade

    apt-get install -y \
	    adduser \
	    alsa-utils \
	    automake \
	    bash-completion \
	    ca-certificates \
	    curl \
	    gcc \
	    git \
	    grep \
	    make \
	    mount \
	    network-manager \
	    rxvt-unicode-256color \
	    ssh \
	    sudo \
	    --no-install-recommends

    setup_sudo

    apt-get autoremove -y
    apt-get autoclean -y
    apt-get clean -y

    install_docker
}

setup_sudo() {
    adduser "$USERNAME" sudo

    gpasswd -a "$USERNAME" systemd-journal
    gpasswd -a "$USERNAME" systemd-network

    mkdir -p "/home/$USERNAME/Downloads"
    echo -e "\n# tmpfs for downloads\ntmpfs\t/home/${USERNAME}/Downloads\ttmpfs\tnodev,nosuid,size=2G\t0\t0" >> /etc/fstab
}

install_docker() {
	sudo groupadd -f docker
	sudo gpasswd -a "$USERNAME" docker

	curl -sSL https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz | tar -xvz \
		-C /usr/local/bin --strip-components 1
	chmod +x /usr/local/bin/docker*

	curl -sSL https://raw.githubusercontent.com/tobiaskohlbau/dotfiles/debian/etc/systemd/system/docker.service > /etc/systemd/system/docker.service
	curl -sSL https://raw.githubusercontent.com/tobiaskohlbau/dotfiles/debian/etc/systemd/system/docker.socket > /etc/systemd/system/docker.socket

	systemctl daemon-reload
	systemctl enable docker

}

install_graphics() {
    local system=$1

    if [[ -z "$system" ]]; then
        echo "You need to specify wheter it's computer or laptop"
        exit 1
    fi

    local pkgs="linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') nvidia-driver"

    if [[ $system == "laptop" ]]; then
        local pkgs="xorg xserver-xorg xserver-xorg-video-intel"
    fi

    apt-get install -y $pkgs --no-install-recommends
}

install_wmapps() {
    local pkgs="feh i3 i3lock i3status scrot slim neovim emacs24"

    apt-get install -y $pkgs --no-install-recommends

    curl -sSL https://raw.githubusercontent.com/tobiaskohlbau/dotfiles/debian/etc/fonts/local.conf > /etc/fonts/local.conf

    echo "Fonts file setup successfully now run:"
    echo "  dpkg-reconfigure fontconfig-config"
    echo "with settings:"
    echo "  Authinter, Automatic, No."
    echo "Run:"
    echo "  dpkg-reconfigure fontconfig"
}

get_dotfiles() {
    (
    cd "/home/$USERNAME"

    git clone https://github.com/powerline/fonts.git "/home/$USERNAME/.fonts"

    git clone -b debian https://github.com/tobiaskohlbau/dotfiles.git "/home/$USERNAME/dotfiles"
    cd "/home/$USERNAME/dotfiles"

    make

    sudo systemctl enable i3lock

    cd "/home/$USERNAME"
    )
}

usage() {
    echo "Usage:"
    echo "  sources			- setup sources & install base pks"
    echo "  graphics {computer, laptop}	- install graphics driver"
    echo "  wm				- install window manager & desktop pks"
    echo "  dotfiles			- receive dotfiles"
}

main() {
    local cmd=$1

    if [[ -z "$cmd" ]]; then
	usage
	exit 1
    fi

    if [[ $cmd == "sources" ]]; then
	check_is_sudo

	setup_sources

	base
    elif [[ $cmd == "graphics" ]]; then
        check_is_sudo

        install_graphics "$2"
    elif [[ $cmd == "wm" ]]; then
        check_is_sudo

        install_wmapps
    elif [[ $cmd == "dotfiles" ]]; then
        get_dotfiles
    fi
}

main "$@"
