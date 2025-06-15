# Tafi Panel - SSH WebSocket & UDP Setup Scripts

This project contains scripts to manage SSH WebSocket servers, UDP gateways, and Vmess/Vless configurations.  
It provides an easy-to-use control panel for starting, stopping, and restarting services on your VPS.

## Features

- Create and manage SSH WebSocket accounts  
- Support for UDP Gateway configuration (for HTTP Custom UDP)  
- Support for Vmess and Vless configurations  
- Service control (start/stop/restart) for each component individually  
- Simple Bash scripts for easy setup and management

## Requirements

- Ubuntu 20.04 or similar Linux distribution  
- Root or sudo access to the VPS  
- Basic knowledge of Linux commands and terminal usage  
- Installed dependencies: git, nginx, docker (optional)

## Usage

1. Clone or download the repository  
2. Give execute permissions to the scripts:
   ```bash
   chmod +x panel.sh setup.sh
