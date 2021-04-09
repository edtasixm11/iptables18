#! /bin/bash
# @edt ASIX M11-SAD Curs 2020-2021
# iptables: fet a casa amb docker= A-B-Z i extern

#echo 1 > /proc/sys/ipv4/ip_forward

# Regles flush
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# Polítiques per defecte: 
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# obrir el localhost
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# obrir la nostra ip
iptables -A INPUT -s 192.168.1.45 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.45 -j ACCEPT

# Fer NAT per les xarxes internes:
# - 172.21.0.0/24
# - 172.22.0.0/24
# - 10.10.10.0/24
iptables -t nat -A POSTROUTING -s 172.21.0.0/24 -o wlp0s20f3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.22.0.0/24 -o wlp0s20f3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o wlp0s20f3 -j MASQUERADE

# (1) Xarxa A accedir al servei web DMZ
iptables -A FORWARD -s 172.21.0.0/24 -d 10.10.10.2 -p tcp \
	 --dport 80 -j ACCEPT
iptables -A FORWARD -s 10.10.10.2    -d 172.21.0.0/24 -p tcp \
         --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT

# (3) Permetre accés exterior al DNS
iptables -A FORWARD -o wlp0s20f3 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i wlp0s20f3 -p udp --sport 53 -j ACCEPT
iptables -A FORWARD -o wlp0s20f3 -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -i wlp0s20f3 -p tcp --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT


# (2) Xarxa B1 pot navegar (80) per internet (exterior)
iptables -A FORWARD -s 172.22.0.0/24 -o wlp0s20f3 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i wlp0s20f3 -d 172.22.0.0/24 -p tcp --sport 80 \
	 -m state --state RELATED,ESTABLISHED -j ACCEPT


# (4) De la xarxa A es pot accedir a la xarxa B 
# (la resta està tancant pel default  DROP )
## permet tot de A --> B
   iptables -A FORWARD -s 172.21.0.0/24 -d 172.22.0.0/24 -j ACCEPT
## Resposta de B --> A icmp-type-0 
   iptables -A FORWARD -s 172.22.0.0/24 -d 172.21.0.0/24  -p icmp --icmp-type 0 -j ACCEPT
## Resposta de B --> A udp
   iptables -A FORWARD -s 172.22.0.0/24 -d 172.21.0.0/24 -p udp -m state --state RELATED,ESTABLISHED -j ACCEPT
## Resposta de B --> A tcp 
   iptables -A FORWARD -s 172.22.0.0/24 -d 172.21.0.0/24 -p tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
## Trick per accedir a servei UDP
   # - engegegar el servei daytime-dgram i echo-dgram (aturar els stream o en un altre port)
   # - (?) assegurar-se que escolta per udp (ipv4) i no només per udp6 
   #       (si cal posar bind 0.0.0.0)
   # - amb netstat -lun observar que el port udp està obert
   # - amb  ncat -u A.B.C.D  13  accedir al servei (prémer alguna cosa per obtenir resposta) 


# (5) port forwarding 3001 al servei 13 de la dmz1
iptables -A FORWARD -i wlp0s20f3 -d 10.10.10.2 -p tcp --dport 13 -j ACCEPT
iptables -A FORWARD -o wlp0s20f3 -s 10.10.10.2 -p tcp --sport 13 \
         -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 3001 -j DNAT --to 10.10.10.2:13

# (6) pendent exemple de icmp permetre ping de dmz a xarxa b
#      fer altres exemples de icmp


