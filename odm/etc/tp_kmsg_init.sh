#!/system/bin/sh
# Copyright (c) 2023, The Linux Foundation.
# Copyright (C) 2023-2024 XiaoMi, Inc.
# All rights reserved.
#

if [ -d /data/vendor/touch ]; then
    dmesg -s 8388608 | grep -iE "MI_TP|GTP|FTS" > /data/vendor/touch/tp_init_log.txt
    fileLines=`sed -n '$=' /data/vendor/touch/tp_init_log.txt`
    if [[ ! -s /data/vendor/touch/tp_init_log.txt ]] || [[ $fileLines -lt 80 ]]; then
        echo "File is null or the len($fileLines) of file is less than 80."
        echo "dmesg again" >> /data/vendor/touch/tp_init_log.txt
        dmesg -s 12582912 | grep -iE "MI_TP|GTP|FTS" >> /data/vendor/touch/tp_init_log.txt
    fi
    date >> /data/vendor/touch/tp_init_log.txt
    echo "Finished"
else
    echo "Failed"
fi

chmod 0666 /data/vendor/touch/tp_init_log.txt
chown system system /data/vendor/touch/tp_init_log.txt
