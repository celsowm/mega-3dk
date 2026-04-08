$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Rom = Join-Path $Root 'build\rom\mega-3dk.bin'
$EmulatorRoot = Join-Path $Root 'emulators'
$ScreenshotsDir = Join-Path $Root 'screenshots'
$TempDir = Join-Path $Root 'build\tmp'
$BizHawkRom = Join-Path $TempDir 'mega-3dk-bizhawk.gen'
$VasmExe = Join-Path $Root 'toolchain\vasm\vasmm68k_mot.exe'
$DelayMs = 1000
$FrameCount = 60

if ($args.Count -ge 1 -and $args[0]) {
    $DelayMs = [int]$args[0]
}

New-Item -ItemType Directory -Force -Path $ScreenshotsDir | Out-Null
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

# Build fresh ROM so config/debug changes are reflected.
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

# Keep BizHawk config isolated; if it becomes invalid JSON, regenerate it.
$Config = Join-Path $TempDir ("bizhawk-{0}.ini" -f (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
if (Test-Path $Config) { Remove-Item -LiteralPath $Config -Force -ErrorAction SilentlyContinue }

Copy-Item -LiteralPath $Rom -Destination $BizHawkRom -Force

$Output = Join-Path $ScreenshotsDir ("bizhawk-{0}.png" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$LuaPath = Join-Path $TempDir 'bizhawk-screenshot.lua'
$LuaScript = @"
for i = 1, $FrameCount do
  emu.frameadvance()
end

client.screenshot([[$Output]])
client.exitCode(0)
"@

Set-Content -LiteralPath $LuaPath -Value $LuaScript -Encoding ASCII

$Process = Start-Process -FilePath $Exe.FullName -ArgumentList @('--config', $Config, '--lua', $LuaPath, $BizHawkRom) -WorkingDirectory $Exe.DirectoryName -PassThru
Start-Sleep -Milliseconds $DelayMs

for ($i = 0; $i -lt 480 -and -not (Test-Path $Output); $i++) {
    Start-Sleep -Milliseconds 250
}

if (-not $Process.HasExited) {
    Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue
}

if (-not (Test-Path $Output)) {
    throw 'BizHawk screenshot failed: Lua screenshot file was not created'
}

Write-Host "Screenshot saved: $Output"
