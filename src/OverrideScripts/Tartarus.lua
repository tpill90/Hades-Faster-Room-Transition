---@diagnostic disable: undefined-global

-- This is for the chamber after Cerberus that contains the pool.  This speeds up the animation where Melinoe opens up the trap door and jumps in.
ModUtil.Path.Override("TartarusChamberMoverPresentation", function(usee, args, user)
    args = args or {}
    AddInputBlock({ Name = "MelUsedSystemObject" })
    HideUseButton(usee.ObjectId, usee)
    UseableOff({ Id = usee.ObjectId })
    MapState.RoomRequiredObjects[usee.ObjectId] = nil

    thread(PlayVoiceLines, HeroVoiceLines.ChamberMoverUsedVoiceLines)
    PanCamera({ Id = usee.ObjectId, Duration = 1.1, FromCurrentLocation = true, Retarget = true, OffsetY = 0, EaseIn = 0 })

    if not GameState.ReachedTrueEnding then
        FocusCamera({ Fraction = 1.02, Duration = 15, ZoomType = "Ease" })

        -- wait(0.1)

        Stop({ Id = CurrentRun.Hero.ObjectId })
        MoveHeroToRoomPosition({ DestinationId = 692127 })
        AngleTowardTarget({ Id = CurrentRun.Hero.ObjectId, DestinationId = usee.ObjectId })

        -- wait(0.41)
    else
        FocusCamera({ Fraction = 1.02, Duration = 10, ZoomType = "Ease" })
        AngleTowardTarget({ Id = CurrentRun.Hero.ObjectId, DestinationId = usee.ObjectId })
        CreateAnimation({ Name = "CWEntranceHadesSymbolIn", DestinationId = usee.ObjectId, OffsetZ = 120, OffsetX = -40, Group = "Combat_Menu_TraitTray" })
    end

    local unequipAnimation = GetEquippedWeaponValue("UnequipAnimation") or "MelinoeIdleWeaponless"
    SetAnimation({ Name = unequipAnimation, DestinationId = CurrentRun.Hero.ObjectId })

    -- wait(0.7)

    -- AdjustFullscreenBloom({ Name = "DesaturatedLight", Duration = 0.9 })
    local vignetteAName = "NightmareVignetteLoop"
    local loopingSoundId = nil

    if not GameState.ReachedTrueEnding then
        thread(DoRumble, { { ScreenPreWait = 0.02, LeftFraction = 0.13, Duration = 1.5 }, })
        ScreenAnchors.FullscreenAlertFxAnchor = CreateScreenObstacle({ Name = "BlankObstacle", Group = "Events", X = ScreenCenterX, Y = ScreenCenterY })
        if ConfigOptionCache.GraphicsQualityPreset == "GraphicsQualityPreset_Low" then
            -- None
        else
            CreateAnimation({ Name = "NightmareEdgeFxSpawner", DestinationId = CurrentRun.Hero.ObjectId }) --nopkg
        end
        local vignetteA = CreateAnimation({ Name = vignetteAName, DestinationId = ScreenAnchors.FullscreenAlertFxAnchor, ScaleX = ScreenScaleX, ScaleY = ScreenScaleY })
        DrawScreenRelative({ Id = vignetteA })

        AdjustRadialBlurDistance({ Fraction = 0.25, Duration = 0.1 })
        AdjustRadialBlurStrength({ Fraction = 1.0, Duration = 0.1 })

        loopingSoundId = PlaySound({ Name = "/SFX/Menu Sounds/CauldronWhispers", Id = CurrentRun.Hero.ObjectId })
        SetAnimation({ Name = "Melinoe_Gesture", DestinationId = CurrentRun.Hero.ObjectId, SpeedMultiplier = 1.2 })

        CreateAnimation({ Name = "MelHPostBossHandFxLeft", DestinationId = CurrentRun.Hero.ObjectId, Group = "FX_Standing_Add" })
        CreateAnimation({ Name = "MelHPostBossHandFxRight", DestinationId = CurrentRun.Hero.ObjectId, Group = "FX_Standing_Add" })
        CreateAnimation({ Name = "MelHPostBossHandFxLeftB", DestinationId = CurrentRun.Hero.ObjectId, Group = "FX_Standing_Add" })
        CreateAnimation({ Name = "MelHPostBossHandFxRightB", DestinationId = CurrentRun.Hero.ObjectId, Group = "FX_Standing_Add" })

        CreateAnimation({ Name = "CWEntranceHadesSymbolIn", DestinationId = usee.ObjectId, OffsetZ = 120, OffsetX = -40, Group = "Combat_Menu_TraitTray" })

        -- wait(2.6)
    else
        thread(DoRumble, { { ScreenPreWait = 0.02, LeftFraction = 0.13, Duration = 0.2 }, })
        SetAnimation({ Name = "Melinoe_CrossCast_Start_Fast", DestinationId = CurrentRun.Hero.ObjectId })
        -- wait(0.25)
        SetAnimation({ Name = "MelinoeCrossCast", DestinationId = CurrentRun.Hero.ObjectId })
    end

    PlaySound({ Name = "/SFX/Menu Sounds/HadesSigilDoorUnlock" })

    StopAnimation({ Name = "CWEntranceHadesSymbolLoop", DestinationId = usee.ObjectId })
    SetAlpha({ Ids = usee.RewardPreviewIconIds, Fraction = 0.0, Duration = 0 })
    AdjustFullscreenBloom({ Name = "FullscreenFlash2", Duration = 0.0 })
    AdjustFullscreenBloom({ Name = "Off", Duration = 1 })


    if not GameState.ReachedTrueEnding then
        -- wait(0.3)
        StopAnimation({ Name = "MelHPostBossHandFxLeft", DestinationId = CurrentRun.Hero.ObjectId })
        StopAnimation({ Name = "MelHPostBossHandFxRight", DestinationId = CurrentRun.Hero.ObjectId })
        StopAnimation({ Name = "MelHPostBossHandFxLeftB", DestinationId = CurrentRun.Hero.ObjectId })
        StopAnimation({ Name = "MelHPostBossHandFxRightB", DestinationId = CurrentRun.Hero.ObjectId })
        StopSound({ Id = loopingSoundId, Duration = 0.4 })
        loopingSoundId = nil
    end

    AdjustRadialBlurDistance({ Fraction = 0, Duration = 1 })
    AdjustRadialBlurStrength({ Fraction = 0, Duration = 1 })

    if not GameState.ReachedTrueEnding then
        StopAnimation({ Name = vignetteAName, DestinationId = ScreenAnchors.FullscreenAlertFxAnchor })
        StopAnimation({ Name = "NightmareEdgeFxSpawner", DestinationId = CurrentRun.Hero.ObjectId })
    end

    ShakeScreen({ Distance = 8, Speed = 500, Duration = 0.3, FalloffSpeed = 1000 })
    thread(DoRumble, { { ScreenPreWait = 0.02, LeftFraction = 0.13, Duration = 0.5 }, })

    PlaySound({ Name = "/SFX/PostBossGears", Id = usee.ObjectId })
    PlaySound({ Name = "/Leftovers/SFX/LightOn", Id = usee.ObjectId, Delay = 0.25 })
    PlaySound({ Name = "/Leftovers/SFX/LightOn", Id = usee.ObjectId, Delay = 0.5 })
    PlaySound({ Name = "/Leftovers/SFX/LightOn", Id = usee.ObjectId, Delay = 0.75 })
    PlaySound({ Name = "/Leftovers/SFX/LightOn", Id = usee.ObjectId })

    -- wait(1.0)
    thread(InCombatText, usee.ObjectId, "ChamberMoverUsed", 2.0, { ShadowScaleX = 1.2, PreDelay = 0.5 })
    PlaySound({ Name = "/SFX/Enemy Sounds/Hades/Hades360Swipe", Id = usee.ObjectId })

    SetAlpha({ Ids = usee.RewardPreviewIconIds, Fraction = 1.0, Duration = 0.25, EaseIn = 0, EaseOut = 1 })
    SetAnimation({ DestinationIds = usee.RewardPreviewIconIds, Name = "ClockworkCountdown" .. (CurrentRun.RemainingClockworkGoals or 0) })
    thread(DoRumble, { { ScreenPreWait = 0.02, LeftFraction = 0.19, Duration = 0.45 }, })

    -- wait(1.50)

    AdjustColorGrading({ Name = "Off", Duration = 0.45 })
    AdjustFullscreenBloom({ Name = "Off", Duration = 0.45 })

    SetUnitProperty({ DestinationId = CurrentRun.Hero.ObjectId, Property = "Speed", Value = 600 }) -- to get her out the gate
    -- wait(0.45, RoomThreadName)
    RemoveInputBlock({ Name = "MelUsedSystemObject" })
end)

-- This is for when Melinoe dives into the pool to get to Chronos' room.
ModUtil.Path.Override("LeaveRoomIPreBoss01Presentation", function(currentRun, exitDoor)
    HideCombatUI("LeaveRoomIPreBoss01Presentation")
    AddInputBlock({ Name = "LeaveRoomIPreBoss01Presentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")

    LeaveRoomAudio(currentRun, exitDoor)

    SetAnimation({ Name = "Blank", DestinationId = exitDoor.ObjectId })

    Stop({ Id = CurrentRun.Hero.ObjectId })
    -- wait(0.01)

    PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENULoudLow" })
    AngleTowardTarget({ Id = CurrentRun.Hero.ObjectId, DestinationId = exitDoor.ObjectId })
    local unequipAnimation = GetEquippedWeaponValue("UnequipAnimation") or "MelinoeIdleWeaponless"
    SetAnimation({ Name = unequipAnimation, DestinationId = CurrentRun.Hero.ObjectId })
    PanCamera({ Id = exitDoor.ObjectId, Duration = 1.1, OffsetY = -50, EaseOut = 0 })

    -- wait(1.0)

    SetAnimation({ Name = "Melinoe_DiveExit_Start", DestinationId = CurrentRun.Hero.ObjectId })

    -- wait(0.53)

    thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.25 }, })
    PlaySound({ Name = "/VO/MelinoeEmotes/EmoteEvading" })
    PlaySound({ Name = "/Leftovers/SFX/PlayerJumpMedium" })
    local args = {}
    args.SuccessDistance = 20
    args.DisableCollision = true
    local exitPath = {}
    table.insert(exitPath, exitDoor.ObjectId)
    thread(MoveHeroAlongPath, exitPath, args)

    -- wait(0.1)

    PanCamera({ Id = exitDoor.ObjectId, Duration = 1.2, OffsetY = 85, Retarget = true })

    -- wait(0.6)
    SetAlpha({ Id = CurrentRun.Hero.ObjectId, Fraction = 0.0, Duration = 0.3 })
    CreateAnimation({ Name = "CWSandBurst_PreBoss", DestinationId = 712195, Group = "Standing" })
    PlaySound({ Name = "/SFX/SandDive", Id = 712195 })
    thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.3, Duration = 0.2 }, })

    AudioState.WaterSoundId = PlaySound({ Name = "/Ambience/SandAmbienceLoop" })
    AdjustColorGrading({ Name = "ChronosSand", Duration = 1 })
    -- wait(1.0)
    FadeOut({ Duration = 0.5, Color = Color.ChronosSand })
    -- wait(0.5)

    WaitForSpeechFinished()

    RemoveInputBlock({ Name = "LeaveRoomIPreBoss01Presentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)
