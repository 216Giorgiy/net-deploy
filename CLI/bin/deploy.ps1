#requires -v 3
param($cmd)

$_appname = 'deploy'

set-strictmode -off

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\commands.ps1"

$commands = commands

if (@($null, '-h', '--help', '/?') -contains $cmd) { exec 'help' $args }
elseif ($commands -contains $cmd) { exec $cmd $args }
else { "$_appname: '$cmd' isn't a $_appname command. See '$_appname help'"; exit 1 }