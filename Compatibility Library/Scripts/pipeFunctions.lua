dofile("basicFunctions.lua")
print("functions loaded")

function CompatLibs.setUvFrame( shape, UvFrame, glowMultiplier )
    if sm.gameData.pipePath.tool ~= nil then
        sm.event.sendToTool( sm.gameData.pipePath.tool, 'sv_lightUpPipes', {shape = shape, UvFrame = UvFrame, glowMultiplier = glowMultiplier} )
    end
end

function CompatLibs.BuildPipeNetwork( baseShape )
    local body =  baseShape:getBody()
    if sm.gameData.pipeNetworks[body] == nil then
        sm.gameData.pipeNetworks[body] = {}
    end
    local pipeNetwork = {}

    pipeNetwork.tick = sm.game.getCurrentTick()

    pipeNetwork.shapes = {baseShape}
    local function recursivebuilding(searchedShape)
        for _, neighbor in pairs(searchedShape:getPipedNeighbours()) do
            local isntIn = true
            for _, shape in pairs(pipeNetwork.shapes) do
                if neighbor == shape then
                    isntIn = false
                end                
            end
            if isntIn then
                table.insert(pipeNetwork.shapes, neighbor)
                recursivebuilding(neighbor)
            end
        end
    end
    recursivebuilding(baseShape)

    pipeNetwork.interactables = {}
    pipeNetwork.containers = {}
    pipeNetwork.tags = {}
    pipeNetwork.tags.VacuumPipe = {}
    for _, shape in pairs(pipeNetwork.shapes) do
        if shape:getInteractable() ~= nil and shape ~= nil then
            table.insert(pipeNetwork.interactables, shape:getInteractable())

            local isIn =  CompatLibs.isUuidInTag(shape:getShapeUuid(), "Container")

            if shape:getInteractable():getContainer(0) ~= nil then
                table.insert(pipeNetwork.containers, shape:getInteractable():getContainer(0))
            end
    
            if isIn.state then
                for _, index in pairs(isIn.data.indexes) do
                    if (index ~= 0) and (shape:getInteractable():getContainer(index) ~= nil) then
                        table.insert(pipeNetwork.containers, shape:getInteractable():getContainer(index))
                    end
                end
            end
            local shapeTags = CompatLibs.getUuidTagList(shape:getShapeUuid())
            for tag, tagData in pairs(shapeTags) do
                if pipeNetwork.tags[tag] == nil then
                    pipeNetwork.tags[tag] = {}
                end
                pipeNetwork.tags[tag][shape] = tagData
            end
        end
    end

    local lightPipe = 2
    if next(pipeNetwork.containers) == nil then
        lightPipe = 0
    end

    for pipe in pairs(pipeNetwork.tags.VacuumPipe) do
        CompatLibs.setUvFrame( pipe, lightPipe, 1.0 )
    end

    return pipeNetwork
end

function CompatLibs.PipeNetwork_onBodyChange( self )
    local body = self.shape:getBody()
    if not (sm.gameData.pipeNetworks[body] == nil or sm.gameData.pipeNetworks[body][0]==nil) then
        for index, pipeNetwork in pairs(sm.gameData.pipeNetworks[body]) do
            if body:hasChanged(pipeNetwork.tick+10) then
                sm.gameData.pipeNetworks[body][index] = nil

                local pipeNetwork = CompatLibs.BuildPipeNetwork(self.shape)
                self.pipeNetwork = pipeNetwork
                table.insert(sm.gameData.pipeNetworks[body], pipeNetwork)
                return pipeNetwork
            else
                for _, shape in pairs(pipeNetwork.shapes) do
                    if self.shape == shape then
                        pipeNetwork.body = body
                        self.pipeNetwork = pipeNetwork
                        return pipeNetwork
                    end
                end
            end
        end
    else
        sm.gameData.pipeNetworks[body] = {}
        local pipeNetwork = CompatLibs.BuildPipeNetwork(self.shape)
        self.pipeNetwork = pipeNetwork
        table.insert(sm.gameData.pipeNetworks[body], pipeNetwork)
        return pipeNetwork
    end
end

function CompatLibs.getShape( self, searchedContainer )
    for _, shape in pairs(self.pipeNetwork.shapes) do
        local isIn =  CompatLibs.isUuidInTag(shape:getShapeUuid(), "Container")

        if shape:getInteractable():getContainer(0) ~= nil then
            if shape:getInteractable():getContainer(0) == searchedContainer then
                return shape
            end
        end

        if isIn.state then
            for _, index in pairs(isIn.data.indexes) do
                if (index ~= 0) and (shape:getInteractable():getContainer(index) ~= nil) then
                    if shape:getInteractable():getContainer(0) == searchedContainer then
                        return shape
                    end
                end
            end
        end
    end
end

function CompatLibs.playPipeTransferEffect( self, startShape, endShape, ItemUuid )
    if type(startShape) == "Container" then
        startShape = CompatLibs.getShape( self, startShape)
    end
    if type(endShape) == "Container" then
        endShape = CompatLibs.getShape( self, endShape)
    end
    if startShape == nil or endShape == nil or ItemUuid == nil then
        return
    end
    local pathKey = startShape:getId()*1000+ endShape:getId()
    local body = startShape:getBody()

    local valid1 = false
    local valid2 = false
    for _, shape in pairs(CompatLibs.BuildPipeNetwork(endShape).shapes) do
        if shape == startShape then
            valid1 = true
        elseif shape == endShape then
            valid2 = true
        end
    end
    if not (valid1 and valid2) then
        sm.log.error( "[ERROR] in \"$CONTENT_8ec0b0e1-b0ab-4f34-ae1c-59ad47c6e5ec/Scripts/pipeFunctions.lua\" > CompatLibs.sv_playPipeTransferEffect() : \n".."Shape "..tostring(startShape:getId()).." and Shape "..tostring(endShape:getId()).." are not in the same pipe network.")
        do return end
    end
    local function BuildItemPath( self, startShape, endShape )

            local pathList = {}
        
            for _, shape in pairs(self.pipeNetwork.shapes) do
                pathList[shape:getId()] = {length = math.huge}
        
            end
            pathList[endShape:getId()] = {length = 0}
            local function RecursiveDijkstraAlgo( currentShape )
                for _, shape in pairs(currentShape:getPipedNeighbours()) do
                    if (pathList[currentShape:getId()].length + 1 < pathList[shape:getId()].length) and (pathList[currentShape:getId()].length + 1 < pathList[startShape:getId()].length) then
                        pathList[shape:getId()] = {length = pathList[currentShape:getId()].length + 1, previousShape = currentShape}
                        if shape ~= startShape then 
                            RecursiveDijkstraAlgo(shape)
                        end
                    end
                end
            end    
            RecursiveDijkstraAlgo( endShape )

            local path = {startShape}
            while path[#path] ~= endShape do
                table.insert(path, pathList[path[#path]:getId()].previousShape)
            end

            if sm.gameData.pipePath[body] == nil then sm.gameData.pipePath[body] = {} end

            if sm.gameData.pipePath[body][pathKey] == nil then
                sm.gameData.pipePath[body][pathKey] = {}
                sm.gameData.pipePath[body][pathKey].tick = sm.game.getCurrentTick()
                sm.gameData.pipePath[body][pathKey].path = path
            end

    end
    if sm.gameData.pipePath[body] == nil or sm.gameData.pipePath[body][pathKey] == nil or  body:hasChanged(sm.gameData.pipePath[body][pathKey].tick)then
        BuildItemPath( self, startShape, endShape )
    end
    if type(sm.gameData.pipePath.tool) ~= "Tool" then return end
    sm.event.sendToTool( sm.gameData.pipePath.tool, 'sv_playPipeTransferEffect', {ItemUuid = ItemUuid, path = sm.gameData.pipePath[body][pathKey].path})
end

