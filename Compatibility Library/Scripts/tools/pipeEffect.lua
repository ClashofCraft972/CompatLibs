dofile( "../Compatibility.lua" )
print("Loading PipeEffect tool")

PipeEffect = class()

function PipeEffect.client_onCreate( self )
    self.effectData = {}
    sm.gameData.pipePath.tool = self.tool
    self.speed = 40
end

function PipeEffect.client_onRefresh( self )
    self.effectData = {}
    self.speed = 40
end

function PipeEffect.cl_playPipeTransferEffect( self , index )
    self.effectData[index].effect = sm.effect.createEffect("ShapeRenderable")
    self.effectData[index].effect:setParameter( "uuid", self.effectData[index].ItemUuid )
    self.effectData[index].effect:start()
    self.effectData[index].pos = self.effectData[index].path[1]:getWorldPosition()
    self.effectData[index].effect:setPosition( self.effectData[index].pos )
    self.effectData[index].effect:setRotation( sm.quat.identity() )
    self.effectData[index].effect:setScale( self.effectData[index].size )
end

function PipeEffect.sv_playPipeTransferEffect(self, data)
    local itemUuid = data.ItemUuid
    local size = sm.item.getShapeSize(itemUuid)
    local factor = size.x
    if size.y > factor then factor = size.y end
    if size.z > factor then factor = size.z end
    factor = 6*factor
    print(factor)

    data.size = sm.vec3.new( 1 / factor, 1 / factor, 1 / factor )

    data.aim = 2

    table.insert(self.effectData, data)
    local index = #self.effectData
    self.network:sendToClients( 'cl_playPipeTransferEffect', index )

end

function PipeEffect.client_onFixedUpdate( self )
    if self.effectData == nil then self.effectData = {} end
    if sm.gameData.pipePath.tool == nil then sm.gameData.pipePath.tool = self.tool end
    local speed = self.speed / 40

    for index in pairs(self.effectData) do
        if self.effectData[index].aim <= #self.effectData[index].path then
            local aimPos = self.effectData[index].path[self.effectData[index].aim]:getWorldPosition()
            if CompatLibs.distance( aimPos, self.effectData[index].pos ) <= speed then
                self.effectData[index].aim = self.effectData[index].aim + 1
            else
                self.effectData[index].dir = aimPos - self.effectData[index].pos
                self.effectData[index].dir = self.effectData[index].dir:normalize() + self.effectData[index].path[self.effectData[index].aim]:getVelocity()
                self.effectData[index].pos = self.effectData[index].pos + self.effectData[index].dir*speed
                self.effectData[index].effect:setPosition( self.effectData[index].pos )
                print( index, "fixed", self.effectData[index].pos )
            end
        else
            self.effectData[index].effect:stop()
            self.effectData[index].effect:destroy()
            self.effectData[index] = nil
        end
    end
end

function PipeEffect.client_onUpdate( self , deltaTime )
    for index, effectData in pairs(self.effectData) do
        if effectData.dir ~= nil then
            self.effectData[index].effect:setPosition( effectData.pos +  effectData.dir*self.speed*deltaTime )
            print( index, "frame", effectData.pos +  effectData.dir*self.speed*deltaTime)
        end
    end
end