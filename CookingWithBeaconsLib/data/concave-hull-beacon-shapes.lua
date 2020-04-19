function cookingwithbeaconslib.public.enable_feature_concave_hull_beacon_shapes()

    if not cookingwithbeaconslib.private.feature_concave_hull_beacon_shapes then
    
        assert(not data.raw["simple-entity"]["concave hull-beacon-radius-visualization"], "CookingWithBeaconsLib: concave hull-beacon-radius-visualization already exists but the feature was not yet enabled; aborting.")
        
        data:extend({{
            type = "simple-entity-with-owner",
            name = "concave-hull-beacon-radius-visualization",
            collision_mask = {},
            render_layer = "radius-visualization",
            tint =  {r=.5, g=1, b=0.5, a=0.5},
            icon = "__base__/graphics/icons/steel-chest.png",
            icon_size = 64, icon_mipmaps = 4,
            flags = {"not-on-map","placeable-off-grid"},
            order = "s-e-w-f",
            max_health = 100,
            corpse = "small-remnants",
            picture = {
              filename = "__CookingWithBeaconsLib__/graphics/entity/concave-hull-beacon-radius-visualization.png",
              priority = "extra-high",
              width = 10,
              height = 10,
              scale = 3.2
            },
        }})
       
        cookingwithbeaconslib.private.feature_concave_hull_beacon_shapes = true
    end

    log("cookingwithbeaconslib: Feature concave hull beacon shapes enabled")
end

function cookingwithbeaconslib.public.setup_concave_hull_beacon_shapes(beaconPrototype)

    assert(cookingwithbeaconslib.private.feature_concave_hull_beacon_shapes, "CookingWithBeaconsLib: cannot give this beacon a concave hull shape as the feature is not enabled yet.")
    assert(beaconPrototype,"CookingWithBeaconsLib: cannot give this beacon a concave hull shape as the given entity is null.")
    assert(beaconPrototype.type, "CookingWithBeaconsLib: entity doesn't have a type, therefore it cannot be given a concave hull beacon shape.")
    assert(type(beaconPrototype.type) == "string", "CookingWithBeaconsLib: entity doesn't have a valid type, therefore it cannot be given a concave hull beacon shape.")
    assert(beaconPrototype.type == "beacon", "CookingWithBeaconsLib: only entities of type beacon can get a concave hull beacon shape. given type was: " .. beaconPrototype.type)

    --turn of the normal beacons effect. it will be transmitted via hidden beacons instead.
    beaconPrototype.supply_area_distance = 0.0

    local nameOfReceiver = "concave-hull-energy-receiver-"..beaconPrototype.name
    if not data.raw["electric-energy-interface"][nameOfReceiver] then
        local hiddenEnergyReceiver = util.table.deepcopy(data.raw["electric-energy-interface"]["hidden-electric-energy-interface"])
        hiddenEnergyReceiver.name = nameOfReceiver
        hiddenEnergyReceiver.icon = beaconPrototype.icon
        hiddenEnergyReceiver.localised_name = {"entity-name.concave-hull-power-consumer",{"entity-name."..beaconPrototype.name}}
        hiddenEnergyReceiver.collision_box = beaconPrototype.collision_box
        hiddenEnergyReceiver.energy_production = "0kW"
        hiddenEnergyReceiver.energy_usage = "0kW"   --to be adjusted at runtime depending on the number of affected tiles
        hiddenEnergyReceiver.energy_source =
        {
            type = "electric",
            usage_priority = "primary-input",
            buffer_capacity = "1MJ",
        }, 
        data:extend({hiddenEnergyReceiver})
    end
    
end