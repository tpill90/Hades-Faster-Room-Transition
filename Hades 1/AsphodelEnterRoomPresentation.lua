function AsphodelEnterRoomPresentation(currentRun, currentRoom, endLookAtId, skipCameraLockOnEnd)
	local roomIntroSequenceDuration = currentRoom.IntroSequenceDuration or RoomData.BaseRoom.IntroSequenceDuration or 0.8

	AddInputBlock({ Name = "EnterRoomPresentation" })
	SetPlayerInvulnerable( "EnterRoomPresentation" )
	FadeIn({ Duration = 0.0 })
	FullScreenFadeInAnimation()

	if currentRoom.HeroStartPoint ~= nil then
		Teleport({ Id = currentRun.Hero.ObjectId, DestinationId = currentRoom.HeroStartPoint })
	end

	local heroStartPointId = currentRoom.HeroStartPoint or GetClosest({ Id = currentRun.Hero.ObjectId, DestinationIds = GetIdsByType({ Name = "HeroStart" }) })
	local boatId = GetClosest({ Id = heroStartPointId, DestinationIds = GetIdsByType({ Name = "AsphodelBoat01" }) })
	local boatMovePoint = GetClosest({ Id = boatId, DestinationIds = GetIdsByType({ Name = "BoatMovePoint" }) })
	local boatMovePointExit = SpawnObstacle({ Name = "BlankObstacle", DestinationId = boatId, Group = "Scripting" })
	LockCamera({ Id = boatId, Duration = 1.0 })

	for k, unusedBoatId in pairs(GetIdsByType({ Name = "AsphodelBoat01" })) do
		if boatId ~= unusedBoatId then
			Destroy({ Id = unusedBoatId })
		end
	end

	local offset = CalcOffset( math.rad(GetAngleBetween({ Id = boatId, DestinationId = heroStartPointId })), GetDistance({ Id = boatId, DestinationId = heroStartPointId }) )
	Attach({ Id = currentRun.Hero.ObjectId, DestinationId = boatId, OffsetX = offset.X, OffsetY = offset.Y })
	AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = boatMovePoint })
	AdjustZLocation({ Id = boatId, Distance = 10, Duration = 0.0 })
	Move({ Id = boatId, DestinationId = boatMovePoint, Duration = 1.0, EaseOut = 1.0 })
	Shake({ Id = raftMovePoint, Distance = 2, Speed = 100, Duration = 0.3 })
	-- wait(0.9)

	AdjustZLocation({ Id = boatId, Distance = -10, Duration = 0.5 })
	SetAnimation({ DestinationId = boatId, Name = "AsphodelBoatSink" })

	-- wait(0.35)

	StopSound({ Id = AsphodelBoatSoundId, Duration = 0.2 })
	AsphodelBoatSoundId = nil
	PlaySound({ Name = "/Leftovers/World Sounds/CaravanWaterBuck2", Id = raftMovePoint })
	local rumbleParams = { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.3 }, }
	thread( DoRumble, rumbleParams )

	-- wait(0.15)
	AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = currentRoom.HeroEndPoint })
	-- wait(0.03)

	if currentRoom.CameraEndPoint ~= nil then
		PanCamera({ Id = currentRoom.CameraEndPoint, Duration = roomIntroSequenceDuration, EaseIn = 0.0, EaseOut = 0.0 })
	end
	if currentRoom.HeroEndPoint ~= nil then
		CreateGroup({ Name = "Standing_Front" })
		InsertGroupInFront({ Name = "Standing_Front", DestinationName = "Standing" })
		AddToGroup({ Id = currentRun.Hero.ObjectId, Name = "Standing_Front", DrawGroup = true })
		thread( MoveHeroToRoomPosition, { DestinationId = currentRoom.HeroEndPoint, DisableCollision =  true, UseDefaultSpeed = true, AngleTowardsIdOnEnd = endLookAtId } )
	end
	wait(0.03)

	RemoveFromGroup({ Id = currentRun.Hero.ObjectId, Name = "Standing_Front" })
	AddToGroup({ Id = currentRun.Hero.ObjectId, Name = "Standing", DrawGroup = true })
	Unattach({ Id = currentRun.Hero.ObjectId, DestinationId = boatId })
	thread( PlayVoiceLines, currentRoom.EnterVoiceLines, true )
	thread( PlayVoiceLines, GlobalVoiceLines[currentRoom.EnterGlobalVoiceLines], true )
	wait( roomIntroSequenceDuration - 0.03 )

	if not skipCameraLockOnEnd then
		LockCamera({ Id = currentRun.Hero.ObjectId, Duration = 0.5 })
	end

	RemoveInputBlock({ Name = "EnterRoomPresentation" })
	SetPlayerVulnerable( "EnterRoomPresentation" )
end