---@diagnostic disable: undefined-global

-- Oceanus - Jumping down the holes
ModUtil.Path.Override("ExitBiomeGRoomPresentation", function(currentRun, exitDoor)
    print("ExitBiomeGRoomPresentation")
    AddInputBlock({ Name = "LeaveRoomPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, false, "LeaveRoom")
    HideCombatUI("ExitBiomeGRoomPresentation")
    LeaveRoomAudio(currentRun, exitDoor)

    if exitDoor ~= nil then
        if exitDoor.AdditionalIcons ~= nil and not IsEmpty(exitDoor.AdditionalIcons) then
            Destroy({ Ids = GetAllValues(exitDoor.AdditionalIcons) })
            exitDoor.AdditionalIcons = nil
        end
        DestroyDoorRewardPresenation(exitDoor)
        if exitDoor.ExitDoorOpenAnimation ~= nil then
            SetAnimation({ DestinationId = exitDoor.ObjectId, Name = exitDoor.ExitDoorOpenAnimation })
        end
    end

    thread(PlayVoiceLines, HeroVoiceLines.OceanusExitVoiceLines, true)

    Stop({ Id = CurrentRun.Hero.ObjectId })
    wait(0.01)

    PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENULoudLow" })
    local unequipAnimation = GetEquippedWeaponValue("UnequipAnimation") or "MelinoeIdleWeaponless"
    SetAnimation({ Name = unequipAnimation, DestinationId = CurrentRun.Hero.ObjectId })
    PanCamera({ Id = exitDoor.ObjectId, Duration = 1.1, OffsetY = -50, EaseOut = 0 })

    -- wait( 0.5 )

    SetAnimation({ Name = "Melinoe_Drop_Exit_Start", DestinationId = CurrentRun.Hero.ObjectId, SpeedMultiplier = 0.5 })
    SetThingProperty({ DestinationId = CurrentRun.Hero.ObjectId, Property = "Tallness", Value = 400 })

    -- wait( 0.35 )

    PlaySound({ Name = "/VO/MelinoeEmotes/EmoteEvading" })
    local args = {}
    args.SuccessDistance = 20
    args.DisableCollision = true
    local exitPath = {}
    table.insert(exitPath, exitDoor.ObjectId)
    thread(MoveHeroAlongPath, exitPath, args)

    -- wait( 0.20 )

    thread(SlightDescent)
    PanCamera({ Id = exitDoor.ObjectId, Duration = 1.2, OffsetY = 85, Retarget = true })
    thread(DoRumble, { { ScreenPreWait = 0.02, Fraction = 0.15, Duration = 0.25 }, })

    FullScreenFadeOutAnimation("RoomTransitionIn_Down")

    WaitForSpeechFinished()

    RemoveInputBlock({ Name = "LeaveRoomPresentation" })
    ToggleCombatControl({ "AdvancedTooltip" }, true, "LeaveRoom")
end)
