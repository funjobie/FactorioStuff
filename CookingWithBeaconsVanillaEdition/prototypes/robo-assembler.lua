local roboAssembler = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
roboAssembler.name = "robo-assembler"
roboAssembler.icon = "__CookingWithBeaconsVanillaEdition__/graphics/icons/robo-assembler.png"
roboAssembler.minable.result = "robo-assembler"
roboAssembler.crafting_categories = {"robo-crafting"}
roboAssembler.crafting_speed = 1.0
roboAssembler.module_specification =
{
    module_slots = 3
}
roboAssembler.animation.layers[1].tint = { r = 1.0, g = 0.6, b = 0.6, a = 1.0 }
roboAssembler.animation.layers[1].hr_version.tint = { r = 1.0, g = 0.6, b = 0.6, a = 1.0 }
data:extend({roboAssembler})

local roboAssemblerItem = table.deepcopy(data.raw["item"]["assembling-machine-3"])
roboAssemblerItem.name = "robo-assembler"
roboAssemblerItem.place_result = "robo-assembler"
roboAssemblerItem.icon = "__CookingWithBeaconsVanillaEdition__/graphics/icons/robo-assembler.png"
roboAssemblerItem.order = "b[assembling-machine-2z]" --after assembler 2, before assembler 3
data:extend({roboAssemblerItem})
local roboAssemblerRecipe = table.deepcopy(data.raw["recipe"]["assembling-machine-3"])
roboAssemblerRecipe.name = "robo-assembler"
roboAssemblerRecipe.ingredients =
{
    {"advanced-circuit", 5},
    {"assembling-machine-2", 1}
}
roboAssemblerRecipe.result = "robo-assembler"
roboAssemblerRecipe.enabled = false
data:extend({roboAssemblerRecipe})

cookingwithbeaconslib.public.make_entity_robot_powered(data.raw["assembling-machine"]["robo-assembler"])

data:extend({
    {
        type = "recipe-category",
        name = "robo-crafting"
    },
    {
        type = "technology",
        name = "robo-assembler",
        icon_size = 128,
        icon = "__CookingWithBeaconsVanillaEdition__/graphics/technologies/robo-assembler.png",
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "robo-assembler"
            },
        },
        unit =
        {
            count = 100,
            ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}},
            time = 30
        },
        prerequisites = {'construction-robotics'},
        order = "c-a"
    },
    {
        type = "technology",
        name = "robo-recipe-standardization",
        icon_size = 128,
        icon = "__CookingWithBeaconsVanillaEdition__/graphics/technologies/robo-recipe-standardization.png",
        effects =
        {
            --to be added in loops below
        },
        unit =
        {
            count = 6000,
            ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}, {"space-science-pack", 1}},
            time = 30
        },
        prerequisites = {"space-science-pack"}, --more added in loops below
        order = "c-a"
    },
})

local function replaceUnlockAddPrerequisite(name, replacement, prerequisite)
    local res = {}
    for _, t in pairs(data.raw.technology) do
        if t.effects then
            for _, e in pairs(t.effects) do
                if e.recipe and e.recipe == name then 
                    e.recipe = replacement
                    table.insert(t.prerequisites, prerequisite)
                    table.insert(res, t.name)
                end
            end
        end
    end
    return res
end

local function createRoboRecipeClone(name)
    local roboRecipe = table.deepcopy(data.raw["recipe"][name])
    roboRecipe.name = "robo-" .. name
    roboRecipe.category = "robo-crafting",
    data:extend({roboRecipe})
end

local function addToStandardizationTech(name, techNames)
    table.insert(data.raw.technology["robo-recipe-standardization"].effects, 
    {
        type = "unlock-recipe",
        recipe = name
    })
    for _, t in pairs(techNames) do
        table.insert(data.raw.technology["robo-recipe-standardization"].prerequisites, t)
    end
end

local function allowProductivity(name)
    table.insert(data.raw.module["productivity-module"].limitation, name)
    table.insert(data.raw.module["productivity-module-2"].limitation, name)
    table.insert(data.raw.module["productivity-module-3"].limitation, name)
end

local function converToRoboCrafting(name)
    techNames = replaceUnlockAddPrerequisite(name, "robo-" .. name, "robo-assembler")
    createRoboRecipeClone(name)
    addToStandardizationTech(name, techNames)
    allowProductivity("robo-"..name)
end

converToRoboCrafting("processing-unit")
converToRoboCrafting("rocket-control-unit")
