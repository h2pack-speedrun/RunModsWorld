table.insert(option_fns,
    {
        type = "checkbox",
        configKey = "CharybdisBehavior",
        label = "Adjust Charybdis Behavior",
        default = false,
        tooltip =
        "At phase transition, Tentacles despawn in 1s (not 9s). Charybdis fires 6 spits instead of 8."
    })
table.insert(apply_fns, {
    key = "CharybdisBehavior",
    fn = function()
        backup(UnitSetData.Charybdis.CharybdisTentacle.AIStages[3], "WaitDuration")
        backup(WeaponData.CharybdisSpit3.AIData, "FireTicks")
        backup(WeaponDataEnemies.CharybdisSpit3.AIData, "FireTicks")
        UnitSetData.Charybdis.CharybdisTentacle.AIStages[3].WaitDuration = 1.0
        WeaponData.CharybdisSpit3.AIData.FireTicks = 6
        WeaponDataEnemies.CharybdisSpit3.AIData.FireTicks = 6
    end
})
