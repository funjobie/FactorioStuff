--https://wiki.factorio.com/Types/Energy
function cookingwithbeaconslib.private.to_energy_number(energyString)
    assert(energyString,"CookingWithBeaconsLib: provided energyString is nil ")
    assert(type(energyString) == "string", "CookingWithBeaconsLib: provided object is not a string: " .. tostring(energyString))
    local stringWithoutWattOrJoul = string.sub(energyString,1,-2)
    if string.sub(stringWithoutWattOrJoul,-1,-1) == "k" or string.sub(stringWithoutWattOrJoul,-1,-1) == "K" then return (10^3) * tonumber(string.sub(stringWithoutWattOrJoul,1,-2)) end
    if string.sub(stringWithoutWattOrJoul,-1,-1) == "M" then return (10^6)  * tonumber(string.sub(stringWithoutWattOrJoul,1,-2)) end
    if string.sub(stringWithoutWattOrJoul,-1,-1) == "G" then return (10^9)  * tonumber(string.sub(stringWithoutWattOrJoul,1,-2)) end
    if string.sub(stringWithoutWattOrJoul,-1,-1) == "T" then return (10^12) * tonumber(string.sub(stringWithoutWattOrJoul,1,-2)) end
    if string.sub(stringWithoutWattOrJoul,-1,-1) == "P" then return (10^15) * tonumber(string.sub(stringWithoutWattOrJoul,1,-2)) end
    if string.sub(stringWithoutWattOrJoul,-1,-1) == "E" then return (10^18) * tonumber(string.sub(stringWithoutWattOrJoul,1,-2)) end
    if string.sub(stringWithoutWattOrJoul,-1,-1) == "Z" then return (10^21) * tonumber(string.sub(stringWithoutWattOrJoul,1,-2)) end
    if string.sub(stringWithoutWattOrJoul,-1,-1) == "Y" then return (10^24) * tonumber(string.sub(stringWithoutWattOrJoul,1,-2)) end
    return tonumber(string.sub(stringWithoutWattOrJoul,1,-2))
end

function cookingwithbeaconslib.private.no_sprite()
    return 
    {
        filename = "__CookingWithBeaconsLib__/graphics/transparent.png",
        width = 32,
        height = 32,
        hr_version =
        {
            filename = "__CookingWithBeaconsLib__/graphics/transparent.png",
            width = 32,
            height = 32,
        }
    }
end

function cookingwithbeaconslib.private.no_anim()
    return 
    {
        filename = "__CookingWithBeaconsLib__/graphics/transparent.png",
        priority = "medium",
        width = 32,
        height = 32,
        frame_count = 1,
        line_length = 1,
        animation_speed = 1,
        hr_version =
        {
            filename = "__CookingWithBeaconsLib__/graphics/transparent.png",
            priority = "medium",
            width = 32,
            height = 32,
            frame_count = 1,
            line_length = 1,
            animation_speed = 1,
        }
    }
end
