#!/bin/sh
# Optional prefix (e.g. a Polybar color)
FORMAT_UP=''

# Find all WireGuard interfaces (wg0, wg1, …)
WG_COUNT=$(ip -j link show type wireguard | jq 'length')

if [ "$WG_COUNT" -gt 0 ]; then
	# Build a "wgX A.B.C.D, wgY E.F.G.H" string
	addrs=""
	for IF in $(ip -j link show type wireguard | jq -r '.[].ifname'); do
		addr=$(ip -4 -j addr show dev "$IF" |
			jq -r '.[0].addr_info[0].local // empty')
		[ -n "$addr" ] && addrs="$addrs$IF $addr, "
	done
	MESSAGE_UP=${addrs%, }
	printf '%s\n' "${FORMAT_UP}${MESSAGE_UP}"
else
	# No WireGuard interfaces up
	printf '\n'
fi
