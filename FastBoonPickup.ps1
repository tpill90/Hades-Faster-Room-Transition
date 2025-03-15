param (
    [switch]$Revert
)

$currentDir = Get-Location
$modName = "FastBoonPickup"
$moddedTag = " --" + $modName
$luaFile = "..\Scripts\RoomPresentation.lua"
$lines = Get-Content $luaFile -Raw

# Patterns for replace and revert
$functionReplaces = @(
    @"
.*function BoonInteractPresentation\( source, args, textLines \)
([\s\S]*?)
end.*
"@,
    @"
.*function ManaUpgradeInteractPresentation\( source, args, textLines \)
([\s\S]*?)
end.*
"@,
    @"
.*function SpellDropInteractPresentation\( source, args, textLines \)
([\s\S]*?)
end.*
"@

)

$newFunctions = @(
    @"
function BoonInteractPresentation( source, args, textLines )
	args = args or {}

	if textLines ~= nil and not textLines.IgnoreInteractAnimation then
		local interactAnim = textLines.InteractAnimation or source.InteractAnimation
		if interactAnim == nil and textLines.PlayOnce then
			interactAnim = "StatusIconWantsToTalkBoon"
		end
		if interactAnim ~= nil then
			CreateAnimation({ Name = interactAnim, DestinationId = source.ObjectId, OffsetZ = source.AnimOffsetZ })
		end
	end

	if not args.SkipAnim then
		SetAnimation({ Name = args.Anim or "MelinoeBoonInteract", DestinationId = CurrentRun.Hero.ObjectId })
	end

	AdjustFullscreenBloom({ Name = "Subtle", Duration = 0.3 })
	ScreenAnchors.FullscreenAlertFxAnchor = CreateScreenObstacle({ Name = "BlankObstacle", Group = "Events", X = ScreenCenterX, Y = ScreenCenterY })
	AdjustColorGrading({ Name = "BoonInteract", Duration = 0.3 })
	local fullscreenAlertDisplacementFx = SpawnObstacle({ Name = "BoonInteractDisplace", Group = "FX_Displacement", DestinationId = ScreenAnchors.FullscreenAlertFxAnchor})
	DrawScreenRelative({ Id = fullscreenAlertDisplacementFx })

	local fullscreenAlertColorFx = SpawnObstacle({ Name = "BoonInteractFx", Group = "FX_Standing_Top", DestinationId = ScreenAnchors.FullscreenAlertFxAnchor})
	DrawScreenRelative({ Id = fullscreenAlertColorFx })

	local boonSound = PlaySound({ Name = "/SFX/Player Sounds/ZagreusWeaponChargeup" })

	PlaySound({ Name = "/SFX/SurvivalChallengeStart2" })
	StopSound({ Id = boonSound, Duration = 0.3 })
	PlaySound({ Name = "/Leftovers/Menu Sounds/EmoteAscended" })

	AdjustColorGrading({ Name = "Devotion", Duration = 0.1 })
	AdjustFullscreenBloom({ Name = "Off", Duration = 0.1 })

	AdjustColorGrading({ Name = "Off", Duration = 3.0 })
	AdjustFullscreenBloom({ Name = "Off", Duration = 3.0 })
	SetAlpha({ Id = fullscreenAlertColorFx, Fraction = 0, Duration = 0.45 })
	SetAlpha({ Id = fullscreenAlertDisplacementFx, Fraction = 0, Duration = 0.45 })
	thread( DestroyOnDelay, { fullscreenAlertColorFx, fullscreenAlertDisplacementFx }, 3.0 )

end
"@,
    @"
function ManaUpgradeInteractPresentation( source, args, textLines )

	if textLines ~= nil and not textLines.IgnoreInteractAnimation then
		local interactAnim = textLines.InteractAnimation or source.InteractAnimation
		if interactAnim == nil and textLines.PlayOnce then
			interactAnim = "StatusIconWantsToTalkBoon"
		end
		if interactAnim ~= nil then
			CreateAnimation({ Name = interactAnim, DestinationId = source.ObjectId, OffsetZ = source.AnimOffsetZ })
		end
	end


	AdjustFullscreenBloom({ Name = "Subtle", Duration = 0.3 })
	ScreenAnchors.FullscreenAlertFxAnchor = CreateScreenObstacle({ Name = "BlankObstacle", Group = "Events", X = ScreenCenterX, Y = ScreenCenterY })
	AdjustColorGrading({ Name = "BoonInteract", Duration = 0.3 })
	local fullscreenAlertDisplacementFx = SpawnObstacle({ Name = "BoonInteractDisplace", Group = "FX_Displacement", DestinationId = ScreenAnchors.FullscreenAlertFxAnchor})
	DrawScreenRelative({ Id = fullscreenAlertDisplacementFx })

	local fullscreenAlertColorFx = SpawnObstacle({ Name = "BoonInteractFx", Group = "FX_Standing_Top", DestinationId = ScreenAnchors.FullscreenAlertFxAnchor})
	DrawScreenRelative({ Id = fullscreenAlertColorFx })

	local boonSound = PlaySound({ Name = "/SFX/Player Sounds/ZagreusWeaponChargeup" })


	PlaySound({ Name = "/Leftovers/Menu Sounds/RosterPickup" })
	StopSound({ Id = boonSound, Duration = 0.3 })
	PlaySound({ Name = "/Leftovers/Menu Sounds/EmoteAscendedDark" })

	AdjustColorGrading({ Name = "NightMoon", Duration = 0.1 })
	AdjustFullscreenBloom({ Name = "Off", Duration = 0.1 })


	AdjustColorGrading({ Name = "Off", Duration = 3.0 })
	AdjustFullscreenBloom({ Name = "Off", Duration = 3.0 })
	SetAlpha({ Id = fullscreenAlertColorFx, Fraction = 0, Duration = 0.45 })
	SetAlpha({ Id = fullscreenAlertDisplacementFx, Fraction = 0, Duration = 0.45 })
	thread( DestroyOnDelay, { fullscreenAlertColorFx, fullscreenAlertDisplacementFx }, 3.0 )
end
"@,
    @"
function SpellDropInteractPresentation( source, args, textLines )

	AdjustColorGrading({ Name = "NightMoon", Duration = 0.5 })
	PlaySound({ Name = "/Leftovers/Menu Sounds/EmoteAscendedDark" })

	if not args.SkipInteractAnim then
		AngleTowardTarget({ Id = CurrentRun.Hero.ObjectId, DestinationId = source.ObjectId })
		thread( PlayInteractAnimation, source.ObjectId  )
	end

	AngleTowardTarget({ Id = CurrentRun.Hero.ObjectId, DestinationId = source.ObjectId })
	SetAnimation({ Name= "MelTalkGifting01", DestinationId = CurrentRun.Hero.ObjectId, SpeedMultiplier = 0.35 })
	local beamTarget = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = source.ObjectId, OffsetY = -560 })
	CreateAnimation({ Name = "MoonbeamsColor", DestinationId = beamTarget, Group = "FX_Standing_Add" })
	PanCamera({ Id = source.ObjectId, OffsetY = -220, Retarget = true, Duration = 4.5 })
	FocusCamera({ Fraction = (CurrentRun.CurrentRoom.ZoomFraction or 1) * 0.875, Duration = 5.0, ZoomType = "Ease" })

	if textLines ~= nil and not textLines.IgnoreInteractAnimation then
		local interactAnim = textLines.InteractAnimation or source.InteractAnimation
		if interactAnim == nil and textLines.PlayOnce then
			interactAnim = "StatusIconWantsToTalkBoon"
		end
		if interactAnim ~= nil then
			CreateAnimation({ Name = interactAnim, DestinationId = source.ObjectId, OffsetZ = source.AnimOffsetZ })
		end
	end

	AdjustFullscreenBloom({ Name = "Subtle", Duration = 0.3 })
	ScreenAnchors.FullscreenAlertFxAnchor = CreateScreenObstacle({ Name = "BlankObstacle", Group = "Events", X = ScreenCenterX, Y = ScreenCenterY })
	AdjustColorGrading({ Name = "BoonInteract", Duration = 0.3 })
	local fullscreenAlertDisplacementFx = SpawnObstacle({ Name = "BoonInteractDisplace", Group = "FX_Displacement", DestinationId = ScreenAnchors.FullscreenAlertFxAnchor})
	DrawScreenRelative({ Id = fullscreenAlertDisplacementFx })

	local fullscreenAlertColorFx = SpawnObstacle({ Name = "BoonInteractFx", Group = "FX_Standing_Top", DestinationId = ScreenAnchors.FullscreenAlertFxAnchor})
	DrawScreenRelative({ Id = fullscreenAlertColorFx })

	local boonSound = PlaySound({ Name = "/SFX/Enemy Sounds/Hades/HadesPhase2Start" })

	PlaySound({ Name = "/Leftovers/Menu Sounds/RosterPickup" })
	StopSound({ Id = boonSound, Duration = 0.3 })
	--PlaySound({ Name = "/Leftovers/Menu Sounds/EmoteAscendedDark" })
	AdjustFullscreenBloom({ Name = "Off", Duration = 0.1 })

	AdjustColorGrading({ Name = "Off", Duration = 3.0 })
	AdjustFullscreenBloom({ Name = "Off", Duration = 3.0 })
	SetAlpha({ Id = fullscreenAlertColorFx, Fraction = 0, Duration = 0.45 })
	SetAlpha({ Id = fullscreenAlertDisplacementFx, Fraction = 0, Duration = 0.45 })
	thread( DestroyOnDelay, { fullscreenAlertColorFx, fullscreenAlertDisplacementFx }, 3.0 )

	SetAnimation({ Name= "MelTalkGifting01ReturnToIdle", DestinationId = CurrentRun.Hero.ObjectId, SpeedMultiplier = 0.5 })
	SetAlpha({ Id = beamTarget, Fraction = 0, Duration = 0.5 })
end
"@

)

#------------------------------------------------------------------ MAIN LOGIC ------------------------------------------------------------------
for ($i = 0; $i -lt $newFunctions.Length; $i++) {
    $newFunctions[$i] += $moddedTag
}



if (-not ($currentDir.Path -like "*Hades II\Content\ModsPS1")) {
    Write-Host "This script must be run from a directory containing 'Hades II\Content\ModsPS1'."
    Pause
    exit
}

if (-not (Test-Path $luaFile)) {
    Write-Host "The file $luaFile does not exist."
    Pause
    exit
}

if ($Revert) {
    $reverted = $false

    for ($i = 0; $i -lt $functionReplaces.Length; $i++) {
        $functionReplace = $functionReplaces[$i]
        $newFunction = $newFunctions[$i]
        $escapedNewFunction = [regex]::Escape($newFunction)
        # Remove new function if it exists
        if ($lines -match $escapedNewFunction) {
            $lines = $lines -replace $escapedNewFunction, ''
            $reverted = $true
        }

        # Revert original function
        if ($lines -match $functionReplace) {
            $matched = $matches[0]
            $matched = $matched -replace '^--\[\[', '' -replace '--\]\]$', ''
            $lines = $lines -replace $functionReplace, $matched
            $reverted = $true
        }

    }
    
    if (-not $reverted) {
        Write-Host "No modifications found to revert in $luaFile."
        exit
    }
    
} else {
    if ($lines -match $moddedTag) {
        Write-Host "MOD $modName $luaFile is up to date."
        exit
    }

    # Wrap matched functions with --[[ and --]] and append the new functions
    for ($i = 0; $i -lt $functionReplaces.Length; $i++) {
        $functionReplace = $functionReplaces[$i]
        $newFunction = $newFunctions[$i]
		$lines = $lines -replace $functionReplace, "--[[`$&--]]`n$newFunction`n"
    }
    
}

$lines | Set-Content -Encoding Default $luaFile
Write-Host "MOD $modName $luaFile has been processed successfully."
exit