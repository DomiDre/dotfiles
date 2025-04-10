function unlock_luks --description 'Unlock an encrypted LUKS device using secret-tool and expect'
    set device $argv[1]
    
    if test -z "$device"
        echo "Usage: unlock_luks /dev/sdX"
        return 1
    end
    
    # Get LUKS UUID using lsblk
    set uuid (lsblk -no UUID $device)
    
    if test -z "$uuid"
        echo "❌ Could not get LUKS UUID for $device"
        return 1
    end
    
    # Get passphrase from Secret Service
    set pass (secret-tool lookup filesystem luks luks.uuid $uuid)
    
    if test -z "$pass"
        echo "❌ Could not retrieve passphrase from secret agent"
        return 1
    end
    
    # Use expect to feed the password to udisksctl
    expect -c "
        spawn udisksctl unlock -b $device
        expect \"Passphrase:\"
        send \"$pass\r\"
        expect eof
    "
end
