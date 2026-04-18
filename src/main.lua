local mods = rom.mods
mods["SGG_Modding-ENVY"].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods["SGG_Modding-ModUtil"]
local chalk = mods["SGG_Modding-Chalk"]
local reload = mods["SGG_Modding-ReLoad"]
lib = mods["adamant-ModpackLib"]

local dataDefaults = import("config.lua")
local config = chalk.auto("config.lua")

local PACK_ID = "speedrun"

RunModsWorldInternal = RunModsWorldInternal or {}
local internal = RunModsWorldInternal

public.definition = {
    modpack = PACK_ID,
    id = "RunModsWorld",
    name = "Run Modifiers: World & Combat Tweaks",
    tooltip = "Run modifier options for world layout and combat behavior.",
    default = dataDefaults.Enabled,
    affectsRunData = true,
}

public.definition.patchPlan = function(plan, activeStore)
    if internal.BuildPatchPlan then
        internal.BuildPatchPlan(plan, activeStore)
    end
end

public.store = nil
store = nil
internal.standaloneUi = nil

local function registerHooks()
    if internal.RegisterHooks then
        internal.RegisterHooks()
    end

    public.DrawTab = internal.DrawTab
end

local function init()
    import_as_fallback(rom.game)

    import("data.lua")
    import("ui.lua")

    public.store = lib.store.create(config, public.definition, dataDefaults)
    store = public.store

    registerHooks()

    if lib.coordinator.isEnabled(store, public.definition.modpack) then
        lib.mutation.apply(public.definition, store)
    end

    if public.definition.affectsRunData and not lib.coordinator.isCoordinated(public.definition.modpack) then
        SetupRunData()
    end

    internal.standaloneUi = lib.host.standaloneUI(
        public.definition,
        store,
        store.uiState,
        {
            getDrawTab = function()
                return public.DrawTab
            end,
        }
    )
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(init, init)
end)

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_imgui(function()
    if internal.standaloneUi and internal.standaloneUi.renderWindow then
        internal.standaloneUi.renderWindow()
    end
end)

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(function()
    if internal.standaloneUi and internal.standaloneUi.addMenuBar then
        internal.standaloneUi.addMenuBar()
    end
end)
