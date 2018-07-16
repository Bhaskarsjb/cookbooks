#!/bin/sh
set -x
#######################################################################################
# OWNER : TCS - CLOUD INFRA UNIT
# Program: Install_Mysql_Sles.sh
# Purpose of script: Install_Mysql_Sles.sh script installs mysql database
# Usage script: Script to run as root user ,it dynamically creates mysql directories 
# USAGE:- ./Install_Mysql_Sles.sh /data02/db mysql
# Created: Jan - 2018
#######################################################################################
#SCRIPT SHOULD BE RUN AS ROOT USER.
if [[ $# -lt 2 ]] ;  then
echo "Usage: $0 #1 #2"
echo "  #1 datafolder               "
echo "  #2 mysqluser                "
exit 1
fi
#./mysql.sh <mysql-data-folder>


#MYSQLBASE=/data/db/MYSQL;export MYSQLBASE
DATE=`date +"%Y%m%d_%H%M%S"`;export DATE
MYSQLPATH=/data/db/MYSQL;export MYSQLPATH
SCRIPTDIR=$MYSQLPATH/scripts;export SCRIPTDIR
MYSQLUSR=$2;export MYSQLUSR
MYSQLBINPATH=/var/mysql/bin;export MYSQLBINPATH
PRIMARY=0
PRIMARYHOST=""
AUTH=0
PASSWORD="password"
LOGFILE=$MYSQLPATH/LOG/Install_Mysql_Sles_$DATE.out
uname -a >> $LOGFILE

export PATH=/usr/bin:/usr/sbin:$PATH

echo "Checking for GLIBC library packages ...." >> $LOGFILE
sleep 1s
sudo rpm -q glibc-2.1.2 >> $LOGFILE
if [ $? != 0 ]
then
echo "GLIBC packages not found.Installing GLIBC libraries at '$MONGOPATH'" >> $LOGFILE
cd $MYSQLPATH
mkdir PKG
chmod 755 PKG
cd PKG
wget http://ftp.gnu.org/gnu/glibc/glibc-2.1.2.tar.gz >> $LOGFILE
tar -xzvf glibc-2.1.2.tar.gz >> $LOGFILE
cd glibc-2.1.2
HOST=`rpm --eval %{_host}`
echo $HOST >> $LOGFILE
./configure --prefix=/tools/glibc-2.12
make j2
make -j2 install
cd libio
/lib64/libpthread.so.0
else
echo "GLIBC packages already exists ..." >> $LOGFILE
fi

echo "checking for cyrus-sasl packages ..." >> $LOGFILE
sudo rpm -q cyrus-sasl >> $LOGFILE
if [ $? != 0 ]
then
echo "CYRUS pkgs not found.Installing cyrus packages.." >>$LOGFILE
cd $MONGOPATH/PKG
zypper addrepo https://download.opensuse.org/repositories/network/SLE_12_SP3/network.repo
zypper refresh|echo 'a'
zypper in cyrus-sasl 
else
echo "CYRUS pkgs already exists ..." >> $LOGFILE
fi

#Create directories for mysql install
echo "Checking directories for Mysql Install" >> $LOGFILE
ls -ltr /var/mysql
if [ $? != 0 ]
then
echo "Mysql directory not found...." >> $LOGFILE
echo "Creating directories for Mysql Install" >> $LOGFILE
mkdir -p /var/mysql/bin/
chmod -R 755 /var/mysql/bin/
file /var/mysql >> $LOGFILE
else
echo "Mysql directory exists.."  >> $LOGFILE
file /var/mysql >> $LOGFILE
fi

#PATH=/var/mysql/bin:$PATH;export PATH
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
#/usr/sbin/useradd -m -g mysql -G dba mysql
useradd -r -g mysql -s /bin/false mysql
else
echo "mysql user already exists..." >> $LOGFILE
fi
#/usr/sbin/useradd -m -g mysql -G dba mysql
#passwd $PASSWORD

echo "Checking mysql USER FROM Password file" >> $LOGFILE
cat /etc/passwd |grep -i mysql >> $LOGFILE
cd /var
chown -R mysql mysql
chgrp -R mysql mysql
chown -R mysql $MYSQLDATAPATH
chgrp -R mysql $MYSQLDATAPATH

echo "Checking the Mongo install directories.. " >> $LOGFILE
ls -ltr /var |grep ^d >> $LOGFILE
ls -ltr /data |grep ^d >> $LOGFILE
ls -ltr /data02/db |grep ^d >> $LOGFILE

echo "Downloading the server key file ..." >> $LOGFILE
cd $MYSQLBINPATH
#wget https://dev.mysql.com/downloads/gpg/?file=mysql-5.7.21-1.sles12.x86_64.rpm-bundle.tar >> $LOGFILE
#ls *.asc >> $LOGFILE
#sudo rpm --import *.asc >> $LOGFILE
wget http://repo.mysql.com/RPM-GPG-KEY-mysql >>$LOGFILE
rpm --import RPM-GPG-KEY-mysql >> $LOGFILE

zypper update -y  >> $LOGFILE
zypper refresh >> $LOGFILE

sudo rpm -qa |grep -i mysql >> $LOGFILE
if [ $? != 0 ]
then
echo "mysql-enterprise package not found. Installing it...." >> $LOGFILE
cd $MYSQLPATH/PKG
echo "Downloading the ALL mysql ENTERPRISE PACKAGES ..." >> $LOGFILE
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-1.sles12.x86_64.rpm-bundle.tar >> $LOGFILE
wget https://dev.mysql.com//get/Downloads/MySQL-5.7/mysql-community-server-5.7.21-1.sles12.x86_64.rpm >> $LOGFILE
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-libs-5.7.21-1.sles12.x86_64.rpm >> $LOGFILE
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-embedded-5.7.21-1.sles12.x86_64.rpm >> $LOGFILE
wget https://dev.mysql.com/get/mysql57-community-release-sles12-11.noarch.rpm >> $LOGFILE
tar -xvf mysql-5.7.21-1.sles12.x86_64.rpm-bundle.tar >> $LOGFILE
else
echo "Mysql-enterprise package found......" >> $LOGFILE
fi

echo "Install the RPM packages into the mysql..." >> $LOGFILE
#sudo rpm -Uvh mysql-community-server-5.7.21-1.sles12.x86_64.rpm >> $LOGFILE
#sudo rpm -Uvh mysql57-community-release-sles12-11.noarch.rpm >> $LOGFILE
#sudo rpm -Uvh mysql-community-common-5.7.21-1.sles12.x86_64.rpm >> $LOGFILE
#sudo rpm -Uvh mysql-community-embedded-5.7.21-1.sles12.x86_64.rpm >> $LOGFILE
#sudo rpm -Uvh mysql-community-libs-5.7.21-1.sles12.x86_64.rpm >> $LOGFILE
cd $MYSQLPATH/PKG
ls -ltr $MYSQLPATH/PKG/*.rpm|awk '{print $9}' > rpm.lst
cat rpm.lst|while read line
do
sudo rpm -Uvh $line >> $LOGFILE
done
echo "Check for the rpm installed.." >> $LOGFILE
rpm_cnt=`rpm -qa|grep mysql|wc -l`
if [ $? != 8 ]
then
echo "Rerun the RPM PACKAGES..." >> $LOGFILE
cat rpm.lst|while read line
do
sudo rpm -Uvh $line >> $LOGFILE
done
else
echo " All RPM PACKAGES HAVE BEEN INSTALLED.." >> $LOGFILE
fi

zypper lr >> $LOGFILE

echo "Install mysql community server ..." >> $LOGFILE
zypper in  -y mysql-community-server >> $LOGFILE
zypper lr >> $LOGFILE

echo "Add repository to mysql..." >> $LOGFILE
zypper repos | grep -i mysql.*community >> $LOGFILE
zypper repos -E | grep -i mysql.*community >> $LOGFILE
sudo zypper refresh >> $LOGFILE

zypper lr >> $LOGFILE
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

zypper lr >> $LOGFILE

echo "Generating key file with random data at $MYSQLPATH/mysql.key"  >> $LOGFILE
tr -cd '[:alnum:]' < /dev/urandom | fold -w50 | head -n1 > "$MYSQLPATH/mysql.key"
cp "$MYSQLPATH/mysql.key" $MYSQLBINPATH/
chmod 700 "$MYSQLPATH/mysql.key" "$MYSQLBINPATH/mysql.key"

echo "creating mysql service" >> $LOGFILE
cd /etc/init.d/ || exit
chmod +x mysql
UP=$(sudo service mysql status|grep running|grep -v not|wc -l);
#UP=$(/etc/init.d/mysql status|grep running| grep -v not|wc -l);
if [ "$UP" -ne 1 ];
then
        echo "MySQL is down."; >> $LOGFILE
else
echo "mysql is running..." >> $LOGFILE
fi
sleep 5

PASS1=`sudo grep 'temporary password' /var/log/mysql/mysqld.log|cut -d ":" -f4`
mysql -u root --password=$PASS1 --connect-expired-password <<EOF >> $LOGFILE
ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';
SHOW DATABASES;
EOF

NPWD=MyNewPass4!;export NPWD
#echo $PASS > PASS
echo "    " >> /etc/my.cnf
echo "[mysql]" >> /etc/my.cnf
echo "user=root" >> /etc/my.cnf
echo "password=$NPWD" >> /etc/my.cnf
mysql -uroot -e show databases >> $LOGFILE
exit 0
