dofile("$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/ModDatabase.lua")
print("==================================")
print("--- Loading Compatibility Libs ---")
print("==================================")
---@class CompatLibs
ModDatabase.loadShapesets()
CompatLibs = class()
sm.localData = {}
sm.gameData = {}
sm.localData.ModsIds = ModDatabase.getAllLoadedMods()
ModDatabase.unloadShapesets()

sm.gameData.pipeNetworks= {}
sm.gameData.pipePath = {}


local function loadEverything()
    ModDatabase.loadDescriptions()
    sm.localData.descriptions = {}
    for _, modId in ipairs(sm.localData.ModsIds) do
        sm.localData.descriptions[tostring(modId)] = ModDatabase.databases.descriptions[modId]
    end
    ModDatabase.unloadDescriptions()



    local function loadLocalSets()
        sm.localData.set = sm.json.open("$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/Databases/vanillaObjects.json")
        OperationList = {
            {Load = "loadShapesets", type = "shape"},
            {Load = "loadToolsets", type = "tool"},
            {Load = "loadHarvestablesets", type = "harvestable"},
            {Load = "loadKinematicsets", type = "kinematic"},
            {Load = "loadCharactersets", type = "character"},
            {Load = "loadScriptableobjectsets", type = "scriptableobject"}
        }
        for _, subList in pairs(OperationList) do
            ModDatabase[subList.Load]()
            local set = ModDatabase.databases[subList.type.."sets"]
            for _, modId in pairs(sm.localData.ModsIds) do
                if set[modId] ~= nil then
                    for setPath, ObjectList in pairs(set[modId]) do
                        for _, Object in ipairs(ObjectList) do
                            sm.localData.set[Object] = {ModID = modId, setPath = setPath, type = subList.type}
                        end
                    end
                end
            end
            ModDatabase["un"..subList.Load]()
        end
    end
    loadLocalSets()

    local function loadLocalTags()
       sm.localData.tags = {}
       for tagName, objectList in pairs(sm.json.open("$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/Databases/vanillaTags.json")) do
        if sm.localData.tags[tagName] == nil then
            sm.localData.tags[tagName] = {}
        end
        for object, data in pairs(objectList) do
            sm.localData.tags[tagName][object] = data
            if sm.localData.set[object].tags == nil then
                sm.localData.set[object].tags = {}
            end
            sm.localData.set[object].tags[tagName] = data
        end
    end
       for _, modId in ipairs(sm.localData.ModsIds) do
            local tagPath = tostring("$CONTENT_"..modId.."/Objects/tags.json")
            if sm.json.fileExists(tagPath) then
                local modTag = sm.json.open(tagPath)
                for tagName, objectList in pairs(modTag) do
                    if sm.localData.tags[tagName] == nil then
                        sm.localData.tags[tagName] = {}
                    end
                    for object, data in pairs(objectList) do
                        sm.localData.tags[tagName][object] = data
                        if sm.localData.set[object].tags == nil then
                            sm.localData.set[object].tags = {}
                        end
                        sm.localData.set[object].tags[tagName] = data
                    end
                end
            end
       end
    end    
    loadLocalTags()


    local function loadLocalRecipes()
        sm.localData.recipes = {}

        for _, recipe in pairs(sm.localData.tags.Crafter) do
            local craftType = recipe.recipe
            sm.localData.recipes[craftType] = {}
            if sm.json.fileExists("$SURVIVAL_DATA/CraftingRecipes/"..craftType..".json") then
                sm.localData.recipes[craftType] = sm.json.open("$SURVIVAL_DATA/CraftingRecipes/"..craftType..".json")
            end
            for _, modId in ipairs(sm.localData.ModsIds) do
                if sm.json.fileExists("$CONTENT_"..modId.."/CraftingRecipes/"..craftType..".json") then
                    for _, craft in ipairs(sm.json.open("$CONTENT_"..modId.."/CraftingRecipes/"..craftType..".json")) do
                        table.insert(sm.localData.recipes[craftType], craft)
                    end
                end
            end
        end
    end
    loadLocalRecipes()
end
loadEverything()

dofile("basicFunctions.lua")
dofile("pipeFunctions.lua")

local function generateVanillafiles()
    local shapeDb = {
        { type ="character", JsonFiles ={
            "$GAME_DATA/Character/CharacterSets/default.json",
            "$SURVIVAL_DATA/Character/CharacterSets/robots.json",
            "$SURVIVAL_DATA/Character/CharacterSets/animals.json",
            "$GAME_DATA/Character/CharacterSets/default.json",
            "$CHALLENGE_DATA/Character/CharacterSets/builderbot.json",
            "$SURVIVAL_DATA/Character/CharacterSets/robots.json",
            "$SURVIVAL_DATA/Character/CharacterSets/animals.json",
            "$GAME_DATA/Character/CharacterSets/default.json",
            "$SURVIVAL_DATA/Character/CharacterSets/robots.json",
            "$SURVIVAL_DATA/Character/CharacterSets/animals.json"
        }},
        {type ="harvestable", JsonFiles ={
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_trees.json",
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_burntforest.json",
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_stones.json",
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_fences.json",
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_fillers.json",
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_farmables.json",
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_remains.json",
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_loot.json",
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_plantables.json",
            "$SURVIVAL_DATA/Harvestables/Database/HarvestableSets/hvs_questitems.json"
        }},
        {type ="kinematic", JsonFiles ={
            
        }},
        {type ="scriptableobject", JsonFiles ={
            "$SURVIVAL_DATA/ScriptableObjects/scriptableObjectSets/sob_quests.sobset",
            "$SURVIVAL_DATA/ScriptableObjects/scriptableObjectSets/sob_managers.sobset"
        }},
        {type ="shape", JsonFiles = {
            "$GAME_DATA/Objects/Database/ShapeSets/blocks.json",
            "$GAME_DATA/Objects/Database/ShapeSets/interactive.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/mounted_guns.json",
            "$GAME_DATA/Objects/Database/ShapeSets/lights.json",
            "$GAME_DATA/Objects/Database/ShapeSets/vehicle.json",
            "$GAME_DATA/Objects/Database/ShapeSets/industrial.json",
            "$GAME_DATA/Objects/Database/ShapeSets/spaceship.json",
            "$GAME_DATA/Objects/Database/ShapeSets/fittings.json",
            "$GAME_DATA/Objects/Database/ShapeSets/containers.json",
            "$GAME_DATA/Objects/Database/ShapeSets/decor.json",
            "$GAME_DATA/Objects/Database/ShapeSets/plants.json",
            "$GAME_DATA/Objects/Database/ShapeSets/characterobject.json",
            "$GAME_DATA/Objects/Database/ShapeSets/debug.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/beacon.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactive_upgradeable.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactivecontainers_shared.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/consumable_shared.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/component.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/blocks.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/powertools.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/bucket.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/lights.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/vehicle.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/industrial.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/fittings.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/containers.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/decor.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/warehouse.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/construction.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/building.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/manmade.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/resources.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/harvests.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/treeparts.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/stoneparts.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/robotparts.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/character_shape.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/vacumpipe.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactive_shared.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/craftbot.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/survivalobject.json",
            "$CHALLENGE_DATA/Objects/Database/ShapeSets/override.json",		
            "$GAME_DATA/Objects/Database/ShapeSets/blocks.json",
            "$GAME_DATA/Objects/Database/ShapeSets/interactive.json",
            "$GAME_DATA/Objects/Database/ShapeSets/lights.json",
            "$GAME_DATA/Objects/Database/ShapeSets/vehicle.json",
            "$GAME_DATA/Objects/Database/ShapeSets/industrial.json",
            "$GAME_DATA/Objects/Database/ShapeSets/spaceship.json",
            "$GAME_DATA/Objects/Database/ShapeSets/fittings.json",
            "$GAME_DATA/Objects/Database/ShapeSets/containers.json",
            "$GAME_DATA/Objects/Database/ShapeSets/decor.json",
            "$GAME_DATA/Objects/Database/ShapeSets/plants.json",		
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/blocks.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/blocks_blueprint.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactive.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactive_shared.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/mounted_guns.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/beacon.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/powertools.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactivecontainers_shared.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactivecontainers.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/scrapinteractables.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/cookbot.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/craftbot.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/bucket.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/tool_parts.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/lights.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/vehicle.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/industrial.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/fittings.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/containers.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/decor.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/consumable_shared.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/consumable.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/component.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/spaceship.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/warehouse.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/construction.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/building.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/manmade.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/resources.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/harvests.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/plantables.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/packingcrates.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/treeparts.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/stoneparts.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactive_upgradeable.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/destructable_tape.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/robotparts.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/character_shape.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/vacumpipe.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/outfitpackage.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/effect_proxies.json",		
            "$GAME_DATA/Objects/Database/ShapeSets/blocks.json",
            "$GAME_DATA/Objects/Database/ShapeSets/interactive.json",
            "$GAME_DATA/Objects/Database/ShapeSets/lights.json",
            "$GAME_DATA/Objects/Database/ShapeSets/vehicle.json",
            "$GAME_DATA/Objects/Database/ShapeSets/industrial.json",
            "$GAME_DATA/Objects/Database/ShapeSets/spaceship.json",
            "$GAME_DATA/Objects/Database/ShapeSets/fittings.json",
            "$GAME_DATA/Objects/Database/ShapeSets/containers.json",
            "$GAME_DATA/Objects/Database/ShapeSets/decor.json",
            "$GAME_DATA/Objects/Database/ShapeSets/plants.json",
            "$GAME_DATA/Objects/Database/ShapeSets/characterobject.json",		
            "$CHALLENGE_DATA/Objects/Database/ShapeSets/blocks.json",
            "$CHALLENGE_DATA/Objects/Database/ShapeSets/challenge.json",
            "$CHALLENGE_DATA/Objects/Database/ShapeSets/interactive.json",		
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactive_upgradeable.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/interactivecontainers_shared.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/consumable_shared.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/component.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/blocks.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/powertools.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/tool_parts.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/lights.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/vehicle.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/industrial.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/fittings.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/containers.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/decor.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/warehouse.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/construction.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/building.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/manmade.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/character_shape.json",
            "$SURVIVAL_DATA/Objects/Database/ShapeSets/robotparts.json",
            "$CHALLENGE_DATA/Objects/Database/ShapeSets/override.json"
        }},
        {type ="tool", JsonFiles ={
            "$GAME_DATA/Tools/ToolSets/tools.json",
            "$GAME_DATA/Tools/ToolSets/deprecated.json",
            "$GAME_DATA/Tools/ToolSets/core.json",    
            "$SURVIVAL_DATA/Tools/ToolSets/spudguns.json",
            "$SURVIVAL_DATA/Tools/ToolSets/carry.json",    
            "$CHALLENGE_DATA/Tools/ToolSets/tools.json",
            "$GAME_DATA/Tools/ToolSets/tools.json",
            "$GAME_DATA/Tools/ToolSets/core.json",
            "$GAME_DATA/Tools/ToolSets/deprecated.json",    
            "$SURVIVAL_DATA/Tools/ToolSets/tools_shared.json",
            "$SURVIVAL_DATA/Tools/ToolSets/spudguns.json",
            "$SURVIVAL_DATA/Tools/ToolSets/carry.json",
            "$GAME_DATA/Tools/ToolSets/core.json",		
            "$SURVIVAL_DATA/Tools/ToolSets/tools.json",
            "$SURVIVAL_DATA/Tools/ToolSets/tools_shared.json",
            "$SURVIVAL_DATA/Tools/ToolSets/spudguns.json",
            "$SURVIVAL_DATA/Tools/ToolSets/carry.json"
        }}
    }
    local finalObjectset = {}
    for _, setList in ipairs(shapeDb) do
        for _, setPath in pairs(setList.JsonFiles) do
            local objectSet = sm.json.open(setPath)
            for t in pairs(objectSet) do
                print("HALLO")
                print(t)
                objectSet = objectSet[t]
                    for _, Object in ipairs(objectSet) do                    
                        
                        finalObjectset[Object.uuid] = {ModID = "00000000-0000-0000-0000-000000000000", setPath = setPath, type = setList.type}
                    end
            end
        end
    end
    print(finalObjectset)
    sm.json.save(finalObjectset, "$CONTENT_be4f1099-5250-487f-be31-d923242f2e56/vanillaObjects.json")
end
--generateVanillafiles()

