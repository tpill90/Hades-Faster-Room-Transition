---@diagnostic disable: undefined-global

-- TODO
ModUtil.Path.Override("BiomeQLeaveRoomPresentation", function(currentRun, exitDoor)
    print("BiomeQLeaveRoomPresentation")

    local exitDoorId = exitDoor.ObjectId
    local door = MapState.OfferedExitDoors[exitDoorId]

    AddInputBlock({ Name = "BiomeQLeaveRoomPresentation" })

    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")
    HideCombatUI("BiomeQLeaveRoomPresentation")

    if door ~= nil then
        thread(DestroyDoorRewardPresenation, door)
        if door.ExitDoorOpenAnimation ~= nil then
            print("ExitDoorOpenAnimation")
            SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
            ClearCameraClamp({ LerpTime = 0.0 })
            ZeroMouseTether("BiomeQLeaveRoomPresentation")
            thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.4 }, })
            PanCamera({ Id = currentRun.Hero.ObjectId, Duration = 0.65, FromCurrentLocation = true, Retarget = true })
            wait(0.7)
        else
            print("else")
            -- consolidate and delete when we have an exit animation above
            ClearCameraClamp({ LerpTime = 0.0 })
            ZeroMouseTether("BiomeQLeaveRoomPresentation")
            thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.4 }, })
            PanCamera({ Id = currentRun.Hero.ObjectId, Duration = 0.65, FromCurrentLocation = true, Retarget = true })
            wait(0.7)
        end
    end
    local heroExitIds = GetIdsByType({ Name = "HeroExit" })
    local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 800 })
    if heroExitPointId > 0 then
        if not currentRun.CurrentRoom.BlockExitPan then
            local cameraPanId = SpawnObstacle({ Name = "InvisibleTarget", DestinationId = CurrentRun.Hero.ObjectId, OffsetY = -1000 })
            PanCamera({ Id = cameraPanId, Duration = 3.0, FromCurrentLocation = true, EaseIn = 0 })
        end
        SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })
        local args = {}
        args.SuccessDistance = 30
        local exitPath = exitDoor.ExitPath or currentRun.CurrentRoom.ExitPath or {}
        if door ~= nil and door.ExitThroughCenter then
            table.insert(exitPath, door.ObjectId)
        end
        table.insert(exitPath, heroExitPointId)
        thread(MoveHeroAlongPath, exitPath, args)
    else
        if exitDoorId ~= nil then
            AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = exitDoorId })
        end
        SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = 1.0 })
        SetAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = currentRun.CurrentRoom.ExitAnimation or RoomData.BaseRoom.ExitAnimation })
        CreateAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = currentRun.CurrentRoom.ExitVfx or RoomData.BaseRoom.ExitVfx })
        if door ~= nil and door.ExitPortalSound then
            PlaySound({ Name = door.ExitPortalSound or "/SFX/Menu Sounds/ChaosRoomEnterExit" })
        end
    end

    LeaveRoomAudio(currentRun, exitDoor)
    if exitDoor.Room.ExitTowardsFunctionName ~= nil then
        CallFunctionName(exitDoor.Room.ExitTowardsFunctionName, exitDoor, exitDoor.Room.ExitTowardsFunctionArgs)
    end

    wait(0.1)

    -- if door ~= nil and door.ExitDoorCloseAnimation ~= nil then
    --     SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorCloseAnimation })
    --     thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.2 }, })
    -- end

    wait(0.02)

    FullScreenFadeOutAnimation("RoomTransitionIn_Up")

    PlaySound({ Name = "/Leftovers/SFX/FootstepsSequence" })

    WaitForSpeechFinished()

    RemoveInputBlock({ Name = "BiomeQLeaveRoomPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)
