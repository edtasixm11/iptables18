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

# Fer NAT per les xarxes internes:
# - 172.19.0.0/24
# - 172.20.0.0/24
iptables -t nat -A POSTROUTING -s 172.19.0.0/24 -o enp6s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.20.0.0/24 -o enp6s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.21.0.0/24 -o enp6s0 -j MASQUERADE

# Regles de DMZ
# ###########################################################

# de la xarxaA només es pot accedir del router/fireall 
# als serveis: ssh i  daytime(13)
iptables -A INPUT -s 172.19.0.0/24 -p tcp --dport 22 -j ACCEPT  # -i br-xxx
iptables -A INPUT -s 172.19.0.0/24 -p tcp --dport 13 -j ACCEPT  # -i br-xxx
iptables -A INPUT -s 172.19.0.0/24 -j REJECT  # -i br-xxx

# de la xarxaA només es pot accedir a l'exterior als serveis 
# web, ssh i daytime(2013)
iptables -A FORWARD  -s 172.19.0.0/24 -p tcp --dport 80 \
    	    -o enp6s0   -j ACCEPT
iptables -A FORWARD  -d 172.19.0.0/24 -p tcp --sport 80 \
            -i enp6s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD  -s 172.19.0.0/24 -p tcp --dport 22 \
            -o enp6s0   -j ACCEPT
iptables -A FORWARD  -d 172.19.0.0/24 -p tcp --sport 22 \
            -i enp6s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD  -s 172.19.0.0/24 -p tcp --dport 2013 \
            -o enp6s0   -j ACCEPT
iptables -A FORWARD  -d 172.19.0.0/24 -p tcp --sport 22 \
            -i enp6s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD  -s 172.19.0.0/24 -o enp6s0 -j REJECT 
iptables -A FORWARD  -d 172.19.0.0/24 -i enp6s0 -j REJECT  






