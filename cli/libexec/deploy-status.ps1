# Usage: deploy status
# Summary: Display status info

. "$psscriptroot\..\lib\core.ps1"

$root = root
$git_root = git_root

if(!$root) {
	if($git_root) {
		warn "no deploy config: use deploy init"	
	} else {
		abort "no deploy config, and not inside git repo"
	}
} else {
	"App: $(app)"
	"Deploy URL: $(baseurl)"
	"Local root: $root"
}

if($git_root) {
	"Git root: $(git_root)"
}
