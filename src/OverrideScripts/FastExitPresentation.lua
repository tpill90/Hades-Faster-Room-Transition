---@diagnostic disable: undefined-global

-- TODO Ephyra - Leaving rooms
ModUtil.Path.Override("FastExitPresentation", function(currentRun, exitDoor)
    print("FastExitPresentation")
    local exitDoorId = exitDoor.ObjectId
    local door = MapState.OfferedExitDoors[exitDoorId]

    AddInputBlock({ Name = "LeaveRoomPresentation" })

    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")
    HideCombatUI("FastExitPresentation")

    local heroExitIds = GetIdsByType({ Name = "HeroExit" })
    local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 800 })

    if heroExitPointId > 0 then
        SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })
        local args = {}
        args.SuccessDistance = 30
        local exitPath = exitDoor.ExitPath or currentRun.CurrentRoom.ExitPath or {}
        if door ~= nil and door.ExitThroughCenter then
            table.insert(exitPath, door.ObjectId)
        end
        if door ~= nil and door.ExitThroughHeroEnd then
            table.insert(exitPath, GetClosest({ Id = door.ObjectId, DestinationIds = GetIdsByType({ Name = "HeroEnd" }) }))
        end
        table.insert(exitPath, heroExitPointId)
        -- thread(MoveHeroAlongPath, exitPath, args)
    else
        print("FastExitPresentation - else")
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

    -- Leaving .1 seconds so that it isn't so strangely abrupt when changing rooms
    wait(0.1)

    -- FullScreenFadeOutAnimation(roomData.EnterWipeAnimation or GetDirectionalWipeAnimation({ TowardsId = heroExitPointId, Enter = false }))

    -- wait(0.26)

    WaitForSpeechFinished()

    RemoveInputBlock({ Name = "LeaveRoomPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)
