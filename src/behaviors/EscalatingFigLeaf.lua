local internal = RunModsWorldInternal
local option_fns = internal.option_fns
local hook_fns = internal.hook_fns

table.insert(option_fns,
    {
        type = "checkbox",
        configKey = "EscalatingFigLeaf",
        label = "Incrementing Fig Leaf",
        default = false,
        tooltip =
        "Dionysus Skip Chance starts at default value and increases by 13% after every encounter, resetting on biome start."
    })

table.insert(hook_fns, function()
    modutil.mod.Path.Wrap("DionysusSkipTrait", function(baseFunc, args, traitData)
        if not store.read("EscalatingFigLeaf") or not lib.coordinator.isEnabled(store, public.definition.modpack) then
            return baseFunc(args, traitData)
        end
        baseFunc(args, traitData)
        for _, trait in ipairs(CurrentRun.Hero.Traits) do
            if trait.Name == "PersistentDionysusSkipKeepsake" then
                trait.InitialSkipEncounterChance = trait.SkipEncounterChance
                trait.SkipEncounterGrowthPerRoom = 0.13
                break
            end
        end
    end)

    modutil.mod.Path.Wrap("EndEncounterEffects", function(baseFunc, currentRun, currentRoom, currentEncounter)
        if not store.read("EscalatingFigLeaf") or not lib.coordinator.isEnabled(store, public.definition.modpack) then
            return baseFunc(currentRun, currentRoom, currentEncounter)
        end
        baseFunc(currentRun, currentRoom, currentEncounter)
        if currentEncounter == currentRoom.Encounter or currentEncounter == MapState.EncounterOverride then
            if HeroHasTrait("PersistentDionysusSkipKeepsake") then
                local traitData = GetHeroTrait("PersistentDionysusSkipKeepsake")
                if traitData.SkipEncounterChance and traitData.SkipEncounterGrowthPerRoom then
                    traitData.SkipEncounterChance = math.min(1,
                        traitData.SkipEncounterChance + traitData.SkipEncounterGrowthPerRoom)
                end
            end
        end
    end)

    modutil.mod.Path.Wrap("StartRoom", function(baseFunc, currentRun, currentRoom)
        if not store.read("EscalatingFigLeaf") or not lib.coordinator.isEnabled(store, public.definition.modpack) then
            return baseFunc(currentRun, currentRoom)
        end
        baseFunc(currentRun, currentRoom)
        if currentRoom.BiomeStartRoom then
            if HeroHasTrait("PersistentDionysusSkipKeepsake") then
                local traitData = GetHeroTrait("PersistentDionysusSkipKeepsake")
                if traitData.InitialSkipEncounterChance then
                    traitData.SkipEncounterChance = traitData.InitialSkipEncounterChance
                end
            end
        end
    end)
end)
