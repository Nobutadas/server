-----------------------------------
-- Area: Lebros Cavern (Excavation Duty)
--  Mob: Qiqirn Volcanist
-----------------------------------
local ID = zones[xi.zone.LEBROS_CAVERN]
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    xi.assault.adjustMobLevel(mob)
    mob:setMobMod(xi.mobMod.GIL_MAX, -1)
end

entity.onMobDeath = function(mob, player, optParams)
    if player:hasItem(xi.item.QIQIRN_MINE, xi.inv.TEMPITEMS) then
        return
    end

    if mob:getLocalVar('dead') == 0 then
        mob:setLocalVar('dead', 1)
        if math.randomInt(1, 100) <= 40 then -- TODO: More Retail data. Current data is 47/127 for drops.
            if player:addTempItem(xi.item.QIQIRN_MINE) then
                player:messageSpecial(ID.text.TEMP_ITEM, xi.item.QIQIRN_MINE)
            end
        end
    end
end

return entity
