@ECHO OFF
REM : CHECK SQL SERVER INSTALL DIRECTORIES AND STARTUP TYPE FOR SERVICES.
REM : USAGE <<SCRIPTNAME>> <<TEST>>
REM : EXAMPLE SQLSERVICES.BAT LMDD2202
REM - SET DATETIME FORMAT AS YYYYMMDD_HHMMSS

set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%


set year=%date:~-4%
set month=%date:~4,2%
if "%month:~0,1%" == " " set month=0%month:~1,1%
set day=%date:~7,2%
if "%day:~0,1%" == " " set day=0%day:~1,1%


set DATETIME=%year%%month%%day%_%hour%%min%%secs%



Setup.exe /qs /ACTION=Install /IACCEPTSQLSERVERLICENSETERMS /FEATURES=SQL,RS /INSTALLSQLDATADIR="C:\Program Files\Microsoft SQL Server" /INSTANCENAME=TEST /SQLSVCACCOUNT="instance-1\bhusia" /SQLSVCPASSWORD="Windows@14" /SQLSYSADMINACCOUNTS="instance-1\Windows@14" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /RSSVCACCOUNT="NT AUTHORITY\Network Service" /SECURITYMODE=SQL /SAPWD="test@123" /SQLUSERDBDIR="C:\TEST\DATA" /SQLUSERDBLOGDIR="c:\TEST\LOG" /SQLTEMPDBDIR="c:\TEST\DATA" /SQLTEMPDBLOGDIR="c:\TEST\LOG" /SQLBACKUPDIR="c:\TEST\BACKUP" 



ECHO - CHECK IF ALL PARAMETERS ARE PASSED



ECHO - SET VARIABLE FOR INSTANCE NAME

SET  INS_NAME=TEST


IF  "%INS_NAME%"=="" GOTO HALT

ECHO : STARTED

ECHO  STARTED : SQL SERVER INSTANCE INSALL DIRECTORES >> SQLSERVICES_%DATETIME%.TXT

wmic service where caption="SQL Server (%INS_NAME%)" get Name,Pathname /format:table  >> SQLSERVICES_%DATETIME%.TXT 

ECHO  COMPLETED : SQL SERVER INSTANCE INSALL DIRECTORES >> SQLSERVICES_%DATETIME%.TXT

ECHO STARTED : SQL AGENT INSTALL DIRECTORIES >> SQLSERVICES_%DATETIME%.TXT

wmic service where caption="SQL Server Agent (%INS_NAME%)" get Name,PathName /format:table >> SQLSERVICES_%DATETIME%.TXT
 
ECHO  COMPLETED : SQL AGENT INSTALL DIRECTORIES >> SQLSERVICES_%DATETIME%.TXT

ECHO STARTED : SQL FULL TEXT SEARCH INSTALL DIRECTORIES >> SQLSERVICES_%DATETIME%.TXT

wmic service where caption="SQL Full-text Filter Daemon Launcher (%INS_NAME%)" get Name,PathName /format:table >> SQLSERVICES_%DATETIME%.TXT

ECHO COMPLETED : SQL FULL TEXT SEARCH INSTALL DIRECTORIES >> SQLSERVICES_%DATETIME%.TXT

ECHO STARTED : SQL SERVER STARTUP TYPE >> SQLSERVICES_%DATETIME%.TXT

wmic service where caption="SQL Server (%INS_NAME%)" get Name,StartMode,State  /format:table >> SQLSERVICES_%DATETIME%.TXT

ECHO COMPLETED : SQL SERVER STARTUP TYPE >> SQLSERVICES_%DATETIME%.TXT

ECHO STARTED : SQL AGENT STARTUP TYPE >> SQLSERVICES_%DATETIME%.TXT

wmic service where caption="SQL Server Agent (%INS_NAME%)" get Name,StartMode,State /format:table >> SQLSERVICES_%DATETIME%.TXT

ECHO COMPLETED : SQL AGENT STARTUP TYPE >> SQLSERVICES_%DATETIME%.TXT

ECHO STARTED : SQL FULL TEXT SEARCH STRATUP TYPE >> SQLSERVICES_%DATETIME%.TXT

wmic service where caption="SQL Full-text Filter Daemon Launcher (%INS_NAME%)" get Name,StartMode,State /format:table >> SQLSERVICES_%DATETIME%.TXT

ECHO COMPLETED : SQL FULL TEXT SEARCH STRATUP TYPE >> SQLSERVICES_%DATETIME%.TXT

ECHO STARTED : SQL BROWSER STARTUP TYPE >> SQLSERVICES_%DATETIME%.TXT

wmic service where caption="SQL Server Browser" get Name,StartMode,State /format:table >> SQLSERVICES_%DATETIME%.TXT

ECHO COMPLETED : SQL BROWSER STARTUP TYPE >> SQLSERVICES_%DATETIME%.TXT

ECHO : COMPLETED.
EXIT /B



