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

backup, revert = lib.createBackupSystem()

-- Behavior registration tables — populated by each behaviors/*.lua file via import().
-- Each behavior file may append to any of these independently:
--   apply_fns : sequence of { key=string, fn=function }  — called on apply, gated on config[key]
--   hook_fns  : sequence of functions                    — called once on load to register hooks
--   option_fns: sequence of option descriptors           — drives the Framework UI options list
apply_fns  = {}
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
    dataMutation = true,
    options      = option_fns,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    for _, b in ipairs(apply_fns) do
        if config[b.key] and b.fn then b.fn() end
    end
end

local function registerHooks()
    for _, fn in ipairs(hook_fns) do fn() end
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.apply = apply
public.definition.revert = revert

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config, public.definition.modpack) then apply() end
        if public.definition.dataMutation and not lib.isCoordinated(public.definition.modpack) then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, revert)
---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(uiCallback)
