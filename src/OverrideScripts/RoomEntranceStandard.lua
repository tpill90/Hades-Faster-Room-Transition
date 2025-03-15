-- ---@diagnostic disable: undefined-global

-- -- TODO is this needed?
-- ModUtil.Path.Override("RoomEntranceStandard", function(currentRun, currentRoom)
--     -- print("RoomEntranceStandard")
--     local roomData = RoomData[currentRoom.Name] or currentRoom
--     local roomIntroSequenceDuration = roomData.IntroSequenceDuration or RoomData.BaseRoom.IntroSequenceDuration or 0.0

--     if currentRoom.HeroEndPoint ~= nil then
--         -- Disable immediately, could be sitting on top of impassibility
--         SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithObstacles", Value = false })
--         SetUnitProperty({ DestinationId = currentRun.Hero.ObjectId, Property = "CollideWithUnits", Value = false })
--     end
--     wait(0.03)

--     FadeIn({ Duration = 0.0 })
--     FullScreenFadeInAnimation(currentRoom.EnterWipeAnimationOverride or roomData.EnterWipeAnimation or
--         GetDirectionalWipeAnimation({ TowardsId = currentRoom.HeroEndPoint, Enter = true }))

--     local roomEntranceAnimation = GetEquippedWeaponValue("RoomEntranceAnimation")
--     if roomEntranceAnimation ~= nil then
--         SetAnimation({ Name = roomEntranceAnimation, DestinationId = CurrentRun.Hero.ObjectId })
--     end

--     if roomData.DoorEntranceAnimation ~= nil then
--         thread(DoorEntranceAnimation, roomData.DoorEntranceAnimation)
--     end

--     if currentRoom.HeroEndPoint ~= nil then
--         thread(MoveHeroToRoomPosition,
--             {
--                 DestinationId = currentRoom.HeroEndPoint,
--                 DisableCollision = true,
--                 UseDefaultSpeed = not roomData
--                     .EntrancePresentationUsePlayerSpeed,
--                 Invulnerable = true
--             })
--     end
--     local panDuration = roomData.IntroPanDuration or roomIntroSequenceDuration
--     if currentRoom.CameraEndPoint ~= nil and panDuration > 0 then
--         PanCamera({
--             Id = currentRoom.CameraEndPoint,
--             Duration = panDuration,
--             EaseIn = roomData.IntroPanEaseIn,
--             EaseOut =
--                 roomData.IntroPanEaseOut
--         })
--     end

--     if currentRoom.EnterSound ~= nil then
--         PlaySound({ Name = currentRoom.EnterSound, Id = currentRoom.HeroStartPoint })
--     end
--     wait(0.03)

--     thread(PlayVoiceLines, currentRoom.Encounter.EnterVoiceLines or roomData.EnterVoiceLines, true)
--     thread(PlayVoiceLines, GlobalVoiceLines[currentRoom.EnterGlobalVoiceLines], true)
--     wait(roomIntroSequenceDuration)
--     LockCamera({ Id = currentRun.Hero.ObjectId, Duration = 2.0 })
-- end)
