function command_files {
	gci (relpath '..\libexec') | where { $_.name -match "$_appname-.*?\.ps1$" }
}

function commands {
	command_files | % { command_name $_ }
}

function command_name($filename) {
	$filename.name | sls "$_appname-(.*?)\.ps1$" | % { $_.matches[0].groups[1].value }
}

function exec($cmd, $arguments) {
	& (relpath "..\libexec\$_appname-$cmd.ps1") @arguments
}