---@diagnostic disable: undefined-global

-- This is triggered when opening the main large door at the beginning of the summit, that has Zeus on it
ModUtil.Path.Override("FortressMainDoorOpenPresentation", function(source, args)
    print("FortressMainDoorOpenPresentation")

    AddInputBlock({ Name = "FortressMainDoorOpening" })
    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")
    HideCombatUI("FortressMainDoorOpening")

    local roomData = RoomData[CurrentRun.CurrentRoom.Name] or CurrentRun.CurrentRoom
    if roomData.GateMusic ~= nil then
        MusicPlayer(roomData.GateMusic)
        SetSoundCueValue({ Names = { "Guitar" }, Id = AudioState.MusicId, Value = 1.0, Duration = 2.0 })
    end

    local fortressDoorId = GetClosestIds({ Id = CurrentRun.Hero.ObjectId, DestinationIds = GetIdsByType({ Name = "FortressMainDoor" }), Distance = 300 })[1]

    PanCamera({ Id = CurrentRun.Hero.ObjectId, Duration = 1.15, FromCurrentLocation = true, Retarget = true })
    PlayInteractAnimation(fortressDoorId, { Animation = GetEquippedWeaponValue("WeaponInteractAnimation") })
    AngleTowardTarget({ Id = CurrentRun.Hero.ObjectId, DestinationId = fortressDoorId })

    -- wait(0.7)

    SetAnimation({ Name = "FortressMainDoorOpen", DestinationId = fortressDoorId }) --nopkg
    PlaySound({ Name = "/SFX/TyphonBigDoorOpen" })
    ShakeScreen({ Speed = 500, Distance = 4, Duration = 4.0 })
    thread(DoRumble, { { ScreenPreWait = 0.02, RightFraction = 0.17, Duration = 4.0 }, })

    thread(PlayVoiceLines, HeroVoiceLines.EnteredFortressVoiceLines, true)

    -- wait(0.5)

    local cameraPanId = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = CurrentRun.Hero.ObjectId, OffsetY = -800 })
    -- PanCamera({ Id = cameraPanId, Duration = 8.0, FromCurrentLocation = true, EaseIn = 0 })
    -- FocusCamera({ Fraction = roomData.ZoomFraction * 0.85, Duration = 5, ZoomType = "Ease" })

    -- wait(2.5)

    PlaySound({ Name = "/Leftovers/World Sounds/ThunderHuge" })

    local heroExitIds = GetIdsByType({ Name = "HeroExit" })
    local heroExitPointId = GetClosest({ Id = fortressDoorId, DestinationIds = heroExitIds, Distance = 800 })
    if heroExitPointId > 0 then
        SetUnitProperty({ DestinationId = CurrentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })
        local pathArgs = { SuccessDistance = 30 }
        local exitPath = CurrentRun.CurrentRoom.ExitPath or {}
        table.insert(exitPath, heroExitPointId)
        thread(MoveHeroAlongPath, exitPath, pathArgs)
    else
        if fortressDoorId ~= nil then
            AngleTowardTarget({ Id = CurrentRun.Hero.ObjectId, DestinationId = fortressDoorId })
        end
        -- SetAlpha({ Id = CurrentRun.Hero.ObjectId, Fraction = 0, Duration = 1.0 })
        SetAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = CurrentRun.CurrentRoom.ExitAnimation or RoomData.BaseRoom.ExitAnimation })
        CreateAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = CurrentRun.CurrentRoom.ExitVfx or RoomData.BaseRoom.ExitVfx })
    end

    LeaveRoomAudio(CurrentRun, {})

    -- wait(0.42)

    FullScreenFadeOutAnimation("RoomTransitionIn_Up")

    WaitForSpeechFinished()

    RemoveInputBlock({ Name = "FortressMainDoorOpening" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)
