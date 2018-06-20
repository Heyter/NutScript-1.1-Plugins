PLUGIN.name = "Looting"
PLUGIN.author = "SuperMicronde"
PLUGIN.desc = "Permits to search NPCs and players corpses."
PLUGIN.corpseMaxDist = 80

-- Includes
local dir = PLUGIN.folder.."/"

nut.util.includeDir(dir.."corpses", true, true)
nut.util.includeDir(dir.."loot", true, true)
--nut.util.include("npc_loot.lua", "shared")