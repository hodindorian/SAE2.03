export testerror=0
testApache2() {
 	vdn-ssh root@$1 '
	echo ""
	echo "----------Test Apache2----------" 
	test=$(lynx -dump http://localhost/index.html -auth=root:sae)         	#put the test to access to the server web of debian-1 with an authentification in variable test 
	test2=$(lynx -dump http://localhost/index.html 2>/dev/null)			  	#put the test to access to the server web of debian-1 without an authentification in variable test1
	test=$(echo $test | tr -d "")											#Remove the space from the variable test	
	test2=$(echo $test2| tr -d "")											#Remove the space from the variable test2	
	bontruc="Welcome to the web server of debian-1"							#expected result from the lynx command	
	if [ -z $test2 ] ;then													#we send the error output to /dev/null, soif test2 is null, protected http works	
		if [ "$test" = "$bontruc" ];then								    #second verification, we try if the expected result is in test	
			echo "Protected HTTP is working."								#if protected http works	
		else
			echo "ERROR: Protected HTTP is not working."					#opposite case	
			testerror=$testerror+1											#counting how many error did the script make	
			exit 1
		fi
	else
		echo "ERROR: Protected HTTP is not working."						#opposite case	
		testerror=$testerror+1												#counting how many error did the script make
		exit 1
	fi
	'
}
testBaseConfig() { 
   	vdn-ssh test@$1 '
	   	echo ""
		echo "----------Test Base Config----------" 
   		if [ $(hostname) != "debian-1" ]; then								#test if the hostname is debian-1	
   			echo "ERROR : Hostname is not valid !" >&2					 	#if its not write ERROR
			testerror=$testerror+1											#counting how many error did the script make
   			exit 1															#and exit the test	
        else
            echo "Hostname is good."										#else write hostanme is good	
   		fi
   		if ! ping -c 1 '$1' &> /dev/null; then								#ping debian-1 to test if the ip->name is working	
   			echo "ERROR : Cant join '$1' !" >&2								#if its not write ERROR
			testerror=$testerror+1											#counting how many error did the script make
   			exit 1															#and exit the test	
        else 	
            echo "The base config is good."									#else write the base config is good	
   		fi
   	'
}
     
testNFS() {
	vdn-ssh root@$1 '
	echo ""
	echo "----------Test NFS----------" 
	if [ -n "ls /mnt/nfs01" ] ;then											#we mount in /mnt/nfs01 the directory /var/nfs01, so if we find /var/nfs01 files in /mnt/nfs01, NFS is working	
		echo "NFS is working."												#write nfs is working	
	else
		echo "ERROR : NFS is not working."									#else write ERROR 	
		testerror=$testerror+1												#counting how many error did the script make
	fi 

	'
}

testFTP() {
	vdn-ssh root@$1 '
	echo ""
	echo "----------Test FTP----------" 
	user="anonymous"														#Try to connect to FTP with anonymous cause anonymous FTP is configured on this machine
	pass=" "																#for anonymous log, the password is nothing, so " "
	#connecting to FTP
	ftp -n -v '$1'<< EOT																														
	user $user $pass														
	bye																		
EOT
#close the FTP connection. If the connection is successfull, FTP is working
#the line user $user $pass log you with the user anonymous and with his password
'
}

testSSH() {
	vdn-ssh root@$1 ' 	
	echo ""
	echo "----------Test SSH----------" 
	timeout 5 bash -c "</dev/tcp/debian-1/22"								#with this command, i test the activity of the ports 22. This ports is dedicated for SSH connection
	if [ $? = 0 ] ;then														#if the return code is 0, that mean the ports 22 is active, so SSH is working
		echo "SSH is working."
	else																	#else the return code is not 0 so the ports 22 is not active, that mean SSH is not working
		echo "ERROR: SSH is not working"
		testerror=$testerror+1												#counting how many error did the script make
		exit 1
	fi
	'
} 

testDNS() {
	vdn-ssh root@$1 ' 	
		echo ""
		echo "----------------Test DNS----------------"
		nslookup example.com  &>/dev/null									#this commande test the connection to a DNS server
		if [ $? = 0 ];then													#if the return code of the last line is 0	
			echo "DNS is working" 											#that mean DNS is working so the script write this
		else
			echo "ERROR: DNS is not working"								#else that mean DNS is not working, write ERROR
			testerror=$testerror+1											#counting how many error did the script make
		fi
		echo ""
	'
} 

testNTP() {
	vdn-ssh root@$1 '
	echo ""
	echo "----------------Test NTP-----------------"
	expected="debian-1.INIT.16u-"											#this is the line we have to find to see if NTP works (without space between the different part)
	final=$(ntpq -p|tail -n 1|tr -d " "| cut -c 1-18)						#this is the results of the command ntpq -p, but only the last line(other line are just display) and without space	
	if [ $final = $expected ];then											#if the expected results and the command output are the same
		echo "NTP is working"												#that mean NTP is working	
	else
		echo "ERROR: NTP is not working"									#else NTP is not working	
		testerror=$testerror+1												#counting how many error did the script make
	fi
	echo ""
	'
} 
# main
    
HOSTNAME=debian-1
IP=10.0.2.15
testBaseConfig $HOSTNAME
testApache2 $HOSTNAME
testNFS $HOSTNAME
testFTP $HOSTNAME
testSSH $HOSTNAME   
testDNS $HOSTNAME 
testNTP $HOSTNAME
echo "################ End of the test script ################"


