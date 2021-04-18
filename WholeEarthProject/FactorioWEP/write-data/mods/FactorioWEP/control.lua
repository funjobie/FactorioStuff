require("util")

local function init_globals()
    
    global.version = "0.1.1"
    global.needed_chunks = {}
                
end

local function player_chunk_dist(chunk)
    local smallestPlayerDistance = 9999999999
    for pk,pv in pairs(game.players) do
        local playerDistance = math.sqrt((pv.position.x - 32*chunk.x)^2 + (pv.position.y - 32*chunk.y)^2)
        if playerDistance < smallestPlayerDistance then
            smallestPlayerDistance = playerDistance
        end
    end
    return smallestPlayerDistance
end

local function get_chunk_req_list()

    table.sort(global.needed_chunks, function(a,b) return player_chunk_dist(a)<player_chunk_dist(b) end
    )
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

        for _,p in pairs(game.players) do
            p.force.chart(game.surfaces[surface], {{32*chunk_x, 32*chunk_y}, {32*chunk_x+31, 32*chunk_y+31}})
        end
        
    end

end

script.on_init(function()
    init_globals()
end)

commands.add_command("get_chunk_req_list", "get the list of chunks that the client would like to get", get_chunk_req_list)
commands.add_command("update_chunk", "transmit the chunk data to the game", update_chunk)

--script.on_load(function()
--end)

local function updateModVersion()
    --nothing to do yet
end

script.on_configuration_changed(function()
    updateModVersion()
end)

script.on_event(defines.events.on_chunk_generated, function(e)

    if e.surface.name ~= "nauvis" then return end
    e.surface.build_checkerboard(e.area)
    e.surface.destroy_decoratives{area=e.area}
    for _, e in pairs(e.surface.find_entities(e.area)) do
        e.destroy()
    end
    if e.position.y < 0 then return end
    if e.position.y > 32 then return end --temporary to avoid unnecessary load. but here a limit is still needed!
    if e.position.x < 0 then return end --temporary to avoid unnecessary load
    if e.position.x > 32 then return end --temporary to avoid unnecessary load
    
    table.insert(global.needed_chunks, {surface=e.surface.name,x=e.position.x,y=e.position.y})

end)

script.on_event(defines.events.on_tick, function(e)

end)