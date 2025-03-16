param (
    [switch]$Revert
)

$currentDir = Get-Location
$modName = "FastAreaExit"
$moddedTag = " --" + $modName
$luaFile = "..\Scripts\PresentationBiomeo.lua"
$lines = Get-Content $luaFile -Raw

# Patterns for replace and revert
$functionReplaces = @(
    @"
.*function LeaveRoomPresentation\( currentRun, exitDoor \)
([\s\S]*?)
end.*
"@,
    @"
.*function ExitBiomeGRoomPresentation\( currentRun, exitDoor \)
([\s\S]*?)
end.*
"@,
    @"
.*function ShipsLeaveRoomPresentation\( currentRun, exitDoor \)
([\s\S]*?)
end.*
"@

)

$newFunctions = @(
    @"
function LeaveRoomPresentation( currentRun, exitDoor )

    local exitDoorId = exitDoor.ObjectId
    local door = MapState.OfferedExitDoors[exitDoorId]
	
	AddInputBlock({ Name = "LeaveRoomPresentation" })
	
    ToggleCombatControl( { "AdvancedTooltip" } , false, "LeaveRoom" )
    HideCombatUI( "LeaveRoomPresentation" )
	
    if door ~= nil then
        thread( DestroyDoorRewardPresenation, door )
        if door.ExitDoorOpenAnimation ~= nil then
            SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
        end
    end
	
	local heroExitIds = GetIdsByType({ Name = "HeroExit" })
	local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 800 })
	if heroExitPointId > 0 then
		if not currentRun.CurrentRoom.BlockExitPan then
			PanCamera({ Id = heroExitPointId, Duration = 10.0 })
		end
		SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })
		local args = {}
		args.SuccessDistance = 30
		local exitPath = exitDoor.ExitPath or currentRun.CurrentRoom.ExitPath or {}
		if door ~= nil and door.ExitThroughCenter then
			table.insert( exitPath, door.ObjectId )
		end
		table.insert( exitPath, heroExitPointId )
		thread( MoveHeroAlongPath, exitPath, args )
	else
		if exitDoorId ~= nil then
			AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = exitDoorId })
		end
		SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = 0.15 })
		SetAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = currentRun.CurrentRoom.ExitAnimation or RoomData.BaseRoom.ExitAnimation })
		CreateAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = currentRun.CurrentRoom.ExitVfx or RoomData.BaseRoom.ExitVfx })
		if door ~= nil and door.ExitPortalSound then
			PlaySound({ Name = door.ExitPortalSound or "/SFX/Menu Sounds/ChaosRoomEnterExit" })
		end
	end
	
    LeaveRoomAudio( currentRun, exitDoor )
    if exitDoor.Room.ExitTowardsFunctionName ~= nil then
        CallFunctionName( exitDoor.Room.ExitTowardsFunctionName, exitDoor, exitDoor.Room.ExitTowardsFunctionArgs )
    end
    if door ~= nil and door.ExitDoorCloseAnimation ~= nil then
        SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorCloseAnimation })
    end
	
	
	if ScreenAnchors.Transition ~= nil then
		Destroy({Id = ScreenAnchors.Transition})
	end
	AdjustColorGrading({ Name = "Dusk", Duration = 0.15 })
	
	ScreenAnchors.Transition = CreateScreenObstacle({Name = "BlankObstacle", X = ScreenCenterX, Y = ScreenCenterY, Group = "Overlay" })
	SetAnimation({ DestinationId = ScreenAnchors.Transition, Name = "RoomTransitionIn" })
	local uniformAspectScale = ScreenScaleX
	if ScreenScaleY > ScreenScaleX then 
		uniformAspectScale = ScreenScaleY
	end
	if not ScreenState.NativeAspetRatio then
		uniformAspectScale = uniformAspectScale + 0.1 -- Scaling isn't pixel-perfect, add some buffer
	end
	SetScale({ Id = ScreenAnchors.Transition, Fraction = uniformAspectScale })
	wait(0.15)
	
    ToggleCombatControl( { "AdvancedTooltip" } , true, "LeaveRoom" )
	RemoveInputBlock({ Name = "LeaveRoomPresentation" })
end
"@,
    @"
function ExitBiomeGRoomPresentation( currentRun, exitDoor )
	AddInputBlock({ Name = "LeaveRoomPresentation" })
	ToggleCombatControl( { "AdvancedTooltip" } , false, "LeaveRoom" )
	HideCombatUI( "ExitBiomeGRoomPresentation" )
	LeaveRoomAudio( currentRun, exitDoor )
	thread( PlayerUseBiomeGDoorPresentation, exitDoor )
	if exitDoor ~= nil then
		if exitDoor.AdditionalIcons ~= nil and not IsEmpty( exitDoor.AdditionalIcons ) then
			Destroy({ Ids = GetAllValues( exitDoor.AdditionalIcons ) })
			exitDoor.AdditionalIcons = nil
		end
		DestroyDoorRewardPresenation( exitDoor )
		if exitDoor.ExitDoorOpenAnimation ~= nil then
			SetAnimation({ DestinationId = exitDoor.ObjectId, Name = exitDoor.ExitDoorOpenAnimation })
		end
	end
	thread( PlayVoiceLines, HeroVoiceLines.OceanusExitVoiceLines, true )
	
	
	if ScreenAnchors.Transition ~= nil then
		Destroy({Id = ScreenAnchors.Transition})
	end
	AdjustColorGrading({ Name = "Dusk", Duration = 0.15 })
	
	ScreenAnchors.Transition = CreateScreenObstacle({Name = "BlankObstacle", X = ScreenCenterX, Y = ScreenCenterY, Group = "Overlay" })
	SetAnimation({ DestinationId = ScreenAnchors.Transition, Name = "RoomTransitionIn" })
	local uniformAspectScale = ScreenScaleX
	if ScreenScaleY > ScreenScaleX then 
		uniformAspectScale = ScreenScaleY
	end
	if not ScreenState.NativeAspetRatio then
		uniformAspectScale = uniformAspectScale + 0.1 -- Scaling isn't pixel-perfect, add some buffer
	end
	SetScale({ Id = ScreenAnchors.Transition, Fraction = uniformAspectScale })
	wait(0.15)
	
	
	RemoveInputBlock({ Name = "LeaveRoomPresentation" })
	ToggleCombatControl( { "AdvancedTooltip" } , true, "LeaveRoom" )	
end
"@,
    @"
function ShipsLeaveRoomPresentation( currentRun, exitDoor )
	AddInputBlock({ Name = "ShipsLeaveRoomPresentation" })
	ToggleCombatControl( { "AdvancedTooltip" } , false, "LeaveRoom" )
	HideCombatUI( "ShipsLeaveRoomPresentation" )

	local exitDoorId = exitDoor.ObjectId
	local door = MapState.OfferedExitDoors[exitDoorId]

	if door ~= nil then
		thread( DestroyDoorRewardPresenation, door )
		if door.ExitDoorOpenAnimation ~= nil then
			SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
		end
	end
	local heroExitIds = GetIdsByType({ Name = "HeroExit" })
	local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 800 })
	if heroExitPointId <= 0 and exitDoorId ~= nil then
		heroExitPointId = exitDoorId
	end

	if not currentRun.CurrentRoom.BlockExitPan then
		PanCamera({ Id = heroExitPointId, Duration = 10.0 })
	end
	AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = heroExitPointId })
	AdjustZoom({ Fraction = (currentRun.CurrentRoom.ZoomFraction or 0.75) * 1.1, LerpTime = 1.2 })
	
	thread( PlayVoiceLines, HeroVoiceLines.ShipsExitVoiceLines, false )
	PlaySound({ Name = "/SFX/ShipsDoorTeleport" })

	-- Mel cast anim 
	SetAnimation({ Name = "Melinoe_Cast_Start", DestinationId = currentRun.Hero.ObjectId, SpeedMultiplier = 2 })
	-- start charging energy VFX
	CreateAnimation({ DestinationId = exitDoorId, Name = "ShipsDoorMelZwoop", Group = "FX_Standing_Add" })
	-- energy shot VFX and camera effects
	PlaySound({ Name = "/SFX/ShipsDoorUse" })
	--AdjustZoom({ Fraction = (currentRun.CurrentRoom.ZoomFraction or 0.75) * 0.9, LerpTime = 0.2 })
	-- CreateAnimation({ DestinationId = exitDoorId, Name = "ShipsDoorBurst" })
	SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = 0.1 })

	LeaveRoomAudio( currentRun, exitDoor )
	if exitDoor.Room.ExitTowardsFunctionName ~= nil then
		CallFunctionName( exitDoor.Room.ExitTowardsFunctionName, exitDoor, exitDoor.Room.ExitTowardsFunctionArgs )
	end

	if door ~= nil and door.ExitDoorCloseAnimation ~= nil then
		SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorCloseAnimation })
	end
	
	
	if ScreenAnchors.Transition ~= nil then
		Destroy({Id = ScreenAnchors.Transition})
	end
	AdjustColorGrading({ Name = "Dusk", Duration = 0.15 })
	
	ScreenAnchors.Transition = CreateScreenObstacle({Name = "BlankObstacle", X = ScreenCenterX, Y = ScreenCenterY, Group = "Overlay" })
	SetAnimation({ DestinationId = ScreenAnchors.Transition, Name = "RoomTransitionIn" })
	local uniformAspectScale = ScreenScaleX
	if ScreenScaleY > ScreenScaleX then 
		uniformAspectScale = ScreenScaleY
	end
	if not ScreenState.NativeAspetRatio then
		uniformAspectScale = uniformAspectScale + 0.1 -- Scaling isn't pixel-perfect, add some buffer
	end
	SetScale({ Id = ScreenAnchors.Transition, Fraction = uniformAspectScale })
	wait(0.15)
	
	ToggleCombatControl( { "AdvancedTooltip" } , true, "LeaveRoom" )
	RemoveInputBlock({ Name = "ShipsLeaveRoomPresentation" })
end
"@

)

#------------------------------------------------------------------ MAIN LOGIC ------------------------------------------------------------------
for ($i = 0; $i -lt $newFunctions.Length; $i++) 
{
    $newFunctions[$i] += $moddedTag
}



if (-not ($currentDir.Path -like "*Hades II\Content\ModsPS1")) 
{
    Write-Host "This script must be run from a directory containing 'Hades II\Content\ModsPS1'."
    Pause
    exit
}

if (-not (Test-Path $luaFile)) 
{
    Write-Host "The file $luaFile does not exist."
    Pause
    exit
}


if ($lines -match $moddedTag) {
    Write-Host "MOD $modName $luaFile is up to date."
    exit
}

# Wrap matched functions with --[[ and --]] and append the new functions
for ($i = 0; $i -lt $functionReplaces.Length; $i++) 
{
    $functionReplace = $functionReplaces[$i]
    $newFunction = $newFunctions[$i]
	$lines = $lines -replace $functionReplace, "--[[`$&--]]`n$newFunction`n"
}


$lines | Set-Content -Encoding Default $luaFile
Write-Host "MOD $modName $luaFile has been processed successfully."
exit