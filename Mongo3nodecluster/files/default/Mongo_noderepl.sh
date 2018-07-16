set -x
# This script will start three shards, a config server and a mongos, all on the current machine.
# The first time you run it, pass this variable for the initial setup:
#     FIRST_TIME=1 bash ./startShardedCluster.sh
# In future you can just start the servers like this:
#     bash ./startShardedCluster.sh
if [[ $# -lt 1 ]] ;  then
echo "Usage: $0 #1 #2"
echo "  #1 remoteip1 remoteip2  "
echo "USAGE:- ./Mongo_noderepl.sh 10.1.13.23 10.1.13.22"
exit 1
fi

#dbname=$1;export dbname
HOME=/data/db;export HOME
MONGOPATH=/data/db/mongodb;export MONGOPATH
DATE=`date +"%Y%m%d_%H%M%S"`;export DATE
LOGFILE=$MONGOPATH/LOG/MongoShrdng_$DATE.log

expected_count=5
cd "$(dirname $0)"
local_ip="$(/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1 |grep -v inet6|awk '{print $2}'|tr -d "addr:"|head -n 1)"
remote_ip1="$1"
remote_ip2="$2"

echo $local_ip >> $LOGFILE
echo $remote_ip1 >> $LOGFILE
echo $remote_ip2 >> $LOGFILE

echo $HOME
ls -ltr $MONGOPATH/log
if [ $? != 0 ]
then
echo "log directory doesnot exists.. Creating log directory.." >> $LOGFILE
mkdir -p $MONGOPATH/log
else
echo "$MONGOPATH/log already exists.." >> $LOGFILE
fi

ls -ltr $HOME/dbData/configdb
if [ $? != 0 ]
then
echo "Configdb directory doesnot exists.. Creating configdb dir..." >> $LOGFILE
mkdir -p $HOME/dbData/configdb
else
echo "$HOME/dbData/configdb already exists.." >> $LOGFILE
fi

ls -ltr $HOME/dbData/db0-0
if [ $? != 0 ]
then
echo "Data dir0 doesnot exists.. Creating Data dir0.." >> $LOGFILE
mkdir -p $HOME/dbData/db0-0
else
echo "$HOME/dbData/db0-0 already exists.." >> $LOGFILE
fi

ls -ltr $HOME/dbData/db1-0
if [ $? != 0 ]
then
echo "Data dir0 doesnot exists.. Creating Data dir1.." >> $LOGFILE
mkdir -p $HOME/dbData/db1-0
else
echo "$HOME/dbData/db1-0 already exists.." >> $LOGFILE
fi

ls -ltr $HOME/dbData/db2-0
if [ $? != 0 ]
then
echo "Data dir0 doesnot exists.. Creating Data dir2.." >> $LOGFILE
mkdir -p $HOME/dbData/db2-0
else
echo "$HOME/dbData/db2-0 already exists.." >> $LOGFILE
fi

ps -ef|grep -i mongo
if [ $? != 0 ]
then
echo "Mongo processes are not running currently" >> $LOGFILE
else
echo "Mongo processes are currently running ..Killing the process.." >> $LOGFILE
pkill -u $UID mongod || true
pkill -u $UID mongos || true
fi

#/etc/init.d/mongodb stop
mongod -f /etc/mongod.conf --shutdown
echo "backup the mongod.conf file .." >> $LOGFILE
echo "Setting the new mongod.conf file for Configreplset and Clustering" >> $LOGFILE
mv /etc/mongod.conf /etc/mongod.conf_bkup$$
touch /etc/mongod.conf
chmod 755 /etc/mongod.conf
echo "# mongod.conf" >> /etc/mongod.conf
echo "systemLog:" >> /etc/mongod.conf
echo "  destination: file" >> /etc/mongod.conf
echo "  logAppend: true" >> /etc/mongod.conf
echo "  path: /var/log/mongodb/mongod.log" >> /etc/mongod.conf
echo " " >> /etc/mongod.conf
echo "storage:" >> /etc/mongod.conf
echo "  dbPath: /var/lib/mongo" >> /etc/mongod.conf
echo "  journal:" >> /etc/mongod.conf
echo "    enabled: true" >> /etc/mongod.conf
echo "#  engine:" >> /etc/mongod.conf
echo "#  mmapv1:" >> /etc/mongod.conf
echo "#  wiredTiger:" >> /etc/mongod.conf
echo " " >> /etc/mongod.conf
echo "processManagement:" >> /etc/mongod.conf
echo "  fork: true " >> /etc/mongod.conf
echo "  pidFilePath: /var/run/mongodb/mongod.pid " >> /etc/mongod.conf
echo "  timeZoneInfo: /usr/share/zoneinfo" >> /etc/mongod.conf
echo " " >> /etc/mongod.conf
echo "net:" >> /etc/mongod.conf
echo "  port: 27017" >> /etc/mongod.conf
echo "  bindIp: 127.0.0.1,${local_ip}" >> /etc/mongod.conf
echo " " >> /etc/mongod.conf
echo "replication:" >> /etc/mongod.conf
echo "  replSetName: confreplset" >> /etc/mongod.conf
echo " " >> /etc/mongod.conf
echo "sharding:" >> /etc/mongod.conf
echo "  clusterRole: configsvr" >> /etc/mongod.conf
sleep 10
echo "Starting the mongodb after config settings" >> $LOGFILE
#cat /etc/mongod.conf|grep replSetName
#if [ $? != 0 ]
#then
#echo "Mongo conf for replication is not set. Setting the replicaiton" >> $LOGFILE
#echo "   " >> /etc/mongod.conf
#echo "replication:" >> /etc/mongod.conf
#echo "  oplogSizeMB: 256" >> /etc/mongo.conf
#echo "  replSetName: mongorepl" >> /etc/mongod.conf
#echo "   " >> /etc/mongod.conf
#else
#echo "Mongo conf for replication is already set.." >>$LOGFILE
#fi

#cat /etc/mongod.conf|grep clusterRole
#if [ $? != 0 ]
#then
#echo "Sharding params is not set in conf file.. Setting the configsvr param.." >> $LOGFILE
#echo "sharding:" >> /etc/mongod.conf
#echo "  clusterRole: configsvr" >> /etc/mongod.conf
#echo "   " >> /etc/mongod.conf
#else
#echo "Mongo conf for Sharding is already set.." >>$LOGFILE
#fi
#/etc/init.d/mongodb start
mongod -f /etc/mongod.conf
sleep 5


echo "Login into Remote server using $remote_ip1 ..." >> $LOGFILE
ssh root@$remote_ip1 <<EOF >> $LOGFILE
#/etc/init.d/mongodb stop
mongod -f /etc/mongod.conf --shutdown
sleep 5

echo "backup the mongod.conf file .." 
echo "Setting the new mongod.conf file for Configreplset and Clustering"
mv /etc/mongod.conf /etc/mongod.conf_bkup$$
touch /etc/mongod.conf
chmod 755 /etc/mongod.conf
echo "# mongod.conf" >> /etc/mongod.conf
echo "systemLog:" >> /etc/mongod.conf
echo "  destination: file" >> /etc/mongod.conf
echo "  logAppend: true" >> /etc/mongod.conf
echo "  path: /var/log/mongodb/mongod.log" >> /etc/mongod.conf
echo " " >> /etc/mongod.conf
echo "storage:" >> /etc/mongod.conf
echo "  dbPath: /var/lib/mongo" >> /etc/mongod.conf
echo "  journal:" >> /etc/mongod.conf
echo "    enabled: true" >> /etc/mongod.conf
echo "#  engine:" >> /etc/mongod.conf
echo "#  mmapv1:" >> /etc/mongod.conf
echo "#  wiredTiger:" >> /etc/mongod.conf
echo "" >> /etc/mongod.conf
echo "processManagement:" >> /etc/mongod.conf
echo "  fork: true " >> /etc/mongod.conf
echo "  pidFilePath: /var/run/mongodb/mongod.pid " >> /etc/mongod.conf
echo "  timeZoneInfo: /usr/share/zoneinfo" >> /etc/mongod.conf
echo "" >> /etc/mongod.conf
echo "net:" >> /etc/mongod.conf
echo "  port: 27017" >> /etc/mongod.conf
echo "  bindIp: 127.0.0.1,${remote_ip1}" >> /etc/mongod.conf
echo "" >> /etc/mongod.conf
echo "replication:" >> /etc/mongod.conf
echo "  replSetName: confreplset" >> /etc/mongod.conf
echo "" >> /etc/mongod.conf
echo "sharding:" >> /etc/mongod.conf
echo "  clusterRole: configsvr" >> /etc/mongod.conf
sleep 10

echo "Starting the mongodb after config settings"

#/etc/init.d/mongodb start
mongod -f /etc/mongod.conf
EOF
sleep 5

echo "Login into Remote server using $remote_ip2 ..." >> $LOGFILE
ssh root@$remote_ip2 <<EOF >> $LOGFILE
#/etc/init.d/mongodb stop
mongod -f /etc/mongod.conf --shutdown
sleep 5

echo "backup the mongod.conf file .."
echo "Setting the new mongod.conf file for Configreplset and Clustering"
mv /etc/mongod.conf /etc/mongod.conf_bkup$$
touch /etc/mongod.conf
chmod 755 /etc/mongod.conf
echo "# mongod.conf" >> /etc/mongod.conf
echo "systemLog:" >> /etc/mongod.conf
echo "  destination: file" >> /etc/mongod.conf
echo "  logAppend: true" >> /etc/mongod.conf
echo "  path: /var/log/mongodb/mongod.log" >> /etc/mongod.conf
echo " " >> /etc/mongod.conf
echo "storage:" >> /etc/mongod.conf
echo "  dbPath: /var/lib/mongo" >> /etc/mongod.conf
echo "  journal:" >> /etc/mongod.conf
echo "    enabled: true" >> /etc/mongod.conf
echo "#  engine:" >> /etc/mongod.conf
echo "#  mmapv1:" >> /etc/mongod.conf
echo "#  wiredTiger:" >> /etc/mongod.conf
echo "" >> /etc/mongod.conf
echo "processManagement:" >> /etc/mongod.conf
echo "  fork: true " >> /etc/mongod.conf
echo "  pidFilePath: /var/run/mongodb/mongod.pid " >> /etc/mongod.conf
echo "  timeZoneInfo: /usr/share/zoneinfo" >> /etc/mongod.conf
echo "" >> /etc/mongod.conf
echo "net:" >> /etc/mongod.conf
echo "  port: 27017" >> /etc/mongod.conf
echo "  bindIp: 127.0.0.1,${remote_ip2}" >> /etc/mongod.conf
echo "" >> /etc/mongod.conf
echo "replication:" >> /etc/mongod.conf
echo "  replSetName: confreplset" >> /etc/mongod.conf
echo "" >> /etc/mongod.conf
echo "sharding:" >> /etc/mongod.conf
echo "  clusterRole: configsvr" >> /etc/mongod.conf
sleep 10

#/etc/init.d/mongodb start
mongod -f /etc/mongod.conf
EOF
sleep 5

replset=`cat /etc/mongod.conf|grep replSetName|cut -d":" -f2|tr -d '[:space:]'`;export replset
mongo --port 27017 -u mongoadmin -p admin --authenticationDatabase admin << ! >> $LOGFILE
rs.initiate({ _id: "${replset}", configsvr: true,
...    members: [ { _id: 0, host: "${local_ip}:27017" },
...       { _id: 1, host: "${remote_ip1}:27017" },
...       { _id: 2, host: "${remote_ip2}:27017" }]});
db.isMaster();
rs.status();
!

#config="{_id:"${replset}",configsvr: true, members: [
#... ... {_id: 0, host: "${local_ip}:27017"},{ _id: 1, host: "${remote_ip1}:27017" },{ _id: 2, host: "${remote_ip2}:27017" }]}";
#rs.initiate(config);
#db.isMaster();
#rs.status();
#!


sleep 20
echo "Checking for the primary server in the configuration.." >> $LOGFILE
mongo --port 27017 << eof >> masterip.lst
db.isMaster();
eof
primary=`cat masterip.lst|grep 'primary'|cut -d ":" -f2 |cut -d '"' -f2`

echo $primary >> $LOGFILE
echo "login into primary server to test the sample table creation and replication .." >> $LOGFILE
if [[ $primary = $local_ip ]]
then 
#ssh root@$primary <<EOF >> $LOGFILE
mongo --port 27017 -u mongoadmin -p admin --authenticationDatabase admin << ! >> $LOGFILE
use admin;
for (var i = 1; i <= 500; i++) db.exampleCollection.insert( { x : i } );
db.exampleCollection.find();
!
else
echo "Check for $primary.." >> $LOGFILE
fi
sleep 5

if [[ $primary = $local_ip ]]
then 
serv2=$remote_ip1;export server2
serv3=$remote_ip2;export server3
else
serv2=$local_ip;export serv2
serv3=$remote_ip1;export serv3
fi

echo "checking for the sample table replication at local_ip $serv2.." >> $LOGFILE
mongo --port 27017 -u mongoadmin -p admin --authenticationDatabase admin << ! >> $LOGFILE
use admin;
rs.slaveOk();
rs.slaveOk();
show tables;
db.exampleCollection.find();
!
sleep 5

echo "Login into remote server using $serv3 to check the replicated table.." >> $LOGFILE
ssh root@$serv3 <<EOF >> $LOGFILE
mongo --port 27017 -u mongoadmin -p admin --authenticationDatabase admin << !
use admin
rs.slaveOk();
rs.slaveOk();
show tables;
db.exampleCollection.find();
!
EOF

#echo "Login into remote server using $remote_ip2 to check the replicated table.." >> $LOGFILE
#ssh root@$remote_ip2 <<EOF >> $LOGFILE
#mongo --port 27017 -u mongoadmin -p admin --authenticationDatabase admin << !
#use admin
#rs.slaveOk();
#rs.slaveOk();
#show tables;
#db.exampleCollection.find();
#!
#EOF
exit 0
