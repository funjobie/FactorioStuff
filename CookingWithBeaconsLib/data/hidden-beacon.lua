function cookingwithbeaconslib.private.get_num_bits_for_module_effects()
    return 15 --factorio uses signed 16 bits for module effects. so 32768 actually is considered negative. so limit to 15 bits. at least this was the case in 0.17.? when this was last checked.
end

function cookingwithbeaconslib.private.add_hidden_beacon()
    if not data.raw.beacon["cwb-hidden-bonus-beacon"] then
        data:extend(
        {
            {
                type = "beacon",
                name = "cwb-hidden-bonus-beacon",
                order = "a",
                icon = "__base__/graphics/icons/beacon.png",
                icon_size = 64, icon_mipmaps = 4,
                flags = {"placeable-player", "player-creation", "not-on-map", "not-blueprintable", 
                    "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion", "not-selectable-in-game", "not-deconstructable"},
                minable = {mining_time = 1, result = nil},
                max_health = 200,
                corpse = "big-remnants",
                dying_explosion = "medium-explosion",
                collision_box = {{-0.1, -0.1}, {0.1, 0.1}}, --for some reason if the bounding box is empty, the beacon no longer affects entities
                collision_mask = {},
                selection_box = {{0, 0}, {0, 0}},
                allowed_effects = {"consumption", "speed", "pollution", "productivity"},
                base_picture = cookingwithbeaconslib.private.no_sprite(),
                animation = cookingwithbeaconslib.private.no_anim(),
                animation_shadow = cookingwithbeaconslib.private.no_anim(),
                radius_visualisation_picture =
                {
                    filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
                    width = 10,
                    height = 10
                },
                supply_area_distance = 0.1,
                energy_source =
                {
                    type = "void",
                },
                vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
                energy_usage = "480kW",
                distribution_effectivity = 1.0,
                module_specification =
                {
                    module_slots = cookingwithbeaconslib.private.get_num_bits_for_module_effects() * 4, --4 kinds of module effects
                    module_info_icon_shift = {0, 0.5},
                    module_info_multi_row_initial_height_modifier = -0.3
                }
            }
        })
    end
end

function cookingwithbeaconslib.private.add_unit_module_if_not_existing(effectType, level, bonusMultiplier)

    if not data.raw.module["positive-unit-module-"..effectType.."-"..level] then
        local newMod = {
            type = "module",
            name = "positive-unit-module-"..effectType.."-"..level,
            flags = { "hidden" },
            icon = "__base__/graphics/icons/speed-module.png",
            icon_size = 64, icon_mipmaps = 4,
            subgroup = "cwb-behind-the-scene",
            category = "unit-module", --"since this has no effect anyway, use a custom category to avoid conflicts later
            tier = level,
            order = "a["..effectType.."]-a["..effectType.."-module-"..level.."]",
            stack_size = 50,
            effect = {}
        }
        newMod.effect[effectType] = {bonus = bonusMultiplier * level / 100.0}

        data:extend({newMod})
    end
    if not data.raw.module["negative-unit-module-"..effectType.."-"..level] then
        local newMod = {
            type = "module",
            name = "negative-unit-module-"..effectType.."-"..level,
            flags = { "hidden" },
            icon = "__base__/graphics/icons/productivity-module.png",
            icon_size = 64, icon_mipmaps = 4,
            subgroup = "cwb-behind-the-scene",
            category = "unit-module", --"since this has no effect anyway, use a custom category to avoid conflicts later
            tier = level,
            order = "a["..effectType.."]-a["..effectType.."-module-"..level.."]",
            stack_size = 50,
            effect = {}
        }
        newMod.effect[effectType] = {bonus = -bonusMultiplier * level / 100.0}

        data:extend({newMod})
    end
end

function cookingwithbeaconslib.private.add_all_unit_modules()
    for i = 1,cookingwithbeaconslib.private.get_num_bits_for_module_effects() do
        cookingwithbeaconslib.private.add_unit_module_if_not_existing("productivity",2^(i-1), 1)
    end
    for i = 1,cookingwithbeaconslib.private.get_num_bits_for_module_effects() do
        cookingwithbeaconslib.private.add_unit_module_if_not_existing("speed",2^(i-1), 1)
    end
    for i = 1,cookingwithbeaconslib.private.get_num_bits_for_module_effects() do
        cookingwithbeaconslib.private.add_unit_module_if_not_existing("consumption",2^(i-1), -1)
    end
    for i = 1,cookingwithbeaconslib.private.get_num_bits_for_module_effects() do
        cookingwithbeaconslib.private.add_unit_module_if_not_existing("pollution",2^(i-1), -1)
    end
    if not data.raw["module-category"]["unit-module"] then
        data:extend({
            {
                type = "module-category",
                name = "unit-module"
            }
        })
    end
end

function cookingwithbeaconslib.private.add_hidden_beacon_and_unit_modules()

    cookingwithbeaconslib.private.add_hidden_beacon()
    cookingwithbeaconslib.private.add_all_unit_modules()

end

function cookingwithbeaconslib.public.set_productivity_limitations(limitation, limitation_message_key)

    assert(limitation,"CookingWithBeaconsLib: cannot set productivity limitations as limitation was not provided")
    assert(limitation_message_key, "CookingWithBeaconsLib: cannot set productivity limitations as limitation was not provided")

    for _, mod in pairs(data.raw.module) do
        if string.sub(mod.name,1,#"positive-unit-module-productivity-") == "positive-unit-module-productivity-" then
            mod.limitation = limitation
            mod.limitation_message_key = limitation_message_key
        end
        if string.sub(mod.name,1,#"negative-unit-module-productivity-") == "negative-unit-module-productivity-" then
            mod.limitation = limitation
            mod.limitation_message_key = limitation_message_key
        end
    end
end