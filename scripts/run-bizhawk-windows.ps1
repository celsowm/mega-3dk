$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Rom = Join-Path $Root 'build\rom\mega-3dk.bin'
$EmulatorRoot = Join-Path $Root 'emulators'
$Config = Join-Path $EmulatorRoot 'config.ini'

if (-not (Test-Path $Rom)) {
    throw "ROM not found: $Rom"
}

$Exe = Get-ChildItem $EmulatorRoot -Filter 'EmuHawk.exe' -Recurse | Select-Object -First 1
if (-not $Exe) {
    throw "BizHawk not found under: $EmulatorRoot"
}

Start-Process -FilePath $Exe.FullName -ArgumentList @('--config', $Config, $Rom) -WorkingDirectory $Exe.DirectoryName
