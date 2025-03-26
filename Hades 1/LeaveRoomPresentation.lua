function LeaveRoomPresentation( currentRun, exitDoor )

	local exitDoorId = exitDoor.ObjectId
	local door = OfferedExitDoors[exitDoorId]

	AddInputBlock({ Name = "LeaveRoomPresentation" })
	ToggleControl({ Names = { "AdvancedTooltip", }, Enabled = false })

	HideCombatUI()

	if door ~= nil then
		if door.AdditionalIcons ~= nil and not IsEmpty( door.AdditionalIcons ) then
			Destroy({ Ids = door.AdditionalIcons })
			door.AdditionalIcons = nil
		end
		DestroyDoorRewardPresenation( door )
		if door.ExitDoorOpenAnimation ~= nil then
			SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
		end
	end

	local heroExitIds = GetIdsByType({ Name = "HeroExit" })
	local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 600 })
	if heroExitPointId > 0 then

		local angleToExit = GetAngleBetween({ Id = exitDoorId, DestinationId = heroExitPointId })
		if angleToExit < 90 or angleToExit > 270 then
			currentRun.CurrentRoom.ExitDirection = "Right"
		else
			currentRun.CurrentRoom.ExitDirection = "Left"
		end

		PanCamera({ Id = heroExitPointId, Duration = 10.0 })
		SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })
		local args = {}
		args.NodeSuccessDistance = 30
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
		SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = .15 })
		SetAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = currentRun.CurrentRoom.ExitAnimation or RoomData.BaseSecret.ExitAnimation })
		CreateAnimation({ DestinationId = CurrentRun.Hero.ObjectId, Name = currentRun.CurrentRoom.ExitVfx or RoomData.BaseSecret.ExitVfx })
		if door ~= nil and door.ExitPortalSound then
			PlaySound({ Name = door.ExitPortalSound or "/SFX/Menu Sounds/ChaosRoomEnterExit" })
		end
	end

	LeaveRoomAudio( currentRun, exitDoor )

	if door ~= nil and door.ExitDoorCloseAnimation ~= nil then
		SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorCloseAnimation })
	end

	wait(0.02)

	ShowInterMapComponents()

	AllowShout = false

	RemoveInputBlock({ Name = "LeaveRoomPresentation" })
	ToggleControl({ Names = { "AdvancedTooltip", }, Enabled = true })
end