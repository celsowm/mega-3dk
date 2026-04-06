$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
& "$Root\scripts\bootstrap-windows.ps1"
& "$Root\scripts\download-emulator-windows.ps1"
& "$Root\scripts\build-windows.ps1"
& "$Root\scripts\run-windows.ps1"
