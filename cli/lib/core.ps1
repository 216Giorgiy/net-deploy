# find the root directory containing deploy.json
function root() {
	$dir = $pwd
	while($dir) {
		if(test-path "$dir\deploy.json") { return $dir }
		$dir = split-path $dir
	}
	return $null
}

function configpath() {	"$(root)\deploy.json" }
function config() {
	if(!(test-path (configpath))) { return $null }
	convertfrom-json (gc (configpath) -raw)
}
function app() { (config).app }
function baseurl() { (config).url }
function apiurl($action, $baseurl, $app) {
	if(!$baseurl) { $baseurl = baseurl }
	if(!$app) { $app = app }
	"$baseurl/api/$app/$action"
}

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
function geturl($url, $username, $password) {
	$wc = new-object net.webclient
	if($username) {
		$wc.credentials = new-object net.networkcredential $username, $password
	}

	try {
		$res = $wc.downloadstring($url)
		return $res, 200
	} catch [net.webexception] {
		$res = $_.exception.response
		if(!$res) { return $_.exception.message, -1 }
		$status = $res.statuscode -as [int]
		$s = $res.getresponsestream()
		$sr = new-object io.streamreader $s
		try {
			return $sr.readtoend(), $status
		} finally {
			$sr.dispose()
		}
	}
}

function getstate($username, $password) {
	$url = apiurl 'detail'
	$json, $status = geturl $url $username $password
	if($status -ne 200) { abort "server returned $status`: $json" }
	return convertfrom-json $json
}
