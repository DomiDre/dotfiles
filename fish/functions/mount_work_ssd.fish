function mount_work_ssd
    udisksctl unlock -b /dev/sda1
    udisksctl mount -b /dev/mapper/luks-*
end
