# Nginx Log DNS Resolver

`nginx-logresolver` is a Bash script that processes Nginx access logs and resolves IP addresses to hostnames in real time. It improves the readability of logs by replacing IPs with their corresponding hostnames using system DNS resolution. The script optionally colorizes the output and checks if `dnsmasq` is installed to improve performance via local DNS caching.

## Why?

By default, Nginx logs contain raw IP addresses instead of hostnames. This is intentional: resolving hostnames requires DNS lookups, which are relatively slow and can degrade performance under high traffic. 

However, hostnames can be helpful for:

- Identify traffic from known domains or bots
- Spot patterns in abuse or suspicious activity
- Debug or audit logs with more context

This script reads logs after they are written, performing DNS resolution on-the-fly without changing Nginx’s configuration or degrading its performance.

## Features

- Resolves IP addresses to hostnames in real time as logs are written.
- Checks if `dnsmasq` is installed and suggests using it for faster local DNS caching.
- Optional colored output via the `-c` / `--color` flag (requires `grc`).
- Skips confirmation prompts using the `-y` / `--yes` flag.
- Lightweight and minimal — pure Bash with no caching layer.

## Requirements

- `bash`
- `getent` for DNS resolution
- `grc` (optional, for colored output)
- `tail`
- Access to your Nginx logs (default: `/var/log/nginx/access.log` — can be customized)

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

### With colorized output (requires grc):
```bash

./nginx-logresolver.sh -c
```

### Skip dnsmasq warning:
```bash

./nginx-logresolver.sh -y
```

## What It Does

- **Tails logs in real time**: Watches `/var/log/nginx/access.log` and processes new entries as they appear.
- **Resolves IPs to hostnames**: Uses `getent hosts` to replace the IP address in each log line with its corresponding hostname.
- **Suggests dnsmasq**: If `dnsmasq` is not found in common system paths, warns the user that enabling it will improve performance by caching DNS queries.
- **Adds color**: If `-c` is specified and `grc` is installed, applies syntax highlighting to logs using `grc`.

## Example Output

```text
host.example.com - - [07/May/2025:10:42:31 +0000] "GET /index.html HTTP/1.1" 200 1024 "-" "Mozilla/5.0"

