function enableFeatureHiddenBeacons()
    if not global.hidden_beacons.feature_enabled then
        global.hidden_beacons.feature_enabled = true
        
        global.hidden_beacons.listOfEntityTypesSupportingBeacons = {"furnace", "assembling-machine", "mining-drill", "rocket-silo"}
        global.hidden_beacons.entityTypesSupportingBeacons = {}
        for _, str in pairs(global.hidden_beacons.listOfEntityTypesSupportingBeacons) do
            global.hidden_beacons.entityTypesSupportingBeacons[str] = true
        end
        
        global.hidden_beacons.entity_specific_boni = {}
        global.hidden_beacons.map_entity_to_hidden_beacon = {}
    end
end

function doesEntitySupportBeacons(entity)
    return not (global.hidden_beacons.entityTypesSupportingBeacons[entity.type] == nil)
end

local function createListOfUnitModules(listToInsert, levelToCheck, moduleType)
    local dirPrefix
    if levelToCheck > 0 then dirPrefix = "positive-" else dirPrefix = "negative-" end    
    local tmp = math.abs(levelToCheck)
    local level = 1
    while tmp > 0 do
        if tmp % 2 == 1 then
            table.insert(listToInsert, dirPrefix.."unit-module-"..moduleType.."-" .. tostring(level))
        end
        level = bit32.lshift(level,1)
        tmp = bit32.rshift(tmp,1)
    end
end

local function createListOfAllUnitModules(productivity, speed, consumption, pollution)
    local listToInsert = {}
    --flip sign for pollution and consumption to choose correct modules
    createListOfUnitModules(listToInsert, productivity, "productivity")
    createListOfUnitModules(listToInsert, speed, "speed")
    createListOfUnitModules(listToInsert, -consumption, "consumption")
    createListOfUnitModules(listToInsert, -pollution, "pollution")
    return listToInsert
end

local function insertModulesIntoBeacon(beacon, listToInsert)

    local inv = beacon.get_module_inventory()
    inv.clear()
    for _, item in pairs(listToInsert) do
        inv.insert({name=item, count=1})
    end
    
end

function reapplyAllHiddenBeaconEffects(entity)
    if global.hidden_beacons.map_entity_to_hidden_beacon[entity.unit_number] and global.hidden_beacons.map_entity_to_hidden_beacon[entity.unit_number].valid and (global.hidden_beacons.entity_specific_boni[entity.unit_number]) then
        local tileBonusBeacon = global.hidden_beacons.map_entity_to_hidden_beacon[entity.unit_number]
        local totalBoniToApply = zeroEffects()
        for _, entityBoni in pairs(global.hidden_beacons.entity_specific_boni[entity.unit_number]) do
            totalBoniToApply = addBonusEffects(totalBoniToApply, entityBoni)
        end
        local moduleList = createListOfAllUnitModules(
            totalBoniToApply.productivity.bonus*100, totalBoniToApply.speed.bonus*100, totalBoniToApply.consumption.bonus*100, totalBoniToApply.pollution.bonus*100)
        insertModulesIntoBeacon(tileBonusBeacon, moduleList)
    end
end

function hiddenBeacons_on_built_pre_boni(entity)
    if doesEntitySupportBeacons(entity) then
        global.hidden_beacons.entity_specific_boni[entity.unit_number] = {}
        
        local newEntity = entity.surface.create_entity{name = "cwb-hidden-bonus-beacon", position = entity.position, force = entity.force}
        newEntity.destructible = false
        newEntity.minable = false
        
        global.hidden_beacons.map_entity_to_hidden_beacon[entity.unit_number] = newEntity
    end
end

function hiddenBeacons_on_built_post_boni(entity)
    reapplyAllHiddenBeaconEffects(entity)
end

function hiddenBeacons_on_unbuilt(entity)
    if doesEntitySupportBeacons(entity) then
        global.hidden_beacons.entity_specific_boni[entity.unit_number] = nil
        if global.hidden_beacons.map_entity_to_hidden_beacon[entity.unit_number].valid then
            global.hidden_beacons.map_entity_to_hidden_beacon[entity.unit_number].destroy()
        end
        global.hidden_beacons.map_entity_to_hidden_beacon[entity.unit_number] = nil
    end
end