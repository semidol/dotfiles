#!/bin/bash
# Blocks the guest from reaching the host's LAN while leaving the internet
# reachable. Runs as root on every boot; nft rules do not survive a reboot.
set -euo pipefail

# Lima's userspace network. The gateway lives here and proxies DNS, so this
# range has to stay reachable.
readonly LIMA_SUBNET="192.168.5.0/24"

# Docker's default bridge, used by containers started inside the VM.
readonly DOCKER_SUBNET="172.17.0.0/16"

readonly PRIVATE_RANGES="10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16"

nft delete table inet lima_guard 2>/dev/null || true

nft -f - <<EOF
table inet lima_guard {
  chain output {
    type filter hook output priority filter; policy accept;

    ip daddr { ${LIMA_SUBNET} } accept
    ip daddr { ${DOCKER_SUBNET} } accept
    ip daddr 127.0.0.0/8 accept

    ip daddr { ${PRIVATE_RANGES} } reject with icmp type net-unreachable
  }
}
EOF
