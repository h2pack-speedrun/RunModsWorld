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

table.insert(apply_fns, {
    key = "SurfaceStructure",
    fn = function()
        backup(RoomSetData.P.P_Shop01, "ForceAtBiomeDepthMin")
        backup(RoomSetData.P.P_Shop01, "ForceAtBiomeDepthMax")
        backup(RoomSetData.O.O_MiniBoss01, "ForceAtBiomeDepthMin")
        backup(RoomSetData.O.O_MiniBoss01, "ForceAtBiomeDepthMax")
        backup(RoomSetData.O.O_MiniBoss02, "ForceAtBiomeDepthMin")
        backup(RoomSetData.O.O_MiniBoss02, "ForceAtBiomeDepthMax")
        backup(RoomData["O_MiniBoss01"], "GameStateRequirements")
        backup(RoomData["O_MiniBoss02"], "GameStateRequirements")

        -- Olympus midshop
        RoomSetData.P.P_Shop01.ForceAtBiomeDepthMin = 5
        RoomSetData.P.P_Shop01.ForceAtBiomeDepthMax = 7

        -- Thessaly minibosses
        RoomSetData.O.O_MiniBoss01.ForceAtBiomeDepthMin = 2
        RoomSetData.O.O_MiniBoss01.ForceAtBiomeDepthMax = 4
        RoomSetData.O.O_MiniBoss02.ForceAtBiomeDepthMin = 2
        RoomSetData.O.O_MiniBoss02.ForceAtBiomeDepthMax = 4

        for _, roomName in ipairs({ "O_MiniBoss01", "O_MiniBoss02" }) do
            local room = RoomData[roomName]
            if room and room.GameStateRequirements then
                for _, req in ipairs(room.GameStateRequirements) do
                    if req.Path and req.Path[2] == "BiomeDepthCache" then
                        if req.Comparison == ">=" and req.Value == 3 then
                            req.Value = 2
                        elseif req.Comparison == "<=" and req.Value == 5 then
                            req.Value = 4
                        end
                    end
                end
            end
        end
    end
})

table.insert(hook_fns, function()
    modutil.mod.Path.Wrap("ChooseEncounter", function(baseFunc, currentRun, room, args)
        if not config.SurfaceStructure or not lib.isEnabled(config, public.definition.modpack) then
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
