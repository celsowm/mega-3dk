$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Rom = Join-Path $Root 'build\rom\mega-3dk.bin'
$EmulatorRoot = Join-Path $Root 'emulator'

if (-not (Test-Path $Rom)) {
    throw "ROM not found: $Rom"
}

$Exe = Get-ChildItem $EmulatorRoot -Filter 'blastem.exe' -Recurse | Select-Object -First 1
if (-not $Exe) {
    throw "BlastEm not found under: $EmulatorRoot"
}

Start-Process -FilePath $Exe.FullName -ArgumentList @($Rom) -WorkingDirectory $Exe.DirectoryName
