local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
lib = rom.mods['adamant-ModpackLib']
local dataDefaults = import("config.lua")
local config = chalk.auto('config.lua')

RunModsWorldInternal = RunModsWorldInternal or {}
local internal = RunModsWorldInternal

-- Behavior registration tables — populated by each behaviors/*.lua file via import().
-- Each behavior file may append to any of these independently:
--   patch_fns : sequence of { key=string, fn=function(plan) } — called on patchPlan, gated on store values
--   hook_fns  : sequence of functions                    — called once on load to register hooks
--   option_fns: sequence of option descriptors           — drives the Framework UI options list
internal.patch_fns = internal.patch_fns or {}
internal.hook_fns = internal.hook_fns or {}
internal.option_fns = internal.option_fns or {}

local PACK_ID = "speedrun"

local function BuildStorageAndUi(options)
    local storage = {}
    local ui = {}
    for _, option in ipairs(options) do
        if option.type == "checkbox" then
            table.insert(storage, {
                type = "bool",
                alias = option.configKey,
                configKey = option.configKey,
            })
            table.insert(ui, {
                type = "checkbox",
                binds = { value = option.configKey },
                label = option.label,
                tooltip = option.tooltip,
            })
        else
            error(("Unsupported option type '%s' in %s"):format(tostring(option.type), PACK_ID .. ".RunModsWorld"))
        end
    end
    return storage, ui
end

import 'behaviors/CharybdisBehavior.lua'
import 'behaviors/EscalatingFigLeaf.lua'
import 'behaviors/SkipGemBossReward.lua'
import 'behaviors/SurfaceStructure.lua'

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    modpack      = PACK_ID,
    id           = "RunModsWorld",
    name         = "Run Modifiers: World & Combat Tweaks",
    category     = "Run Modifiers",
    subgroup     = "World & Combat Tweaks",
    tooltip      = "Run modifier options for world structure and combat tweaks.",
    default      = dataDefaults.Enabled,
    affectsRunData = true,
}

public.definition.storage, public.definition.ui = BuildStorageAndUi(internal.option_fns)

public.store = lib.createStore(config, public.definition, dataDefaults)
store = public.store

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function buildPatchPlan(plan)
    for _, b in ipairs(internal.patch_fns) do
        if store.read(b.key) and b.fn then b.fn(plan) end
    end
end

local function registerHooks()
    for _, fn in ipairs(internal.hook_fns) do fn() end
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.patchPlan = buildPatchPlan

local loader = reload.auto_single()

local function init()
    import_as_fallback(rom.game)
    registerHooks()
    if lib.isEnabled(store, public.definition.modpack) then
        lib.applyDefinition(public.definition, store)
    end
    if public.definition.affectsRunData and not lib.isCoordinated(public.definition.modpack) then
        SetupRunData()
    end
end

modutil.once_loaded.game(function()
    loader.load(init, init)
end)

local uiCallback = lib.standaloneUI(public.definition, store)
---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(uiCallback)
