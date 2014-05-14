# Usage: deploy hash <username> <password>
# Summary: Get a hashed username/password entry
# Help: This command is used to generate a hashed username/password entry to be used in the users configuration file on the deploy web server.
#
# It outputs a line in the format username iterations:salt:hash
param($username, $password)

. "$psscriptroot\..\lib\help.ps1"

if(!$username) { my_usage; exit 1 }
if(!$password) { my_usage; exit 1 }

function base64($bytes) {
	[convert]::tobase64string($bytes)
}

function salt($bytesize) {
	$rng = new-object security.cryptography.rngcryptoserviceprovider
	$salt = new-object byte[] $bytesize
	$rng.getbytes($salt)
	$salt
}

function pbkdf2($password, $salt, $iterations, $bytesize) {
	$pbkdf2 = new-object security.cryptography.rfc2898derivebytes $password, $salt
	$pbkdf2.iterationcount = $iterations
	$pbkdf2.getbytes($bytesize)
}

$ITERATIONS = 1000
$SALT_BYTESIZE = 24
$HASH_BYTESIZE = 24

$salt = salt $SALT_BYTESIZE
$hash = pbkdf2 $password $salt $ITERATIONS $HASH_BYTESIZE

"$username $ITERATIONS`:$(base64 $salt):$(base64 $hash)"
