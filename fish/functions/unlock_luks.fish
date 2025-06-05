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

    echo "Checking passphrase for UID $uuid"
    
    # Get passphrase from Secret Service
    set pass (secret-tool lookup filesystem luks luks.uuid $uuid)
    
    if test -z "$pass"
        echo "❌ Could not retrieve passphrase from secret agent"
        return 1
    end
    echo "Got the password. Going to unlock and mount"
    
    set output (expect -c "
        log_user 1
        spawn udisksctl unlock -b $device
        expect \"Passphrase:\"
        send \"$pass\r\"
        expect eof
    ")

    # Extract the mapped device from the captured output
    set mapped (echo $output | string match -r '/dev/dm-[0-9]+')

    echo "Now only need to mount $mapped"
    # Check if unlock succeeded and mount it
    if test -n "$mapped"
        udisksctl mount -b $mapped
    else
        echo "❌ Failed to unlock $device"
    end
end
