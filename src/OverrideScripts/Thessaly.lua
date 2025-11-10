---@diagnostic disable: undefined-global

-- This is when you leave a room while on the ships in Thessaly
ModUtil.Path.Override("ShipsLeaveRoomPresentation", function(currentRun, exitDoor)
    print("Ships Leave RoomPresentation")

    RunWeaponMethod({ Id = currentRun.Hero.ObjectId, Weapon = "All", Method = "cancelCharge" })
    AddInputBlock({ Name = "ShipsLeaveRoomPresentation" })

    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")
    HideCombatUI("ShipsLeaveRoomPresentation")

    local exitDoorId = exitDoor.ObjectId
    local door = MapState.OfferedExitDoors[exitDoorId]

    if door ~= nil then
        thread(DestroyDoorRewardPresenation, door)
        -- if door.ExitDoorOpenAnimation ~= nil then
        --     SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
        --     thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.4 }, })
        --     wait(0.7)
        -- end
    end
    local heroExitIds = GetIdsByType({ Name = "HeroExit" })
    local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 800 })
    if heroExitPointId <= 0 and exitDoorId ~= nil then
        heroExitPointId = exitDoorId
    end

    if not currentRun.CurrentRoom.BlockExitPan then
        PanCamera({ Id = heroExitPointId, Duration = 10.0 })
    end

    Halt({ Id = CurrentRun.Hero.ObjectId })
    wait(0.02)

    AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = heroExitPointId })
    AdjustZoom({ Fraction = (currentRun.CurrentRoom.ZoomFraction or 0.75) * 1.1, LerpTime = 1.2 })

    thread(PlayVoiceLines, HeroVoiceLines.ShipsExitVoiceLines, false)
    PlaySound({ Name = "/SFX/ShipsDoorTeleport" })

    -- Mel cast anim
    SetAnimation({ Name = "Melinoe_Cast_Start", DestinationId = currentRun.Hero.ObjectId, SpeedMultiplier = 0.5 })

    -- start charging energy VFX
    CreateAnimation({ DestinationId = exitDoorId, Name = "ShipsDoorMelZwoop", Group = "FX_Standing_Add" }) --nopkg
    -- wait(1.2)

    -- energy shot VFX and camera effects
    -- PlaySound({ Name = "/SFX/ShipsDoorUse" })
    -- ShakeScreen({ Speed = 500, Distance = 4, FalloffSpeed = 1000, Duration = 0.2 })
    -- SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = 0.1 })

    LeaveRoomAudio(currentRun, exitDoor)
    if exitDoor.Room.ExitTowardsFunctionName ~= nil then
        CallFunctionName(exitDoor.Room.ExitTowardsFunctionName, exitDoor, exitDoor.Room.ExitTowardsFunctionArgs)
    end

    -- wait(0.1)

    -- if door ~= nil and door.ExitDoorCloseAnimation ~= nil then
    --     SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorCloseAnimation })
    --     thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.2 }, })
    -- end

    wait(0.02)

    -- FullScreenFadeOutAnimation("RoomTransitionIn_TopRight")

    WaitForSpeechFinished()

    RemoveInputBlock({ Name = "ShipsLeaveRoomPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)

ModUtil.Path.Override("ShipsRoomEntrancePresentation", function(currentRun, currentRoom, args)
    print("Ships Room Entrance Presentation")

    args = args or {}

    local roomData = RoomData[currentRoom.Name] or currentRoom
    local roomIntroSequenceDuration = roomData.IntroSequenceDuration or 0.3
    local roomIntroPanDuration = roomData.IntroPanDuration or 2.0

    if CurrentRun.BiomeDepthCache <= 2 then
        roomIntroSequenceDuration = roomIntroSequenceDuration + 0.5
        roomIntroPanDuration = roomIntroPanDuration + 0.5
    end

    if GetConfigOptionValue({ Name = "EditingMode" }) then
        AdjustZoom({ Fraction = (currentRoom.ZoomFraction or 0.75), LerpTime = 0.0 })
    else
        AdjustZoom({ Fraction = (currentRoom.ZoomFraction or 0.75) * (roomData.IntroZoomFactor or 0.55), LerpTime = 0.0 })
    end
    if currentRoom.CameraStartPoint then
        LockCamera({ Id = currentRoom.CameraStartPoint, Duration = 0 })
        CreateAnimation({
            DestinationId = currentRoom.CameraStartPoint,
            Name = "ShipsGustSpawnerForward",
            GroupName =
            "Combat_UI_World"
        })
    end

    SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = 0.0 })
    Teleport({ Id = currentRun.Hero.ObjectId, DestinationId = currentRoom.HeroEndPoint })
    SetGoalAngle({ Id = currentRun.Hero.ObjectId, Angle = 30 })
    wait(0.03)

    FadeIn({ Duration = 0.0 })

    FullScreenFadeInAnimation("RoomTransitionOut_TopRight")

    if currentRoom.CameraEndPoint ~= nil then
        local cameraSetupPoint = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = currentRoom.CameraEndPoint, OffsetX = -80, OffsetY = 30 })
        LockCamera({ Id = cameraSetupPoint, Duration = roomIntroSequenceDuration })
        if not args.SkipGusts then
            thread(GustWinds, { ObjectId = cameraSetupPoint, Count = 4 })
        end

        local heroExitIds = GetIdsByType({ Name = "HeroExit" })
        local heroExitPointId = heroExitIds[1]

        if not args.SkipGusts then
            thread(GustWinds, { ObjectId = heroExitPointId, AnimationName = "ShipsGustSpawnerForward", Count = 3 })
        end
    end

    wait(roomIntroPanDuration)

    AdjustZoom({ Fraction = (currentRoom.ZoomFraction or 0.75), LerpTime = 0.2 })

    wait(0.05)

    -- CreateAnimation({ DestinationId = currentRoom.HeroEndPoint, Name = "ShipsDoorBurstArrival" })
    PlaySound({ Name = "/SFX/ShipsTeleportArrive", Id = CurrentRun.Hero.ObjectId })

    wait(0.10)

    --PanCamera({ Id = currentRoom.CameraEndPoint, OffsetX = 70, OffsetY = -34, Duration = 0.2, Retarget = true })

    SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 1, Duration = 0.1 })
    CreateAnimation({ DestinationId = currentRoom.HeroEndPoint, Name = "DustPuffA" })
    CreateAnimation({ DestinationId = currentRoom.HeroEndPoint, Name = "ShipsDoorMelZwoop_In", OffsetZ = 80 }) --nopkg
    SetAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = "MelinoeDash" })
    ShakeScreen({ Speed = 500, Distance = 8, FalloffSpeed = 1000, Duration = 0.2 })
    thread(DoRumble, { { ScreenPreWait = 0.1, Fraction = 0.23, Duration = 1.0 }, })

    wait(0.03)

    thread(PlayVoiceLines, currentRoom.Encounter.EnterVoiceLines or roomData.EnterVoiceLines, true)
    thread(PlayVoiceLines, GlobalVoiceLines[currentRoom.EnterGlobalVoiceLines], true)
    wait(0.03)
    LockCamera({ Id = currentRun.Hero.ObjectId, Duration = 2.0 })
end)
