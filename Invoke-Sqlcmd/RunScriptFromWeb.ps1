# Download SQL script from a http location and run the script  on default sql server instance

$uri = "http://blogs.msdn.com/cfs-file.ashx/__key/communityserver-blogs-components-weblogfiles/00-00-01-05-58/8625.version.sql"
$dest = "$Env:temp\version.sql"

import-module sqlps
write-host "Downloading from $uri to $dest"
invoke-webrequest -Uri $uri -outfile $dest

write-host "running T-SQL script $dest"
invoke-sqlcmd -ServerInstance . -InputFile  $dest
