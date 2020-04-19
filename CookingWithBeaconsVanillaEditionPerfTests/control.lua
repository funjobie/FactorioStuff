--[[
credits:

factorio devs

--]]
--[[
Measurement results:
0.18.3, 2020-2-4, dimensions = 256, 4225 entities, no research, 6.4ms script update time.
0.18.3, 2020-2-4, dimensions = 256, 4225 entities, all research, 6.2ms script update time.
0.18.3, 2020-2-4, dimensions = 128, 1089 entities, no research, 2.1ms script update time.
0.18.3, 2020-2-4, dimensions = 128, 1089 entities, all research, 1.9ms script update time.
0.18.3, 2020-2-5, dimensions = 128, 1089 entities, no research, 1.0ms script update time.
0.18.3, 2020-2-5, dimensions = 128, 1089 entities, all research, 0.9ms script update time.
0.18.3, 2020-2-5, dimensions = 32, 81 entities, no research, 0.11ms script update time.
0.18.3, 2020-2-5, dimensions = 32, 81 entities, all research, 0.10ms script update time.
0.18.3, 2020-2-5, dimensions = 512, 16641 entities, no research, 3.6 - 6ms script update time.
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

script.on_event(defines.events.on_tick, function(event)

    local enabled = false
    if event.tick == 0 and enabled then
        local force="player"
        if false then game.forces[force].research_all_technologies() end
        game.surfaces["nauvis"].create_entity{name="electric-energy-interface", position = {0,0}, force=force}
        local dimensions = 128
        local entityCount = 0
        for x = -dimensions,dimensions,8 do
            for y = -dimensions,dimensions,8 do
                if not (x==0 and y==0) then
                    local newRoboport = game.surfaces["nauvis"].create_entity{name="roboport", position = {x+0,y+0}, force=force}
                    newRoboport.insert({name="construction-robot", count=10})
                end
                game.surfaces["nauvis"].create_entity{name="substation", position = {x+3,y+0}, force=force}
                game.surfaces["nauvis"].create_entity{name="centrifuge", position = {x,y+3}, force=force, raise_built=true, recipe="uranium-processing"}
                entityCount = entityCount + 1
                game.surfaces["nauvis"].create_entity{name="stack-inserter", position = {x+2,y+3}, force=force, direction=defines.direction.east}
                game.surfaces["nauvis"].create_entity{name="stack-inserter", position = {x+2,y+4}, force=force, direction=defines.direction.west}
                local chestA = game.surfaces["nauvis"].create_entity{name="infinity-chest", position = {x+3,y+3}, force=force}
                chestA.set_infinity_container_filter(1, {name = "uranium-ore", count = 50})
                local chestB = game.surfaces["nauvis"].create_entity{name="infinity-chest", position = {x+3,y+4}, force=force}
                --currently no way to enable the setting to clear the chest automatically
            end
        end
        game.print("entity count: " .. entityCount)
    end

end)
