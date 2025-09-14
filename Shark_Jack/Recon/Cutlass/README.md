# Cutlass v3.0 - Professional Nmap Payload

### A Hardened Reconnaissance Tool for the Hak5 Shark Jack

**Author**: wino_willy and William Shire III
**Version**: 3.0
**Category**: Reconnaissance, Network Mapping
**Target**: General purpose wired networks

### Description

Cutlass v3.0 is a robust and reliable Nmap payload designed for the Hak5 Shark Jack. This script automates the process of network reconnaissance, prioritizing a fast initial scan followed by a detailed, in-depth analysis of live hosts. It is specifically hardened to overcome common network and filesystem inconsistencies, ensuring successful data capture on every deployment.

This payload performs the following actions:
1.  **Stealthy Host Discovery**: Identifies live hosts on the connected subnet.
2.  **MAC Address Randomization**: Changes the device's MAC address to evade basic network-level detection.
3.  **Comprehensive Port Scanning**: Conducts a full port scan on all 65,535 TCP ports of every live host to uncover all potential services.
4.  **Service and OS Fingerprinting**: Uses Nmap's advanced capabilities to identify service versions (`-sV`) and guess the operating system (`-O`) of discovered hosts.
5.  **Actionable Reporting**: Generates a clean, human-readable report summarizing the findings for quick analysis.

### LED Status Indicators

The payload relies on the Shark Jack's multi-color LED for silent, discreet status updates, as it is designed for a model without a serial console.

* **Solid Magenta**: The payload is in its `SETUP` phase, awaiting a DHCP lease from the network.
* **Single Yellow Blink**: The `ATTACK` phase is active. Nmap is currently scanning the network.
* **Slow Red Blink**: A critical `FAIL` has occurred, likely due to a timeout while acquiring an IP address. The mission has been aborted.
* **Green Success Pattern**: The `FINISH` phase is complete. The mission was successful, and the report has been saved.

### How to Use

1.  **Preparation**:
    * Set the Shark Jack's switch to **Arming Mode** (middle position).
    * Connect the Shark Jack to your computer via Ethernet.
    * Configure your computer's Ethernet interface with a static IP address in the `172.16.24.0/24` range.
    * Access the device via SSH using the default credentials: `root` and `hak5shark`.

2.  **Deployment**:
    * Transfer this payload file (`payload.sh`) to the `/root/payload/` directory on the Shark Jack via `scp`.
    * Disconnect the Shark Jack safely.
    * Set the switch to **Attack Mode** (the position closest to the Ethernet jack).
    * Plug the Shark Jack into the target network.

3.  **Retrieving Loot**:
    * After the LED displays the Green Success Pattern, disconnect the Shark Jack.
    * Return the switch to **Arming Mode** and reconnect to your computer.
    * Access the device via SSH.
    * Navigate to `/root/loot/cutlass_scans` to retrieve your scan report.

### Payload Code

```bash
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
# The 'macchanger' command changes the MAC address of a network card
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
echo " - Shark Jack IP:  $SHARK_IP" >> $REPORT_FILE
echo " - Network Gateway:  $GATEWAY" >> $REPORT_FILE
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