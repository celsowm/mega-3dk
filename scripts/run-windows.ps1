$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Rom = "$Root\build\rom\mega-3dk.bin"
$Exe = Get-ChildItem "$Root\emulator" -Filter "blastem*.exe" -Recurse | Select-Object -First 1
if (-not $Exe) { throw "BlastEm não encontrado" }
if (-not (Test-Path $Rom)) { throw "ROM não encontrada" }
& $Exe.FullName $Rom
