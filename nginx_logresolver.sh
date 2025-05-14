#!/bin/bash

USE_GRC=false
ASSUME_YES=false
SHOW_IP=false

# Display help message
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "OPTIONS:"
  echo "  -c, --color      Use colorized output with grc"
  echo "  -y, --yes        Assume 'yes' to prompts"
  echo "  -i, --show-ip    Show the IP address after the resolved domain"
  echo "  -h, --help       Show this help message"
}

# Handle command-line options
while [[ $# -gt 0 ]]; do
  case $1 in
  -c | --color)
    USE_GRC=true
    shift
    ;;
  -y | --yes)
    ASSUME_YES=true
    shift
    ;;
  -i | --show-ip)
    SHOW_IP=true
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    echo "Invalid option: $1"
    show_help
    exit 1
    ;;
  esac
done

# Check if dnsmasq binary exists in common locations
find_dnsmasq() {
  for path in /usr/sbin/dnsmasq /sbin/dnsmasq /usr/bin/dnsmasq /bin/dnsmasq; do
    if [[ -x "$path" ]]; then
      return 0
    fi
  done
  return 1
}

# Warn user if dnsmasq is not found
if ! find_dnsmasq; then
  echo "Warning: 'dnsmasq' is not installed or not found in common locations."
  echo "This script performs better with dnsmasq installed because it caches DNS queries and avoids repeated lookups."

  if ! $ASSUME_YES; then
    read -rp "Do you want to continue anyway? [y/N]: " answer
    case "$answer" in
    [Yy]*) ;;
    *)
      echo "Exiting."
      exit 1
      ;;
    esac
  fi
fi

# Get host for IP using DNS
get_host() {
  local ip=$1
  local resolved_host

  resolved_host=$(getent hosts "$ip" | awk '{print $2}')
  echo "${resolved_host:-$ip}"
}

# Regular expression to match both IPv4 and IPv6 addresses
is_ip_address() {
  local ip=$1
  # Matches IPv4 or IPv6 (basic check)
  [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ || $ip =~ ^([0-9a-fA-F:]+:+)+[0-9a-fA-F]+$ ]]
}

# Tail logs and process
tail -F /var/log/nginx/access.log |
  while read -r line; do
    ip=$(echo "$line" | awk '{print $1}')
    if is_ip_address "$ip"; then
      host=$(get_host "$ip")
      if $SHOW_IP; then
        # Remove any spaces before or after the domain and IP, and ensure proper formatting
        formatted_line=$(echo "$line" | awk -v host="$host" -v ip="$ip" '{$1=host " - (" ip ")"; $2=""; print $0}' | sed 's/ - - / /')
      else
        formatted_line=$(echo "$line" | awk -v host="$host" '{$1=host; print $0}')
      fi
      echo "$formatted_line"
    else
      echo "$line"
    fi
  done |
  {
    if $USE_GRC; then
      grc -c /usr/share/grc/conf.log cat
    else
      cat
    fi
  }
