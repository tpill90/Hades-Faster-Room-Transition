function LeaveRoomPresentation( currentRun, exitDoor )

    local exitDoorId = exitDoor.ObjectId
    local door = MapState.OfferedExitDoors[exitDoorId]

	AddInputBlock({ Name = "LeaveRoomPresentation" })

    ToggleCombatControl( { "AdvancedTooltip" } , false, "LeaveRoom" )
    HideCombatUI( "LeaveRoomPresentation" )

    if door ~= nil then
        thread( DestroyDoorRewardPresenation, door )
        if door.ExitDoorOpenAnimation ~= nil then
            SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
        end
    end

	local heroExitIds = GetIdsByType({ Name = "HeroExit" })
	local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 800 })
	if heroExitPointId > 0 then
		if not currentRun.CurrentRoom.BlockExitPan then
			PanCamera({ Id = heroExitPointId, Duration = 10.0 })
		end
		SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })
		local args = {}
		args.SuccessDistance = 30
		local exitPath = exitDoor.ExitPath or currentRun.CurrentRoom.ExitPath or {}
		if door ~= nil and door.ExitThroughCenter then
			table.insert( exitPath, door.ObjectId )
		end
		table.insert( exitPath, heroExitPointId )
		thread( MoveHeroAlongPath, exitPath, args )
	else
		if exitDoorId ~= nil then
			AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = exitDoorId })
		end
		SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = 0.15 })
		SetAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = currentRun.CurrentRoom.ExitAnimation or RoomData.BaseRoom.ExitAnimation })
		CreateAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = currentRun.CurrentRoom.ExitVfx or RoomData.BaseRoom.ExitVfx })
		if door ~= nil and door.ExitPortalSound then
			PlaySound({ Name = door.ExitPortalSound or "/SFX/Menu Sounds/ChaosRoomEnterExit" })
		end
	end

    LeaveRoomAudio( currentRun, exitDoor )
    if exitDoor.Room.ExitTowardsFunctionName ~= nil then
        CallFunctionName( exitDoor.Room.ExitTowardsFunctionName, exitDoor, exitDoor.Room.ExitTowardsFunctionArgs )
    end
    if door ~= nil and door.ExitDoorCloseAnimation ~= nil then
        SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorCloseAnimation })
    end


	if ScreenAnchors.Transition ~= nil then
		Destroy({Id = ScreenAnchors.Transition})
	end
	AdjustColorGrading({ Name = "Dusk", Duration = 0.15 })

	ScreenAnchors.Transition = CreateScreenObstacle({Name = "BlankObstacle", X = ScreenCenterX, Y = ScreenCenterY, Group = "Overlay" })
	SetAnimation({ DestinationId = ScreenAnchors.Transition, Name = "RoomTransitionIn" })
	local uniformAspectScale = ScreenScaleX
	if ScreenScaleY > ScreenScaleX then
		uniformAspectScale = ScreenScaleY
	end
	if not ScreenState.NativeAspetRatio then
		uniformAspectScale = uniformAspectScale + 0.1 -- Scaling isn't pixel-perfect, add some buffer
	end
	SetScale({ Id = ScreenAnchors.Transition, Fraction = uniformAspectScale })
	wait(0.15)

    ToggleCombatControl( { "AdvancedTooltip" } , true, "LeaveRoom" )
	RemoveInputBlock({ Name = "LeaveRoomPresentation" })
end