function enableFeatureForbiddenBeaconOverlap()

    if not global.forbidden_beacon_overlap.feature_enabled then
        global.forbidden_beacon_overlap.feature_enabled = true
        global.forbidden_beacon_overlap.overlap = {}
    end
end

function setForbiddenBeaconOverlapForEntity(args, args2)

    assert(global.forbidden_beacon_overlap.feature_enabled, "Library usage error set_forbidden_beacon_overlap_for_entity: feature was not enabled yet via enable_feature_forbidden_beacon_overlap().")

    assert(args, "Library usage error set_forbidden_beacon_overlap_for_entity: arguments are missing.")
    assert(type(args) == "table", "Library usage error set_forbidden_beacon_overlap_for_entity: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error set_forbidden_beacon_overlap_for_entity: too many arguments given. arguments have to be provided in a table as one argument.")

    local name = args.name
    args.name = nil
    local forbidden = args.forbidden
    args.forbidden = nil
    for k,_ in pairs(args) do error("Library usage error set_forbidden_beacon_overlap_for_entity: unsupported argument " .. k) end

    assert(name, "Library usage error set_forbidden_beacon_overlap_for_entity: name was not provided")
    assert(type(name) == "string", "Library usage error set_forbidden_beacon_overlap_for_entity: name was given but it is not a string but a " .. type(name))
    assert(global.forbidden_beacon_overlap.overlap[name] == nil, "Library usage error set_forbidden_beacon_overlap_for_entity: entity " .. name .. " already has a list of forbidden entities, setting it again is not possible.")
    assert(game.entity_prototypes[name], "Library usage error set_forbidden_beacon_overlap_for_entity: name was given but such an entity doesn't exist. name is: " .. name)
    assert(game.entity_prototypes[name].type == "beacon", "Library usage error set_forbidden_beacon_overlap_for_entity: name was given as " .. name .. " but it is not a beacon but a " .. game.entity_prototypes[name].type)

    assert(forbidden, "Library usage error set_forbidden_beacon_overlap_for_entity: forbidden was not provided for " .. name)
    assert(type(forbidden) == "table", "Library usage error set_forbidden_beacon_overlap_for_entity: forbidden was given but it is not a table but a " .. type(forbidden) .. " for " .. name)
    for k, v in pairs(forbidden) do 
        assert(type(v) == "string", "Library usage error set_forbidden_beacon_overlap_for_entity: forbidden did not consist of a table of strings for " .. name) 
        assert(game.entity_prototypes[v], "Library usage error set_forbidden_beacon_overlap_for_entity: the entity called " .. v .. " which may not overlap " .. name .. " doesn't exist")
        assert(game.entity_prototypes[v].type == "beacon", "Library usage error set_forbidden_beacon_overlap_for_entity: the entity called " .. v .. " which may not overlap " .. name .. " is not a beacon but a " .. game.entity_prototypes[v].type)
    end
    
    global.forbidden_beacon_overlap.overlap[name] = forbidden
end

local function getAreaAffectedByRegularBeacon(beaconEntityName)
    local prototype = game.entity_prototypes[beaconEntityName]
    local collision_box = prototype.collision_box or zeroBox()
    local distance = prototype.supply_area_distance or 0
    return {
        left_top=    {x=collision_box.left_top.x - distance,     y=collision_box.left_top.y - distance},
        right_bottom={x=collision_box.right_bottom.x + distance, y=collision_box.right_bottom.y + distance}
    }
end

local function getAreaToSearchPotentialBeacons(box1, box2)
    return {
        left_top=    {x=box1.left_top.x + box2.left_top.x,         y=box1.left_top.y + box2.left_top.y},
        right_bottom={x=box1.right_bottom.x + box2.right_bottom.x, y=box1.right_bottom.y + box2.right_bottom.y}
    }
end

function customShapedBeaconOverlapsAnotherCustomShapedBeacon(beaconEntity1, beaconEntity2)
        
    local positionLookupMap = {}
        
    local beaconShape1 = global.custom_beacon_shapes.shapes[beaconEntity1.name]
    local beaconShape2 = global.custom_beacon_shapes.shapes[beaconEntity2.name]
    local relativeEntityPositionInBeaconShape1 = global.custom_beacon_shapes.entityPositionInShape[beaconEntity1.name]
    local relativeEntityPositionInBeaconShape2 = global.custom_beacon_shapes.entityPositionInShape[beaconEntity2.name]
    local beaconBoundingBox1 = shiftArea(global.custom_beacon_shapes.boundingBox[beaconEntity1.name], beaconEntity1.position)
    local beaconBoundingBox2 = shiftArea(global.custom_beacon_shapes.boundingBox[beaconEntity2.name], beaconEntity1.position)
    
    for _, gridPosition in pairs(getGridOfPositionsInsideBox(beaconBoundingBox1)) do
    
        local xIndex = math.floor(relativeEntityPositionInBeaconShape1.x - (beaconEntity1.position.x - gridPosition.x) + 0.5)
        local yIndex = math.floor(relativeEntityPositionInBeaconShape1.y - (beaconEntity1.position.y - gridPosition.y) + 0.5) 
        
        --check if the position is inside the affected area
        if 1 <= yIndex and yIndex <= #beaconShape1 and 1 <= xIndex and xIndex <= #beaconShape1[yIndex] then            
            
            local customShapeLetter = string.sub(beaconShape1[yIndex],xIndex,xIndex)
            if customShapeLetter == "X" or customShapeLetter == "E" then
                if not positionLookupMap[gridPosition.x] then positionLookupMap[gridPosition.x]  = {} end
                positionLookupMap[gridPosition.x][gridPosition.y] = true
            end
        end
    end
    for _, gridPosition in pairs(getGridOfPositionsInsideBox(beaconBoundingBox2)) do
    
        local xIndex = math.floor(relativeEntityPositionInBeaconShape2.x - (beaconEntity2.position.x - gridPosition.x) + 0.5)
        local yIndex = math.floor(relativeEntityPositionInBeaconShape2.y - (beaconEntity2.position.y - gridPosition.y) + 0.5) 
        
        --check if the position is inside the affected area
        if 1 <= yIndex and yIndex <= #beaconShape2 and 1 <= xIndex and xIndex <= #beaconShape2[yIndex] then            
            
            local customShapeLetter = string.sub(beaconShape2[yIndex],xIndex,xIndex)
            if customShapeLetter == "X" or customShapeLetter == "E" then
                if positionLookupMap[gridPosition.x] and positionLookupMap[gridPosition.x][gridPosition.y] then return true end
            end
        end
    end
    
    return false
end

local function twoConcaveHullBeaconsInSameHull(beaconEntity1, beaconEntity2)
    if not global.concave_beacon_shapes.mapEntityToListOfHulls[beaconEntity1.unit_number] then return false end
    if not global.concave_beacon_shapes.mapEntityToListOfHulls[beaconEntity2.unit_number] then return false end
    for _, hull1 in pairs(global.concave_beacon_shapes.mapEntityToListOfHulls[beaconEntity1.unit_number]) do
        for _, hull2 in pairs(global.concave_beacon_shapes.mapEntityToListOfHulls[beaconEntity2.unit_number]) do
            if hull1 == hull2 then return true end
        end
    end
    return false
end

local function concaveHullBeaconOverlapsCustomBeacon(entity, candidate, shiftedOtherBeaconBox)
    if not global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number] then return false end
    
    local beaconShape = global.custom_beacon_shapes.shapes[candidate.name]
    local relativeEntityPositionInBeaconShape = global.custom_beacon_shapes.entityPositionInShape[candidate.name]
    
    for _, hull in pairs(global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number]) do
        if boundingBoxesOverlap(hull.boundingBox, shiftedOtherBeaconBox) then
            for _, pos in pairs(hull.floodedPositionsWithinHull) do
        
                local xIndex = math.floor(relativeEntityPositionInBeaconShape.x - (candidate.position.x - pos.x) + 0.5)
                local yIndex = math.floor(relativeEntityPositionInBeaconShape.y - (candidate.position.y - pos.y) + 0.5) 
                
                --check if the position is inside the affected area
                if 1 <= yIndex and yIndex <= #beaconShape and 1 <= xIndex and xIndex <= #beaconShape[yIndex] then            
                    
                    local customShapeLetter = string.sub(beaconShape[yIndex],xIndex,xIndex)
                    if customShapeLetter == "X" or customShapeLetter == "E" then return true end
                end
            end
        end
    end
    return false

end

local function concaveHullBeaconOverlapsRegularBeacon(entity, shiftedOtherBeaconBox)
    if not global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number] then return false end
    for _, hull in pairs(global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number]) do
        if boundingBoxesOverlap(hull.boundingBox, shiftedOtherBeaconBox) then
            for _, pos in pairs(hull.floodedPositionsWithinHull) do
                if positionIsInBoundingBox(pos, shiftedOtherBeaconBox) then return true end
            end
        end
    end
    return false
end

function forbiddenBeaconOverlap_on_built(entity)
    if entity.type == "wall" or entity.type == "gate" and global.forbidden_beacon_overlap.overlap[entity.name] then
        for _, hull in pairs(global.concave_beacon_shapes.completeHulls) do
            --only perform a rough check rather than checking detailed if this wall piece finished a hull - the details are checked during forbiddenBeaconOverlap_on_built anyway.
            if positionIsInBoundingBox(entity.position, hull.boundingBox) then
                for _, beaconEntity in pairs(hull.containedBeacons) do forbiddenBeaconOverlap_on_built(beaconEntity) end
            end
        end
    end
    if entity.type == "beacon" and global.forbidden_beacon_overlap.overlap[entity.name] then
        
        local overlappingForbiddenBeacons = {}
        
        local ownBeaconBox
        local selfType
        if isABeaconWithCustomShape(entity) then
            ownBeaconBox = global.custom_beacon_shapes.boundingBox[entity.name]
            selfType = "custom-beacon"
        elseif isABeaconWithConcaveHull({type="beacon", name=entity.name}) then
            --todo also consider that the wall may be placed afterwards to complete the beacon!
            if global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number] then
                local hulls = global.concave_beacon_shapes.mapEntityToListOfHulls[entity.unit_number]
                for _, hull in pairs(hulls) do
                    if not ownBeaconBox then 
                        ownBeaconBox = hull.boundingBox
                    else
                        ownBeaconBox = mergeBoundingBoxes(ownBeaconBox, hull.boundingBox)
                    end
                end
            end
            if not ownBeaconBox then return end --entity hull was not yet present - in that case it cannot conflict yet
            --box is absolute but rest of the code is working with relative boxes -> convert
            ownBeaconBox = {
                left_top={x=ownBeaconBox.left_top.x - entity.position.x, y=ownBeaconBox.left_top.y - entity.position.y}, 
                right_bottom={x=ownBeaconBox.right_bottom.x - entity.position.x, y=ownBeaconBox.right_bottom.y - entity.position.y}
            }
            selfType = "concave-hull-beacon"
        else
            ownBeaconBox = getAreaAffectedByRegularBeacon(entity.name)
            selfType = "regular-beacon"
        end
        
        for _, entityName in pairs(global.forbidden_beacon_overlap.overlap[entity.name]) do
            local otherBeaconBox
            local otherType
            if isABeaconWithCustomShape({type="beacon", name=entityName}) then
                otherBeaconBox = global.custom_beacon_shapes.boundingBox[entityName]
                otherType = "custom-beacon"
            elseif isABeaconWithConcaveHull({type="beacon", name=entityName}) then
                --todo also consider that the wall may be placed afterwards to complete the beacon!
                --do not set otherBeaconBox as each beacon has its own box so it can't be pre-calculated
                otherType = "concave-hull-beacon"
            else
                otherBeaconBox = getAreaAffectedByRegularBeacon(entityName)
                otherType = "regular-beacon"
            end
            local candidates = {}
            if otherType == "concave-hull-beacon" then
                for _, hull in pairs(global.concave_beacon_shapes.completeHulls) do
                    for _, beacon in pairs(hull.containedBeacons) do
                        if beacon.name == entityName then
                            table.insert(candidates, beacon)
                        end
                    end
                end
            else
                local relativeAreaToSearch = getAreaToSearchPotentialBeacons(ownBeaconBox, otherBeaconBox)
                local absoluteAreaToSearch = shiftArea(relativeAreaToSearch, entity.position)
                candidates = entity.surface.find_entities_filtered{
                    type="beacon", 
                    name=entityName, 
                    area = absoluteAreaToSearch}
            end
            for _, candidate in pairs(candidates) do
                if candidate ~= entity then
                    if selfType == "regular-beacon" and otherType == "regular-beacon" then
                        if boundingBoxesOverlap(shiftArea(ownBeaconBox, entity.position), shiftArea(otherBeaconBox, candidate.position)) then
                            table.insert(overlappingForbiddenBeacons, candidate)
                        end
                    elseif (selfType == "regular-beacon" and otherType == "custom-beacon") or (selfType == "custom-beacon" and otherType == "regular-beacon") then
                        local overlap
                        if selfType == "custom-beacon" then
                            overlap = customShapedBeaconAffectsEntity(entity, {bounding_box=(shiftArea(otherBeaconBox, candidate.position))}, false)
                        else
                            overlap = customShapedBeaconAffectsEntity(candidate, {bounding_box=(shiftArea(ownBeaconBox, entity.position))}, false)
                        end
                        if overlap then
                            table.insert(overlappingForbiddenBeacons, candidate)
                        end
                    elseif selfType == "custom-beacon" and otherType == "custom-beacon" then
                        if customShapedBeaconOverlapsAnotherCustomShapedBeacon(entity, candidate) then
                            table.insert(overlappingForbiddenBeacons, candidate)
                        end
                    elseif selfType == "concave-hull-beacon" and otherType == "concave-hull-beacon" then
                        if twoConcaveHullBeaconsInSameHull(entity, candidate) then
                            table.insert(overlappingForbiddenBeacons, candidate)
                        end
                    elseif (selfType == "concave-hull-beacon" and otherType == "custom-beacon") or (selfType == "custom-beacon" and otherType == "concave-hull-beacon") then
                        if selfType == "concave-hull-beacon" then
                            if concaveHullBeaconOverlapsCustomBeacon(entity, candidate, shiftArea(otherBeaconBox, candidate.position)) then 
                                table.insert(overlappingForbiddenBeacons, candidate)
                            end
                        else
                            if concaveHullBeaconOverlapsCustomBeacon(candidate, entity, shiftArea(ownBeaconBox, entity.position)) then 
                                table.insert(overlappingForbiddenBeacons, candidate)
                            end
                        end
                    elseif  (selfType == "concave-hull-beacon" and otherType == "regular-beacon") or (selfType == "regular-beacon" and otherType == "concave-hull-beacon") then
                        if selfType == "concave-hull-beacon" then
                            if concaveHullBeaconOverlapsRegularBeacon(entity, candidate) then 
                                table.insert(overlappingForbiddenBeacons, candidate)
                            end
                        else
                            if concaveHullBeaconOverlapsRegularBeacon(candidate, shiftArea(otherBeaconBox, candidate.position)) then 
                                table.insert(overlappingForbiddenBeacons, candidate)
                            end
                        end
                    else
                        error("unexpected permutation: selfType: " .. selfType .. " vs otherType: " .. otherType )
                    end
                end
            end
            ::continue::
        end
        if #overlappingForbiddenBeacons > 0 then
            --do visualizations
            entity.surface.create_entity{name="flying-text", position = entity.position, text={"ingame-error-messages.beacon-overlap-forbidden"}}
            if entity.bounding_box then entity.surface.create_entity{name="highlight-box", bounding_box=entity.bounding_box, position = {0,0}, time_to_live=300, blink_interval=30, box_type="not-allowed"} end
            for _, otherBeacon in pairs(overlappingForbiddenBeacons) do 
                if otherBeacon.valid then 
                    if otherBeacon.bounding_box then otherBeacon.surface.create_entity{name="highlight-box", bounding_box=otherBeacon.bounding_box, position = {0,0}, time_to_live=300, blink_interval=30, box_type="not-allowed"} end
                    otherBeacon.surface.create_entity{name="laser-beam", position = {0,0}, target=entity, source=otherBeacon}
                end 
            end

            --destroy forbidden entities
            entity.die()
            for _, otherBeacon in pairs(overlappingForbiddenBeacons) do 
                if otherBeacon.valid then 
                    otherBeacon.die() 
                end 
            end
        end
    end
end
