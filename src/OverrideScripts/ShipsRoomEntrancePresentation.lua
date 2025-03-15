---@diagnostic disable: undefined-global

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
