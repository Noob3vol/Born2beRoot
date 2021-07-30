#!/bin/bash

MESS=


#Architecture

ARCH=$(uname -srvnom)

MESS+="#Architecture: $ARCH\n"
#----------------------------------------------------------
#CPU Physical

NB_CPU=$(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)

MESS+="#CPU physical : $NB_CPU\n"

#----------------------------------------------------------
#vCPU

NB_VCPU=$(cat /proc/cpuinfo | grep "^processor" | wc -l)

MESS+="#vCPU : $NB_VCPU\n"

#----------------------------------------------------------
# MEMORY

MEM_TOTAL=$(free -mh --si | grep Mem | sed -e "s/\ \+/\ /g" | cut -d' ' -f2)
MEM_T=$(echo $MEM_TOTAL | tr -d 'M')

MEM_USED=$(free -mh --si | grep Mem | sed -e "s/\ \+/\ /g" | cut -d' ' -f3)
MEM_U=$(echo $MEM_USED | tr -d 'M')

MEM_PERC=$(echo "scale=2;${MEM_U} * 100 / ${MEM_T}" | bc)

MESS+="#Memory usage: ${MEM_U}/${MEM_TOTAL} (${MEM_PERC}%)\n"

#----------------------------------------------------------
#Disk Usage

DISK_TOTAL=$(df -h --total | grep total | tr -s " " | cut -d' ' -f 2)
DISK_USE=$(df -m --total | grep total | tr -s " " | cut -d' ' -f 3)
DISK_PERC=$(df -m --total | grep total | tr -s " " | cut -d' ' -f 5)

MESS+="#Disk Usage : $DISK_USE/$DISK_TOTAL ($DISK_PERC)\n"

#----------------------------------------------------------
#Cpu usage

CPU_U=$(top -b -n 1 | grep Cpu | sed "s/\ \+/\ /g" | cut -d' ' -f2)

MESS+="#Cpu Load : ${CPU_U}%\n"

#----------------------------------------------------------
# UPTIME

UPTIME=$(uptime -s)

MESS+="#Last Boot: ${UPTIME}\n"

#----------------------------------------------------------
# LVM

LVM_LINE=$(/usr/sbin/lvdisplay | wc -l)

if [[ LVM_LINE -eq 0 ]]
then
	LVM="no"
else
	LVM="yes"
fi

MESS+="#LVM use: $LVM\n"

#----------------------------------------------------------
#TCP ACTIVE CONNECTION

TCP_NB=$(netstat -t | grep ESTABLISHED | wc -l)

MESS+="#Connexion TCP: $TCP_NB ESTABLISHED\n"

#----------------------------------------------------------
#USER_LOGGED

NB_USER=$(who | wc -l)

MESS+="#User Log: ${NB_USER}\n"

#----------------------------------------------------------
#NET INFORMATION

IP=$(hostname -I)
MAC=$(cat /sys/class/net/enp0s3/address)

MESS+="#Network: IP $IP (${MAC})\n"

#----------------------------------------------------------
#SUDO COUNT

SUDO_COUNT=$(cat /var/log/sudo.log | grep "COMMAND" | wc -l)

MESS+="#Sudo : $SUDO_COUNT cmd\n"

wall <(echo -en "$MESS")
