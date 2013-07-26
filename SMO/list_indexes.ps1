# Powershell script to filter all tables in a database schema and 
# print indexes created on those tables

import-module sqlps;
CD SQLSERVER:\SQL\$env:COMPUTERNAME\DEFAULT\Databases\msdb\tables

# "Get-ChildItem -force" includes system objects 
$tables = Get-ChildItem -force | where-object {$_.Schema -eq 'dbo' }


foreach($t in $tables)
{
   write-host '---------------------------------'
   write-host 'Table:' $t
   write-host '---------------------------------'
   foreach($i in $t.Indexes)
    {
       write-host 'Index Name:'  $i.Name
       write-host 'IsClustered:'  $i.IsClustered
       write-host 'IsUnique:'  $i.IsUnique

    }
}