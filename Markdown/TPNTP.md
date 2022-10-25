# TP sur le service NTP

### Installation :

Pour installer le paquet NTP:

    sudo apt-get install ntp


### Configuration :

Pour un client NTP, il suffit d'aller dans le ficher /etc/ntp.conf et de décommenter les deux lignes suivantes:



    disable auth

    broadcastclient



Une fois ces deux lignes décommentés NTP est déjà configuré pour le client.

Pour le server NTP, il suffit de regarder le ficher /etc/ntp.conf et d'ajouter une ligne comme ça :



    server votreIPmachine



pour ajouter votre propre horloge système.

Pour gérer le serveur utilisé les commandes de base, c'est à dire :



    sudo service ntp start

    sudo service ntp stop

    sudo servoce ntp restart



### Utilisation:

L'utilisationde NTP est très simple, il vous suffit simplement de faire :



    ntpq -p



Pour afficher la liste de serveur auquel vous êtes connecté. 


Vous pouvez aussi voir les clients connectés à votre propre serveur NTP avec :



  ntpq -c mrulist



Vous avez maintenant de quoi manipuler NTP. Pour plus de préscision, voici des liens utiles:

https://doc.ubuntu-fr.org/ntp

https://www.frameip.com/ntp/
