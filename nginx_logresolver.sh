#!/bin/bash

USE_GRC=false
ASSUME_YES=false

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
  *)
    echo "Usage: $0 [-c|--color] [-y|--yes]"
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

# Tail logs and process
tail -F /var/log/nginx/access.log |
  while read -r line; do
    ip=$(echo "$line" | awk '{print $1}')
    [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
      echo "$line"
      continue
    }

    host=$(get_host "$ip")
    formatted_line=$(echo "$line" | awk -v host="$host" '{$1=host; print}')

    echo "$formatted_line"
  done |
  {
    if $USE_GRC; then
      grc -c /usr/share/grc/conf.log cat
    else
      cat
    fi
  }
