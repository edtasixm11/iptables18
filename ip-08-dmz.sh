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

# necessari per al funcionament de l'exercici 4.
iptables -A FORWARD  -d 172.19.0.0/16 -i enp6s0 -p tcp --dport 80 -j ACCEPT  #**2**
iptables -A FORWARD  -s 172.19.0.0/16 -o enp6s0 -p tcp --sport 80 \
	    -m state --state ESTABLISHED,RELATED -j ACCEPT  #**2**

# de la xarxaA només es pot accedir del router/fireall 
# als serveis: ssh i  daytime(13)
iptables -A INPUT -s 172.19.0.0/16 -p tcp --dport 22 -j ACCEPT  # -i br-xxx
iptables -A INPUT -s 172.19.0.0/16 -p tcp --dport 13 -j ACCEPT  # -i br-xxx
iptables -A INPUT -s 172.19.0.0/16 -j REJECT  # -i br-xxx

# de la xarxaA només es pot accedir a l'exterior als serveis 
# web, ssh i daytime(2013)
iptables -A FORWARD  -s 172.19.0.0/16 -p tcp --dport 80 \
    	    -o enp6s0   -j ACCEPT
iptables -A FORWARD  -d 172.19.0.0/16 -p tcp --sport 80 \
            -i enp6s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD  -s 172.19.0.0/16 -p tcp --dport 22 \
            -o enp6s0   -j ACCEPT
iptables -A FORWARD  -d 172.19.0.0/16 -p tcp --sport 22 \
            -i enp6s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD  -s 172.19.0.0/16 -p tcp --dport 2013 \
            -o enp6s0   -j ACCEPT
iptables -A FORWARD  -d 172.19.0.0/16 -p tcp --sport 2013 \
            -i enp6s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD  -s 172.19.0.0/16 -o enp6s0 -j REJECT  #**1**
iptables -A FORWARD  -d 172.19.0.0/16 -i enp6s0 -j REJECT  #**1**

# de la xarxaA només es pot accedir serveis que ofereix la 
# DMZ al servei web
iptables -A FORWARD -s 172.19.0.0/16 -d 172.21.0.0/16 -p tcp \
	    --dport 80 -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/16 -d 172.21.0.0/16 -j REJECT

# redirigir <F5>els ports perquè des de l'exterior es tingui 
# accés a: 3001->hostA1:80, 3002->hostA2:2013, 3003->hostB1:2080,
# 3004->hostB2:2007
iptables -t nat -A PREROUTING -i enp6s0 -p tcp --dport 3001 \
	    -j DNAT --to 172.19.0.2:80
iptables -t nat -A PREROUTING -i enp6s0 -p tcp --dport 3002 \
            -j DNAT --to 172.19.0.3:80
          # Aquests dos primers exercicis no funcionen perquè
	  # el tràfic està tallat a la regla **1**
	  # caldria rectificar les regles **1** o escriure abans
	  # una regla que permeti el tràfic exterior al port
	  # 80 dels hosta A1 i A2 **2**
iptables -t nat -A PREROUTING -i enp6s0 -p tcp --dport 3003 \
            -j DNAT --to 172.20.0.2:80
iptables -t nat -A PREROUTING -i enp6s0 -p tcp --dport 3004 \
            -j DNAT --to 172.20.0.3:80





