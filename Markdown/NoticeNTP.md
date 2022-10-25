# Notice d'Utilisation du service NTP

###### NTP est un service réseau crée en 1985 qui permet de une synchronisation des horloges sytèmes à la nano-seconde près.

## Informations génerales:

La version la plus récente de NTP est la version 4 sortie en juin 2010. Le protocole NTP a été inventé à l'Université du Delaware par un professeur, David L. Mills avec l'aide de nombreux bénévoles. 

La version la plus répendue de NTP est la version 3 sortie en 1992.
NTP veut dire lettre pour lettre Network Time Protocol, qui est un dérivé de Time Protocol qui est aussi un service de synchronisation des horloges sytemes mais moins précis et performant.

L'horloge de NTP est défnit depuis 1967 sur le temps atomique à jet de césium.

## Utilité :

NTP n'as pas l'air d'être très utile pour les communications entre dfférentes machines en réseau, mais pourtant c'est presque indispensable. En effet, synchroniser les horloges systemes permet d'éviter de nombreuses erreurs pendant le transfert de ficher via d'autre protocole (DNS,SSH,etc..).

Par exemple, la commande make se base sur les heures de modification des fichiers, les fichers logs utilisent aussi la date système, et plein d'autres fonctions se référent à l'horloge système.

Par conséquent, si les horloges systèmes ne sont pas toutes syncrhonisés à la même nanoseconde près, cela peut entrainer de nombreux souci lors de la communication en réseau de ces machines.

NTP sert aussi à réaliser des connections via de la cryptographie avec la géneration de clés. 

La synchronisation des horloges sytèmes n'as pas l'air utile quand on la mentionne comme ça mais cependant, c'est indispensable à chaque ordinateur qui voudrait se connecter en réseau avec d'autres machines.