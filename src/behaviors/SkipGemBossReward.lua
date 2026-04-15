local internal = RunModsWorldInternal
local option_fns = internal.option_fns
local hook_fns = internal.hook_fns

table.insert(option_fns,
    {
        type = "checkbox",
        configKey = "SkipGemBossReward",
        label = "Skip Gem Boss Reward",
        default = false,
        tooltip =
        "Bosses no longer drop gem rewards when using Grave Thirst."
    })

table.insert(hook_fns, function()
    modutil.mod.Path.Wrap("UnusedWeaponBonusDropGems", function(baseFunc, source, args)
        if not store.read("SkipGemBossReward") or not lib.coordinator.isEnabled(store, public.definition.modpack) then
            return baseFunc(source, args)
        end
        return
    end)
end)
