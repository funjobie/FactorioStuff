function enableFeatureCustomBeaconShapes()

    enableFeatureHiddenBeacons()
    
    if not global.custom_beacon_shapes.feature_enabled then

        --data structures modified during initialization
        global.custom_beacon_shapes.feature_enabled = true
        global.custom_beacon_shapes.shapes = {}
        global.custom_beacon_shapes.boundingBox = {}
        global.custom_beacon_shapes.biggestBoundingBox = {
            left_top={
                x=0,
                y=0,
                }, 
            right_bottom={
                x=0,
                y=0,
            }}
        global.custom_beacon_shapes.entityPositionInShape = {}
        global.custom_beacon_shapes.transmission = {}
        global.custom_beacon_shapes.timeDependentTransmission = {}
        global.custom_beacon_shapes.entityFilter = {}
        
        --data structures dynamically updated
        global.custom_beacon_shapes.affected_entities_to_recheck = {}
        global.custom_beacon_shapes.slow_update_queue = {}
        global.custom_beacon_shapes.slow_update_queue_2 = {}
        global.custom_beacon_shapes.fast_update_queue = {}
        global.custom_beacon_shapes.fast_update_queue_2 = {}
        global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities = {}
        global.custom_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons = {}
        global.custom_beacon_shapes.range_visualization = {}
        global.custom_beacon_shapes.range_visualization_cursorItem = {}
        global.custom_beacon_shapes.active_timeDependentTransmission = {}
        global.custom_beacon_shapes.map_beacon_name_to_beacon_entities = {}
    end
end

function giveCustomBeaconShapeToEntity(args, args2)

    assert(global.custom_beacon_shapes.feature_enabled, "Library usage error give_custom_beacon_shape_to_entity: feature was not enabled yet via enable_feature_custom_beacon_shapes().")

    assert(args, "Library usage error give_custom_beacon_shape_to_entity: arguments are missing.")
    assert(type(args) == "table", "Library usage error give_custom_beacon_shape_to_entity: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error give_custom_beacon_shape_to_entity: too many arguments given. arguments have to be provided in a table as one argument.")

    local name = args.name
    args.name = nil
    local shape = args.shape
    args.shape = nil
    local entityFilter = args.entityFilter
    args.entityFilter = nil
    local transmission = args.transmission
    args.transmission = nil
    local timeDependentTransmission = args.timeDependentTransmission
    args.timeDependentTransmission = nil
    for k,_ in pairs(args) do error("Library usage error give_custom_beacon_shape_to_entity: unsupported argument " .. k) end

    assert(name, "Library usage error give_custom_beacon_shape_to_entity: name was not provided")
    assert(type(name) == "string", "Library usage error give_custom_beacon_shape_to_entity: name was given but it is not a string but a " .. type(name))
    assert(global.custom_beacon_shapes.shapes[name] == nil, "Library usage error give_custom_beacon_shape_to_entity: entity " .. name .. " already has a custom shape, setting it again is not possible.")
    assert(game.entity_prototypes[name], "Library usage error give_custom_beacon_shape_to_entity: name was given but such an entity doesn't exist. name is: " .. name)
    assert(game.entity_prototypes[name].type == "beacon", "Library usage error give_custom_beacon_shape_to_entity: name was given as " .. name .. " but it is not a beacon but a " .. game.entity_prototypes[name].type)
    assert(game.entity_prototypes[name].supply_area_distance == 0, "Library usage error give_custom_beacon_shape_to_entity: beacon with name " .. name .. " still has a normal supply_area_distance value; did you forget to call cookingwithbeaconslib.public.setup_custom_beacon_shapes during the data stage?")
    assert(shape, "Library usage error give_custom_beacon_shape_to_entity: shape was not provided for " .. name)
    assert(type(shape) == "table", "Library usage error give_custom_beacon_shape_to_entity: shape was given but it is not a table but a " .. type(shape) .. " for " .. name)
    for k, v in pairs(shape) do assert(type(v) == "string", "Library usage error give_custom_beacon_shape_to_entity: shape did not consist of a table of strings for " .. name) end
    --entityFilter, transmission, timeDependentTransmission are optional

    global.custom_beacon_shapes.entityFilter[name] = entityFilter
    if not transmission then
        global.custom_beacon_shapes.transmission[name] ={
            {
                speed=function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return speed * distribution_effectivity end,
                consumption=function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return consumption * distribution_effectivity end,
                productivity=function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return productivity * distribution_effectivity end,
                pollution=function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return pollution * distribution_effectivity end,
            }
        }
    else
        assert(type(transmission) == "table", "Library usage error give_custom_beacon_shape_to_entity: transmission was given but it is not a table but a " .. type(transmission))
        global.custom_beacon_shapes.transmission[name] ={}
        for transmissionGroupIndex, transmissionGroup in pairs(transmission) do
            table.insert(global.custom_beacon_shapes.transmission[name], {})
            for _, effectType in pairs({"speed", "consumption", "productivity", "pollution"}) do
                assert(transmissionGroup[effectType], "Library usage error: in the transmission group " .. transmissionGroupIndex .. "the element for effectType " .. effectType .. "is missing")
                assert(type(transmissionGroup[effectType]) == "string", "Library usage error: in the transmission group " .. transmissionGroupIndex .. "the element for effectType " .. effectType .. "is expected to be a string, but it is " .. type(transmissionGroup[effectType]))
                local registerFunction , errmsg = loadstring(
                    "global.custom_beacon_shapes.transmission[\"" ..  name .. "\"]["..transmissionGroupIndex.."]."..effectType.." = " .. transmissionGroup[effectType])
                if not registerFunction then
                    error("Library usage error give_custom_beacon_shape_to_entity: transmission " .. transmissionGroupIndex .. " effect " .. effectType .. " has error: " .. tostring(errmsg))
                end
                registerFunction()
            end
        end
    end
        
    if not timeDependentTransmission then
        global.custom_beacon_shapes.timeDependentTransmission[name] = function(tick) return 1 end
    else
        assert(type(timeDependentTransmission) == "string", "Library usage error give_custom_beacon_shape_to_entity: timeDependentTransmission is expected to be a string, but it is " .. type(timeDependentTransmission))
        local registerFunction , errmsg = loadstring("global.custom_beacon_shapes.timeDependentTransmission[\"" ..  name .. "\"] = " .. timeDependentTransmission)
        if not registerFunction then
            error("Library usage error give_custom_beacon_shape_to_entity: timeDependentTransmission for " .. name .. " : error: " .. tostring(errmsg))
        end
        registerFunction()
    end
    global.custom_beacon_shapes.active_timeDependentTransmission[name] = 1
    global.custom_beacon_shapes.map_beacon_name_to_beacon_entities[name] = {}

    --[[
shape can be for example data such as: 
shape = {
        "OOOOOXOOOOO",
        "OOOOXXXOOOO",
        "OOOXXXXXOOO",
        "OOXXXXXXXOO",
        "OXXXXXXXXXO",
        "XXXXXEXXXXX",
        "OXXXXXXXXXO",
        "OOXXXXXXXOO",
        "OOOXXXXXOOO",
        "OOOOXXXOOOO",
        "OOOOOXOOOOO",
    }
--]]
    local left_top = {x=0,y=0}
    local right_bottom = {x=0,y=0}
    local length_x = 0
    local length_y = #shape
    local centerFound = false
    local center_x = 0
    local center_y = 0
    
    for yIndex, str in pairs(shape) do
        length_x = math.max(length_x,#str)
        xIndex = 0
        for c in string.gmatch(str,".") do
            assert(c == "E" or c == "X" or c == "O",
                "Library usage error give_custom_beacon_shape_to_entity: failed because shape contained unrecognized letter. only E,X,O are supported. found letter: " .. c)
            xIndex = xIndex + 1
            if c == "E" then
                if centerFound then  --center exist twice: reject this beacon shape.
                    error("Library usage error give_custom_beacon_shape_to_entity: failed because shape contained more than 1 E to indicate entity position.")
                    return 
                end
                centerFound = true
                center_x = xIndex
                center_y = yIndex
            end
        end
    end
    assert(centerFound, "Library usage error give_custom_beacon_shape_to_entity: failed because shape did not contain an E to indicate entity position.")

    left_top.x = -center_x + 1
    left_top.y = -center_y + 1
    right_bottom.x = left_top.x+length_x - 1
    right_bottom.y = left_top.y+length_y - 1
    
    global.custom_beacon_shapes.shapes[name] = shape
    global.custom_beacon_shapes.boundingBox[name] = {left_top=left_top, right_bottom=right_bottom}
    global.custom_beacon_shapes.entityPositionInShape[name] = {x=center_x, y=center_y}
    
    global.custom_beacon_shapes.biggestBoundingBox = {
        left_top={
            x=math.min(global.custom_beacon_shapes.biggestBoundingBox.left_top.x, left_top.x),
            y=math.min(global.custom_beacon_shapes.biggestBoundingBox.left_top.y, left_top.y),
            }, 
        right_bottom={
            x=math.max(global.custom_beacon_shapes.biggestBoundingBox.right_bottom.x, right_bottom.x),
            y=math.max(global.custom_beacon_shapes.biggestBoundingBox.right_bottom.y, right_bottom.y),
        }}
    
end

function createSphereCustomShape(args, args2)

    assert(global.custom_beacon_shapes.feature_enabled, "Library usage error create_sphere_custom_shape: feature was not enabled yet via enable_feature_custom_beacon_shapes().")

    assert(args, "Library usage error create_sphere_custom_shape: arguments are missing.")
    assert(type(args) == "table", "Library usage error create_sphere_custom_shape: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error create_sphere_custom_shape: too many arguments given. arguments have to be provided in a table as one argument.")

    local radius = args.radius
    args.radius = nil
    
    assert(radius, "Library usage error create_sphere_custom_shape: radius was not provided")
    assert(type(radius) == "number", "Library usage error create_sphere_custom_shape: radius was given but it is not a number but a " .. type(radius))
    assert(radius > 0, "Library usage error create_sphere_custom_shape: radius was given but it was negative, radius =  " .. radius)
    
    local result = {}
    for y = -radius, radius do
        local str = ""
        for x = -radius, radius do
            local c
            if x == 0 and y == 0 then 
                c = "E" 
            elseif math.sqrt(y*y + x*x) <= radius then
                c = "X"
            else
                c = "O"
            end
            str = str .. c
        end
        table.insert(result, str)
    end
    return result
end

function createDiamondCustomShape(args, args2)

    assert(global.custom_beacon_shapes.feature_enabled, "Library usage error create_diamond_custom_shape: feature was not enabled yet via enable_feature_custom_beacon_shapes().")

    assert(args, "Library usage error create_diamond_custom_shape: arguments are missing.")
    assert(type(args) == "table", "Library usage error create_diamond_custom_shape: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error create_diamond_custom_shape: too many arguments given. arguments have to be provided in a table as one argument.")

    local radius = args.radius
    args.radius = nil
    
    assert(radius, "Library usage error create_diamond_custom_shape: radius was not provided")
    assert(type(radius) == "number", "Library usage error create_diamond_custom_shape: radius was given but it is not a number but a " .. type(radius))
    assert(radius > 0, "Library usage error create_diamond_custom_shape: radius was given but it was negative, radius =  " .. radius)
    
    local result = {}
    for y = -radius, radius do
        local str = ""
        for x = -radius, radius do
            local c
            if x == 0 and y == 0 then 
                c = "E" 
            elseif math.abs(x) + math.abs(y) <= radius then
                c = "X"
            else
                c = "O"
            end
            str = str .. c
        end
        table.insert(result, str)
    end
    return result
end

function isABeaconWithCustomShape(entity)
    if not global.custom_beacon_shapes.feature_enabled then return false end
    return (entity.type == "beacon" and global.custom_beacon_shapes.shapes[entity.name])
end

local function CalculateBeaconEffects(beaconEntities)

    local result = zeroEffects()

    for _, entityAndStrength in pairs(beaconEntities) do
        if entityAndStrength.entity.valid then
            local effects = entityAndStrength.entity.effects
            local effectivity = entityAndStrength.entity.prototype.distribution_effectivity
            local transmission = global.custom_beacon_shapes.transmission[entityAndStrength.entity.name][global.custom_beacon_shapes.active_timeDependentTransmission[entityAndStrength.entity.name]]
            local strength = entityAndStrength.strength
            local consumption = 0
            local speed = 0
            local productivity = 0
            local pollution = 0
            if entityAndStrength.entity.effects then
                if effects.consumption  and effects.consumption.bonus  then consumption = effects.consumption.bonus end
                if effects.speed        and effects.speed.bonus        then speed = effects.speed.bonus end
                if effects.productivity and effects.productivity.bonus then productivity = effects.productivity.bonus end
                if effects.pollution    and effects.pollution.bonus    then pollution = effects.pollution.bonus end
            end
            result.consumption.bonus = result.consumption.bonus + transmission.consumption(speed,consumption,productivity,pollution,effectivity, strength)
            result.speed.bonus = result.speed.bonus + transmission.speed(speed,consumption,productivity,pollution,effectivity, strength)
            result.productivity.bonus = result.productivity.bonus + transmission.productivity(speed,consumption,productivity,pollution,effectivity, strength)
            result.pollution.bonus = result.pollution.bonus + transmission.pollution(speed,consumption,productivity,pollution,effectivity, strength)
        end
    end
    return result
end

local function updateBonusOfAffectedEntity(entity)
    local sumOfBeaconEffects = CalculateBeaconEffects(global.custom_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number])
    global.hidden_beacons.entity_specific_boni[entity.unit_number].custom_beacon_effects = sumOfBeaconEffects
end

local function entitifyFilterContains(beaconEntity, affectedEntity)
    if not global.custom_beacon_shapes.entityFilter[beaconEntity.name] then return true end
    for _, affectionGroup in pairs(global.custom_beacon_shapes.entityFilter[beaconEntity.name]) do
        local stilMatches = true
        if affectionGroup.type and affectionGroup.type ~=affectedEntity.type then stilMatches = false end
        if affectionGroup.name and affectionGroup.name ~=affectedEntity.name then stilMatches = false end
        if affectionGroup.crafting_category then
            local entityPrototype = affectedEntity.prototype
            if entityPrototype.crafting_categories then
                if not entityPrototype.crafting_categories[affectionGroup.crafting_category] then stilMatches = false end
            else
                stilMatches = false
            end
        end
        if stilMatches then return true end
    end
    return false
end

function customShapedBeaconAffectsEntity(beaconEntity, affectedEntity, useTypeFilter)
    
    if useTypeFilter and not entitifyFilterContains(beaconEntity, affectedEntity) then return false, 0 end
    
    local beaconShape = global.custom_beacon_shapes.shapes[beaconEntity.name]
    local relativeEntityPositionInBeaconShape = global.custom_beacon_shapes.entityPositionInShape[beaconEntity.name]
    
    local tilesInside = 0
    local totalTiles = 0
    for _, gridPosition in pairs(getGridOfPositionsInsideBox(affectedEntity.bounding_box)) do
    
        totalTiles = totalTiles + 1
    
        local xIndex = math.floor(relativeEntityPositionInBeaconShape.x - (beaconEntity.position.x - gridPosition.x) + 0.5)
        local yIndex = math.floor(relativeEntityPositionInBeaconShape.y - (beaconEntity.position.y - gridPosition.y) + 0.5) 
        
        --check if the position is inside the affected area
        if 1 <= yIndex and yIndex <= #beaconShape and 1 <= xIndex and xIndex <= #beaconShape[yIndex] then            
            
            local customShapeLetter = string.sub(beaconShape[yIndex],xIndex,xIndex)
            if customShapeLetter == "X" or customShapeLetter == "E" then
                tilesInside = tilesInside + 1
            end
        end
    end
    
    local isAffected = tilesInside > 0
    return isAffected, tilesInside / totalTiles
end

local function getCustomShapeBeaconsWhichAffectEntity(entity)
    local result = {}
    --check biggest possible bounding box of any custom beacon
    local possibleBeacons = entity.surface.find_entities_filtered{
        type="beacon", 
        area = shiftArea(global.custom_beacon_shapes.biggestBoundingBox, entity.position)}
    for _, possibleBeacon in pairs(possibleBeacons) do
        if possibleBeacon ~= entity and isABeaconWithCustomShape(possibleBeacon) then
            --now check this ones bounding box for overlap
            if boundingBoxesOverlap(entity.bounding_box, shiftArea(global.custom_beacon_shapes.boundingBox[possibleBeacon.name], possibleBeacon.position)) then
                local doesAffect, strength = customShapedBeaconAffectsEntity(possibleBeacon, entity, true)
                if doesAffect then
                    table.insert(result, {entity=possibleBeacon, strength=strength})
                end
            end
            
        end
    end
    return result
end

local function getEntitiesWhichAreAffectedByBeacon(beaconEntity)
    local result = {}
    local possibleEntities = beaconEntity.surface.find_entities_filtered{
        type = global.hidden_beacons.listOfEntityTypesSupportingBeacons, 
        area = shiftArea(global.custom_beacon_shapes.boundingBox[beaconEntity.name], beaconEntity.position)}
    for _, possibleEntity in pairs(possibleEntities) do
        local doesAffect, strength =customShapedBeaconAffectsEntity(beaconEntity, possibleEntity, true)
        if doesAffect then
            table.insert(result, {entity=possibleEntity, strength=strength})
        end
    end
    return result
end

function customBeaconShapes_on_built(entity)
    if doesEntitySupportBeacons(entity) then
        local listOfBeaconsAndStrength = getCustomShapeBeaconsWhichAffectEntity(entity)
        global.custom_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number] = listOfBeaconsAndStrength
        for _, beaconAndStrength in pairs(listOfBeaconsAndStrength) do table.insert(global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[beaconAndStrength.entity.unit_number], entity) end
        updateBonusOfAffectedEntity(entity) --no need to reapply boni to entity here, as generic handler from hidden-beacons already does it
    end
    if entity.type == "beacon" and global.custom_beacon_shapes.shapes[entity.name] then
        if beaconHasAnyModuleSlots(entity) then
            --no point in recalculating this beacons effects now because beacons start without any modules inside. instead put it into a queue to be updated.
            table.insert(global.custom_beacon_shapes.fast_update_queue, entity)
        end
        local listOfEntitiesAndStrength = getEntitiesWhichAreAffectedByBeacon(entity)
        global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number] = {}
        for _, affectedEntityAndStrength in pairs(listOfEntitiesAndStrength) do 
            table.insert(global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number], affectedEntityAndStrength.entity)
            table.insert(global.custom_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[affectedEntityAndStrength.entity.unit_number], {entity=entity, strength=affectedEntityAndStrength.strength}) 
            if not beaconHasAnyModuleSlots(entity) then
                --as this beacon doesn't have space for modules, its effect can immediately be applied.
                updateBonusOfAffectedEntity(affectedEntityAndStrength.entity)
                reapplyAllHiddenBeaconEffects(affectedEntityAndStrength.entity)
            end
        end
        table.insert(global.custom_beacon_shapes.map_beacon_name_to_beacon_entities[entity.name], entity)
    end
end

function customBeaconShapes_on_unbuilt(entity)
    if not entity.unit_number then return end
    if global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number] then
        for _, affectedEntity in pairs(global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number]) do
            if affectedEntity and affectedEntity.valid then
                local newListOfAffectingBeaconsAndStrength = {}
                for _, correspondingBeaconAndStrength in pairs(global.custom_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[affectedEntity.unit_number]) do
                    if correspondingBeaconAndStrength.entity ~= entity then table.insert(newListOfAffectingBeaconsAndStrength, correspondingBeaconAndStrength) end
                end
                global.custom_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[affectedEntity.unit_number] = newListOfAffectingBeaconsAndStrength
                updateBonusOfAffectedEntity(affectedEntity)
                reapplyAllHiddenBeaconEffects(affectedEntity)
            end
        end
    end
    global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number] = nil
    
    if global.custom_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number] then
        for _, affectingBeaconAndStrength in pairs(global.custom_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number]) do
            if affectingBeaconAndStrength.entity and affectingBeaconAndStrength.entity.valid then
                local newListOfAffectedEntities = {}
                for _, affectedEntity in pairs(global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[affectingBeaconAndStrength.entity.unit_number]) do
                    if affectedEntity ~= entity then table.insert(newListOfAffectedEntities, affectedEntity) end
                end
                global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[affectingBeaconAndStrength.entity.unit_number] = newListOfAffectedEntities
            end
        end
    end
    global.custom_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number] = nil

    if global.custom_beacon_shapes.map_beacon_name_to_beacon_entities[entity.name] then
        local newEntityList = {}
        for _, listEntry in pairs(global.custom_beacon_shapes.map_beacon_name_to_beacon_entities[entity.name]) do
            if listEntry ~= entity then table.insert(newEntityList,listEntry) end
        end
        global.custom_beacon_shapes.map_beacon_name_to_beacon_entities[entity.name] = newEntityList
    end
    --no removal from
    --global.custom_beacon_shapes.slow_update_queue
    --global.custom_beacon_shapes.slow_update_queue_2
    --global.custom_beacon_shapes.fast_update_queue
    --global.custom_beacon_shapes.fast_update_queue_2
    --this will happen automatically during customBeaconShapes_on_nth_tick_60 once the removed beacon is tried to be updated (by not flipping it into the other buffer)
end

function customBeaconShapes_on_nth_tick_60(event)
    for entityName, timeDependentTransmission in pairs(global.custom_beacon_shapes.timeDependentTransmission) do
        local currentIndex = timeDependentTransmission(game.tick)
        if currentIndex ~= global.custom_beacon_shapes.active_timeDependentTransmission[entityName] then
            global.custom_beacon_shapes.active_timeDependentTransmission[entityName] = currentIndex
            local entitiesToUpdate = {}
            if global.custom_beacon_shapes.map_beacon_name_to_beacon_entities[entityName] then
                local hasInvalidBeaconEntities = false
                for _, beaconEntity in pairs(global.custom_beacon_shapes.map_beacon_name_to_beacon_entities[entityName]) do
                    if beaconEntity.valid then
                        for _, affectedEntity in pairs(global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[beaconEntity.unit_number]) do 
                            entitiesToUpdate[affectedEntity.unit_number] = affectedEntity
                        end
                    else
                        hasInvalidBeaconEntities = true
                    end
                end
                if hasInvalidBeaconEntities then
                    local newListOfBeacons = {}
                    for _, beaconEntity in pairs(global.custom_beacon_shapes.map_beacon_name_to_beacon_entities[entityName]) do
                        if beaconEntity.valid then table.insert(newListOfBeacons, beaconEntity) end
                    end
                    global.custom_beacon_shapes.map_beacon_name_to_beacon_entities[entityName] = newListOfBeacons
                end
                for _, entityToUpdate in pairs(entitiesToUpdate) do
                    --table.insert(global.custom_beacon_shapes.affected_entities_to_recheck, entityToUpdate)
                    updateBonusOfAffectedEntity(entityToUpdate)
                    reapplyAllHiddenBeaconEffects(entityToUpdate)
                end
            end
        end
    end

    if #global.custom_beacon_shapes.affected_entities_to_recheck > 0 then
        local entity = table.remove(global.custom_beacon_shapes.affected_entities_to_recheck)
        if entity and entity.valid then
            updateBonusOfAffectedEntity(entity)
            reapplyAllHiddenBeaconEffects(entity)
        end
        return
    end

    if #global.custom_beacon_shapes.slow_update_queue > 0 then
        local entity = table.remove(global.custom_beacon_shapes.slow_update_queue)
        if entity and entity.valid then
            for _, affectedEntity in pairs(global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number]) do 
                table.insert(global.custom_beacon_shapes.affected_entities_to_recheck, affectedEntity) 
            end
            if beaconIsFullyLoaded(entity) then
                table.insert(global.custom_beacon_shapes.slow_update_queue_2, entity)
            else
                table.insert(global.custom_beacon_shapes.fast_update_queue_2, entity)            
            end
        end
    else
        global.custom_beacon_shapes.slow_update_queue = global.custom_beacon_shapes.slow_update_queue_2
        global.custom_beacon_shapes.slow_update_queue_2 = {}
    end
    
    if #global.custom_beacon_shapes.fast_update_queue > 0 then
        local entity = table.remove(global.custom_beacon_shapes.fast_update_queue)
        if entity and entity.valid then
            for _, affectedEntity in pairs(global.custom_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number]) do 
                table.insert(global.custom_beacon_shapes.affected_entities_to_recheck, affectedEntity) 
            end
            if beaconIsFullyLoaded(entity) then
                table.insert(global.custom_beacon_shapes.slow_update_queue_2, entity)
            else
                table.insert(global.custom_beacon_shapes.fast_update_queue_2, entity)            
            end
        end
    else
        global.custom_beacon_shapes.fast_update_queue = global.custom_beacon_shapes.fast_update_queue_2
        global.custom_beacon_shapes.fast_update_queue_2 = {}
    end
end

local function highlightBeaconEntity(entity, player_index)

    local newEntities = {}
    if entity and isABeaconWithCustomShape(entity) then
        local beaconShape = global.custom_beacon_shapes.shapes[entity.name]
        local relativeEntityPositionInBeaconShape = global.custom_beacon_shapes.entityPositionInShape[entity.name]
        for _, gridPosition in pairs(getGridOfPositionsInsideBox(shiftArea(global.custom_beacon_shapes.boundingBox[entity.name], entity.position))) do
    
            local xIndex = math.floor(relativeEntityPositionInBeaconShape.x - (entity.position.x - gridPosition.x) + 0.5)
            local yIndex = math.floor(relativeEntityPositionInBeaconShape.y - (entity.position.y - gridPosition.y) + 0.5) 
            
            --check if the position is inside the affected area
            if 1 <= yIndex and yIndex <= #beaconShape and 1 <= xIndex and xIndex <= #beaconShape[yIndex] then            
                
                local customShapeLetter = string.sub(beaconShape[yIndex],xIndex,xIndex)
                if customShapeLetter == "X" or customShapeLetter == "E" then
                    local newEntity = entity.surface.create_entity{name = "custom-beacon-radius-visualization", position = {gridPosition.x, gridPosition.y}, render_player_index=player_index}
                    newEntity.destructible = false
                    newEntity.minable = false
                    table.insert(newEntities, newEntity)
                end
            end
        end
    end
    return newEntities
    
end

local function highlightEntitiesAffectedByCustomShapedBeacon(entity, player_index)
    local newEntities = {}
    if entity and isABeaconWithCustomShape(entity) then
        local affectedEntitiesAndStrength = getEntitiesWhichAreAffectedByBeacon(entity)
        for _, affectedEntityAndStrength in pairs(affectedEntitiesAndStrength) do
            if affectedEntityAndStrength.entity.selection_box then 
                table.insert(newEntities, affectedEntityAndStrength.entity.surface.create_entity{name="highlight-box", bounding_box=affectedEntityAndStrength.entity.selection_box, position = {0,0}, blink_interval=0, box_type="train-visualization"})
            end
        end
    end
    return newEntities
end

function customBeaconShapes_on_selected_entity_changed(event)
    --player_index :: uint: The player whose selected entity changed.
    --last_entity :: LuaEntity (optional): The last selected entity if it still exists and there was one.
    if global.custom_beacon_shapes.range_visualization[event.player_index] then
        for _, entity in pairs(global.custom_beacon_shapes.range_visualization[event.player_index]) do entity.destroy() end
    end
    local player = game.players[event.player_index]
    local selectedEntity = player.selected
    local newHighlightEntities = highlightBeaconEntity(selectedEntity, event.player_index)
    local additionalHighlightBoxes = highlightEntitiesAffectedByCustomShapedBeacon(selectedEntity, player_index)
    for _, e in pairs(additionalHighlightBoxes) do table.insert(newHighlightEntities, e) end
    global.custom_beacon_shapes.range_visualization[event.player_index] = newHighlightEntities
end

function customBeaconShapes_on_player_cursor_stack_changed(event)
    --player_index :: uint
    if global.custom_beacon_shapes.range_visualization_cursorItem[event.player_index] then
        for _, entity in pairs(global.custom_beacon_shapes.range_visualization_cursorItem[event.player_index]) do entity.destroy() end
    end
    global.custom_beacon_shapes.range_visualization_cursorItem[event.player_index] = {}
    local player = game.players[event.player_index]
    local itemStack = player.cursor_stack
    if itemStack and itemStack.valid and itemStack.valid_for_read and itemStack.prototype and itemStack.prototype.place_result 
    and (doesEntitySupportBeacons({type=itemStack.prototype.place_result.type}) or itemStack.prototype.place_result.type == "beacon")
        then --maybe at some point allow filtering which entites could affect the entity in the cursor, then also filter here
        --it is not really possible to identify the entities on screen which should be used for illustration purposes... so here this is only done around the player
        local character = player.character
        if character then
            local entities = character.surface.find_entities_filtered{
                type="beacon", 
                area = shiftArea({left_top={x=-64,y=-64}, right_bottom={x=64,y=64}}, character.position)}
            for _, entityToHighlight in pairs(entities) do
                local newHighlightEntities = highlightBeaconEntity(entityToHighlight, event.player_index)
                for _, entity in pairs(newHighlightEntities) do
                    table.insert(global.custom_beacon_shapes.range_visualization_cursorItem[event.player_index], entity)
                end
            end
        end
    end
end