#!/bin/bash

# Install paket yang dibutuhkan
sudo apt update
sudo apt install wget -y

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker (Latest)
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verifikasi berhasil install Docker
if sudo docker run hello-world > /dev/null 2>&1; then
  clear
  echo "Docker sukses terinstall! Melanjutkan..."
  sleep 3
else
  clear
  echo "Docker gagal berjalan! Menghentikan..."
  sleep 3
  exit 1
fi

# Buat folder wordpress dan cd ke wordpress
mkdir wordpress
cd wordpress

# Dapatkan file docker compose
wget https://raw.githubusercontent.com/rohmatsb/wordpress-installer/main/docker-compose.yml

# Dapatkan file nginx.conf
wget https://raw.githubusercontent.com/rohmatsb/wordpress-installer/main/nginx.conf

# Dapatkan file php.ini
wget https://raw.githubusercontent.com/rohmatsb/wordpress-installer/main/php.ini

# Compose docker
docker compose up -d

# Cek docker berjalan
docker ps

# Jeda untuk melihat hasil docker ps
sleep 5

# Script telah selesai berjalan
clear
echo "Instalasi wordpress selesai!"
