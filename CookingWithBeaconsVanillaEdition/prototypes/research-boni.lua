local researchBonusChains = 
{
    {level = 1, levelMax = 1, ingredients = {{"automation-science-pack", 1}}, count_formula = "50", time=30},
    {level = 2, levelMax = 3, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}, count_formula = "(L-1)*100", time=30, additionalPrerequisites={"logistic-science-pack"}},
}
local entities = {"manual-assembler"}
cookingwithbeaconslib.public.add_research_boni("improvements-for-manual-assembler", entities, {"entity-name.manual-assembler"}, researchBonusChains, {productivity={bonus=0.25},speed={bonus=0.20}})

researchBonusChains = 
{
    {level = 1, levelMax = 2, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1}}, count_formula = "L*100", time=30, additionalPrerequisites={"logistic-science-pack"}},
    {level = 3, levelMax = 3, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1}}, count_formula = "L*100", time=30, additionalPrerequisites={"chemical-science-pack"}},
    {level = 4, levelMax = 4, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1}}, count_formula = "L*100", time=30, additionalPrerequisites={"production-science-pack"}},
    {level = 5, levelMax = 5, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1},{"utility-science-pack", 1}}, count_formula = "L*100", time=30, additionalPrerequisites={"utility-science-pack"}},
}
entities = {
    "assembling-machine-1",
    "assembling-machine-2",
    "assembling-machine-3",
    "oil-refinery",
    "chemical-plant",
    "centrifuge",
    "robo-assembler"
}
cookingwithbeaconslib.public.add_research_boni("pollution-reduction-for-all-assemblers", entities, {"research-boni-group-name.all-crafting-machines"}, researchBonusChains, {pollution={bonus=-0.10}})

researchBonusChains = 
{
    {level = 1, levelMax = 2, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1}}, count_formula = "(L*75)+50", time=30, additionalPrerequisites={"advanced-material-processing-2"}},
    {level = 3, levelMax = 3, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1}}, count_formula = "(L*75)+50", time=30, additionalPrerequisites={"production-science-pack"}},
    {level = 4, levelMax = 5, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1},{"utility-science-pack", 1}}, count_formula = "(L*75)+50", time=30, additionalPrerequisites={"utility-science-pack"}},
}
entities = {"electric-furnace"}
cookingwithbeaconslib.public.add_research_boni("power-reduction-for-electric-furnaces", entities, {"entity-name.electric-furnace"}, researchBonusChains, {consumption={bonus=-0.10}})

researchBonusChains = 
{
    {level = 1, levelMax = 1, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1}}, count_formula = "L*1000", time=30, additionalPrerequisites={"logistic-science-pack"}},
    {level = 2, levelMax = 2, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1}}, count_formula = "L*1000", time=30, additionalPrerequisites={"chemical-science-pack"}},
    {level = 3, levelMax = 3, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1}}, count_formula = "L*1000", time=30, additionalPrerequisites={"production-science-pack"}},
    {level = 4, levelMax = 5, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1},{"utility-science-pack", 1}}, count_formula = "L*1000", time=30, additionalPrerequisites={"utility-science-pack"}},
}
entities = 
{
    "assembling-machine-1",
    "assembling-machine-2",
    "assembling-machine-3",
    "robo-assembler"
}
cookingwithbeaconslib.public.add_research_boni("upgrades-for-assemblers", entities, {"research-boni-group-name.regular-assemblers"}, researchBonusChains, {productivity={bonus=0.04},speed={bonus=0.05}})

researchBonusChains = 
{
    {level = 1, levelMax = 2, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1}}, count_formula = "L*100", time=30, additionalPrerequisites={"logistic-science-pack"}},
    {level = 3, levelMax = 3, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1}}, count_formula = "L*100", time=30, additionalPrerequisites={"chemical-science-pack"}},
    {level = 4, levelMax = 4, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1}}, count_formula = "L*100", time=30, additionalPrerequisites={"production-science-pack"}},
    {level = 5, levelMax = 5, ingredients = {{"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1},{"utility-science-pack", 1}}, count_formula = "L*100", time=30, additionalPrerequisites={"utility-science-pack"}},
}
entities = {"electric-mining-drill"}
cookingwithbeaconslib.public.add_research_boni("pollution-reduction-for-electric-mining-drill", entities, {"entity-name.electric-mining-drill"}, researchBonusChains, {pollution={bonus=-0.10}})