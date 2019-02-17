#!/usr/bin/python3
from netmiko import ConnectHandler
from getpass import getpass
import os
iplist = os.getenv('iplist').split(',')

#change ip and user as needed
ip = '10.17.17.29'
user = 'admin'
password = '1111'
enablepass = '1111'

#
#Define ASA
#
asa = {
'device_type': 'cisco_asa',
'ip': ip,
'username': user,
#'password': getpass(prompt = "\nEnter User Password: "),
#'secret': getpass(prompt = "Enter Enable Password: "),
'password': password,
'secret': enablepass,
'fast_cli': True,
}

active = ConnectHandler(**asa)
print("Connected")
clearcommands = ['no access-list outside_access_in extended deny ip object-group EmergingThreats any','no object-group network EmergingThreats']
output = active.send_config_set(clearcommands)
print("old-list cleared")
print("Command sent")
for ip in iplist:
	sendlist = ['object-group network EmergingThreats', ip]
	output = active.send_config_set(sendlist)
blockrule = ['access-list outside_access_in line 1 extended deny ip object-group EmergingThreats any']
active.disconnect()



# no access-list outside_access_in extended deny ip object-gro$
# no object-group network EmergingThreats
