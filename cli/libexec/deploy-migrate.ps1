# Usage: deploy migrate OR deploy migrate new <name>
# Summary: Create or run database migrations
# Help: The migrate command lets you create or run database migrations.
#
# Deploy migrations are just SQL scripts.
#
# deploy migrate
#   Run any migrations that haven't been run yet
#
# deploy migrate new <name>
#   Create a new migration

param($cmd)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"

function migrationdir() {
	return "$(root)\migrations"
}

$template = "-- migration SQL goes here
/*
-- rollback SQL goes here
*/
"

switch($cmd) {
	'' {
		# run migrations
	}
	'new' {
		$name = $args
		if(!$name) {
			"<name> missing"; my_usage; exit 1;
		}
		$name = [regex]::replace($name, '[^a-zA-Z0-9]{1,}', '_')
		$name = $name.trim('_')

		if(!(test-path (migrationdir))) {
			mkdir (migrationdir) > $null
		}

		$path = "$(migrationdir)\$(get-date -format 'yyyyMMddhhmmss')_$name.sql"

		$template | out-file $path -encoding default

		write-host "path: $path"
		
		# notepad $path
		success "created migration '$name'"
	}
	default {
		"invalid migrate command: $cmd"; my_usage; exit 1;
	}
}