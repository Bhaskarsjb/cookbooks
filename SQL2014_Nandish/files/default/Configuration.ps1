param(
 
   [Parameter(Mandatory=$false)]$SCRIPT_PARENT,
   
   [Parameter(Mandatory=$false)]$File,
   
   [Parameter(Mandatory=$false)]$SQL_SERVER_NAME=$env:computername,
   
   [Parameter(Mandatory=$True)][validateset("Install","InstallFailoverCluster","AddNode","RemoveNode","Uninstall")]$Action,

   [Parameter(Mandatory=$True)][validateset("SQL2008","SQL2008R2","SQL2012","SQL2014","SQL2016","SQL2017")]$SQLVERSION,
   
   [Parameter(Mandatory=$True)]$SQLSETUPEXEPATH,
   
   [Parameter(Mandatory=$False)]$SQLINSTALL,
   
   [Parameter(Mandatory=$False)]$INSTANCE_NAME,
   
   [Parameter(Mandatory=$False)]$SQLCOLLATION='SQL_Latin1_General_CP1_CI_AS',
   
   [Parameter(Mandatory=$False)]$FEATURES,
   
   [Parameter(Mandatory=$False)]$SQLCLIENTINSTALL,

   [Parameter(Mandatory=$False)]$SQLSVCACCT,

   [Parameter(Mandatory=$False)]$SQLSVCPWD = $null,
   
   [Parameter(Mandatory=$False)]$SQLSVCSTARTUPTYPE,

   [Parameter(Mandatory=$False)]$AGTSVCACCOUNT,

   [Parameter(Mandatory=$False)]$AGTSVCPWD = $null,

   [Parameter(Mandatory=$False)]$AGTSVCSTARTUPTYPE,

   [Parameter(Mandatory=$False)]$FTSVCACCOUNT='NT AUTHORITY\LOCAL SERVICE',
   
   [Parameter(Mandatory=$False)]$SQLSYSADMINACCOUNTS,

   [Parameter(Mandatory=$False)]$ADDCURRENTUSERASSQLADMIN,

   [Parameter(Mandatory=$FALSE)]$SECURITYMODE = $null,

   [Parameter(Mandatory=$False)]$SAPWD = $null ,

   [Parameter(Mandatory=$False)]$TCPENABLED='1',

   [Parameter(Mandatory=$False)]$INSTALLSQLDATADIR,

   [Parameter(Mandatory=$False)]$SQLUSERDBDRIVE = $null ,

   [Parameter(Mandatory=$False)]$SQLUSERLOGDRIVE = $null ,

   [Parameter(Mandatory=$False)]$SQLBACKUPDRIVE = $null ,

   [Parameter(Mandatory=$False)]$SQLTEMPDBDATADRIVE = $null ,

   [Parameter(Mandatory=$False)]$SQLTEMPDBLOGDRIVE = $null ,

   [Parameter(Mandatory=$False)]$SQLTEMPDBFILECOUNT = $null ,
   
   [Parameter(Mandatory=$false)]$SQLTEMPDBFILESIZE,
   
   [Parameter(Mandatory=$false)]$SQLTEMPDBFILEGROWTH,
   
   [Parameter(Mandatory=$false)]$SQLTEMPDBLOGFILESIZE,
   
   [Parameter(Mandatory=$false)]$SQLTEMPDBLOGFILEGROWTH,
   
   [Parameter(Mandatory=$False)]$ASINSTALL='FALSE',

   [Parameter(Mandatory=$False)]$RSINSTALL='FALSE',

   [Parameter(Mandatory=$False)]$ISINSTALL='FALSE',

   [Parameter(Mandatory=$False)]$DQCINSTALL='FALSE',

   [Parameter(Mandatory=$False)]$MDSINSTALL='FALSE',
   
   [Parameter(Mandatory=$False)]$FAILOVERCLUSTERDISKS = $null ,

   [Parameter(Mandatory=$False)]$FAILOVERCLUSTERGROUP = $null ,

   [Parameter(Mandatory=$False)]$FAILOVERCLUSTERIPADDRESSES,

   [Parameter(Mandatory=$False)]$FAILOVERCLUSTERNETWORKNAME,

   [Parameter(Mandatory=$False)]$VirtualIP,

   [Parameter(Mandatory=$False)]$argumentList,
 
   [Parameter(Mandatory=$False)]$ASSVCPASSWORD,

   [Parameter(Mandatory=$false)]$ASSVCACCOUNT,
  
   [Parameter(Mandatory=$False)] $ASSYSADMINACCOUNTS,

   [Parameter(Mandatory=$False)] $ISAVCACCT,
   [Parameter(Mandatory=$False)] $ISSVCPWD,
   [Parameter(Mandatory=$False)] $ISSVCSTARTUPTYPE,
  [Parameter(Mandatory=$False)] $RSSVCACCT,
  [Parameter(Mandatory=$False)] $RSSVCPWD


   )
 
 Set-PSDebug -trace 2
   
#Function to get Script Directory location
function Get-ScriptDirectory 
{  
    if($hostinvocation -ne $null) 
    { 
        Split-Path $hostinvocation.MyCommand.path 
    } 
    else 
    { 
        Split-Path $script:MyInvocation.MyCommand.Path 
    } 
} 
$SCRIPT_PARENT   = Get-ScriptDirectory  
write-host $SCRIPT_PARENT
$File = $SCRIPT_PARENT
Remove-Item ($SCRIPT_PARENT + '\config.ini') -Recurse -ErrorAction Ignore
New-Item ($SCRIPT_PARENT + '\config.ini') -ItemType file		

   
Write-output Action=$Action | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output SQL_SERVER_NAME=$SQL_SERVER_NAME | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output File=$File | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output SQLVERSION=$SQLVERSION | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output SQLCOLLATION=$SQLCOLLATION | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output SQLSETUPEXEPATH=$SQLSETUPEXEPATH | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output FTSVCACCOUNT=$FTSVCACCOUNT | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output ASINSTALL=$ASINSTALL | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output RSINSTALL=$RSINSTALL | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output ISINSTALL=$ISINSTALL | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output DQCINSTALL=$DQCINSTALL | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output MDSINSTALL=$MDSINSTALL | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
if($AddCurrentUserAsSQLAdmin ) {Write-Output ADDCURRENTUSERASSQLADMIN=$ADDCURRENTUSERASSQLADMIN | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}
Write-output TCPENABLED=$TCPENABLED | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-Output FTSVCACCOUNT=$FTSVCACCOUNT | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-Output ISSVCSTARTUPTYPE='Automatic' | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
if($FEATURES) {Write-Output FEATURES=$FEATURES  | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}
IF($SQLINSTALL) {Write-output SQLINSTALL=$SQLINSTALL | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append } else { Write-output SQLINSTALL='True' | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append }
if($SQLCLIENTINSTALL) {Write-output SQLCLIENTINSTALL=$SQLCLIENTINSTALL | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append } else { Write-output SQLCLIENTINSTALL='True' | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}
If($ASSVCACCOUNT) { Write-Output ASSVCACCT=$ASSVCACCOUNT | out-file -FilePath ($SCRIPT_PARENT + '\config.ini') -Append }
If($ASSVCPASSWORD) { Write-Output ASSVCPWD=$ASSVCPASSWORD | out-file -FilePath ($SCRIPT_PARENT + '\config.ini') -Append }
If($ASSYSADMINACCOUNTS) { Write-Output ASSYSADMINACCOUNTS=$ASSYSADMINACCOUNTS | out-file -FilePath ($SCRIPT_PARENT + '\config.ini') -Append }
If($SQLSYSADMINACCOUNTS) { Write-Output SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS | out-file -FilePath ($SCRIPT_PARENT + '\config.ini') -Append } else { Write-Output SQLSYSADMINACCOUNTS='builtin\users' | out-file -FilePath ($SCRIPT_PARENT + '\config.ini') -Append }
if($ISAVCACCT) { Write-Output ISAVCACCT=$ISAVCACCT | out-file -FilePath ($SCRIPT_PARENT + '\config.ini') -Append }
if($ISSVCPWD) { Write-Output ISSVCPWD=$ISSVCPWD | out-file -FilePath ($SCRIPT_PARENT + '\config.ini') -Append }
if($RSSVCACCT) { Write-Output RSSVCACCT=$RSSVCACCT | out-file -FilePath ($SCRIPT_PARENT + '\config.ini') -Append }
if($RSSVCPWD) { Write-Output RSSVCPWD=$RSSVCPWD | out-file -FilePath ($SCRIPT_PARENT + '\config.ini') -Append }


#Configuration Parameters for InstallFailoverCluster
If($Action -eq "InstallFailoverCluster")
{
#To get the SQL Instance Name
IF($INSTANCE_NAME){Write-output INSTANCE_NAME=$INSTANCE_NAME | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append} 
else { Write-output INSTANCE_NAME="MSSQLSERVER" | out-file -filepath ($SCRIPT_PARENT + '\config.ini')}

#Get the IP FailoverClusterIPAddress
If($VirtualIP){ $nic_configuration = gwmi -computer .  -class "win32_networkadapterconfiguration" | Where-Object {$_.defaultIPGateway -ne $null} 
$SubnetMask = $nic_configuration.ipsubnet |Select-object -First 1 
$ClusterNetworkname = Get-ClusterNetwork  
$FAILOVERCLUSTERIPADDRESSES="IPv4;$VirtualIP;$ClusterNetworkname;$SubnetMask"  
Write-output FAILOVERCLUSTERIPADDRESSES=$FAILOVERCLUSTERIPADDRESSES | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append } 
else { write-host "Virtual IP Address not defined"  break }

#To Verity SQLData Directory path
if($INSTALLSQLDATADIR){Write-output INSTALLSQLDATADIR=$INSTALLSQLDATADIR | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}
else{ Write-host -foreground Red "The data directory must to specified and on a shared cluster disk" break}

#To Get Failover network name for the new SQL Server Database Engine failover cluster
if($FAILOVERCLUSTERNETWORKNAME) {Write-output FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}
else{Write-host -FOreground Red "Specify the network name for the new SQL Server Database Engine failover cluster. This name is used to identify the new SQL Server Database Engine failover cluster instance on the network."break}

#To create failoverCluster Group Name
if($FAILOVERCLUSTERGROUP){
try
{
Add-ClusterGroup -Name $FAILOVERCLUSTERGROUP 
Write-output {FAILOVERCLUSTERGROUP=$FAILOVERCLUSTERGROUP | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}} 
catch { write-host -ForegroundColor RED "FailoverClusterGroup $FAILOVERCLUSTERGROUP already exists" Write-Host $FAILOVERCLUSTERGROUP  break } }

#To create Shared Cluster disk from the available Storage
#Get-ClusterResource | where-object {$_.OwnerGroup.name -eq "Available Storage"} | Add-ClusterSharedVolume

#To list of shared disks to be included in the SQL Server Database Engine failover cluster resource group
If($FAILOVERCLUSTERDISKS) {Write-output FAILOVERCLUSTERDISKS=$FAILOVERCLUSTERDISKS | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}

#To Veify SQL Server Authentication mode enabled
If($SECURITYMODE -eq "SQL") { Write-output SECURITYMODE=$SECURITYMODE | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append If($SAPWD) { Write-output SAPWD=$SAPWD | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append} else { write-host "SAPassword to be specified for SQL Server Authentication mode"  Break} }

#To verify the account for the SQL Server Agent service.
if(($SQLSVCACCT) -and ($AGTSVCACCOUNT)) 
{ Write-output SQLSVCACCT=$SQLSVCACCT | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output SQLSVCPWD=$SQLSVCPWD | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output AGTSVCACCOUNT=$AGTSVCACCOUNT | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output AGTSVCPWD=$AGTSVCPWD | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append } 
else { write-host "Service account required for SQL Server and Agent service" break } 

 
Write-output SQLSVCSTARTUPTYPE='Manual' | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output AGTSVCSTARTUPTYPE='Manual' | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append
Write-output SQLSVCSTARTUPTYPE='Manual' | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append

}

elseIf($Action -eq "Addnode")
{
#Configuration Parameters for Addnode
#To get the SQL Instance Name
IF($INSTANCE_NAME){Write-output INSTANCE_NAME=$INSTANCE_NAME | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append} else { Write-output INSTANCE_NAME="MSSQLSERVER" | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append }


#To verify the account for the SQL Server Agent service.
if(($SQLSVCACCT) -and ($AGTSVCACCOUNT)) 
{ Write-output SQLSVCACCT=$SQLSVCACCT | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output SQLSVCPWD=$SQLSVCPWD | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output AGTSVCACCOUNT=$AGTSVCACCOUNT | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output AGTSVCPWD=$AGTSVCPWD | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append } 
else { write-host "Service account required for SQL Server and Agent service" break } 


#Get the IP FailoverClusterIPAddress
If($VirtualIP){ $nic_configuration = gwmi -computer .  -class "win32_networkadapterconfiguration" | Where-Object {$_.defaultIPGateway -ne $null} 
$SubnetMask = $nic_configuration.ipsubnet |Select-object -First 1 
$ClusterNetworkname = Get-ClusterNetwork  
$FAILOVERCLUSTERIPADDRESSES="IPv4;$VirtualIP;$ClusterNetworkname;$SubnetMask"  
Write-output FAILOVERCLUSTERIPADDRESSES=$FAILOVERCLUSTERIPADDRESSES | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append } 
else { write-host "Virtual IP Address not defined"  break }
}


#Configuration Parameters for Removenode
elseIf($Action -eq "RemoveNode")
{
#To Get Failover network name for the new SQL Server Database Engine failover cluster
if($FAILOVERCLUSTERNETWORKNAME) { Write-output FAILOVERCLUSTERNETWORKNAME=$FAILOVERCLUSTERNETWORKNAME | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append} 
else 
{
Write-host "Specify the network name for the new SQL Server Database Engine failover cluster. 
This name is used to identify the new SQL Server Database Engine failover cluster instance on the network." 
break
} 

#To get the SQL Instance Name
IF($INSTANCE_NAME) { Write-output INSTANCE_NAME=$INSTANCE_NAME | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append} else { Write-output INSTANCE_NAME="MSSQLSERVER" | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}
}


#Configuration Parameters for Standalone
elseIf($Action -eq "Install")
{
IF($INSTANCE_NAME){Write-output INSTANCE_NAME=$INSTANCE_NAME | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append} else { Write-output INSTANCE_NAME="MSSQLSERVER" | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}
If($AGTSVCSTARTUPTYPE) {write-output AGTSVCSTARTUPTYPE=$AGTSVCSTARTUPTYPE | out-file -filepath ($SCRIPT_PARENT + '\config.ini')} else {write-output AGTSVCSTARTUPTYPE="Automatic" | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}
If($SQLSVCSTARTUPTYPE) {write-output SQLSVCSTARTUPTYPE=$SQLSVCSTARTUPTYPE | out-file -filepath ($SCRIPT_PARENT + '\config.ini')} else {write-output SQLSVCSTARTUPTYPE="Automatic" | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append}
If($SECURITYMODE -eq "SQL") { Write-output SECURITYMODE=$SECURITYMODE | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append If($SAPWD) { Write-output SAPWD=$SAPWD | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append} else { write-host "SAPassword to be specified for SQL Server Authentication mode"  Break} 

#To verify the account for the SQL Server Agent service.
if(($SQLSVCACCT -like "NT Service\MSSQLSERVER" ) -and ($AGTSVCACCOUNT -like "NT Service\SQLSERVERAGENT" )) 
{ Write-output SQLSVCACCT=$SQLSVCACCT | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output SQLSVCPWD=$SQLSVCPWD | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output AGTSVCACCOUNT=$AGTSVCACCOUNT | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output AGTSVCPWD=$AGTSVCPWD | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append } 
}
else
{
Write-output SQLSVCACCT='NT Service\MSSQLSERVER' | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
Write-output AGTSVCACCOUNT='NT Service\SQLSERVERAGENT' | out-file -filepath ($SCRIPT_PARENT + '\config.ini') -Append 
}

}
$argumentList = "-c " +  $SCRIPT_PARENT + "\config.ini -a " + $Action
Invoke-Expression "$SCRIPT_PARENT\SQLInstall.ps1 $argumentList"
write-host $SCRIPT_PARENT\SQLInstall.ps1 $argumentList

