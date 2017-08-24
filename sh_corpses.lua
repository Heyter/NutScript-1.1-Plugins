PLUGIN.name = "Corpses"
PLUGIN.author = "SuperMicronde"
PLUGIN.desc = "You can search the player corpses for take items and money."

//Items that you dont want to be put in the corpse when you die //
local BLACKLIST = {												//
	"cid", // Dont forget the "," !								//
}																//
//////////////////////////////////////////////////////////////////

nut.config.add("corpseTimer", 86000, "Après combien de temps un corps disparaît", nil, {
	data = {min = 0, max = 86400},
	category = "server",
	default = 86000,
	value = 86000,
})

nut.config.add("corpseOpenTime", 5, "Combien de temps prend un joueur a fouiller un corps", nil, {
	data = {min = 0, max = 20},
	category = "server",
	default = 5,
	value = 5,
})

nut.command.add("corpsesclean", {
	superAdminOnly = true,
	onRun = function (client, arguments)
		for k, itm in pairs( ents.FindByClass( "prop_ragdoll" ) ) do
			if itm:GetClass() == "prop_ragdoll" && itm:GetNWInt("nut_inventoryID", -1) > 1 then
				itm:Remove()
			end
		end
		client:notify("Cleanup effectué")
	end
})

local function isOnBlacklist(item)
	return table.HasValue( BLACKLIST, item )
end

if(SERVER)then

local alreadySpawn = false

local function addReserve(amt, ragdoll)
	ragdoll:SetNWInt("corpseMoney", ragdoll:GetNWInt("corpseMoney") + amt)
end

local function takeReserve(amt, ragdoll)
	addReserve(-amt, ragdoll)
end

netstream.Hook("askOpenToServer", function(client, index, ownerName, ragdollEnt)
	if !nut.item.inventories[index] then
		nut.item.restoreInv(index, ragdollEnt:GetNWInt("corpseInvW"), ragdollEnt:GetNWInt("corpseInvH"))
	end
	
	nut.item.inventories[index]:sync(client)
	
	client:setAction("Fouille", nut.config.get("corpseOpenTime"), function()
		if IsValid(ragdollEnt) then
			netstream.Start(client, "corpseInvSynced", index, ownerName, ragdollEnt)
		end
	end)	
end)
	
netstream.Hook("BankTakeMoneyCorpse", function(client, value, ragdoll)
	if IsValid(ragdoll) && ragdoll:GetNWInt("corpseMoney") >= value then
		client:getChar():giveMoney(value)
		takeReserve(value, ragdoll)
	end
end)
	
netstream.Hook("BankGiveMoneyCorpse", function(client, value, ragdoll)
	if IsValid(ragdoll) && client:getChar():getMoney() >= value then
		client:getChar():takeMoney(value)
		addReserve(value, ragdoll)
	end
end)

function createRagdoll(ragdollData)
	local ragdoll = ents.Create("prop_ragdoll");
	ragdoll:SetNWString("nut_inventoryOwner", ragdollData[1])
	ragdoll:SetMaterial(ragdollData[2]);
	ragdoll:SetAngles(ragdollData[3]);
	ragdoll:SetColor(ragdollData[4]);
	ragdoll:SetModel(ragdollData[5]);
	ragdoll:SetSkin(ragdollData[6]);
	ragdoll:SetPos(ragdollData[7]);
	ragdoll:SetVar("time", ragdollData[8])
	ragdoll:SetNWInt("nut_inventoryID", ragdollData[9])
	ragdoll:SetNWInt("corpseMoney", ragdollData[10])
	ragdoll:SetNWInt("corpseInvH", ragdollData[11])
	ragdoll:SetNWInt("corpseInvW", ragdollData[12])
	ragdoll:Spawn();
end

function PLUGIN:LoadData()
	if alreadySpawn == false then
		alreadySpawn = true
		for k, v in pairs(self:getData()) do
			createRagdoll(v)
		end
	end
end

function PLUGIN:SaveData()

	local ragdolls = {}

	for k, v in pairs(ents.FindByClass( "prop_ragdoll" )) do
		if v:GetNWInt("nut_inventoryOwner") then
		
			ragdolls[#ragdolls + 1] = {v:GetNWString("nut_inventoryOwner"), v:GetMaterial(), v:GetAngles(), v:GetColor(), v:GetModel(), v:GetSkin(), v:GetPos(), v:GetVar("time"), v:GetNWInt("nut_inventoryID"), v:GetNWInt("corpseMoney"), v:GetNWInt("corpseInvH"), v:GetNWInt("corpseInvW")}
		end
	end
	
	self:setData(ragdolls)
end

function PLUGIN:PlayerDeath(victim, inflictor, attacker)
	
	if victim:getChar() then
		local OldRagdoll = victim:GetRagdollEntity()
		if ( OldRagdoll && OldRagdoll:IsValid() ) then OldRagdoll:Remove() end
		
		nut.item.newInv(0, "corpse."..victim:getChar():getID(), function(inventory)
			local victimInv = victim:getChar():getInv()
			inventory.h = victimInv.h
			inventory.w = victimInv.w
			
			if #victimInv:getItems() then
				for k, v in pairs(victimInv:getItems()) do
					local item = victimInv:getItemAt(v.gridX, v.gridY)
					
					if !isOnBlacklist(item.uniqueID) then
						if item.functions.EquipUn then
							item.player = victim
							item.functions.EquipUn.onRun(item)
						end
					
						inventory:add(item.uniqueID, 1, item.data, v.gridX, v.gridY)
					end
				
				end
			end
			
			local ragdollData = {victim:getChar():getName(), victim:GetMaterial(), victim:GetAngles(), victim:GetColor(), victim:GetModel(), victim:GetSkin(), victim:GetPos(), 0, inventory:getID(), victim:getChar():getMoney(), inventory.h, inventory.w}
			createRagdoll(ragdollData)
		end)
		
		if (nut.config.get("pkActive") == false) or (nut.config.get("pkActive") == true && nut.config.get("pkWorld") == true && inflictor:IsWorld()) then
			local victimChar = victim:getChar()
			local victimInv = victimChar:getInv()

			for key, value in pairs(victimInv:getItems()) do
				if !isOnBlacklist(value.uniqueID) then
					victimInv:remove(value.id)
				end
			end
				
			victimChar:setMoney(0)
		end

	end
	
end

hook.Add("EntityRemoved", "remove_inv_from_db_corpse", function(ent)
	if ent:GetClass() == "prop_ragdoll" && ent:GetNWInt("nut_inventoryOwner", nil) then
		local index = ent:GetNWInt("nut_inventoryID")

		if (!nut.shuttingDown and !ent.nutIsSafe and index) then
			local item = nut.item.inventories[index]

			if (item) then
				nut.item.inventories[index] = nil
				nut.db.query("DELETE FROM nut_items WHERE _invID = "..index)
				nut.db.query("DELETE FROM nut_inventories WHERE _invID = "..index)
			end
		end
	end
end)

local nextUpdate = 0

hook.Add("Think", "supprimer_le_corps", function()
	if CurTime() > nextUpdate then
		nextUpdate = CurTime() + 1
		for k, v in pairs(ents.FindByClass( "prop_ragdoll" )) do
			if v:GetVar( "time" ) then
				v:SetVar("time", v:GetVar( "time" ) + 1)
				if v:GetVar( "time" ) >= nut.config.get("corpseTimer") then
					v:Remove()
				end
			end
		end
	end
end)

end

if(CLIENT)then
	local inventory = nil
	local name = nil
	local showHud = nil
	local inventoryMoney = nil
	local ragdollEntity = nil
	
	hook.Add("HUDPaint", "corpse_hud_nut1.1", function()
		if LocalPlayer():getChar() && LocalPlayer():Alive() then
			local eyeTrace = LocalPlayer():GetEyeTraceNoCursor().Entity
			if IsValid(eyeTrace) && eyeTrace:GetClass() == "prop_ragdoll" && eyeTrace:GetNWInt("nut_inventoryID", -1) > 1 && LocalPlayer():GetPos():Distance( eyeTrace:GetPos()) < 60 then
				inventory = eyeTrace:GetNWInt("nut_inventoryID")
				name = eyeTrace:GetNWString("nut_inventoryOwner")
				ragdollEntity = eyeTrace
				// HUD
				if 	showHud != false then
					surface.SetFont( "CenterPrintText" )
					surface.SetTextColor( 255, 255, 255 )
					local invOwnerID = eyeTrace:GetNWInt("nut_inventoryID")
					local invOwner = eyeTrace:GetNWString("nut_inventoryOwner")
					local textToDraw = ""
					
					if LocalPlayer():getChar():doesRecognize(invOwnerID) then
						textToDraw = invOwner
					else
						textToDraw = L("noRecog")
					end
					
					local xSize, ySize = surface.GetTextSize( textToDraw )
					surface.SetTextPos( (ScrW() / 2) - (xSize / 2), (ScrH() / 2) - (ySize / 2) - ScrH() * 0.035)
					surface.DrawText( textToDraw )
				
					surface.SetFont( "Trebuchet24" )
					//surface.SetTextColor( 156, 56, 58 ) Bug de transparence
					textToDraw = "Fouiller: \""..string.upper( input.LookupBinding( "+use" ) ).."\""
					xSize, ySize = surface.GetTextSize( textToDraw )
					surface.SetTextPos( (ScrW() / 2) - (xSize / 2), (ScrH() / 2) - (ySize / 2) + ScrH() * 0.035)
					surface.DrawText( textToDraw )
				end
			else
				inventory = nil
				inventoryMoney = nil
				name = nil
				ragdollEntity = nil
			end
		end
	end)
	
	//MENU
	
	local function displayInventory(inventoryId, ownerName, ragdollEnt)
		nut.gui.inv1 = vgui.Create("nutInventory")
		nut.gui.inv1:ShowCloseButton(true)

		local inventory2 = LocalPlayer():getChar():getInv()

		if (inventory2) then
			nut.gui.inv1:setInventory(inventory2)
		end

		safebox_menuINV = vgui.Create("nutInventory")
		safebox_menuINV:ShowCloseButton(true)
		
		local title = nil
		
		if LocalPlayer():getChar():doesRecognize(inventoryId) then
			title = ownerName
		else
			title = L("noRecog")
		end
		
		safebox_menuINV:SetTitle(title)
		safebox_menuINV:setInventory(nut.item.inventories[inventoryId])
		safebox_menuINV:MoveRightOf(nut.gui.inv1, 4)

		safebox_menuINV.OnClose = function(this)
			if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
				nut.gui.inv1:Remove()
			end
		end
		
		local oldClose = nut.gui.inv1.OnClose
		nut.gui.inv1.OnClose = function()
			if (IsValid(safebox_menuINV) and !IsValid(nut.gui.menu)) then
				safebox_menuINV:Remove()
			end
			nut.gui.inv1.OnClose = oldClose
		end

		nut.gui["inv"..inventoryId] = safebox_menuINV
		nut.gui.inv1:SetSize(nut.gui.inv1:GetWide(), nut.gui.inv1:GetTall() + 48)
		local text = nut.gui.inv1:Add("DLabel")
		text.Think = function()
			if LocalPlayer():getChar() && IsValid(ragdollEnt) then
				text:SetText(nut.currency.get(LocalPlayer():getChar():getMoney()))
			else
				nut.gui.inv1:Remove()
				safebox_menuINV:Remove()
			end
		end
		text:Dock(BOTTOM)
		text:DockMargin(0, 0, nut.gui.inv1:GetWide()/2, 0)
		text:SetTextColor(color_white)
		text:SetFont("nutGenericFont")
		
		local entry = nut.gui.inv1:Add("DTextEntry")
		entry:Dock(BOTTOM)
		entry:DockMargin(nut.gui.inv1:GetWide()/2, 0, 0, 0)
		entry:SetValue(0)
		entry:SetNumeric(true)
		entry.OnEnter = function()
			local value = tonumber(entry:GetValue()) or 0
			if value and value > 0 then
				if LocalPlayer():getChar():hasMoney(value) then
					surface.PlaySound("hgn/crussaria/items/itm_gold_down.wav")
					netstream.Start("BankGiveMoneyCorpse", value, ragdollEnt)
					--nut.command.send("actstand", 4)
					entry:SetValue(0)
				else
					nut.util.notify(L("provideValidNumber"))
					entry:SetValue(0)
				end
			else
				nut.util.notify(L("cantAfford"))
				entry:SetValue(0)
			end		
		end
		
		local transfer = nut.gui.inv1:Add("DButton")
		transfer:Dock(BOTTOM)
		transfer:DockMargin(nut.gui.inv1:GetWide()/2, 40, 0, -40)
		transfer:SetText("Déposer")
		transfer.DoClick = function()
			local value = tonumber(entry:GetValue()) or 0
			if value and value > 0 then
				if LocalPlayer():getChar():hasMoney(value) then
					surface.PlaySound("hgn/crussaria/items/itm_gold_down.wav")
					netstream.Start("BankGiveMoneyCorpse", value, ragdollEnt)
					--nut.command.send("actstand", 4)
					entry:SetValue(0)
				else
					nut.util.notify(L("provideValidNumber"))
					entry:SetValue(0)
				end
			else
				nut.util.notify(L("cantAfford"))
				entry:SetValue(0)
			end					
		end
		
		safebox_menuINV:SetSize(safebox_menuINV:GetWide(), safebox_menuINV:GetTall() + 48)
		
		local text1 = safebox_menuINV:Add("DLabel")
		text1.Think = function()
			if LocalPlayer():getChar() && IsValid(ragdollEnt) then
				text1:SetText(nut.currency.get(ragdollEnt:GetNWInt("corpseMoney")))
			else
				nut.gui.inv1:Remove()
				safebox_menuINV:Remove()
			end
		end			
		text1:Dock(BOTTOM)
		text1:DockMargin(0, 0, safebox_menuINV:GetWide()/2, 0)
		text1:SetTextColor(color_white)
		text1:SetFont("nutGenericFont")
		
		local entry1 = safebox_menuINV:Add("DTextEntry")
		entry1:Dock(BOTTOM)
		entry1:SetValue(ragdollEnt:GetNWInt("corpseMoney") or 0)
		entry1:SetNumeric(true)
		entry1:DockMargin(safebox_menuINV:GetWide()/2, 0, 0, 0)
		entry1.OnEnter = function()
			local value = tonumber(entry1:GetValue()) or 0
			if ragdollEnt:GetNWInt("corpseMoney") >= value and value > 0 then
				surface.PlaySound("hgn/crussaria/items/itm_gold_up.wav")
				netstream.Start("BankTakeMoneyCorpse", value, ragdollEnt)
				entry1:SetValue(0)
			elseif value < 1 then
				nut.util.notify(L("provideValidNumber"))
				entry1:SetValue(0)
			else
				nut.util.notify(L("cantAfford"))
				entry1:SetValue(0)
			end			
		end
		
		local transfer1 = safebox_menuINV:Add("DButton")
		transfer1:Dock(BOTTOM)
		transfer1:DockMargin(safebox_menuINV:GetWide()/2, 40, 0, -40)
		transfer1:SetText("Retirer")
		transfer1.DoClick = function()
			local value = tonumber(entry1:GetValue()) or 0
			if ragdollEnt:GetNWInt("corpseMoney") >= value and value > 0 then
				surface.PlaySound("hgn/crussaria/items/itm_gold_up.wav")
				netstream.Start("BankTakeMoneyCorpse", value, ragdollEnt)
				entry1:SetValue(0)
			elseif value < 1 then
				nut.util.notify(L("provideValidNumber"))
				entry1:SetValue(0)
			else
				nut.util.notify(L("cantAfford"))
				entry1:SetValue(0)
			end								
		end
	end
	// FIN
	
	netstream.Hook("corpseInvSynced", function(index, ownerName, ragdollEnt)
		displayInventory(index, ownerName, ragdollEnt )
	end)
	
	hook.Add( "Tick", "CheckPlayer1Forward", function()
		if IsValid(LocalPlayer()) && inventory && LocalPlayer():Alive() then
			if (LocalPlayer():KeyPressed( IN_USE )) then
				netstream.Start("askOpenToServer", inventory, name, ragdollEntity)
			end
		end
	end )
end
