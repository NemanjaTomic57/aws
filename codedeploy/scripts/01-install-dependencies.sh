#!/bin/bash -xeu

sudo apt update
sudo apt update
sudo apt install -y \
  awscli \
  nginx \
  curl \
  wget \
  ca-certificates \
  gnupg \
  unzip

sudo systemctl enable --now nginx
