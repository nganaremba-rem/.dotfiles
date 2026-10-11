#!/bin/sh
# Cloudflare WARP's nft table (inet cloudflare-warp) drops all non-private
# traffic and is rebuilt on every reconnect; re-punch WireGuard's port each time.
add() {
    nft list chain inet cloudflare-warp input 2>/dev/null | grep -q 'udp dport 4500 accept' && return
    nft list table inet cloudflare-warp >/dev/null 2>&1 || return
    nft insert rule inet cloudflare-warp input udp dport 4500 accept
    nft insert rule inet cloudflare-warp output udp sport 4500 accept
}
add
nft monitor | while read -r _; do add; done
