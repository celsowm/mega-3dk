$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EmulatorRoot = Join-Path $Root 'emulators'
$Zip = Join-Path $EmulatorRoot 'bizhawk-win-x64.zip'
$Headers = @{
    'User-Agent' = 'mega-3dk'
    'Accept' = 'application/vnd.github+json'
}

New-Item -ItemType Directory -Force -Path $EmulatorRoot | Out-Null

$Release = Invoke-RestMethod -Uri 'https://api.github.com/repos/TASEmulators/BizHawk/releases/latest' -Headers $Headers
$Asset = $Release.assets | Where-Object { $_.name -match '^BizHawk-.*-win-x64\.zip$' } | Select-Object -First 1

if (-not $Asset) {
    throw 'BizHawk release asset not found'
}

Write-Host "Downloading BizHawk: $($Asset.name)"
Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $Zip -Headers $Headers

Write-Host "Extracting to: $EmulatorRoot"
Expand-Archive -Path $Zip -DestinationPath $EmulatorRoot -Force
