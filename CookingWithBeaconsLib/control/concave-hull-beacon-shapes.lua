function enableFeatureConcaveHullBeaconShapes()

    enableFeatureHiddenBeacons()
    
    if not global.concave_beacon_shapes.feature_enabled then

        --data structures modified during initialization
        global.concave_beacon_shapes.feature_enabled = true
        global.concave_beacon_shapes.hullEntityNames = {}
        global.concave_beacon_shapes.beaconEntityHullName = {}
        global.concave_beacon_shapes.mapHullEntityNameToSameHullNames = {}
        global.concave_beacon_shapes.transmission = {}
        global.concave_beacon_shapes.timeDependentTransmission = {}
        global.concave_beacon_shapes.entityFilter = {}
        global.concave_beacon_shapes.powerConsumption = {}
        global.concave_beacon_shapes.powerExponent = {}
    
        
        --data structures dynamically updated
        global.concave_beacon_shapes.incompleteHulls = {}
        global.concave_beacon_shapes.completeHulls = {}
        global.concave_beacon_shapes.mapEntityToListOfHulls = {}
        global.concave_beacon_shapes.lastRejectedPlacement = {}
        
        global.concave_beacon_shapes.affected_entities_to_recheck = {}
        global.concave_beacon_shapes.slow_update_queue = {}
        global.concave_beacon_shapes.slow_update_queue_2 = {}
        global.concave_beacon_shapes.fast_update_queue = {}
        global.concave_beacon_shapes.fast_update_queue_2 = {}
        global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities = {}
        global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons = {}
        global.concave_beacon_shapes.range_visualization = {}
        global.concave_beacon_shapes.range_visualization_cursorItem = {}
        global.concave_beacon_shapes.active_timeDependentTransmission = {}
        global.concave_beacon_shapes.map_beacon_name_to_beacon_entities = {}
        global.concave_beacon_shapes.map_entity_unit_number_to_consumer = {}
    end
end

function registerHullEntities(args, args2)

    assert(global.concave_beacon_shapes.feature_enabled, "Library usage error set_concave_hull_creating_group: feature was not enabled yet via enable_feature_concave_beacon_shapes().")

    assert(args, "Library usage error set_concave_hull_creating_group: arguments are missing.")
    assert(type(args) == "table", "Library usage error set_concave_hull_creating_group: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error set_concave_hull_creating_group: too many arguments given. arguments have to be provided in a table as one argument.")
    
    local hullName = args.hullName
    args.hullName = nil
    local entities = args.entities
    args.entities = nil
    for k,_ in pairs(args) do error("Library usage error set_concave_hull_creating_group: unsupported argument " .. k) end

    assert(hullName, "Library usage error set_concave_hull_creating_group: hullName was not provided")
    assert(type(hullName) == "string", "Library usage error set_concave_hull_creating_group: hullName was given but it is not a string but a " .. type(hullName))
    assert(global.concave_beacon_shapes.hullEntityNames[hullName] == nil, "Library usage error set_concave_hull_creating_group: hull group " .. hullName .. " already has a list of entities, setting it again is not possible.")
    assert(entities, "Library usage error set_concave_hull_creating_group: entities was not provided")
    assert(type(entities) == "table", "Library usage error set_concave_hull_creating_group: entities was given but it is not a table but a " .. type(entities))
    local hasAtLeastOneEntity = false
    for _, entity in pairs(entities) do
        hasAtLeastOneEntity = true
        assert(type(entity) == "string", "Library usage error set_concave_hull_creating_group: entity in entity list was given but it is not a string but a " .. type(entity))
        assert(game.entity_prototypes[entity], "Library usage error set_forbidden_beacon_overlap_for_entity: entity was given but such an entity doesn't exist. entity is: " .. entity)
        assert(game.entity_prototypes[entity].type == "wall" or game.entity_prototypes[entity].type == "gate", 
            "Library usage error set_forbidden_beacon_overlap_for_entity: entity was given as " .. entity .. " however it is neither a wall or gate, instead it is " .. game.entity_prototypes[entity].type)
        assert(global.concave_beacon_shapes.hullEntityNames[entity] == nil, "Library usage error set_forbidden_beacon_overlap_for_entity: entity " .. entity .. " was already specified for a different hull")
    end
    assert(hasAtLeastOneEntity, "Library usage error set_concave_hull_creating_group: entity list was empty")
    
    for _, entity1 in pairs(entities) do
        global.concave_beacon_shapes.hullEntityNames[entity1] = true
        global.concave_beacon_shapes.mapHullEntityNameToSameHullNames[entity1] = {}
        for _, entity2 in pairs(entities) do
            table.insert(global.concave_beacon_shapes.mapHullEntityNameToSameHullNames[entity1], entity2)
        end
    end
    
end

function giveConcaveHullBeaconShapeToEntity(args, args2)

    assert(global.concave_beacon_shapes.feature_enabled, "Library usage error give_concave_hull_beacon_shape_to_entity: feature was not enabled yet via enable_feature_concave_beacon_shapes().")

    assert(args, "Library usage error give_concave_hull_beacon_shape_to_entity: arguments are missing.")
    assert(type(args) == "table", "Library usage error give_concave_hull_beacon_shape_to_entity: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error give_concave_hull_beacon_shape_to_entity: too many arguments given. arguments have to be provided in a table as one argument.")
    
    local name = args.name
    args.name = nil
    local hullName = args.hullName
    args.hullName = nil
    local entityFilter = args.entityFilter
    args.entityFilter = nil
    local transmission = args.transmission
    args.transmission = nil
    local timeDependentTransmission = args.timeDependentTransmission
    args.timeDependentTransmission = nil
    local powerConsumption = args.powerConsumption
    args.powerConsumption = nil
    local powerExponent = args.powerExponent
    args.powerExponent = nil
    for k,_ in pairs(args) do error("Library usage error give_concave_hull_beacon_shape_to_entity: unsupported argument " .. k) end

    assert(name, "Library usage error give_concave_hull_beacon_shape_to_entity: name was not provided")
    assert(type(name) == "string", "Library usage error give_concave_hull_beacon_shape_to_entity: name was given but it is not a string but a " .. type(name))
    assert(global.concave_beacon_shapes.beaconEntityHullName[name] == nil, "Library usage error give_concave_hull_beacon_shape_to_entity: entity " .. name .. " already has a concave hull shape, setting it again is not possible.")
    assert(game.entity_prototypes[name], "Library usage error give_concave_hull_beacon_shape_to_entity: name was given but such an entity doesn't exist. name is: " .. name)
    assert(game.entity_prototypes[name].type == "beacon", "Library usage error give_concave_hull_beacon_shape_to_entity: name was given as " .. name .. " but it is not a beacon but a " .. game.entity_prototypes[name].type)
    assert(game.entity_prototypes[name].supply_area_distance == 0, "Library usage error give_concave_hull_beacon_shape_to_entity: beacon with name " .. name .. " still has a normal supply_area_distance value; did you forget to call cookingwithbeaconslib.public.setup_concave_beacon_shapes during the data stage?")
    assert(hullName, "Library usage error give_concave_hull_beacon_shape_to_entity: hullName was not provided for " .. name)
    assert(type(hullName) == "string", "Library usage error give_concave_hull_beacon_shape_to_entity: hullName was given but it is not a table but a " .. type(hullName) .. " for " .. name)
    --todo maybe assert that the hull name is already specified? or is this not needed?

    global.concave_beacon_shapes.beaconEntityHullName[name] = hullName
        
    --entityFilter, transmission, timeDependentTransmission are optional
    --powerConsumption and powerExponent are checked below

    global.concave_beacon_shapes.entityFilter[name] = entityFilter
    if not transmission then
        global.concave_beacon_shapes.transmission[name] ={
            {
                speed=function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return speed * distribution_effectivity end,
                consumption=function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return consumption * distribution_effectivity end,
                productivity=function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return productivity * distribution_effectivity end,
                pollution=function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return pollution * distribution_effectivity end,
            }
        }
    else
        assert(type(transmission) == "table", "Library usage error give_concave_hull_beacon_shape_to_entity: transmission was given but it is not a table but a " .. type(transmission))
        global.concave_beacon_shapes.transmission[name] ={}
        for transmissionGroupIndex, transmissionGroup in pairs(transmission) do
            table.insert(global.concave_beacon_shapes.transmission[name], {})
            for _, effectType in pairs({"speed", "consumption", "productivity", "pollution"}) do
                assert(transmissionGroup[effectType], "Library usage error: in the transmission group " .. transmissionGroupIndex .. "the element for effectType " .. effectType .. "is missing")
                assert(type(transmissionGroup[effectType]) == "string", "Library usage error: in the transmission group " .. transmissionGroupIndex .. "the element for effectType " .. effectType .. "is expected to be a string, but it is " .. type(transmissionGroup[effectType]))
                local registerFunction , errmsg = loadstring(
                    "global.concave_beacon_shapes.transmission[\"" ..  name .. "\"]["..transmissionGroupIndex.."]."..effectType.." = " .. transmissionGroup[effectType])
                if not registerFunction then
                    error("Library usage error give_concave_hull_beacon_shape_to_entity: transmission " .. transmissionGroupIndex .. " effect " .. effectType .. " has error: " .. tostring(errmsg))
                end
                registerFunction()
            end
        end
    end
        
    if not timeDependentTransmission then
        global.concave_beacon_shapes.timeDependentTransmission[name] = function(tick) return 1 end
    else
        assert(type(timeDependentTransmission) == "string", "Library usage error give_concave_hull_beacon_shape_to_entity: timeDependentTransmission is expected to be a string, but it is " .. type(timeDependentTransmission))
        local registerFunction , errmsg = loadstring("global.concave_beacon_shapes.timeDependentTransmission[\"" ..  name .. "\"] = " .. timeDependentTransmission)
        if not registerFunction then
            error("Library usage error give_concave_hull_beacon_shape_to_entity: timeDependentTransmission for " .. name .. " : error: " .. tostring(errmsg))
        end
        registerFunction()
    end
    global.concave_beacon_shapes.active_timeDependentTransmission[name] = 1
    
    assert(powerConsumption, "Library usage error give_concave_hull_beacon_shape_to_entity: powerConsumption was not provided")
    assert(type(powerConsumption) == "number", "Library usage error give_concave_hull_beacon_shape_to_entity: powerConsumption was given but it is not a string but a " .. type(powerConsumption))
    assert(powerExponent, "Library usage error give_concave_hull_beacon_shape_to_entity: powerExponent was not provided")
    assert(type(powerExponent) == "number", "Library usage error give_concave_hull_beacon_shape_to_entity: powerExponent was given but it is not a string but a " .. type(powerExponent))
    global.concave_beacon_shapes.powerConsumption[name] = powerConsumption
    global.concave_beacon_shapes.powerExponent[name] = powerExponent
    
    
    global.concave_beacon_shapes.map_beacon_name_to_beacon_entities[name] = {}
end

function isEntityTypePartOfConvexHull(entity)
    if not global.concave_beacon_shapes.feature_enabled then return false end
    return ((entity.type == "gate" or entity.type == "wall") and global.concave_beacon_shapes.hullEntityNames[entity.name])
end

function isABeaconWithConcaveHull(entity)
    if not global.concave_beacon_shapes.feature_enabled then return false end
    return (entity.type == "beacon" and global.concave_beacon_shapes.beaconEntityHullName[entity.name])
end

local function CalculateBeaconEffects(beaconEntities)

    local result = zeroEffects()

    for _, entityAndStrength in pairs(beaconEntities) do
        if entityAndStrength.entity.valid then
            local effectivity = entityAndStrength.entity.prototype.distribution_effectivity
            local transmission = global.concave_beacon_shapes.transmission[entityAndStrength.entity.name][global.concave_beacon_shapes.active_timeDependentTransmission[entityAndStrength.entity.name]]
            local strength = entityAndStrength.strength
            local consumption = 0
            local speed = 0
            local productivity = 0
            local pollution = 0
            local effects = entityAndStrength.entity.effects
            if effects then
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
    local sumOfBeaconEffects = CalculateBeaconEffects(global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number])
    global.hidden_beacons.entity_specific_boni[entity.unit_number].concave_beacon_effects = sumOfBeaconEffects
end

local function entitifyFilterContains(beaconEntity, affectedEntity)
    if not global.concave_beacon_shapes.entityFilter[beaconEntity.name] then return true end
    for _, affectionGroup in pairs(global.concave_beacon_shapes.entityFilter[beaconEntity.name]) do
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

local function getCustomShapeBeaconsWhichAffectEntity(entity)
    local result = {}
    
    local hulls = global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number]

    for _, hull in pairs(hulls) do
        for _, beacon in pairs(hull.containedBeacons) do
            if isABeaconWithConcaveHull(beacon) and entitifyFilterContains(beacon, entity) then
                table.insert(result, {entity=beacon, strength=1})
            end
        end
    end
    return result
end

local function getEntitiesWhichAreAffectedByBeacon(beaconEntity)
    local result = {}
    
    local hulls = global.concave_beacon_shapes.mapEntityToListOfHulls[beaconEntity.unit_number]
    for _, hull in pairs(hulls) do
        for _, entity in pairs(hull.containedEntities) do
            if entitifyFilterContains(beaconEntity, entity) then
                table.insert(result, {entity=entity, strength=1})
            end
        end
    end
    return result
end

local function isLooseEnd(entity)
    for hullIndex, concaveHull in pairs(global.concave_beacon_shapes.incompleteHulls) do
        if entity == concaveHull.looseEnd1 or (concaveHull.looseEnd2 and entity == concaveHull.looseEnd2) then 
            return true, concaveHull, entity == concaveHull.looseEnd1, hullIndex
        end
    end
    return false
end

local function recalculateBeaconPowerConsumption(entity)
    local numberOfAffectedTiles = 0
    for _, hull in pairs(global.concave_beacon_shapes.completeHulls) do
        if positionIsInBoundingBox(entity.position, hull.boundingBox) then
            local positionToCheck = {x=math.floor(entity.position.x) + 0.5,y=math.floor(entity.position.y) + 0.5}
            if hull.floodedPositionsMatrix[positionToCheck.x] and hull.floodedPositionsMatrix[positionToCheck.x][positionToCheck.y] then
                numberOfAffectedTiles = numberOfAffectedTiles + #hull.floodedPositionsWithinHull
            end
        end
    end
    local consumer = global.concave_beacon_shapes.map_entity_unit_number_to_consumer[entity.unit_number]
    consumer.power_usage = (numberOfAffectedTiles * global.concave_beacon_shapes.powerConsumption[entity.name]) ^ global.concave_beacon_shapes.powerExponent[entity.name]    
end

local function getNeighbourHullEntities(entity)    
    local otherHullEntityNames = global.concave_beacon_shapes.mapHullEntityNameToSameHullNames[entity.name] --todo is this correct? what if neighbor is of a different kind of hull?
    local neighbourCount = 0
    local entitiesNorth = entity.surface.find_entities_filtered{
        type={"wall","gate"}, 
        name = otherHullEntityNames,
        position = {x=entity.position.x, y=entity.position.y - 1},
        limit = 1}
    local entityNorth = nil
    if #entitiesNorth > 0 then entityNorth = entitiesNorth[1] neighbourCount = neighbourCount + 1 end
    local entitiesSouth = entity.surface.find_entities_filtered{
        type={"wall","gate"}, 
        name = otherHullEntityNames,
        position = {x=entity.position.x, y=entity.position.y + 1},
        limit = 1}
    local entitySouth = nil
    if #entitiesSouth > 0 then entitySouth = entitiesSouth[1] neighbourCount = neighbourCount + 1 end
    local entitiesWest = entity.surface.find_entities_filtered{
        type={"wall","gate"}, 
        name = otherHullEntityNames,
        position = {x=entity.position.x - 1, y=entity.position.y},
        limit = 1}
    local entityWest = nil
    if #entitiesWest > 0 then entityWest = entitiesWest[1] neighbourCount = neighbourCount + 1 end
    local entitiesEast = entity.surface.find_entities_filtered{
        type={"wall","gate"}, 
        name = otherHullEntityNames,
        position = {x=entity.position.x + 1, y=entity.position.y},
        limit = 1}
    local entityEast = nil
    if #entitiesEast > 0 then entityEast = entitiesEast[1] neighbourCount = neighbourCount + 1 end
    return neighbourCount, entityNorth, entitySouth, entityWest, entityEast
end

local function floodPositions(startingPosition, hullMatrix, boundingBox)
    local pendingListOfPositions = {startingPosition}
    local visitedPositionsMatrix = {}
    local floodedPositions = {}
    local floodedPositionsMatrix = {}
    while #pendingListOfPositions > 0 do
        local positionToVisit = table.remove(pendingListOfPositions)
        if not visitedPositionsMatrix[positionToVisit.x] or not visitedPositionsMatrix[positionToVisit.x][positionToVisit.y] then
            if not visitedPositionsMatrix[positionToVisit.x] then visitedPositionsMatrix[positionToVisit.x] = {} end
            visitedPositionsMatrix[positionToVisit.x][positionToVisit.y] = true
            if not positionIsInBoundingBox(positionToVisit, boundingBox) then return false end
            if not(hullMatrix[positionToVisit.x] and hullMatrix[positionToVisit.x][positionToVisit.y]) then
                table.insert(floodedPositions, positionToVisit)
                if floodedPositionsMatrix[positionToVisit.x] == nil then floodedPositionsMatrix[positionToVisit.x] = {} end 
                floodedPositionsMatrix[positionToVisit.x][positionToVisit.y] = true
                table.insert(pendingListOfPositions, {x=positionToVisit.x-1, y=positionToVisit.y})
                table.insert(pendingListOfPositions, {x=positionToVisit.x+1, y=positionToVisit.y})
                table.insert(pendingListOfPositions, {x=positionToVisit.x, y=positionToVisit.y-1})
                table.insert(pendingListOfPositions, {x=positionToVisit.x, y=positionToVisit.y+1})                
            end
        end
    end
    return true, floodedPositions, floodedPositionsMatrix
end

local function determinePositionsInsideHull(hullMatrix, hullBoundingBox, entity, entityNorth, entitySouth, entityWest, entityEast)
    --it is known here that two of the entities are nil, and two are set indicating the hull.
    --try to flood both sides identified from the two hull sides.
    --it is not known which position is outside or inside. once flooding either terminates or reaches the bounding box it is clear.
    local floodingPosition1
    local floodingPosition2
    local pN = {x=entity.position.x, y=entity.position.y-1}
    local pNE = {x=entity.position.x+1, y=entity.position.y-1}
    local pE = {x=entity.position.x+1, y=entity.position.y}
    local pSE = {x=entity.position.x+1, y=entity.position.y+1}
    local pS = {x=entity.position.x, y=entity.position.y+1}
    local pSW = {x=entity.position.x-1, y=entity.position.y+1}
    local pW = {x=entity.position.x-1, y=entity.position.y}
    local pNW = {x=entity.position.x-1, y=entity.position.y-1}
    if entityNorth and entitySouth then floodingPosition1 = pE floodingPosition2 = pW   end
    if entityNorth and entityWest  then floodingPosition1 = pNW floodingPosition2 = pSE end
    if entityNorth and entityEast  then floodingPosition1 = pNE floodingPosition2 = pSW end
    if entitySouth and entityWest  then floodingPosition1 = pSW floodingPosition2 = pNE end
    if entitySouth and entityEast  then floodingPosition1 = pSE floodingPosition2 = pNW end
    if entityWest and entityEast   then floodingPosition1 = pN floodingPosition2 = pS   end    
    local containedInBoundingBox, floodedPositions, floodedPositionsMatrix = floodPositions(floodingPosition1, hullMatrix, hullBoundingBox)
    if not containedInBoundingBox then
        containedInBoundingBox, floodedPositions, floodedPositionsMatrix = floodPositions(floodingPosition2, hullMatrix, hullBoundingBox)        
    end
    assert(containedInBoundingBox, "CookingWithBeacons: when flooding the concave hull, both ends exceeded the bounding box.")
    return floodedPositions, floodedPositionsMatrix
end

function concaveHullBeaconShapes_on_built(entity)

    if isEntityTypePartOfConvexHull(entity) then
    
        --check if this would complete a hull inside another hull of same type, which is forbidden
        local isAHullInsideHull = false
        for _, hull in pairs(global.concave_beacon_shapes.completeHulls) do
            if positionIsInBoundingBox(entity.position, hull.boundingBox) and
                hull.floodedPositionsMatrix[entity.position.x] and
                hull.floodedPositionsMatrix[entity.position.x][entity.position.y] then
                
                local sameHullEntities = global.concave_beacon_shapes.mapHullEntityNameToSameHullNames[hull.hullEntities[1].name]
                for _, sameHullEntity in pairs(sameHullEntities) do
                    if entity.name == sameHullEntity then
                        isAHullInsideHull = true
                    end
                end
            end
        end
        if isAHullInsideHull then
            global.concave_beacon_shapes.lastRejectedPlacement = entity
            entity.die()
        else
            local neighbourCount, entityNorth, entitySouth, entityWest, entityEast = getNeighbourHullEntities(entity)
            
            if neighbourCount == 0 then
                table.insert(global.concave_beacon_shapes.incompleteHulls, {looseEnd1 = entity, entities={entity}})
            elseif neighbourCount == 1 then
                local other = entityNorth or entitySouth or entityWest or entityEast
                local isLooseEnd, concaveHull, isSideA = isLooseEnd(other) 
                if isLooseEnd then
                    if not concaveHull.looseEnd2 then
                        concaveHull.looseEnd2 = entity
                        table.insert(concaveHull.entities, entity)
                    elseif isSideA then
                        concaveHull.looseEnd1 = entity
                        table.insert(concaveHull.entities, 1, entity)
                    else
                        concaveHull.looseEnd2 = entity
                        table.insert(concaveHull.entities, entity)
                    end
                else
                    global.concave_beacon_shapes.lastRejectedPlacement = entity
                    entity.die()
                    --todo error message shown
                end
            elseif neighbourCount == 2 then
                local entity1 = entityNorth or entitySouth or entityWest
                local entity2 = entityEast or entityWest or entitySouth
                local isLooseEnd1, concaveHull1, isSideA1, hullIndex1 = isLooseEnd(entity1) 
                local isLooseEnd2, concaveHull2, isSideA2, hullIndex2 = isLooseEnd(entity2) 
                if isLooseEnd1 and isLooseEnd2 and (concaveHull1 == concaveHull2) then --finish concave hull
                    table.insert(concaveHull1.entities, entity)
                    local entities = concaveHull1.entities
                    table.remove(global.concave_beacon_shapes.incompleteHulls, hullIndex1)
                    local hullBoundingBox = {left_top={x=entity.position.x,y=entity.position.y}, right_bottom={x=entity.position.x,y=entity.position.y}}
                    local hullMatrix = {}
                    for _, e in pairs(entities) do
                        hullBoundingBox.left_top.x = math.min(hullBoundingBox.left_top.x, e.position.x)
                        hullBoundingBox.left_top.y = math.min(hullBoundingBox.left_top.y, e.position.y)
                        hullBoundingBox.right_bottom.x = math.max(hullBoundingBox.right_bottom.x, e.position.x)
                        hullBoundingBox.right_bottom.y = math.max(hullBoundingBox.right_bottom.y, e.position.y)
                        if hullMatrix[e.position.x] == nil then hullMatrix[e.position.x] = {} end
                        hullMatrix[e.position.x][e.position.y] = true
                    end
                    local floodedPositions, floodedPositionsMatrix = determinePositionsInsideHull(hullMatrix, hullBoundingBox, entity, entityNorth, entitySouth, entityWest, entityEast)
                    local newConcaveHull = {
                        hullEntities=entities, 
                        hullMatrix=hullMatrix, 
                        boundingBox=hullBoundingBox, 
                        floodedPositionsWithinHull=floodedPositions, 
                        floodedPositionsMatrix=floodedPositionsMatrix,
                        containedEntities = {},
                        containedBeacons = {},
                    }
                    table.insert(global.concave_beacon_shapes.completeHulls, newConcaveHull)
                    --todo now all contained entities must be collected as well
                    local entitiesInHullBoundingBox = entity.surface.find_entities_filtered{area=hullBoundingBox, type=global.hidden_beacons.listOfEntityTypesSupportingBeacons}
                    local beaconsInHullBoundingBox = entity.surface.find_entities_filtered{area=hullBoundingBox, type="beacon"}
                    local hullPiecesInsideBoundingBox = entity.surface.find_entities_filtered{area=hullBoundingBox, type={"wall", "gate"}, 
                        name=global.concave_beacon_shapes.mapHullEntityNameToSameHullNames[entity.name]}
                    for _, e in pairs(entitiesInHullBoundingBox) do
                        --now precise check
                        local positionToCheck = {x=math.floor(e.position.x) + 0.5,y=math.floor(e.position.y) + 0.5}
                        if floodedPositionsMatrix[positionToCheck.x] and floodedPositionsMatrix[positionToCheck.x][positionToCheck.y] then
                            if global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number] == nil then global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number] = {} end
                            table.insert(global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number], newConcaveHull)
                            table.insert(newConcaveHull.containedEntities, e)
                        end
                    end
                    for _, e in pairs(beaconsInHullBoundingBox) do
                        --now precise check
                        local positionToCheck = {x=math.floor(e.position.x) + 0.5,y=math.floor(e.position.y) + 0.5}
                        if floodedPositionsMatrix[positionToCheck.x] and floodedPositionsMatrix[positionToCheck.x][positionToCheck.y] then
                            if global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number] == nil then global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number] = {} end
                            table.insert(global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number], newConcaveHull)
                            table.insert(newConcaveHull.containedBeacons, e)
                            if isABeaconWithConcaveHull(e) then
                                for _, affectedEntity in pairs(newConcaveHull.containedEntities) do
                                    table.insert(global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[e.unit_number], affectedEntity)
                                    table.insert(global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[affectedEntity.unit_number], {entity=e, strength=1})
                                    updateBonusOfAffectedEntity(affectedEntity)
                                    reapplyAllHiddenBeaconEffects(affectedEntity)
                                end
                                recalculateBeaconPowerConsumption(e)
                            end
                        end
                    end
                    for _, e in pairs(hullPiecesInsideBoundingBox) do
                        --now precise check
                        local positionToCheck = {x=math.floor(e.position.x) + 0.5,y=math.floor(e.position.y) + 0.5}
                        if floodedPositionsMatrix[positionToCheck.x] and floodedPositionsMatrix[positionToCheck.x][positionToCheck.y] then
                            e.die()
                            --todo error message shown (hull inside hull)
                        end
                    end
                elseif isLooseEnd1 and isLooseEnd2 then --merge hull pieces
                    if not isSideA1 and isSideA2 then
                        table.insert(concaveHull1.entities, entity)
                        for i = 1,#concaveHull2.entities, 1 do table.insert(concaveHull1.entities, concaveHull2.entities[i]) end
                        concaveHull1.looseEnd2 = concaveHull2.entities[#concaveHull2.entities]
                        table.remove(global.concave_beacon_shapes.incompleteHulls, hullIndex2)
                    elseif not isSideA1 and not isSideA2 then
                        table.insert(concaveHull1.entities, entity)
                        for i = #concaveHull2.entities,1,-1 do table.insert(concaveHull1.entities, concaveHull2.entities[i]) end
                        concaveHull1.looseEnd2 = concaveHull2.entities[1]
                        table.remove(global.concave_beacon_shapes.incompleteHulls, hullIndex2)
                    elseif isSideA1 and isSideA2 then
                        local newEntityList = {}
                        for i=#concaveHull1.entities, 1,-1 do
                            newEntityList[#newEntityList+1] = concaveHull1.entities[i]
                        end
                        table.insert(newEntityList, entity)
                        for i = 1,#concaveHull2.entities, 1 do table.insert(newEntityList, concaveHull2.entities[i]) end                    
                        concaveHull1.looseEnd1 = newEntityList[1]
                        concaveHull1.looseEnd2 = concaveHull2.entities[#concaveHull2.entities]
                        concaveHull1.entities = newEntityList
                        table.remove(global.concave_beacon_shapes.incompleteHulls, hullIndex2)
                    else --isSideA1 and not isSideA2
                        table.insert(concaveHull2.entities, entity)
                        for i = 1,#concaveHull1.entities, 1 do table.insert(concaveHull2.entities, concaveHull1.entities[i]) end
                        concaveHull2.looseEnd2 = concaveHull1.entities[#concaveHull1.entities]
                        table.remove(global.concave_beacon_shapes.incompleteHulls, hullIndex1)                    
                    end
                    --todo fast replace of wall with gate not considered... maybe it still works though
                else
                    global.concave_beacon_shapes.lastRejectedPlacement = entity
                    entity.die()
                    --todo error message shown
                end
            else
                global.concave_beacon_shapes.lastRejectedPlacement = entity
                entity.die()
                --todo error message shown
            end
        end
    --now update beacons and affected entities
    elseif doesEntitySupportBeacons(entity) then
        global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number] = {}
        for _, hull in pairs(global.concave_beacon_shapes.completeHulls) do
            if positionIsInBoundingBox(entity.position, hull.boundingBox) then
                local positionToCheck = {x=math.floor(entity.position.x) + 0.5,y=math.floor(entity.position.y) + 0.5}
                if hull.floodedPositionsMatrix[positionToCheck.x] and hull.floodedPositionsMatrix[positionToCheck.x][positionToCheck.y] then
                    table.insert(global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number], hull)
                    table.insert(hull.containedEntities, entity)
                end
            end
        end
        
        local listOfBeaconsAndStrength = getCustomShapeBeaconsWhichAffectEntity(entity)
        global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number] = listOfBeaconsAndStrength
        for _, beaconAndStrength in pairs(listOfBeaconsAndStrength) do table.insert(global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[beaconAndStrength.entity.unit_number], entity) end
        updateBonusOfAffectedEntity(entity) --no need to reapply boni to entity here, as generic handler from hidden-beacons already does it
    elseif isABeaconWithConcaveHull(entity) then
        if beaconHasAnyModuleSlots(entity) then
            --no point in recalculating this beacons effects now because beacons start without any modules inside. instead put it into a queue to be updated.
            table.insert(global.concave_beacon_shapes.fast_update_queue, entity)
        end
        global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number] = {}
        for aaa, hull in pairs(global.concave_beacon_shapes.completeHulls) do
            if positionIsInBoundingBox(entity.position, hull.boundingBox) then
                local positionToCheck = {x=math.floor(entity.position.x) + 0.5,y=math.floor(entity.position.y) + 0.5}
                if hull.floodedPositionsMatrix[positionToCheck.x] and hull.floodedPositionsMatrix[positionToCheck.x][positionToCheck.y] then
                    table.insert(global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number], hull)
                    table.insert(hull.containedBeacons, entity)
                end
            end
        end
        
        local listOfEntitiesAndStrength = getEntitiesWhichAreAffectedByBeacon(entity)
        global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number] = {}
                            
        for _, affectedEntityAndStrength in pairs(listOfEntitiesAndStrength) do 
            table.insert(global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number], affectedEntityAndStrength.entity)
            table.insert(global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[affectedEntityAndStrength.entity.unit_number], {entity=entity, strength=affectedEntityAndStrength.strength})
            if not beaconHasAnyModuleSlots(entity) then
                --as this beacon doesn't have space for modules, its effect can immediately be applied.
                updateBonusOfAffectedEntity(affectedEntityAndStrength.entity)
                reapplyAllHiddenBeaconEffects(affectedEntityAndStrength.entity)
            end
        end
        table.insert(global.concave_beacon_shapes.map_beacon_name_to_beacon_entities[entity.name], entity)
        local nameOfReceiver = "concave-hull-energy-receiver-"..entity.name
        local newPowerConsumer = entity.surface.create_entity{name = nameOfReceiver, position = entity.position, force = entity.force}
        global.concave_beacon_shapes.map_entity_unit_number_to_consumer[entity.unit_number] = newPowerConsumer
        recalculateBeaconPowerConsumption(entity)
    end
end

function concaveHullBeaconShapes_on_unbuilt(entity)
    
    if entity == global.concave_beacon_shapes.lastRejectedPlacement then 
        --ignore this entities destruction logic since its construction had no affect as it was rejected
        global.concave_beacon_shapes.lastRejectedPlacement = nil
        return 
    end

    if isEntityTypePartOfConvexHull(entity) then
        
        local neighbourCount, entityNorth, entitySouth, entityWest, entityEast = getNeighbourHullEntities(entity)
        
        if neighbourCount == 0 then
            local isLooseEnd, concaveHull, isSideA, hullIndex = isLooseEnd(entity)
            assert(isLooseEnd, "CookingWithBeacons: expected destroyed hull entity without neighbours to be a loose end of the hull.")
            table.remove(global.concave_beacon_shapes.incompleteHulls, hullIndex)
        elseif neighbourCount == 1 then
            local isLooseEnd, concaveHull, isSideA, hullIndex = isLooseEnd(entity)
            assert(isLooseEnd, "CookingWithBeacons: expected destroyed hull entity with 1 neighbours to be a loose end of the hull.")
            local other = entityNorth or entitySouth or entityWest or entityEast
            if isSideA then
                concaveHull.looseEnd1 = other
                table.remove(concaveHull.entities, 1)
                if #concaveHull.entities == 1 then concaveHull.looseEnd2 = nil end
            else
                table.remove(concaveHull.entities)
                if #concaveHull.entities > 1 then concaveHull.looseEnd2 = concaveHull.entities[#concaveHull.entities] else concaveHull.looseEnd2 = nil end
            end
        elseif neighbourCount == 2 then
            local entity1 = entityNorth or entitySouth or entityWest
            local entity2 = entityEast or entityWest or entitySouth
            local isLooseEnd1, concaveHull1, isSideA1, hullIndex1 = isLooseEnd(entity1) 
            local isLooseEnd2, concaveHull2, isSideA2, hullIndex2 = isLooseEnd(entity2) 
            if hullIndex1 and hullIndex2 then assert(hullIndex1 == hullIndex2, "CookingWithBeacons: expected destroyed hull entity with 2 loose end neighbours to be from the same hull.") end
            if isLooseEnd1 and isLooseEnd2 then
                concaveHull1.looseEnd1 = entity1
                concaveHull1.looseEnd2 = nil
                concaveHull1.entities = {entity1}
                table.insert(global.concave_beacon_shapes.incompleteHulls, {looseEnd1=entity2, entities={entity2}})
            elseif (isLooseEnd1 and (not isLooseEnd2)) or ((not isLooseEnd1) and isLooseEnd2) then
                local hullToKeep
                local notLooseEntity
                local looseEntity
                local isSideA
                if isLooseEnd1 and not isLooseEnd2 then
                    hullToKeep = concaveHull1                    
                    notLooseEntity = entity2
                    looseEntity = entity1
                    isSideA = isSideA1
                else
                    hullToKeep = concaveHull2
                    notLooseEntity = entity1
                    looseEntity = entity2
                    isSideA = isSideA2
                end
                if isSideA then
                    hullToKeep.looseEnd1 = notLooseEntity                
                    table.remove(hullToKeep.entities, 1)
                    table.remove(hullToKeep.entities, 1)
                    table.insert(global.concave_beacon_shapes.incompleteHulls, {looseEnd1=looseEntity, entities={looseEntity}})                    
                else
                    hullToKeep.looseEnd2 = notLooseEntity
                    table.remove(hullToKeep.entities)
                    table.remove(hullToKeep.entities)
                    table.insert(global.concave_beacon_shapes.incompleteHulls, {looseEnd1=looseEntity, entities={looseEntity}})                    
                end
            else --not isLooseEnd1 and not isLooseEnd2
                --still 2 possibilities: either this was a complete hull, or the hull ends are further away.
                --search through incomplete hulls first.
                local foundInIncompleteHulls = false
                local foundHullIndex
                local foundEntityIndex
                for hullIndex, incompleteHull in pairs(global.concave_beacon_shapes.incompleteHulls) do
                    for entityIndex, e in pairs(incompleteHull.entities) do 
                        if e == entity then 
                            foundInIncompleteHulls = true 
                            foundHullIndex = hullIndex
                            foundEntityIndex = entityIndex
                            break 
                        end
                    end
                    if foundInIncompleteHulls then break end
                end
                if foundInIncompleteHulls then
                    local concaveHull1 = global.concave_beacon_shapes.incompleteHulls[foundHullIndex]
                    local concaveHull2 = {entities={}}
                    concaveHull2.looseEnd2 = concaveHull1.looseEnd2
                    concaveHull1.looseEnd2 = concaveHull1.entities[foundEntityIndex-1]
                    concaveHull2.looseEnd1 = concaveHull1.entities[foundEntityIndex+1]
                    for i = foundEntityIndex + 1, #concaveHull1.entities do table.insert(concaveHull2.entities, concaveHull1.entities[i]) end
                    local newEntities = {}
                    for i = 1, foundEntityIndex - 1 do table.insert(newEntities, concaveHull1.entities[i]) end
                    concaveHull1.entities = newEntities
                    table.insert(global.concave_beacon_shapes.incompleteHulls, concaveHull2)     
                else
                    --should be a complete hull which needs to be broken
                    local foundInCompleteHulls = false
                    local foundCompleteHullIndex
                    local foundCompleteHullEntityIndex
                    for completeHullIndex, completeHull in pairs(global.concave_beacon_shapes.completeHulls) do
                        for entityIndex, e in pairs(completeHull.hullEntities) do
                            if e == entity then
                                foundInCompleteHulls = true
                                foundCompleteHullIndex = completeHullIndex
                                foundCompleteHullEntityIndex = entityIndex
                            end
                        end
                    end
                    assert(foundInCompleteHulls, "CookingWithBeacons: did not find entity in complete hulls either; this is unexpected")
                    if foundInCompleteHulls then
                        local completeHull = global.concave_beacon_shapes.completeHulls[foundCompleteHullIndex]
                        
                        for _, e in pairs(completeHull.containedEntities) do
                            if e.valid then
                                local foundHullIndex = nil
                                for hi, h in pairs(global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number]) do
                                    if h == completeHull then
                                        foundHullIndex = hi
                                    end
                                end
                                assert(foundHullIndex, "CookingWithBeacons: expected to find hull index to remove hull reference")
                                table.remove(global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number], foundHullIndex)
                            end
                        end
                        local beaconsToRecalculatePower = {}
                        for _, e in pairs(completeHull.containedBeacons) do
                            if e.valid then
                                local foundHullIndex = nil
                                for hi, h in pairs(global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number]) do
                                    if h == completeHull then
                                        foundHullIndex = hi
                                    end
                                end
                                assert(foundHullIndex, "CookingWithBeacons: expected to find hull index to remove hull reference")
                                table.remove(global.concave_beacon_shapes.mapEntityToListOfHulls[e.unit_number], foundHullIndex)
                                                                
                                if global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[e.unit_number] then
                                    for _, affectedEntity in pairs(global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[e.unit_number]) do
                                        if affectedEntity and affectedEntity.valid then
                                            local newListOfAffectingBeaconsAndStrength = {}
                                            for _, correspondingBeaconAndStrength in pairs(global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[affectedEntity.unit_number]) do
                                                if correspondingBeaconAndStrength.entity ~= e then table.insert(newListOfAffectingBeaconsAndStrength, correspondingBeaconAndStrength) end
                                            end
                                            global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[affectedEntity.unit_number] = newListOfAffectingBeaconsAndStrength
                                            updateBonusOfAffectedEntity(affectedEntity)
                                            reapplyAllHiddenBeaconEffects(affectedEntity)
                                        end
                                    end
                                end
                                global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[e.unit_number] = {}
                                if isABeaconWithConcaveHull(e) then
                                    table.insert(beaconsToRecalculatePower, e)
                                end
                            end
                        end
                        
                        local entities = {}
                        if foundCompleteHullEntityIndex > 1 and foundCompleteHullEntityIndex < #completeHull.hullEntities then
                            for i = foundCompleteHullEntityIndex + 1, #completeHull.hullEntities do table.insert(entities, completeHull.hullEntities[i]) end
                            for i = 1, foundCompleteHullEntityIndex - 1 do table.insert(entities, completeHull.hullEntities[i]) end
                            table.insert(global.concave_beacon_shapes.incompleteHulls, {looseEnd1=entities[1], looseEnd2=entities[#entities], entities=entities})
                        elseif foundCompleteHullEntityIndex == 1 then
                            entities = completeHull.hullEntities
                            table.remove(entities, 1)
                            table.insert(global.concave_beacon_shapes.incompleteHulls, {looseEnd1=entities[1], looseEnd2=entities[#entities], entities=entities})
                        else --foundCompleteHullEntityIndex == #completeHull.hullEntities
                            entities = completeHull.hullEntities
                            table.remove(entities)
                            table.insert(global.concave_beacon_shapes.incompleteHulls, {looseEnd1=entities[1], looseEnd2=entities[#entities], entities=entities})
                        end                        
                        table.remove(global.concave_beacon_shapes.completeHulls, foundCompleteHullIndex)
                        
                        for _, e in pairs(beaconsToRecalculatePower) do
                            recalculateBeaconPowerConsumption(e)
                        end
                    end
                end
            end
        else
            error('CookingWithBeacons: did not expect to find 3 or 4 neighbors on destruction of concave hull entity as entity construction should have been rejected.')
        end
        
    end
    
    --next up: update beacons and affected entities
    if not entity.unit_number then return end
    if global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number] then
        local hulls = global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number]
        for _, hull in pairs(hulls) do
            for entityIndex, e in pairs(hull.containedEntities) do
                if e == entity then
                    table.remove(hull.containedEntities, entityIndex)
                    break
                end
            end
            for beaconIndex, e in pairs(hull.containedBeacons) do
                if e == entity then
                    table.remove(hull.containedBeacons, beaconIndex)
                    break
                end
            end
        end
        global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number] = nil
    end
    if global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number] then
        for _, affectedEntity in pairs(global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number]) do
            if affectedEntity and affectedEntity.valid then
                local newListOfAffectingBeaconsAndStrength = {}
                for _, correspondingBeaconAndStrength in pairs(global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[affectedEntity.unit_number]) do
                    if correspondingBeaconAndStrength.entity ~= entity then table.insert(newListOfAffectingBeaconsAndStrength, correspondingBeaconAndStrength) end
                end
                global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[affectedEntity.unit_number] = newListOfAffectingBeaconsAndStrength
                updateBonusOfAffectedEntity(affectedEntity)
                reapplyAllHiddenBeaconEffects(affectedEntity)
            end
        end
    end
    global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number] = nil
    if global.concave_beacon_shapes.map_entity_unit_number_to_consumer[entity.unit_number] then
        local consumer = global.concave_beacon_shapes.map_entity_unit_number_to_consumer[entity.unit_number]
        consumer.destroy()
        global.concave_beacon_shapes.map_entity_unit_number_to_consumer[entity.unit_number] = nil
    end
    
    if global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number] then
        for _, affectingBeaconAndStrength in pairs(global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number]) do
            if affectingBeaconAndStrength.entity and affectingBeaconAndStrength.entity.valid then
                local newListOfAffectedEntities = {}
                for _, affectedEntity in pairs(global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[affectingBeaconAndStrength.entity.unit_number]) do
                    if affectedEntity ~= entity then table.insert(newListOfAffectedEntities, affectedEntity) end
                end
                global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[affectingBeaconAndStrength.entity.unit_number] = newListOfAffectedEntities
            end
        end
    end
    global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons[entity.unit_number] = nil

    if global.concave_beacon_shapes.map_beacon_name_to_beacon_entities[entity.name] then
        local newEntityList = {}
        for _, listEntry in pairs(global.concave_beacon_shapes.map_beacon_name_to_beacon_entities[entity.name]) do
            if listEntry ~= entity then table.insert(newEntityList,listEntry) end
        end
        global.concave_beacon_shapes.map_beacon_name_to_beacon_entities[entity.name] = newEntityList
    end
    --no removal from
    --global.concave_beacon_shapes.slow_update_queue
    --global.concave_beacon_shapes.slow_update_queue_2
    --global.concave_beacon_shapes.fast_update_queue
    --global.concave_beacon_shapes.fast_update_queue_2
    --this will happen automatically during customBeaconShapes_on_nth_tick_60 once the removed beacon is tried to be updated (by not flipping it into the other buffer)
end

function concaveHullBeaconShapes_on_nth_tick_60(event)
    for entityName, timeDependentTransmission in pairs(global.concave_beacon_shapes.timeDependentTransmission) do
        local currentIndex = timeDependentTransmission(game.tick)
        if currentIndex ~= global.concave_beacon_shapes.active_timeDependentTransmission[entityName] then
            global.concave_beacon_shapes.active_timeDependentTransmission[entityName] = currentIndex
            local entitiesToUpdate = {}
            if global.concave_beacon_shapes.map_beacon_name_to_beacon_entities[entityName] then
                local hasInvalidBeaconEntities = false
                for _, beaconEntity in pairs(global.concave_beacon_shapes.map_beacon_name_to_beacon_entities[entityName]) do
                    if beaconEntity.valid then
                        for _, affectedEntity in pairs(global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[beaconEntity.unit_number]) do 
                            entitiesToUpdate[affectedEntity.unit_number] = affectedEntity
                        end
                    else
                        hasInvalidBeaconEntities = true
                    end
                end
                if hasInvalidBeaconEntities then
                    local newListOfBeacons = {}
                    for _, beaconEntity in pairs(global.concave_beacon_shapes.map_beacon_name_to_beacon_entities[entityName]) do
                        if beaconEntity.valid then table.insert(newListOfBeacons, beaconEntity) end
                    end
                    global.concave_beacon_shapes.map_beacon_name_to_beacon_entities[entityName] = newListOfBeacons
                end
                for _, entityToUpdate in pairs(entitiesToUpdate) do
                    --table.insert(global.concave_beacon_shapes.affected_entities_to_recheck, entityToUpdate)
                    updateBonusOfAffectedEntity(entityToUpdate)
                    reapplyAllHiddenBeaconEffects(entityToUpdate)
                end
            end
        end
    end

    if #global.concave_beacon_shapes.affected_entities_to_recheck > 0 then
        local entity = table.remove(global.concave_beacon_shapes.affected_entities_to_recheck)
        if entity and entity.valid then
            updateBonusOfAffectedEntity(entity)
            reapplyAllHiddenBeaconEffects(entity)
        end
        return
    end

    if #global.concave_beacon_shapes.slow_update_queue > 0 then
        local entity = table.remove(global.concave_beacon_shapes.slow_update_queue)
        if entity and entity.valid then
            for _, affectedEntity in pairs(global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number]) do 
                table.insert(global.concave_beacon_shapes.affected_entities_to_recheck, affectedEntity) 
            end
            if beaconIsFullyLoaded(entity) then
                table.insert(global.concave_beacon_shapes.slow_update_queue_2, entity)
            else
                table.insert(global.concave_beacon_shapes.fast_update_queue_2, entity)            
            end
        end
    else
        global.concave_beacon_shapes.slow_update_queue = global.concave_beacon_shapes.slow_update_queue_2
        global.concave_beacon_shapes.slow_update_queue_2 = {}
    end
    
    if #global.concave_beacon_shapes.fast_update_queue > 0 then
        local entity = table.remove(global.concave_beacon_shapes.fast_update_queue)
        if entity and entity.valid then
            for _, affectedEntity in pairs(global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities[entity.unit_number]) do 
                table.insert(global.concave_beacon_shapes.affected_entities_to_recheck, affectedEntity) 
            end
            if beaconIsFullyLoaded(entity) then
                table.insert(global.concave_beacon_shapes.slow_update_queue_2, entity)
            else
                table.insert(global.concave_beacon_shapes.fast_update_queue_2, entity)            
            end
        end
    else
        global.concave_beacon_shapes.fast_update_queue = global.concave_beacon_shapes.fast_update_queue_2
        global.concave_beacon_shapes.fast_update_queue_2 = {}
    end
end

local function highlightBeaconEntity(entity, player_index)

    local newEntities = {}
    if entity and isABeaconWithConcaveHull(entity) then
    
        if global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number] then
            local hulls = global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number]
            for _, hull in pairs(hulls) do
                for _, position in pairs(hull.floodedPositionsWithinHull) do
                    local newEntity = entity.surface.create_entity{name = "concave-hull-beacon-radius-visualization", position = {position.x, position.y}, render_player_index=player_index}
                    newEntity.destructible = false
                    newEntity.minable = false
                    table.insert(newEntities, newEntity)
                end
            end
        end
    end
    return newEntities
    
end

local function highlightEntitiesAffectedByConcaveHullBeacon(entity, player_index)
    local newEntities = {}
    if entity and isABeaconWithConcaveHull(entity) then
        local affectedEntitiesAndStrength = getEntitiesWhichAreAffectedByBeacon(entity)
        for _, affectedEntityAndStrength in pairs(affectedEntitiesAndStrength) do
            if affectedEntityAndStrength.entity.selection_box then 
                table.insert(newEntities, affectedEntityAndStrength.entity.surface.create_entity{name="highlight-box", bounding_box=affectedEntityAndStrength.entity.selection_box, position = {0,0}, blink_interval=0, box_type="train-visualization"})
            end
        end
    end
    return newEntities
end

function concaveHullBeaconShapes_on_selected_entity_changed(event)
    --player_index :: uint: The player whose selected entity changed.
    --last_entity :: LuaEntity (optional): The last selected entity if it still exists and there was one.
    if global.concave_beacon_shapes.range_visualization[event.player_index] then
        for _, entity in pairs(global.concave_beacon_shapes.range_visualization[event.player_index]) do entity.destroy() end
    end
    local player = game.players[event.player_index]
    local selectedEntity = player.selected
    local newHighlightEntities = highlightBeaconEntity(selectedEntity, event.player_index)
    local additionalHighlightBoxes = highlightEntitiesAffectedByConcaveHullBeacon(selectedEntity, player_index)
    for _, e in pairs(additionalHighlightBoxes) do table.insert(newHighlightEntities, e) end
    global.concave_beacon_shapes.range_visualization[event.player_index] = newHighlightEntities
end

function concaveHullBeaconShapes_on_player_cursor_stack_changed(event)
    --player_index :: uint
    if global.concave_beacon_shapes.range_visualization_cursorItem[event.player_index] then
        for _, entity in pairs(global.concave_beacon_shapes.range_visualization_cursorItem[event.player_index]) do entity.destroy() end
    end
    global.concave_beacon_shapes.range_visualization_cursorItem[event.player_index] = {}
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
                    table.insert(global.concave_beacon_shapes.range_visualization_cursorItem[event.player_index], entity)
                end
            end
        end
    end
end