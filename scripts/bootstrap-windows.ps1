$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
New-Item -ItemType Directory -Force -Path "$Root\toolchain","$Root\toolchain\vasm-src","$Root\toolchain\vasm" | Out-Null
$Archive = "$Root\toolchain\vasm.tar.gz"
Invoke-WebRequest -Uri "http://sun.hasenbraten.de/vasm/release/vasm.tar.gz" -OutFile $Archive
Write-Host "Baixado. Extraia e compile em MSYS2/MinGW se necessário."
