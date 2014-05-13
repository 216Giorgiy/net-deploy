# Usage: deploy init [url] [name]
# Summary: Initialise a project for deployment
param($url)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"

if(!$url) { my_usage; exit 1 }

if(root) {
	abort "already initialized!"
}

$git_root = git_root

if(!$git_root) {
	abort "no git project found!"
}

$url | out-file "$git_root\.deploy" -encoding ascii

success "initialized!"