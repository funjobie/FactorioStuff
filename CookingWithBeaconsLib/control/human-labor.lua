function enableFeatureHumanPowered()
    if not global.human_labor.feature_enabled then
        global.human_labor.feature_enabled = true
        global.human_labor.tool_specification = {}
    end
end

function makeHumanPoweredEntityRequireTools(args, args2)

    assert(global.human_labor.feature_enabled, "Library usage error make_human_powered_entity_require_tools: feature was not enabled yet via enable_feature_human_powered().")

    assert(args, "Library usage error make_human_powered_entity_require_tools: arguments are missing.")
    assert(type(args) == "table", "Library usage error make_human_powered_entity_require_tools: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error make_human_powered_entity_require_tools: too many arguments given. arguments have to be provided in a table as one argument.")

    local name = args.name
    args.name = nil
    local listOfTools = args.listOfTools
    args.listOfTools = nil
    local durabilityLosPerLaborUnit = args.durabilityLosPerLaborUnit
    args.durabilityLosPerLaborUnit = nil
    for k,_ in pairs(args) do error("Library usage error make_human_powered_entity_require_tools: unsupported argument " .. k) end

    assert(name, "Library usage error make_human_powered_entity_require_tools: name was not provided")
    assert(type(name) == "string", "Library usage error make_human_powered_entity_require_tools: name was given but it is not a string but a " .. type(name))
    assert(global.human_labor.tool_specification[name] == nil, "Library usage error make_human_powered_entity_require_tools: entity " .. name .. " already has a definition what tools are required, setting it again is not possible.")
    assert(game.entity_prototypes[name], "Library usage error make_human_powered_entity_require_tools: name was given but such an entity doesn't exist. name is: " .. name)
    
    assert(listOfTools, "Library usage error make_human_powered_entity_require_tools: listOfTools was not provided. If you don't want this entity to use tools for manual work, you can just not call this function.")
    assert(type(listOfTools) == "table", "Library usage error make_human_powered_entity_require_tools: listOfTools was given but it is not a table but a " .. type(listOfTools))
    local hasAtLeastOneToolGroup = false
    for _,toolGroup in pairs(listOfTools) do 
        hasAtLeastOneToolGroup = true
        assert(type(toolGroup) == "table", "Library usage error make_human_powered_entity_require_tools: listOfTools contained a non-table entry, found " .. type(toolGroup))
        local groupHasAtLeastOneTool = false
        for _, toolName in pairs(toolGroup) do
            groupHasAtLeastOneTool = true
            assert(type(toolName) == "string", "Library usage error make_human_powered_entity_require_tools: listOfTools has a tool group which contains a non-string entry, found " .. type(toolName))
            assert(game.item_prototypes[toolName], "Library usage error make_human_powered_entity_require_tools: listOfTools has a tool group which contains the entry " .. toolName .. " which is not an item")
            assert(game.item_prototypes[toolName].durability, "Library usage error make_human_powered_entity_require_tools: the specified tool is an item, but doesn't have durability. toolname: " .. toolName)
            assert(game.item_prototypes[toolName].durability > 0, "Library usage error make_human_powered_entity_require_tools: the specified tool is an item, but has 0 durability. toolname: " .. toolName)
        end
        assert(groupHasAtLeastOneTool, "Library usage error make_human_powered_entity_require_tools: listOfTools was provided, there was a tool group which was empty. it must contain at least one tool. If you don't want this entity to use tools for manual work, you can just not call this function.")
    end
    assert(hasAtLeastOneToolGroup, "Library usage error make_human_powered_entity_require_tools: listOfTools was provided, but empty. it must contain at least one tool group. If you don't want this entity to use tools for manual work, you can just not call this function.")
    
    assert(durabilityLosPerLaborUnit, "Library usage error make_human_powered_entity_require_tools: durabilityLosPerLaborUnit was not provided.")
    assert(type(durabilityLosPerLaborUnit) == "number", "Library usage error make_human_powered_entity_require_tools: durabilityLosPerLaborUnit was given but it is not a number but a " .. type(durabilityLosPerLaborUnit))

    global.human_labor.tool_specification[name] = {listOfTools = listOfTools, durabilityLosPerLaborUnit = durabilityLosPerLaborUnit}
end

local function calculateNewLaborAmount(entityName, fluid, player)

    local missingLabor
    if not fluid or not fluid.amount then 
        missingLabor = 20
    else
        missingLabor = 20 - fluid.amount
        missingLabor = math.min(math.max(missingLabor, 0),20)
    end
    if missingLabor == 0 then 
        return 20 
    end
    local durabilityLosPerLaborUnit = global.human_labor.tool_specification[entityName].durabilityLosPerLaborUnit
    
    local inv = player.get_main_inventory()
    if not inv then return 0 end
    for _, toolGroup in pairs(global.human_labor.tool_specification[entityName].listOfTools) do
        --determine how much durability can be drained at most.
        local minAmountForGroup = 999999999999
        for _, tool in pairs(toolGroup) do
            local toolMaxDurability = game.item_prototypes[tool].durability
            local toolInfDurability = game.item_prototypes[tool].infinite
            local stack = inv.find_item_stack(tool)
            local amountInDurability = 0
            if stack and stack.valid_for_read then
                if toolInfDurability then 
                    amountInDurability = 999999999999 
                else
                    amountInDurability = (stack.count - 1) * toolMaxDurability + stack.durability
                end
            end
            minAmountForGroup = math.min(minAmountForGroup, amountInDurability)
        end
        --can drain some durability from this group, so do this
        if minAmountForGroup > 0 then
            local fluidAmountToFill = math.min(missingLabor, minAmountForGroup / durabilityLosPerLaborUnit)
            missingLabor = missingLabor - fluidAmountToFill
            local durabilityToDrain = fluidAmountToFill * durabilityLosPerLaborUnit
            for _, tool in pairs(toolGroup) do
                local toolMaxDurability = game.item_prototypes[tool].durability
                local toolInfDurability = game.item_prototypes[tool].infinite
                local stack = inv.find_item_stack(tool) --must be successfull since it delivered a result above already
                if not toolInfDurability then --if infinite durability, no need to drain anything here
                    stack.drain_durability(durabilityToDrain)
                end
            end
        end
    end
    return 20 - missingLabor
end

local function humanLaborChargeNearbyEntities()

    if not global.human_labor.feature_enabled then return end
    
    for _, player in pairs(game.connected_players) do
        if player.character and player.crafting_queue_size == 0 then
            local character = player.character
            local checkOffset = {x=0,y=0}
            if character.direction == defines.direction.north then checkOffset.y = -1 end
            if character.direction == defines.direction.east then checkOffset.x = 1 end
            if character.direction == defines.direction.south then checkOffset.y = 1 end
            if character.direction == defines.direction.west then checkOffset.x = -1 end
            if checkOffset.x ~= 0 or checkOffset.y ~= 0 then
                local surface = character.surface
                local entities = surface.find_entities_filtered{
                    type = {"assembling-machine", "furnace", "mining-drill", "lab"},
                    area = {{character.position.x + checkOffset.x - 0.1, character.position.y + checkOffset.y - 0.1},{character.position.x + checkOffset.x + 0.1, character.position.y + checkOffset.y + 0.1}}, 
                    force = player.force}
                for _, entity in pairs(entities) do
                    local fluidBoxes = entity.fluidbox
                    if fluidBoxes then
                        for fluidBoxIndex = 1,#fluidBoxes do
                            local filter = fluidBoxes.get_filter(fluidBoxIndex)
                            if filter and filter.name == "human-labor" then
                                if global.human_labor.tool_specification[entity.name] then
                                    local newAmount = calculateNewLaborAmount(entity.name, fluidBoxes[fluidBoxIndex], player)
                                    if newAmount > 0 then
                                        fluidBoxes[fluidBoxIndex] = {name="human-labor", amount=newAmount}
                                    else
                                        fluidBoxes[fluidBoxIndex] = nil
                                    end
                                else
                                    fluidBoxes[fluidBoxIndex] = {name="human-labor", amount=20}
                                end
                                
                            end
                        end
                    end
                end
            end
        end
    end
end

function humanLabor_on_nth_tick_20(event)
    humanLaborChargeNearbyEntities()
end
