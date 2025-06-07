#!/bin/sh
# dnsmonitor.sh - monitor DNS connections via nf_conntrack
#
# This script is intended to run on OpenWrt using BusyBox utilities.
# It periodically parses the conntrack tables and logs DNS related entries.

INTERVAL=30
LOGFILE=/var/log/dnsmonitor.log
DATA=/tmp/dnsmonitor.out
NF_CT4=/proc/net/nf_conntrack
NF_CT6=/proc/net/nf_conntrack6

check_tools() {
    for t in grep awk sort; do
        command -v "$t" >/dev/null 2>&1 || {
            echo "Required tool '$t' not found" >&2
            exit 1
        }
    done
}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOGFILE"
}

read_conntrack() {
    [ -r "$NF_CT4" ] && cat "$NF_CT4"
    [ -r "$NF_CT6" ] && cat "$NF_CT6"
}

process_conntrack() {
    read_conntrack | grep -E '^ipv[46] .* (udp|tcp) .* dport=(53|853) ' | \
        awk '/ASSURED/{printf "%s %-19s %-19s %-9s %-19s %s\n", $3, $7, $8, $10, $11, $12}' | \
        sort
}

run_loop() {
    log "dnsmonitor started"
    while true; do
        process_conntrack > "$DATA"
        while IFS= read -r line; do
            log "$line"
        done < "$DATA"
        sleep "$INTERVAL"
    done
}

case "$1" in
    start)
        check_tools
        touch "$LOGFILE"
        run_loop &
        echo $! > /var/run/dnsmonitor.pid
        ;;
    stop)
        if [ -f /var/run/dnsmonitor.pid ]; then
            kill "$(cat /var/run/dnsmonitor.pid)" && rm -f /var/run/dnsmonitor.pid
        fi
        log "dnsmonitor stopped"
        ;;
    *)
        echo "Usage: $0 {start|stop}" >&2
        exit 1
        ;;
esac
