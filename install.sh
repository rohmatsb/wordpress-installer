#!/bin/bash

# Function to check if Docker is installed
install_docker() {
  if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install Docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    if ! sudo docker run hello-world > /dev/null 2>&1; then
      echo "Docker installation failed. Exiting..."
      exit 1
    fi
    echo "Docker successfully installed."
  else
    echo "Docker is already installed."
  fi
}

# Function to check if a port is already in use
check_port() {
  local port=$1
  if sudo lsof -i :$port > /dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

# Install Docker if not already installed
install_docker

# Prompt user for port number
while true; do
  read -p "Enter the port number to use for this WordPress site: " port
  if [[ ! $port =~ ^[0-9]+$ ]] || ((port < 1 || port > 65535)); then
    echo "Invalid port number. Please enter a number between 1 and 65535."
    continue
  fi

  if check_port $port; then
    echo "Port $port is available."
    break
  else
    echo "Port $port is already in use. Please choose another port."
  fi
done

# Define directory name based on the port
site_dir="wordpress_port_$port"
mkdir -p $site_dir
cd $site_dir

# Download the Docker Compose template
wget -O docker-compose.yml https://raw.githubusercontent.com/rohmatsb/wordpress-installer/main/docker-compose.yml

# Replace placeholders in docker-compose.yml
sed -i "s/DB_CONTAINER/wordpress_db_port_$port/" docker-compose.yml
sed -i "s/APP_CONTAINER/wordpress_app_port_$port/" docker-compose.yml
sed -i "s/NGINX_CONTAINER/wordpress_webserver_port_$port/" docker-compose.yml
sed -i "s/DB_VOLUME/db_data_port_$port/" docker-compose.yml
sed -i "s/APP_VOLUME/wp_data_port_$port/" docker-compose.yml
sed -i "s/PORT/$port/" docker-compose.yml

# Download configuration files
wget -O php.ini https://raw.githubusercontent.com/rohmatsb/wordpress-installer/main/php.ini
wget -O nginx.conf https://raw.githubusercontent.com/rohmatsb/wordpress-installer/main/nginx.conf

# Start Docker containers
docker compose up -d

# Verify if the containers are running
docker ps

# Script completion message
echo "WordPress site installed successfully on port $port with directory '$site_dir'."
