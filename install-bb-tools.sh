#!/bin/bash

sudo apt-get update && apt-get dist-upgrade -y

# install tools
sudo apt-get install -y sudo \
  git \
  screen \
  vim \
  aptitude \
  zsh \
  man \
  zip \
  net-tools \
  wget \
  ruby \
  socat  \
  golang \
  nmap \
  chromium-browser \
  pwgen \
  jq \
  tree

# create directories
directories=(files work bin)
for dir in ${directories[*]}; do
  mkdir -p "${HOME}/${dir}"
done


go get -u github.com/tomnomnom/assetfinder \
github.com/tomnomnom/waybackurls \
github.com/tomnomnom/meg \
github.com/tomnomnom/httprobe \
github.com/tomnomnom/gf \
github.com/tomnomnom/unfurl \
github.com/ffuf/ffuf \
github.com/michenriksen/aquatone \
github.com/lc/gau \
github.com/OJ/gobuster \
github.com/jaeles-project/gospider

