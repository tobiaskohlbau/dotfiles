#!/bin/bash
set -e

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
	    --no-install-recomends

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

    apt-get autoremove
    apt-get autoclean
    apt-get clean
}

setup_sudo() {
    adduser "$USERNAME" sudo

    gpasswd -a "$USERNAME" systemd-journal
    gpasswd -a "$USERNAME" systemd-network

    mkdir -p "/home/$USERNAME/Downloads"
    echo -e "\n# tmpfs for downloads\ntmpfs\t/home/${USERNAME}/Downloads\ttmpfs\tnodev,nosuid,size=2G\t0\t0" >> /etc/fstab
}

usage() {
    echo "Usage: "
}

main() {
    local cmd=$1

    if [[ -z "$cmd" ]]; then
	#usage
	exit 1
    fi

    if [[ $cmd == "sources" ]]; then
	check_is_sudo

	setup_sources

	base
    fi
}
