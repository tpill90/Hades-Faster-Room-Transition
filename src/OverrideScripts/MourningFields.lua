---@diagnostic disable: undefined-global

-- TODO comment
ModUtil.Path.Override("LeaveRoomHBossPresentation", function(currentRun, exitDoor)
    print("LeaveRoomHBossPresentation")
    local currentRoom = CurrentRun.CurrentRoom
    local roomData = RoomData[currentRoom.Name] or currentRoom
    HideCombatUI("LeaveRoomHBossPresentation")
    AddInputBlock({ Name = "LeaveRoomHBossPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")

    LeaveRoomAudio(currentRun, exitDoor)

    if exitDoor ~= nil then
        if exitDoor.AdditionalIcons ~= nil and not IsEmpty(exitDoor.AdditionalIcons) then
            Destroy({ Ids = GetAllValues(exitDoor.AdditionalIcons) })
            exitDoor.AdditionalIcons = nil
        end
        DestroyDoorRewardPresenation(exitDoor)
        if exitDoor.ExitDoorOpenAnimation ~= nil then
            SetAnimation({ DestinationId = exitDoor.ObjectId, Name = exitDoor.ExitDoorOpenAnimation })
        end
    end

    Stop({ Id = CurrentRun.Hero.ObjectId })
    wait(0.01)

    PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENULoudLow" })
    local unequipAnimation = GetEquippedWeaponValue("UnequipAnimation") or "MelinoeIdleWeaponless"
    SetAnimation({ Name = unequipAnimation, DestinationId = CurrentRun.Hero.ObjectId })
    PanCamera({ Id = exitDoor.ObjectId, Duration = 1.1, OffsetY = -50, EaseOut = 0 })

    -- wait(0.5)

    SetAnimation({ Name = "Melinoe_Drop_Exit_Start", DestinationId = CurrentRun.Hero.ObjectId, SpeedMultiplier = 0.5 })

    -- wait(0.35)

    PlaySound({ Name = "/VO/MelinoeEmotes/EmoteEvading" })
    local args = {}
    args.SuccessDistance = 20
    args.DisableCollision = true
    local exitPath = {}
    table.insert(exitPath, exitDoor.ObjectId)
    thread(MoveHeroAlongPath, exitPath, args)

    thread(FullScreenFadeOutAnimation, "RoomTransitionIn")

    -- wait(0.2)

    PanCamera({ Id = exitDoor.ObjectId, Duration = 1.2, OffsetY = 85, Retarget = true })
    -- thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.25 }, })
    -- thread(SlightDescent)

    local notifyName = "LeaveRoomHBossPresentationFade"
    NotifyOnAnimationTimeRemaining({ Id = ScreenAnchors.Transition, Animation = "RoomTransitionIn", Remaining = 0.02, Notify = notifyName, Timeout = 1.0 })
    waitUntil(notifyName)
    -- wait(0.05)

    WaitForSpeechFinished()

    RemoveInputBlock({ Name = "LeaveRoomHBossPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)

-- TODO comment
ModUtil.Path.Override("LeaveRoomHPostBossPresentation", function(currentRun, exitDoor, args)
    print("LeaveRoomHPostBossPresentation")
    HideCombatUI("LeaveRoomHPostBossPresentation")
    AddInputBlock({ Name = "LeaveRoomHPostBossPresentation" })

    Stop({ Id = CurrentRun.Hero.ObjectId })
    MoveHeroToRoomPosition({ DestinationId = args.MoveTargetId })
    AngleTowardTarget({ Id = CurrentRun.Hero.ObjectId, DestinationId = exitDoor.ObjectId })
    SetAnimation({ Name = "Blank", DestinationId = exitDoor.ObjectId })
    -- wait(0.65)

    local unequipAnimation = GetEquippedWeaponValue("UnequipAnimation") or "MelinoeIdleWeaponless"
    SetAnimation({ Name = unequipAnimation, DestinationId = CurrentRun.Hero.ObjectId })

    local soundId = nil

    thread(PlayVoiceLines, GlobalVoiceLines.PostBossHiddenExitUsedVoiceLines, true)

    -- Door opening
    if args.FirstVisitRequirements == nil or IsGameStateEligible(exitDoor, args.FirstVisitRequirements) then
        PanCamera({ Id = exitDoor.ObjectId, Duration = 2.1, OffsetY = -50, EaseOut = 0 })

        wait(1.0)

        local loopingSoundId = PlaySound({ Name = "/SFX/Menu Sounds/CauldronWhispers", Id = CurrentRun.Hero.ObjectId })


        wait(0.5)

        SetAnimation({ Name = "Melinoe_Gesture_ToWeaponless", DestinationId = CurrentRun.Hero.ObjectId })
        CreateAnimation({ Name = "MelHPostBossHandFxLeft", DestinationId = CurrentRun.Hero.ObjectId, Group = "FX_Standing_Add" })
        CreateAnimation({ Name = "MelHPostBossHandFxRight", DestinationId = CurrentRun.Hero.ObjectId, Group = "FX_Standing_Add" })
        CreateAnimation({ Name = "MelHPostBossHandFxLeftB", DestinationId = CurrentRun.Hero.ObjectId, Group = "FX_Standing_Add" })
        CreateAnimation({ Name = "MelHPostBossHandFxRightB", DestinationId = CurrentRun.Hero.ObjectId, Group = "FX_Standing_Add" })

        wait(0.3)

        CreateAnimation({ Name = "CWEntranceHadesSymbolIn", DestinationId = 637439, OffsetZ = 200 })

        wait(2.3)

        PlaySound({ Name = "/SFX/Menu Sounds/CauldronSpellCompleteNova", Id = CurrentRun.Hero.ObjectId })
        StopAnimation({ Name = "CWEntranceDoorGlowAnim", DestinationId = exitDoor.ObjectId })

        wait(0.4)


        StopSound({ Id = loopingSoundId, Duration = 0.4 })
        loopingSoundId = nil

        ShakeScreen({ Distance = 8, Speed = 500, Duration = 0.3, FalloffSpeed = 1000 })
        thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 3.0 }, })

        SetScale({ Ids = { 566218, 556772, 556773 }, Fraction = 0.0, Duration = 0.0 })
        CreateAnimation({ Name = "CWEntranceDoorOpen", DestinationId = 566218 })


        PlaySound({ Name = "/SFX/Enemy Sounds/Polyphemus/PolyphemusRockThrowImpact", Id = 556772 })

        soundId = PlaySound({ Name = "/SFX/Menu Sounds/CWTrapDoorSlide", })
        SetVolume({ Id = soundId, Value = 2.0 })
        wait(0.05)
        StopAnimation({ Name = "CWEntranceHadesSymbolLoop", DestinationId = 637439 })
        AdjustFullscreenBloom({ Name = "FullscreenFlash2", Duration = 0.0 })
        AdjustFullscreenBloom({ Name = "Off", Duration = 1 })
        wait(0.95)
        StopAnimation({ Name = "MelHPostBossHandFxLeft", DestinationId = CurrentRun.Hero.ObjectId })
        StopAnimation({ Name = "MelHPostBossHandFxRight", DestinationId = CurrentRun.Hero.ObjectId })
        StopAnimation({ Name = "MelHPostBossHandFxLeftB", DestinationId = CurrentRun.Hero.ObjectId })
        StopAnimation({ Name = "MelHPostBossHandFxRightB", DestinationId = CurrentRun.Hero.ObjectId })

        SetAnimation({ Name = "MelinoeIdleWeaponless", DestinationId = CurrentRun.Hero.ObjectId })

        wait(1.0)
    else
        -- wait(0.4)
        StopAnimation({ Name = "CWEntranceDoorGlowAnim", DestinationId = exitDoor.ObjectId })
        -- wait(0.4)
        SetScale({ Ids = { 566218, 556772, 556773 }, Fraction = 0.0, Duration = 0.0 })
        CreateAnimation({ Name = "CWEntranceDoorOpen", DestinationId = 566218 })
        PlaySound({ Name = "/SFX/Enemy Sounds/Polyphemus/PolyphemusRockThrowImpact", Id = 556772 })

        soundId = PlaySound({ Name = "/SFX/Menu Sounds/CWTrapDoorSlide", })
        SetVolume({ Id = soundId, Value = 2.0 })

        -- wait(0.75)
    end

    StopSound({ Id = soundId, Duration = 0.1 })

    -- wait(0.2)

    LeaveRoomAudio(currentRun, exitDoor)

    SetAnimation({ Name = "Melinoe_Drop_Exit_Start", DestinationId = CurrentRun.Hero.ObjectId, SpeedMultiplier = 0.5 })

    -- wait(0.35)

    thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.17, Duration = 0.2 }, })
    PlaySound({ Name = "/VO/MelinoeEmotes/EmoteEvading" })
    local args = {}
    args.SuccessDistance = 20
    args.DisableCollision = true
    local exitPath = {}
    table.insert(exitPath, exitDoor.ObjectId)
    thread(MoveHeroAlongPath, exitPath, args)

    -- wait(0.2)

    PanCamera({ Id = exitDoor.ObjectId, Duration = 1.2, OffsetY = 85, Retarget = true })
    thread(SlightDescent)

    FullScreenFadeOutAnimation("RoomTransitionIn_Down")
    RemoveInputBlock({ Name = "LeaveRoomHPostBossPresentation" })
end)
