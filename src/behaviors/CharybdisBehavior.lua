local internal = RunModsWorldInternal
local option_fns = internal.option_fns
local patch_fns = internal.patch_fns

table.insert(option_fns,
    {
        type = "checkbox",
        configKey = "CharybdisBehavior",
        label = "Adjust Charybdis Behavior",
        default = false,
        tooltip =
        "At phase transition, Tentacles despawn in 1s (not 9s). Charybdis fires 6 spits instead of 8."
    })
table.insert(patch_fns, {
    key = "CharybdisBehavior",
    fn = function(plan)
        plan:set(UnitSetData.Charybdis.CharybdisTentacle.AIStages[3], "WaitDuration", 1.0)
        plan:set(WeaponData.CharybdisSpit3.AIData, "FireTicks", 6)
        plan:set(WeaponDataEnemies.CharybdisSpit3.AIData, "FireTicks", 6)
    end
})
