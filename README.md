# nginx-logresolver

`nginx-logresolver` is a Bash script that processes Nginx log files and resolves IP addresses to hostnames. It improves the readability of your logs by replacing IP addresses with their corresponding hostnames. It also caches the results for efficient performance, ensuring that hostnames are looked up only once every 3 hours.

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

## Usage

Make the script executable:

```bash
chmod +x nginx-logresolver.sh

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


