$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Rom = Join-Path $Root 'build\rom\mega-3dk.bin'
$EmulatorRoot = Join-Path $Root 'emulators'
$ScreenshotsDir = Join-Path $Root 'screenshots'
$Config = Join-Path $EmulatorRoot 'config.ini'
$TempDir = Join-Path $Root 'build\tmp'
$DelayMs = 2000

if ($args.Count -ge 1 -and $args[0]) {
    $DelayMs = [int]$args[0]
}

if (-not (Test-Path $Rom)) {
    throw "ROM not found: $Rom"
}

$Exe = Get-ChildItem $EmulatorRoot -Filter 'EmuHawk.exe' -Recurse | Select-Object -First 1
if (-not $Exe) {
    throw "BizHawk not found under: $EmulatorRoot"
}

New-Item -ItemType Directory -Force -Path $ScreenshotsDir | Out-Null
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

$Output = Join-Path $ScreenshotsDir ("bizhawk-{0}.png" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$LuaPath = Join-Path $TempDir 'bizhawk-screenshot.lua'
$OutputLua = $Output -replace '\\','\\'
$FrameCount = 180

$LuaScript = @"
for i = 1, $FrameCount do
  emu.frameadvance()
end

client.screenshot("$OutputLua")
client.pause()
client.closerom()
client.exitCode(0)
"@

Set-Content -LiteralPath $LuaPath -Value $LuaScript -Encoding ASCII

$Process = Start-Process -FilePath $Exe.FullName -ArgumentList @('--config', $Config, '--lua', $LuaPath, $Rom) -WorkingDirectory $Exe.DirectoryName -PassThru
Start-Sleep -Milliseconds $DelayMs

for ($i = 0; $i -lt 80 -and -not (Test-Path $Output); $i++) {
    Start-Sleep -Milliseconds 250
}

if (-not (Test-Path $Output)) {
    throw 'BizHawk screenshot failed: Lua screenshot file was not created'
}

Write-Host "Screenshot saved: $Output"
