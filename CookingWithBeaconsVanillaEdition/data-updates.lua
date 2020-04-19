--todo make it a setting

if data.raw["mining-drill"]["burner-mining-drill"] and not data.raw["mining-drill"]["burner-mining-drill"].module_specification then
    data.raw["mining-drill"]["burner-mining-drill"].module_specification =
    {
      module_slots = 1
    }
    data.raw["mining-drill"]["burner-mining-drill"].allowed_effects = {"consumption", "speed", "productivity", "pollution"}
end

if data.raw["furnace"]["stone-furnace"] and not data.raw["furnace"]["stone-furnace"].module_specification then
    data.raw["furnace"]["stone-furnace"].module_specification =
    {
      module_slots = 1
    }
    data.raw["furnace"]["stone-furnace"].allowed_effects = {"consumption", "speed", "productivity", "pollution"}
end

if data.raw["furnace"]["steel-furnace"] and not data.raw["furnace"]["steel-furnace"].module_specification then
    data.raw["furnace"]["steel-furnace"].module_specification =
    {
      module_slots = 1
    }
    data.raw["furnace"]["steel-furnace"].allowed_effects = {"consumption", "speed", "productivity", "pollution"}
end

if data.raw["assembling-machine"]["assembling-machine-1"] and not data.raw["assembling-machine"]["assembling-machine-1"].module_specification then
    data.raw["assembling-machine"]["assembling-machine-1"].module_specification =
    {
      module_slots = 1
    }
    data.raw["assembling-machine"]["assembling-machine-1"].allowed_effects = {"consumption", "speed", "productivity", "pollution"}
end