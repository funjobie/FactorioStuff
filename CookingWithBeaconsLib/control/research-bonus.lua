function enableFeatureResearchBonus()

    enableFeatureHiddenBeacons()

    if not global.research_bonus.feature_enabled then
        global.research_bonus.feature_enabled = true
        global.research_bonus.boni = {}
        global.research_bonus.currentLevel = {}
        global.research_bonus.mapGroupToEntityMap = {}
        global.research_bonus.effectiveResearchBoni = {}
    end
end

local function getEffectiveResearchBonus(entityGroupUniqueName)

    local entityGroupDetails = global.research_bonus.boni[entityGroupUniqueName]
    local result = zeroEffects()

    local productivityResearchBoni = entityGroupDetails.boniMultiplier.productivity
    local productivityResearchLevel = global.research_bonus.currentLevel[entityGroupUniqueName].productivity
    if productivityResearchBoni and productivityResearchLevel then 
        result.productivity.bonus = productivityResearchBoni.multiplier * productivityResearchLevel + productivityResearchBoni.levelZeroOffset 
    end
    
    local speedResearchBoni = entityGroupDetails.boniMultiplier.speed
    local speedResearchLevel = global.research_bonus.currentLevel[entityGroupUniqueName].speed
    if speedResearchBoni and speedResearchLevel then 
        result.speed.bonus = speedResearchBoni.multiplier * speedResearchLevel + speedResearchBoni.levelZeroOffset 
    end
    
    local consumptionResearchBoni = entityGroupDetails.boniMultiplier.consumption
    local consumptionResearchLevel = global.research_bonus.currentLevel[entityGroupUniqueName].consumption
    if consumptionResearchBoni and consumptionResearchLevel then 
        result.consumption.bonus = consumptionResearchBoni.multiplier * consumptionResearchLevel + consumptionResearchBoni.levelZeroOffset 
    end
    
    local pollutionResearchBoni = entityGroupDetails.boniMultiplier.pollution
    local pollutionResearchLevel = global.research_bonus.currentLevel[entityGroupUniqueName].pollution
    if pollutionResearchBoni and pollutionResearchLevel then 
        result.pollution.bonus = pollutionResearchBoni.multiplier * pollutionResearchLevel + pollutionResearchBoni.levelZeroOffset 
    end
    
    return result
end

function giveResearchBonusToEntities(args, args2)

    assert(global.research_bonus.feature_enabled, "Library usage error give_research_bonus_to_entities: feature was not enabled yet via enable_feature_research_bonus().")

    assert(args, "Library usage error give_research_bonus_to_entities: arguments are missing.")
    assert(type(args) == "table", "Library usage error give_research_bonus_to_entities: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error give_research_bonus_to_entities: too many arguments given. arguments have to be provided in a table as one argument.")

    local uniqueBonusName = args.uniqueBonusName
    args.uniqueBonusName = nil
    local entities = args.entities
    args.entities = nil
    local boniMultiplier = args.boniMultiplier
    args.boniMultiplier = nil
    for k,_ in pairs(args) do error("Library usage error give_research_bonus_to_entities: unsupported argument " .. k) end
    
    assert(uniqueBonusName, "Library usage error give_research_bonus_to_entities: uniqueBonusName was not provided")
    assert(type(uniqueBonusName) == "string", "Library usage error give_research_bonus_to_entities: uniqueBonusName was given but it is not a string but a " .. type(uniqueBonusName))
    assert(global.research_bonus.boni[uniqueBonusName] == nil, "Library usage error give_research_bonus_to_entities: uniqueBonusName + " .. uniqueBonusName .. " was already used, calling it twice is not allowed.")
    assert(entities, "Library usage error give_research_bonus_to_entities: entities list is not provided")
    assert(type(entities) == "table", "Library usage error give_research_bonus_to_entities: the entities list was given but not a table, it is " .. type(entities))
    local entitiesListHasAtLeastOneEntry = false
    for k1, v in pairs(entities) do
        entitiesListHasAtLeastOneEntry = true
        assert(type(v) == "string", "Library usage error give_research_bonus_to_entities: the entity list contained an entry which was not a string, but " .. type(v))
        assert(game.entity_prototypes[v], "Library usage error give_research_bonus_to_entities: the entity list contained an entry which is not an entity, name is: " .. v)
        assert(doesEntitySupportBeacons(game.entity_prototypes[v]), "Library usage error give_research_bonus_to_entities: the entity list contained an entry which cannot be affected by beacons. name is: " .. v)
        for k2, v2 in pairs(entities) do
            if k1 ~= k2 then
                assert(v ~= v2, "Library usage error give_research_bonus_to_entities: the entity " .. v .. " is present twice in the entity list.")
            end
        end
    end
    assert(entitiesListHasAtLeastOneEntry, "Library usage error give_research_bonus_to_entities: entities list is empty")

    assert(boniMultiplier, "Library usage error give_research_bonus_to_entities: boniMultiplier was not provided")
    assert(type(boniMultiplier) == "table", "Library usage error give_research_bonus_to_entities: boniMultiplier was given but it is not a table but a " .. type(boniMultiplier))
    local boniMultiplierHasAtLeastOneEntry = false
    for k,v in pairs(boniMultiplier) do
        boniMultiplierHasAtLeastOneEntry = true
        assert(k=="consumption" or k=="speed" or k=="productivity" or k=="pollution",
            "Library usage error give_research_bonus_to_entities: boniMultiplier has unknown key " .. k)
        assert(type(v) == "table", "Library usage error give_research_bonus_to_entities: the boniMultiplier contains an element which is not a table, it is " .. type(v))
        assert(v.multiplier, "Library usage error give_research_bonus_to_entities: boniMultiplier element doesn't have the value 'multiplier'")
        assert(type(v.multiplier) == "number", "Library usage error give_research_bonus_to_entities: the multiplier given to one boniMultiplier is not a number but " .. type(v.multiplier))
        assert(v.levelZeroOffset, "Library usage error give_research_bonus_to_entities: boniMultiplier element doesn't have the value 'levelZeroOffset'")
        assert(type(v.levelZeroOffset) == "number", "Library usage error give_research_bonus_to_entities: the levelZeroOffset given to one boniMultiplier is not a number but " .. type(v.levelZeroOffset))
    end
    assert(boniMultiplierHasAtLeastOneEntry, "Library usage error give_research_bonus_to_entities: boniMultiplier doesn't have any elements inside")
    

    global.research_bonus.boni[uniqueBonusName] = {entities=entities, boniMultiplier=boniMultiplier}
    global.research_bonus.currentLevel[uniqueBonusName] = {}
    for boni, _ in pairs(boniMultiplier) do
        global.research_bonus.currentLevel[uniqueBonusName][boni] = 0
    end
    global.research_bonus.mapGroupToEntityMap[uniqueBonusName] = {}
    global.research_bonus.effectiveResearchBoni[uniqueBonusName] = getEffectiveResearchBonus(uniqueBonusName)    
end

function addEntitiesToResearchBonusGroup(args, args2)

    assert(global.research_bonus.feature_enabled, "Library usage error add_entities_to_research_bonus_group: feature was not enabled yet via enable_feature_research_bonus().")

    assert(args, "Library usage error add_entities_to_research_bonus_group: arguments are missing.")
    assert(type(args) == "table", "Library usage error add_entities_to_research_bonus_group: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error add_entities_to_research_bonus_group: too many arguments given. arguments have to be provided in a table as one argument.")

    local uniqueBonusName = args.uniqueBonusName
    args.uniqueBonusName = nil
    local entities = args.entities
    args.entities = nil
    for k,_ in pairs(args) do error("Library usage error add_entities_to_research_bonus_group: unsupported argument " .. k) end
    
    assert(uniqueBonusName, "Library usage error add_entities_to_research_bonus_group: uniqueBonusName was not provided")
    assert(type(uniqueBonusName) == "string", "Library usage error add_entities_to_research_bonus_group: uniqueBonusName was given but it is not a string but a " .. type(uniqueBonusName))
    assert(global.research_bonus.boni[uniqueBonusName] ~= nil, "Library usage error add_entities_to_research_bonus_group: uniqueBonusName + " .. uniqueBonusName .. " was not yet used. This interface is intended to add additional entities.")
    assert(entities, "Library usage error add_entities_to_research_bonus_group: entities list is not provided")
    assert(type(entities) == "table", "Library usage error add_entities_to_research_bonus_group: the entities list was given but not a table, it is " .. type(entities))
    local entitiesListHasAtLeastOneEntry = false
    for _, v in pairs(entities) do
        entitiesListHasAtLeastOneEntry = true
        assert(type(v) == "string", "Library usage error add_entities_to_research_bonus_group: the entity list contained an entry which was not a string, but " .. type(v))
        assert(game.entity_prototypes[v], "Library usage error add_entities_to_research_bonus_group: the entity list contained an entry which is not an entity, name is: " .. v)
        assert(doesEntitySupportBeacons(game.entity_prototypes[v]), "Library usage error add_entities_to_research_bonus_group: the entity list contained an entry which cannot be affected by beacons. name is: " .. v)
    end
    assert(entitiesListHasAtLeastOneEntry, "Library usage error add_entities_to_research_bonus_group: entities list is empty")
    
    for _, e in pairs(entities) do
        for _, e2 in pairs(global.research_bonus.boni[uniqueBonusName].entities) do
            assert(e ~= e2, "Library usage error add_entities_to_research_bonus_group: entity " .. e .. " was already in the list of group " .. uniqueBonusName) 
        end
        table.insert(global.research_bonus.boni[uniqueBonusName].entities, e)
    end
end

function researchBonus_on_research_finished(event)

    if string.sub(event.research.name,1,#"cwb-research-bonus-") == "cwb-research-bonus-" then
        local str = string.sub(event.research.name,#"cwb-research-bonus-" + 1,-1)
        local uniqueBonusName = string.match(str, "^[^%^]+")
        str = string.sub(str,#uniqueBonusName + 2,-1)
        local effectType = string.match(str, "^[^%^]+")
        
        local actualLevel = (event.research.level - 1)
        if event.research.researched then 
            actualLevel = actualLevel + 1 
        end
        
        global.research_bonus.currentLevel[uniqueBonusName][effectType] = actualLevel
    
        local effectiveResearchBonus = getEffectiveResearchBonus(uniqueBonusName)
        global.research_bonus.effectiveResearchBoni[uniqueBonusName] = effectiveResearchBonus
        
        local entriesToErase = {}
        for unit_number, entity in pairs(global.research_bonus.mapGroupToEntityMap[uniqueBonusName]) do
            if entity.valid then
                global.hidden_beacons.entity_specific_boni[entity.unit_number]["research-bonus-"..uniqueBonusName] = effectiveResearchBonus        
                reapplyAllHiddenBeaconEffects(entity)
            else
                table.insert(entriesToErase, unit_number)
            end
        end
        for _, unit_number in pairs(entriesToErase) do
            global.research_bonus.mapGroupToEntityMap[uniqueBonusName][unit_number] = nil
        end
    end
end

function researchBonus_on_built(entity)
    for uniqueBonusName, entityGroupDetails in pairs(global.research_bonus.boni) do
        for _, groupElement in pairs(entityGroupDetails.entities) do
            if groupElement == entity.name then
                global.research_bonus.mapGroupToEntityMap[uniqueBonusName][entity.unit_number] = entity
                local effectiveResearchBonus = global.research_bonus.effectiveResearchBoni[uniqueBonusName]
                global.hidden_beacons.entity_specific_boni[entity.unit_number]["research-bonus-"..uniqueBonusName] = effectiveResearchBonus
            end
        end
    end
end

function researchBonus_on_unbuilt(entity)
    for uniqueBonusName, entityGroupDetails in pairs(global.research_bonus.boni) do
        for _, groupElement in pairs(entityGroupDetails.entities) do
            if groupElement == entity.name then
                global.research_bonus.mapGroupToEntityMap[uniqueBonusName][entity.unit_number] = nil
            end
        end
    end
end