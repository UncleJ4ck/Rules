#!/bin/bash

set -e

if ! grep -q "$(hostname)" /etc/hosts; then
    sed -i 's/^\(127\.0\.0\.1\s+localhost\)\(.*\)$/\1 '"$(hostname)"'\2/' /etc/hosts
fi

apt-get update
apt-get install -y apt-transport-https ca-certificates curl jq net-tools vim git gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

ARCHITECTURE=$(dpkg --print-architecture)
DEBIAN_CODENAME=$(source /etc/os-release && echo $VERSION_CODENAME)
echo "deb [arch=$ARCHITECTURE] https://download.docker.com/linux/debian $DEBIAN_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker
systemctl start docker
usermod -aG docker $USER

OS_ARCH="$(uname -s)-$(uname -m)"
DOCKER_COMPOSE_VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$OS_ARCH" -o /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose
