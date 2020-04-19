function removeByValue(list, value)
    local result = {}
    for _, entry in pairs(list) do
        if entry ~= value then 
            table.insert(result, entry) 
        end
    end
    return result
end

function zeroEffects()
    return
    {
        productivity = {bonus=0},
        speed = {bonus=0},
        consumption = {bonus=0},
        pollution = {bonus=0},
    }
end

function zeroBox()
    return {
        left_top=    {x=0, y=0},
        right_bottom={x=0, y=0}
    }
end

function addBonusEffects(effects1, effects2)
    local result = zeroEffects()
    if effects1.productivity then result.productivity.bonus = result.productivity.bonus + effects1.productivity.bonus end
    if effects1.speed        then result.speed.bonus        = result.speed.bonus        + effects1.speed.bonus        end
    if effects1.consumption  then result.consumption.bonus  = result.consumption.bonus  + effects1.consumption.bonus  end
    if effects1.pollution    then result.pollution.bonus    = result.pollution.bonus    + effects1.pollution.bonus    end
    if effects2.productivity then result.productivity.bonus = result.productivity.bonus + effects2.productivity.bonus end
    if effects2.speed        then result.speed.bonus        = result.speed.bonus        + effects2.speed.bonus        end
    if effects2.consumption  then result.consumption.bonus  = result.consumption.bonus  + effects2.consumption.bonus  end
    if effects2.pollution    then result.pollution.bonus    = result.pollution.bonus    + effects2.pollution.bonus    end
        
    return result
end

function shiftArea(area, position)
    return {
        left_top=    {x=position.x+area.left_top.x,     y=position.y+area.left_top.y},
        right_bottom={x=position.x+area.right_bottom.x, y=position.y+area.right_bottom.y}
    }
end

function boundingBoxesOverlap(box1, box2)
    
    return (
        box1.left_top.x < box2.right_bottom.x and
        box2.left_top.x < box1.right_bottom.x and
        box1.left_top.y < box2.right_bottom.y and
        box2.left_top.y < box1.right_bottom.y
        ) 
end

function mergeBoundingBoxes(box1, box2)
    return {
        left_top = {x = math.min(box1.left_top.x, box2.left_top.x), y = math.min(box1.left_top.y, box2.left_top.y)},
        right_bottom = {x = math.min(box1.right_bottom.x, box2.right_bottom.x), y = math.min(box1.right_bottom.y, box2.right_bottom.y)}
    }
end

function positionIsInBoundingBox(position, box)
    
    return (
        position.x <= box.right_bottom.x and
        position.x >= box.left_top.x and
        position.y <= box.right_bottom.y and
        position.y >= box.left_top.y
        ) 
end

function getGridOfPositionsInsideBox(box)
    local result = {}
    for x = box.left_top.x, box.right_bottom.x do
        for y = box.left_top.y, box.right_bottom.y do
            table.insert(result, {x=x,y=y})
        end
    end
    return result
end

function beaconIsFullyLoaded(entity)
    local inv = entity.get_module_inventory()
    local itemCount = 0
    for _, amount in pairs(inv.get_contents()) do itemCount = itemCount + amount end
    return itemCount == #inv
end

function beaconHasAnyModuleSlots(entity)
    return entity.prototype.module_inventory_size and entity.prototype.module_inventory_size > 0
end

function toString_position(position)
    if not position then 
        return "nil" 
    else 
        return "x: " .. position.x .. " / y:" .. position.y 
    end
end
