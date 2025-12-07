---@diagnostic disable: undefined-global

-- These functions are ones that generally slow down the transitions.
-- We will basically make them do nothing, but rather than overriding them globally we will
-- instead only apply these overrides inside of specific functions.
function GeneralOverrides()
    ModUtil.Path.Wrap("wait", function(...)
        return
    end)

    ModUtil.Path.Wrap("FullScreenFadeOutAnimation", function(...)
        return
    end)

    ModUtil.Path.Wrap("thread", function(...)
        return
    end)

    ModUtil.Path.Wrap("SetAnimation", function(...)
        return
    end)

    ModUtil.Path.Wrap("WaitForSpeechFinished", function(...)
        return
    end)

    ModUtil.Path.Wrap("PanCamera", function(...)
        return
    end)
end

-- Regular room exit
ModUtil.Path.Context.Wrap("LeaveRoomPresentation", GeneralOverrides)

-- Oceanus - Jumping down the holes
ModUtil.Path.Context.Wrap("ExitBiomeGRoomPresentation", GeneralOverrides)

-- Mourning Fields - This is the hole that Melinoe jumps into after defeating Cerberus
ModUtil.Path.Context.Wrap("LeaveRoomHBossPresentation", function()
    GeneralOverrides()

    -- This are additionally needed
    ModUtil.Path.Wrap("waitUntil", function(...)
        return
    end)
end)

-- Mourning Fields - This is for the chamber after Cerberus that contains the pool.  This speeds up the animation where Melinoe opens up the trap door and jumps in.
ModUtil.Path.Context.Wrap("LeaveRoomHPostBossPresentation", GeneralOverrides)

-- Tartarus - Entrance when you open the gate that says "Express route set"
ModUtil.Path.Context.Wrap("TartarusChamberMoverPresentation", GeneralOverrides)

-- Tartarus - When Melinoe dives into the pool to get to Chronos' room.
ModUtil.Path.Context.Wrap("LeaveRoomIPreBoss01Presentation", GeneralOverrides)

-- Ephyra - Leaving rooms
ModUtil.Path.Context.Wrap("FastExitPresentation", GeneralOverrides)

-- Ephyra - Animations for when you enter the central hub
ModUtil.Path.Context.Wrap("HubCombatRoomEntrance", GeneralOverrides)

-- Thessaly - This is when you leave a room while on the ships in Thessaly
ModUtil.Path.Context.Wrap("ShipsLeaveRoomPresentation", GeneralOverrides)

-- Olympus - This is for the exits that launch you into the sky
ModUtil.Path.Context.Wrap("OlympusSkyExitPresentation", function()
    -- Disabling functions like FullScreenFadeOutAnimation, SetAnimation, Thread make  Melinoe unable to move
    ModUtil.Path.Wrap("wait", function(...)
        return
    end)

    ModUtil.Path.Wrap("waitUnmodified", function(...)
        return
    end)

    ModUtil.Path.Wrap("WaitForSpeechFinished", function(...)
        return
    end)

    ModUtil.Path.Wrap("PanCamera", function(...)
        return
    end)
end)

-- Summit - Leaving a regular room on the summit, includes typhon's entrance.
ModUtil.Path.Context.Wrap("BiomeQLeaveRoomPresentation", GeneralOverrides)

-- Summit - Opening the main large door at the beginning of the summit, that has Zeus on it
ModUtil.Path.Context.Wrap("FortressMainDoorOpenPresentation", function()
    -- Disabling functions like FullScreenFadeOutAnimation, SetAnimation, Thread make  Melinoe unable to move
    ModUtil.Path.Wrap("wait", function(...)
        return
    end)

    ModUtil.Path.Wrap("WaitForSpeechFinished", function(...)
        return
    end)

    ModUtil.Path.Wrap("PanCamera", function(...)
        return
    end)
end)

-- Chaos gates
ModUtil.Path.Context.Wrap("LeaveRoomSecretExitDoorPresentation", GeneralOverrides)
