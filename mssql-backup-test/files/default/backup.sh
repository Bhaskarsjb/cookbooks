#!/bin/bash

DB_NAME=TestDB
DB_HOSTNAME=mssql-chef-test

BK_FILE=/mnt/disks/MSSQL/BACKUP/$DB_NAME.bak

sqlcmd -S $DB_HOSTNAME -U SA -P 'Test@123$' -Q "IF NOT EXISTS (SELECT * FROM sysdatabases WHERE name='$DB_NAME') Print N'wrong DBName';"

sqlcmd -S $DB_HOSTNAME -U SA -P 'Test@123$' -Q "BACKUP DATABASE [$DB_NAME] TO DISK = N'$BK_FILE' WITH INIT, NOUNLOAD , NAME = N'$DB_NAME backup', NOSKIP , STATS = 10, NOFORMAT"

echo Done!
