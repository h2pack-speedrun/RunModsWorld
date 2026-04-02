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

config = chalk.auto('config.lua')
public.config = config

-- Behavior registration tables — populated by each behaviors/*.lua file via import().
-- Each behavior file may append to any of these independently:
--   patch_fns : sequence of { key=string, fn=function(plan) } — called on patchPlan, gated on config[key]
--   hook_fns  : sequence of functions                    — called once on load to register hooks
--   option_fns: sequence of option descriptors           — drives the Framework UI options list
patch_fns  = {}
hook_fns   = {}
option_fns = {}

local PACK_ID = "speedrun"

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
    group        = "World & Combat Tweaks",
    tooltip      = "Run modifier options for world structure and combat tweaks.",
    default      = true,
    affectsRunData = true,
    options      = option_fns,
}

public.store = lib.createStore(config, public.definition)

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function buildPatchPlan(plan)
    for _, b in ipairs(patch_fns) do
        if config[b.key] and b.fn then b.fn(plan) end
    end
end

local function registerHooks()
    for _, fn in ipairs(hook_fns) do fn() end
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.patchPlan = buildPatchPlan

local loader = reload.auto_single()

local function init()
    import_as_fallback(rom.game)
    registerHooks()
    if lib.isEnabled(public.store, public.definition.modpack) then
        lib.applyDefinition(public.definition, public.store)
    end
    if public.definition.affectsRunData and not lib.isCoordinated(public.definition.modpack) then
        SetupRunData()
    end
end

modutil.once_loaded.game(function()
    loader.load(init, init)
end)

local uiCallback = lib.standaloneUI(public.definition, public.store)
---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(uiCallback)
