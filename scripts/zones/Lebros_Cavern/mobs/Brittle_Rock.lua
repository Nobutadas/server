-----------------------------------
-- Area: Lebros Cavern (Excavation Duty)
--  Mob: Brittle Rock
-- Immune to sleep (light, dark), poison, cannot regain HP on deaggro
-----------------------------------
local ID = zones[xi.zone.LEBROS_CAVERN]
-----------------------------------
---@type TMobEntity
local entity = {}

-- TODO: Unable to mimic damage exactly with current LSB. Modified the UDMG values to get approximate damage.
local reductionByCap = { [50] = -9800, [60] = -9800, [70] = -9800, [0] = -9650 }

-- HP varies based on level sync. 
-- HP varies within an instance (possibly the rocks have a level that varies).
-- HP varies based on ID: ID 17035289 was higher than the other rocks.
-- To simplify everything, hp values were set to averages: 2355, 2185, 1845, 1505. 
-- TODO: allow for variable hp for the rocks.
local hpByCap = { [50] =  1505, [60] =  1845, [70] =  2185, [0] =  2355 }

entity.onMobSpawn = function(mob)
    xi.assault.adjustMobLevel(mob)

    -- TODO: Mob should not have a death message.

    local levelCap  = mob:getInstance():getLevelCap()
    local hp        = hpByCap[levelCap]
    local reduction = reductionByCap[levelCap]

    mob:setMaxHP(hp)
    mob:setHP(mob:getMaxHP())

    -- The odd offset is the targetable rock, the even one is the pair
    if (mob:getID() - ID.mob.BRITTLE_ROCK) % 2 == 0 then
        mob:setUntargetable(true)
        mob:hideName(true)
        mob:hideHP(true)
    end

    mob:setMobMod(xi.mobMod.NO_REST, 0)
    mob:setMobMod(xi.mobMod.EXP_BONUS, -100)
    mob:setMobMod(xi.mobMod.NO_MOVE, 1)
    mob:setAutoAttackEnabled(false)
    mob:setMod(xi.mod.UDMGPHYS, reduction)
    mob:setMod(xi.mod.UDMGBREATH, reduction)
    mob:setMod(xi.mod.UDMGRANGE, -9650) -- TODO: More testing at 50/60/70 cap.
    mob:setMod(xi.mod.UDMGMAGIC, -9650) -- TODO: More testing at 50/60/70 cap.
    mob:setMod(xi.mod.CURSE_MEVA, 9999)
    mob:setMod(xi.mod.EVA, 0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    -- TODO: Crits should not be doing so much damage. About 1-3 damage bonus, but capped at 20.
end

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller or optParams.noKiller then
        local instance = mob:getInstance()
        if not instance then
            return
        end

        local rockOffset = mob:getID() - ID.mob.BRITTLE_ROCK
        if rockOffset == 1 then
            GetNPCByID(ID.npc._1rx, instance):setAnimation(xi.animation.OPEN_DOOR)
        elseif rockOffset == 3 then
            GetNPCByID(ID.npc._1ry, instance):setAnimation(xi.animation.OPEN_DOOR)
        elseif rockOffset == 5 then
            GetNPCByID(ID.npc._1rz, instance):setAnimation(xi.animation.OPEN_DOOR)
        elseif rockOffset == 7 then
            GetNPCByID(ID.npc._jr0, instance):setAnimation(xi.animation.OPEN_DOOR)
        elseif rockOffset == 9 then
            GetNPCByID(ID.npc._jr1, instance):setAnimation(xi.animation.OPEN_DOOR)
        end

        DespawnMob(mob:getID() - 1, instance) -- the silent twin vanishes with its rock
        instance:setProgress(instance:getProgress() + 1)
    end
end

return entity
