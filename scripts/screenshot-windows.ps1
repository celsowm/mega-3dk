$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Rom = Join-Path $Root 'build\rom\mega-3dk.bin'
$EmulatorRoot = Join-Path $Root 'emulators'
$ScreenshotsDir = Join-Path $Root 'screenshots'
$DelayMs = 2000

if ($args.Count -ge 1 -and $args[0]) {
    $DelayMs = [int]$args[0]
}

if (-not (Test-Path $Rom)) {
    throw "ROM not found: $Rom"
}
New-Item -ItemType Directory -Force -Path $ScreenshotsDir | Out-Null

$Exe = Get-ChildItem $EmulatorRoot -Filter 'blastem*.exe' -Recurse | Select-Object -First 1
if (-not $Exe) {
    throw "BlastEm not found under: $EmulatorRoot"
}

$Before = Get-ChildItem $ScreenshotsDir -Filter 'blastem_*.png' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
$BeforePath = if ($Before) { $Before.FullName } else { '' }

$env:HOME = $ScreenshotsDir
$Process = Start-Process -FilePath $Exe.FullName -ArgumentList @($Rom) -WorkingDirectory $Exe.DirectoryName -PassThru
Start-Sleep -Milliseconds $DelayMs

$Shell = New-Object -ComObject WScript.Shell
if (-not $Shell.AppActivate($Process.Id)) {
    Start-Sleep -Milliseconds 500
    [void]$Shell.AppActivate($Process.Id)
}

Start-Sleep -Milliseconds 150
[void]$Shell.SendKeys('p')
Start-Sleep -Milliseconds 500
[void]$Shell.SendKeys('%{F4}')

$NewShot = $null
for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Milliseconds 250
    $Candidate = Get-ChildItem $ScreenshotsDir -Filter 'blastem_*.png' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($Candidate -and $Candidate.FullName -ne $BeforePath) {
        $NewShot = $Candidate.FullName
        break
    }
}

if (-not $Process.HasExited) {
    Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue
}

if (-not $NewShot) {
    throw 'BlastEm screenshot failed: no new blastem_*.png was created'
}

Write-Host "Screenshot saved: $NewShot"
