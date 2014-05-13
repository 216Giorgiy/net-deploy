#requires -v 3
param($cmd)

$appname = 'deploy'

set-strictmode -off

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\commands.ps1"

$commands = commands

if (@($null, '-h', '--help', '/?') -contains $cmd) { exec 'help' $args }
elseif ($commands -contains $cmd) { exec $cmd $args }
else { "$appname`: '$cmd' isn't a $appname command. See '$appname help'"; exit 1 }