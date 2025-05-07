#!/bin/bash

# Cache file location
CACHE_FILE="/tmp/ip_cache.txt"

# Function to fetch host for an IP and update cache
get_host() {
  local ip=$1
  local host=""

  # Temporary cache to store valid entries
  temp_cache=""

  # Check if the IP exists in the cache and if it's still valid (within 5 hours)
  if [[ -f "$CACHE_FILE" ]]; then
    while read -r line; do
      cache_ip=$(echo "$line" | cut -d' ' -f1)
      cache_host=$(echo "$line" | cut -d' ' -f2)
      cache_time=$(echo "$line" | cut -d' ' -f3)

      current_time=$(date +%s)
      time_diff=$((current_time - cache_time))

      # If the entry is valid (within 5 hours), keep it
      if ((time_diff < 18000)); then
        # If the IP matches, set the host and skip adding a new entry
        if [[ "$cache_ip" == "$ip" ]]; then
          host=$cache_host
        fi
        # Add the valid entry to temp_cache
        temp_cache+="$cache_ip $cache_host $cache_time"$'\n'
      fi
    done <"$CACHE_FILE"
  fi

  # If no valid host found in the cache, resolve and add it to cache
  if [[ -z "$host" ]]; then
    host=$(getent hosts "$ip" | awk '{print $2}')
    if [[ -n "$host" ]]; then
      temp_cache+="$ip $host $(date +%s)"$'\n'
    else
      host=$ip
    fi
  fi

  # Rewrite the cache file with the valid entries
  echo -n "$temp_cache" >"$CACHE_FILE"

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
tail -F /var/log/nginx/access.log | while read -r line; do
  ip=$(echo "$line" | awk '{print $1}')
  host=$(get_host "$ip")

  formatted_line=$(echo "$line" | awk -v host="$host" '{$1=host; print}')

  if $USE_GRC; then
    echo "$formatted_line" | grc -c /usr/share/grc/conf.log cat
  else
    echo "$formatted_line"
  fi
done
