#!/bin/bash

# Update package index
sudo apt-get update

# Install packages to allow apt to use a repository over HTTPS
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package index again
sudo apt-get update

# Install Docker CE
sudo apt-get install -y docker-ce

# Add the current user to the docker group to run docker commands without sudo
sudo usermod -aG docker $USER

# Install Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
sudo curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Give Docker Compose executable permissions
sudo chmod +x /usr/local/bin/docker-compose

# Verify the installation of Docker and Docker Compose
docker --version
docker-compose --version

echo "Docker and Docker Compose installation complete. Please log out and log back in to apply group changes."
