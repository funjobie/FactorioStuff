if not cookingwithbeaconslib then
    log("CookingWithBeaconsLib mod was not initialzed; exiting")
    local force = nil
    force.exit = true
end

cookingwithbeaconslib.public.set_productivity_limitations(data.raw.module["productivity-module"].limitation, data.raw.module["productivity-module"].limitation_message_key)