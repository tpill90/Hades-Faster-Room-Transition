function ShipsLeaveRoomPresentation( currentRun, exitDoor )
	AddInputBlock({ Name = "ShipsLeaveRoomPresentation" })
	ToggleCombatControl( { "AdvancedTooltip" } , false, "LeaveRoom" )
	HideCombatUI( "ShipsLeaveRoomPresentation" )

	local exitDoorId = exitDoor.ObjectId
	local door = MapState.OfferedExitDoors[exitDoorId]

	if door ~= nil then
		thread( DestroyDoorRewardPresenation, door )
		if door.ExitDoorOpenAnimation ~= nil then
			SetAnimation({ DestinationId = exitDoorId, Name = door.ExitDoorOpenAnimation })
		end
	end
	local heroExitIds = GetIdsByType({ Name = "HeroExit" })
	local heroExitPointId = GetClosest({ Id = exitDoorId, DestinationIds = heroExitIds, Distance = 800 })
	if heroExitPointId <= 0 and exitDoorId ~= nil then
		heroExitPointId = exitDoorId
	end

	if not currentRun.CurrentRoom.BlockExitPan then
		PanCamera({ Id = heroExitPointId, Duration = 10.0 })
	end
	AngleTowardTarget({ Id = currentRun.Hero.ObjectId, DestinationId = heroExitPointId })
	AdjustZoom({ Fraction = (currentRun.CurrentRoom.ZoomFraction or 0.75) * 1.1, LerpTime = 1.2 })

	thread( PlayVoiceLines, HeroVoiceLines.ShipsExitVoiceLines, false )
	PlaySound({ Name = "/SFX/ShipsDoorTeleport" })

	-- Mel cast anim
	SetAnimation({ Name = "Melinoe_Cast_Start", DestinationId = currentRun.Hero.ObjectId, SpeedMultiplier = 2 })
	-- start charging energy VFX
	CreateAnimation({ DestinationId = exitDoorId, Name = "ShipsDoorMelZwoop", Group = "FX_Standing_Add" })
	-- energy shot VFX and camera effects
	PlaySound({ Name = "/SFX/ShipsDoorUse" })
	--AdjustZoom({ Fraction = (currentRun.CurrentRoom.ZoomFraction or 0.75) * 0.9, LerpTime = 0.2 })
	-- CreateAnimation({ DestinationId = exitDoorId, Name = "ShipsDoorBurst" })
	SetAlpha({ Id = currentRun.Hero.ObjectId, Fraction = 0, Duration = 0.1 })

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
	RemoveInputBlock({ Name = "ShipsLeaveRoomPresentation" })
end