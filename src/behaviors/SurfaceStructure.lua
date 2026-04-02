local internal = RunModsWorldInternal
local option_fns = internal.option_fns
local patch_fns = internal.patch_fns
local hook_fns = internal.hook_fns

table.insert(option_fns,
    {
        type = "checkbox",
        configKey = "SurfaceStructure",
        label = "Less Sucky Surface",
        default = false,
        tooltip =
        "1. Thessaly Miniboss forced between rooms 2-4. 2.\n Olympus midshop forced between rooms 5-7.\n 3. Removes Boatacles."
    })

local bannedEncounters = {
    HeraclesCombatO = true, HeraclesCombatO2 = true, -- Thessaly
}

table.insert(patch_fns, {
    key = "SurfaceStructure",
    fn = function(plan)
        plan:setMany(RoomSetData.P.P_Shop01, {
            ForceAtBiomeDepthMin = 5,
            ForceAtBiomeDepthMax = 7,
        })
        plan:setMany(RoomSetData.O.O_MiniBoss01, {
            ForceAtBiomeDepthMin = 2,
            ForceAtBiomeDepthMax = 4,
        })
        plan:setMany(RoomSetData.O.O_MiniBoss02, {
            ForceAtBiomeDepthMin = 2,
            ForceAtBiomeDepthMax = 4,
        })

        for _, roomName in ipairs({ "O_MiniBoss01", "O_MiniBoss02" }) do
            plan:transform(RoomData, roomName, function(room)
                if room == nil then return room end
                local copy = rom.game.DeepCopyTable(room)
                if copy.GameStateRequirements then
                    for _, req in ipairs(copy.GameStateRequirements) do
                        if req.Path and req.Path[2] == "BiomeDepthCache" then
                            if req.Comparison == ">=" and req.Value == 3 then
                                req.Value = 2
                            elseif req.Comparison == "<=" and req.Value == 5 then
                                req.Value = 4
                            end
                        end
                    end
                end
                return copy
            end)
        end
    end
})

table.insert(hook_fns, function()
    modutil.mod.Path.Wrap("ChooseEncounter", function(baseFunc, currentRun, room, args)
        if not store.read("SurfaceStructure") or not lib.isEnabled(store, public.definition.modpack) then
            return baseFunc(currentRun, room, args)
        end
        args = args or {}
        local source = args.LegalEncounters or room.LegalEncounters
        if source then
            local filtered = {}
            for _, enc in pairs(source) do
                if not bannedEncounters[enc] then
                    table.insert(filtered, enc)
                end
            end
            args.LegalEncounters = filtered
        end
        return baseFunc(currentRun, room, args)
    end)
end)
