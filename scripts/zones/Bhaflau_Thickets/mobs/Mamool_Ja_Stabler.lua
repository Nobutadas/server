-----------------------------------
-- Area: Bhaflau Thickets
--  Mob: Mamool Ja Stabler
-----------------------------------
mixins = { require('scripts/mixins/break_mob') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Mamool_Jas_Raptor')
end

return entity
