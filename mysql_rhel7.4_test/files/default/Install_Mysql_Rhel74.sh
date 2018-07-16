#!/bin/sh
set -x
#######################################################################################
# OWNER : TCS - CLOUD INFRA UNIT
# Program: Install_Mysql_Rhel74.sh
# Purpose of script: Install_Mysql_Rhel74.sh script installs mysql database on RHEL7.4 .
# Usage script: Script to run as root user ,it dynamically creates mysql directories
# USAGE:- ./Install_Mysql_Rhel74.sh /data02/db mysql
# Created: Mar - 2018
#######################################################################################
#SCRIPT SHOULD BE RUN AS ROOT USER.

if [[ $# -lt 2 ]] ;  then
echo "Usage: $0 #1 #2"
echo "  #1 datafolder               "
echo "  #2 mysqluser                "
exit 1
fi
#./mysql.sh <mysql-data-folder>

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

echo "Checking for wget pkgs.." >> $LOGFILE
sudo rpm -qa |grep -i wget >> $LOGFILE
if [ $? != 0 ]
then
echo "wget packages not found.Installing wget pkgs" >> $LOGFILE
yum install -y wget >> $LOGFILE
else
echo "wget packages already exists ..." >> $LOGFILE
fi

echo "Checking for GLIBC library packages ...." >> $LOGFILE
sleep 1s
sudo rpm -q glibc-2.1.2 >> $LOGFILE
if [ $? != 0 ]
then
echo "GLIBC packages not found.Installing GLIBC libraries at '$MYSQLPATH'" >> $LOGFILE
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

echo "Checking mysql USER FROM Password file" >> $LOGFILE
cat /etc/passwd |grep -i mysql >> $LOGFILE
cd /var
chown -R mysql mysql
chgrp -R mysql mysql
chown -R mysql $MYSQLDATAPATH
chgrp -R mysql $MYSQLDATAPATH

echo "Checking the mysql install directories.. " >> $LOGFILE
ls -ltr /var |grep ^d >> $LOGFILE
ls -ltr /data |grep ^d >> $LOGFILE
ls -ltr /data01/db |grep ^d >> $LOGFILE

echo "Downloading the server key file ..." >> $LOGFILE
cd $MYSQLBINPATH
#wget http://repo.mysql.com/RPM-GPG-KEY-mysql >>$LOGFILE
#rpm --import RPM-GPG-KEY-mysql >> $LOGFILE

sudo rpm -qa |grep -i mysql >> $LOGFILE
if [ $? != 0 ]
then
echo "mysql package not found. Installing it...." >> $LOGFILE
cd $MYSQLPATH/PKG
echo "Downloading the MYSQL community pkgs..." >> $LOGFILE
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm >> $LOGFILE
sudo yum localinstall -y mysql57-community-release-el7-11.noarch.rpm >> $LOGFILE
else
echo "Mysql-community package found......" >> $LOGFILE
fi

echo "Install mysql community server ..." >> $LOGFILE
sudo yum install -y mysql-community-server >> $LOGFILE

echo "Add repository to mysql..." >> $LOGFILE
yum repolist enabled | grep "mysql.*-community.*" >> $LOGFILE
yum repolist all | grep mysql >> $LOGFILE

echo "Starting the MYSQL service ..." >> $LOGFILE
sudo service mysqld start >> $LOGFILE
echo "Check the status of mysql.." >> $LOGFILE
sudo service mysqld status >> $LOGFILE
echo "Stop the MYSQL service.. " >> $LOGFILE
sudo service mysqld stop >> $LOGFILE
echo "Restarting the MYSQL service.. " >> $LOGFILE
sudo service mysqld start >> $LOGFILE
echo "Validate the MYSQL process on the server.. " >> $LOGFILE
ps -ef|grep -i my >> $LOGFILE

echo "Generating key file with random data at $MYSQLPATH/mysql.key"  >> $LOGFILE
tr -cd '[:alnum:]' < /dev/urandom | fold -w50 | head -n1 > "$MYSQLPATH/mysql.key"
cp "$MYSQLPATH/mysql.key" $MYSQLBINPATH/
chmod 700 "$MYSQLPATH/mysql.key" "$MYSQLBINPATH/mysql.key"

echo "creating mysql service" >> $LOGFILE
cd /etc/init.d/ || exit
chmod +x mysql
#UP=$(/etc/init.d/mysql status|grep running| grep -v not|wc -l);
UP=$(ps -efa|grep -i mysqld|wc -l);
if [ "$UP" -lt 1 ];
then
        echo "MySQL is down."; >> $LOGFILE
else
echo "mysql is running..." >> $LOGFILE
fi
sleep 10

pass=`sudo grep 'temporary password' /var/log/mysqld.log|cut -d ":" -f4|tr -d '[:space:]'`
echo $pass
mysql -uroot --password=${pass} --connect-expired-password <<EOF >> $LOGFILE
ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';
SHOW DATABASES;
EOF

NPWD=MyNewPass4!;export NPWD
#echo $PASS > PASS
echo "    " >> /etc/my.cnf
echo "[mysql]" >> /etc/my.cnf
echo "user=root" >> /etc/my.cnf
echo "password=$NPWD" >> /etc/my.cnf
mysql -uroot -e "show databases" >> $LOGFILE

exit 0
