# iptables
## @ edt ASIX M11-SAD Curs 2018-2019

Podeu trobar les imatges docker al Dockehub de [edtasixm11](https://hub.docker.com/u/edtasixm11/)

Podeu trobar la documentació del mòdul a [ASIX-M11](https://sites.google.com/site/asixm11edt/)

ASIX M06-ASO Escola del treball de barcelona

Exemples  d'iptables

 * **ip-default.sh**

   Accions bàsiques de configuració d'un script de iptables:
   * Esborar les regles (flush)  i comptadors actuals
   * Regles per defecte
   * Obrir la connectivitat pròpia al loopback i a la propia adreça ip
   * Definir si el host fa de router

 * **ip-01-input.sh** 

    Regles INPUT.

    Exemples bàsics de filtrats INPUT. Jugant amb el port 80
    s'han redefinit ports alternatius on aplicar regles de filtrat d'entrada. 
    Les clàssiques regles
    * Port obert a tothom
    * Port tancat a tothom amb reject
    * Port tancat a tothom amb drop
    * Port tancat a tothom excepte hostA
    * Port obert a tothom excepte hostA
    * Port tancat a tothom excepte xarxaA (obert), però no al seu hostA (tancat)
    * Port obert a tothom excepte xarxaA (tancat), però no al seu hostA (obert)
    * Port obert per defecte, tancat a la xarxaA i obert als seus hosts hostA, hostB i hostC
     * barrera per defecte: tancar els altrs ports

 * **ip-02-output.sh**

    Regles OUTPUT.

    Exemples bàsics de filtrats OUTPUT. Jugant amb el port 13
    s'han redefinit ports alternatius on aplicar regles de filtrat de sortida.
    Les clàssiques regles
    * Accedir a qualsevol port/destí
    * Accedir al portA de qualsevol destí
    * Accés permès al portA a qualsevol destí excepte hostA (denegat)
    * Accés denegat al portA a qualsevol destí  excepte hostA (permès)
    * Accés permès al portA a qualsevol destí excepte xarxaA (denegat)
    * Accés denegat al portA a qualsevol destí excepte xarxaA (permès)
    * Accés permès al portA a qualsevol destí, excepte de xarxaA (denegat)
      exceptuant hostA (permès)
    * Accés denegat al portA a qualsevol destí, excepte xarxaA (permès) 
      exceptuant hostA (denegat)
    * Denegat l'accés als ports externs 80, 13 i 7.
    * Denegat qualsevol tipus d'accés a les xarxes destí xarxaA i xarxaB
    * Denegat qualsevol tipus d'accés als hosts hostA, hostB i hostC
    * Denegat qualsevol accés extern a la xarxaA excepte si és per ssh.

 * **ip-03-established.sh**

    Identificar tràfic de resposta (RELATED, ESTABLISHED).
    * Permetre "navegar per internet". És a dir, accedir a qualsevol servidor
      web extern i ecceptar només les respostes.
    * "Ser un servidor web". permetre que accedeixin al nostre servei web i 
      permetre únicament les respostes de sortida.

 * **ip-04-icmp.sh**

    Tràfic ICMP de ping request (8) i ping reply (0).
    * No permetre fer pings a l'exterior.
    * No permetre fer pings al host i26.
    * No respondre als pings que ens facin
    * No acceptem, rebre respostes ping

 * **ip-05-nat.sh**
    
    Activar NAT per a dues xarxes internes. Podem crear dues xarxes (xarxaA i xarxaB) 
    de docker i engegar dos hosts (edtasixm11/net18:nethost) a cada xarxa. 
    * Verificar que 'abans de fer res' els hosts de docker tenen accés extern i a internet.
    * Eliminar totes les refles de iptables aplicant ip-default.sh. Ara els hosts són
      interns, no es fa nat, per tant no tenen accés a l'exterior (i26, 8.8.8.8, etc).
    * Aplicar NAT per a les dues xarxes. verificar que tornen a tenir connectivitat a l'exterior.
       
```
docker network create netA netB netZ
docker run --rm --name hostA1 -h hostA1 --net netA --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostA2 -h hostA2 --net netA --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostB1 -h hostB1 --net netB --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostB2 -h hostB2 --net netB --privileged -d edtasixm11/net18:nethost
```


 * **ip-06-forward.sh**

    Definir regles de forwarding. Usar configuració de host/router amb dues subxarxes
    xarxaA i xarxaB fetes amb dos hosts de docker cada una.
    * No deixar sortir de la lan a exterior a serveis concrets
    * No deixar sortir de la lan a exterior segons destí
    * Un host de la lan concret no pot accedir a un servei extern (segons destí)
    * Evitar que des de dins de la LAN es falsifiqui ip origen (spoofing
    * Evitar que tràfic extern entri a la lan

 * **ip-07-ports.sh**
    
    Refinir regles de port/host forwarding.
    * ports del router/firewall que porten a hosts de la lan
    * port forwarding també en funció de la ip origen

 * **ip-08-dmz.sh**

    Configurar un host/router amb dues xarxes privades locals xarxaA i xarxaB i una
    tercera xarxa DMZ amb servidors. Implementar-ho amb containers i xarxes docker.

   Implementeu el següent firewall:
    * de la xarxaA només es pot accedir del router/fireall als serveis: ssh i  daytime(13)
    * de la xarxaA només es pot accedir a l'exterior als serveis web,  ssh  i daytime(2013)
    * de la xarxaA només es pot accedir   serveis que ofereix la DMZ al servei web
    * redirigir els ports perquè des de l'exterior es tingui accés a: 3001->hostA1:80, 
      3002->hostA2:2013, 3003->hostB1:2080,3004->hostB2:2007
    * S'habiliten els ports 4001 en endavant per accedir per ssh als ports ssh de: hostA1,
      hostA2, hostB1, hostB2.
    * S'habilita el port 4000 per accedir al port ssh del router/firewal si la ip origen és 
      del host i26.
    * Els hosts de la xarxaB tenen accés a tot arreu excepte a la xarxaA.


```
docker network create netA netB netZ
docker run --rm --name hostA1 -h hostA1 --net netA --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostA2 -h hostA2 --net netA --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostB1 -h hostB1 --net netB --privileged -d edtasixm11/net18:nethost
docker run --rm --name hostB2 -h hostB2 --net netB --privileged -d edtasixm11/net18:nethost
docker run --rm --name dmz1 -h dmz1 --net netDMZ --privileged -d edtasixm11/net18:nethost
docker run --rm --name dmz2 -h dmz2 --net netDMZ --privileged -d edtasixm06/ldapserver:18group
docker run --rm --name dmz3 -h dmz3 --net netDMZ --privileged -d edtasixm11/k18:kserver
docker run --rm --name dmz4 -h dmz4 --net netDMZ --privileged -d edtasixm06/samba:18detach
```
  

 * AWS EC2

 * firewalld



