PLUGIN:RegisterNpc("npc_metropolice", {0, 100}, {

	w = 5,
	h = 5,

	maxTry = 20,
	MAX_RARITY = 8,

	rarities = {
		[0] = {
			{id = "aviators"}
		},
		[2] = {
			{id = "aviators"}
		},
		[4] = {
			{id = "aviators"},
			{id = "aviators"}
		},
		[8] = {
			{id = "aviators"},
			{id = "aviators"}
		}
	}
	
})

local function RandomItem(rarities, maxRarity)

	local rarity = 0

	while ( rarity < maxRarity ) do
		local roll = math.random(0, 100)

		if (roll > 50) then
			rarity = rarity + 1
		else
			break
		end
	end

	local fixedRarity

	for k, v in SortedPairs(rarities) do
		if ( rarity >= k ) then
			fixedRarity = k
		else
			break
		end
	end

	if ( fixedRarity ) then
		return table.Random(rarities[fixedRarity])
	end

end

function PLUGIN:MakeNpcLoot(corpse, lootInfo)

	-- Money
	local moneyInfo = lootInfo.money

	local minMoney = moneyInfo[1] or 0
	local maxMoney = moneyInfo[2] or 0

	local money = math.random(minMoney, maxMoney)
	corpse:SetVar("LootMoney", money)

	-- Inventory creation
	local inventoryInfo = lootInfo.inventory

	local invWidth = inventoryInfo.w or 1
	local invHeight = inventoryInfo.h or 1
	local newInv = NewInventory(corpse, invWidth, invHeight)

	if ( newInv ) then
		local rarities = inventoryInfo.rarities
		local trys = math.random(inventoryInfo.minTry or 0, inventoryInfo.maxTry or 0)
		local maxRarity = inventoryInfo.MAX_RARITY or 0

		-- Item generation
		timer.Create("LootGen", 0.05, trys, function()

			if ( newInv) then
				local item = RandomItem(rarities, maxRarity)

				if ( item ) then
					local quantity = math.random(item.min or 1, item.max or 1)
					newInv:add(item.id, quantity)
				end
			end

		end)

	end

end


-- Make NPC loot on death
function PLUGIN:OnNPCKilled( npc, attacker, inflictor )

	local class = npc:GetClass()

	local lootInfo = PLUGIN:GetClassLoot(class)
	if ( lootInfo ) then

		local pos = npc:GetPos()
		local ang = npc:GetAngles()

		PLUGIN:NpcLoot(npc, angles, lootInfo)

	end

end

PLUGIN.npcRandomLoot = PLUGIN.npcRandomLoot or {}

function PLUGIN:RegisterNpc(class, moneyInfo, inventoryInfo)

	PLUGIN.npcRandomLoot[class] = {
		money = moneyInfo,
		inventory = inventoryInfo
	}

end


function PLUGIN:GetNpcLootInfo(class)

	return PLUGIN.npcRandomLoot[class]
	
end