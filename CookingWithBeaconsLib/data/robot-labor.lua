function cookingwithbeaconslib.public.enable_feature_robot_powered()

    if not cookingwithbeaconslib.private.feature_robot_powered then
    
        assert(not data.raw.fluid["robot-labor"], "CookingWithBeaconsLib: robot-labor already exists but the feature was not yet enabled; aborting.")        
        assert(not data.raw["simple-entity-with-force"]["robot-labor-charge-task"], "CookingWithBeaconsLib: robot-labor-charge-task already exists but the feature was not yet enabled; aborting.")        
        assert(not data.raw.item["robot-labor-charge-task"], "CookingWithBeaconsLib: robot-labor-charge-task already exists but the feature was not yet enabled; aborting.")        
        assert(not data.raw["simple-entity-with-force"]["robot-labor-dummy-discharging-sparks"], "CookingWithBeaconsLib: robot-labor-dummy-discharging-sparks already exists but the feature was not yet enabled; aborting.")        
        data:extend(
        {
            --fluid, which acts as the fuel
            {
                type = "fluid",
                name = "robot-labor",
                default_temperature = 25,
                fuel_value = "1kJ",
                base_color = {r=0, g=0.4, b=0},
                flow_color = {r=0, g=0.5, b=0},
                max_temperature = 100,
                icon = "__base__/graphics/icons/construction-robot.png",
                icon_size = 64, icon_mipmaps = 4,
                order = "a[fluid]-h[robot-labor]"
            },
            --This invisible entity will be de-constructed which will make the game engine move one construction robot towards this entity
            {
                type = "simple-entity-with-force",
                name = "robot-labor-charge-task",
                render_layer = "object",
                --todo can deconstruction icon be hidden?
                --alert_icon_scale = 0.1, --has no effect on deconstruction icon...
                --alert_icon_shift = {999999999,999999999}, --has no effect on deconstruction icon...
                icon = "__base__/graphics/icons/steel-chest.png",
                icon_size = 64, icon_mipmaps = 4,
                flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-repairable", "player-creation", "not-flammable"},
                order = "s-e-w-f",
                max_health = 100,
                corpse = "small-remnants",
                picture = cookingwithbeaconslib.private.no_sprite(),
            },
            --a dummy item which is required in 0.17.79 because without an item than can place_result an entity, it cannot be ordered to be de-constructed.
            {
                type = "item",
                name = "robot-labor-charge-task",
                flags = { "hidden" },
                icon = "__base__/graphics/icons/iron-chest.png",
                icon_size = 64, icon_mipmaps = 4,
                subgroup = "cwb-behind-the-scene",
                order = "a[items]-b[iron-chest]",
                place_result = "robot-labor-charge-task",
                stack_size = 50
            },
            --This entity will be created where the "discharging" construction robot is, to fake the sparks animation (since it isn't really charging)
            {
                type = "simple-entity-with-force",
                name = "robot-labor-dummy-discharging-sparks",
                flags = {"placeable-off-grid", "not-on-map"},
                render_layer = "air-object",
                animations = {
                    {
                        filename = "__base__/graphics/entity/sparks/sparks-01.png",
                        width = 39,
                        height = 34,
                        frame_count = 19,
                        line_length = 19,
                        shift = {-0.109375, 0.3125},
                        tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
                        animation_speed = 0.3
                    },
                },
                working_sound =
                {
                    sound =
                    {
                        filename = "__base__/sound/accumulator-working.ogg",
                        volume = 1
                    },
                    max_sounds_per_type = 5
                },
            },
        })
    
        cookingwithbeaconslib.private.feature_robot_powered = true
    end

    log("CookingWithBeaconsLib: Feature Robot powered enabled")
end

function cookingwithbeaconslib.public.make_entity_robot_powered(entity, energy_buffer_in_seconds)

    assert(cookingwithbeaconslib.private.feature_robot_powered, "CookingWithBeaconsLib: cannot make entity robot powered as the feature is not enabled yet.")
    assert(entity, "CookingWithBeaconsLib: cannot make entity robot powered as the given entity is null.")
    assert(entity.type, "CookingWithBeaconsLib: entity doesn't have a type, therefore it cannot be made robot powered.")
    --note: rocket-silo can't be done until https://forums.factorio.com/viewtopic.php?f=7&t=80438 is solved
    assert((entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "mining-drill" or entity.type == "inserter" or entity.type == "lab"), 
        "CookingWithBeaconsLib: entity type is not supported for being robot powered yet. given type was: " .. entity.type)

    local energy_usage_1_second = 0
    if (entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "mining-drill" or entity.type == "lab") then
        assert(entity.energy_usage, "CookingWithBeaconsLib: given entity doesn't have the energy_usage property. this is required to derive the size of the energy buffer")
        assert(type(entity.energy_usage) == "string", "CookingWithBeaconsLib: given entity doesn't have a valid energy_usage property. this is required to derive the size of the energy buffer")
        energy_usage_1_second = cookingwithbeaconslib.private.to_energy_number(entity.energy_usage)
        assert(energy_usage_1_second, "CookingWithBeaconsLib: the energy_usage string of the given entity is not valid. this is required to derive the size of the energy buffer")
    end
    if (entity.type == "inserter") then
        assert(entity.energy_per_movement and entity.energy_per_rotation and entity.extension_speed and entity.rotation_speed, "CookingWithBeaconsLib: given entity doesn't all of the required properties energy_per_movement, energy_per_rotation, extension_speed and rotation_speed. this is required to derive the size of the energy buffer")
        assert(type(entity.energy_per_movement) == "string", "CookingWithBeaconsLib: given entity doesn't have a valid energy_per_movement property. this is required to derive the size of the energy buffer")
        assert(type(entity.energy_per_rotation) == "string", "CookingWithBeaconsLib: given entity doesn't have a valid energy_per_rotation property. this is required to derive the size of the energy buffer")
        assert(type(entity.extension_speed) == "number", "CookingWithBeaconsLib: given entity doesn't have a valid extension_speed property. this is required to derive the size of the energy buffer")
        assert(type(entity.rotation_speed) == "number", "CookingWithBeaconsLib: given entity doesn't have a valid rotation_speed property. this is required to derive the size of the energy buffer")
        local energy_per_movement_number = cookingwithbeaconslib.private.to_energy_number(entity.energy_per_movement)
        assert(energy_per_movement_number, "CookingWithBeaconsLib: the energy_per_movement string of the given entity is not valid. this is required to derive the size of the energy buffer")
        local energy_per_rotation_number = cookingwithbeaconslib.private.to_energy_number(entity.energy_per_rotation)
        assert(energy_per_rotation_number, "CookingWithBeaconsLib: the energy_per_rotation string of the given entity is not valid. this is required to derive the size of the energy buffer")
        --same estimate as used ingame: 60 ticks of both rotations and movement. this is over-estimating the consumption (quite a bit).
        energy_usage_1_second = 60 * (energy_per_movement_number * entity.extension_speed + energy_per_rotation_number * entity.rotation_speed)
    end
    
    if energy_buffer_in_seconds then assert(type(energy_buffer_in_seconds) == "number", "CookingWithBeaconsLib: the given energy_buffer_in_seconds is not a number.") end
    local number_of_seconds_to_buffer = 30
    if energy_buffer_in_seconds then number_of_seconds_to_buffer = energy_buffer_in_seconds end
    local energy_buffer_size = energy_usage_1_second * number_of_seconds_to_buffer
    
    assert(data.raw.fluid["robot-labor"], "CookingWithBeaconsLib: robot-labor didn't exist but the feature was enabled.")
    assert(data.raw.fluid["robot-labor"].fuel_value, "CookingWithBeaconsLib: the fuel_value of robot-labor didn't exist")
    assert(type(data.raw.fluid["robot-labor"].fuel_value) == "string", "CookingWithBeaconsLib: the fuel_value of robot-labor was not a string")
    local value_of_1_fluid = cookingwithbeaconslib.private.to_energy_number(data.raw.fluid["robot-labor"].fuel_value)
    assert(value_of_1_fluid, "CookingWithBeaconsLib: the fuel_value of robot-labor was not an energy string")
    
    local fluid_buffer_size = energy_buffer_size / value_of_1_fluid
    fluid_buffer_size = fluid_buffer_size / 100 --factorio multiplies the capacity by 100 automatically
    
    entity.energy_source =
    {
        type = "fluid",
        emissions_per_minute = 0,
        render_no_power_icon = true,
        fluid_box =
        {
          base_area = fluid_buffer_size,
          height = 1,
          base_level = 0,
          pipe_connections =
          {
          },
          production_type = "input",
          filter = "robot-labor"
        },
        burns_fluid = true,
        scale_fluid_usage = true,
        effectivity = 1,
    }
end