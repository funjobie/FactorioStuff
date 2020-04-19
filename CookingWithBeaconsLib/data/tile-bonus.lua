function cookingwithbeaconslib.public.enable_feature_tile_bonus()

    if not cookingwithbeaconslib.private.feature_tile_bonus then
        cookingwithbeaconslib.private.add_hidden_beacon_and_unit_modules()    
        cookingwithbeaconslib.private.feature_tile_bonus = true
    end

    log("cookingwithbeaconslib: Feature tile bonus enabled")
end
