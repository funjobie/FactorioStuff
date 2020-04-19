function enableFeatureTileBonus()

    enableFeatureHiddenBeacons()

    if not global.tile_bonus.feature_enabled then
        global.tile_bonus.feature_enabled = true
        global.tile_bonus.tileBoni = {}
    end
end

function giveTileBonusToEntity(args, args2)

    assert(global.tile_bonus.feature_enabled, "Library usage error give_tile_bonus_to_entity: feature was not enabled yet via enable_feature_custom_beacon_shapes().")

    assert(args, "Library usage error give_tile_bonus_to_entity: arguments are missing.")
    assert(type(args) == "table", "Library usage error give_tile_bonus_to_entity: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error give_tile_bonus_to_entity: too many arguments given. arguments have to be provided in a table as one argument.")

    local name = args.name
    args.name = nil
    local mode = args.mode
    args.mode = nil
    local defaultBoni = args.defaultBoni
    args.defaultBoni = nil
    local tileBoni = args.tileBoni
    args.tileBoni = nil
    for k,_ in pairs(args) do error("Library usage error give_tile_bonus_to_entity: unsupported argument " .. k) end

    assert(name, "Library usage error give_tile_bonus_to_entity: name was not provided")
    assert(type(name) == "string", "Library usage error give_tile_bonus_to_entity: name was given but it is not a string but a " .. type(name))
    assert(game.entity_prototypes[name], "Library usage error give_tile_bonus_to_entity: name was given but such an entity doesn't exist. name is: " .. name)
    assert(doesEntitySupportBeacons(game.entity_prototypes[name]), "Library usage error give_tile_bonus_to_entity: the given entity cannot be affected by beacons. name is: " .. name)

    assert(mode, "Library usage error give_tile_bonus_to_entity: mode was not provided")
    assert(type(mode) == "string", "Library usage error give_tile_bonus_to_entity: mode was given but it is not a string but a " .. type(mode))
    assert(mode == "background" or mode == "foreground", "Library usage error give_tile_bonus_to_entity: mode must be either background or foreground but it is " .. mode)
    if global.tile_bonus.tileBoni[name] then assert(global.tile_bonus.tileBoni[name][mode] == nil, "Library usage error give_tile_bonus_to_entity: tile boni is already set for entity " .. name .. " mode " .. mode ) end

    assert(defaultBoni, "Library usage error give_tile_bonus_to_entity: defaultBoni was not provided")
    assert(type(defaultBoni) == "table", "Library usage error give_tile_bonus_to_entity: defaultBoni was given but it is not a table but a " .. type(defaultBoni))
    for k,v in pairs(defaultBoni) do
        assert(k=="consumption" or k=="speed" or k=="productivity" or k=="pollution",
            "Library usage error give_tile_bonus_to_entity: defaultBoni has unknown key " .. k)
        assert(type(v) == "table", "Library usage error give_tile_bonus_to_entity: the defaultBoni contains an element which is not a table, it is " .. type(v))
        assert(v.bonus, "Library usage error give_tile_bonus_to_entity: defaultBoni element doesn't have the value 'bonus'")
        assert(type(v.bonus) == "number", "Library usage error give_tile_bonus_to_entity: the bonus given to one defaultBoni is not a number but " .. type(v.bonus))
    end
    
    assert(tileBoni, "Library usage error give_tile_bonus_to_entity: tileBoni was not provided")
    assert(type(tileBoni) == "table", "Library usage error give_tile_bonus_to_entity: tileBoni was given but it is not a table but a " .. type(tileBoni))
    local tileBoniHasAtLeastOneEntry = false
    for k,v in pairs(tileBoni) do
        assert(game.tile_prototypes[k], "Library usage error give_tile_bonus_to_entity: the key " .. k .. " is not a tile")
        assert(type(v) == "table", "Library usage error give_tile_bonus_to_entity: tileBoni for tile " .. k .. " was given but it is not a table but a " .. type(v))
        tileBoniHasAtLeastOneEntry = true
        local oneBoniHasAtLeastOneEntry = false
        for k2,v2 in pairs(v) do
            oneBoniHasAtLeastOneEntry = true
            assert(k2=="consumption" or k2=="speed" or k2=="productivity" or k2=="pollution",
                "Library usage error give_tile_bonus_to_entity: tileBoni has unknown key " .. k2)
            assert(type(v2) == "table", "Library usage error give_tile_bonus_to_entity: the tileBoni contains an element which is not a table, it is " .. type(v2))
            assert(v2.bonus, "Library usage error give_tile_bonus_to_entity: tileBoni element doesn't have the value 'bonus'")
            assert(type(v2.bonus) == "number", "Library usage error give_tile_bonus_to_entity: the multiplier given to one tileBoni is not a number but " .. type(v2.bonus))
        end
        assert(oneBoniHasAtLeastOneEntry, "Library usage error give_tile_bonus_to_entity: tileBoni for the tile " .. k .. " doesn't have any elements inside")
    end
    assert(tileBoniHasAtLeastOneEntry, "Library usage error give_tile_bonus_to_entity: tileBoni doesn't have any elements inside")
    

    if mode == "background" or mode == "foreground" then
        if not global.tile_bonus.tileBoni[name] then global.tile_bonus.tileBoni[name] = {} end
        global.tile_bonus.tileBoni[name][mode] = {defaultBoni=defaultBoni,tileBoni=tileBoni}
    end
end

local function recalculateTileBonus(entity)
    if global.tile_bonus.tileBoni[entity.name] then
        local backgroundTile = nil
        local foregroundTile = nil
        local tile = entity.surface.get_tile(entity.position.x,entity.position.y)
        if tile then tile = tile.name end
        local hiddenTile = entity.surface.get_hidden_tile(entity.position)
        
        if hiddenTile then
            backgroundTile = hiddenTile
            foregroundTile = tile
        else
            backgroundTile = tile
            foregroundTile = tile
        end
        
        local actualBoni1 = global.tile_bonus.tileBoni[entity.name]["background"].tileBoni[backgroundTile] or global.tile_bonus.tileBoni[entity.name]["background"].defaultBoni
        local actualBoni2 = global.tile_bonus.tileBoni[entity.name]["foreground"].tileBoni[foregroundTile] or global.tile_bonus.tileBoni[entity.name]["foreground"].defaultBoni
        local boniToApply = addBonusEffects(actualBoni1, actualBoni2)
        global.hidden_beacons.entity_specific_boni[entity.unit_number].tile_bonus = boniToApply        
    end
end

function tileBonus_on_tile_changed(surface_index, tiles)
    for _, tile in pairs(tiles) do --OldTileAndPosition
        local position = tile.position
        local foundEntities = game.surfaces[surface_index].find_entities_filtered{
            type = global.hidden_beacons.listOfEntityTypesSupportingBeacons, 
            area = {position, {position.x+0.99, position.y+0.99}}}
        for _, entity in pairs(foundEntities) do
            recalculateTileBonus(entity)
            reapplyAllHiddenBeaconEffects(entity)
        end
    end
end

function tileBonus_on_built(entity)
    recalculateTileBonus(entity)
end