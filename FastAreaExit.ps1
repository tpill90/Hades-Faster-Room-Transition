$hadesDir = "C:\Program Files (x86)\Steam\steamapps\common\Hades II\Content"
$modName = "FastAreaExit"

$moddedTag = " --" + $modName
$lines = Get-Content "$hadesDir\Scripts\RoomPresentation.lua" -Raw

$newFunction = Get-Content .\LeaveRoomPresentation.lua -Raw
$newFunction += $moddedTag

if ($lines -match $moddedTag)
{
    Write-Host "MOD $modName $luaFile is up to date."
    exit
}

# Wrap matched functions with --[[ and --]] and append the new functions
$functionReplace = @"
.*function LeaveRoomPresentation\( currentRun, exitDoor \)
([\s\S]*?)
end.*
"@

$lines = $lines -replace $functionReplace, "--[[`$&--]]`n$newFunction`n"
$lines | Set-Content -Encoding Default $luaFile

Write-Host "MOD $modName $luaFile has been processed successfully."