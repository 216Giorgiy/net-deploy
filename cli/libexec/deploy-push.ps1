# Usage: deploy push
# Summary: Push changes to deploy

. "$psscriptroot/../lib/core.ps1"

$cred = new-object pscredential "example", (convertto-securestring "secret2" -asplaintext -force)
$wc = new-object net.webclient
$wc.credentials = $cred

try {
	$s = $wc.openread('http://windows:8083/api/promo/test')
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