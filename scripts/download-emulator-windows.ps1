$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
New-Item -ItemType Directory -Force -Path "$Root\emulator" | Out-Null
$Zip = "$Root\emulator\blastem-win64.zip"
Invoke-WebRequest -Uri "https://www.retrodev.com/blastem/nightlies/blastem-win64.zip" -OutFile $Zip
Expand-Archive -Path $Zip -DestinationPath "$Root\emulator" -Force
