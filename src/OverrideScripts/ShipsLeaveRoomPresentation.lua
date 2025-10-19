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
