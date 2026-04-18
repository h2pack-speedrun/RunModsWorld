-- luacheck: globals RunModsWorldInternal public
local internal = RunModsWorldInternal

internal.patch_fns = {}
internal.hook_fns = {}
internal.option_fns = {}

local PACK_ID = "speedrun"

local function BuildStorage(options)
    local storage = {}
    for _, option in ipairs(options) do
        if option.type == "checkbox" then
            table.insert(storage, {
                type = "bool",
                alias = option.configKey,
                configKey = option.configKey,
            })
        else
            error(("Unsupported option type '%s' in %s"):format(tostring(option.type), PACK_ID .. ".RunModsWorld"))
        end
    end
    return storage
end

import("behaviors/CharybdisBehavior.lua")
import("behaviors/EscalatingFigLeaf.lua")
import("behaviors/SkipGemBossReward.lua")
import("behaviors/SurfaceStructure.lua")

public.definition.storage = BuildStorage(internal.option_fns)

function internal.BuildPatchPlan(plan, activeStore)
    for _, b in ipairs(internal.patch_fns) do
        if activeStore.read(b.key) and b.fn then
            b.fn(plan)
        end
    end
end

function internal.RegisterHooks()
    for _, fn in ipairs(internal.hook_fns) do
        fn()
    end
end

return internal
