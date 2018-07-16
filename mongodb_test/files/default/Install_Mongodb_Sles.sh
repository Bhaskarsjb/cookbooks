#!/bin/sh
set -x
#SCRIPT SHOULD BE RUN AS ROOT USER.
#######################################################################################
# OWNER : TCS - CLOUD INFRA UNIT
# Program: Install_mongo_sles.sh 
# Purpose of script: Install_mongo_sles.sh script installs mongodb standalone
# Usage script: Script to run as root user ,it dynamically creates mongodb directories 
# USAGE:- ./Mongo_install.sh /data01/db mongodb sles12 3.6.2
# Created: Jan - 2018
#######################################################################################

if [[ $# -lt 4 ]] ;  then
echo "Usage: $0 #1 #2 #3 #4"
echo "  #1 datafolder               "
echo "  #2 mongouser                "
echo "  #3 osversion                "
echo "  #4 dbversion                "
echo "USAGE:- ./Mongo_install.sh /data01/db mongodb suse12 3.6.2"
exit 1
fi

MONGOBASE=/data/db;export MONGOBASE
SCRIPTDIR=/data/db/mongodb/Install_Mongodb;export SCRIPTDIR
MONGOUSER=$2;export MONGOUSER
OSVER=$3;export OSVER
DBVER=$4;export DBVER
MONGOPATH=$MONGOBASE/mongodb;export MONGOPATH
MONGOBINPATH=/var/mongodb/bin;export MONGOBINPATH
PRIMARY=0
PRIMARYHOST=""
AUTH=0
PASSWORD="password"
DATE=`date +"%Y%m%d_%H%M%S"`
LOGFILE=$MONGOPATH/LOG/install_mongodb_${DBVER}_${DATE}.out

uname -a >> $LOGFILE
#Create directories for mongodb install
echo "Checking directories for MongoDB Install" >> $LOGFILE
ls -ltr /var/mongodb
if [ $? != 0 ]
then
echo "Mongodb directory not found...." >> $LOGFILE
echo "Creating directories for MongoDB Install" >> $LOGFILE
mkdir -p /var/mongodb/
chmod -R 755 /var/mongodb/
file /var/mongodb >> $LOGFILE
else
echo "Mongodb directory exists.."  >> $LOGFILE
file /var/mongodb >> $LOGFILE
fi

PATH=/var/mongodb/bin:$PATH;export PATH
if [ ! -z "$1" ]
then
        MONGODATAPATH=$1
fi
mkdir -p $MONGODATAPATH
chmod -R 755 $MONGODATAPATH

#Create mongodb group and user
echo "Check Mongodb user/group from /etc/passwd" >> $LOGFILE
id -a mongodb
if [ $? != 0 ]
then
echo "mongodb user not found. creating mongodb user...." >> $LOGFILE
groupadd dba
groupadd mongodb
/usr/sbin/useradd -m -g mongodb -G dba mongodb
#/usr/sbin/useradd -r -g mongodb -s /bin/false mongodb
else
echo "mongodb user already exists..." >> $LOGFILE
fi

echo "Checking MONGODB USER FROM Password file" >> $LOGFILE
cat /etc/passwd |grep -i mongo >> $LOGFILE

echo "Change the ownership under /var/mongodb.. " >> $LOGFILE
cd /var
chown -R $MONGOUSER mongodb
chgrp -R mongodb mongodb
chown -R mongodb $MONGODATAPATH
chgrp -R mongodb $MONGODATAPATH

echo "Checking the Mongo install directories.. " >> $LOGFILE
ls -ltr /var |grep ^d >> $LOGFILE
ls -ltr /data |grep ^d >> $LOGFILE
ls -ltr $MONGODATAPATH |grep ^d >> $LOGFILE

zypper update -y  >> $LOGFILE
zypper refresh >> $LOGFILE

echo "Checking for GLIBC library packages ...." >> $LOGFILE
sleep 1s
sudo rpm -q glibc-2.1.2 >> $LOGFILE
if [ $? != 0 ]
then
echo "GLIBC packages not found.Installing GLIBC libraries at '$MONGOPATH'" >> $LOGFILE
cd $MONGOPATH
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

echo "Checking availability of Mongodb packages" >>$LOGFILE
sleep 1s
sudo rpm -q mongodb-enterprise >> $LOGFILE
if [ $? != 0 ]
then
echo "mongodb-enterprise package not found. Installing it...." >> $LOGFILE
cd $MONGOPATH/PKG
wget https://downloads.mongodb.com/linux/mongodb-linux-x86_64-enterprise-${OSVER}-${DBVER}.tgz >> $LOGFILE
tar -zxvf "mongodb-linux-x86_64-enterprise-${OSVER}-${DBVER}.tgz"  >> $LOGFILE
mv ./mongodb-linux-x86_64-enterprise-${OSVER}-${DBVER}/* /var/mongodb/
ln -nfs /var/mongodb/bin/mongod /usr/local/sbin
else
echo "mongodb-enterprise package found ..." $LOGFILE
fi

echo "Downloading the server key file ..." >> $LOGFILE
cd $MONGOBINPATH
KEY=`echo $DBVER|cut -c1-3`;export KEY
echo $KEY >> $LOGFILE
curl -LO https://www.mongodb.org/static/pgp/server-${KEY}.asc  >> $LOGFILE
gpg --import server-${KEY}.asc  >> $LOGFILE

echo "Downloading the Signature file...." >> $LOGFILE
curl -LO https://downloads.mongodb.com/linux/mongodb-linux-x86_64-enterprise-${OSVER}-${DBVER}.tgz.sig >> $LOGFILE

echo "Verify the signature file with mongoinstallfile.." >> $LOGFILE
gpg --verify mongodb-linux-x86_64-enterprise-${OSVER}-${DBVER}.tgz.sig $MONGOPATH/PKG/mongodb-linux-x86_64-enterprise-${OSVER}-${DBVER}.tgz  >> $LOGFILE

zypper lr >> $LOGFILE
OS=`echo $OSVER|cut -c5-6`;export OS
echo $OS >> $LOGFILE
echo "Add repository to mongodb..." >> $LOGFILE
sudo zypper addrepo --gpgcheck "https://repo.mongodb.com/zypper/suse/$OS/mongodb-enterprise/${KEY}/x86_64/" 'mongodb${DBVER}'>>$LOGFILE

zypper lr >> $LOGFILE

echo "Downloading the ALL MONGODB ENTERPRISE PACKAGES ..." >> $LOGFILE
wget https://repo.mongodb.com/zypper/suse/$OS/mongodb-enterprise/${KEY}/x86_64/RPMS/mongodb-enterprise-server-${DBVER}-1.${OSVER}.x86_64.rpm >> $LOGFILE
wget https://repo.mongodb.com/zypper/suse/$OS/mongodb-enterprise/${KEY}/x86_64/RPMS/mongodb-enterprise-mongos-${DBVER}-1.${OSVER}.x86_64.rpm >> $LOGFILE
wget https://repo.mongodb.com/zypper/suse/$OS/mongodb-enterprise/${KEY}/x86_64/RPMS/mongodb-enterprise-tools-${DBVER}-1.${OSVER}.x86_64.rpm >> $LOGFILE
wget https://repo.mongodb.com/zypper/suse/$OS/mongodb-enterprise/${KEY}/x86_64/RPMS/mongodb-enterprise-shell-${DBVER}-1.${OSVER}.x86_64.rpm >> $LOGFILE
chmod 777 *.rpm

echo "Install the packages into the Mongodb..." >> $LOGFILE
sudo zypper --no-gpg-checks in -y mongodb-enterprise-server-${DBVER}-1.${OSVER}.x86_64.rpm >> $LOGFILE
sudo zypper --no-gpg-checks in -y mongodb-enterprise-mongos-${DBVER}-1.${OSVER}.x86_64.rpm >> $LOGFILE
sudo zypper --no-gpg-checks in -y mongodb-enterprise-shell-${DBVER}-1.${OSVER}.x86_64.rpm >> $LOGFILE
sudo zypper --no-gpg-checks in -y mongodb-enterprise-tools-${DBVER}-1.${OSVER}.x86_64.rpm >> $LOGFILE

echo "Install Mongodb Enterprise ..." >> $LOGFILE
sudo zypper --no-gpg-checks in -y mongodb-enterprise >> $LOGFILE

#echo "creating required directories: $MONGOPATH, $MONGOPATH/data, $MONGOPATH/log"
# Ensures the required folders exist for MongoDB to run properly
#eval "mkdir -p $MONGOPATH/data"
#eval "mkdir -p $MONGOPATH/log"

echo "Checking for Mongo.key file from $MONGOPATH" >> $LOGFILE
ls -ltr $MONGOPATH/mongo.key
if [ $? != 0 ]
then
echo "Mongo.key file not found...." $LOGFILE
echo "Generating key file with random data at $MONGOPATH/mongo.key"  >> $LOGFILE
tr -cd '[:alnum:]' < /dev/urandom | fold -w50 | head -n1 > "$MONGOPATH/mongo.key"
cp "$MONGOPATH/mongo.key" $MONGOBINPATH/
chmod 700 "$MONGOPATH/mongo.key" "$MONGOBINPATH/mongo.key"
else
echo "Mongo.key file exists.." >> $LOGFILE
fi

#echo "creating mongo config"
#printf "storage:\n    dbPath: %s/data\n systemLog:\n    destination: file\n    path: %s/log/mongod.log\n logAppend: true\n
#processManagement:\n fork: true\n replication:\n replSetName: myitsocial\n net:\n http:\n enabled: false" "$MONGOPATH"
#"$MONGOPATH" > /etc/mongod.conf

#echo "Update the mongod.conf file ...." >> $LOGFILE
#printf "\nsecurity:\n    keyFile: %s/mongo.key" "$MONGOBINPATH" >> /etc/mongod.conf
#printf "\nsecurity:\n    authorization: enabled\n setParameter:\n    enableLocalhostAuthBypass: true" >> /etc/mongod.conf

echo "Change dbPath in config file .." >> $LOGFILE
sed 's+/var/lib/mongodb+$MONGODATAPATH+g' /etc/mongod.conf >/etc/mongod.tmp
mv /etc/mongod.tmp /etc/mongod.conf

datapath=`cat /etc/mongod.conf |grep 'dbPath'`
dbpath=`echo $datapath |cut -d ":" -f2`
if [[ $dbpath = '$MONGODATAPATH' ]]
then
echo "dbPath in Config file has been modified to ($dbpath).." >> $LOGFILE
else
echo "dbPath in Configfile is referring to /var/lib/mongodb" >> $LOGFILE
fi

echo "creating mongodb service"
# Renames it to mongodb and makes it executable
#cp ./mongoservice.sh /etc/init.d/mongodb
#cp /etc/init.d/gistfile /etc/init.d/mongodb
cd /etc/init.d/ || exit
chmod +x mongodb

# Starts up MongoDB right now
echo "Start the MONGODB SERVICE..." >> $LOGFILE
/var/mongodb/bin/mongod -f /etc/mongod.conf >> $LOGFILE

cnt=`ps -ef|grep -i mongo |wc -l`
echo "Mongo process =$cnt..." >> $LOGFILE

if [[ $cnt -gt 1 ]]
then
echo "Mongodb has started sucessfully.." >> $LOGFILE
else
echo "Mongodb has not started..." >> $LOGFILE
fi

sleep 10s
exit 0

