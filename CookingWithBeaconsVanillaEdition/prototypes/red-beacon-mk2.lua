local redBeaconMK2 = table.deepcopy(data.raw["beacon"]["beacon"])
redBeaconMK2.name = "red-beacon-mk2"
redBeaconMK2.minable.result = "red-beacon-mk2"
redBeaconMK2.allowed_effects = {"consumption", "speed", "productivity", "pollution"}
redBeaconMK2.energy_usage = "720kW"
redBeaconMK2.distribution_effectivity = 1.0
redBeaconMK2.base_picture.tint = { r = 1.0, g = 0.6, b = 0.6, a = 1.0 }
redBeaconMK2.animation.tint = { r = 1.0, g = 0.6, b = 0.6, a = 1.0 }
data:extend({redBeaconMK2})

local redBeaconMK2Item = table.deepcopy(data.raw["item"]["beacon"])
redBeaconMK2Item.name = "red-beacon-mk2"
redBeaconMK2Item.place_result = "red-beacon-mk2"
redBeaconMK2Item.icon = "__CookingWithBeaconsVanillaEdition__/graphics/icons/red-beacon-mk2.png"
data:extend({redBeaconMK2Item})
local redBeaconMK2Recipe = table.deepcopy(data.raw["recipe"]["beacon"])
redBeaconMK2Recipe.name = "red-beacon-mk2"
redBeaconMK2Recipe.ingredients =
{
    {"electronic-circuit", 15},
    {"advanced-circuit", 15},
    {"steel-plate", 10},
    {"copper-cable", 10},
    {"processing-unit", 5}
}
redBeaconMK2Recipe.result = "red-beacon-mk2"
data:extend({redBeaconMK2Recipe})

table.insert(data.raw.technology["effect-transmission"].effects, 
{
    type = "unlock-recipe",
    recipe = "red-beacon-mk2"
})

cookingwithbeaconslib.public.setup_custom_beacon_shapes(data.raw.beacon["red-beacon-mk2"])