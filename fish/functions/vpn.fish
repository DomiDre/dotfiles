function vpn --description 'Connect to VPN'
    set vpnname $argv[1]
    
    if test -z "$vpnname"
        echo "Usage: vpn <VPN_NAME>"
        return 1
    end
    
    # Get UUID using nmcli
    set uuid (nmcli c show $vpnname | grep uuid | awk '{print $2}')
    
    if test -z "$uuid"
        echo "❌ Could not get UUID for $vpnname"
        return 1
    end

    # Check if already active
    if nmcli connection show --active | grep -q "^$vpnname\b"
        echo "✅ Already connected to $vpnname"
        return 0
    end

    echo "Checking passphrase for UID $vpnname"
    
    # Get passphrase from Secret Service
    set pass (secret-tool lookup setting-name vpn connection-uuid $uuid)
    
    if test -z "$pass"
        echo "❌ Could not retrieve passphrase from secret agent"
        return 1
    end
    
    set output (expect -c "
        log_user 1
        spawn nmcli c up $vpnname --ask
        expect {
            \"Password (vpn.secrets.password):\"
            {
                send \"$pass\\r\"
                expect eof
            }
            eof
            {
            }
        }
    ")
    echo $output
end
