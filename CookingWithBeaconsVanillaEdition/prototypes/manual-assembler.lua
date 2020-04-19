local manualAssembler = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
manualAssembler.name = "manual-assembler"
manualAssembler.minable.result = "manual-assembler"
manualAssembler.energy_usage = "75W"
manualAssembler.crafting_speed = 1.5
manualAssembler.module_specification =
{
    module_slots = 1
}
manualAssembler.allowed_effects = {"consumption", "speed", "productivity", "pollution"}
manualAssembler.animation.layers[1].tint = { r = 1.0, g = 1.0, b = 0.6, a = 1.0 }
manualAssembler.animation.layers[1].hr_version.tint = { r = 1.0, g = 1.0, b = 0.6, a = 1.0 }
data:extend({manualAssembler})

local manualAssemblerItem = table.deepcopy(data.raw["item"]["assembling-machine-1"])
manualAssemblerItem.name = "manual-assembler"
manualAssemblerItem.place_result = "manual-assembler"
manualAssemblerItem.icon = "__CookingWithBeaconsVanillaEdition__/graphics/icons/manual-assembler.png"
manualAssemblerItem.order = "a[assembling-machine-0]"
data:extend({manualAssemblerItem})
local manualAssemblerRecipe = table.deepcopy(data.raw["recipe"]["assembling-machine-1"])
manualAssemblerRecipe.name = "manual-assembler"
manualAssemblerRecipe.ingredients =
{
    {"iron-gear-wheel", 5},
    {"iron-plate", 9}
}
manualAssemblerRecipe.result = "manual-assembler"
manualAssemblerRecipe.enabled = true
data:extend({manualAssemblerRecipe})

cookingwithbeaconslib.public.make_entity_human_powered(data.raw["assembling-machine"]["manual-assembler"])
data:extend({
    {
        type = "tool",
        name = "infinity-screwdriver",
        icon = "__CookingWithBeaconsVanillaEdition__/graphics/icons/screwdriver.png",
        icon_size = 64, icon_mipmaps = 1,
        subgroup = "tool",
        order = "z[infinity-screwdriver]",
        stack_size = 1,
        durability = 1,
        infinite = true,
    },
    {
        type = "recipe",
        name = "infinity-screwdriver",
        ingredients =
        {
            {"electronic-circuit", 2},
            {"iron-gear-wheel", 2},
            {"steel-plate", 2}
        },
        result = "infinity-screwdriver",
        enabled = false,
    },
    {
        type = "technology",
        name = "infinity-screwdriver-tech",
        icon_size = 128,
        icon = "__CookingWithBeaconsVanillaEdition__/graphics/technologies/screwdriver.png",
        enabled = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "infinity-screwdriver"
            },
        },
        unit =
        {
            count = 50,
            ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
            time = 30
        },
        prerequisites = {'logistic-science-pack'},
        order = "c-a"
    },
})