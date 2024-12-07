#! /vendor/bin/sh
md5img=$(md5sum "/vendor/etc/tt_img/Signal.pkg"  | awk '{print $1}')
log -p i -t "flash.sh" "md5img = $md5img"

if [ ! -e "/mnt/vendor/persist/tt_md5sum/md5sum" ];then
    log -p i -t "flash.sh" "persist md5sum do not exist,create it!"
    `touch /mnt/vendor/persist/tt_md5sum/md5sum`
    `touch /mnt/vendor/persist/tt_md5sum/flashstate`
    `touch /mnt/vendor/persist/tt_md5sum/s_version`
fi

if [ ! -e "/data/vendor/tt_md5sum/md5sum" ];then
    log -p i -t "flash.sh" "data md5sum do not exist,create it!"
    `touch /data/vendor/tt_md5sum/md5sum`
    a=$(</mnt/vendor/persist/tt_md5sum/flashstate)
    b=$(</mnt/vendor/persist/tt_md5sum/s_version)
    $(setprop persist.vendor.radio.flashstate $a)
    $(setprop persist.vendor.radio.s_version $b)
fi

val=$(</mnt/vendor/persist/tt_md5sum/md5sum)
factory=`getprop persist.odm.radio.factorybuild`
region=`getprop ro.miui.build.region`
device=`getprop ro.product.device`
log -p i -t "flash.sh" "val = $val"
log -p i -t "flash.sh" "factory = $factory"
log -p i -t "flash.sh" "region = $region"
log -p i -t "flash.sh" "device = $device"

if [ "$val" != "$md5img" ];then
   log -p i -t "flash.sh" "enter"
   if [ "$factory" != "1" -a "$region" == "cn" -a "$device" == "xuanyuan" ];then
       log -p i -t "flash.sh" "flash_mode_start"
       `echo 0 > /mnt/vendor/persist/tt_md5sum/flashstate`
       $(setprop persist.vendor.radio.flashstate 0)
       #flash mode
       /odm/bin/ttftm_msc06a_daemon -p flash_on &
       bin1_pid=$!
       wait $bin1_pid
       log -p i -t "flash.sh" "flash_mode_pid = $bin1_pid"
       log -p i -t "flash.sh" "flash_mode_end"
       sleep 0.5

       #start flash
       log -p i -t "flash.sh" "burn_img_start"
       /odm/bin/flashmsc06a /dev/ttyHS5 4000000 1 /vendor/etc/tt_img/Signal.pkg
       x=$?
       log -p i -t "flash.sh" "burn_img_end"
       sleep 0.5

       #If flash failure, retry twice.
       j=1
       while [ $j -le 2 ]
       do
          if [ $x == 0 ]; then
             log -p i -t "flash.sh" "burn_img_ok"
             break
          else
             log -p i -t "flash.sh" "burn failure, retry $j times"
             log -p i -t "flash.sh" "retry_burn_img_start"
             `echo 2 > /mnt/vendor/persist/tt_md5sum/flashstate`
             $(setprop persist.vendor.radio.flashstate 2)
             /odm/bin/ttftm_msc06a_daemon -p flash_on &
             bin3_pid=$!
             wait $bin3_pid
             sleep 0.5
             /odm/bin/flashmsc06a /dev/ttyHS5 4000000 1 /vendor/etc/tt_img/Signal.pkg
             x=$?
             log -p i -t "flash.sh" "retry_burn_img_end"
             sleep 0.5

             if [ $x != 0 -a $j == 2 ];then
                log -p i -t "flash.sh" "Retry burn failure, flash origin img"
                log -p i -t "flash.sh" "origin_burn_img_start"
                `echo 3 > /mnt/vendor/persist/tt_md5sum/flashstate`
                $(setprop persist.vendor.radio.flashstate 3)
                /odm/bin/ttftm_msc06a_daemon -p flash_on &
                bin3_pid=$!
                wait $bin3_pid
                sleep 0.5
                /odm/bin/flashmsc06a /dev/ttyHS5 4000000 1 /vendor/etc/tt_img/origin/Origin_Signal.pkg
                log -p i -t "flash.sh" "origin_burn_img_end"
                sleep 0.5
             fi
          fi
          let j++
       done

       log -p i -t "flash.sh" "Read S_AT^SWVER Start"
       /odm/bin/ttftm_msc06a_daemon -p on -b S &
       bin4_pid=$!
       wait $bin4_pid
       y=$(/odm/bin/ttftm_msc06a_daemon -a AT^SWVER? | sed -n '4p')
       log -p i -t "flash.sh" "$y"
       log -p i -t "flash.sh" "Read S_AT^SWVER End"
       sleep 0.5

       #power off
       log -p i -t "flash.sh" "power off_start"
       /odm/bin/ttftm_msc06a_daemon -p off &
       bin5_pid=$!
       wait $bin5_pid
       log -p i -t "flash.sh" "bin5_pid = $bin5_pid"
       log -p i -t "flash.sh" "power off_end"
       sleep 0.5

       #write md5img value
       `echo $md5img > /mnt/vendor/persist/tt_md5sum/md5sum`
       `echo 1 > /mnt/vendor/persist/tt_md5sum/flashstate`
       $(setprop persist.vendor.radio.flashstate 1)
       `echo $y > /mnt/vendor/persist/tt_md5sum/s_version`
       $(setprop persist.vendor.radio.s_version $y)
   else
       log -p i -t "flash.sh" "do nothing!"
   fi

fi

