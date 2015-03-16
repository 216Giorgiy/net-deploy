# Usage: deploy fixlines
# Summary: Convert Unix line-endings
# Help: Checks modified files for those that contain Unix line-endings,
#       and converts them to Windows line-endings.

# Adapted from answer by JasonMArcher here:
# http://stackoverflow.com/questions/724083/unix-newlines-to-windows-newlines-on-windows

$root = root
$changes = git status --porcelain

$changes | % {
    $type, $path = $_.substring(0,2), "$root\$($_.substring(3))"

    if($type -ne ' D') {
        $content = [io.file]::readalltext($path)
        if($content | sls "[^`r]`n") {
            write-host "Fixing line endings for $path..." -nonewline
            $content = gc $path
            $content | sc $path
            write-host 'done.'
        }
    }
}