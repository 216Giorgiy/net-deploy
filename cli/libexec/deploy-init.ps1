# Usage: deploy init <name> <url> [options]
# Summary: Initialize a Git repo for deployment
# Help: Initializes a Git repo for deployment
#
# Parameters:
#
#   <name>: the name of the app, must be present on the server
#   <url>: the URL of the deploy server
# 
# Options:
#
#   --reinit: re-init a project that's already been init'd
param($name, $url)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\getopt.ps1"

if(!$name) { 'name is missing'; my_usage; exit 1 }
if(!$url) { 'url is missing'; my_usage; exit 1 }

if($url -notmatch '^https?://') {
	abort "invalid url: $url" 
}

$opts, $arg, $err = getopt $args '' 'reinit'

if((root) -and !($opts.reinit)) {
	abort "already initialized! use --reinit to change configuration"
}

$git_root = git_root

if(!$git_root) {
	abort "no git project found!"
}

# ensure no trailing slash for URL
$url = $url.trim('/')

$pingurl = "$url/api/global/ping"
write-host "pinging deploy server..."
$text, $code = geturl $pingurl
if(($text -ne 'net-deploy') -or ($code -ne 200)) {
	abort "$url doesn't look like a deploy server"
}

"$name $url" | out-file "$git_root\.deploy" -encoding ascii

success "initialized!"