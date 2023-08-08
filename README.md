# Farfetshd

## Sample output

```

 🐧: Fedora 37 (6.3.12)
 🧠: i5-1240P 2.1GHz 35°C
 🐏: 3.0/8GB 38%
 💾: 19.3/254G 7.4% 30.8°C
 🔋: 99% Full battery
 ⌚: 0d 10h 50m

```

## Description

This is a shell script that prints out some system information, it is written in POSIX shell (I used dash).

Made for linux, tested on Fedora workstation 37, please let me know what errors you have, and what distro you run.

It only relies on 2 external commands (stat and awk), for the storage option. If you don't want storage, then no external commands are used. (*If someone knows a method to get this info without external commands it would be greatly appreciated*).

## Installation

Put farfetshd.sh somewhere in your path and run `chmod +x farfetshd.sh`.

## Configuration 

The first function is config. In there you write what options you want to display, one per line.

### Options

* cpu

    + Prints the name of the cpu, the frequency of core 0, and the temperature of the package

* cpusmall

    + Prints the name of the cpu

* memory

    + prints the gigbytes of RAM used and total, and the percentage used

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

### Results

|         | Default (s) | NoStor (s) | Small (s) |
|---------|-------------|------------|-----------|
| time 1  | 153.043     | 73.553     | 64.115    |
| time 2  | 159.606     | 76.172     | 68.157    |
| time 3  | 139.607     | 75.669     | 64.767    |
| time 4  | 147.307     | 76.110     | 67.140    |
| time 5  | 143.440     | 77.090     | 66.454    |
| Average | 148.601     | 75.719     | 66.127    |

## Inspiration

This was heavily inspired by [dylanaraps/pfetch](https://github.com/dylanaraps/pfetch) and [6gk/fet.sh](https://github.com/6gk/fet.sh), and was helped significantly by [dylanaraps/pure-sh-bible](https://github.com/dylanaraps/pure-sh-bible) and numerous stackexchange and stackoverflow threads.
