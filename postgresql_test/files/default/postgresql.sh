#!/bin/sh
#! /bin/bash
set -x
#SCRIPT SHOULD BE RUN AS ROOT USER.

############################################
#20/06/2018 : Changes to include Binary,  and log path
############################################

sudo clear
if [[ $# -lt 5 ]] ;  then
echo "Usage: $0 #1 #2 #3 #4 #5 #6           "
echo " PostgreVersion	: $1           	    "
echo " binarypath	 	: $2               	"
echo " Datafolder    	: $3       	        "
echo " logfilepath	 	: $4               	"
echo " InstallFolder 	: $5   	            "
echo " Port      	 	: $6   	            "

echo "USAGE:- ./postgresql_install.sh 10.1 /var/lib/postgresql/bin /var/lib/postgresql/data /var/lib/postgresql/log /root/postgresql 5432"
exit 0
fi


#Initialize the Parameters
PostgreVersion=$1
binarypath=$2
DataFolder=$3
logfilepath=$4
InstallFolder=$5
port=${6:-5432}

#Create sysconfig file for systemclt
echo "Creating Systemctl parameters" 
touch /etc/sysconfig/postgresql
echo -e "POSTGRES_DATADIR="$DataFolder/$PostgreVersion"" | tee -a /etc/sysconfig/postgresql
echo -e "POSTGRES_OPTIONS="\"-p $port"\"" | tee -a /etc/sysconfig/postgresql
echo -e "POSTGRES_LOGDIR="$logfilepath/$PostgreVersion""  | tee -a /etc/sysconfig/postgresql
echo -e "POSTGRES_TIMEOUT="600"" | tee -a /etc/sysconfig/postgresql
echo -e "POSTGRE_BINDIR="$binarypath/$PostgreVersion"" | tee -a /etc/sysconfig/postgresql
chmod -R 0644 /etc/sysconfig/postgresql


#Initialize the Installation log file location
LOGFILE=/root/PostgreSQL-$PostgreVersion-Installlogfile.out
#chmod 777  /root/PostgreSQL-$PostgreVersion-Installlogfile.out
if [ $? != 0 ];then
echo "Script execution failed, please validate the logfile..." | tee -a $LOGFILE
echo ""
exit 0
fi
echo "Install logfile path is $LOGFILE...." | tee -a $LOGFILE
echo ""
echo ""
sleep 5s

echo "PostGreSQL Version-$PostgreVersion Installation Details" | tee -a $LOGFILE
echo ""
echo "########################################################"  	| tee -a $LOGFILE
echo " PostgreSQL Version        :        $PostgreVersion " 		| tee -a $LOGFILE
echo " Binary Location           :        $binarypath " 			| tee -a $LOGFILE
echo " Data Folder               :        $DataFolder " 			| tee -a $LOGFILE
echo " Logfilepath               :        $logfilepath " 			| tee -a $LOGFILE
echo " Install Folder            :        $InstallFolder " 			| tee -a $LOGFILE
echo " Portnumber                :        $port " 					| tee -a $LOGFILE
echo "########################################################" 	| tee -a $LOGFILE
echo ""
echo ""
echo ""
echo ""
echo ""
echo 5s

#Create software Directory
echo "Creating software directory"  | tee -a $LOGFILE
if [ ! -d "$InstallFolder/$PostgreVersion" ]  
then
echo "software Folder NOt found...." | tee -a $LOGFILE
echo ""
echo "Creating software Folder...." | tee -a $LOGFILE
sudo mkdir -p  $InstallFolder/$PostgreVersion 
sudo chmod -R 777 $InstallFolder/$PostgreVersion 
if [ $? != 0 ];then
echo "Script execution failed, please validate the logfile..." | tee -a $LOGFILE
exit 1
fi
echo "software Directory created successfully..." | tee -a $LOGFILE
fi
echo ""
echo ""
echo ""
echo ""
#Create Data directory folder
echo "Creating Data Directory Folder" | tee -a $LOGFILE
if [ ! -d "$DataFolder/$PostgreVersion" ]
then
echo "Data folder not found...." | tee -a $LOGFILE
echo ""
sudo mkdir -p  $DataFolder/$PostgreVersion/ 
sudo chmod -R 755 $DataFolder/$PostgreVersion/ 
if [ $? != 0 ];then
echo "Script execution failed, please validate the logfile..." | tee -a $LOGFILE
exit 0
echo ""
exit 0
fi
echo "Data Directory created successfully" | tee -a $LOGFILE
fi
sleep 1s
echo ""
echo ""
echo ""
echo ""
echo ""

#Create executable binary Directory
echo "Validating executable binary directory" | tee -a $LOGFILE
if [ ! -d "$binarypath/$PostgreVersion" ]  
then
echo "Installation Folder Not found...." | tee -a $LOGFILE
echo ""
echo "Creating executable binary Folder...." | tee -a $LOGFILE
sudo mkdir -p  $binarypath/$PostgreVersion 
sudo chmod -R 755 $binarypath/$PostgreVersion
if [ $? != 0 ];then
echo "Script execution failed, please validate the logfile..." | tee -a $LOGFILE
exit 1
fi
echo "Executable binary Directory created successfully..." | tee -a $LOGFILE
fi
echo ""
echo ""
echo ""
echo ""
echo ""


#Create Server Logouput filename 
echo "Creating Server logoutput filename" | tee -a $LOGFILE
if [ ! -d "$logfilepath/$PostgreVersion" ]  
then
echo "File NOt found...." | tee -a $LOGFILE
echo ""
echo "Creating Server logfile path...." | tee -a $LOGFILE
sudo mkdir -p  $logfilepath/$PostgreVersion 
umask 077 $logfilepath/$PostgreVersion 
if [ $? != 0 ];then
echo "Script execution failed, please validate the logfile..." | tee -a $LOGFILE
exit 1
fi
echo "Server Log output file path  created successfully..."
fi
echo ""
echo ""
echo ""
echo ""
echo ""

#Chekcing for wget RPM Packages
sudo rpm -q wget 
if [ $? != 0 ]
then
echo "wget command not found. Installing it...." | tee -a $LOGFILE
sudo zypper -n wget 
fi
echo ""
echo ""
echo ""
echo ""
echo ""
#Download Postgresql tar binaries
echo "Downloading & Unpacking PostgreSQL tarball..." | tee -a $LOGFILE
wget -P $InstallFolder/$PostgreVersion https://ftp.postgresql.org/pub/source/v$PostgreVersion/postgresql-$PostgreVersion.tar.gz  | tee -a $LOGFILE | tee -a $LOGFILE
if [ $? != 0 ];then
echo "Postgresql Binary Download failed...." | tee -a $LOGFILE
exit 0
fi
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Untaring binaries" | tee -a $LOGFILE
tar -zxf $InstallFolder/$PostgreVersion/postgresql-$PostgreVersion.tar.gz -C $InstallFolder/$PostgreVersion > /dev/null
if [ $? != 0 ];then
echo "Untaring binaries not successfull...." | tee -a $LOGFILE
exit 0
fi
sleep 1s
echo ""
echo "Checking availability of pre-required packages" | tee -a $LOGFILE
sleep 1s
echo ""
echo ""
echo ""
echo ""

#Chekcing for Readline RPM Packages
sudo rpm -q readline-devel.x86_64 
if [ $? != 0 ]
then
echo "Readline package not found. Installing it...." 
sudo zypper -n install readline-devel.x86_64 
fi
echo ""
echo ""
echo ""
echo ""
echo ""
#Chekcing for zLib RPM Packages
sudo rpm -q zlib-devel-1.2.3-29.el6.x86_64 
if [ $? != 0 ]
then
echo "zlib package not found. Installing it...." | tee -a $LOGFILE
sudo zypper -n install zlib-devel.x86_64
fi
echo ""
echo ""
echo ""
echo ""
echo ""
#Chekcing for Readline gcc Packages
sudo rpm -q gcc 
if [ $? != 0 ]
then
echo "gcc package not found. Installing it...." | tee -a $LOGFILE
sudo zypper -n install gcc
fi
sleep 1s
echo ""



#PostGreInstallation
echo ""
echo "PostgreSQL-$PostgreVersion Installation Started......" | tee -a $LOGFILE
sleep 1s
cd $InstallFolder/$PostgreVersion/
sudo $InstallFolder/$PostgreVersion/postgresql-$PostgreVersion/configure --prefix=$binarypath/$PostgreVersion/ --bindir=$binarypath/$PostgreVersion >/dev/null
sleep 2s
echo ""
echo "Installer built. Installing it now...." | tee -a $LOGFILE
sudo zypper -n install make > /dev/null
echo "Gmake Install in progress.... " | tee -a $LOGFILE
sudo make install > /dev/null
#sudo zypper update > /dev/null
sudo zypper refresh > /dev/null
echo ""
echo ""

#sudo systemctl enable postgresql | tee -a $LOGFILE
#echo "Starting PostgreSQL services...." 
#echo "Starting PostgreSQL services...." | tee -a $LOGFILE
#sudo systemctl start postgresql | tee -a $LOGFILE
echo ""

#Create PostgreSQL user account
echo "Creating PostGreSQL account.... " | tee -a $LOGFILE
ps -efa|grep -i postgres 
sleep 1s
id -a postgres 
if [ $? != 0 ]
then
echo "postgres user not found. Adding it...." | tee -a $LOGFILE
sudo useradd postgres 
sudo groupadd postgres 
sudo groupadd dba 
sudo /usr/sbin/useradd -m -g postgres -G dba pgsql 
else
echo "postgres user already exists. Proceeding to next step...." | tee -a $LOGFILE
fi


#Start the PostgreSQL services with specified data directory.
echo "Starting PostgreSQL Database services....." | tee -a $LOGFILE
echo ""
echo ""
sleep 1s
chown -R postgres $DataFolder/$PostgreVersion/
chown -R postgres $binarypath/$PostgreVersion
chown -R postgres $logfilepath/$PostgreVersion/
chmod -R 755 $DataFolder/$PostgreVersion/
chmod -R 755 $binarypath/$PostgreVersion/
chmod -R 755 $logfilepath/$PostgreVersion
echo "login to Postgres.."  | tee -a $LOGFILE

su - postgres <<eof
$binarypath/$PostgreVersion/initdb -D $DataFolder/$PostgreVersion/ 
if [ $? != 0 ]
then
echo "Postgres service restart failed.. please validate the logfile..." | tee -a $LOGFILE
exit 0
fi
eof

su - postgres --command "$binarypath/$PostgreVersion/pg_ctl -D $DataFolder/$PostgreVersion/ -o '-p $port' -l $logfilepath/$PostgreVersion/postgres_serverlog.out  start" | tee -a $LOGFILE
if [ $? != 0 ]
then
echo "Postgres service restart failed.. please validate the logfile..." | tee -a $LOGFILE
exit 1
fi


sleep 2s
#Verify if PostGre services is started
cnt=`ps -ef|grep -i postgres | wc -l`
echo "PostgreSQL process =$cnt..." | tee -a $LOGFILE
if [[ $cnt -gt 4 ]]
then
echo "PostgreSQL has started.." | tee -a $LOGFILE
else
echo "PostgreSQL has not started..." | tee -a $LOGFILE
exit 0
fi

echo ""
echo ""
#Display Checking version....
$binarypath/$PostgreVersion/postgres -V | tee -a $LOGFILE
echo ""
echo ""

#Display Log destination folder
$binarypath/$PostgreVersion/psql -U postgres -p $port -c "show log_destination;" | tee -a $LOGFILE
echo ""
echo ""

#Display Data Directory Location
$binarypath/$PostgreVersion/psql -U postgres -p $port -c "show data_directory;" | tee -a $LOGFILE
echo ""
echo ""

#Display Log Directory...."
$binarypath/$PostgreVersion/psql -U postgres -p $port -c "show log_directory;" | tee -a $LOGFILE
echo ""
echo ""
echo "Script executed successfully!" | tee -a $LOGFILE
echo "Script executed successfully!" 



#Process to create files for systemctl
echo " Copying postgresql-script files " | tee -a $LOGFILE
mkdir -p /usr/share/postgresql
chown 0755 -R /usr/share/postgresql
cp /root/postgresql/postgresql-script  /usr/share/postgresql/
chmod -R 0755 /usr/share/postgresql/postgresql-script
chown -R postgres /usr/share/postgresql/postgresql-script
chown -R postgres /etc/sysconfig/postgresql
chmod +x /usr/share/postgresql/postgresql-script

#Process to create postgresql.service file
echo "Creating postgresql.service file..."  | tee -a $LOGFILE
cp /root/postgresql/postgresql.service /usr/lib/systemd/system/
chmod -R 0444 /usr/lib/systemd/system/postgresql.service 
ln -s /usr/lib/systemd/system/postgresql.service /etc/systemd/system/multi-user.target.wants/postgresql.service

#Enable systemctl for postgres
#sudo system daemon-relaod
systemctl enable postgresql
systemctl status postgresql


