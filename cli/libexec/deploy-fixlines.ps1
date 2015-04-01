# Usage: deploy fixlines
# Summary: Convert Unix line-endings
# Help: Checks modified files for those that contain Unix line-endings,
#       and converts them to Windows line-endings.

# Adapted from answer by JasonMArcher here:
# http://stackoverflow.com/questions/724083/unix-newlines-to-windows-newlines-on-windows

$root = root
$changes = git status --porcelain

# only process files that Git thinks are text
pushd $root
$non_binary = git grep -I --name-only -e "" -- .
popd

$changes | % {
    $type, $path = $_.substring(0,2), $_.substring(3)

    if(($type -ne ' D') -and ($path -in $non_binary)) {
        $fullpath = resolve-path "$root/$path"
        $content = [io.file]::readalltext($fullpath)
        if($content | sls "[^`r]`n") {
            write-host "Fixing line endings for $path..." -nonewline
            $content = gc $fullpath
            $content | sc $fullpath
            write-host 'done.'
        }
    }
}