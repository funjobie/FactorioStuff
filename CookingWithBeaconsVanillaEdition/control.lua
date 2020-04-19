--[[
credits:

factorio devs

--]]

local function init_globals()
    
    global.version = "0.1.2"
    
    remote.call("CookingWithBeaconsLib", "enable_feature_human_powered")
    remote.call("CookingWithBeaconsLib", "make_human_powered_entity_require_tools", {name="manual-assembler", listOfTools={{"infinity-screwdriver"},{"repair-pack"}}, durabilityLosPerLaborUnit=0.1})

    remote.call("CookingWithBeaconsLib", "enable_feature_robot_powered")
    remote.call("CookingWithBeaconsLib", "make_entity_robot_powered", {name="robo-assembler",requestThreshold=0.75})
    
    remote.call("CookingWithBeaconsLib", "enable_feature_tile_bonus")
    
    local furnaceDefaultBoni = {} --no boni
    local furnaceBackgroundBoni = {}
    --[[ no boni, therefore no need to provide them
    for _, tile in pairs({"grass-1","grass-2","grass-3","grass-4"}) do
        furnaceBackgroundBoni[tile] ={}
    end
    for _, tile in pairs({"dry-dirt","dirt-1","dirt-2","dirt-3","dirt-4","dirt-5","dirt-6","dirt-7"}) do
        furnaceBackgroundBoni[tile] ={}
    end
    --]]
    for _, tile in pairs({"sand-1","sand-2","sand-3"}) do
        furnaceBackgroundBoni[tile] ={speed = {bonus = 0.2},consumption = {bonus = -0.2}}
    end
    for _, tile in pairs({"red-desert-0","red-desert-1","red-desert-2","red-desert-3"}) do
        furnaceBackgroundBoni[tile] ={speed = {bonus = 0.4},consumption = {bonus = -0.4}}
    end
    remote.call("CookingWithBeaconsLib", "give_tile_bonus_to_entity", {name="stone-furnace", mode="background", defaultBoni=furnaceDefaultBoni,tileBoni=furnaceBackgroundBoni})
    remote.call("CookingWithBeaconsLib", "give_tile_bonus_to_entity", {name="steel-furnace", mode="background", defaultBoni=furnaceDefaultBoni,tileBoni=furnaceBackgroundBoni})
    remote.call("CookingWithBeaconsLib", "give_tile_bonus_to_entity", {name="electric-furnace", mode="background", defaultBoni=furnaceDefaultBoni,tileBoni=furnaceBackgroundBoni})
    
    local furnaceForegroundBoni = {}
    for _, tile in pairs({"stone-path"}) do
        furnaceForegroundBoni[tile] ={productivity = {bonus = 0.1}}
    end
    for _, tile in pairs({"concrete", "hazard-concrete-left", "hazard-concrete-right"}) do
        furnaceForegroundBoni[tile] ={productivity = {bonus = 0.15}}
    end
    for _, tile in pairs({"refined-concrete", "refined-hazard-concrete-left", "refined-hazard-concrete-right"}) do
        furnaceForegroundBoni[tile] ={productivity = {bonus = 0.2}}
    end
    remote.call("CookingWithBeaconsLib", "give_tile_bonus_to_entity", {name="stone-furnace", mode="foreground", defaultBoni=furnaceDefaultBoni,tileBoni=furnaceForegroundBoni})
    remote.call("CookingWithBeaconsLib", "give_tile_bonus_to_entity", {name="steel-furnace", mode="foreground", defaultBoni=furnaceDefaultBoni,tileBoni=furnaceForegroundBoni})
    remote.call("CookingWithBeaconsLib", "give_tile_bonus_to_entity", {name="electric-furnace", mode="foreground", defaultBoni=furnaceDefaultBoni,tileBoni=furnaceForegroundBoni})
    --todo add this also for other crafting entities?
    
    remote.call("CookingWithBeaconsLib", "enable_feature_research_bonus")
    
    local entityBoniMultiplier = {productivity={multiplier=0.25,levelZeroOffset=0.25},speed={multiplier=0.20,levelZeroOffset=0}}
    local entities = {"manual-assembler"}
    remote.call("CookingWithBeaconsLib", "give_research_bonus_to_entities", {uniqueBonusName="improvements-for-manual-assembler", entities = entities, boniMultiplier = entityBoniMultiplier})

    entityBoniMultiplier = {pollution={multiplier=-0.1,levelZeroOffset=0}}
    entities = {
        "assembling-machine-1",
        "assembling-machine-2",
        "assembling-machine-3",
        "oil-refinery",
        "chemical-plant",
        "centrifuge",
        "robo-assembler"
    }
    remote.call("CookingWithBeaconsLib", "give_research_bonus_to_entities", {uniqueBonusName="pollution-reduction-for-all-assemblers", entities = entities, boniMultiplier = entityBoniMultiplier})
    
    entityBoniMultiplier = {consumption={multiplier=-0.1,levelZeroOffset=0}}
    entities = {"electric-furnace"}
    remote.call("CookingWithBeaconsLib", "give_research_bonus_to_entities", {uniqueBonusName="power-reduction-for-electric-furnaces", entities = entities, boniMultiplier = entityBoniMultiplier})

    entityBoniMultiplier = {productivity={multiplier=0.04,levelZeroOffset=0},speed={multiplier=0.05,levelZeroOffset=0}}
    entities = 
    {
        "assembling-machine-1",
        "assembling-machine-2",
        "assembling-machine-3",
        "robo-assembler"
    }
    remote.call("CookingWithBeaconsLib", "give_research_bonus_to_entities", {uniqueBonusName="upgrades-for-assemblers", entities = entities, boniMultiplier = entityBoniMultiplier})
    
    entityBoniMultiplier = {pollution={multiplier=-0.1,levelZeroOffset=0}}
    entities = {"electric-mining-drill"}
    remote.call("CookingWithBeaconsLib", "give_research_bonus_to_entities", {uniqueBonusName="pollution-reduction-for-electric-mining-drill", entities = entities, boniMultiplier = entityBoniMultiplier})
    
    remote.call("CookingWithBeaconsLib", "enable_feature_custom_beacon_shapes")
    
    local sphereShape = remote.call("CookingWithBeaconsLib", "create_sphere_custom_shape", {radius = 12})
    local transmission = {
        {
            speed=       "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return speed        * distribution_effectivity * strength end",
            consumption= "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return consumption  * distribution_effectivity * strength end",
            productivity="function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return productivity * distribution_effectivity * strength end",
            pollution=   "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return pollution    * distribution_effectivity * strength end",
        },
    }
    
    remote.call("CookingWithBeaconsLib", "give_custom_beacon_shape_to_entity", {name="green-beacon-mk2", shape=sphereShape, transmission=transmission})

    --[[
    local diamondShape = {
        "OOOOXOOOO",
        "OOOXXXOOO",
        "OOXXXXXOO",
        "OXXXXXXXO",
        "XXXXEXXXX",
        "OXXXXXXXO",
        "OOXXXXXOO",
        "OOOXXXOOO",
        "OOOOXOOOO",
    }
    --]]
    local diamondShape = remote.call("CookingWithBeaconsLib", "create_diamond_custom_shape", {radius = 9})
    local entityFilter = {{type=nil, name=nil, crafting_category="smelting"}}
    local nightOrDay = "function(tick) local mod = tick % 25000 if mod >= 25000*0.25 and mod < 25000*0.75 then return 2 else return 1 end end"
    local zeroEffect = "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0 end"
    local prodBuff = "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return productivity * distribution_effectivity end"
    local speedDebuff = "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return -1 end"
    local prodDebuff = "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return -1 end"
    transmission = {
        {speed=speedDebuff,consumption=zeroEffect,productivity=prodDebuff,pollution=zeroEffect},
        {speed=zeroEffect,consumption=zeroEffect,productivity=prodBuff,pollution=zeroEffect},
    }
    remote.call("CookingWithBeaconsLib", "give_custom_beacon_shape_to_entity", {name="red-beacon-mk2", shape=diamondShape, entityFilter=entityFilter, transmission=transmission, timeDependentTransmission=nightOrDay})

    remote.call("CookingWithBeaconsLib", "enable_feature_concave_hull_beacon_shapes")
    remote.call("CookingWithBeaconsLib", "set_concave_hull_creating_group", {hullName="hull1", entities={"concrete-energy-field","concrete-energy-field-gate"}})
    local entityFilter = {{type="mining-drill", name=nil, crafting_category=nil}}
    transmission = {
        {
            speed=       "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0.5 end",
            consumption= "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0 end", --rather than increasing the consumption of users, it is handled as consumption for the concave hull
            productivity="function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0 end",
            pollution=   "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0.25 end",
        },
    }
    remote.call("CookingWithBeaconsLib", "give_concave_hull_beacon_shape_to_entity", {name="blue-beacon-mk2", hullName="hull1", entityFilter=entityFilter, transmission=transmission, powerConsumption=20, powerExponent=1.2})
    
    remote.call("CookingWithBeaconsLib", "enable_feature_forbidden_beacon_overlap")
    remote.call("CookingWithBeaconsLib", "set_forbidden_beacon_overlap_for_entity", {name="red-beacon-mk2", forbidden={"red-beacon-mk2", "green-beacon-mk2", "blue-beacon-mk2"}})
    remote.call("CookingWithBeaconsLib", "set_forbidden_beacon_overlap_for_entity", {name="green-beacon-mk2", forbidden={"green-beacon-mk2", "red-beacon-mk2", "blue-beacon-mk2"}})
    remote.call("CookingWithBeaconsLib", "set_forbidden_beacon_overlap_for_entity", {name="blue-beacon-mk2", forbidden={"green-beacon-mk2", "red-beacon-mk2", "blue-beacon-mk2"}})
    
end

script.on_init(function()
    init_globals()
end)

local function updateModVersion()

    if global.version == "0.1.1" then
        
        entities = {
            "robo-assembler"
        }
        remote.call("CookingWithBeaconsLib", "add_entities_to_research_bonus_group", {uniqueBonusName="pollution-reduction-for-all-assemblers", entities = entities})
        
        entities = 
        {
            "robo-assembler"
        }
        remote.call("CookingWithBeaconsLib", "add_entities_to_research_bonus_group", {uniqueBonusName="upgrades-for-assemblers", entities = entities})
        
        game.print("updated CookingWithBeaconsVanillaEdition from 0.1.1 to 0.1.2")
    end

    global.version = "0.1.2"

end

script.on_configuration_changed(function()
    updateModVersion()
end)
