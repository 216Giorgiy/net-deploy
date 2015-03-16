# Usage: deploy fixlines
# Summary: Convert Unix line-endings
# Help: Checks modified files for those that contain Unix line-endings,
#       and converts them to Windows line-endings.

# Adapted from answer by JasonMArcher here:
# http://stackoverflow.com/questions/724083/unix-newlines-to-windows-newlines-on-windows

$root = root
$changes = git status --porcelain |% { "$root\$($_.substring(3))" }

$changes | % {
    if(gc $_ -delimiter "`0" | sls "[^`r]`n") {
        write-host "Fixing line endings for $_..." -nonewline
        $content = gc $_
        $content | sc $_
        write-host 'done.'
    }
}