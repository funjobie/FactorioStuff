if not cookingwithbeaconslib then
    log("CookingWithBeaconsLib mod was not initialzed; exiting")
    local force = nil
    force.exit = true
end

cookingwithbeaconslib.public.enable_feature_human_powered()
cookingwithbeaconslib.public.enable_feature_robot_powered()
cookingwithbeaconslib.public.enable_feature_tile_bonus()
cookingwithbeaconslib.public.enable_feature_research_bonus()
cookingwithbeaconslib.public.enable_feature_custom_beacon_shapes()
cookingwithbeaconslib.public.enable_feature_concave_hull_beacon_shapes()

require('prototypes/manual-assembler')
require('prototypes/research-boni')
require('prototypes/blue-beacon-mk2')
require('prototypes/green-beacon-mk2')
require('prototypes/red-beacon-mk2')
require('prototypes/robo-assembler')
