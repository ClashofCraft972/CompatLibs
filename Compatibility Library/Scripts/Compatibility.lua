dofile("$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/ModDatabase.lua")
print("==================================")
print("--- Loading Compatibility Libs ---")
print("==================================")
---@class CompatLibs
ModDatabase.loadShapesets()
CompatLibs = class()
CompatLibs.localData = {}
CompatLibs.localData.ModsIds = ModDatabase.getAllLoadedMods()
ModDatabase.unloadShapesets()


local function loadEverything()

    ModDatabase.loadDescriptions()
    CompatLibs.localData.descriptions = {}
    for k in ipairs(CompatLibs.localData.ModsIds) do
        CompatLibs.localData.descriptions[tostring(CompatLibs.localData.ModsIds[k])] = ModDatabase.databases.descriptions[CompatLibs.localData.ModsIds[k]]
    end
    ModDatabase.unloadDescriptions()

    CompatLibs.localData.tags = {}
    CompatLibs.localData.tags["00000000-0000-0000-0000-000000000000"] = sm.json.open("$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/Databases/vanillaTags.json")
    for k in ipairs(CompatLibs.localData.ModsIds) do
        if sm.json.fileExists("$CONTENT_"..CompatLibs.localData.ModsIds[k].."/Objects/tags.json") then
            CompatLibs.localData.tags[CompatLibs.localData.ModsIds[k]] = sm.json.open("$CONTENT_"..CompatLibs.localData.ModsIds.."/Objects/tags.json")
        end
    end

    local function loadLocalSets()
        CompatLibs.localData.sets = {}

        ModDatabase.loadShapesets()
        CompatLibs.localData.sets.shape = sm.json.open("$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/Databases/shapesets.json")
        for k in ipairs(CompatLibs.localData.ModsIds) do
            CompatLibs.localData.sets.shape[tostring(CompatLibs.localData.ModsIds[k])] = ModDatabase.databases.shapesets[CompatLibs.localData.ModsIds[k]]
        end
        ModDatabase.unloadShapesets()

        ModDatabase.loadToolsets()
        CompatLibs.localData.sets.tool = sm.json.open("$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/Databases/toolsets.json")
        for k in ipairs(CompatLibs.localData.ModsIds) do
            CompatLibs.localData.sets.tool[tostring(CompatLibs.localData.ModsIds[k])] = ModDatabase.databases.toolsets[CompatLibs.localData.ModsIds[k]]
        end
        ModDatabase.unloadToolsets()

        ModDatabase.loadHarvestablesets()
        CompatLibs.localData.sets.harvestable = sm.json.open("$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/Databases/harvestablesets.json")
        for k in ipairs(CompatLibs.localData.ModsIds) do
            CompatLibs.localData.sets.harvestable[tostring(CompatLibs.localData.ModsIds[k])] = ModDatabase.databases.harvestablesets[CompatLibs.localData.ModsIds[k]]
        end
        ModDatabase.unloadHarvestablesets()

        ModDatabase.loadKinematicsets()
        CompatLibs.localData.sets.kinematic = sm.json.open("$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/Databases/kinematicsets.json")
        for k in ipairs(CompatLibs.localData.ModsIds) do
            CompatLibs.localData.sets.kinematic[tostring(CompatLibs.localData.ModsIds[k])] = ModDatabase.databases.kinematicsets[CompatLibs.localData.ModsIds[k]]
        end
        ModDatabase.unloadKinematicsets()

        ModDatabase.loadCharactersets()
        CompatLibs.localData.sets.character = sm.json.open("$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/Databases/charactersets.json")
        for k in ipairs(CompatLibs.localData.ModsIds) do
            CompatLibs.localData.sets.character[tostring(CompatLibs.localData.ModsIds[k])] = ModDatabase.databases.charactersets[CompatLibs.localData.ModsIds[k]]
        end
        ModDatabase.unloadCharactersets()

        ModDatabase.loadScriptableobjectsets()
        CompatLibs.localData.sets.scriptableobject = sm.json.open("$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/Databases/scriptableobjectsets.json")
        for k in ipairs(CompatLibs.localData.ModsIds) do
            CompatLibs.localData.sets.scriptableobject[tostring(CompatLibs.localData.ModsIds[k])] = ModDatabase.databases.scriptableobjectsets[CompatLibs.localData.ModsIds[k]]
        end
        ModDatabase.unloadScriptableobjectsets()
    end
    loadLocalSets()

    local function loadLocalRecipes()
        CompatLibs.localData.recipes = {}

        CompatLibs.localData.recipes.craftbot = sm.json.open("$SURVIVAL_DATA/CraftingRecipes/craftbot.json")
        for i in ipairs(CompatLibs.localData.ModsIds) do
            if sm.json.fileExists("$CONTENT_"..CompatLibs.localData.ModsIds[i].."/CraftingRecipes/craftbot.json") then
                local craftbotData = sm.json.open("$CONTENT_"..CompatLibs.localData.ModsIds[i].."/CraftingRecipes/craftbot.json")
                for k in ipairs(craftbotData) do
                    table.insert(CompatLibs.localData.recipes.craftbot, craftbotData[k])
                end
            end
        end

        CompatLibs.localData.recipes.hideout = sm.json.open("$SURVIVAL_DATA/CraftingRecipes/hideout.json")
        for i in ipairs(CompatLibs.localData.ModsIds) do
            if sm.json.fileExists("$CONTENT_"..CompatLibs.localData.ModsIds[i].."/CraftingRecipes/hideout.json") then
                local hideoutData = sm.json.open("$CONTENT_"..CompatLibs.localData.ModsIds[i].."/CraftingRecipes/hideout.json")
                for k in ipairs(hideoutData) do
                    table.insert(CompatLibs.localData.recipes.hideout, hideoutData[k])
                end
            end
        end

        CompatLibs.localData.recipes.refinery = sm.json.open("$SURVIVAL_DATA/CraftingRecipes/refinery.json")
        for i in ipairs(CompatLibs.localData.ModsIds) do
            if sm.json.fileExists("$CONTENT_"..CompatLibs.localData.ModsIds[i].."/CraftingRecipes/refinery.json") then
                local hideoutData = sm.json.open("$CONTENT_"..CompatLibs.localData.ModsIds[i].."/CraftingRecipes/refinery.json")
                for k in ipairs(hideoutData) do
                    table.insert(CompatLibs.localData.recipes.refinery, hideoutData[k])
                end
            end
        end


    end
    loadLocalRecipes()


end
loadEverything()

function CompatLibs.getUuidData( searchedUuid )
    print("Searching info for : "..tostring(searchedUuid))
    for setTypeInt in pairs(CompatLibs.localData.sets) do
        local setType = CompatLibs.localData.sets[setTypeInt]
        for modInt in pairs(setType) do
            local modId = setType[modInt]
            if type(modId) == 'table' then
                for setInt in pairs(modId) do
                    local setPath = modId[setInt]
                    if type(setPath) == 'table' then
                        for uuidInt in ipairs(setPath) do
                            if searchedUuid == sm.uuid.new(setPath[uuidInt]) then
                                local set = sm.json.open(setInt)
                                for listName in pairs(set) do
                                    for partInt in ipairs(set[listName]) do
                                        if sm.uuid.new(set[listName][partInt].uuid) == searchedUuid then
                                            local returned = set[listName][partInt]
                                            returned.setPath = setInt
                                            returned.modLocalId = modInt
                                            returned.objectType = setTypeInt
                                            return returned
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end            
        end
    end
end

function CompatLibs.getTagContent( tagName )
    print("Searching content from tag : "..tagName)
    local tagContent = {}
    for i in pairs(CompatLibs.localData.tags) do
        if type(CompatLibs.localData.tags[i][tagName]) == 'table' then
            local modTag = CompatLibs.localData.tags[i][tagName]
            for k in ipairs(modTag) do
                table.insert(tagContent, sm.uuid.new(modTag[k]))
            end
        end
    end
    return tagContent
end

function CompatLibs.getUuidTagList( uuid )
    local tagList = {}
    local originMod = CompatLibs.getUuidData(uuid).modLocalId
    local uuidStr = tostring(uuid)
    for tagName in pairs(CompatLibs.localData.tags[originMod]) do
        for k in ipairs(CompatLibs.localData.tags[originMod][tagName]) do
            if CompatLibs.localData.tags[originMod][tagName][k] == uuidStr then
                table.insert(tagList, tagName)
            end
        end
    end
    return tagList
end

function CompatLibs.isUuidInTag( uuid, tag )
    local tagContent = CompatLibs.getTagContent(tag)
    for i in ipairs(tagContent) do
        if tagContent[i] == uuid then
            return true
        end
    end
    return false
end





local function generateVanillafiles()
    --local shapeDb = sm.json.open("$SURVIVAL_DATA/ScriptableObjects/scripstableObjectSets.sobdb")
    local shapeDb = {
        scriptableObjectSetList= {
        {
            scriptableObjectSet= "$SURVIVAL_DATA/ScriptableObjects/scriptableObjectSets/sob_quests.sobset"
        },
        {
            scriptableObjectSet= "$SURVIVAL_DATA/ScriptableObjects/scriptableObjectSets/sob_managers.sobset"
        }
    } }
    local shapesets = {}
    for k in ipairs(shapeDb.scriptableObjectSetList) do
        local shapeset = sm.json.open(shapeDb.scriptableObjectSetList[k].scriptableObjectSet)
        shapesets[shapeDb.scriptableObjectSetList[k].scriptableObjectSet] = {}
        for i in pairs(shapeset) do
            for j in ipairs(shapeset[i]) do
                table.insert(shapesets[shapeDb.scriptableObjectSetList[k].scriptableObjectSet], shapeset[i][j].uuid)
            end
        end
    end
    local finalShapesets = {}
    finalShapesets["00000000-0000-0000-0000-000000000000"] = shapesets
    print(finalShapesets)
    sm.json.save(finalShapesets, "$CONTENT_be4f1099-5250-487f-be31-d923242f2e56/ScriptableObjectsets.json")
end

