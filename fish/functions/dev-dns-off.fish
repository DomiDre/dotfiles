function dev-dns-off --description 'Revert split-DNS tweaks on an interface'
    # usage:
    #   dev-dns-off
    #   dev-dns-off IFACE

    function _usage
        echo 'usage: dev-dns-off [IFACE]'
        echo 'If IFACE is omitted, the default-route interface is auto-detected.'
    end

    set -l IFACE
    switch (count $argv)
        case 0
            set IFACE (ip route show default | awk '{print $5}' | head -n1)
        case 1
            set IFACE $argv[1]
        case '*'
            _usage
            return 1
    end

    if test -z "$IFACE"
        echo "dev-dns-off: could not detect an active interface. pass one explicitly."
        return 1
    end

    echo "Reverting DNS config on $IFACE..."
    if not sudo resolvectl revert $IFACE
        echo "dev-dns-off: failed to revert settings on $IFACE"
        return 1
    end

    if resolvectl --help 2>/dev/null | grep -q 'default-route'
        sudo resolvectl default-route $IFACE yes >/dev/null 2>&1
    end

    echo ""
    echo "Status for $IFACE:"
    resolvectl status $IFACE
end

