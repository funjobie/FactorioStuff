function cookingwithbeaconslib.public.enable_feature_custom_beacon_shapes()

    if not cookingwithbeaconslib.private.feature_custom_beacon_shapes then
    
        assert(not data.raw["simple-entity"]["custom-beacon-radius-visualization"], "CookingWithBeaconsLib: custom-beacon-radius-visualization already exists but the feature was not yet enabled; aborting.")
        
        data:extend({{
            type = "simple-entity-with-owner",
            name = "custom-beacon-radius-visualization",
            collision_mask = {},
            render_layer = "radius-visualization",
            tint =  {r=1, g=1, b=1, a=0.5},
            icon = "__base__/graphics/icons/steel-chest.png",
            icon_size = 64, icon_mipmaps = 4,
            flags = {"not-on-map","placeable-off-grid"},
            order = "s-e-w-f",
            max_health = 100,
            corpse = "small-remnants",
            picture = {
              filename = "__CookingWithBeaconsLib__/graphics/entity/custom-beacon-radius-visualization.png",
              priority = "extra-high",
              width = 10,
              height = 10,
              scale = 3.2
            },
        }})
       
        cookingwithbeaconslib.private.feature_custom_beacon_shapes = true
    end

    log("cookingwithbeaconslib: Feature custom beacon shapes enabled")
end

function cookingwithbeaconslib.public.setup_custom_beacon_shapes(beaconPrototype)

    assert(cookingwithbeaconslib.private.feature_custom_beacon_shapes, "CookingWithBeaconsLib: cannot give this beacon a custom shape as the feature is not enabled yet.")
    assert(beaconPrototype,"CookingWithBeaconsLib: cannot give this beacon a custom shape as the given entity is null.")
    assert(beaconPrototype.type, "CookingWithBeaconsLib: entity doesn't have a type, therefore it cannot be given a custom beacon shape.")
    assert(type(beaconPrototype.type) == "string", "CookingWithBeaconsLib: entity doesn't have a valid type, therefore it cannot be given a custom beacon shape.")
    assert(beaconPrototype.type == "beacon", "CookingWithBeaconsLib: only entities of type beacon can get a custom beacon shape. given type was: " .. beaconPrototype.type)

    --turn of the normal beacons effect. it will be transmitted via hidden beacons instead.
    --the rest is done at runtime
    beaconPrototype.supply_area_distance = 0.0

end