#!/bin/bash

# Cache file location
CACHE_FILE="/tmp/ip_cache.txt"

# Function to fetch host for an IP and update cache
get_host() {
  local ip=$1
  local host=""

  # Check if the IP exists in the cache and if it's still valid (within 5 hours)
  if [[ -f "$CACHE_FILE" ]]; then
    while read -r line; do
      cache_ip=$(echo "$line" | cut -d' ' -f1)
      cache_host=$(echo "$line" | cut -d' ' -f2)
      cache_time=$(echo "$line" | cut -d' ' -f3)

      if [[ "$cache_ip" == "$ip" ]]; then
        current_time=$(date +%s)
        time_diff=$((current_time - cache_time))
        if ((time_diff < 18000)); then
          host=$cache_host
        else
          break
        fi
      fi
    done <"$CACHE_FILE"
  fi

  if [[ -z "$host" ]]; then
    host=$(getent hosts "$ip" | awk '{print $2}')
    if [[ -n "$host" ]]; then
      echo "$ip $host $(date +%s)" >>"$CACHE_FILE"
    else
      host=$ip
    fi
  fi

  echo "$host"
}

# Check if grc and its config are available
USE_GRC=false
if which grc >/dev/null 2>&1 && [[ -f /usr/share/grc/conf.log ]]; then
  read -p "It looks like you have grc installed, would you like some colors? (Y/N): " use_colors
  case "$use_colors" in
  [Yy]*) USE_GRC=true ;;
  esac
fi

# Main processing loop
tail -F /var/log/nginx/error.log /var/log/nginx/access.log | while read -r line; do
  ip=$(echo "$line" | awk '{print $1}')
  host=$(get_host "$ip")

  formatted_line=$(echo "$line" | awk -v host="$host" '{$1=host; print}')

  if $USE_GRC; then
    echo "$formatted_line" | grc -c /usr/share/grc/conf.log cat
  else
    echo "$formatted_line"
  fi
done
