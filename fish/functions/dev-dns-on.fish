function dev-dns-on --description 'Route given domain(s) to 127.0.0.1 via systemd-resolved on a specific interface'
    # usage:
    #   dev-dns-on DOMAIN
    #   dev-dns-on IFACE DOMAIN [DOMAIN2 DOMAIN3 ...]
    #
    # examples:
    #   dev-dns-on local
    #   dev-dns-on wlan0 local dev

    function _usage
        echo 'usage: dev-dns-on [IFACE] DOMAIN [MORE_DOMAINS...]'
        echo 'If IFACE is omitted, the default-route interface is auto-detected.'
    end

    set -l IFACE
    set -l DOMAINS

    switch (count $argv)
        case 0
            _usage
            return 1
        case 1
            # auto-detect iface; single domain
            set IFACE (ip route show default | awk '{print $5}' | head -n1)
            set DOMAINS $argv[1]
        case '*'
            # first arg is iface, rest are domains
            set IFACE $argv[1]
            set DOMAINS $argv[2..-1]
    end

    if test -z "$IFACE"
        echo "dev-dns-on: could not detect an active interface. pass one explicitly."
        return 1
    end

    if test (count $DOMAINS) -lt 1
        echo "dev-dns-on: at least one DOMAIN is required."
        _usage
        return 1
    end

    echo "Using interface: $IFACE"
    echo "Routing domains -> 127.0.0.1:"
    for d in $DOMAINS
        echo "  * .$d"
    end

    # point this link's DNS to local dnsmasq
    if not sudo resolvectl dns $IFACE 127.0.0.1
        echo "dev-dns-on: failed to set DNS on $IFACE"
        return 1
    end

    # set routing-only domains (leading ~)
    set -l ROUTE_DOMAINS
    for d in $DOMAINS
        set ROUTE_DOMAINS $ROUTE_DOMAINS "~$d"
    end
    if not sudo resolvectl domain $IFACE $ROUTE_DOMAINS
        echo "dev-dns-on: failed to set routing domains on $IFACE"
        return 1
    end

    # best-effort: avoid using this link as default DNS for non-matching domains
    if resolvectl --help 2>/dev/null | grep -q 'default-route'
        sudo resolvectl default-route $IFACE no >/dev/null 2>&1
    end

    echo ""
    echo "Status for $IFACE:"
    resolvectl status $IFACE
end

