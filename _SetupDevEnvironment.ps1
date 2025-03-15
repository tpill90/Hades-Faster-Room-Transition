if(-Not(Get-Command tcli -ErrorAction SilentlyContinue))
{
    Write-Host "Install Thunderstore CLI" -ForegroundColor Yellow
    dotnet tool install -g tcli
}

$targetPluginDir = "C:\Users\$env:USERNAME\AppData\Roaming\r2modmanPlus-local\HadesII\profiles\Default\ReturnOfModding\plugins\tpill90-FasterRoomTransitions"

if(-Not(Test-Path $targetPluginDir))
{
    New-Item -Path $targetPluginDir -Force -ItemType SymbolicLink -Value "$((Get-Location).Path)\src"
}

#TODO copy a manifest.json over

Write-Color "Development Environment Setup!"