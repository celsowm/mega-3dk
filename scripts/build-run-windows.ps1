$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$RomDir = Join-Path $Root 'build\rom'
$Rom = Join-Path $RomDir 'mega-3dk.bin'
$Entry = Join-Path $Root 'src\boot\boot.asm'
$Vasm = Join-Path $Root 'toolchain\vasm\vasmm68k_mot.exe'
$EmulatorRoot = Join-Path $Root 'emulators'

if (-not (Test-Path $Vasm)) {
    throw "vasm not found: $Vasm"
}

New-Item -ItemType Directory -Force -Path $RomDir, (Join-Path $Root 'build\tmp') | Out-Null

$IncludeDirs = @(
    'src',
    'src\boot',
    'src\core',
    'src\hw',
    'src\render',
    'src\scene',
    'src\data',
    'src\math',
    'src\debug'
)

$Args = @('-Fbin', '-m68000', '-spaces', '-o', $Rom)
foreach ($Dir in $IncludeDirs) {
    $Args += @('-I', (Join-Path $Root $Dir))
}
$Args += $Entry

Write-Host "Building ROM: $Rom"
& $Vasm @Args
if ($LASTEXITCODE -ne 0) {
    throw "Build failed with exit code $LASTEXITCODE"
}

$Exe = Get-ChildItem $EmulatorRoot -Filter 'blastem*.exe' -Recurse | Select-Object -First 1
if (-not $Exe) {
    throw "BlastEm not found under: $EmulatorRoot"
}

if (-not (Test-Path $Rom)) {
    throw "ROM not found after build: $Rom"
}

Write-Host "Running emulator: $($Exe.FullName)"
$Process = Start-Process -FilePath $Exe.FullName -ArgumentList @($Rom) -WorkingDirectory $Exe.DirectoryName -PassThru -Wait
if ($Process.ExitCode -ne 0) {
    throw "Emulator exited with code $($Process.ExitCode)"
}
