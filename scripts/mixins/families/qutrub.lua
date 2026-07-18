require('scripts/globals/mixins')

g_mixins = g_mixins or {}
g_mixins.families = g_mixins.families or {}

g_mixins.families.qutrub = function(qutrubMob)
    -- when a qutrub's weapon has been broken it will switch between using its second
    qutrubMob:addListener('COMBAT_TICK', 'QUTRUB_COMBAT_TICK', function(mob)
        local swapTime = mob:getLocalVar('swapTime')

        if swapTime > 0 and GetSystemTime() > swapTime then
            local animationSub = mob:getAnimationSub()

            if animationSub == 1 then
                mob:setAnimationSub(2)
                mob:setLocalVar('swapTime', GetSystemTime() + 60)

            elseif animationSub == 2 then
                mob:setAnimationSub(1)
                mob:setLocalVar('swapTime', GetSystemTime() + 60)
            end
        end
    end)
end

return g_mixins.families.qutrub
