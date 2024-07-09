dofile( "../Compatibility.lua" )
print("Loading PipeEffect tool")

PipeEffect = class()

function PipeEffect.client_onCreate( self )
    self.effectTasks = {}
    self.speed = 2.5
    sm.gameData.pipePath.tool = self.tool
    self.glowchange = 4
end

function PipeEffect.client_onRefresh( self )
    self.speed = 2.5
    self.glowchange = 4
    self.effectTasks = {}
    sm.gameData.pipePath.tool = self.tool
end

function PipeEffect.cl_lightUpPipes( self, data )
    local uvFrame = 2
    local glowMultiplier = 1.0

    if data.UvFrame ~= nil then
        uvFrame = data.UvFrame
    end
    if data.glowMultiplier ~= nil then
        glowMultiplier = data.glowMultiplier
    end

    data.shape:getInteractable():setUvFrameIndex( uvFrame )
    data.shape:getInteractable():setGlowMultiplier( glowMultiplier )
end

function PipeEffect.sv_lightUpPipes( self, data )
    self.network:sendToClients( 'cl_lightUpPipes' , data )
end

function PipeEffect.pushShapeEffectTask( self, data )
    local shapeList = data.path
    local item = data.ItemUuid
	assert( item )
	local effect = sm.effect.createEffect( "ShapeRenderable" )
	local bounds = sm.item.getShapeSize( item )
	assert( bounds )
	effect:setParameter( "uuid", item )
	effect:setPosition( shapeList[1]:getWorldPosition() )
	effect:setScale( sm.vec3.new( sm.construction.constants.subdivideRatio, sm.construction.constants.subdivideRatio, sm.construction.constants.subdivideRatio ) / bounds )

    local pipes = {}
    for _, shape in ipairs(shapeList) do
        if CompatLibs.getUuidTagList(item) ~= nil and CompatLibs.getUuidTagList(item).VacuumPipe ~= nil then
            table.insert(pipes, shape)
        end
    end

	self:pushEffectTask( shapeList, effect, pipes )
end

function PipeEffect.pushEffectTask( self, shapeList, effect, pipes )
	table.insert( self.effectTasks, { shapeList = shapeList, effect = effect, progress = 0, pipes = pipes })
end

function PipeEffect.client_onUpdate( self, dt )
    if self.effectTasks ~= nil then
        local function reverse_ipairs( a )
            function iter( a, i )
                i = i - 1
                local v = a[i]
                if v then
                    return i, v
                end
            end
            return iter, a, #a + 1
        end
        for idx, task in reverse_ipairs( self.effectTasks ) do

            if task.progress == 0 then
                task.effect:start()
            end

            if task.progress > 0 and task.progress < 1 and #task.shapeList > 1 then
                for _, pipe in pairs(task.pipes) do
                    local glowMultiplier = 0.5*(1+math.sin(4*math.pi*(task.progress+0.125)))
                    local uvFrame = 2
                    if task.progress >.25 and task.progress < .75 then
                        uvFrame = 3 
                    end
                    self:cl_lightUpPipes({shape = pipe, UvFrame = uvFrame, glowMultiplier = glowMultiplier})
                end

                local span = ( 1.0 / ( #task.shapeList - 1 ) )

                local b = math.ceil( task.progress / span ) + 1
                local a = b - 1
                local t = ( task.progress - ( a - 1 ) * span ) / span
                --print( "A: "..a.." B: "..b.." t: "..t)

                assert(a ~= 0 and a <= #task.shapeList)
                assert(b ~= 0 and b <= #task.shapeList)

                local nodeA = task.shapeList[a]
                local nodeB = task.shapeList[b]

                if pcall( function() nodeA:shapeExists() end ) and pcall( function() nodeB:shapeExists() end ) then
                    local lerpedPosition = ( nodeA:getWorldPosition() * ( 1 - t ) ) + ( nodeB:getWorldPosition() * t )
                    task.effect:setPosition( lerpedPosition )
                else
                    task.progress = 1 -- End the effect
                end
            end

            task.progress = task.progress + dt / self.speed

            if task.progress >= 1 then
                task.effect:stop()
                table.remove( self.effectTasks, idx )
            end
        end
    end
end

function PipeEffect.sv_playPipeTransferEffect(self, data)
    self.network:sendToClients( 'pushShapeEffectTask', data )
end