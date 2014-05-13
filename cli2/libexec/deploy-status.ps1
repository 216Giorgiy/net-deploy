# Usage: deploy status
# Summary: Display status info

. "$psscriptroot\..\lib\core.ps1"

$root = root

if(!$root) {
	warn "no deploy config: use deploy init"
} else {
	"Deploy root: $(root)"	
}

"Git root: $(git_root)"