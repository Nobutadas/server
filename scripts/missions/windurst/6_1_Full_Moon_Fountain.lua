-----------------------------------
-- Full Moon Fountain
-- Windurst M6-1
-----------------------------------
-- !addmission 2 16
-- Rakoh Buuma         : !pos 106 -5 -23 241
-- Mokyokyo            : !pos -55 -8 227 238
-- Janshura-Rashura    : !pos -227 -8 184 240
-- Zokima-Rokima       : !pos 0 -16 124 239
-- Hakkuru-Rinkuru     : !pos -111 -4 101 240
-- Gate: Magical Gizmo : !pos -291 0 -659 194
-----------------------------------
local outerHorutotoID = zones[xi.zone.OUTER_HORUTOTO_RUINS]
-----------------------------------

local mission = Mission:new(xi.mission.log_id.WINDURST, xi.mission.id.windurst.FULL_MOON_FOUNTAIN)

mission.reward =
{
    rankPoints = 650,
}

local handleAcceptMission = function(player, csid, option, npc)
    if option == 16 then
        mission:begin(player)
        player:messageSpecial(zones[player:getZoneID()].text.YOU_ACCEPT_THE_MISSION)
    end
end

local function areJacksSpawned()
    for mobIdOffset = 0, 3 do
        local mobObj = GetMobByID(outerHorutotoID.mob.FULL_MOON_FOUNTAIN_OFFSET + mobIdOffset)

        if mobObj and mobObj:isSpawned() then
            return true
        end
    end

    return false
end

local jackOnMobDeath = function(mob, player, optParams)
    local areMobsDefeated = true

    if player:getMissionStatus(mission.areaId) ~= 1 then
        return
    end

    for mobIdOffset = 0, 3 do
        local mobObj = GetMobByID(outerHorutotoID.mob.FULL_MOON_FOUNTAIN_OFFSET + mobIdOffset)

        if
            mobObj and
            not mobObj:isDead() and
            mobObj:isSpawned()
        then
            areMobsDefeated = false
        end
    end

    if areMobsDefeated then
        player:setMissionStatus(mission.areaId, 2)
    end
end

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == xi.mission.id.nation.NONE and
                player:getNation() == mission.areaId
        end,

        [xi.zone.PORT_WINDURST] =
        {
            onEventFinish =
            {
                [78] = handleAcceptMission,
            },
        },

        [xi.zone.WINDURST_WALLS] =
        {
            onEventFinish =
            {
                [93] = handleAcceptMission,
            },
        },

        [xi.zone.WINDURST_WATERS] =
        {
            onEventFinish =
            {
                [111] = handleAcceptMission,
            },
        },

        [xi.zone.WINDURST_WOODS] =
        {
            onEventFinish =
            {
                [114] = handleAcceptMission,
            },
        },
    },

    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Hakkuru-Rinkuru'] =
            {
                onTrigger = function(player, npc)
                    local missionStatus = player:getMissionStatus(mission.areaId)

                    if missionStatus == 0 then
                        return mission:progressEvent(456, 0, xi.ki.SOUTHWESTERN_STAR_CHARM)
                    elseif missionStatus == 1 or missionStatus == 2 then
                        return mission:event(457)
                    elseif missionStatus == 3 then
                        return mission:event(459)
                    end
                end,
            },

            ['Janshura-Rashura'] = mission:event(452),

            ['Kuroido-Moido'] =
            {
                onTrigger = function(player, npc)
                    local missionStatus = player:getMissionStatus(mission.areaId)

                    if missionStatus == 1 or missionStatus == 2 then
                        return mission:event(458)
                    elseif missionStatus == 3 then
                        return mission:event(460)
                    end
                end,
            },

            ['Nine_of_Clubs'] = mission:event(454),

            ['Puo_Rhen'] = mission:event(453), -- TODO: Verify with capture

            ['Ten_of_Clubs'] = mission:event(455),

            onEventFinish =
            {
                [456] = function(player, csid, option, npc)
                    player:setMissionStatus(mission.areaId, 1)
                    npcUtil.giveKeyItem(player, xi.ki.SOUTHWESTERN_STAR_CHARM)
                end,
            },
        },

        [xi.zone.OUTER_HORUTOTO_RUINS] =
        {
            ['_5eb'] =
            {
                onTrigger = function(player, npc)
                    local missionStatus = player:getMissionStatus(mission.areaId)

                    if not areJacksSpawned() then
                        if missionStatus == 1 then
                            for mobId = outerHorutotoID.mob.FULL_MOON_FOUNTAIN_OFFSET, outerHorutotoID.mob.FULL_MOON_FOUNTAIN_OFFSET + 3 do
                                SpawnMob(mobId)
                            end

                            return mission:messageSpecial(outerHorutotoID.text.GUARDIAN_BLOCKING_WAY)
                        elseif missionStatus == 2 then
                            player:messageSpecial(outerHorutotoID.text.STAR_CHARM_DISAPPEARS, xi.zone.OUTER_HORUTOTO_RUINS, xi.ki.SOUTHWESTERN_STAR_CHARM)
                            return mission:progressEvent(68)
                        end
                    else
                        return mission:messageSpecial(outerHorutotoID.text.DOOR_WONT_OPEN_STAR_CHARM, xi.zone.OUTER_HORUTOTO_RUINS, xi.ki.SOUTHWESTERN_STAR_CHARM)
                    end
                end,
            },

            ['Jack_of_Batons'] =
            {
                onMobDeath = jackOnMobDeath,
            },

            ['Jack_of_Coins'] =
            {
                onMobDeath = jackOnMobDeath,
            },

            ['Jack_of_Cups'] =
            {
                onMobDeath = jackOnMobDeath,
            },

            ['Jack_of_Swords'] =
            {
                onMobDeath = jackOnMobDeath,
            },

            onEventFinish =
            {
                [68] = function(player, csid, option, npc)
                    player:setMissionStatus(mission.areaId, 3)
                    player:delKeyItem(xi.ki.SOUTHWESTERN_STAR_CHARM)
                end,
            },
        },

        [xi.zone.FULL_MOON_FOUNTAIN] =
        {
            onZoneIn = function(player, prevZone)
                if player:getMissionStatus(mission.areaId) == 3 then
                    return 50
                end
            end,

            onEventFinish =
            {
                [50] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },

        [xi.zone.WINDURST_WALLS] =
        {
            ['Chawo_Shipeynyo'] = mission:event(354), -- TODO: Verify with capture

            ['Keo-Koruo'] = mission:event(353), -- TODO: Verify with capture

            ['Pakke-Pokke'] = mission:event(352), -- TODO: Verify with capture

            ['Zokima-Rokima'] = mission:event(351),
        },

        [xi.zone.WINDURST_WATERS] =
        {
            ['Dagoza-Beruza'] = mission:event(703),

            ['Mokyokyo'] = mission:event(701),

            ['Panna-Donna'] = mission:event(702),

            ['Ten_of_Hearts'] = mission:event(704), -- TODO: Verify with capture
        },

        [xi.zone.WINDURST_WOODS] =
        {
            ['Miiri-Wohri'] = mission:event(561), -- TODO: Verify with capture

            ['Rakoh_Buuma'] = mission:event(558),

            ['Sola_Jaab'] = mission:event(560),

            ['Tih_Pikeh'] = mission:event(559),
        },
    },

    { -- Dialog between missions
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == xi.mission.id.nation.NONE and
                player:getNation() == mission.areaId and
                player:hasCompletedMission(mission.areaId, mission.missionId) and
                not player:hasCompletedMission(mission.areaId, xi.mission.id.windurst.SAINTLY_INVITATION)
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Goltata'] = mission:event(494),

            ['Hakkuru-Rinkuru'] = mission:event(461),

            ['Kunchichi'] = mission:event(492),

            ['Kuroido-Moido'] = mission:event(462),

            ['Maabu-Sonbu'] = mission:event(491),

            ['Mojo-Pojo'] = mission:event(493),

            ['Nine_of_Clubs'] = mission:event(489),

            ['Puo_Rhen'] = mission:event(488), -- TODO: Verify with capture

            ['Ten_of_Clubs'] = mission:event(490),
        },

        [xi.zone.HEAVENS_TOWER] =
        {
            ['Kinono'] = mission:event(331),

            ['Kiwawa'] = mission:event(317),

            ['Kupipi'] = mission:event(314),

            ['Nebibi'] = mission:event(330),

            ['Ufu_Koromoa'] = mission:event(324),

            ['Zubaba'] = mission:event(315),
        },

        -- TODO: Capture guard events post mission for Windurst Walls

        [xi.zone.WINDURST_WATERS] =
        {
            ['Dagoza-Beruza'] = mission:event(769),

            ['Panna-Donna'] = mission:event(768),

            ['Ten_of_Hearts'] = mission:event(770), -- TODO: Verify with capture
        },

        [xi.zone.WINDURST_WOODS] =
        {
            ['Miiri-Wohri'] = mission:event(596), -- TODO: Verify with capture

            ['Sola_Jaab'] = mission:event(595),

            ['Tih_Pikeh'] = mission:event(594),
        },
    },
}

return mission
