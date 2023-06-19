# Media server

## Containers:

-  **AdGuard Home** - DNS server with ad blocking
-  **Qbittorrent** - Torrent client
-  **Prowlarr** - Torrent indexer
-  **Radarr** - Movie indexer
-  **Sonarr** - TV and Anime indexer
-  **Bazarr** - Subtitle downloader

## How to use:

**_Script is designed for Linux systems. It requires bash to startup!_**

1. Create or use existing user for containers (**default**: _user which runs script_)
2. Clone this repository to your pc/server
3. Make **run.sh** script executable: `chmod +x run.sh`
4. Run **run.sh** script: `./run.sh` (or `bash run.sh`)<br> **_Do not run the script as root!_**<br> If you run the script it will use root as a user for containers!<br> Script will ask you for some information. Please, read it carefully!
5. Wait for script to finish!
6. Enjoy! :)
