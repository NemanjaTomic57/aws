#!/bin/bash -xeu

sudo apt update
sudo apt update
sudo apt install -y \
  nginx \
  curl \
  wget \
  ca-certificates \
  gnupg \
  unzip

curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o /tmp/aws.zip
unzip -q /tmp/aws.zip -d /tmp
/tmp/aws/install

rm -rf /tmp/aws /tmp/aws.zip

sudo systemctl enable --now nginx
