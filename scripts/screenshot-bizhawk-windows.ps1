$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Rom = Join-Path $Root 'build\rom\mega-3dk.bin'
$EmulatorRoot = Join-Path $Root 'emulator'
$ScreenshotsDir = Join-Path $Root 'screenshots'
$DelayMs = 2000

if ($args.Count -ge 1 -and $args[0]) {
    $DelayMs = [int]$args[0]
}

if (-not (Test-Path $Rom)) {
    throw "ROM not found: $Rom"
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Exe = Get-ChildItem $EmulatorRoot -Filter 'EmuHawk.exe' -Recurse | Select-Object -First 1
if (-not $Exe) {
    throw "BizHawk not found under: $EmulatorRoot"
}

New-Item -ItemType Directory -Force -Path $ScreenshotsDir | Out-Null
$Output = Join-Path $ScreenshotsDir ("bizhawk-{0}.png" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

$Process = Start-Process -FilePath $Exe.FullName -ArgumentList @($Rom) -WorkingDirectory $Exe.DirectoryName -PassThru
Start-Sleep -Milliseconds $DelayMs

$Shell = New-Object -ComObject WScript.Shell
if (-not $Shell.AppActivate($Process.Id)) {
    Start-Sleep -Milliseconds 500
    [void]$Shell.AppActivate($Process.Id)
}

Start-Sleep -Milliseconds 150
[void]$Shell.SendKeys('%{PRTSC}')

Start-Sleep -Milliseconds 250
if (-not [System.Windows.Forms.Clipboard]::ContainsImage()) {
    throw 'BizHawk screenshot failed: clipboard has no image'
}

$Image = [System.Windows.Forms.Clipboard]::GetImage()
if (-not $Image) {
    throw 'BizHawk screenshot failed: no image returned from clipboard'
}

$Image.Save($Output, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Screenshot saved: $Output"
