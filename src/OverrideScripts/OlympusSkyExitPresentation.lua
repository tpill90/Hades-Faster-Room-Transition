ModUtil.Path.Override("OlympusSkyExitPresentation", function(currentRun, exitDoor)
    print("Olympus Sky Exit Presentation")

    CurrentRun.CurrentRoom.NextRoomEntranceFunctionNameOverride = exitDoor.NextRoomEntranceFunctionName
    CurrentRun.CurrentRoom.NextRoomEntranceFunctionArgsOverride = exitDoor.NextRoomEntranceFunctionArgs
    AddInputBlock({ Name = "OlympusLeaveRoomPresentation" })

    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")
    HideCombatUI("OlympusLeaveRoomPresentation")

    local exitDoorId = exitDoor.ObjectId
    local door = MapState.OfferedExitDoors[exitDoorId]

    Stop({ Id = CurrentRun.Hero.ObjectId })
    waitUnmodified(0.01)
    PlayInteractAnimation(exitDoorId, { Animation = GetEquippedWeaponValue("WeaponInteractAnimation") })

    if door ~= nil then
        thread(DestroyDoorRewardPresenation, door)
        if door.ExitDoorOpenAnimation ~= nil then
            SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
            thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.4 }, })
            -- wait( 0.7 )
        end
    end

    local heroExitIds = GetIdsByType({ Name = "HeroExit" })
    local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 800 })
    if heroExitPointId <= 0 and exitDoorId ~= nil then
        heroExitPointId = exitDoorId
    end

    thread(PlayVoiceLines, HeroVoiceLines.OlympusSkyExitVoiceLines, false)

    local args = {}
    args.SuccessDistance = 20
    args.DisableCollision = true
    local exitPath = {}
    table.insert(exitPath, exitDoor.ObjectId)
    thread(MoveHeroAlongPath, exitPath, args)

    waitUnmodified(0.01)

    local jumpSound = PlaySound({ Name = "/SFX/BombFusePreExplode", Id = exitDoor.ObjectId })
    local unequipAnimation = GetEquippedWeaponValue("UnequipAnimation") or "MelinoeIdleWeaponless"
    SetAnimation({ Name = unequipAnimation, DestinationId = CurrentRun.Hero.ObjectId, SpeedMultiplier = 1.8 })
    Flash({ Id = exitDoorId, Speed = 0.65, MinFraction = 0, MaxFraction = 1.0, Color = Color.White, ExpireAfterCycle = true })

    -- waitUnmodified(0.5)

    PlaySound({ Name = "/VO/MelinoeEmotes/EmoteEvading", Id = CurrentRun.Hero.ObjectId })
    SetAnimation({ Name = "Melinoe_CrossCast_Start_Fast", DestinationId = CurrentRun.Hero.ObjectId, })
    PanCamera({ Id = exitDoor.ObjectId, Duration = 1.5, OffsetY = -400, Retarget = true })

    -- waitUnmodified(0.18)

    PlaySound({ Name = "/VO/MelinoeEmotes/EmoteEvading", Id = CurrentRun.Hero.ObjectId })

    thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.25 }, })
    SetAnimation({ Name = "MelinoeCrossCastHold", DestinationId = CurrentRun.Hero.ObjectId })
    ShakeScreen({ Speed = 400, Distance = 4, Angle = 0, FalloffSpeed = 1000, Duration = 1.0 })

    waitUnmodified(0.05)
    PlaySound({ Name = "/SFX/OlympusJumpLaunchOnly" })
    StopSound({ Id = jumpSound, Duration = 0.2 })
    jumpSound = nil

    AdjustZLocation({ Id = CurrentRun.Hero.ObjectId, Distance = 1400, Duration = 0.35, })

    -- waitUnmodified(0.12)

    SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = 0.2 })
    PlaySound({ Name = "/Leftovers/World Sounds/MapZoomInShortHigh" })

    LeaveRoomAudio(currentRun, exitDoor)
    if exitDoor.Room.ExitTowardsFunctionName ~= nil then
        CallFunctionName(exitDoor.Room.ExitTowardsFunctionName, exitDoor, exitDoor.Room.ExitTowardsFunctionArgs)
    end

    if door ~= nil and door.ExitDoorCloseAnimation ~= nil then
        SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorCloseAnimation })
        thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.2 }, })
    end

    IgnoreGravity({ Id = CurrentRun.Hero.ObjectId })
    FullScreenFadeOutAnimation("RoomTransitionIn_Up")

    WaitForSpeechFinished()

    RemoveInputBlock({ Name = "OlympusLeaveRoomPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)
