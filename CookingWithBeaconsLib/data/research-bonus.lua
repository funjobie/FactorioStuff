function cookingwithbeaconslib.public.enable_feature_research_bonus()

    if not cookingwithbeaconslib.private.feature_research_bonus then
        cookingwithbeaconslib.private.add_hidden_beacon_and_unit_modules()
        cookingwithbeaconslib.private.feature_research_bonus = true
    end

    log("cookingwithbeaconslib: Feature research bonus enabled")
end

--todo actually it may not be necessary to use separate plural forms since the game supports __plural_for_parameter_
--https://wiki.factorio.com/Tutorial:Localisation
--but i realized it after the fact and it works for now.
function cookingwithbeaconslib.private.getLocalizedNameAndDescription(uniqueBonusName, entities, groupLocalization, effectType, effectAmount)
    local localization_positiveOrNegative
    if effectAmount.bonus > 0 then 
        localization_positiveOrNegative = "positive-" 
    else 
        localization_positiveOrNegative = "negative-" 
    end
    local localization_technologyDescrption_singularOrPlural
    if #entities == 1 then
        localization_technologyDescrption_singularOrPlural = "singular-"
    else
        localization_technologyDescrption_singularOrPlural = "plural-"
    end
    
    local localised_name = {"technology-name.cwb-research-bonus-"..localization_positiveOrNegative..effectType, groupLocalization}
    
    local entityNamesAsLocalizationStr = {}
    table.insert(entityNamesAsLocalizationStr, "localization-stuff.localization-helper-"..#entities.."-arg")
    for _, entity in pairs(entities) do
        table.insert(entityNamesAsLocalizationStr, {"entity-name."..entity})
    end
    
    local localised_description = {"technology-description.cwb-research-bonus-"..localization_positiveOrNegative..localization_technologyDescrption_singularOrPlural..effectType, 
        entityNamesAsLocalizationStr, math.abs(effectAmount.bonus * 100)}
    
    return localised_name, localised_description
end

function cookingwithbeaconslib.private.add_technology(uniqueBonusName, entities, groupLocalization, effectType, effectAmount, level, maxLevel, count_formula, ingredients, timeVal, additionalPrerequisites)
    local name = "cwb-research-bonus-"..uniqueBonusName.."^"..effectType.."^-"..tostring(level)
    assert(not data.raw.technology[name], "cookingwithbeaconslib: research bonus for the entity group " .. uniqueBonusName .. " was specified twice!")

    local localised_name, localised_description = cookingwithbeaconslib.private.getLocalizedNameAndDescription(uniqueBonusName, entities, groupLocalization, effectType, effectAmount)
    
    data:extend(
    {
        {
            type = "technology",
            name = name,
            localised_name = localised_name,
            localised_description = localised_description,
            icon_size = 128,
            icon = "__CookingWithBeaconsLib__/graphics/technology/research-bonus-".. effectType ..".png",
            enabled = true,
            effects = {},
            upgrade = true,
            prerequisites = additionalPrerequisites,
            unit =
            {
                count_formula = count_formula,
                ingredients = ingredients,
                time = timeVal
            },
            level = level,
            max_level = maxLevel,
            order = "c-a"
        },
    })
end

function cookingwithbeaconslib.public.add_research_boni(uniqueBonusName, entities, groupLocalization, researchBonusChains, affectedBoni)

    assert(cookingwithbeaconslib.private.feature_research_bonus, "CookingWithBeaconsLib: cannot add research boni as the feature is not enabled yet.")
    assert(uniqueBonusName, "CookingWithBeaconsLib: cannot add research boni because the uniqueBonusName was not provided.")
    assert(type(uniqueBonusName) == "string", "CookingWithBeaconsLib: cannot add research boni because the uniqueBonusName was not a string.")
    assert(uniqueBonusName ~= "", "CookingWithBeaconsLib: cannot add research boni because the uniqueBonusName was an empty string.")
    assert(not string.match(uniqueBonusName, "%^"), "CookingWithBeaconsLib: cannot add research boni because the uniqueBonusName contains the char ^ which is needed for internal use.")
    assert(entities, "CookingWithBeaconsLib: cannot add research boni because the entities list was not provided.")
    assert(type(entities) == "table", "CookingWithBeaconsLib: cannot add research boni because the entities list is not a table.")
    assert(#entities > 0, "CookingWithBeaconsLib: cannot add research boni because the entities list is empty.")
    for _, s in pairs(entities) do
        assert(type(s) == "string", "CookingWithBeaconsLib: cannot add research boni because the entities list contains a non-string entry.")
        assert(s ~= "", "CookingWithBeaconsLib: cannot add research boni because the entities list contains an empty string.")
    end
    assert(groupLocalization, "CookingWithBeaconsLib: cannot add research boni because the groupLocalization was not provided.")
    assert(type(groupLocalization) == "table", "CookingWithBeaconsLib: cannot add research boni because the groupLocalization is not a table.")
    assert(researchBonusChains, "CookingWithBeaconsLib: cannot add research boni because the researchBonusChains was not provided.")
    assert(type(researchBonusChains) == "table", "CookingWithBeaconsLib: cannot add research boni because the researchBonusChains is not a table.")
    assert(affectedBoni, "CookingWithBeaconsLib: cannot add research boni because the affectedBoni was not provided.")
    assert(type(affectedBoni) == "table", "CookingWithBeaconsLib: cannot add research boni because the affectedBoni is not a table.")
    
    local hasAtLeastOneBoni = false
    for affectedBonus, affectedBonusAmount in pairs(affectedBoni) do
        hasAtLeastOneBoni = true
        assert((affectedBonus == "productivity" or affectedBonus == "speed" or affectedBonus == "pollution" or affectedBonus == "consumption"), 
            "CookingWithBeaconsLib: cannot add research boni because the affectedBoni contains a key which is not recognized. expected to get "
            .. "productivity, speed, pollution or consumption but got " .. affectedBonus .. " instead")
        assert(type(affectedBonusAmount) == "table", "CookingWithBeaconsLib: cannot add research boni because the affectedBoni contains a boni which is not a table. key was: " .. affectedBonus)
        assert(affectedBonusAmount.bonus, "CookingWithBeaconsLib: cannot add research boni because the affectedBoni contains a boni which doesn't have a bonus value. key was: " .. affectedBonus)
        assert(type(affectedBonusAmount.bonus) == "number", "CookingWithBeaconsLib: cannot add research boni because the affectedBoni contains a boni where the bonus value is not a number. key was: " .. affectedBonus)        
        for _, chain in pairs(researchBonusChains) do
            assert(chain.level, "CookingWithBeaconsLib: cannot add research boni because the level value in the chain is missing.")
            assert(type(chain.level) == "number", "CookingWithBeaconsLib: cannot add research boni because the level value in the chain is of wrong type, it should be a number.")
            assert(chain.levelMax, "CookingWithBeaconsLib: cannot add research boni because the levelMax value in the chain is missing.")
            assert(type(chain.levelMax) == "number", "CookingWithBeaconsLib: cannot add research boni because the levelMax value in the chain is of wrong type, it should be a number.")
            assert(chain.ingredients, "CookingWithBeaconsLib: cannot add research boni because the ingredients value in the chain is missing.")
            assert(type(chain.ingredients) == "table", "CookingWithBeaconsLib: cannot add research boni because the ingredients value in the chain is of wrong type, it should be a table.")
            assert(chain.count_formula, "CookingWithBeaconsLib: cannot add research boni because the count_formula value in the chain is missing.")
            assert(type(chain.count_formula) == "string", "CookingWithBeaconsLib: cannot add research boni because the count_formula value in the chain is of wrong type, it should be a string.")
            assert(chain.time, "CookingWithBeaconsLib: cannot add research boni because the time value in the chain is missing.")
            assert(type(chain.time) == "number", "CookingWithBeaconsLib: cannot add research boni because the time value in the chain is of wrong type, it should be a number.")
            if chain.additionalPrerequisites then
                assert(type(chain.additionalPrerequisites) == "table", "CookingWithBeaconsLib: cannot add research boni because the additionalPrerequisites value in the chain is of wrong type, it should be a table.")
            end
            
            cookingwithbeaconslib.private.add_technology(uniqueBonusName, entities, groupLocalization, affectedBonus, affectedBonusAmount, chain.level, chain.levelMax, chain.count_formula, chain.ingredients, chain.time, chain.additionalPrerequisites)
        end
    end
    assert(hasAtLeastOneBoni, "CookingWithBeaconsLib: cannot add research boni because the affectedBoni table is empty.")
end