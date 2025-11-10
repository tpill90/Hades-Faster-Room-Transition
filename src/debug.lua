-- TODO clean this up + document
-- TODO put in Chaos Gate, Thessaly ship
-- TODO can I speed up the thessaly ship transition?
-- TODO speed up initial run transition

-- Cerberus boss fight room :
-- NextRoom, NextEncounter = "H_Boss01", "BossInfestedCerberus01"

-- Post Cerberus room with fountain.  Melinoe jumps down the hatch:
-- NextRoom, NextEncounter = "H_PostBoss01", "Empty"

-- Entrance to Tartarus, opens gate "Express route set":
-- NextRoom, NextEncounter = "I_Intro", "Empty"

-- Charon shop before Chronos
-- NextRoom, NextEncounter = "I_PreBoss01", "Empty"

-- Prometheus
-- NextRoom, NextEncounter = "P_Boss01", "BossPrometheus01"

-- The summit, door with Zeus on it
NextRoom, NextEncounter = "Q_Intro", "Empty"

-- Room before Typhon
-- NextRoom, NextEncounter = "Q_PreBoss01", "TyphonShop"

rom.inputs.on_key_pressed { "Ctrl C", Name = "Force Next Room", function()
    if next(MapState.OfferedExitDoors) == nil then
        rom.log.warning("Can't force next room, need to clear encounter first!")
    end

    print("Forcing encounter " .. NextRoom .. " " .. NextEncounter);
    ForceNextRoom = NextRoom

    -- Stomp any rooms already assigned to doors
    for doorId, door in pairs(MapState.OfferedExitDoors) do
        local room = door.Room

        if room ~= nil then
            ForceNextEncounter = NextEncounter

            local forcedRoomData = RoomData[ForceNextRoom]
            local forcedRoom = CreateRoom(forcedRoomData)
            AssignRoomToExitDoor(door, forcedRoom)
        end
    end
end
}

rom.inputs.on_key_pressed { "Ctrl F", Name = "Kill all", function()
    if not ActiveEnemies then
        return
    end

    for enemyId, enemy in pairs(ActiveEnemies) do
        print(enemyId)
        if ActiveEnemies[enemyId] ~= nil then
            thread(Kill, ActiveEnemies[enemyId], { BlockRespawns = true })
        end
    end

    print("KillAllEnemiesDebug: All enemies killed")
end
}
