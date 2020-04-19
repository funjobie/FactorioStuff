local blueBeaconMK2 = table.deepcopy(data.raw["beacon"]["beacon"])
blueBeaconMK2.name = "blue-beacon-mk2"
blueBeaconMK2.minable.result = "blue-beacon-mk2"
blueBeaconMK2.module_specification.module_slots = 0 --use fixed effect instead of deriving the effect from the modules placed in the beacon
blueBeaconMK2.allowed_effects = {"consumption", "speed", "productivity", "pollution"}
blueBeaconMK2.energy_usage = "240kW"
blueBeaconMK2.distribution_effectivity = 0.75
blueBeaconMK2.base_picture.tint = { r = 0.6, g = 0.6, b = 1.0, a = 1.0 }
blueBeaconMK2.animation.tint = { r = 0.6, g = 0.6, b = 1.0, a = 1.0 }
data:extend({blueBeaconMK2})

local blueBeaconMK2Item = table.deepcopy(data.raw["item"]["beacon"])
blueBeaconMK2Item.name = "blue-beacon-mk2"
blueBeaconMK2Item.place_result = "blue-beacon-mk2"
blueBeaconMK2Item.icon = "__CookingWithBeaconsVanillaEdition__/graphics/icons/blue-beacon-mk2.png"
data:extend({blueBeaconMK2Item})
local blueBeaconMK2Recipe = table.deepcopy(data.raw["recipe"]["beacon"])
blueBeaconMK2Recipe.name = "blue-beacon-mk2"
blueBeaconMK2Recipe.ingredients =
{
    {"electronic-circuit", 15},
    {"advanced-circuit", 15},
    {"steel-plate", 10},
    {"copper-cable", 10},
    {"processing-unit", 5}
}
blueBeaconMK2Recipe.result = "blue-beacon-mk2"
data:extend({blueBeaconMK2Recipe})

table.insert(data.raw.technology["effect-transmission"].effects, 
{
    type = "unlock-recipe",
    recipe = "blue-beacon-mk2"
})

cookingwithbeaconslib.public.setup_concave_hull_beacon_shapes(data.raw.beacon["blue-beacon-mk2"])

local blueWall = table.deepcopy(data.raw["wall"]["stone-wall"])
blueWall.name = "concrete-energy-field"
blueWall.minable.result = "concrete-energy-field"
--blueWall.energy_usage = "240kW"
blueWall.visual_merge_group=1 --stone-wall is 0, don't merge with it
local patchFctn = function(e) e.tint = { r = 0.6, g = 0.6, b = 1.0, a = 1.0 } if e.hr_version then e.hr_version.tint = { r = 0.6, g = 0.6, b = 1.0, a = 1.0 } end end
patchFctn(blueWall.pictures.single.layers[1])
patchFctn(blueWall.pictures.straight_vertical.layers[1])
patchFctn(blueWall.pictures.straight_horizontal.layers[1])
patchFctn(blueWall.pictures.corner_right_down.layers[1])
patchFctn(blueWall.pictures.corner_left_down.layers[1])
patchFctn(blueWall.pictures.t_up.layers[1])
patchFctn(blueWall.pictures.ending_right.layers[1])
patchFctn(blueWall.pictures.ending_left.layers[1])
patchFctn(blueWall.pictures.filling)
patchFctn(blueWall.pictures.water_connection_patch.sheets[1])
patchFctn(blueWall.pictures.gate_connection_patch.sheets[1])
data:extend({blueWall})

local blueWallItem = table.deepcopy(data.raw["item"]["stone-wall"])
blueWallItem.name = "concrete-energy-field"
blueWallItem.place_result = "concrete-energy-field"
blueWallItem.icon = "__CookingWithBeaconsVanillaEdition__/graphics/icons/concrete-energy-field.png"
data:extend({blueWallItem})
local blueWallRecipe = table.deepcopy(data.raw["recipe"]["stone-wall"])
blueWallRecipe.name = "concrete-energy-field"
blueWallRecipe.ingredients = {{"concrete", 5},{"copper-cable", 12}}
blueWallRecipe.result = "concrete-energy-field"
data:extend({blueWallRecipe})

table.insert(data.raw.technology["effect-transmission"].effects, 
{
    type = "unlock-recipe",
    recipe = "concrete-energy-field"
})

local blueGate = table.deepcopy(data.raw["gate"]["gate"])
blueGate.name = "concrete-energy-field-gate"
blueGate.minable.result = "concrete-energy-field-gate"
--blueGate.energy_usage = "240kW"
blueGate.visual_merge_group=1 --stone-wall is 0, don't merge with it
local patchFctn = function(e) e.tint = { r = 0.6, g = 0.6, b = 1.0, a = 1.0 } if e.hr_version then e.hr_version.tint = { r = 0.6, g = 0.6, b = 1.0, a = 1.0 } end end
patchFctn(blueGate.vertical_animation.layers[1])
patchFctn(blueGate.horizontal_animation.layers[1])
patchFctn(blueGate.horizontal_rail_animation_left.layers[1])
patchFctn(blueGate.horizontal_rail_animation_right.layers[1])
patchFctn(blueGate.vertical_rail_animation_left.layers[1])
patchFctn(blueGate.vertical_rail_animation_right.layers[1])
patchFctn(blueGate.vertical_rail_base)
patchFctn(blueGate.horizontal_rail_base)
patchFctn(blueGate.wall_patch.layers[1])
data:extend({blueGate})

local blueGateItem = table.deepcopy(data.raw["item"]["gate"])
blueGateItem.name = "concrete-energy-field-gate"
blueGateItem.place_result = "concrete-energy-field-gate"
blueGateItem.icon = "__CookingWithBeaconsVanillaEdition__/graphics/icons/concrete-energy-field-gate.png"
data:extend({blueGateItem})
local blueGateRecipe = table.deepcopy(data.raw["recipe"]["gate"])
blueGateRecipe.name = "concrete-energy-field-gate"
blueGateRecipe.ingredients = {{"concrete-energy-field", 1}, {"steel-plate", 2}, {"electronic-circuit", 2}}
blueGateRecipe.result = "concrete-energy-field-gate"
data:extend({blueGateRecipe})

table.insert(data.raw.technology["effect-transmission"].effects, 
{
    type = "unlock-recipe",
    recipe = "concrete-energy-field-gate"
})