# Usage: deploy hash <username>
# Summary: Get a hashed user configuration entry
# Help: This command is used to generate an entry to be used in the users configuration file on the deploy web server.
#
# It will prompt you to enter a password for the given username.
#
# It outputs a line in the format "username iterations:salt:hash"
param($username)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"

if(!$username) { my_usage; exit 1 }

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

$password = unsecure (read-host "password for $username" -assecurestring)
$confirm = unsecure (read-host "re-enter password" -assecurestring)

if($confirm -ne $password) {
	abort "password didn't match!"
}

$ITERATIONS = 1000
$SALT_BYTESIZE = 24
$HASH_BYTESIZE = 24

$salt = salt $SALT_BYTESIZE
$hash = pbkdf2 $password $salt $ITERATIONS $HASH_BYTESIZE

"$username $ITERATIONS`:$(base64 $salt):$(base64 $hash)"
