# TP sur le service NTP

### Installation :

Pour installer le paquet NTP:



	sudo apt-get install bind9

	sudo apt-get install dnsutils



### Configuration :

Pour le serveur DNS, il suffit d'aller dans le ficher /etc/bind/named.conf.options et d'ajouter les lignes suivantes:



	forwarders {

	8.8.8.8;

	};



Qui permet d'utiliser le serveur DNS de Google.

Après ça il faut aller dans le fichier /etc/bind/named.conf et rajouter les trois lignes suivantes:



	include “/etc/bind/named.conf.options”;

	include “/etc/bind/named.conf.local”;

	include “/etc/bind/named.conf.default-zones”;



Il faut ensuite modifier le ficher /etc/bind/named.conf.local pour ajouter une zone DNS:



	zone “example.com” {

	type master;

	file “/etc/bind/db.example.com”;

	};



On crée ensuite un ficher pour la zone via l'exemple db.local:



	sudo cp /etc/bind/db.local /etc/bind/db.example.com



Et on modifie ensuite le ficher config de la nouvelle zone qui s'appelle /etc/bind/db.example.com et on met dedans:


	;

	; BIND data file for example

	;

	\$TTL	604800

	@	IN	SOA	example. root.example.com. (

				2	; Serial

				604800	; Refresh

				86400	; Retry

				2419200	; Expire

				604800)	; Negative Cache TTL

		IN	A	192.168.1.10

	;

	@	IN	NS	ns.example.com.

	@	IN	A	192.168.1.10

	@	IN	AAAA	::1

	ns	IN	A	192.168.1.10



Et on redémarre ensuite le service lié à DNS:



	sudo systemctl restart bin9



Pour l'installation côté client, on modifie le fichier /etc/bind/named.conf.local et on y ajoute:



	zone “10.0.2.in-addr.arpa” {

	type master;

	file “/etc/bind/db.10”;

	};



En remplaçant 10.0.2 par les 3 premiers octets de votre adresse IP. Si votre adresse est 192.168.24.50, il faudra donc écrire 192.168.24 .

On crée ensuite un nouveau ficher de config sur l'exemple du fichier /etc/bind/db.127:



	sudo cp /etc/bind/db.127 /etc/bind/db.10



Et on réecrit ce nouveau fichier avec les lignes suivantes:



	;

	; BIND reverse data file for local 10.0.2.X net

	;

	\$TTL	604800

	@	IN	SOA	ns.example.com root.example.com. (

				2	; Serial

				604800	; Refresh

				86400	; Retry

				2419200	; Expire

				604800)	; Negative Cache TTL

	;

	@	IN	NS	ns.

	10	IN	PTR	ns.example.com.



On redémarre maintenant le service avec la même commande que celle de le configiration DNS du serveur.

### Utilisation:

On peut vérfier que DNS est bien fonctionel sur sa machine avec les commandes suivantes:



	named-checkzone example.com /etc/bind/db.example.com 

	named-checkzone 192.168.0.0/32 /etc/bind/db.10 

	named-checkconf  /etc/bind/named.conf.local 

	named-checkconf  /etc/bind/named.conf



Si toutes ces commandes focntionnent sans renvoyer de codes d'erreurs, alors DNS fonctionnent bien sur votre machine.

Voici quelques liens si vous voulez en savoir plus:

https://www.fosslinux.com/7631/how-to-install-and-configure-dns-on-ubuntu.htm

https://fr.wikipedia.org/wiki/Domain_Name_System
