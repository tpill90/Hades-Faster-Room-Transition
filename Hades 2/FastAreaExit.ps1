$hadesDir = "C:\Program Files (x86)\Steam\steamapps\common\Hades II\Content"
$modName = "FastAreaExit"
$targetScript = "RoomPresentation.lua"
$replacementScript = "LeaveRoomPresentation.lua"

$functionReplace = @"
.*function LeaveRoomPresentation\( currentRun, exitDoor \)
([\s\S]*?)
end.*
"@

$moddedTag = " --" + $modName
$luaFile = "$hadesDir\Scripts\$targetScript"
$lines = Get-Content $luaFile -Raw

$newFunction = Get-Content $replacementScript -Raw
$newFunction += $moddedTag

if ($lines -match $moddedTag)
{
    Write-Host "MOD $modName $luaFile is up to date."
    exit
}

# Wrap matched functions with --[[ and --]] and append the new functions
$lines = $lines -replace $functionReplace, "--[[`$&--]]`n$newFunction`n"
$lines | Set-Content -Encoding Default $luaFile

Write-Host "MOD $modName $luaFile has been processed successfully."