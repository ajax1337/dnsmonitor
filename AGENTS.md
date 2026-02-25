# AGENTS.md

## Cursor Cloud specific instructions

### Overview

This repository contains `dnsmonitor.sh`, a POSIX shell script fragment for monitoring active DNS connections on OpenWrt routers. It parses `/proc/net/nf_conntrack` (Linux netfilter connection tracking) to detect DNS traffic on ports 53 (Do53) and 853 (DoT).

### Linting

- **shellcheck**: Run `shellcheck dnsmonitor.sh` to lint. The script is a code fragment (not a complete standalone script), so SC2154 warnings about unassigned variables are expected — those variables are defined in the full upstream script context.
- **Syntax check**: Run `sh -n dnsmonitor.sh` for a quick syntax validation.

### Testing

There is no automated test suite. To test the grep/awk pipelines, create mock `/proc/net/nf_conntrack` data and pipe it through the script's patterns. The real `/proc/net/nf_conntrack` is not available in this cloud VM environment (no active netfilter conntrack).

### Runtime caveat

The script requires Linux kernel netfilter connection tracking (`/proc/net/nf_conntrack`). This file is not present in the cloud agent container, so the script cannot be run as a daemon here. Functional testing must use mock data or be performed on an actual OpenWrt/Linux router.
