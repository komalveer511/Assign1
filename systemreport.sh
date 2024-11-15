#!/bin/bash
echo ""
# System Information
echo "System Report generated by $USER, $(date)"
echo ""
echo "System Information"
echo "-------------------"
echo "Hostname: $(hostname)"
echo "OS: $(source /etc/os-release; echo "$NAME $VERSION")"
echo "Uptime: $(uptime -p)"
echo ""

# Hardware Information
echo "Hardware Information"
echo "----------------------"
processor_make_model=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}')
echo "CPU: $processor_make_model"
cpu_speed=$(sudo lshw -class processor | grep size | awk '{print $2}' | sort -u)
echo "Speed: $cpu_speed"
echo "RAM: $(free -h | awk '/Mem:/ {print $2}')"
echo "Disk(s):"
lsblk -o NAME,SIZE,MODEL --noheadings | grep -v "loop" | awk '{print $1, $2, $3}'
echo "Video:"
lspci -v | grep -i "VGA compatible controller"
echo ""

# Network Information
echo "Network Information"
echo "---------------------"
echo "FQDN: $(hostname --fqdn)"
echo "Host Address: $(hostname -I | awk '{print $1}')"
default_gateway=$(ip r | awk '$1 == "default" {print $3}')
echo "Gateway IP: $default_gateway"
echo "DNS Server(s) IP:"
grep "nameserver" /etc/resolv.conf | awk '{print $2}'
echo ""
echo "Network Card Information:"
sudo lshw -class network | awk '/description: (Ethernet|Wireless interface)/ || /product:/ {print}'
echo ""
echo "IP Address: $(ip -4 addr show | awk '/inet / {print $2}' | head -n 1)"
echo "CIDR Format: $(ip -4 addr show | awk '/inet / {print $2}' | head -n 1)"
echo ""

# System Status
echo "System Status"
echo "--------------"
echo "Users Logged In: $(who | awk '{users = users $1 ","} END {sub(/,$/, "", users); print users}')"
echo "Disk Space:"
df -h | awk '{print $6, $4}' | column -t
echo "Process Count: $(($(ps -e | wc -l) - 1))"
echo "Load Averages: $(uptime | awk -F'load average:' '{print $2}' | sed 's/ //g')"
echo "Memory Allocation: $(free -h | awk '/Mem:/ {print "Used: "$3 " Free: "$4}')"
echo "Listening Network Ports:"
ss -lntu | awk '{print $5}' | awk -F':' '{print $NF}' | paste -sd "," -
echo "UFW Rules:"
sudo ufw status
echo ""
