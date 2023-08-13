# Farfetshd

## Sample output

``` 
 🐧: Fedora 37 (6.4.6)
 🧠: Intel i5-1240P 1.0GHz 39°C
 🐏: 4.0/8GB 50%
 💾: 19.11/254G 7.5% 32.8°C
 🔋: 99% Wall power
 ⌚: 0d 10h 46m
```

## Description

This is a shell script that prints out some system information, it is written in POSIX shell (I used dash).

Made for GNU/Linux, tested on Fedora workstation 37, please let me know what errors you have, and what distro you run.

It only relies on 2 external commands (stat and awk), for the storage option. If you don't want storage, then no external commands are used. (*If someone knows a method to get this info without external commands it would be greatly appreciated*).

## Installation

Put farfetshd.sh somewhere in your path and Run `chmod +x farfetshd.sh` and put farfetshd.sh somewhere in your path, or use `./farfetshd.sh`.

## Configuration 

The first function is config. In there you write what options you want to display, one per line.

### Options

* cpu

    + Prints the name of the cpu, the frequency of core 0, and the temperature of the package

* cpusmall

    + Prints the name of the cpu

* memory

    + prints the gigabytes of RAM used and total, and the percentage used

* memorysmall

    + prints the total megabytes of ram

* battery

    + prints the percentage of battery, and the time remaining till empty or full charge

* batterysmall

    + prints the percentage of battery,

* os

    + prints the distribution name and version, and the kernel version

* ossmall

    + prints the distribution name

* storage

    + prints the gigabytes of storage used and total, the percentage used, and the tempurature of your nvme drive (if present)

    + **Warning** this options significantly slows down the script 

* uptime

    + prints the time your device has been on in days, hours, and minutes

## Speed

Speed testing was done by running:

``` 
#! /bin/sh
time for run in {1..10000}; do
    ./farfetshd.sh > /dev/null 2>&1;
done
```

The real time was recorded.

3 different configs were tested, each config was test 5 times.

**Default** Config:

``` 
config(){
os
cpu
memory
storage
battery
uptime
}
```

**NoStor** Config:

``` 
config(){
os
cpu
memory
battery
uptime
}
```

**Small** Config:

``` 
config(){
ossmall
cpusmall
memorysmall
batterysmall
}
```

Additionally I tested [dylanaraps/pfetch](https://github.com/dylanaraps/pfetch) with `PF_INFO="os host kernel uptime memory"`.

### Results

|         | Default (s) | NoStor (s) | Small (s) | pfetch (s) |
|---------|-------------|------------|-----------|------------|
| time 1  | 153.043     | 73.553     | 64.115    | 126.016    |
| time 2  | 159.606     | 76.172     | 68.157    | 92.465     |
| time 3  | 139.607     | 75.669     | 64.767    | 97.727     |
| time 4  | 147.307     | 76.110     | 67.140    | 101.517    |
| time 5  | 143.440     | 77.090     | 66.454    | 89.493     |
| Average | 148.601     | 75.719     | 66.127    | 101.4436   |

Storage does make a large impact on the speed, so the use of external programs is a detriment. The difference between NoStor and Small is negligible.
I suspect that the assochw function is also rather slow, perhaps having a set up script that stores the values in your shrc could improve speeds as they should be *relatively* static.

## Inspiration

This was heavily inspired by [dylanaraps/pfetch](https://github.com/dylanaraps/pfetch) and [6gk/fet.sh](https://github.com/6gk/fet.sh), and was helped significantly by [dylanaraps/pure-sh-bible](https://github.com/dylanaraps/pure-sh-bible) and numerous stackexchange and stackoverflow threads.
