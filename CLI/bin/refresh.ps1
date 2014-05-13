# for development, update the installed scripts to match local source
. "$psscriptroot\..\lib\core.ps1"

$src = resolve-path "$psscriptroot\.."
$dest = scoop which deploy

if(!$dest) {
	"installed deploy with scoop first"; exit 1;
}

$dest = resolve-path $dest

# make sure not running from the installed directory
if("$src" -eq "$dest") { abort "$(strip_ext $myinvocation.mycommand.name) is for development only" }

'copying files...'
$output = robocopy $src $dest /mir /njh /njs /nfl /ndl /xd .git tmp /xf .DS_Store last_updated

$output | ? { $_ -ne "" }

success 'deploy was refreshed!'