# This will only make changes if there is something to be setup, running it again won't hurt anything.
if (-Not(Get-Command dotnet -ErrorAction SilentlyContinue))
{
    Write-Host "The dotnet sdk is required to run this script.  Install it and try again!" -ForegroundColor Red
    return
}

if(-Not(Get-Command tcli -ErrorAction SilentlyContinue))
{
    Write-Host "Install Thunderstore CLI" -ForegroundColor Yellow
    dotnet tool install -g tcli
}

# Setting up the required manifest for development work.  We only need this while we're in development, so that r2modman will pick it up correctly.
# Otherwise this will be setup in our published release package.
if(-Not(Test-Path "./src/manifest.json"))
{
    Write-Host "Missing development manifest.json.  Building it now..."

    tcli build
    Expand-Archive "./build/tpill90-FasterRoomTransitions-1.0.0.zip" -DestinationPath "./build/extracted"
    Copy-Item "./build/extracted/manifest.json" -Destination "./src/"
    Remove-Item "./build" -Recurse -Force
}

$targetPluginDir = "C:\Users\$env:USERNAME\AppData\Roaming\r2modmanPlus-local\HadesII\profiles\Default\ReturnOfModding\plugins\tpill90-FasterRoomTransitions"
if(-Not(Test-Path $targetPluginDir))
{
    New-Item -Path $targetPluginDir -Force -ItemType SymbolicLink -Value "$((Get-Location).Path)\src"
}

Write-Host "Development Environment Setup!"