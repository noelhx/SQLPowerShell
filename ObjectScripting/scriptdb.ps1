# Powershell script to script out database, tables, sp, udfs
# Pre-req: Install SQL 2012 management tools, Open Windows powershell and run this script

import-module sqlps

if($args.Count -le 1)
{
   throw "Usage: scriptdb.ps1 server_name, db_name"
}

$srvname = $args[0]
$database = $args[1]

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null

$srv =  New-Object ("Microsoft.SqlServer.Management.SMO.Server") ($srvname)

# Gather all Urns to be included for scripting
$dbUrns = $srv.Databases[$database].Urn
$tableUrns = $srv.Databases[$database].Tables |  where-object { $_.IsSystemObject -eq $False } | foreach { $_.Urn}
$spUrns = $srv.Databases[$database].StoredProcedures |  where-object { $_.IsSystemObject -eq $False } | foreach { $_.Urn}
$viewUrns = $srv.Databases[$database].Views |  where-object { $_.IsSystemObject -eq $False } | foreach { $_.Urn}
$functionsUrns = $srv.Databases[$database].UserDefinedFunctions |  where-object { $_.IsSystemObject -eq $False } | foreach { $_.Urn}

$allUrns = @()
$allUrns = $allUrns + $viewUrns
$allUrns = $allUrns + $tableUrns 
$allUrns = $allUrns + $spUrns 
$allUrns = $allUrns + $functionsUrns
$allUrns = $allUrns + $dbUrns

$scriptingOptions = New-Object ("Microsoft.SqlServer.Management.SMO.ScriptingOptions") 
$scriptingOptions.IncludeDatabaseContext = $true

$scripter = New-Object ("Microsoft.SqlServer.Management.SMO.Scripter") ($srv)
$scripter.Options = $scriptingOptions

write-host "Scripting " $allUrns.Length " objects ..."
foreach($s in $scripter.Script($allUrns))
{
    write-host $s
    write-host "GO"
}



