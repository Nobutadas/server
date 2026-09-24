/*
===========================================================================

  Copyright (c) 2023 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "besieged_system.h"

#include "ipc_server.h"

#include "common/database.h"
#include "common/ipp.h"
#include "common/xirand.h"

#include <vector>

BesiegedSystem::BesiegedSystem(WorldEngine& worldServer)
: worldServer_(worldServer)
{
}

bool BesiegedSystem::handleMessage(uint8 messageType, IPPMessage&& message)
{
    const auto besiegedMsgType = static_cast<BesiegedMessage>(messageType);
    switch (besiegedMsgType)
    {
        case BesiegedMessage::M2W_PrisonerChange:
        {
            if (const auto object = ipc::fromBytes<BesiegedPrisoner>(message.payload))
            {
                prisonerChange((*object).prisoner, (*object).stronghold);
            }
            return true;
        }
        break;
        default:
        {
            ShowWarningFmt("Message: unknown besieged type message received: {} from {}",
                           besiegedMsgType,
                           message.ipp.toString());
        }
        break;
    }

    return false;
}

void BesiegedSystem::setPrisonerStronghold(xi::BesiegedPrisoner prisoner, xi::BesiegedStronghold stronghold, uint8 cell)
{
    auto zoneId = xi::ZoneId::AlZahbi;

    switch (stronghold)
    {
        case xi::BesiegedStronghold::Mamook:
            zoneId = xi::ZoneId::Mamook;
            break;
        case xi::BesiegedStronghold::Halvung:
            zoneId = xi::ZoneId::Halvung;
            break;
        case xi::BesiegedStronghold::Arrapago:
            zoneId = xi::ZoneId::ArrapagoReef;
            break;
        case xi::BesiegedStronghold::AlZahbi:
            zoneId = xi::ZoneId::AlZahbi;
            break;
    }

    // Zone is not currently up
    const auto zoneIPP = worldServer_.ipcServer_->getIPPForZoneId(zoneId);
    if (!zoneIPP)
    {
        return;
    }

    worldServer_.ipcServer_->sendMessage(*zoneIPP, ipc::BesiegedEvent{
        .type    = BesiegedMessage::W2M_PrisonerChange,
        .payload = ipc::toBytes(BesiegedPrisoner{
            .prisoner   = prisoner,
            .stronghold = stronghold,
            .cell       = cell,
        }),
    });
}

void BesiegedSystem::prisonerChange(xi::BesiegedPrisoner prisoner, xi::BesiegedStronghold stronghold)
{
    // Get prisoner sql stuff
    const auto rset = db::preparedStmt("SELECT stronghold FROM besieged_prisoners WHERE prisoner = ?",
                                       static_cast<uint8>(prisoner));
    if (!rset)
    {
        return;
    }

    uint8 cell = 0;

    // Find free cell
    if (stronghold != xi::BesiegedStronghold::AlZahbi)
    {
        const auto rset2 = db::preparedStmt("SELECT cell FROM besieged_prisoners WHERE stronghold = ? ORDER BY cell",
                                            static_cast<uint8>(stronghold));

        uint8 cellCount = 0;

        switch (stronghold)
        {
            case xi::BesiegedStronghold::Mamook:
                cellCount = 16;
                break;
            case xi::BesiegedStronghold::Halvung:
                cellCount = 20;
                break;
            case xi::BesiegedStronghold::Arrapago:
                cellCount = 18;
                break;
        }

        // THIS SUCKS REWRITE
        std::vector<uint8> freeCells;
        for (uint8 i = 1; i <= cellCount; i++)
        {
            freeCells.push_back(i);
        }

        while (rset2 && rset2->next())
        {
            std::erase(freeCells, rset2->get<uint8>("cell"));
        }

        // Thic needs to be a random free cell
        cell = xirand::GetRandomElement(freeCells);
    }

    // Update SQL
    const auto rset3 = db::preparedStmt("UPDATE besieged_prisoners SET stronghold = ?, cell = ? WHERE prisoner = ?",
                                        static_cast<uint8>(stronghold),
                                        cell,
                                        static_cast<uint8>(prisoner));
    if (!rset3)
    {
        return;
    }

    // Send out command to prisoner
    setPrisonerStronghold(prisoner, stronghold, cell);
}
