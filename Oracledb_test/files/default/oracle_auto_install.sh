######################### Variable #######################

if [[ $# -lt 8 ]] ;  then
echo "Usage: $0 #1 #2"
echo "  #1 Instance_Name            "
echo "  #2 Required_Memory          "
echo "  #3 version                  "
echo "  #4 ORACLE_BASE                          "
echo "  #5 ORACLE_INVENTORY                     "
echo "  #6 ORACLE_SOURCE                        "
echo "  #7 ENV_FILE_LOCATION            "
echo "  #8 DOMAIN_NAME                          "

exit 1
fi

export Instance_Name=$1
export Required_Memory=$2
export version=$3
export ORACLE_BASE=$4
export ORACLE_INVENTORY=$5
export ORACLE_SOURCE=$6
export ENV_FILE_LOCATION=$7
export LOG_LOCATION=/var/log/oracle
export DOMAIN_NAME=$8
export DB_VERSION=$(echo $version|awk -F'.' '{print $1}')

ps -ef|grep $Instance_Name|grep pmon|awk '{print $2}'|xargs kill -9
ps -ef|grep $Instance_Name|grep tns|awk '{print $2}'|xargs kill -9
ps -ef|grep $Instance_Name|grep smon|awk '{print $2}'|xargs kill -9
ps -ef|grep $Instance_Name|grep lgwr|awk '{print $2}'|xargs kill -9
ps -ef|grep $Instance_Name|grep dbwr|awk '{print $2}'|xargs kill -9


if [ -d $ORACLE_BASE ]; then
    rm -rf $ORACLE_BASE
fi

if [ -d $ORACLE_INVENTORY ]; then
    rm -rf $ORACLE_INVENTORY
fi

if [ -f /etc/oratab ]; then
    >/etc/oratab
fi

#########################################################

############### YUM Configuration########################

mkdir -p $LOG_LOCATION

echo "Zypper Configuration"
echo "  "
echo "  "

echo "
zypper --non-interactive install binutils
zypper --non-interactive install gcc
zypper --non-interactive install gcc-c++
zypper --non-interactive install gcc48
zypper --non-interactive install glibc
zypper --non-interactive install glibc-32bit
zypper --non-interactive install glibc-devel
zypper --non-interactive install glibc-devel-32bit
zypper --non-interactive install ksh-93u
zypper --non-interactive install libaio
zypper --non-interactive install libaio-devel
zypper --non-interactive install libaio1
zypper --non-interactive install libcap1
zypper --non-interactive install libgcc46
zypper --non-interactive install libgcc_s1-32bit-5.2.1+r226025
zypper --non-interactive install libgcc_s1-5.2.1+r226025
zypper --non-interactive install libstdc++-devel
zypper --non-interactive install libstdc++-devel-32bit
zypper --non-interactive install libstdc++33
zypper --non-interactive install libstdc++33-32bit
zypper --non-interactive install libstdc++43-devel
zypper --non-interactive install libstdc++46
zypper --non-interactive install libstdc++48-devel
zypper --non-interactive install libstdc++48-devel-32bit
zypper --non-interactive install libstdc++6-32bit-5.2.1+r226025
zypper --non-interactive install libstdc++6-5.2.1+r226025
zypper --non-interactive install make
zypper --non-interactive install mksh-50
zypper --non-interactive install sysstat
zypper --non-interactive install xorg-x11
zypper --non-interactive install xorg-x11-Xvnc
zypper --non-interactive install xorg-x11-driver-video
zypper --non-interactive install xorg-x11-essentials
zypper --non-interactive install xorg-x11-fonts
zypper --non-interactive install xorg-x11-fonts-core
zypper --non-interactive install xorg-x11-libX11
zypper --non-interactive install xorg-x11-libX11-32bit
zypper --non-interactive install xorg-x11-libXau
zypper --non-interactive install xorg-x11-libXau-32bit
zypper --non-interactive install xorg-x11-libXext
zypper --non-interactive install xorg-x11-libXext-32bit
zypper --non-interactive install xorg-x11-libs
zypper --non-interactive install xorg-x11-libs-32bit
zypper --non-interactive install xorg-x11-libxcb
zypper --non-interactive install xorg-x11-libxcb-32bit
zypper --non-interactive install xorg-x11-server" >/etc/zypp/repos.d/install_packages.sh

chmod 755 /etc/zypp/repos.d/install_packages.sh

/etc/zypp/repos.d/install_packages.sh >$LOG_LOCATION/zypper_installation.log

error_count=$(grep -i error $LOG_LOCATION/zypper_installation.log|wc -l)

if [ $error_count -gt 0 ]
then
echo "Oracle prerequisite package installation fail"
exit 1
fi


#########################################################

############## USER Modification ########################

echo "USER Modification"

echo "  "
echo "  "

mkdir -p $ORACLE_BASE
mkdir -p $ORACLE_INVENTORY

groupadd oracle
groupadd dba
groupadd oinstall
usermod -m -d /home/oracle -s /bin/bash oracle -g dba -G oracle,oinstall

chown -R oracle:oinstall $ORACLE_BASE
chown -R oracle:oinstall $ORACLE_INVENTORY

echo oracle | passwd oracle --stdin

#########################################################

################ SWAP FILE Creation(Atleast 1GB) #####################

swapsize=$(grep SwapTotal /proc/meminfo|awk '{print $2}')

if [ $swapsize -lt 1048571 ]
then
echo "SWAP FILE Creation"

echo "  "
echo "  "

dd if=/dev/zero of=/myswapfile bs=1M count=1024 >$LOG_LOCATION/swapcreation.log
mkswap /myswapfile >>$LOG_LOCATION/swapcreation.log
swapon /myswapfile >>$LOG_LOCATION/swapcreation.log
echo "/myswapfile        swap                    swap    defaults        0 0" >>/etc/fstab

error_count=$(grep -i error $LOG_LOCATION/swapcreation.log|wc -l)

if [ $error_count -gt 0 ]
then
echo "SWAP Creation fail"
exit 1
fi
fi

#########################################################

################# Stop Firewall #########################

echo "Stopping Firewall"

echo "  "
echo "  "

/sbin/rcSuSEfirewall2 stop  >$LOG_LOCATION/firewall.log

error_count=$(grep -i error $LOG_LOCATION/firewall.log|wc -l)

if [ $error_count -gt 0 ]
then
echo "Firewall couldn't be stopped"
exit 1
fi

###########################################################


################ Oracle Software Installation #############

chown -R oracle:dba $LOG_LOCATION

echo "sudo -u oracle $ORACLE_SOURCE/database/runInstaller \
-ignoreSysPrereqs \
-ignorePrereq \
-waitforcompletion \
-showProgress \
-silent \
-responseFile $ORACLE_SOURCE/database/response/db_install.rsp \
oracle.install.option=INSTALL_DB_SWONLY \
ORACLE_HOSTNAME=`hostname` \
UNIX_GROUP_NAME=oinstall \
INVENTORY_LOCATION=$ORACLE_INVENTORY \
ORACLE_HOME=$ORACLE_BASE/"$Instance_Name"/"$version" \
ORACLE_BASE=$ORACLE_BASE \
oracle.install.db.InstallEdition=EE \
oracle.install.db.EEOptionsSelection=true \
oracle.install.db.DBA_GROUP=dba \
oracle.install.db.OPER_GROUP=dba \
oracle.install.db.OSDBA_GROUP=dba \
oracle.install.db.OSOPER_GROUP=dba \
oracle.install.db.OSBACKUPDBA_GROUP=dba \
oracle.install.db.OSDGDBA_GROUP=dba \
oracle.install.db.OSKMDBA_GROUP=dba \
oracle.install.db.OSRACDBA_GROUP=dba \
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
DECLINE_SECURITY_UPDATES=true \
oracle.installer.autoupdates.option=SKIP_UPDATES" >$ORACLE_SOURCE/auto_oracle_sw.sh

chown oracle:dba $ORACLE_SOURCE/auto_oracle_sw.sh
chmod 755 $ORACLE_SOURCE/auto_oracle_sw.sh

$ORACLE_SOURCE/auto_oracle_sw.sh >$LOG_LOCATION/install_oracle.log

$ORACLE_BASE/$Instance_Name/$version/root.sh >>$LOG_LOCATION/install_oracle.log
$ORACLE_INVENTORY/orainstRoot.sh >>$LOG_LOCATION/install_oracle.log

error_count=$(grep -i error $LOG_LOCATION/install_oracle.log|wc -l)
fail_count=$(grep -i fail $LOG_LOCATION/install_oracle.log|wc -l)
ora_error_count=$(grep "ORA-" $LOG_LOCATION/install_oracle.log|wc -l)

if [ $error_count -gt 0 ]
then
echo "Oracle Installation has been failed"
grep -i error $LOG_LOCATION/install_oracle.log
exit 1
fi

if [ $ora_error_count -gt 0 ]
then
echo "Oracle Installation has been failed"
grep "ORA-" $LOG_LOCATION/install_oracle.log
exit 1
fi

if [ $fail_count -gt 0 ]
then
echo "Oracle Installation has been failed"
grep -i fail $LOG_LOCATION/install_oracle.log
exit 1
fi

#########################################################

################ Listener Installation ##################

echo "
[GENERAL]
CREATE_TYPE=\"CUSTOM\"

[oracle.net.ca]
INSTALLED_COMPONENTS={\"server\",\"net8\",\"javavm\"}
INSTALL_TYPE=\"\"CUSTOM\"\"
LISTENER_NUMBER=1
LISTENER_NAMES={\"LISTENER_$Instance_Name\"}
LISTENER_PROTOCOLS={\"TCP;1521\"}
LISTENER_START=\"\"LISTENER_$Instance_Name\"\"
NAMING_METHODS={\"TNSNAMES\",\"ONAMES\",\"HOSTNAME\"}
NSN_NUMBER=1
NSN_NAMES={\"EXTPROC_CONNECTION_DATA\"}
NSN_SERVICE={\"PLSExtProc\"}
NSN_PROTOCOLS={\"TCP;HOSTNAME;1521\"} " >$ORACLE_SOURCE/database/response/netca_custom.rsp

chown oracle:dba $ORACLE_SOURCE/database/response/netca_custom.rsp
chmod 755 $ORACLE_SOURCE/database/response/netca_custom.rsp

sudo -u oracle $ORACLE_BASE/$Instance_Name/$version/bin/netca -silent \
-responseFile $ORACLE_SOURCE/database/response/netca_custom.rsp >$LOG_LOCATION/install_listener.log

error_count=$(grep -i error $LOG_LOCATION/install_listener.log|wc -l)
fail_count=$(grep -i fail $LOG_LOCATION/install_listener.log|wc -l)
ora_error_count=$(grep "ORA-" $LOG_LOCATION/install_listener.log|wc -l)

if [ $error_count -gt 0 ]
then
echo "Oracle Listener Installation has been failed"
grep -i error $LOG_LOCATION/install_listener.log
exit 1
fi

if [ $ora_error_count -gt 0 ]
then
echo "Oracle Listener Installation has been failed"
grep "ORA-" $LOG_LOCATION/install_listener.log
exit 1
fi

if [ $fail_count -gt 0 ]
then
echo "Oracle Listener Installation has been failed"
grep -i fail $LOG_LOCATION/install_listener.log
exit 1
fi

#########################################################

################# Database Creation #####################

echo "sudo -u oracle $ORACLE_BASE/$Instance_Name/$version/bin/dbca -silent -createDatabase \
-templateName General_Purpose.dbc \
-gdbname "$Instance_Name"."$DOMAIN_NAME" \
-sid "$Instance_Name" \
-responseFile NO_VALUE \
-characterSet AL32UTF8 \
-sysPassword W0rldw1de \
-systemPassword W0rldw1de \
-databaseType OLTP \
-emConfiguration NONE \
-totalMemory "$Required_Memory" \
-recoveryAreaDestination "$ORACLE_BASE"/fast_recovery_area \
-redoLogFileSize 500 \
-sampleSchema true \
-storageType FS \
-datafileDestination "$ORACLE_BASE"/oradata " >$ORACLE_SOURCE/auto_oracle_db.sh

chown oracle:dba $ORACLE_SOURCE/auto_oracle_db.sh
chmod 755 $ORACLE_SOURCE/auto_oracle_db.sh

$ORACLE_SOURCE/auto_oracle_db.sh >$LOG_LOCATION/install_oracle_database.log

error_count=$(grep -i error $LOG_LOCATION/install_oracle_database.log|wc -l)
fail_count=$(grep -i fail $LOG_LOCATION/install_oracle_database.log|wc -l)
ora_error_count=$(grep "ORA-" $LOG_LOCATION/install_oracle_database.log|wc -l)
dbca_error_count=$(grep -i fail $ORACLE_BASE/cfgtoollogs/dbca/$Instance_Name/$Instance_Name.log|wc -l)

if [ $error_count -gt 0 ]
then
echo "Oracle Database Installation has been failed"
grep -i error $LOG_LOCATION/install_oracle_database.log
exit 1
fi

if [ $ora_error_count -gt 0 ]
then
echo "Oracle Database Installation has been failed"
grep "ORA-" $LOG_LOCATION/install_oracle_database.log
exit 1
fi

if [ $fail_count -gt 0 ]
then
echo "Oracle Database Installation has been failed"
grep -i fail $LOG_LOCATION/install_oracle_database.log
exit 1
fi

if [ $dbca_error_count -gt 0 ]
then
echo "Oracle Database Installation has been failed"
grep -i fail $ORACLE_BASE/cfgtoollogs/dbca/$Instance_Name/$Instance_Name.log
exit 1
fi

#########################################################

################ Environment File Creation ##############

echo "export ORACLE_SID=$Instance_Name
export ORAENV_ASK=NO
. $ENV_FILE_LOCATION/oraenv" >$ENV_FILE_LOCATION/$Instance_Name

chown oracle:dba $ENV_FILE_LOCATION/$Instance_Name
chmod 755 $ENV_FILE_LOCATION/$Instance_Name

. $ENV_FILE_LOCATION/$Instance_Name

echo "export TNS_ADMIN=$ORACLE_HOME/network/admin" >>$ENV_FILE_LOCATION/$Instance_Name

#########################################################

#################### Database Check #####################

echo ". $ENV_FILE_LOCATION/$Instance_Name
sqlplus -S "system/W0rldw1de"@"$Instance_Name" <<EOF >$ORACLE_SOURCE/count
set head off
set feed off
set pagesize 0
select open_mode from "v\\\$database";
EOF" >$ORACLE_SOURCE/database_check.sh

chown oracle:dba $ORACLE_SOURCE/database_check.sh
chmod 755 $ORACLE_SOURCE/database_check.sh

su -l oracle -c $ORACLE_SOURCE/database_check.sh

count=`cat $ORACLE_SOURCE/count`
echo $count

if [ "$count" != "READ WRITE" ]
then
echo "$Instance_Name Database unavailable"
exit 1
fi
rm -f $ORACLE_SOURCE/count

#########################################################

################# Archivelog Mode #######################

echo ". $ENV_FILE_LOCATION/$Instance_Name

sqlplus -S / as sysdba <<EOF
shutdown immediate;
exit;
EOF

sqlplus -S / as sysdba <<EOF
startup mount;
alter database archivelog;
alter database open;
alter system switch logfile;
alter system register;
exit;
EOF

lsnrctl reload listener" >$ORACLE_SOURCE/archivelogmode.sh

chown oracle:dba $ORACLE_SOURCE/archivelogmode.sh
chmod 755 $ORACLE_SOURCE/archivelogmode.sh

su -l oracle -c $ORACLE_SOURCE/archivelogmode.sh

#########################################################

################ Start Firewall #########################

/sbin/rcSuSEfirewall2 start

#########################################################
