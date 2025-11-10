---@diagnostic disable: undefined-global

-- Regular room exit
ModUtil.Path.Override("LeaveRoomPresentation", function(currentRun, exitDoor)
    print("LeaveRoomPresentation")

    local exitDoorId = exitDoor.ObjectId
    local door = MapState.OfferedExitDoors[exitDoorId]
    local nextRoomData = nil
    local roomData = RoomData[CurrentRun.CurrentRoom.Name] or CurrentRun.CurrentRoom

    AddInputBlock({ Name = "LeaveRoomPresentation" })

    SetThreadWait("InfoBanner", 0.01)

    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")
    HideCombatUI("LeaveRoomPresentation")

    if door ~= nil then
        nextRoomData = RoomData[door.Room.Name] or door.Room
        thread(DestroyDoorRewardPresenation, door)
        -- if door.ExitDoorOpenAnimation ~= nil then
        --     SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
        -- thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.4 }, })
        -- wait(0.7)
        -- end
    end
    local heroExitIds = GetIdsByType({ Name = "HeroExit" })
    local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 800 })
    if heroExitPointId > 0 then
        -- if not currentRun.CurrentRoom.BlockExitPan then
        --     PanCamera({ Id = heroExitPointId, Duration = 10.0 })
        -- end

        SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })
        local args = {}
        args.SuccessDistance = 30
        local exitPath = exitDoor.ExitPath or currentRun.CurrentRoom.ExitPath or {}
        if door ~= nil and door.ExitThroughCenter then
            table.insert(exitPath, door.ObjectId)
        end
        table.insert(exitPath, heroExitPointId)
        -- thread(MoveHeroAlongPath, exitPath, args)
    else
        print("else")
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

    -- Leaving .1 seconds so that it isn't so strangely abrupt when changing rooms
    wait(0.1)

    -- if door ~= nil and door.ExitDoorCloseAnimation ~= nil then
    --     SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorCloseAnimation })
    --     thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.2 }, })
    -- end

    -- wait(0.02)

    -- if HasEventFunctionName(roomData.LeavePostPresentationEvents, "BiomeMapPresentation") then
    --     FullScreenFadeOutAnimation()
    -- else
    --     FullScreenFadeOutAnimation(nextRoomData.LeavePrevRoomWipeAnimation or currentRun.CurrentRoom.LeaveWipeAnimation or
    --         GetDirectionalWipeAnimation({ TowardsId = heroExitPointId, Enter = false }))
    -- end

    WaitForSpeechFinished()

    RemoveInputBlock({ Name = "LeaveRoomPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)

-- ModUtil.Path.Context.Wrap("LeaveRoomPresentation", function()
--     ModUtil.Path.Wrap("wait", function(...)
--         return
--     end)
-- end)
