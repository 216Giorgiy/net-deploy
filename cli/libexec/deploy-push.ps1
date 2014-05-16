# Usage: deploy push
# Summary: Push changes to deploy

. "$psscriptroot/../lib/core.ps1"
. "$psscriptroot/../lib/native.ps1"

$url = 'http://windows:8083/api/promo/test'

$username, $password = ensure_creds $url

$username = 'example'
$password = 'secret'

request $url $username $password