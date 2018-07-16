#!/bin/sh
set -x
#sCRIPT SHOULD BE RUN AS ROOT USER.

if [[ $# -lt 2 ]] ;  then
echo "Usage: $0 #1 #2"
echo "  #1 datafolder               "
echo "  #2 mysqluser                "
exit 1
fi
#./mysql.sh <mysql-data-folder>

SCRIPTDIR=/root/mysql/SCRIPTS;export SCRIPTDIR
MYSQLUSR=$2;export MYSQLUSR
MYSQLPATH="$HOME/mysql/";export MYSQLPATH
MYSQLBINPATH=/var/mysql/bin;export MYSQLBINPATH
PRIMARY=0
PRIMARYHOST=""
AUTH=0
PASSWORD="password"
LOGFILE=$MYSQLPATH/MONITOR/LOG/mysql.out

uname -a >> $LOGFILE
#Create directories for mysql install
echo "Checking directories for Mysql Install" >> $LOGFILE
ls -ltr /var/mysql
if [ $? != 0 ]
then
echo "Mysql directory not found...." >> $LOGFILE
echo "Creating directories for Mysql Install" >> $LOGFILE
mkdir -p /var/mysql/  
chmod -R 755 /var/mysql/  
file /var/mysql >> $LOGFILE
else
echo "Mysql directory exists.."  >> $LOGFILE
file /var/mysql >> $LOGFILE
fi


PATH=/var/mysql/bin:$PATH;export PATH

if [ ! -z "$1" ]
then
        MYSQLDATAPATH=$1
fi

mkdir -p $MYSQLDATAPATH
chmod -R 755 $MYSQLDATAPATH

#Create mysql group and user
echo "Creating mysql user and mysql GROUP" >> $LOGFILE
id -a mysql
if [ $? != 0 ]
then
echo "mysql user not found. Adding it...." >> $LOGFILE
groupadd dba
groupadd mysql
/usr/sbin/useradd -m -g mysql -G dba mysql
else
echo "mysql user already exists..." >> $LOGFILE
fi

#/usr/sbin/useradd -m -g mysql -G dba mysql
#passwd $PASSWORD

echo "Checking mysql USER FROM Password file" >> $LOGFILE
cat /etc/passwd |grep -i mongo >> $LOGFILE

cd /var
chown -R mysql mysql
chgrp -R mysql mysql
chown -R mysql $MYSQLDATAPATH
chgrp -R mysql $MYSQLDATAPATH

echo "Checking the Mongo install directories.. " >> $LOGFILE
ls -ltr /var |grep ^d >> $LOGFILE
ls -ltr /data |grep ^d >> $LOGFILE

echo "Downloading the server key file ..." >> $LOGFILE
cd $MYSQLBINPATH
wget https://dev.mysql.com/downloads/gpg/?file=mysql-5.7.21-1.sles11.x86_64.rpm-bundle.tar >> $LOGFILE

echo "Installing mysql at '$MYSQLPATH'" >> $LOGFILE
cd $MYSQLPATH

echo "Downloading the ALL mysql ENTERPRISE PACKAGES ..." >> $LOGFILE
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-1.sles11.x86_64.rpm-bundle.tar >> $LOGFILE
wget https://dev.mysql.com/get/mysql57-community-release-sles11-8.noarch.rpm >> $LOGFILE
tar -xvf mysql-5.7.21-1.sles11.x86_64.rpm-bundle.tar >> $LOGFILE

echo "Install the RPM packages into the mysql..." >> $LOGFILE
sudo rpm -Uvh mysql57-community-release-sles11-8.noarch.rpm >> $LOGFILE
sudo rpm -Uvh mysql-community-common-5.7.21-1.sles11.x86_64.rpm >> $LOGFILE
sudo rpm -Uvh mysql-community-embedded-5.7.21-1.sles11.x86_64.rpm >> $LOGFILE
sudo rpm -Uvh mysql-community-libs-5.7.21-1.sles11.x86_64.rpm >> $LOGFILE

zypper lr >> $LOGFILE
zypper in -n mysql-5.7.21-1.sles11.x86_64.rpm-bundle.tar >> $LOGFILE
zypper in -n index.html?file=mysql-5.7.21-1.sles11.x86_64.rpm-bundle.tar >> $LOGFILE
zypper lr >> $LOGFILE

echo "Add repository to mysql..." >> $LOGFILE
zypper repos | grep mysql.*community >> $LOGFILE
zypper repos -E | grep mysql.*community >> $LOGFILE
sudo zypper refresh >> $LOGFILE
zypper lr >> $LOGFILE

echo "Install mysql community server ..." >> $LOGFILE
sudo zypper install -n mysql-community-server >> $LOGFILE

echo "Starting the MYSQL service ..." >> $LOGFILE
sudo service mysql start >> $LOGFILE 

echo "Check the status of mysql.." >> $LOGFILE
sudo service mysql status >> $LOGFILE

echo "Stop the MYSQL service.. " >> $LOGFILE
sudo service mysql stop >> $LOGFILE

echo "Restarting the MYSQL service.. " >> $LOGFILE
sudo service mysql start >> $LOGFILE

echo "Validate the MYSQL process on the server.. " >> $LOGFILE
ps -ef|grep -i my >> $LOGFILE

#mv ./mysql-linux-x86_64-enterprise-suse11-3.6.1/* /var/mysql/
#ln -nfs /var/mysql/bin/mongod /usr/local/sbin

zypper lr >> $LOGFILE

#echo "creating required directories: $MYSQLPATH, $MYSQLPATH/data, $MYSQLPATH/log"
# Ensures the required folders exist for mysql to run properly
#eval "mkdir -p $MYSQLPATH/data"
#eval "mkdir -p $MYSQLPATH/log"

echo "Generating key file with random data at $MYSQLPATH/mysql.key"  >> $LOGFILE
tr -cd '[:alnum:]' < /dev/urandom | fold -w50 | head -n1 > "$MYSQLPATH/mysql.key"  
cp "$MYSQLPATH/mysql.key" $MYSQLBINPATH/ 

chmod 700 "$MYSQLPATH/mysql.key" "$MYSQLBINPATH/mysql.key"

#echo "creating mongo config"
#printf "storage:\n    dbPath: %s/data\n systemLog:\n    destination: file\n    path: %s/log/mongod.log\n logAppend: true\n
#processManagement:\n fork: true\n replication:\n replSetName: myitsocial\n net:\n http:\n enabled: false" "$MYSQLPATH" 


#echo "Update the mongod.conf file ...." >> $LOGFILE
#printf "\nsecurity:\n    keyFile: %s/mongo.key" "$MYSQLBINPATH" >> /etc/mongod.conf

#echo "creating mysql service"
#cd /etc/init.d/ || exit
#chmod +x mysql

cnt=`ps -ef|grep -i mysql |wc -l` 
echo "MYSQL process =$cnt..." >> $LOGFILE

if [[ $cnt -gt 1 ]]
then
echo "mysql has started.." >> $LOGFILE
else
echo "mysql has not started..." >> $LOGFILE
fi

sleep 10s
exit 0
