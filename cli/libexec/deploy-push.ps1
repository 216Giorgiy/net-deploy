# Usage: deploy push
# Summary: Push changes to deploy

. "$psscriptroot/../lib/core.ps1"
. "$psscriptroot/../lib/creds.ps1"

$url = apiurl 'build'

write-host 'authenticating...'
$username, $password = ensure_creds

write-host 'starting build...'
request $url $username $password

$state = getstate $username $password
write-host "server state: $($state.state)"