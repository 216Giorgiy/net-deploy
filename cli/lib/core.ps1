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

# convert secure string back to string
# from http://blogs.msdn.com/b/fpintos/archive/2009/06/12/how-to-properly-convert-securestring-to-string.aspx
function unsecure($secure) {
	$ptr = [intptr]::zero
	$marshal = [runtime.interopservices.marshal]
	try {
		$ptr = $marshal::SecureStringToGlobalAllocUnicode($secure)
		return $marshal::PtrToStringUni($ptr)
	} finally {
		$marshal::ZeroFreeGlobalAllocUnicode($ptr)
	}
}

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

function ensure_creds($url) {
	$creds = get_creds (host $url)
	if($creds) { return $creds }

	$username = read-host 'username'
	$password = unsecure (read-host 'password' -assecurestring)

	
}