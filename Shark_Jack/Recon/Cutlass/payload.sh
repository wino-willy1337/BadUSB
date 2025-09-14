#!/bin/bash
#
# TITLE:        Cutlass v3.0 - The Final Polish
# AUTHOR:       wino_willy and William Shire III
# VERSION:      3.0
# DESCRIPTION:  A final, hardened payload for the Hak5 Shark Jack. It
#               prioritizes reliability and clear, actionable reporting.
#
# LED SETUP:    Solid Magenta - Acquiring IP.
# LED ATTACK:   Single Yellow Blink - Scan active.
# LED FAIL:     Slow Red Blink - Failed to acquire IP.
# LED FINISH:   Green Success Pattern - Mission complete.
#
#################################################################

# --- SETUP ---
LOOT_DIR=/root/loot/cutlass_scans
mkdir -p $LOOT_DIR

TIMESTAMP=$(date "+%Y-%m-%d_%H%M%S")
REPORT_FILE="$LOOT_DIR/scan_${TIMESTAMP}.txt"
DEBUG_LOG="/tmp/payload-debug.log"
HOSTS_IP_FILE="/tmp/hosts.ip"

# Initialize logs
echo "CUTLASS v3.0 PAYLOAD INITIALIZED AT $(date)" > $DEBUG_LOG

# --- NETWORK ACQUISITION ---
LED SETUP
echo "[*] Setting NETMODE to DHCP_CLIENT" >> $DEBUG_LOG
NETMODE DHCP_CLIENT

echo "[*] Awaiting DHCP lease (max 25s)..." >> $DEBUG_LOG
i=0
while ! ifconfig eth0 | grep -q "inet addr"; do
    if [ $i -ge 25 ]; then
        echo "[!] TIMEOUT after 25s. No DHCP lease." >> $DEBUG_LOG
        LED FAIL
        exit 1
    fi
    sleep 1; i=$((i+1))
done

# The 'ip addr' command is a modern and reliable way to get network details
SUBNET_CIDR=$(ip addr show eth0 | grep "inet " | awk '{print $2}')
SHARK_IP=$(echo $SUBNET_CIDR | cut -d'/' -f1)
GATEWAY=$(ip route | grep default | awk '{print $3}')
echo "[+] Network Lock Acquired: $SUBNET_CIDR" >> $DEBUG_LOG

# --- EXECUTION ---
LED ATTACK
# The 'macchanger' command changes the MAC address of a network card.
# The -r flag randomizes it, and since we use it in a script, it will happen automatically.
macchanger -r eth0 > /dev/null
echo "[*] MAC address changed for stealth." >> $DEBUG_LOG

# STAGE 1: Host Discovery (Fast & Verbose)
echo "[*] Starting Host Discovery: nmap -sn $SUBNET_CIDR" >> $DEBUG_LOG
nmap -sn $SUBNET_CIDR -oG - | grep "Up" | awk '{print $2}' > $HOSTS_IP_FILE

# STAGE 2: Write Report and Port Scan
HOST_COUNT=$(wc -l < $HOSTS_IP_FILE)
echo "[*] Host discovery complete. Found $HOST_COUNT live hosts." >> $DEBUG_LOG

# Write the Executive Summary
echo "### CUTLASS v3.0 RECON REPORT | $TIMESTAMP ###" > $REPORT_FILE
echo "" >> $REPORT_FILE
echo "--- EXECUTIVE SUMMARY ---" >> $REPORT_FILE
echo " - Shark Jack IP:  $SHARK_IP" >> $REPORT_FILE
echo " - Network Gateway:  $GATEWAY" >> $REPORT_FILE
echo " - Discovered Hosts: $HOST_COUNT" >> $REPORT_FILE
echo "" >> $REPORT_FILE
echo "--- DETAILED FINDINGS ---" >> $REPORT_FILE

if [ $HOST_COUNT -gt 0 ]; then
    # STAGE 3: Enhanced Port & Service Scan on Live Hosts
    echo "[*] Beginning detailed scan on live hosts..." >> $DEBUG_LOG
    # Nmap options for a truly juicy scan.
    # -p 1-65535: Full port scan. This will take longer, but is more thorough.
    # -sV: Service version detection.
    # -O: OS detection.
    # -T4: Aggressive timing.
    # --open: Only list open ports.
    NMAP_FULL_SCAN_OPTIONS="-p 1-65535 -sS -sV -O -T4 --open"
    
    for host in $(cat $HOSTS_IP_FILE); do
        echo -e "\n[+] Host Report: $host" >> $REPORT_FILE
        # Execute the detailed scan and append the results.
        nmap $NMAP_FULL_SCAN_OPTIONS $host >> $REPORT_FILE
    done
else
    echo "[!] No live hosts responded to discovery scan." >> $REPORT_FILE
fi

# --- CLEANUP ---
echo "[*] Mission Complete. Cleaning up." >> $DEBUG_LOG
rm -f $HOSTS_IP_FILE
echo "" >> $REPORT_FILE
echo "### END OF REPORT ###" >> $REPORT_FILE
LED FINISH