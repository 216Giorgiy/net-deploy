# Usage: deploy init [url] [options]
# Summary: Initialise a project for deployment
# Help:
# Options:
# --reinit: re-init a project that's already been init'd
param($url)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\getopt.ps1"

if(!$url) { my_usage; exit 1 }

$opts, $arg, $err = getopt $args '' 'reinit'

if((root) -and !($opts.reinit)) {
	abort "already initialized!"
}

$git_root = git_root

if(!$git_root) {
	abort "no git project found!"
}

$url | out-file "$git_root\.deploy" -encoding ascii

success "initialized!"