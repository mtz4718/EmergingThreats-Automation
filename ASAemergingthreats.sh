#!/bin/bash
rm emerging-Block-IPs.txt
wget https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt
#declare -a rawArray
#unset rawArray
mapfile -t rawArray < <(sed '/^#/ d; /^$/ d' emerging-Block-IPs.txt)
cdr2mask ()
{
   # Number of args to shift, 255..255, first non-255 byte, zeroes
   set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
   [ $1 -gt 1 ] && shift $1 || shift
   echo ${1-0}.${2-0}.${3-0}.${4-0}
}



for ip in ${rawArray[@]};
do
#take care of subnets
if [[ $ip == *"/"* ]];
then
ip=$(echo $ip | sed 's/\// /')
cidr=$(echo $ip | awk '{ print $2 }')
mask=$(cdr2mask $cidr)
ip=$(echo $ip | awk '{ print $1 }')
cmd=$(echo "network-object "$ip $mask",")
iplist+=$(echo $cmd)
#take care of hosts
else
cmd=$(echo "network-object host "$ip",")
iplist+=$(echo $cmd)
fi
done
#remove last comma
iplist=${iplist::-1}
export iplist

python3 ASAemergingthreats.py