---@diagnostic disable: undefined-global

-- Ephyra -- Animations for when you enter the central hub
ModUtil.Path.Override("HubCombatRoomEntrance", function(currentRun, exitDoor)
    print("HubCombatRoomEntrance")
    local exitDoorId = exitDoor.ObjectId
    local door = MapState.OfferedExitDoors[exitDoorId]

    AddInputBlock({ Name = "LeaveRoomPresentation" })

    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")
    HideCombatUI("HubCombatRoomEntrance")

    if door ~= nil then
        DestroyDoorRewardPresenation(door)
        -- if door.ExitDoorOpenAnimation ~= nil then
        --     SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
        --     thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.4 }, })
        --     wait(0.02)
        -- end
    end

    local heroExitPointId = nil
    if exitDoorId ~= nil then
        AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = exitDoorId })
        local heroExitIds = GetIdsByType({ Name = "HeroExit" })
        heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 300 })
        if heroExitPointId < 0 then
            heroExitPointId = exitDoorId
        end
        -- PanCamera({ Id = heroExitPointId, Duration = 3.0 })
        SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })
        local args = {}
        args.SuccessDistance = 30
        local exitPath = exitDoor.ExitPath or currentRun.CurrentRoom.ExitPath or {}
        if door ~= nil and door.ExitThroughCenter then
            table.insert(exitPath, door.ObjectId)
        end
        table.insert(exitPath, heroExitPointId)
        -- thread(MoveHeroAlongPath, exitPath, args)
    end

    LeaveRoomAudio(currentRun, exitDoor)

    -- Leaving .1 seconds so that it isn't so strangely abrupt when changing rooms
    wait(0.1)

    -- SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = 0.35 })

    -- FullScreenFadeOutAnimation(roomData.EnterWipeAnimation or GetDirectionalWipeAnimation({ TowardsId = heroExitPointId, Enter = false }))

    -- wait(0.31)
    WaitForSpeechFinished()
    RemoveInputBlock({ Name = "LeaveRoomPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)
