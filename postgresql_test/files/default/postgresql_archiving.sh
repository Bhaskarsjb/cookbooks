#!/bin/sh
#! /bin/bash
#set -x
#SCRIPT SHOULD BE RUN AS ROOT USER.
sudo clear

if [[ $# -lt 5 ]] ;  then
echo " Usage: $0 #1 #2 #3 #4  #5       				    	              "
echo " wal_level	     		 	: $1            	                  "
echo " max_wal_size	             	: $2                    	          "
echo " wal_keep_segments	     	: $3                        	      "
echo " archive_mode      			: $4                            	  "
echo " archive_command   			: S5	                              "
echo " archive_timeout  			: S6  		                          "

echo "USAGE:- ./postgrearchive.sh archive 1GB 10 on  "cp %p /var/lib/postgresql/10.1/archive/%f" 1h"
exit 0
fi

wal_level=$1
max_wal_size=$2
wal_keep_segments=$3
archive_mode=$4
archive_command=$5
archive_timeout=$6
sleep 5s
echo "Write Ahead Log Archive Parameters......."
echo""
echo "########################################################"
echo " wal_level                 :        $wal_level              "
echo " max_wal_size              :        $max_wal_size           "
echo " wal_keep_segments         :        $wal_keep_segments      "
echo "															  "	
echo " archive_mode              :        $archive_mode           "
echo " archive_command           :        $archive_command        "
echo " archive_timeout           :        $archive_timeout        "
echo "########################################################"
echo ""

sleep 2s

echo "Fetch Binary path location"
directory=$(ps ax -o pid,cmd | grep 'postgres *-D' | awk '{ print $2 }')
bindirectory=$(dirname $directory)
    echo "Binary directory path of postgresql is $bindirectory"


echo "Fetching Data Directory Locaiton"
data="$($bindirectory/psql -q -U postgres -t -P format=unaligned -c 'show data_directory;')"
echo "Postgre Data Directory : $data "
echo""


config="$($bindirectory/psql -q -U postgres -t -P format=unaligned -c 'show config_file;')"
echo "Postgres configuration file path : $config"
echo "backup postgresql.config file to \root\ "
cp $config \root\postgresql.config.bak
echo ""

echo ""
echo " ###########Updating Postgresql.conf########### "
echo""
sleep 5s
echo""
sed -i -e "/#wal_level = minimal/s/minimal/$wal_level/" "$config"
sed -i -e "/#wal_level/s/#/ /" "$config"
echo "wal_level updated..."
echo""



echo""
sed -i -e "/#wal_keep_segments = 0/s/0/$wal_keep_segments/" "$config"
sed -i -e "/#wal_keep_segments/s/#/ /" "$config"
echo "wal_keep_segments updated..."
echo""



echo""
sed -i -e "/#max_wal_size = 1GB/s/1GB/$max_wal_size/" "$config"
sed -i -e "/#max_wal_size/s/#/ /" "$config"
echo "max_wal_size updated..."
echo""


echo""
sed -i -e "/#archive_mode = off/s/off/$archive_mode/" "$config"
sed -i -e "/#archive_mode/s/#/ /" "$config"
echo "archive_mode updated..."
echo""


echo""
#sed -i -e "/#archive_command = ''/s/''/'$archive_command'/" "$config"
#sed -i -e "/#archive_command/s/#/ /" "$config"
sed -i -e "s|#archive_command = ''|archive_command = '$archive_command '|" "$config"
echo "archive_command updated..."
echo""


echo""
sed -i -e "/#archive_timeout = 0/s/0/$archive_timeout/" "$config"
sed -i -e "/#archive_timeout/s/#/ /" "$config"
echo " Archive_timeout updated..."
echo""



echo""
echo " #####Configuration file Update completed###### "
echo""
echo""

echo "Restarting postgres Database services..."
su - postgres <<eof 
$bindirectory/pg_ctl -D $data restart
if [ $? != 0 ]
then
echo "Postgres service restart failed.. please validate the logfile..."
else
echo "Postgres service restarted successfully...please validate the logfile for more information..."
exit 0
fi
eof

sleep 15s
echo "####Archive Configuration details#### "

wallevel="$($bindirectory/psql -q -U postgres -t -P format=unaligned -c 'show wal_level;')"
walkeepsegments="$($bindirectory/psql -q -U postgres -t -P format=unaligned -c 'show wal_keep_segments;')"
maxwalsize="$($bindirectory/psql -q -U postgres -t -P format=unaligned -c 'show max_wal_size;')"
archivemode="$($bindirectory/psql -q -U postgres -t -P format=unaligned -c 'show archive_mode;')"
archivecommand="$($bindirectory/psql -q -U postgres -t -P format=unaligned -c 'show archive_command;')"
archivetimeout="$($bindirectory/psql -q -U postgres -t -P format=unaligned -c 'show archive_timeout;')"




echo "	New Wal_level 				: 		$wallevel			"
echo "	New wal_keep_segments 		: 		$walkeepsegments	"
echo "	New Archive_mode 			: 		$archivemode		"
echo "	New Archive_timeout 		: 		$archivetimeout		"
echo "	New Archive_command			: 		$archivecommand		"

exit 0
