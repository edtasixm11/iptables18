# iptables
## @ edt ASIX M11-SAD Curs 2018-2019

Exemples  d'iptables

 * **ip-default.sh**

   Accions bàsiques de configuració d'un script de iptables:
   * Esborar les regles (flush)  i comptadors actuals
   * Regles per defecte
   * Obrir la connectivitat pròpia al loopback i a la propia adreça ip
   * Definir si el host fa de router

 * **io-basic-01.sh** 

    Regles INPUT.

    Exemples bàsics de filtrats INPUT. Jugant amb el port 80
    s'ha redefinit ports alternatius on aplicar regles de filtrat d'entrada. 
    Les clàssiques regles
    * Port obert a tothom
    * Port tancat a tothom amb reject
    * Port tancat a tothom amb drop
    * Port tancat a tothom excepte hostA
    * Port obert a tothom excepte hostA
    * Port tancat a tothom excepte xarxaA (obert), però no al seu hostA (tancat)
    * Port obert a tothom excepte xarxaA (tancat), però no al seu hostA (obert)
    * Port obert per defecte, tancat a la xarxaA i obert als seus hosts hostA, hostB i hostC





