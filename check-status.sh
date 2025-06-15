#!/bin/bash

# Author: Tafi 🇲🇦
# Check services status

DOMAIN="samir.aboazzam.shop"
IP=$(curl -s ifconfig.me)

echo "--- 🔍 SERVICES CHECK ---"
echo "IP: $IP"
echo

echo "[+] Checking SSH WebSocket (port 80)..."
systemctl is-active ws-server && echo "✅ SSH WS is running" || echo "❌ SSH WS is not running"

echo "[+] Checking Xray Service..."
systemctl is-active xray && echo "✅ Xray is running" || echo "❌ Xray is not running"

echo "[+] Checking UDPGW (badvpn)..."
screen -list | grep badvpn && echo "✅ UDPGW is running" || echo "❌ UDPGW is not running"

echo "[+] Testing WebSocket Response..."
curl -I -m 5 -s http://$DOMAIN:80 | grep "HTTP/" && echo "✅ WS reachable" || echo "❌ WS not reachable"

echo "[+] Testing TLS (443)..."
curl -I -m 5 -s https://$DOMAIN | grep "HTTP/" && echo "✅ TLS reachable" || echo "❌ TLS not reachable"

echo "--- ✅ Done ---"
