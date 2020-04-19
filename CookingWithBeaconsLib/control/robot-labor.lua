function enableFeatureRobotPowered()
    if not global.robot_labor.feature_enabled then
        global.robot_labor.feature_enabled = true
        global.robot_labor.temporaryChargingRobots = {}
        global.robot_labor.temporaryForceForChargingRobots = game.create_force("robot-labor-force")
        --todo this may not be right if there are additional forces being created... mod interoperability issues
        game.forces["player"].set_friend(global.robot_labor.temporaryForceForChargingRobots, true)
        
        global.robot_labor.listOfRoboPoweredEntities = {}
        global.robot_labor.mapOfLastKnownRoboCapacity = {}
        global.robot_labor.mapOfEntityToChargeTasks = {}
        global.robot_labor.mapChargeTaskToEntity = {}
        global.robot_labor.slowUpdateQueue = {}
    end
end

function makeEntityRobotPowered(args, args2)

    assert(global.robot_labor.feature_enabled, "Library usage error make_entity_robot_powered: feature was not enabled yet via enable_feature_robot_powered().")

    assert(args, "Library usage error make_entity_robot_powered: arguments are missing.")
    assert(type(args) == "table", "Library usage error make_entity_robot_powered: arguments must be given as a table, but the type is " .. type(args))
    assert(not args2, "Library usage error make_entity_robot_powered: too many arguments given. arguments have to be provided in a table as one argument.")

    local name = args.name
    args.name = nil
    local requestThreshold = args.requestThreshold
    args.requestThreshold = nil
    for k,_ in pairs(args) do error("Library usage error make_entity_robot_powered: unsupported argument " .. k) end
    
    assert(name, "Library usage error make_entity_robot_powered: name was not provided")
    assert(type(name) == "string", "Library usage error make_entity_robot_powered: name was given but it is not a string but a " .. type(name))
    assert(global.robot_labor.listOfRoboPoweredEntities[name] == nil, "Library usage error make_entity_robot_powered: entity " .. name .. " is already setup to be robot-powered, setting it again is not possible.")
    assert(game.entity_prototypes[name], "Library usage error make_entity_robot_powered: name was given but such an entity doesn't exist. name is: " .. name)
    
    assert(requestThreshold, "Library usage error make_entity_robot_powered: requestThreshold was not provided")
    assert(type(requestThreshold) == "number", "Library usage error make_entity_robot_powered: requestThreshold was given but it is not a number but a " .. type(requestThreshold))
    
    global.robot_labor.listOfRoboPoweredEntities[name] = {}
    global.robot_labor.listOfRoboPoweredEntities[name].requestThreshold = requestThreshold
end

local function createNewChargeTasks(entity, currentAmount, capacity)
    local unit_number = entity.unit_number
    local joulPerFluid = game.fluid_prototypes["robot-labor"].fuel_value
    local requestThreshold = global.robot_labor.listOfRoboPoweredEntities[entity.name].requestThreshold
    if (currentAmount / capacity) < requestThreshold then
        local entityBoundingBox = game.entity_prototypes[entity.name].collision_box
        local entityWidth = entityBoundingBox.right_bottom.x - entityBoundingBox.left_top.x
        local entityHeight = entityBoundingBox.right_bottom.y - entityBoundingBox.left_top.y
        local numberOfRequestsToMake = math.ceil(joulPerFluid * (capacity - currentAmount) / (global.robot_labor.mapOfLastKnownRoboCapacity[unit_number] or 999999999999))
        if global.robot_labor.mapOfEntityToChargeTasks[unit_number] == nil then global.robot_labor.mapOfEntityToChargeTasks[unit_number] = {} end
        numberOfRequestsToMake = numberOfRequestsToMake - #global.robot_labor.mapOfEntityToChargeTasks[unit_number]
        while numberOfRequestsToMake > 0 do
            numberOfRequestsToMake = numberOfRequestsToMake - 1
            local newPosition = {entity.position.x + math.random() * entityWidth - (entityWidth / 2),entity.position.y + math.random() * entityHeight - (entityHeight / 2)}
            local newRequestEntity = entity.surface.create_entity{position=newPosition, name="robot-labor-charge-task", force=entity.force}
            if newRequestEntity then
                newRequestEntity.order_deconstruction(entity.force)
                table.insert(global.robot_labor.mapOfEntityToChargeTasks[unit_number], newRequestEntity)
                global.robot_labor.mapChargeTaskToEntity[newRequestEntity.unit_number] = entity
            else
                game.print("AssemblerTypesLib: failed to create the entity robot-labor-charge-task")
            end
        end
    else
        global.robot_labor.slowUpdateQueue[entity.unit_number] = entity
    end
end

local function robotLaborQueueChargeIfRequired(entity)
    local fluidBoxes = entity.fluidbox
    if fluidBoxes then
        for fluidBoxIndex = 1,#fluidBoxes do
            local filter = fluidBoxes.get_filter(fluidBoxIndex)
            if filter and filter.name == "robot-labor" then
                local currentAmount = 0
                if fluidBoxes[fluidBoxIndex] and fluidBoxes[fluidBoxIndex].amount then currentAmount = fluidBoxes[fluidBoxIndex].amount end
                local capacity = fluidBoxes.get_capacity(fluidBoxIndex)
                createNewChargeTasks(entity, currentAmount, capacity)
            end
        end
    end
end

local function robotLaborProcessSlowUpdateQueue()
    local entitiesToUpdate = {}
    for _, e in pairs(global.robot_labor.slowUpdateQueue) do table.insert(entitiesToUpdate, e) end
    global.robot_labor.slowUpdateQueue = {}
    for _, e in pairs(entitiesToUpdate) do if e.valid then robotLaborQueueChargeIfRequired(e) end end
end

local function robotLaborReleaseDischargingRobots()
    
    if not global.robot_labor.feature_enabled then return end
    
    local listOfFinishedRobotUnitNumbers = {}
    for robotUnitNumber, properties in pairs(global.robot_labor.temporaryChargingRobots) do
        properties.numTicks = properties.numTicks - 5
        if properties.numTicks <= 0 then table.insert(listOfFinishedRobotUnitNumbers,robotUnitNumber) end
    end
    for _, robotUnitNumber in pairs(listOfFinishedRobotUnitNumbers) do

        local properties = global.robot_labor.temporaryChargingRobots[robotUnitNumber]
        --check if valid, since they could be destroyed in the meantime
        if properties.robotEntity and properties.robotEntity.valid then
            properties.robotEntity.force = properties.originalForce
        end
        if properties.tempSparkEntity and properties.tempSparkEntity.valid then
            properties.tempSparkEntity.destroy()
        end
        global.robot_labor.temporaryChargingRobots[robotUnitNumber] = nil
    end

end

local function robotLaborChargeEntity(event)

    --robot :: LuaEntity: The robot doing the mining.
    --entity :: LuaEntity: The entity that has been mined.
    --buffer :: LuaInventory: The temporary inventory that holds the result of mining the entity.
    if event.entity and event.entity.name == "robot-labor-charge-task" and event.robot and game.fluid_prototypes["robot-labor"] then
        
        local joulPerFluid = game.fluid_prototypes["robot-labor"].fuel_value
        local energyToDistribute = event.robot.energy -- in J
        local spentEnergy = 0
        
        local entityToCharge = global.robot_labor.mapChargeTaskToEntity[event.entity.unit_number]
        global.robot_labor.mapChargeTaskToEntity[event.entity.unit_number] = nil
        if not entityToCharge or not entityToCharge.valid then return end
        global.robot_labor.mapOfEntityToChargeTasks[entityToCharge.unit_number] = removeByValue(global.robot_labor.mapOfEntityToChargeTasks[entityToCharge.unit_number], event.entity)
        global.robot_labor.mapOfLastKnownRoboCapacity[entityToCharge.unit_number] = event.robot.prototype.max_energy
        local fluidBoxes = entityToCharge.fluidbox
        if fluidBoxes then
            for fluidBoxIndex = 1,#fluidBoxes do
                local filter = fluidBoxes.get_filter(fluidBoxIndex)
                if filter and filter.name == "robot-labor" then
                    local currentAmount = 0
                    if fluidBoxes[fluidBoxIndex] and fluidBoxes[fluidBoxIndex].amount then currentAmount = fluidBoxes[fluidBoxIndex].amount end

                    local capacity = fluidBoxes.get_capacity(fluidBoxIndex)
                    local missingAmount = capacity - currentAmount --in fluid amount
                    local missingAmountJ = missingAmount * joulPerFluid
                    local energyTransfer = math.min(missingAmountJ,energyToDistribute)
                    local fluidTransfer = energyTransfer / joulPerFluid
                    
                    energyToDistribute = energyToDistribute - energyTransfer
                    spentEnergy = spentEnergy + energyTransfer
                    fluidBoxes[fluidBoxIndex] = {name="robot-labor", amount=currentAmount + fluidTransfer}
                    createNewChargeTasks(entityToCharge, currentAmount, capacity)
                end
            end
        end
        event.robot.energy = energyToDistribute
        local ticksToSuspendRobot = 5*60 * (spentEnergy / event.robot.prototype.max_energy)
        
        local originalForce = event.robot.force
        event.robot.force = global.robot_labor.temporaryForceForChargingRobots
        local tempSparkEntity = event.robot.surface.create_entity{ name="robot-labor-dummy-discharging-sparks", position=event.robot.position, force=event.robot.force }
        global.robot_labor.temporaryChargingRobots[event.robot.unit_number] = {numTicks = ticksToSuspendRobot, originalForce = originalForce, robotEntity = event.robot, tempSparkEntity = tempSparkEntity}
    end
end

local function robotLaborCleanupRobotChargeTasks(entity)
    
    if not global.robot_labor.feature_enabled then return end
    
    if entity and entity.valid and global.robot_labor.listOfRoboPoweredEntities and global.robot_labor.listOfRoboPoweredEntities[entity.name] then
        global.robot_labor.mapOfLastKnownRoboCapacity[entity.unit_number] = nil
        if global.robot_labor.mapOfEntityToChargeTasks[entity.unit_number] then
            for _, task in pairs(global.robot_labor.mapOfEntityToChargeTasks[entity.unit_number]) do
                if task.valid then
                    global.robot_labor.mapChargeTaskToEntity[task.unit_number] = nil
                    task.destroy()
                end
            end
            global.robot_labor.mapOfEntityToChargeTasks[entity.unit_number] = nil
        end
    end
end

function robotLabor_on_nth_tick_61(event)
    robotLaborProcessSlowUpdateQueue()
end

function robotLabor_on_nth_tick_5(event)
    robotLaborReleaseDischargingRobots()
end

function robotLabor_on_built(entity)
    if entity.valid and global.robot_labor.listOfRoboPoweredEntities[entity.name] then
        robotLaborQueueChargeIfRequired(entity)
    end
end

function robotLabor_on_unbuilt(entity)
    robotLaborCleanupRobotChargeTasks(entity)
end

function robotLabor_on_robot_mined_entity(event)
    robotLaborChargeEntity(event)
end