#!/bin/bash
DATABASENAME=${1?Error : No Database Name Given}
SERVERNAME=${2?Error : No Instance name Given}

BACKUPFILENAME=/mnt/disks/MSSQL/BACKUP/$DATABASENAME.bak

sqlcmd -S $SERVERNAME -U SA -P 'Test@123$' -Q "ALTER DATABASE $DATABASENAME SET SINGLE_USER WITH ROLLBACK IMMEDIATE;"

sqlcmd -S $SERVERNAME -U SA -P 'Test@123$' -Q "IF EXISTS (SELECT * FROM sysdatabases WHERE name=N'$DATABASENAME' ) DROP DATABASE $DATABASENAME;"
sqlcmd -S $SERVERNAME -U SA -P 'Test@123$' -Q "CREATE DATABASE $DATABASENAME;"

sqlcmd -S $SERVERNAME -U SA -P 'Test@123$' -Q "RESTORE DATABASE $DATABASENAME FROM DISK ='$BACKUPFILENAME' WITH REPLACE;"

#remap user/login (http://msdn.microsoft.com/en-us/library/ms174378.aspx)
#sqlcmd -E -S %SERVERNAME% -d %DATABASENAME% -Q "sp_change_users_login 'Update_One', 'login-name', 'user-name'"
sqlcmd -S $SERVERNAME -U SA -P 'Test@123$' -Q "ALTER DATABASE $DATABASENAME SET MULTI_USER"
echo Done!
