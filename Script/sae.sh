#!/bin/sh  
echo "\n\n"
echo '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ START OF ALL THE SCRIPT ////////////////' 
echo ""
echo "############### Starting the configuration script of debian-1 ###############"
./init203

configNTP() {
	vdn-ssh root@$1 '
	echo ""
	echo "----------------Configuration of NTP----------------"
	echo""
	apt-get install -y ntp															#install the ntp package
	cat << NTPCONF > /etc/ntp.conf													#write in ntp.conf and put the IP of debian-1 to synchronise all system clock
driftfile /var/lib/ntp/ntp.drift
leapfile /usr/share/zoneinfo/leap-seconds.list
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable
server '$2'
restrict -4 default kod notrap nomodify nopeer noquery limited
restrict -6 default kod notrap nomodify nopeer noquery limited
restrict 127.0.0.1
restrict ::1
restrict source notrap nomodify noquery
NTPCONF
		#end of the writing of the new ntp.conf file							
		service ntp restart															#restarting the ntp service to refresh ntp
		echo "NTP is now active"													#write "ntp is now active" to indicate the end of the NTP configuration
		echo ""

	'
}
 
	
baseConfig() {
    vdn-ssh root@$1 '	
		echo ""
		echo "----------------Configuration IP and Hostname of '$1'----------------"
		echo ""
    		echo '$1' > /etc/hostname										#put the name of the machine in the hostname file
    		hostname -F /etc/hostname    
    		if ! grep -q '$2' /etc/hosts; then								#if the configuration ip->hostname is not in the file /etc/hosts
    			echo '$2 $1' >> /etc/hosts									#write the configuration ip->hostname
    		fi
		echo "IP and Hostname configured"									#write "Ip and Hostname configured" to indicate the end of the IP/Hostnameconfiguration
		echo ""
		echo "----------------Creating the user toto----------------"
		echo ""
		useradd -m toto --create-home										#creating the user toto and his home directory
		pos=$(pwd)															#put the actual position in the variable pos cause we have to be in this directory for some steps later
		echo toto:sae | chpasswd											#change the password for toto to sae
		echo "Password of toto is now: sae"  								#write this to indicate the new password
		if [ -d mnt ]														#check if the directory mtn exists
		then
			umount -f mnt													#if yes umount the directory and
			rm -R mnt														#remove it
		fi 
		mkdir mnt															#create the directory mnt
		mkdir mnt/nfs01														#create the directory nfs01 in the directory mnt
		cd /var																#go in the directory var
		if [ -d nfs01 ]														#check if the directory nfs01 exists
		then 
			rm -R nfs01														#if yes remove it
		fi
		mkdir /var/nfs01													#and create this directory again
 		echo "toto" > /var/nfs01/toto										#create the file toto and write toto in the file
		cd $pos																#go back in the last directory, we save his position before
		apt-get install -y vim												#installing vim to gain the ability to modify file
		apt-get update -y													#update all the packages in the machine
	 	apt-get full-upgrade -y												#download all the updates of the machine
		echo ""
	'
}



configNFS() {
	vdn-ssh root@$1 '
		echo "----------------Configuration of NFS----------------"
		echo ""
		apt-get install -y nfs-kernel-server												#install nfs-kernel-server packages for server
		cd /home/toto																		#go to the directory /home/toto, the home of the user toto
		echo "/var/nfs01 *(rw,sync,no_subtree_check,no_root_squash)" > /etc/exports			#write in /etc/exports this line who allows NFS to work on the machine by adding the folder to share with this service
		exportfs -a																			#reload the NFS config
		systemctl enable nfs-kernel-server													#enable the NFS service when the machine starts
		apt-get install -y nfs-common														#install nfs-common packages for client
		mount -t nfs debian-1:/var/nfs01 /mnt/nfs01											#mount the directory /var/nfs01 in the directory /mnt/nfs01
		echo "debian-1:/var/nfs01		/mnt/nfs01		nfs" >> /etc/fstab					#write in /etc/fstab this line who allows the mounting of /var/nfs01 when the machine starts
 		echo ""
		echo "----------------End of the base configuration and the NFSs configuration of '$1'---------------"
		echo ""
    '
}



configApache2() {
	vdn-ssh root@$1 "
	apt-get install -y apache2 lynx													#install the packages apache2 and lynx
	#The next echo fill the apache2.conf file with the correct configuration
	echo '#Base config of apache2:
	
Mutex file:\${APACHE_LOCK_DIR} default

PidFile \${APACHE_PID_FILE}

Timeout 300

KeepAlive On

MaxKeepAliveRequests 100

KeepAliveTimeout 5

User \${APACHE_RUN_USER}
Group \${APACHE_RUN_GROUP}

HostnameLookups Off

ErrorLog \${APACHE_LOG_DIR}/error.log

LogLevel warn

IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf

Include ports.conf

<Directory />
        Options FollowSymLinks
        AllowOverride None
        Require all granted
</Directory>

<Directory /usr/share>
        AllowOverride None
        Require all granted
</Directory>

#End of the first base configuration of apache2.conf,now the modification

#For this section, I put AllowOverride to All for force apache2 to check the access before entering the website in /var/www
#And I put Require to user root for allow only the user root to access the website

<Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require user root
</Directory>

#The next line indicates where the security instructions for accessing the site are stored

AccessFileName .htaccess

#Second part of base config of apache2.conf

<FilesMatch \"^\.ht\">
        Require all denied
</FilesMatch>

<Files ~ \"^\.ht\">
    Order allow,deny
    Deny from all
</Files>

LogFormat \"%v:%p %h %l %u %t \\\"%r\\\" %>s %O \\\"%{Referer}i\\\" \\\"%{User-Agent}i\\\"\" vhost_combined
LogFormat \"%h %l %u %t \\\"%r\\\" %>s %O \\\"%{Referer}i\\\" \\\"%{User-Agent}i\\\"\" combined
LogFormat \"%h %l %u %t \\\"%r\\\" %>s %O\" common
LogFormat \"%{Referer}i -> %U\" referer
LogFormat \"%{User-agent}i\" agent

IncludeOptional conf-enabled/*.conf

IncludeOptional sites-enabled/*.conf

' > /etc/apache2/apache2.conf								#End of the new config file of apache2
"
    	vdn-ssh root@$1 '
		echo ""
		echo "----------------Downloading of the server apache2 and lynx----------------"
		echo "apache2 and lynx are now download"										#write this line to be sure the scrip works
     	echo ""
		echo "----------------Creating of index.html and filling of this file---------------"
		echo ""
		#the next part write in the file /var/www/html/index.html the minimal config to display a web page
   		cat << EOF > /var/www/html/index.html
<html>
<body>
<align=left>Welcome to the web server of '$1'</align>
</body>
</html>
EOF
		echo "index.html configured and fill in the directory /var/www/html"
		echo ""
    	echo "--------------Configuration of the secutiry of index.html-------------"
		echo ""
		cd /var/www/html
        cat << DONE > /var/www/html/.htaccess 				#write in the file .htaccess the following lines
AuthType Basic
AuthUserFile /etc/apache2/users
AuthName "Private Access"
Require user root
DONE
		cd /etc/apache2										#go to the directory /etc/apache2
		echo "sae" |htpasswd -i -c users root				#create an apache2 user with the login root and the password sae
		echo "Password to access index.html is now sae"
		echo "Security of index.html active"				#write this line to be sure the script end correctly
		systemctl restart apache2							#restart apache2 to reload all the config files
		echo ""
	'
}



configFTP() {
	vdn-ssh root@$1 '
		echo "-------------Configuration of FTP-------------"
		echo ""
		apt-get install -y vsftpd									#install the vsftpf packages for FTP
		apt-get install -y ftp										#and install FTP
		#the next part write the new config file of vsftpd
		cat << FTPCONF > /etc/vsftpd.conf	
listen=NO

listen_ipv6=YES

#the next line enable anonymous login to FTP. Exepts this line I dont change anything else

anonymous_enable=YES

local_enable=YES

dirmessage_enable=YES

use_localtime=YES

xferlog_enable=YES

connect_from_port_20=YES

secure_chroot_dir=/var/run/vsftpd/empty

pam_service_name=vsftpd

rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem

rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key

ssl_enable=NO

FTPCONF
		systemctl restart vsftpd									#restart vsftpd to reload it
		echo ""	
	'
}

configSSH() {
	vdn-ssh root@$1 '
		echo ""
		echo "----------------Configuration of SSH----------------"
		echo ""
		cd /home/toto														#go to the directory /home/toto
		if [ -d .ssh ];then													#if the directory .ssh exists
			rm -R .ssh														#remove it and all the file inside
		fi
		mkdir /home/toto/.ssh												#and create the directory .ssh in /home/toto
		cd /root/.ssh														#go in this new directory
		rm /root/.ssh/sshkey /root/.ssh/sshkey.pub							#remove the old ssh keys	
		ssh-keygen -b 2048 -t rsa -f /root/.ssh/sshkey -q -N ""				#and generate ssh keys in this new directory without passphrase with -N
		cat > /home/toto/.ssh/authorized_keys < ~/.ssh/sshkey.pub			#write in authorized_keys the new SSH key to allows the machine to ssh itself
		systemctl restart ssh												#restart ssh to load the new config
		echo "SSH is now active."											#and write this line to be sure the script end correctly
		echo ""
	'
}

configDNS(){
	vdn-ssh root@$1 '
		apt-get install -y bind9											#install the bind9
		apt-get install -y dnsutils											#and the dnsutils packages
		#the next part write in the new config file of DNS
		cat << DNSCONF > /etc/bind/named.conf.options
options {
	directory "/var/cache/bind";
	#The next 3 lines allows the machine to use the Googles DNS
	forwarders {
		8.8.8.8;
	};
	dnssec-validation auto;
	auth-nxdomain no;
	listen-on-v6 { any; };
};
DNSCONF
		#The next part include all the conf file to make it work
		cat << DNSCONF > /etc/bind/named.conf
include “/etc/bind/named.conf.options”;
include “/etc/bind/named.conf.local”;
include “/etc/bind/named.conf.default-zones”;
DNSCONF
		systemctl restart bind9												#restart bind9 to reload the file
		#next lines write in /etc/bind/names.conf.local a new DNS zone
		cat << DNSCONF > /etc/bind/named.conf.local
zone "example.com" {
	type master;
	file "/etc/bind/db.example.com";
};
DNSCONF
		cp /etc/bind/db.local /etc/bind/db.example.com						#creating a new file for the new zone
		#and adding more lines to make the zone that we created before works
		cat << DNSCONF >> /etc/bind/db.example.com
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
DNSCONF
	systemctl restart bind9													#restart again bind9
	#write again in the file named.conf.local
	newIP=$(echo '$2'|cut -d "." -f 1-3 )									#cut the actual IP to keep only the 3 first octets
	cat << DNSCONF >> /etc/bind/named.conf.local
#The 10.0.2 have to be replace by the first three octets of your IP, so the IP of this machine is 10.0.2.15 so we keep 10.0.2
zone "$newIP.in-addr.arpa" {
	type master;
	file "/etc/bind/db.10";
};
DNSCONF
		cp /etc/bind/db.127 /etc/bind/db.10									#create the new file db.10 from the model db.127
		#and add the next lines in this file to configure it
		cat << DNSCONF >> /etc/bind/db.10
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
DNSCONF
		systemctl restart bind9												#restart for the last time bind9
	'
}
     
# main

HOSTNAME=debian-1
IP=10.0.2.15
#Next lines start all the config 
baseConfig $HOSTNAME $IP
configNFS $HOSTNAME
configApache2 $HOSTNAME
configFTP $HOSTNAME   
configNTP $HOSTNAME $IP
configSSH $HOSTNAME
configDNS $HOSTNAME $IP
echo "\n\n\n"
echo "############## End of configuration script #############"
echo "\n\n\n"
echo "############## Start of machine configuration testing ##############"
echo "\n\n\n"
#Start the test script
./test.sh
echo "\n\n\n"
echo '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ END OF ALL THE SCRIPT ////////////////'
echo ""