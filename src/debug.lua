-- Erebus - Standard room
-- NextRoom, NextEncounter = "F_Combat01", "GeneratedF"

-- Oceanus - Standard room
-- NextRoom, NextEncounter = "G_Combat01", "GeneratedG"

-- Mourning Fields - Cerberus boss fight room :
-- NextRoom, NextEncounter = "H_Boss01", "BossInfestedCerberus01"

-- Mourning Fields - Post Cerberus room with fountain.  Melinoe jumps down the hatch:
-- NextRoom, NextEncounter = "H_PostBoss01", "Empty"

-- Tartarus - Entrance opens gate "Express route set":
-- NextRoom, NextEncounter = "I_Intro", "Empty"

-- Tartarus - Charon shop before Chronos
-- NextRoom, NextEncounter = "I_PreBoss01", "Empty"

-- Ephyra - Polyphemus
NextRoom, NextEncounter = "N_Boss01", "BossPolyphemus01"

-- Olympus - Entrance
-- NextRoom, NextEncounter = "P_Intro", "Empty"

-- Olympus - Prometheus
-- NextRoom, NextEncounter = "P_Boss01", "BossPrometheus01"

-- Summit - Door with Zeus on it
-- NextRoom, NextEncounter = "Q_Intro", "Empty"

-- Summit - Room before Typhon
-- NextRoom, NextEncounter = "Q_PreBoss01", "TyphonShop"

-- Chaos gate
-- NextRoom, NextEncounter = "Chaos_01", "Empty_Chaos"

-- Use this to teleport to different areas in the game for testing.  Uncomment lines above to pick where you will go after you exist the current area.
-- This can only be run once the room has been cleared and the gates open up.
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

-- Kills all enemies on demand, to be able to move between rooms faster.
rom.inputs.on_key_pressed { "Ctrl F", Name = "Kill all", function()
    if not ActiveEnemies then
        return
    end

    for enemyId, enemy in pairs(ActiveEnemies) do
        if ActiveEnemies[enemyId] ~= nil then
            thread(Kill, ActiveEnemies[enemyId], { BlockRespawns = true })
        end
    end

    print("[Debug] All enemies killed")
end
}
