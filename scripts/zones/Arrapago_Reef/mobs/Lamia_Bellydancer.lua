-----------------------------------
-- Area: Arrapago Reef
--  Mob: Lamia Bellydancer
-----------------------------------
mixins = { require('scripts/mixins/break_mob') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Lamias_Elemental')
end

return entity
