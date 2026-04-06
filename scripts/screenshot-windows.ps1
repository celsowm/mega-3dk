$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Rom = Join-Path $Root 'build\rom\mega-3dk.bin'
$EmulatorRoot = Join-Path $Root 'emulator'
$DelayMs = 2000

if ($args.Count -ge 1 -and $args[0]) {
    $DelayMs = [int]$args[0]
}

if (-not (Test-Path $Rom)) {
    throw "ROM not found: $Rom"
}

$Exe = Get-ChildItem $EmulatorRoot -Filter 'blastem*.exe' -Recurse | Select-Object -First 1
if (-not $Exe) {
    throw "BlastEm not found under: $EmulatorRoot"
}

$Process = Start-Process -FilePath $Exe.FullName -ArgumentList @($Rom) -WorkingDirectory $Exe.DirectoryName -PassThru
Start-Sleep -Milliseconds $DelayMs

$Shell = New-Object -ComObject WScript.Shell
if (-not $Shell.AppActivate($Process.Id)) {
    Start-Sleep -Milliseconds 500
    [void]$Shell.AppActivate($Process.Id)
}

Start-Sleep -Milliseconds 150
[void]$Shell.SendKeys('p')
