# Nginx Log Resolver

`nginx-logresolver` is a Bash script that processes Nginx log files and resolves IP addresses to hostnames. It improves the readability of your logs by replacing IP addresses with their corresponding hostnames. It also caches the results for efficient performance, ensuring that hostnames are looked up only once every 5 hours.

## Why?

By default, Nginx logs contain raw IP addresses instead of hostnames. This is intentional: resolving hostnames requires DNS lookups, which are relatively slow and can significantly degrade performance—especially under high traffic. For that reason, Nginx avoids hostname resolution in logs to keep things fast and efficient.

However, there are many cases where seeing a hostname instead of an IP can be helpful, such as:

- Quickly identifying traffic from known domains or bots
- Spotting patterns in abuse or suspicious activity
- Debugging or auditing logs in real-time with more context

This script bridges that gap by resolving IPs to hostnames **outside of Nginx**, after the logs are written. It runs in real time, uses a cache to minimize DNS overhead, and optionally adds colorized output for better readability—all without modifying your Nginx config or affecting its performance.

## Features

- Resolves IP addresses to hostnames in real-time as Nginx logs are written.
- Caches hostname lookups for up to 3 hours to reduce the frequency of DNS queries.
- Supports both error and access logs (`/var/log/nginx/error.log` and `/var/log/nginx/access.log`).
- Integrates with `grc` (Generic Colourizer) to add color to the log output for easier reading.
- Efficient and minimal Bash-based solution with minimal dependencies.

## Requirements

- `bash`
- `getent` for DNS lookups
- `grc` (Generic Colourizer) for colorized log output
- `/var/log/nginx/error.log` and `/var/log/nginx/access.log` for Nginx logs

## Installation

### Clone the repository:

```bash
git clone https://github.com/spithash/nginx-logresolver.git
cd nginx-logresolver
```
## Usage

Make the script executable:

```bash
chmod +x nginx-logresolver.sh
```
## Running the Script

Once the script is executable, you can start it with:

```bash
./nginx-logresolver.sh
```

### What It Does

- **Tails Nginx Logs**: Monitors both `/var/log/nginx/access.log` and `/var/log/nginx/error.log` in real-time.
- **Resolves IPs to Hostnames**: Converts IP addresses in each log line to hostnames using `getent`.
- **Uses a Cache**: Saves hostname lookups in `/tmp/ip_cache.txt` and reuses them for 3 hours to reduce DNS lookups.
- **Adds Color**: Uses `grc` to colorize log output for easier readability.


### Example Output

```text
host.example.com - - [07/May/2025:10:42:31 +0000] "GET /index.html HTTP/1.1" 200 1024 "-" "Mozilla/5.0"
```


