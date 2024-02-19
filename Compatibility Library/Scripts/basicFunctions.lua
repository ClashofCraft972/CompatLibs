function CompatLibs.getUuidData( searchedUuid )
    searchedUuid = tostring(searchedUuid)
    if sm.localData.set[searchedUuid] ~= nil then
        if sm.json.fileExists(sm.localData.set[searchedUuid].setPath) then
            local set = sm.json.open(sm.localData.set[searchedUuid].setPath)
            for _, data in pairs(set) do
                for _, Objectdata in pairs(data) do
                    print(Objectdata.uuid)
                    if Objectdata.uuid == searchedUuid then
                        local uuidData = Objectdata
                        for dataName, data in pairs(sm.localData.set[searchedUuid]) do
                            uuidData[dataName] = data
                        end
                        return uuidData
                    end
                end
            end
        else
            sm.log.error( "[ERROR] in \"$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/pipeFunctions.lua\" > CompatLibs.sv_playPipeTransferEffect() : \n".." File \""..sm.localData.set[searchedUuid].setPath.."\" for Uuid \""..tostring(searchedUuid).."\" isn't registered/detected in the server's local storage")
        end
    else
        sm.log.error( "[ERROR] in \"$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/pipeFunctions.lua\" > CompatLibs.sv_playPipeTransferEffect() : \n".."Uuid \""..tostring(searchedUuid).."\" isn't registered/detected in the Compatibility Library/ModDatabase")
        return nil
    end
end

function CompatLibs.getTagContent( tagName )
    return sm.localData.tags[tagName]
end

function CompatLibs.getUuidTagList( uuid )
    uuid = tostring(uuid)
    return sm.localData.set[uuid].tags
end

function CompatLibs.isUuidInTag( uuid, tag )
    uuid = tostring(uuid)
    local tagContent = CompatLibs.getTagContent(tag)
    for tagUuid, uuidData in pairs(tagContent) do
        if tagUuid == uuid then
            return {state = true, data = uuidData}
        end
    end
    return {state = false, data = nil}
end