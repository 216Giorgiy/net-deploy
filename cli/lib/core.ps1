# find the root directory containing .deploy
function root() {
	$dir = $pwd
	while($dir) {
		if(test-path "$dir\.deploy") { return $dir }
		$dir = split-path $dir
	}
}

function configpath() {	"$(root)\.deploy" }
function apiurl() {
	gc (configpath)
}


function git_root() {
	if(!(gcm git)) {
		abort "git isn't installed!"
	}
	resolve-path (git rev-parse --show-toplevel)
}

function abort($msg) { write-host $msg -f darkred; exit 1 }
function success($msg) { write-host $msg -f darkgreen }
function warn($msg) { write-host $msg -f darkyellow }