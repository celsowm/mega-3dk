$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Write-Host "Use MSYS2/MinGW para compilar vasm no Windows e depois rode: make -C $Root build"
