#!/bin/sh
config(){
os
cpu
memory
battery
uptime
}
assochw(){
    if [ -n "$hwr" ]; then
        return
    fi
    count=0
    for find in /sys/class/hwmon/*; do
        read -r content < "$find"/name
        case $content in
            *BAT*) bl=$find; ;;
            *AC*) pl=$find; ;;
            *nvme*) sl=$find; ;;
            *core*) cl=$find; ;;
            *k10*) cl=$find; ;;
        esac
        count=$((count+1))
    done
    hwr=1
}
cpu(){
    if [ -z "$hwr" ]; then
        assochw
    fi
    while  IFS=":" read -r line info; do
        case $line in
            model\ name*) cn=${info##*) }; ;;
            cpu\ MHz*) cf=${info##* }; break;;
        esac
    done < /proc/cpuinfo
    cf=${cf%%.*} # remove decimal from frequency
    if [ ${#cf} = 4 ]; then
        cf=${cf%??} #partial converion to GHz 
        cfi=${cf%?}
        cfd=$((cf%(cfi*10)))
        cf="$cfi.$cfd""GHz"
    else
        cf="$cf""MHz"
    fi
    read -r ct < "$cl"/temp1_input
    ct=${ct%%???}
    printf " %s: %s %s %i%s\n" "🧠" "$cn" "$cf" "$ct" "°C"
}
cpusmall(){
    while  IFS=":" read -r line info; do
        case $line in
            model\ name*) cn=${info##*) }; break;;
        esac
    done < /proc/cpuinfo
    printf " %s: %s\n" "🧠" "$cn"
}
memory(){
    while IFS=":" read -r name info; do
        case $name in
            MemTotal) mt=${info% *}; ;;
            MemFree) mf=${info% *}; ;; # Usable RAM kibibyte
            Cached) mc=${info% *}; ;; # RAM active in the system kibibyte
            Buffers) mb=${info% *}; ;; # RAM active in the system kibibyte
            SReclaimable) mr=${info% *}; ;; # RAM active in the system kibibyte
        esac
    done < /proc/meminfo
    mu=$((mt-mf-mb-mc-mr)) # get ram used in kibibytes
    mp=$(((mu*100)/mt)) # get usage percentage
    mt=$((mt/976562)) #kibibytes to gigabytes
    mu=$((mu/976)) #convert used ram from kibibytes to megabytes
    mui=${mu%???}
    if [ ${#mu} = 4 ]; then
        mud=${mu%??}
        mud=${mud#?}
        mm="$mui.$mud/$mt""GB"
    elif [ ${#mu} -le 3 ]; then
        mm="$mu/$mt""GB"
    else
        mm="$mui/$mt""GB"
    fi
    printf " %s: %s %i%%\n" "🐏" "$mm" "$mp"
}
memorysmall(){    
    while IFS=":" read -r line info; do
        case $line in
            MemTotal) mt=${info% *}; ;;
        esac
    done < /proc/meminfo 
    mt=$((((mt/976)/1000)*1000))
    printf " %s: %i%s\n" "🐏" "$mt" "MB"
}
battery(){
    if [ -z "$hwr" ]; then
        assochw
    fi
    while IFS="=" read -r line info; do
        case $line in
            POWER_SUPPLY_CHARGE_FULL) bcf=$info; ;; # The battery capacity in MicroAmpereHours
            POWER_SUPPLY_CHARGE_NOW) bcn=$info; ;; # The present battery capacity in MicroAmpereHours
            POWER_SUPPLY_CURRENT_NOW) bc=$info; ;; # The present outgoing charge in MicroAmperes
            POWER_SUPPLY_POWER_NOW) bpn=$info; ;; # The present outgoing charge in MicroAmperes
            POWER_SUPPLY_VOLTAGE_MIN_DESIGN) bvf=$info; ;; # The minimum battery outgoing voltage
            POWER_SUPPLY_VOLTAGE_NOW) bvn=$info; ;; # The present outgoing battery voltage
            POWER_SUPPLY_ENERGY_FULL) bef=$info; ;; # The battery capacity in microwatthours
            POWER_SUPPLY_ENERGY_NOW) ben=$info; ;; # The present battery capacity in microwatthours
            POWER_SUPPLY_CAPACITY) bp=$info; ;; # The present battery percentage
        esac
    done < "$bl"/device/uevent
    while read -r line; do
        case $line in
            POWER_SUPPLY_ONLINE*) ps=${line#*=}; ;; # If the laptop is currently plugged in
        esac
    done < "$pl"/device/uevent
    if [ "$bc" != "$bpn" ] && [ -z "$bc" ]; then
        bc="$bpn"
    fi
    if [ -z "$bcf" ] && [ -z "$bcn" ]; then
        bef=${bef%???}
        bvf=${bvf%???}
        ben=${ben%???}
        bvn=${bvn%???}
        bcf=$((bef*bvf))
        bcn=$((ben*bvn))
    fi
    bcl=$((99*bcf/100))
    if [ -z "$bp" ]; then
        bp=$((bcn/(bcf/100)))
    fi
    if [ "$bcn" -gt "$bcl" ]; then
        if [ "$ps" = 1 ]; then
            bs="Wall power"
        else
            bs="Full battery"
        fi
    else
        if [ "$ps" = 0 ]; then
            br=$((((bcn/(bc/1000))*600000)/10000000));
            bh=$((br/60))
            bm=$((br%60))
            bs="$bh"":""$bm"" Remaining"
        else
            br=$(((((bcf-bcn)/(bc/1000))*600000)/10000000))
            bh=$((br/60))
            bm=$((br%60))
            bs="$bh"":""$bm"" Till full charge"
        fi
    fi
    printf " %s: %s%% %s\n" "🔋" "$bp" "$bs"
}
batterysmall(){
    if [ -z "$hwr" ]; then
        assochw
    fi
    while IFS="=" read -r line info; do
        case $line in
            POWER_SUPPLY_CAPACITY) bp=$info; ;; # The present battery percentage
        esac
    done < "$bl"/device/uevent
    printf " %s: %i%%\n" "🔋" "$bp"
}
ossmall(){
    while read -r line; do
        case $line in
            NAME=*) D=${line#*\"}; ;; #get distro name
        esac
    done < /usr/lib/os-release
    D=${D%\"}
    D=${D%% *} # shorten distro name
    printf " %s: %s \n" "🐧" "$D"
}
os(){
    while read -r line; do
        case $line in
            NAME=*) D=${line#*\"}; ;; #get distro name
            VERSION_ID=*) V=${line#*=}; ;; #get distro version
        esac
    done < /usr/lib/os-release
    D=${D%\"}
    D=${D%% *} # shorten distro name
    read -r K < /proc/version # get kernel information
        K=${K%%-*} # shorten kernel name step 1
        K=${K##* }  # shorten kernel name step 2
        printf " %s: %s %s (%s)\n" "🐧" "$D" "$V" "$K"
}
storage(){
    if [ -z "$hwr" ]; then
        assochw
    fi
    s=$(stat -f / | awk '/^Blocks:/ {print (($3-$5)*4096),$3*4096}')
    sr=${s##* } # Get total space of SSD
    su=${s%% *} # get usued space of SSD
    sr=${sr%?????????} # Convert total space to gigabytes approx
    su=${su%???????} # Convert used space to 100s of mega bytes approx
    sp=$((su*10/sr)) #  get space usage in per mille
    spi=${sp%?} # get integer compoent of space usage percent
    spd=$((sp%spi)) # get decimal  compoent of space usage percent
    sug=${su%??}
    sud=$((su%(sug*100)))
    if [ -n "$pl" ]; then
        read -r st < "$sl"/temp1_input
        sti=${st%%???}
        std=${st##??}
        std=${std%%??}
        st="$sti"".""$std""°C"
    else
        st=""
    fi
    printf " %s: %i.%i/%iG %i.%i%% %s\n" "💾" "$sug" "$sud" "$sr" "$spi" "$spd" "$st"
}
uptime(){
    IFS=. read -r U _ < /proc/uptime # get uptime in seconds
    printf " %s: %id %ih %im\n" "⌚" "$((U/60/60/24))" "$((U/60/60%24))" "$((U/60%60))"
}
config
