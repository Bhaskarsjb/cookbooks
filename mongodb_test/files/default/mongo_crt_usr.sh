set -x
if [[ $# -lt 1 ]] ;  then
echo "Usage: $0 #1 #
echo "  #1 dbname               "
echo "USAGE:- ./mongo_crt_usr.sh mydb"
exit 1
fi

dbname=$1;export dbname
CRT_DT=`date +'%Y-%m-%d_%H.%M.%S'`;export CRT_DT
MONGOPATH=/data/db/mongodb;export MONGOPATH
LOGFILE=/$MONGOPATH/LOG/crtuser_$CRT_DT.log
echo $dbname >> $LOGFILE
echo "Login to Mongodb..." >> $LOGFILE
#su - mongodb  >> $LOGFILE
function mongoscript {
/var/mongodb/bin/mongo << EOF >> $LOGFILE
echo "Adding admin user"
use $dbname
var user = {
  "user" : "admin",
  "pwd" : "admin",
  roles : [
      {
          "role" : "userAdminAnyDatabase",
          "db" : "$dbname"
      }
  ]
}
db.auth("admin", "admin")
db.grantRolesToUser("admin", [ { role: "read", db: "$dbname" } ])

db.createUser(user);
echo "Adding mongoadmin user"
db.createUser(
  {
    user: "mongoadmin",
    pwd: "admin",
    roles: [ { role: "userAdminAnyDatabase", db: "$dbname" } ]
  }
)
db.auth("mongoadmin", "admin")
db.grantRolesToUser("mongoadmin", [ { role: "read", db: "$dbname" } ])

db.createUser( {
    user: "siteUserAdmin",
    pwd: "admin",
    roles: [ { role: "userAdminAnyDatabase", db: $dbname" } ]})
db.auth("mongoadmin", "admin")
db.grantRolesToUser("mongoadmin", [ { role: "read", db: "$dbname" } ])
db.createUser( {
    user: "siteRootAdmin",
    pwd: "admin",
    roles: [ { role: "root", db: "$dbname" } ]})
db.auth("mongoadmin", "admin")
db.grantRolesToUser("mongoadmin", [ { role: "read", db: "$dbname" } ])
echo "Exit the Mongoshell..."
exit
EOF
}
#quit()
mongoscript
echo "Connect to Mongoshell using admin user .." >> $LOGFILE
mongo --port 27017 -u "mongoadmin" -p "admin" --authenticationDatabase "admin" <<EOF >> $LOGFILE
show dbs
use $dbname
show collections
show users
EOF

