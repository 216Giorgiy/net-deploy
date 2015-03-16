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
    if($type -ne ' D' -and (gc $path -delimiter "`0" | sls "[^`r]`n")) {
        write-host "Fixing line endings for $path..." -nonewline
        $content = gc $_
        $content | sc $_
        write-host 'done.'
    }
}