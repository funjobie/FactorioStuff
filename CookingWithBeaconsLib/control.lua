--[[
credits:

factorio devs

--todo maybe use LuaPlayerBuiltEntityEventFilters to optimize event registration
https://lua-api.factorio.com/latest/Event-Filters.html#LuaPlayerBuiltEntityEventFilters
...but since it isn't guaranteed that only filtered types appear maybe that doesn't simplify the code. it could however improve performance a little bit.
https://test.forums.factorio.com/viewtopic.php?t=78072
--]]

require('control/util')
require('control/human-labor')
require('control/robot-labor')
require('control/hidden-beacons')
require('control/tile-bonus')
require('control/research-bonus')
require('control/custom-beacon-shapes')
require('control/concave-hull-beacon-shapes')
require('control/forbidden-beacon-overlap')

local function init_interface()
    remote.remove_interface("CookingWithBeaconsLib")
    remote.add_interface("CookingWithBeaconsLib",
        {
            enable_feature_human_powered = function() enableFeatureHumanPowered() end,
            make_human_powered_entity_require_tools = function(args, extraArgsCatch) makeHumanPoweredEntityRequireTools(args, extraArgsCatch) end,
            
            enable_feature_robot_powered = function() enableFeatureRobotPowered() end,
            make_entity_robot_powered = function(args, extraArgsCatch) makeEntityRobotPowered(args, extraArgsCatch) end,
            
            enable_feature_tile_bonus = function() enableFeatureTileBonus() end,
            give_tile_bonus_to_entity = function(args, extraArgsCatch) giveTileBonusToEntity(args, extraArgsCatch) end,
            
            enable_feature_research_bonus = function() enableFeatureResearchBonus() end,
            give_research_bonus_to_entities = function(args, extraArgsCatch) giveResearchBonusToEntities(args, extraArgsCatch) end,
            add_entities_to_research_bonus_group = function(args, extraArgsCatch) addEntitiesToResearchBonusGroup(args, extraArgsCatch) end,
            
            enable_feature_custom_beacon_shapes = function() enableFeatureCustomBeaconShapes() end,
            give_custom_beacon_shape_to_entity = function(args, extraArgsCatch) giveCustomBeaconShapeToEntity(args, extraArgsCatch) end,
            create_sphere_custom_shape = function(args, extraArgsCatch) return createSphereCustomShape(args, extraArgsCatch) end,
            create_diamond_custom_shape = function(args, extraArgsCatch) return createDiamondCustomShape(args, extraArgsCatch) end,

            enable_feature_concave_hull_beacon_shapes = function() enableFeatureConcaveHullBeaconShapes() end,
            set_concave_hull_creating_group = function(args, extraArgsCatch) registerHullEntities(args, extraArgsCatch) end,
            give_concave_hull_beacon_shape_to_entity = function(args, extraArgsCatch) giveConcaveHullBeaconShapeToEntity(args, extraArgsCatch) end,
            
            enable_feature_forbidden_beacon_overlap = function() enableFeatureForbiddenBeaconOverlap() end,
            set_forbidden_beacon_overlap_for_entity = function(args, extraArgsCatch) setForbiddenBeaconOverlapForEntity(args, extraArgsCatch) end,
            
            run_maintainance_script = function(args) str, errmsg = loadstring(args) if not str then error("ERROR: " .. errmsg) else return str() end end,
            set_verbose_logging = function(args) assert(type(args) == "boolean") global.verbose_logging = args end
        }
    )
end

local function init_globals()
    
    global.version = "0.1.2"
    
    global.human_labor = {}
    global.robot_labor = {}
    global.hidden_beacons = {}
    global.tile_bonus = {}
    global.research_bonus = {}
    global.custom_beacon_shapes = {}
    global.concave_beacon_shapes = {}
    global.forbidden_beacon_overlap = {}
    global.verbose_logging = false

    init_interface()
            
end

script.on_init(function()
    init_globals()
end)

local function updateModVersion()

    if global.version == "0.1.1" then
        init_interface()
        game.print("updated CookingWithBeaconsLib from 0.1.1 to 0.1.2")
    end

    global.version = "0.1.2"
    
end

script.on_configuration_changed(function()
    updateModVersion()
end)

script.on_nth_tick(61, function(event)
    robotLabor_on_nth_tick_61(event)
end)

script.on_nth_tick(60, function(event)
    customBeaconShapes_on_nth_tick_60(event)
    concaveHullBeaconShapes_on_nth_tick_60(event)
end)

script.on_nth_tick(20, function(event)
    humanLabor_on_nth_tick_20(event)
end)

script.on_nth_tick(5, function(event)
    robotLabor_on_nth_tick_5(event)
end)

local function on_built(entity)

    if global.hidden_beacons.feature_enabled           and entity.valid then hiddenBeacons_on_built_pre_boni(entity) end
    if global.tile_bonus.feature_enabled               and entity.valid then tileBonus_on_built(entity) end
    if global.research_bonus.feature_enabled           and entity.valid then researchBonus_on_built(entity) end
    if global.custom_beacon_shapes.feature_enabled     and entity.valid then customBeaconShapes_on_built(entity) end
    if global.concave_beacon_shapes.feature_enabled    and entity.valid then concaveHullBeaconShapes_on_built(entity) end
    if global.hidden_beacons.feature_enabled           and entity.valid then hiddenBeacons_on_built_post_boni(entity) end
    
    if global.forbidden_beacon_overlap.feature_enabled and entity.valid then forbiddenBeaconOverlap_on_built(entity) end

    if global.robot_labor.feature_enabled              and entity.valid then robotLabor_on_built(entity) end
end

local function on_unbuilt(entity)
    if global.research_bonus.feature_enabled           and entity.valid then  researchBonus_on_unbuilt(entity) end
    if global.custom_beacon_shapes.feature_enabled     and entity.valid then customBeaconShapes_on_unbuilt(entity) end
    if global.concave_beacon_shapes.feature_enabled    and entity.valid then concaveHullBeaconShapes_on_unbuilt(entity) end
    if global.hidden_beacons.feature_enabled           and entity.valid then hiddenBeacons_on_unbuilt(entity) end

    if global.robot_labor.feature_enabled              and entity.valid then robotLabor_on_unbuilt(entity) end
end

local function on_tile_changed(surface_index, tiles)
    tileBonus_on_tile_changed(surface_index, tiles)
end


script.on_event(defines.events.on_built_entity, function(event)
    on_built( event.created_entity )
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
    on_built( event.created_entity )
end)

script.on_event(defines.events.script_raised_built, function(event)
    on_built( event.entity )
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
    on_unbuilt(event.entity)
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
    on_unbuilt(event.entity)
    robotLabor_on_robot_mined_entity(event)
end)

script.on_event(defines.events.script_raised_destroy, function(event)
    on_unbuilt(event.entity)
end)

script.on_event(defines.events.on_entity_died, function(event)
    on_unbuilt(event.entity)
end)

script.on_event(defines.events.on_player_built_tile, function(event)
    on_tile_changed(event.surface_index, event.tiles)
end)

script.on_event(defines.events.on_player_mined_tile, function(event)
    on_tile_changed(event.surface_index, event.tiles)
end)

script.on_event(defines.events.on_robot_built_tile, function(event)
    on_tile_changed(event.surface_index, event.tiles)
end)

script.on_event(defines.events.on_robot_mined_tile, function(event)
    on_tile_changed(event.surface_index, event.tiles)
end)

script.on_event(defines.events.on_research_finished, function(event)
    researchBonus_on_research_finished(event)
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
    customBeaconShapes_on_selected_entity_changed(event)
    concaveHullBeaconShapes_on_selected_entity_changed(event)
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    customBeaconShapes_on_player_cursor_stack_changed(event)
    concaveHullBeaconShapes_on_player_cursor_stack_changed(event)
end)

