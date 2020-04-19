local greenBeaconMK2 = table.deepcopy(data.raw["beacon"]["beacon"])
greenBeaconMK2.name = "green-beacon-mk2"
greenBeaconMK2.minable.result = "green-beacon-mk2"
greenBeaconMK2.allowed_effects = {"consumption"}
greenBeaconMK2.energy_usage = "240kW"
greenBeaconMK2.distribution_effectivity = 0.75
greenBeaconMK2.base_picture.tint = { r = 0.6, g = 1.0, b = 0.6, a = 1.0 }
greenBeaconMK2.animation.tint = { r = 0.6, g = 1.0, b = 0.6, a = 1.0 }
data:extend({greenBeaconMK2})

local greenBeaconMK2Item = table.deepcopy(data.raw["item"]["beacon"])
greenBeaconMK2Item.name = "green-beacon-mk2"
greenBeaconMK2Item.place_result = "green-beacon-mk2"
greenBeaconMK2Item.icon = "__CookingWithBeaconsVanillaEdition__/graphics/icons/green-beacon-mk2.png"
data:extend({greenBeaconMK2Item})
local greenBeaconMK2Recipe = table.deepcopy(data.raw["recipe"]["beacon"])
greenBeaconMK2Recipe.name = "green-beacon-mk2"
greenBeaconMK2Recipe.ingredients =
{
    {"electronic-circuit", 15},
    {"advanced-circuit", 15},
    {"steel-plate", 10},
    {"copper-cable", 10},
    {"processing-unit", 5}
}
greenBeaconMK2Recipe.result = "green-beacon-mk2"
data:extend({greenBeaconMK2Recipe})

table.insert(data.raw.technology["effect-transmission"].effects, 
{
    type = "unlock-recipe",
    recipe = "green-beacon-mk2"
})

cookingwithbeaconslib.public.setup_custom_beacon_shapes(data.raw.beacon["green-beacon-mk2"])