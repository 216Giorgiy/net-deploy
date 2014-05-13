# find the root directory containing .deploy
function root() {
	$dir = $pwd
	while(!(test-path "$dir\.deploy")) {
		$dir = split-path $dir;
		if(!$dir) { return $null }
	}
	return $dir
}

function configpath() {
	return "$(root)\.deploy"
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