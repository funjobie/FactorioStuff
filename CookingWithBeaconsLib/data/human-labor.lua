--todo consider doing this with electricity, using https://wiki.factorio.com/Types/EnergySource input_flow_limit=0 and buffer_capacity set.
--but currently assemblers don't support buffer_capacity and always use 1 tick buffer.
function cookingwithbeaconslib.public.enable_feature_human_powered()

    if not cookingwithbeaconslib.private.feature_human_powered then
    
        assert(not data.raw.fluid["human-labor"], "CookingWithBeaconsLib: human-labor already exists but the feature was not yet enabled; aborting.")
        
        data:extend(
        {
            {
                type = "fluid",
                name = "human-labor",
                default_temperature = 25,
                fuel_value = "1.25J", --based on https://en.wikipedia.org/wiki/Human_power 75J / 60 ticks. 
                base_color = {r=0.5, g=0.5, b=0},
                flow_color = {r=0.6, g=0.6, b=0},
                max_temperature = 100,
                icon = "__base__/graphics/icons/character.png",
                icon_size = 64, icon_mipmaps = 4,
                order = "a[fluid]-g[human-labor]"
            },
        })
            
        cookingwithbeaconslib.private.feature_human_powered = true
    end

    log("CookingWithBeaconsLib: Feature Human labor enabled")
end

function cookingwithbeaconslib.public.make_entity_human_powered(entity)

    assert(cookingwithbeaconslib.private.feature_human_powered, "CookingWithBeaconsLib: cannot make entity human powered as the feature is not enabled yet.")
    assert(entity, "CookingWithBeaconsLib: cannot make entity human powered as the given entity is null.")
    assert(entity.type, "CookingWithBeaconsLib: entity doesn't have a type, therefore it cannot be made human powered.")
    assert(type(entity.type) == "string", "CookingWithBeaconsLib: entity doesn't have a type, therefore it cannot be made human powered.")
    --note: rocket-silo can't be done until https://forums.factorio.com/viewtopic.php?f=7&t=80438 is solved
    assert((entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "mining-drill" or entity.type == "lab"), 
        "CookingWithBeaconsLib: entity type is not supported for being human powered yet. given type was: " .. entity.type)
    
    assert(data.raw.fluid["human-labor"], "CookingWithBeaconsLib: human-labor didn't exist but the feature was enabled.")
    
    entity.energy_source =
    {
        type = "fluid",
        emissions_per_minute = 0,
        render_no_power_icon = true,
        fluid_box =
        {
          base_area = 0.2,
          height = 1,
          base_level = 0,
          pipe_connections =
          {
          },
          production_type = "input",
          filter = "human-labor"
        },
        burns_fluid = true,
        scale_fluid_usage = true,
        effectivity = 1,
    }
end