--[[
credits:

factorio devs

--]]

local function init_globals()
    
    global.version = "0.1.1"
    
end

script.on_init(function()
    init_globals()
end)

local function updateModVersion()

end

script.on_configuration_changed(function()
    updateModVersion()
end)

local function getIncompleteHulls()
    return remote.call("CookingWithBeaconsLib", "run_maintainance_script", "return global.concave_beacon_shapes.incompleteHulls")
end

local function getCompleteHulls()
    return remote.call("CookingWithBeaconsLib", "run_maintainance_script", "return global.concave_beacon_shapes.completeHulls")
end

local function get_map_beacon_unit_number_to_affected_entities()
    return remote.call("CookingWithBeaconsLib", "run_maintainance_script", "return global.concave_beacon_shapes.map_beacon_unit_number_to_affected_entities")
end

local function get_map_entity_unit_number_to_custom_shaped_beacons()
    return remote.call("CookingWithBeaconsLib", "run_maintainance_script", "return global.concave_beacon_shapes.map_entity_unit_number_to_custom_shaped_beacons")
end

local function assertIncompleteHullsEmpty()
    local incompleteHulls = getIncompleteHulls()
    assert(#incompleteHulls == 0, "incomplete hull wasn't empty")
end

local function assertCompleteHullsEmpty()
    local completeHulls = getCompleteHulls()
    assert(#completeHulls == 0, "complete hull wasn't empty")
end

local function assertIncompleteHullsEqual(expected)
    local incompleteHulls = getIncompleteHulls()
    assert(#incompleteHulls == #expected)
    for k,v in pairs(expected) do
        assert(incompleteHulls[k] ~= nil)
        assert(v.looseEnd1 == incompleteHulls[k].looseEnd1)
        assert(v.looseEnd2 == incompleteHulls[k].looseEnd2)
        assert(#v.entities == #incompleteHulls[k].entities)
        for i = 1,#v.entities do 
            assert(v.entities[i] == incompleteHulls[k].entities[i]) 
        end
    end
end

local function assertCompleteHullsEqual(expected)
    local completeHulls = getCompleteHulls()
    assert(#completeHulls == #expected)
    for k,v in pairs(expected) do
        assert(completeHulls[k] ~= nil)
        assert(#v.hullEntities == #completeHulls[k].hullEntities)
        for i = 1,#v.hullEntities do 
            assert(v.hullEntities[i] == completeHulls[k].hullEntities[i]) 
        end
    end
end

local function placeEntitiesInPattern(pattern, basePosition, entityNames)
    local result = {}
    for yIndex, str in pairs(pattern) do
        xIndex = 0
        for c in string.gmatch(str,".") do
            xIndex = xIndex + 1
            local entityName = entityNames[c]
            if entityName then
                local newEntity = game.surfaces["nauvis"].create_entity{name=entityName, position = {basePosition.x+xIndex-1, basePosition.y+yIndex-1}, force="player", raise_built=true}
                assert(newEntity)
                if not result[c] then result[c] = {} end
                table.insert(result[c], newEntity)
            end
        end
    end
    for _,v in pairs(result) do
        for _,v2 in pairs(v) do
            assert(v2)
            assert(v2.valid)
        end
    end
    return result
end

local function doFullCleanup()
    local tmp = game.surfaces["nauvis"].find_entities_filtered{name={"concrete-energy-field","blue-beacon-mk2","electric-mining-drill"}}
    for _, e in pairs(tmp) do e.die() end
    assertCompleteHullsEmpty()
    assertIncompleteHullsEmpty()
    local tmp = get_map_beacon_unit_number_to_affected_entities()
    local tmp2 = get_map_entity_unit_number_to_custom_shaped_beacons()
    assert(#tmp == 0)
    assert(#tmp2 == 0)
end

script.on_event(defines.events.on_tick, function(event)

    local enabled = true
    if event.tick == 0 and enabled then
  
        local force="player"
        local x = 3
        local y = 3
        
        local tmp = game.surfaces["nauvis"].find_entities_filtered{area={
            left_top=    {x=x-80, y=y-80},
            right_bottom={x=x+80, y=y+80}
        }}
        for _, e in pairs(tmp) do if e.type ~= "character" then e.die() end end
        
        
        --single entity
        assertIncompleteHullsEmpty()
        local entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        assertIncompleteHullsEqual({{looseEnd1=entity1, entities={entity1}}})
        entity1.die()
        assertIncompleteHullsEmpty()

        --not a neighbor entity
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        local entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        assertIncompleteHullsEqual({
            {looseEnd1=entity1, entities={entity1}},
            {looseEnd1=entity2, entities={entity2}},
        })
        entity2.die()
        entity1.die()
        assertIncompleteHullsEmpty()
        
        --1 neighbor entity, neighbor is single a loose entity
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        assertIncompleteHullsEqual({{looseEnd1=entity1,looseEnd2=entity2, entities={entity1,entity2}}})
        entity2.die()
        assertIncompleteHullsEqual({{looseEnd1=entity1, entities={entity1}}})
        entity1.die()
        assertIncompleteHullsEmpty()

        --1 neighbor entity, neighbor is a loose entity of a hull, side a
        assertIncompleteHullsEmpty()
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        local entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        assertIncompleteHullsEqual({{looseEnd1=entity3,looseEnd2=entity1, entities={entity3,entity2,entity1}}})
        entity3.die()
        assertIncompleteHullsEqual({{looseEnd1=entity2,looseEnd2=entity1, entities={entity2,entity1}}})
        entity1.die()
        entity2.die()
        assertIncompleteHullsEmpty()
        
        --1 neighbor entity, neighbor is a loose entity of a hull, side b
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        assertIncompleteHullsEqual({{looseEnd1=entity1,looseEnd2=entity3, entities={entity1,entity2,entity3}}})
        entity3.die()
        assertIncompleteHullsEqual({{looseEnd1=entity1,looseEnd2=entity2, entities={entity1,entity2}}})
        entity2.die()
        entity1.die()
        assertIncompleteHullsEmpty()
        
        --1 neighbor entity, neighbor is not a loose entity. expect entity destruction.
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y-1}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y+1}, force=force, raise_built=true}
        local entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        assert(not entity4 or not entity4.valid)
        assertIncompleteHullsEqual({{looseEnd1=entity1,looseEnd2=entity3, entities={entity1,entity2,entity3}}})
        entity3.die()
        entity2.die()
        entity1.die()
        assertIncompleteHullsEmpty()
        
        --2 neighbor entities, both are singular loose ends
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        assertIncompleteHullsEqual({{looseEnd1=entity1,looseEnd2=entity3, entities={entity1,entity2,entity3}}})
        entity2.die()
        assertIncompleteHullsEqual({
            {looseEnd1=entity1, entities={entity1}},
            {looseEnd1=entity3, entities={entity3}},
        })
        entity3.die()
        entity1.die()
        assertIncompleteHullsEmpty()

        --2 neighbor entities, side b + side a
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+3,y}, force=force, raise_built=true}
        local entity5 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+4,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        assertIncompleteHullsEqual({{looseEnd1=entity1,looseEnd2=entity5, entities={entity1,entity2,entity3,entity4,entity5}}})
        entity3.die()
        assertIncompleteHullsEqual({
            {looseEnd1=entity1,looseEnd2=entity2, entities={entity1,entity2}},
            {looseEnd1=entity4,looseEnd2=entity5, entities={entity4,entity5}},
        })
        entity5.die()
        entity4.die()
        entity2.die()
        entity1.die()
        assertIncompleteHullsEmpty()
        
        --2 neighbor entities, side a + side a
        assertIncompleteHullsEmpty()
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+3,y}, force=force, raise_built=true}
        entity5 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+4,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        assertIncompleteHullsEqual({{looseEnd1=entity1,looseEnd2=entity5, entities={entity1,entity2,entity3,entity4,entity5}}})
        entity3.die()
        assertIncompleteHullsEqual({
            {looseEnd1=entity1,looseEnd2=entity2, entities={entity1,entity2}},
            {looseEnd1=entity4,looseEnd2=entity5, entities={entity4,entity5}},
        })
        entity5.die()
        entity4.die()
        entity2.die()
        entity1.die()
        assertIncompleteHullsEmpty()
        
        --2 neighbor entities, side b + side b
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        entity5 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+4,y}, force=force, raise_built=true}
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+3,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        local incompleteHulls = getIncompleteHulls()
        assertIncompleteHullsEqual({{looseEnd1=entity1,looseEnd2=entity5, entities={entity1,entity2,entity3,entity4,entity5}}})
        entity3.die()
        assertIncompleteHullsEqual({
            {looseEnd1=entity1,looseEnd2=entity2, entities={entity1,entity2}},
            {looseEnd1=entity4,looseEnd2=entity5, entities={entity4,entity5}},
        })
        entity4.die()
        entity5.die()
        entity2.die()
        entity1.die()
        assertIncompleteHullsEmpty()
        
        --2 neighbor entities, side a + side b
        assertIncompleteHullsEmpty()
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity5 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+4,y}, force=force, raise_built=true}
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+3,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        assertIncompleteHullsEqual({{looseEnd1=entity5,looseEnd2=entity1, entities={entity5,entity4,entity3,entity2,entity1}}})
        entity3.die()
        assertIncompleteHullsEqual({
            {looseEnd1=entity5,looseEnd2=entity4, entities={entity5,entity4}},
            {looseEnd1=entity2,looseEnd2=entity1, entities={entity2,entity1}},
        })
        entity4.die()
        entity5.die()
        entity1.die()
        entity2.die()
        assertIncompleteHullsEmpty()
        
        --2 neighbor entities, finish the creation of a concave hull. test destruction of entity 1 of concave hull.
        --no complete hulls should have been formed up to this point
        assertCompleteHullsEmpty()
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y+1}, force=force, raise_built=true}
        entity5 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y+2}, force=force, raise_built=true}
        local entity6 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y+2}, force=force, raise_built=true}
        local entity7 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y+2}, force=force, raise_built=true}
        assertCompleteHullsEmpty()
        local entity8 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y+1}, force=force, raise_built=true}
        assertIncompleteHullsEmpty()
        assertCompleteHullsEqual({{hullEntities={entity1,entity2,entity3,entity4,entity5,entity6,entity7,entity8}}})
        entity1.die()
        assertCompleteHullsEmpty()
        assertIncompleteHullsEqual({{looseEnd1=entity2,looseEnd2=entity8, entities={entity2,entity3,entity4,entity5,entity6,entity7,entity8}}})
        entity8.die()
        entity7.die()
        entity6.die()
        entity5.die()
        entity4.die()
        entity3.die()
        entity2.die()
        assertIncompleteHullsEmpty()
        
        --2 neighbor entities, finish the creation of a concave hull. test destruction of entity in the middle of concave hull.
        assertCompleteHullsEmpty()
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y+1}, force=force, raise_built=true}
        entity5 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y+2}, force=force, raise_built=true}
        entity6 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y+2}, force=force, raise_built=true}
        entity7 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y+2}, force=force, raise_built=true}
        assertCompleteHullsEmpty()
        entity8 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y+1}, force=force, raise_built=true}
        assertIncompleteHullsEmpty()
        assertCompleteHullsEqual({{hullEntities={entity1,entity2,entity3,entity4,entity5,entity6,entity7,entity8}}})
        entity2.die()
        assertCompleteHullsEmpty()
        assertIncompleteHullsEqual({{looseEnd1=entity3,looseEnd2=entity1, entities={entity3,entity4,entity5,entity6,entity7,entity8,entity1}}})
        entity1.die()
        entity8.die()
        entity7.die()
        entity6.die()
        entity5.die()
        entity4.die()
        entity3.die()
        assertIncompleteHullsEmpty()
        
        --2 neighbor entities, finish the creation of a concave hull. test destruction of entity at the end of concave hull.
        assertCompleteHullsEmpty()
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y+1}, force=force, raise_built=true}
        entity5 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y+2}, force=force, raise_built=true}
        entity6 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y+2}, force=force, raise_built=true}
        entity7 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y+2}, force=force, raise_built=true}
        assertCompleteHullsEmpty()
        entity8 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y+1}, force=force, raise_built=true}
        assertIncompleteHullsEmpty()
        assertCompleteHullsEqual({{hullEntities={entity1,entity2,entity3,entity4,entity5,entity6,entity7,entity8}}})
        entity8.die()
        assertCompleteHullsEmpty()
        assertIncompleteHullsEqual({{looseEnd1=entity1,looseEnd2=entity7, entities={entity1,entity2,entity3,entity4,entity5,entity6,entity7}}})
        entity7.die()
        entity6.die()
        entity5.die()
        entity4.die()
        entity3.die()
        entity2.die()
        entity1.die()
        assertIncompleteHullsEmpty()
                                
        --3 neighbor entities, expect entity destruction.
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y-1}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        assert(not entity4 or not entity4.valid)
        assertIncompleteHullsEqual({
            {looseEnd1=entity1, entities={entity1}},
            {looseEnd1=entity2, entities={entity2}},
            {looseEnd1=entity3, entities={entity3}},
        })
        entity3.die()
        entity2.die()
        entity1.die()
        assertIncompleteHullsEmpty()
        
        --4 neighbor entities, expect entity destruction.
        assertIncompleteHullsEmpty()
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y-1}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y}, force=force, raise_built=true}
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y+1}, force=force, raise_built=true}
        local entity5 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+1,y}, force=force, raise_built=true}
        assert(not entity5 or not entity5.valid)
        assertIncompleteHullsEqual({
            {looseEnd1=entity1, entities={entity1}},
            {looseEnd1=entity2, entities={entity2}},
            {looseEnd1=entity3, entities={entity3}},
            {looseEnd1=entity4, entities={entity4}},
        })
        entity4.die()
        entity3.die()
        entity2.die()
        entity1.die()
        assertIncompleteHullsEmpty()
        
        --test destruction of 'hull inside hull' entities: present before forming hull
        placeEntitiesInPattern(
            {
                "XXXXXXX",
                "OOOOOOX",
                "XOOOOOX",
                "XOOOOOX",
                "XXXXXXX"
            },
            {x=x,y=y},
            {X="concrete-energy-field",Y="blue-beacon-mk2",Z="electric-mining-drill"})
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y+2}, force=force, raise_built=true}
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+3,y+2}, force=force, raise_built=true}
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+4,y+2}, force=force, raise_built=true}
        assert(entity1 and entity1.valid)
        assert(entity2 and entity2.valid)
        assert(entity3 and entity3.valid)
        entity4 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x,y+1}, force=force, raise_built=true}
        assert(not entity1 or not entity1.valid)
        assert(not entity2 or not entity2.valid)
        assert(not entity3 or not entity3.valid)
        assertIncompleteHullsEmpty()
        doFullCleanup()
        
        --test destruction of 'hull inside hull' entities: placing inside formed hull
        placeEntitiesInPattern(
            {
                "XXXXXXX",
                "XOOOOOX",
                "XOOOOOX",
                "XOOOOOX",
                "XXXXXXX"
            },
            {x=x,y=y},
            {X="concrete-energy-field",Y="blue-beacon-mk2",Z="electric-mining-drill"})
        entity1 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+2,y+2}, force=force, raise_built=true}
        assert(not entity1 or not entity1.valid)
        entity2 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+3,y+2}, force=force, raise_built=true}
        assert(not entity2 or not entity2.valid)
        entity3 = game.surfaces["nauvis"].create_entity{name="concrete-energy-field", position = {x+4,y+2}, force=force, raise_built=true}
        assert(not entity3 or not entity3.valid)
        assertIncompleteHullsEmpty()
        doFullCleanup()
        
        --test that finishing a hull links beacons and affected entities together
        tmp = placeEntitiesInPattern(
            {
                "XXXXXXXXX",
                "XOOOOOOOX",
                "XOYOOOZOX",
                "XOOOOOOOX",
                "XXXXXXXXX"
            },
            {x=x,y=y},
            {X="concrete-energy-field",Y="blue-beacon-mk2",Z="electric-mining-drill"})
        entity1 = tmp.Y[1]
        entity2 = tmp.Z[1]
        tmp = get_map_beacon_unit_number_to_affected_entities()
        local tmp2 = get_map_entity_unit_number_to_custom_shaped_beacons()
        assert(tmp[entity1.unit_number])
        assert(#tmp[entity1.unit_number] == 1)
        assert(tmp[entity1.unit_number][1] == entity2)
        assert(tmp2[entity2.unit_number])
        assert(#tmp2[entity2.unit_number] == 1)
        assert(tmp2[entity2.unit_number][1].entity == entity1)
        assert(tmp2[entity2.unit_number][1].strength == 1)
        doFullCleanup()
        
        --test that placing entities into a finished hull links beacons and affected entities together. place beacon first
        remote.call("CookingWithBeaconsLib", "set_verbose_logging", true)
        placeEntitiesInPattern(
            {
                "XXXXXXXXX",
                "XOOOOOOOX",
                "XOOOOOOOX",
                "XOOOOOOOX",
                "XXXXXXXXX"
            },
            {x=x,y=y},
            {X="concrete-energy-field"})
        tmp = placeEntitiesInPattern(
            {
                "OOOOOOOOO",
                "OOOOOOOOO",
                "OOYOOOZOO",
                "OOOOOOOOO",
                "OOOOOOOOO"
            },
            {x=x,y=y},
            {Y="blue-beacon-mk2",Z="electric-mining-drill"})
        entity1 = tmp.Y[1]
        entity2 = tmp.Z[1]
        tmp = get_map_beacon_unit_number_to_affected_entities()
        tmp2 = get_map_entity_unit_number_to_custom_shaped_beacons()
        assert(tmp[entity1.unit_number])
        assert(#tmp[entity1.unit_number] == 1)
        assert(tmp[entity1.unit_number][1] == entity2)
        assert(tmp2[entity2.unit_number])
        assert(#tmp2[entity2.unit_number] == 1)
        assert(tmp2[entity2.unit_number][1].entity == entity1)
        assert(tmp2[entity2.unit_number][1].strength == 1)
        doFullCleanup()
        
        --test that placing entities into a finished hull links beacons and affected entities together. place miner first
        remote.call("CookingWithBeaconsLib", "set_verbose_logging", true)
        placeEntitiesInPattern(
            {
                "XXXXXXXXX",
                "XOOOOOOOX",
                "XOOOOOOOX",
                "XOOOOOOOX",
                "XXXXXXXXX"
            },
            {x=x,y=y},
            {X="concrete-energy-field"})
        tmp = placeEntitiesInPattern(
            {
                "OOOOOOOOO",
                "OOOOOOOOO",
                "OOYOOOZOO",
                "OOOOOOOOO",
                "OOOOOOOOO"
            },
            {x=x,y=y},
            {Z="blue-beacon-mk2",Y="electric-mining-drill"})
        entity1 = tmp.Z[1]
        entity2 = tmp.Y[1]
        tmp = get_map_beacon_unit_number_to_affected_entities()
        tmp2 = get_map_entity_unit_number_to_custom_shaped_beacons()
        assert(tmp[entity1.unit_number])
        assert(#tmp[entity1.unit_number] == 1)
        assert(tmp[entity1.unit_number][1] == entity2)
        assert(tmp2[entity2.unit_number])
        assert(#tmp2[entity2.unit_number] == 1)
        assert(tmp2[entity2.unit_number][1].entity == entity1)
        assert(tmp2[entity2.unit_number][1].strength == 1)
        doFullCleanup()
    end

end)
