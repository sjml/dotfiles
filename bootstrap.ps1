$homePath = "C:\Users\" + $env:username
$dotPath = $homePath + "\.dotfiles"

if (Test-Path -Path $dotPath) {
    Write-Warning "There's already a .dotfiles directory in $homePath. Aborting bootstrap."
    Return
}

Set-ExecutionPolicy Bypass -Scope Process -Force

Push-Location $homePath

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://api.github.com/repos/sjml/dotfiles/zipball" -OutFile "dotfiles.zip"
Expand-Archive "dotfiles.zip"

# Better way to do this? Probably...
$unzipped = $homePath + "\dotfiles"
$items = Get-ChildItem -Path $unzipped
$actual = $unzipped + "\" + $items[0].Name
Move-Item $actual $dotpath

# remove excess
Remove-Item $unzipped
Remove-Item "dotfiles.zip"

Push-Location $dotPath
.\provision-windows.ps1
Pop-Location

Pop-Location
