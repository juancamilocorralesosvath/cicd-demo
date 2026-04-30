#!/bin/bash
apt-get update
apt-get install -y gettext-base curl apt-transport-https ca-certificates gnupg2 software-properties-common wget
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian bookworm stable"
apt-get update
apt-get install -y docker-ce-cli
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
