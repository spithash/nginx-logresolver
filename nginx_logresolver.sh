#!/bin/bash

CACHE_FILE="/tmp/ip_cache.txt"
declare -A ip_cache
CACHE_TIMEOUT=18000 # 5 hours
USE_GRC=false

# Handle command-line options
while [[ $# -gt 0 ]]; do
  case $1 in
  -c | --color)
    USE_GRC=true
    shift
    ;;
  *)
    echo "Usage: $0 [-c|--color]"
    exit 1
    ;;
  esac
done

# Load cache into associative array
load_cache() {
  local current_time
  current_time=$(date +%s)

  if [[ -f "$CACHE_FILE" ]]; then
    while read -r line; do
      local ip host timestamp
      ip=$(echo "$line" | cut -d' ' -f1)
      host=$(echo "$line" | cut -d' ' -f2)
      timestamp=$(echo "$line" | cut -d' ' -f3)

      if ((current_time - timestamp < CACHE_TIMEOUT)); then
        ip_cache["$ip"]="$host $timestamp"
      fi
    done <"$CACHE_FILE"
  fi
}

# Save cache back to file
save_cache() {
  >"$CACHE_FILE"
  for ip in "${!ip_cache[@]}"; do
    echo "$ip ${ip_cache[$ip]}" >>"$CACHE_FILE"
  done
}

# Get host for IP, using cache or DNS
get_host() {
  local ip=$1
  local current_time
  current_time=$(date +%s)

  if [[ -n "${ip_cache[$ip]}" ]]; then
    local cached_host cached_time
    cached_host=$(echo "${ip_cache[$ip]}" | cut -d' ' -f1)
    cached_time=$(echo "${ip_cache[$ip]}" | cut -d' ' -f2)

    if ((current_time - cached_time < CACHE_TIMEOUT)); then
      echo "$cached_host"
      return
    fi
  fi

  local resolved_host
  resolved_host=$(getent hosts "$ip" | awk '{print $2}')
  resolved_host=${resolved_host:-$ip}

  ip_cache["$ip"]="$resolved_host $current_time"
  echo "$resolved_host"
}

# Load initial cache
load_cache

# Save updated cache on exit
trap save_cache EXIT

# Tail logs and process
tail -F /var/log/nginx/infocopy-access.log |
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
