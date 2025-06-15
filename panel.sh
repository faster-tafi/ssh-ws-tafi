#!/bin/bash

# Author: Tafi 🇲🇦
# Updated SSH/Xray Control Panel with Manage Services options

DOMAIN="samir.aboazzam.shop"
UUID_FILE="/etc/xray/config.json"

function show_menu() {
  clear
  echo "=========== 🛠 TAFI SERVER PANEL ==========="
  echo "1. Show System Info"
  echo "2. Show Current UUID"
  echo "3. Generate New UUID"
  echo "4. Restart All Services"
  echo "5. Show Services Status"
  echo "6. Manage Services (Start/Stop/Restart)"
  echo "0. Exit"
  echo "=========================================="
  echo -n "Choose: "
}

function system_info() {
  echo "--- SYSTEM INFO ---"
  echo "Domain        : $DOMAIN"
  echo "IP Address    : $(curl -s ifconfig.me)"
  echo "Memory Used   : $(free -m | grep Mem | awk '{print $3 " MB / " $2 " MB"}')"
  echo "Uptime        : $(uptime -p)"
  echo "SSH WS Port   : 80"
  echo "UDPGW Port    : 7300"
  echo "VLESS (TLS)   : wss://$DOMAIN/vless"
  echo "VMESS (NoTLS) : ws://$DOMAIN:2086/vmess"
  echo "-------------------"
  read -p "Press enter to return..."
}

function current_uuid() {
  echo "--- CURRENT UUID ---"
  grep -oP '"id":\s*"\K[^"]+' $UUID_FILE
  read -p "Press enter to return..."
}

function generate_uuid() {
  NEW_UUID=$(cat /proc/sys/kernel/random/uuid)
  sed -i "s/\"id\": \".*\"/\"id\": \"$NEW_UUID\"/g" $UUID_FILE
  systemctl restart xray
  echo "--- NEW UUID GENERATED ---"
  echo "New UUID: $NEW_UUID"
  read -p "Press enter to return..."
}

function restart_all() {
  systemctl restart ws-server
  systemctl restart xray
  screen -S badvpn -X quit
  screen -dmS badvpn /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
  echo "✅ All services restarted."
  read -p "Press enter to return..."
}

function service_status() {
  echo "--- SERVICES STATUS ---"
  systemctl is-active ws-server && echo "SSH WebSocket: ✅ Running" || echo "SSH WebSocket: ❌ Stopped"
  systemctl is-active xray && echo "Xray (Vmess/Vless): ✅ Running" || echo "Xray: ❌ Stopped"
  screen -list | grep badvpn && echo "UDPGW: ✅ Running" || echo "UDPGW: ❌ Stopped"
  echo "------------------------"
  read -p "Press enter to return..."
}

function manage_services_menu() {
  while true; do
    clear
    echo "====== Manage Services ======"
    echo "1) Start Service"
    echo "2) Stop Service"
    echo "3) Restart Service"
    echo "0) Back to Main Menu"
    echo "============================="
    echo -n "Choose an option: "
    read action

    if [[ "$action" == "0" ]]; then
      break
    fi

    case $action in
      1) service_action="start" ;;
      2) service_action="stop" ;;
      3) service_action="restart" ;;
      *) echo "Invalid option. Press enter to try again." ; read ; continue ;;
    esac

    while true; do
      clear
      echo "--- Select Service ---"
      echo "1) SSH WebSocket"
      echo "2) Xray (VMESS/VLESS)"
      echo "3) UDPGW (badvpn)"
      echo "0) Back"
      echo "---------------------"
      echo -n "Choose service: "
      read svc_choice

      if [[ "$svc_choice" == "0" ]]; then
        break
      fi

      case $svc_choice in
        1) svc_name="ws-server" ;;
        2) svc_name="xray" ;;
        3) svc_name="badvpn" ;;
        *) echo "Invalid service. Press enter to try again." ; read ; continue ;;
      esac

      # Execute service action
      if [[ "$svc_name" == "badvpn" ]]; then
        # badvpn is run inside screen session
        if [[ "$service_action" == "start" ]]; then
          screen -dmS badvpn /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
          echo "Started UDPGW (badvpn)."
        elif [[ "$service_action" == "stop" ]]; then
          screen -S badvpn -X quit
          echo "Stopped UDPGW (badvpn)."
        elif [[ "$service_action" == "restart" ]]; then
          screen -S badvpn -X quit
          screen -dmS badvpn /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
          echo "Restarted UDPGW (badvpn)."
        fi
      else
        systemctl $service_action $svc_name
        echo "${service_action^}ed $svc_name."
      fi
      read -p "Press enter to continue..."
      break
    done
  done
}

# MAIN
while true; do
  show_menu
  read choice
  case $choice in
    1) system_info ;;
    2) current_uuid ;;
    3) generate_uuid ;;
    4) restart_all ;;
    5) service_status ;;
    6) manage_services_menu ;;
    0) exit 0 ;;
    *) echo "Invalid option." ;;
  esac
done
