#!/bin/sh
set -x
#SCRIPT SHOULD BE RUN AS ROOT USER.
############################################################################################
# OWNER : TCS - CLOUD INFRA UNIT
# Program: MongoShrdng.sh
# Purpose of script: MongoShrdng.sh script sets up sharding on current configsrvr
# Usage script: Script to run as root user,it will start two shards,
# all on a single node with single Replicaset.
# USAGE:- ./MongoShrdng.sh <dbname>
# Created: Feb - 2018
############################################################################################
#
if [[ $# -lt 1 ]] ;  then
echo "Usage: $0 #1 "
echo "  #1 dbname  "
echo "USAGE:- ./MongoShrdng.sh testdb"
exit 1
fi

dbname=$1;export dbname
HOME=/data/db;export HOME
MONGOPATH=/data/db/mongodb;export MONGOPATH
DATE=`date +"%Y%m%d_%H%M%S"`;export DATE
LOGFILE=$MONGOPATH/LOG/MongoShrdng_$DATE.log
expected_count=3
cd "$(dirname $0)"
local_ip="$(/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1 |grep -v inet6|awk '{print $2}'|tr -d "addr:"|head -n 1)"
echo $local_ip >> $LOGFILE
echo $HOME
ls -ltr $MONGOPATH/LOG
if [ $? != 0 ]
then
echo "log directory doesnot exists.. Creating log directory.." >> $LOGFILE
mkdir -p $MONGOPATH/LOG
else
echo "$MONGOPATH/LOG already exists.." >> $LOGFILE
fi

ls -ltr $HOME/dbData/configdb
if [ $? != 0 ]
then
echo "Configdb directory doesnot exists.. Creating configdb dir..." >> $LOGFILE
mkdir -p $HOME/dbData/configdb
else
echo "$HOME/dbData/configdb already exists.." >> $LOGFILE
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

sleep 5

mongod --shardsvr --replSet mongorepl --dbpath $MONGOPATH/dbData/configdb --port 27017 --logpath $MONGOPATH/LOG/mongodshrads.log --logappend --fork >> $LOGFILE
sleep 5
#mongo localhost:27017 << !
#rs.initiate({_id: "mongorepl", configsvr: true, members: [{_id: 0, host: "${local_ip}:27028"}]});
#!

mongo localhost:27017 << !
rs.initiate({_id: "mongorepl", members: [{_id: 0, host: "${local_ip}:27017"}, {_id: 1, host: "${local_ip}:27018"}]});

db.isMaster();
rs.status();
!

#mongo --port 27017 << ! >> $LOGFILE
#config = {_id:"mongorepl", members: [
#... ... {_id: 0, host: "localhost:27017"},
#... ... {_id: 1, host: "localhost:27018"},
#... ... {_id: 2, host: "localhost:27019"}]
#... ... };

#rs.initiate(config);
#db.isMaster();
#rs.status();
#!
#mongos --port 10003 --configdb localhost:10002 
mongos --port 27018 --configdb mongorepl/localhost:27017 --fork --logpath $MONGOPATH/LOG/mongos.log & >> $LOGFILE
sleep 5
#mongo --port 27028 << ! >> $LOGFILE
#sh.addShard("mongorepl/localhost:27025");
#sh.addShard("mongorepl/localhost:27026");
#sh.addShard("mongorepl/localhost:27027");
#sh.enableSharding("$dbname");
#!
mongo --port 27018 << ! >> $LOGFILE
use admin
db.runCommand({addshard:"localhost:27020", name:"shard27020"});
db.runCommand({addshard:"localhost:27021", name:"shard27021"});

use test_sharding
sh.enableSharding("test_sharding")
db.people.ensureIndex({"zip": 1})
db.people.insert({"name": "a1", "password": "a1", .... )

sh.status()
!
echo "=============================" >> $LOGFILE
ss -lntp|egrep 27017 >> $LOGFILE
ps aux | grep " mongo[ds] " >> $LOGFILE
process_count="$(ps aux | grep " mongo[ds] " | wc -l)"

if [ "$process_count" -ge  "$expected_count" ]
then echo "Started OK" >> $LOGFILE
else
    echo "ERROR: We need $expected_count DB processes to be running.  Please try re-running the script." >> $LOGFILE
    exit 1
fi
exit 0

