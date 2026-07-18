-----------------------------------
-- Area: Mamook
--  Mob: Mamool Ja Philosopher
-----------------------------------
mixins = { require('scripts/mixins/break_mob') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.SEES_THROUGH_ILLUSION, 1)
end

return entity
