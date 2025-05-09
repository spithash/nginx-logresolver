# Nginx Log Resolver

`nginx-logresolver` is a Bash script that processes Nginx log files and resolves IP addresses to hostnames. It improves the readability of your logs by replacing IP addresses with their corresponding hostnames. The script uses a cache to avoid repeated DNS lookups, ensuring efficient performance, and supports optional colorized output for better readability.

## Why?

By default, Nginx logs contain raw IP addresses instead of hostnames. This is intentional: resolving hostnames requires DNS lookups, which are relatively slow and can degrade performance under high traffic. 

However, hostnames can be helpful for:

- Identifying traffic from known domains or bots
- Spotting patterns in abuse or suspicious activity
- Debugging or auditing logs in real time with more context

This script bridges the gap by resolving IPs **after** logs are written, without modifying Nginx's configuration or performance. It works in real time, uses a smart caching mechanism, and optionally outputs colorized logs.

## Features

- Resolves IP addresses to hostnames in real time as logs are written.
- Caches hostname lookups for 5 hours to reduce repeated DNS queries.
- Processes multiple log files simultaneously.
- Supports `grc` (Generic Colourizer) for optional color output via a `-c` flag.
- Lightweight and dependency-minimal Bash script.

## Requirements

- `bash`
- `getent` for hostname resolution
- `grc` (optional, for colored output)
- `tail`
- Access to your Nginx logs (default: `/var/log/nginx/infocopy-access.log`, `/var/log/nginx/infocopy-error.log`, and `/var/log/fail2ban.log` — update as needed)

## Installation

```bash
git clone https://github.com/spithash/nginx-logresolver.git
cd nginx-logresolver
chmod +x nginx-logresolver.sh
```

## Usage

### Basic usage:

```bash
./nginx-logresolver.sh
```

## With colorized output (requires grc):
```bash

./nginx-logresolver.sh -c
```

## What It Does

- **Tails logs in real time**: Monitors `/var/log/nginx/infocopy-access.log`, `/var/log/nginx/infocopy-error.log`, and `/var/log/fail2ban.log`.
- **Resolves IPs to Hostnames**: Converts IP addresses in the log lines to their corresponding hostnames using `getent`.
- **Caches Results**: Saves hostname lookups in `/tmp/ip_cache.txt` and reuses them for up to 5 hours to reduce DNS lookups.
- **Adds Color to Logs**: If `-c` is specified and `grc` is installed, log output will be colorized using the `apache` config, making it easier to read.

## Example Output

```text
host.example.com - - [07/May/2025:10:42:31 +0000] "GET /index.html HTTP/1.1" 200 1024 "-" "Mozilla/5.0"


