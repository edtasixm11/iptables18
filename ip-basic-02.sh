#! /bin/bash
# @edt ASIX M11-SAD Curs 2018-2019
# iptables

#echo 1 > /proc/sys/ipv4/ip_forward

# Regles flush
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# Polítiques per defecte: 
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# obrir el localhost
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# obrir la nostra ip
iptables -A INPUT -s 192.168.0.18 -j ACCEPT
iptables -A OUTPUT -d 192.168.0.18 -j ACCEPT


# Exemples de regles output
################################################
# accedir a qualsevol port/destí
#iptables -A OUTPUT -j ACCEPT
# accedir a port 13 de qualsevol destí
#iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 13 -d 0.0.0.0/0  -j ACEEPT
# accedir a qualsevol port 2013 excepte el del i26
iptables -A OUTPUT -p tcp --dport 2013 -d 192.168.2.56 -j REJECT
iptables -A OUTPUT -p tcp --dport 2013 -j ACCEPT


