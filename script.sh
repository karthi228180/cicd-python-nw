#!/bin/bash

set -e 

echo "Devops environment setup"

echo "updating packages"

sudo apt-get update

echo "installing docker..."

sudo apt-get update

sudo apt-get install ca-certificates curl gnupg -y

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

apt-cache policy docker-ce

sudo apt-get install docker-ce -y

echo "docker installation completed"


echo "Installing java  for jenkins"

sudo apt-get update
sudo apt-get install fontconfig openjdk-21-jre -y
java -version


echo "Installing java completed"

echo "Installing jenkins "

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

sudo usermod -aG docker jenkins

echo "Installation of jenkins completed and added to docker group"
