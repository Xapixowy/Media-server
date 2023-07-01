#!/bin/bash
network_name="media-server"
username=$(whoami)
uid=$(id -u)
gid=$(id -g)
default_path="/home/$username"

generate_env() {
   clear
   echo "##############################################################"
   echo "#  __  __          _ _                                       #"
   echo "# |  \/  | ___  __| (_) __ _   ___  ___ _ ____   _____ _ __  #"
   echo "# | |\/| |/ _ \/ _\` | |/ _\` | / __|/ _ \ '__\ \ / / _ \ '__| #"
   echo "# | |  | |  __/ (_| | | (_| | \__ \  __/ |   \ V /  __/ |    #"
   echo "# |_|  |_|\___|\__,_|_|\__,_| |___/\___|_|    \_/ \___|_|    #"
   echo "#                                                            #"
   echo "##############################################################"
   echo "                                              Author: Xapixowy"
   echo ""
   echo "0. Elevating permissions to root..."
   sudo echo "Permissions elevated!"
   echo ""
   echo "1. Checking if docker is installed..."
   if ! sudo docker --version >/dev/null 2>&1; then
      echo "Docker is not installed!"
      echo "Follow the documentation to install docker: https://docs.docker.com/get-docker/"
      exit 1
   fi
   echo "Docker is installed!"
   echo ""

   echo "2. Checking if docker-compose is installed..."
   if ! sudo docker-compose --version >/dev/null 2>&1; then
      echo "Docker-compose is not installed!"
      echo "Follow the documentation to install docker-compose: https://docs.docker.com/compose/install/"
      exit 1
   fi
   echo "Docker-compose is installed!"
   echo ""

   # check if containers exists
   echo "3. Checking if docker containers exists..."
   if sudo docker ps -a | grep -q "adguardhome"; then
      echo "Adguardhome container exists!"
      echo "Stopping and removing adguardhome container..."
      sudo docker stop adguardhome
      sudo docker rm adguardhome
   fi
   if sudo docker ps -a | grep -q "qbittorrent"; then
      echo "Qbittorrent container exists!"
      echo "Stopping and removing qbittorrent container..."
      sudo docker stop qbittorrent
      sudo docker rm qbittorrent
   fi
   if sudo docker ps -a | grep -q "prowlarr"; then
      echo "Prowlarr container exists!"
      echo "Stopping and removing prowlarr container..."
      sudo docker stop prowlarr
      sudo docker rm prowlarr
   fi
   if sudo docker ps -a | grep -q "radarr"; then
      echo "Radarr container exists!"
      echo "Stopping and removing radarr container..."
      sudo docker stop radarr
      sudo docker rm radarr
   fi
   if sudo docker ps -a | grep -q "sonarr"; then
      echo "Sonarr container exists!"
      echo "Stopping and removing sonarr container..."
      sudo docker stop sonarr
      sudo docker rm sonarr
   fi
   if sudo docker ps -a | grep -q "bazarr"; then
      echo "Bazarr container exists!"
      echo "Stopping and removing bazarr container..."
      sudo docker stop bazarr
      sudo docker rm bazarr
   fi
   echo "Containers does not exist!"
   echo ""

   echo "4. Checking if docker network exists..."
   if sudo docker network inspect "$network_name" >/dev/null 2>&1; then
      echo "Network $network_name already exists! Deleting..."
      sudo docker network rm "$network_name"
   fi
   echo "Network $network_name does not exist!"
   echo ""

   echo "5. Creating docker network..."
   echo "Creating network $network_name..."
   sudo docker network create -d bridge "$network_name" --subnet=169.0.0.0/28
   echo "Network created!"
   echo ""

   echo "6. Choosing config path..."
   echo "In this path, a new folder .docker-configs will be created if it does not exist"
   echo "If the folder already exists, it will be used"
   check_config_path() {
      echo "Suggested path: $default_path"
      read -p "Type a path for your config files: " config_path
      if [[ ! -d "$config_path" ]]; then
         echo "Path does not exist!"
         check_config_path
      fi
   }
   check_config_path
   echo "Path $config_path is correct!"
   echo ""

   echo "7. Choosing media path..."
   echo "In this path, a new folder @Media-server will be created if it does not exist"
   echo "If the folder already exists, it will be used"
   check_media_path() {
      read -p "Type a path for your media files: " media_path
      if [[ ! -d "$media_path" ]]; then
         echo "Path does not exist!"
         check_media_path
      fi
   }
   check_media_path
   echo "Path $media_path is correct!"
   clear

   echo "8. Extracting default config files..."
   echo "Do you want to extract default config files?"
   echo "If you choose no, you will have to configure the containers yourself"
   read -p "Extract default config files? [y/n]: " -n 1 -r
   echo ""
   if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Extracting default config files..."
      sudo mkdir -p "$config_path/.docker-configs"
      sudo tar -xzf docker-configs.tar.gz -C "$config_path/.docker-configs"
      echo "Default config files extracted!"
   else
      echo "Skipping extracting default config files..."
   fi
   echo ""

   echo "9. Summary"
   if sudo docker network inspect "$network_name" >/dev/null 2>&1; then
      echo "Network exists: true"
   else
      echo "Network exists: false"
   fi
   echo "Username: $username"
   echo "UID: $uid"
   echo "GID: $gid"
   echo "Config path: $config_path"
   echo "Media path: $media_path"
   read -p "Is everything correct? [y/n]: " -n 1 -r
   echo ""
   if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      clear
      generate_env
   fi
}
generate_env

echo "10. Generating .env file"
env_content="USERNAME=$username\nUID=$uid\nGID=$gid\nCONFIG_PATH=$config_path\nMEDIA_PATH=$media_path\nTIMEZONE=Europe/Warsaw"
echo -e "$env_content" > .env
echo ".env file was generated"
echo ""

echo "11. Creating docker containers"
sudo docker-compose up -d
echo "Containers created!"
echo ""

echo "12. Setting up permissions"
sudo chown -R "$uid":"$gid" "$config_path/.docker-configs"
sudo chown -R "$uid":"$gid" "$media_path/@Media-server"
echo "Permissions set!"
echo ""

echo "Press any key to continue..."
read -n 1 -s
clear
echo "##############################################################"
echo "#  __  __          _ _                                       #"
echo "# |  \/  | ___  __| (_) __ _   ___  ___ _ ____   _____ _ __  #"
echo "# | |\/| |/ _ \/ _\` | |/ _\` | / __|/ _ \ '__\ \ / / _ \ '__| #"
echo "# | |  | |  __/ (_| | | (_| | \__ \  __/ |   \ V /  __/ |    #"
echo "# |_|  |_|\___|\__,_|_|\__,_| |___/\___|_|    \_/ \___|_|    #"
echo "#                                                            #"
echo "##############################################################"
echo "                                              Author: Xapixowy"
echo ""
echo "All done!"
echo ""
echo "You can now access your services at:"
echo "- Aduardhome: http://localhost:8080"
echo "- Qbittorrent: http://localhost:8112"
echo "- Prowlarr: http://localhost:9696"
echo "- Radarr: http://localhost:7878"
echo "- Sonarr: http://localhost:8989"
echo "- Bazarr: http://localhost:6767"
echo ""
echo "Default credentials (only if you chose extracting default config files):"
echo "- Username: xapixowy"
echo "- Password: Password123!"
echo ""