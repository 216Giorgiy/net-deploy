# find the root directory containing .deploy
function root() {
	$dir = $pwd
	while($dir) {
		if(test-path "$dir\.deploy") { return $dir }
		$dir = split-path $dir
	}
}

function configpath() {	"$(root)\.deploy" }
function config() {	(gc (configpath)) -split ' ' }
function app() { (config)[0] }
function baseurl() { (config)[1] }
function apiurl($action) { "$(baseurl)/api/$(app)/$action" }

function git_root() {
	if(!(gcm git)) {
		abort "git isn't installed!"
	}
	$relpath = git rev-parse --show-toplevel 2> $null
	if(!$relpath) { return }
	resolve-path $relpath
}

function abort($msg) { write-host $msg -f darkred; exit 1 }
function success($msg) { write-host $msg -f darkgreen }
function warn($msg) { write-host $msg -f darkyellow }

# http functions
function host($url) {
	(new-object uri $url).getleftpart('authority')
}
function request($url, $username, $password) {
	$cred = new-object net.networkcredential $username, $password
	$wc = new-object net.webclient
	$wc.credentials = $cred

	try {
		$s = $wc.openread($url)
	} catch {
		abort $_.exception.message
	}
	$sr = new-object io.streamreader($s)
	try {
		while($line = $sr.readline()) {
			write-host $line
		}
	} finally {
		$sr.dispose()
	}
}

# returns text, status
function geturl($url) {
	$wc = new-object net.webclient

	try {
		$res = $wc.downloadstring($url)
		return $res, 200
	} catch [net.webexception] {
		$res = $_.exception.response
		$status = $res.statuscode -as [int]
		$s = $res.getresponsestream()
		$sr = new-object io.streamreader $s
		try {
			return $sr.readtoend(), $status
			return $text, $status
		} finally {
			$sr.dispose()
		}
	}
}

