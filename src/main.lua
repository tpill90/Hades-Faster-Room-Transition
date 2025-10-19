---@meta _
-- #region grabbing our dependencies,

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

---@module 'config'
config = chalk.auto 'config.lua'
-- ^ this updates our `.cfg` file in the config folder!
public.config = config -- so other mods can access our config

-- #endregion

modEnabled = config.enabled;

modEnabled = true;

-- what to do when we are ready, but not re-do on reload.
local function on_ready()
    revertOverrides()

    if modEnabled == false then
        return
    end
    loadOverrideScripts()
end

-- what to do when we are ready, but also again on every reload.
-- only do things that are safe to run over and over.
local function on_reload()
    revertOverrides()

    if modEnabled == false then
        return
    end
    loadOverrideScripts()

    mod = modutil.mod.Mod.Register(_PLUGIN.guid)
end
-- TODO comment how this all works
function loadOverrideScripts()
    import "OverrideScripts/ExitBiomeGRoomPresentation.lua"
    import "OverrideScripts/FastExitPresentation.lua"
    import "OverrideScripts/HubCombatRoomEntrance.lua"
    import "OverrideScripts/LeaveRoomPresentation.lua"
    import "OverrideScripts/OlympusSkyExitPresentation.lua"
    import "OverrideScripts/RoomEntranceStandard.lua"
    import "OverrideScripts/ShipsLeaveRoomPresentation.lua"
    import "OverrideScripts/ShipsRoomEntrancePresentation.lua"
end

function revertOverrides()
    ExitBiomeGRoomPresentation = ModUtil.Original("ExitBiomeGRoomPresentation")
    FastExitPresentation = ModUtil.Original("FastExitPresentation")
    HubCombatRoomEntrance = ModUtil.Original("HubCombatRoomEntrance")
    LeaveRoomPresentation = ModUtil.Original("LeaveRoomPresentation")
    OlympusSkyExitPresentation = ModUtil.Original("OlympusSkyExitPresentation")
    RoomEntranceStandard = ModUtil.Original("RoomEntranceStandard")
    ShipsLeaveRoomPresentation = ModUtil.Original("ShipsLeaveRoomPresentation")
    ShipsRoomEntrancePresentation = ModUtil.Original("ShipsRoomEntrancePresentation")
end

-- this allows us to limit certain functions to not be reloaded.
local loader = reload.auto_single()

-- this runs only when modutil and the game's lua is ready
modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)
