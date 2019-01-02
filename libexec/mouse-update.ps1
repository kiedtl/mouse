# Usage: mouse update
# Summary: Updates Mouse
# Help: Updates Mouse to the latest version on GitHub with a simple
#       `git pull`.

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\gitutils.ps1"

$newver = dl_string $nvurl;
$nvurl = "https://raw.githubusercontent.com/Kiedtl/mouse/master/share/version.dat"
$branch = Get-GitBranch

$git = try {
    Get-Command git -ErrorAction Stop
}
catch {
    $null
}

if (!$git) {
    abort "mouse update: Mouse utilises Git to update itself. Install Git and try again."
}


if (test_internet) {
    spinner_sticks 10 80 "Updating Mouse..."
    Push-Location;
    $newver = dl_string $nvurl;
    Set-Location "$HOME/.mouse/app";
    git stash > $HOME/.mouse/dump.tmp
    git pull origin $branch --quiet --force | Out-Null

    $res = $lastexitcode

    Set-Content -Path "share\version.dat" -Value $newver;
    git commit -a -q -m "Updated Mouse" | Out-Null

    Write-Host "`r`r[ - ] Updating Mouse..." -NoNewline
    Write-Host " done                        " -f Green

    if (($res -ne 0)){
        abort "mouse error: Last exit code ( $lastexitcode  ) not equal to 0, update may have failed."
    }

    git --no-pager log --no-decorate --date=local --since="`"$last_update`"" --format="`"tformat: * %C(yellow)%h%Creset %<|(72,trunc)%s %C(cyan)%cr%Creset`"" HEAD

    success "Successfully updated Mouse."
    Pop-Location
}

else {
    spinner_sticks 5 80 "Updating Mouse... "
    Start-Sleep -m 1000
    Write-Host " error" -f Red
    abort "mouse: Unable to update Mouse: no internet."
}

