function AsphodelLeaveRoomPresentation( currentRun, exitDoor )

	local exitDoorId = exitDoor.ObjectId
	AddInputBlock({ Name = "LeaveRoomPresentation" })
	ToggleControl({ Names = { "AdvancedTooltip", }, Enabled = false })
	SetPlayerInvulnerable( "LeaveRoomPresentation" )
	HideCombatUI()

	local door = OfferedExitDoors[exitDoorId]
	local boatId = exitDoorId

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

	if currentRun.CurrentRoom.ExitVoiceLines ~= nil then
		thread( PlayVoiceLines, currentRun.CurrentRoom.ExitVoiceLines, true )
	else
		thread( PlayVoiceLines, GlobalVoiceLines.ExitedAsphodelRoomVoiceLines, true )
	end

	local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = GetIdsByType({ Name = "HeroExit" }), Distance = 600 })

	local boatMovePoint = GetClosest({ Id = boatId, DestinationIds = GetIdsByType({ Name = "BoatMovePoint" }), Distance = 500 })
	if heroExitPointId > 0 then
		local angleToExit = GetAngleBetween({ Id = exitDoorId, DestinationId = boatMovePoint })
		if angleToExit < 90 or angleToExit > 270 then
			currentRun.CurrentRoom.ExitDirection = "Right"
		else
			currentRun.CurrentRoom.ExitDirection = "Left"
		end

		PanCamera({ Id = heroExitPointId, Duration = 10.0 })
		SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })

		CreateGroup({ Name = "Standing_Front" })
		InsertGroupInFront({ Name = "Standing_Front", DestinationName = "Standing" })
		AddToGroup({ Id = currentRun.Hero.ObjectId, Name = "Standing_Front", DrawGroup = true })

		thread( MoveHeroToRoomPosition, { DestinationId = heroExitPointId, DisableCollision =  false, UseDefaultSpeed = true } )
	end
	SetAnimation({ DestinationId = boatId, Name = "AsphodelBoatRise" })

	wait(0.02)

	AdjustZLocation({ Id = boatId, Distance = 10, Duration = 0.5 })

	--AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = boatMovePoint })
	Move({ Id = boatId, DestinationId = boatMovePoint, Duration = 2.0, EaseIn = 0.4 })
	Shake({ Id = boatMovePoint, Distance = 4, Speed = 100, Duration = 3 })
	PlaySound({ Name = "/SFX/AsphodelIslandTransitionStart", Id = currentRun.Hero.ObjectId })
	AsphodelBoatSoundId = PlaySound({ Name = "/SFX/AsphodelIslandTransitionLoop" })

	RemoveFromGroup({ Id = currentRun.Hero.ObjectId, Name = "Standing_Front" })
	AddToGroup({ Id = currentRun.Hero.ObjectId, Name = "Standing", DrawGroup = true })
	local offset = CalcOffset( math.rad(GetAngleBetween({ Id = boatId, DestinationId = currentRun.Hero.ObjectId })), GetDistance({ Id = boatId, DestinationId = currentRun.Hero.ObjectId }) )
	Attach({ Id = currentRun.Hero.ObjectId, DestinationId = boatId, OffsetX = offset.X, OffsetY = offset.Y })
	SetThingProperty({ Property = "SortMode", Value = "FromParent", DestinationId = currentRun.Hero.ObjectId })

	LeaveRoomAudio( currentRun, exitDoor )

	wait(0.02)

	if door ~= nil and door.ExitDoorCloseAnimation ~= nil then
		SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorCloseAnimation })
	end

	wait(0.02)

	FullScreenFadeOutAnimation()
	ShowInterMapComponents()

	AllowShout = false

	RemoveInputBlock({ Name = "LeaveRoomPresentation" })
	ToggleControl({ Names = { "AdvancedTooltip", }, Enabled = true })
	SetPlayerVulnerable( "LeaveRoomPresentation" )
end