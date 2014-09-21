########################################################################################################
# Author: Sethu Srinivasan
# Date: 9/20/2014
# Windows Azure Database - enumerate DBs, enumerate tables in DBs, get the number of rows in the tables
########################################################################################################

import-module sqlps -DisableNameChecking

$user = "YOUR_USER"
$password = "YOUR_PASSWORD"
$azureserver ="YOUR_SQLDBSERVER"

$azuredbserver = "$azureserver.database.windows.net"
$azuredbport = 1433

#######################################################
# Check host and port  connectivity
# Reference: http://www.travisgan.com/2014/03/use-powershell-to-test-port.html
#######################################################
$testSqlAzure = new-object System.Net.Sockets.TcpClient;
try
{
    write-host "testing connectivity to host:"$azuredbserver" Port:"$azuredbport
    $testSqlAzure.Connect($azuredbserver, $azuredbport);
    write-host "Connection successful!";
}
catch
{
    throw "Check connectivity to azure db host and port"
}
finally
{
    $testSqlAzure.Dispose();
}

#######################################################
# enumerate all user databases on Azure DB server
#######################################################
$databases = invoke-sqlcmd -Username $user -Password $password -ServerInstance "$azuredbserver" -Database master -Query "select name from sys.databases where database_id > 1"

#######################################################
# for every database, print list of tables along with their row count
#######################################################
$rowcount_query = "
select t.name ,s.row_count from sys.tables t
join sys.dm_db_partition_stats s
ON t.object_id = s.object_id
and t.type_desc = 'USER_TABLE'
and s.index_id = 1
ORDER BY s.row_count DESC
"

foreach($db in $databases)
{
    # Enumerate tables and  row counts
    write-host "--------------------"
    write-host "Database:"$db.Name
    write-host "--------------------"
    invoke-sqlcmd -Username $user -Password $password -ServerInstance "$azuredbserver" -Database $db.Name -Query $rowcount_query
}
