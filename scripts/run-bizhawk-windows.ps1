$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Rom = Join-Path $Root 'build\rom\mega-3dk.bin'
$EmulatorRoot = Join-Path $Root 'emulators'
$TempDir = Join-Path $Root 'build\tmp'
$BizHawkRom = Join-Path $TempDir 'mega-3dk-bizhawk.gen'
$VasmExe = Join-Path $Root 'toolchain\vasm\vasmm68k_mot.exe'

New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Root 'build\rom') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Root 'build\obj') | Out-Null

if (-not (Test-Path $VasmExe)) {
    throw "VASM not found: $VasmExe"
}

$Exe = Get-ChildItem $EmulatorRoot -Filter 'EmuHawk.exe' -Recurse | Select-Object -First 1
if (-not $Exe) {
    throw "BizHawk not found under: $EmulatorRoot"
}

# Build fresh ROM.
& $VasmExe -Fbin -m68000 -spaces `
    -I (Join-Path $Root 'src') `
    -I (Join-Path $Root 'src\boot') `
    -I (Join-Path $Root 'src\core') `
    -I (Join-Path $Root 'src\hw') `
    -I (Join-Path $Root 'src\render') `
    -I (Join-Path $Root 'src\scene') `
    -I (Join-Path $Root 'src\data') `
    -I (Join-Path $Root 'src\math') `
    -I (Join-Path $Root 'src\debug') `
    -o $Rom (Join-Path $Root 'src\boot\boot.asm')
if ($LASTEXITCODE -ne 0) {
    throw "VASM build failed with exit code $LASTEXITCODE"
}

$Config = Join-Path $TempDir ("bizhawk-{0}.ini" -f (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
if (Test-Path $Config) { Remove-Item -LiteralPath $Config -Force -ErrorAction SilentlyContinue }

Copy-Item -LiteralPath $Rom -Destination $BizHawkRom -Force

Start-Process -FilePath $Exe.FullName -ArgumentList @('--config', $Config, $BizHawkRom) -WorkingDirectory $Exe.DirectoryName
