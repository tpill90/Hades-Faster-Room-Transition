---@diagnostic disable: undefined-global
-- #region grabbing our dependencies

---@meta _

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'SGG_Modding-ENVY-auto'
mods['SGG_Modding-ENVY'].auto()
-- ^ this gives us `public` and `import`, among others
--	and makes all globals we define private to this plugin.
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

-- get definitions for the game's globals
---@module 'SGG_Modding-Hades2GameDef-Globals'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

-- Loads config file
---@module 'config'
config = chalk.auto 'config.lua'
public.config = config

local loader = reload.auto_single()

-- #endregion

-- What to do when mod is ready, but also again on every reload. Only do things that are safe to run over and over.
local function on_reload()
    revertOverrides()
    loadOverrideScripts()

    if config.debugEnabled then
        import "debug.lua"
    end

    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
end

-- TODO comment how this all works
function loadOverrideScripts()
    import "OverrideScripts/ExitBiomeGRoomPresentation.lua"
    import "OverrideScripts/FastExitPresentation.lua"
    import "OverrideScripts/HubCombatRoomEntrance.lua"
    import "OverrideScripts/LeaveRoomPresentation.lua"
    import "OverrideScripts/OlympusSkyExitPresentation.lua"
    import "OverrideScripts/Summit-BiomeQLeaveRoomPresentation.lua"
    import "OverrideScripts/Summit-FortressMainDoorOpenPresentation.lua"

    import "OverrideScripts/MourningFields.lua"
    import "OverrideScripts/Tartarus.lua"
    import "OverrideScripts/Thessaly.lua"
end

function revertOverrides()
    BiomeQLeaveRoomPresentation = ModUtil.Original("BiomeQLeaveRoomPresentation")
    ExitBiomeGRoomPresentation = ModUtil.Original("ExitBiomeGRoomPresentation")
    FastExitPresentation = ModUtil.Original("FastExitPresentation")
    FastExitPresentation = ModUtil.Original("FortressMainDoorOpenPresentation")
    HubCombatRoomEntrance = ModUtil.Original("HubCombatRoomEntrance")
    LeaveRoomPresentation = ModUtil.Original("LeaveRoomPresentation")

    OlympusSkyExitPresentation = ModUtil.Original("OlympusSkyExitPresentation")

    -- Mourning Fields
    LeaveRoomHBossPresentation = ModUtil.Original("LeaveRoomHBossPresentation")
    LeaveRoomHPostBossPresentation = ModUtil.Original("LeaveRoomHPostBossPresentation")

    -- Tartarus
    LeaveRoomIPreBoss01Presentation = ModUtil.Original("LeaveRoomIPreBoss01Presentation")
    TartarusChamberMoverPresentation = ModUtil.Original("TartarusChamberMoverPresentation")

    -- Thessaly
    ShipsLeaveRoomPresentation = ModUtil.Original("ShipsLeaveRoomPresentation")
    ShipsRoomEntrancePresentation = ModUtil.Original("ShipsRoomEntrancePresentation")
end

-- This runs only when modutil and the game's lua is ready
modutil.once_loaded.game(function()
    loader.load(function() end, on_reload)
end)

-- Some stuff that will make debugging easier.  Enables debug keybinds, invincibility, and max damage
modutil.once_loaded.save(function()
    -- Only enabling debugging cheats if the debug flag is enabled.
    if config.debugEnabled == false then
        return
    end
    rom.log.warning("Enabling invincibility + max damage")

    SessionState.SafeMode = true
    SessionState.BlockHeroDeath = true
    SessionState.BlockHeroDamage = true
    SessionState.UnlimitedMana = true

    SetConfigOption({ Name = "DamageMultiplier", Value = 100.0 })
    UpdateConfigOptionCache()
end)
