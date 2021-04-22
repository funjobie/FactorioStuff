require("util")

local function init_globals()
    
    global.version = "0.1.1"
    global.needed_chunks = {}
    global.available_chunks = {}
    --global.spawn set via rcon
    global.save_spawn = {x=-10000, y=-10000}
    global.player_spawns_to_process = {}
                
end

local function position_to_chunkPosition(val)
    return {
        x=math.floor(val.x/32), 
        y=math.floor(val.y/32)
    }
end

local function is_chunk_loaded(chunkPosition)
    if global.available_chunks[chunkPosition.x] and global.available_chunks[chunkPosition.x][chunkPosition.y] then 
        return true 
    end
    return false
end

local function mark_chunk_loaded(chunkPosition)
    if not global.available_chunks[chunkPosition.x] then
        global.available_chunks[chunkPosition.x] = {}
    end
    global.available_chunks[chunkPosition.x][chunkPosition.y] = true
end

local function player_or_spawn_chunk_dist(chunk)
    local smallestPlayerDistance = 9999999999
    local hasPlayers = false
    for pk,pv in pairs(game.players) do
        local playerDistance = math.sqrt((pv.position.x - 32*chunk.x)^2 + (pv.position.y - 32*chunk.y)^2)
        if playerDistance < smallestPlayerDistance then
            smallestPlayerDistance = playerDistance
        end
        hasPlayers = true
    end
    if not hasPlayers and global.spawn then
        return math.sqrt((global.spawn.x - 32*chunk.x)^2 + (global.spawn.y - 32*chunk.y)^2)
    end
    return smallestPlayerDistance
end

local function get_chunk_req_list()

    table.sort(global.needed_chunks, function(a,b) return player_or_spawn_chunk_dist(a)<player_or_spawn_chunk_dist(b) end)
    count = 0
    for _,chunk in pairs(global.needed_chunks) do
        rcon.print("RCON_CHUNK_REQ:surface=" .. chunk.surface .. ";x=" .. chunk.x .. ";y=" .. chunk.y..";")
        count = count + 1
        if count > 32 then break end
    end
    
end

local function update_chunk(event)

    --name :: string: Name of the command.
    --tick :: uint: Tick the command was used.
    --player_index :: uint (optional): The player who used the command. It will be missing if run from the server console.
    --parameter :: string (optional): The parameter passed after the command, separated from the command by 1 space.
    
    if not event.player_index then --ensure only rcon triggers chunk update
        f = loadstring(event.parameter)
        f() --sets "surface", "chunk_x", "chunk_y", "tiles"

        game.surfaces[surface].set_tiles(tiles)
        for k,v in pairs(global.needed_chunks) do
            if v.surface == surface and v.x == chunk_x and v.y == chunk_y then
                table.remove(global.needed_chunks, k)
                break
            end
        end
        mark_chunk_loaded({x=chunk_x, y=chunk_y})
        print("marked chunk as loaded: " .. tostring(chunk_x) .. " : " .. tostring(chunk_y))
        
        for _,p in pairs(game.players) do
            p.force.chart(game.surfaces[surface], {{32*chunk_x, 32*chunk_y}, {32*chunk_x+31, 32*chunk_y+31}})
        end
        
        if global.spawn then
            local chunk_position = position_to_chunkPosition(global.spawn)
            if (chunk_position.x == chunk_x and chunk_position.y == chunk_y) then
                print("spawning pending players into received spawn chunk")
                for _, player_index in pairs(global.player_spawns_to_process) do
                    game.players[player_index].teleport(global.spawn)
                end
                global.player_spawns_to_process = {}
            end
        end
        
    end

end

local function set_spawn_position(event)

    --name :: string: Name of the command.
    --tick :: uint: Tick the command was used.
    --player_index :: uint (optional): The player who used the command. It will be missing if run from the server console.
    --parameter :: string (optional): The parameter passed after the command, separated from the command by 1 space.
    
    if not event.player_index then --ensure only rcon triggers
        f = loadstring(event.parameter)
        f() --sets "spawn_x", "spawn_y"
        print("received set_spawn_position with " .. tostring(spawn_x) .. " : " .. tostring(spawn_y))
        global.spawn = {x=spawn_x, y=spawn_y}
        
        --this is over simplified as there can be multiple forces depending on  mod setups... default has: 0:player, 1:enemy, 2:neutral
        for _, f in pairs(game.forces) do
            if f.name == "player" then --todo unclear to set for which forces
                print("setting spawn to " .. tostring(spawn_x) .. " : " .. tostring(spawn_y) .. " for force: " .. f.name)
                f.set_spawn_position(global.save_spawn, "nauvis")
            end
        end
        
        game.surfaces["nauvis"].request_to_generate_chunks(global.spawn, 2) --2 is radius to request
        
    end
end

script.on_init(function()
    init_globals()
end)

commands.add_command("get_chunk_req_list", "get the list of chunks that the client would like to get", get_chunk_req_list)
commands.add_command("update_chunk", "transmit the chunk data to the game", update_chunk)
commands.add_command("set_spawn_position", "transmit the spawn position to the game", set_spawn_position)


--script.on_load(function()
--end)

--on_game_created_from_scenario
--on_force_created

local function updateModVersion()
    --nothing to do yet
end

script.on_configuration_changed(function()
    updateModVersion()
end)

script.on_event(defines.events.on_chunk_generated, function(e)

    if e.surface.name ~= "nauvis" then return end
    --e.surface.set_chunk_generated_status(e.position, defines.chunk_generated_status.entities) --did not help
    e.surface.build_checkerboard(e.area)
    e.surface.destroy_decoratives{area=e.area}
    for _, e in pairs(e.surface.find_entities(e.area)) do
        e.destroy()
    end
    if e.position.y < 0 then return end
    if e.position.y > 32 then return end --temporary to avoid unnecessary load. but here a limit is still needed!
    if e.position.x < 0 then return end --temporary to avoid unnecessary load
    if e.position.x > 32 then return end --temporary to avoid unnecessary load
    
    --somehow x=15 / y=10 is requested twice! its the spawn location
    print("chunk generation for: " .. e.position.x .. " / " .. e.position.y)
    
    table.insert(global.needed_chunks, {surface=e.surface.name,x=e.position.x,y=e.position.y})
    
end)

script.on_event(defines.events.on_player_respawned, function(e)
    --player_index :: uint
    --player_port :: LuaEntity (optional): The player port used to respawn if one was used.
    print("processing on_player_respawned")
    if global.spawn and is_chunk_loaded(position_to_chunkPosition(global.spawn)) then
        if game.players[e.player_index] then
            game.players[e.player_index].teleport(global.spawn)
        end
    else
        game.players[e.player_index].teleport(global.save_spawn)
        table.insert(global.player_spawns_to_process, player_index)
    end
end)

script.on_event(defines.events.on_player_created, function(e)
    --player_index :: uint
    --player_port :: LuaEntity (optional): The player port used to respawn if one was used.
    print("processing on_player_created")
    if global.spawn and is_chunk_loaded(position_to_chunkPosition(global.spawn)) then
        if game.players[e.player_index] then
            game.players[e.player_index].teleport(global.spawn)
        end
    else
        table.insert(global.player_spawns_to_process, e.player_index)
    end
end)

