#!/bin/bash
# Project1 Application Performance Monitor
# Victor Hermes
# Tool collects RX and TX data rates (in kB/s) with a sampling interval of 1 second
# using ifstat, then writes the statistics out to a file
# Tool collects hard disk access and writes out to a file
# Tool collects the process level statistics for 6 APM programs and writes out to a file for each

# use tail -f system_metrics.csv to monitor the file output during the script run

# FUNCTIONS ---------------
spawn () {
# changing ifstat sampling interval to 1 second
   ifstat -d 1  # start of ifstat
   
   # starting each APM module and saving the PID
   ./APM1 192.168.86.1 & 
   pid1=$!
   ./APM2 192.168.86.1 &
   pid2=$!
   ./APM3 192.168.86.1 &
   pid3=$!
   ./APM4 192.168.86.1 &
   pid4=$!
   ./APM5 192.168.86.1 &
   pid5=$!
   ./APM6 192.168.86.1 &
   pid6=$!
}

read_proc (){ # reading in the statistics of each process to a respective file
   
   cpu1=$(ps -p $pid1 -o %cpu | tail -1)
   mem1=$(ps -p $pid1 -o %mem | tail -1)
   cpu2=$(ps -p $pid2 -o %cpu | tail -1)
   mem2=$(ps -p $pid2 -o %mem | tail -1)
   cpu3=$(ps -p $pid3 -o %cpu | tail -1)
   mem3=$(ps -p $pid3 -o %mem | tail -1)
   cpu4=$(ps -p $pid4 -o %cpu | tail -1)
   mem4=$(ps -p $pid4 -o %mem | tail -1)
   cpu5=$(ps -p $pid5 -o %cpu | tail -1)
   mem5=$(ps -p $pid5 -o %mem | tail -1)
   cpu6=$(ps -p $pid6 -o %cpu | tail -1)
   mem6=$(ps -p $pid6 -o %mem | tail -1)
   echo "APM1,$SECONDS,$cpu1,$mem1" >> apm1Proc_metrics.csv
   echo "APM2,$SECONDS,$cpu2,$mem2" >> apm2Proc_metrics.csv
   echo "APM3,$SECONDS,$cpu3,$mem3" >> apm3Proc_metrics.csv
   echo "APM4,$SECONDS,$cpu4,$mem4" >> apm4Proc_metrics.csv
   echo "APM5,$SECONDS,$cpu5,$mem5" >> apm5Proc_metrics.csv
   echo "APM6,$SECONDS,$cpu6,$mem6" >> apm6Proc_metrics.csv
}

read_sys () { # runs ifstat, filters for the necessary data and stores it in variables to be written out, and then writes it out
   rxdata=$( ifstat ens33 | tail -2 | head -1 | awk '{print $7}' | sed 's/K//g' )
   txdata=$( ifstat ens33 | tail -2 | head -1 | awk '{print $9}' | sed 's/K//g' )
   hda=$( iostat -d sda | tail -2 | head -n 1 | awk '{print $4}' )
   # line for hard disk utilization
   hdu=$(df -m / | tail -1 | tr -s ' ' | cut -d ' ' -f4)
   # writing out the in statistics to system_metrics.csv
   echo "$SECONDS,$rxdata,$txdata,$hda,$hdu" >> system_metrics.csv
}

cleanup () { # killing all of the processes which were spawned by the script (on exit)
   pkill -o ifstat # killing ifstat via the process name
   kill -1 $pid1 # killing each APM module via the PID
   kill -1 $pid2
   kill -1 $pid3
   kill -1 $pid4
   kill -1 $pid5
   kill -1 $pid6
} 
trap cleanup EXIT

# MAIN -----------------

spawn
while [ true ] # collecting data while the script is still running
do
sleep 5
   # collecting data and then outputting to .csv files
   read_proc
   read_sys
done  




