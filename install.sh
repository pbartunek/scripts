#!/bin/bash

user=$1

if [ -z $user ]; then
  echo "Usage $0 user_name"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  return 1
fi

apt-get update && apt-get dist-upgrade -y

# install tools
apt-get install -y sudo \
  git \
  screen \
  i3 \
  rofi \
  sakura \
  zsh \
  open-vm-tools \
  open-vm-tools-desktop \
  nautilus \
  xserver-xorg \
  xinit \
  maim \
  slop \
  zenity \
  man \
  zip \
  feh \
  net-tools \
  wget \
  slim \
  ruby \
  ruby-dev \
  zlib1g-dev \
  aptitude \
  vim \
  ipcalc \
  socat \
  golang \
  nmap \
  dnsutils \
  firefox-esr \
  chromium \
  gobuster \
  jq \
  xclip \
  dos2unix \
  grc \
  tmux \
  moreutils \
  crunch \
  flameshot \
  tree

# docker
apt-get install -y \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common \
     moreutils

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

apt-get update && apt-get install -y docker-ce
update-rc.d docker defaults

# powershell
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list'
apt-get update && apt-get install -y powershell

# enable user namespaces

echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/00-local-userns.conf
service procps restart

# add $user to groups
usermod -G docker,sudo $user

# create directories
directories=(bin files work)
for dir in ${directories[*]}; do
  mkdir -p /home/$user/$dir
done

chown -R $user:$user /home/$user

