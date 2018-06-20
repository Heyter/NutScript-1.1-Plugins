local PLUGIN = PLUGIN

--[[ Vars management ]]--

local corpses_vars = {
	"Entity",
	"Inventory",
	"Money",
	"Name"
}

for _, v in pairs(corpses_vars) do
	local name = "Cur"..v
	AccessorFunc(PLUGIN, name, name)
end

function PLUGIN:EraseVars()
	for _, v in pairs(corpses_vars) do
		PLUGIN["SetCur"..v](PLUGIN, nil)
	end
end

--[[ Loot interface ]]--

PLUGIN.nextTrace = PLUGIN.nextTrace or 0
-- Request corpse opening to server when pressing E on a corpse
function PLUGIN:KeyPress(_, key)

	if ( key == IN_USE and CurTime() > PLUGIN.nextTrace ) then
		local entLooked = PLUGIN:EyeTrace(LocalPlayer())

		if ( IsValid(entLooked) and entLooked:IsCorpse() ) then
			PLUGIN:SetCurEntity(entLooked)

			netstream.Start("lootOpen")
		end

		PLUGIN.nextTrace = CurTime() + 0.5
	end

end

function PLUGIN:SetCorpseMoney(value)
	PLUGIN:SetCurMoney(value)

	if ( IsValid(PLUGIN.widthdrawText) ) then
		PLUGIN.widthdrawText:SetText( nut.currency.get(value) )
	end
end

netstream.Hook("lootMoney", function(value)
	PLUGIN:SetCorpseMoney(value)
end)

local function widthdrawMoney(panel)
	
	local entry = PLUGIN.widthdrawEntry
	local value = tonumber(entry:GetValue()) or 0

	if ( PLUGIN:GetCurMoney() >= value and value > 0 ) then
		
		surface.PlaySound("hgn/crussaria/items/itm_gold_up.wav")
		netstream.Start("lootWdMny", value)
		entry:SetValue(0)
		
	elseif ( value < 1  ) then
		
		nut.util.notify(L("provideValidNumber"))
		entry:SetValue(0)
		
	else
		
		nut.util.notify(L("cantAfford"))
		entry:SetValue(0)
		
	end

end

local function depositMoney(panel)

	local entry = PLUGIN.depositEntry
	local value = tonumber(entry:GetValue()) or 0

	if ( value and value > 0 ) then

		if ( LocalPlayer():getChar():hasMoney(value) ) then

			surface.PlaySound("hgn/crussaria/items/itm_gold_down.wav")
			netstream.Start("lootDpMny", value)
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

-- Display loot panel
function PLUGIN:DisplayInventory()

	-- Player loot
	nut.gui.inv1 = vgui.Create("nutInventory")
	nut.gui.inv1:ShowCloseButton(true)

	local oldClose = nut.gui.inv1.OnClose
	nut.gui.inv1.OnClose = function()
		
		if (IsValid(PLUGIN.lootingPanelMain) and !IsValid(nut.gui.menu)) then
			PLUGIN.lootingPanelMain:Remove()
		end

		netstream.Start("lootExit")

		oldClose()
	end

	local inventory2 = LocalPlayer():getChar():getInv()
	if (inventory2) then
		nut.gui.inv1:setInventory(inventory2)
	end

	-- Adjust inventory size to show deposit elements
	nut.gui.inv1:SetSize(nut.gui.inv1:GetWide(), nut.gui.inv1:GetTall() + 48)

	PLUGIN.depositText = nut.gui.inv1:Add("DLabel")
	PLUGIN.depositText:Dock(BOTTOM)
	PLUGIN.depositText:DockMargin(0, 0, nut.gui.inv1:GetWide()/2, 0)
	PLUGIN.depositText:SetTextColor(color_white)
	PLUGIN.depositText:SetFont("nutGenericFont")
	PLUGIN.depositText:SetText( nut.currency.get(LocalPlayer():getChar():getMoney()) )
	PLUGIN.depositText.Think = function()

		local char = LocalPlayer():getChar()

		if ( char and IsValid(PLUGIN:GetCurEntity()) ) then
			PLUGIN.depositText:SetText( nut.currency.get(char:getMoney()) )
		else
			nut.gui.inv1:Close()
		end

	end

	PLUGIN.depositEntry = nut.gui.inv1:Add("DTextEntry")
	PLUGIN.depositEntry:Dock(BOTTOM)
	PLUGIN.depositEntry:SetNumeric(true)
	PLUGIN.depositEntry:DockMargin(nut.gui.inv1:GetWide()/2, 0, 0, 0)
	PLUGIN.depositEntry:SetValue(0)
	PLUGIN.depositEntry.OnEnter = depositMoney

	PLUGIN.depositButton = nut.gui.inv1:Add("DButton")
	PLUGIN.depositButton:Dock(BOTTOM)
	PLUGIN.depositButton:DockMargin(nut.gui.inv1:GetWide()/2, 40, 0, -40)
	PLUGIN.depositButton:SetTextColor( Color( 255, 255, 255 ) )
	PLUGIN.depositButton:SetText("Deposit")
	PLUGIN.depositButton.DoClick = depositMoney
	
	-- Victim loot
	local inventory = PLUGIN:GetCurInventory()

	PLUGIN.lootingPanelMain = vgui.Create("nutInventory")
	PLUGIN.lootingPanelMain:ShowCloseButton(true)
	PLUGIN.lootingPanelMain:SetTitle("Loot")
	PLUGIN.lootingPanelMain:setInventory(inventory)
	PLUGIN.lootingPanelMain:MoveLeftOf(nut.gui.inv1, 4)
	PLUGIN.lootingPanelMain.OnClose = function(this)

		if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
			nut.gui.inv1:Remove()
		end

		netstream.Start("lootExit")
	end

	-- Adjust inventory size to show widthdraw elements
	PLUGIN.lootingPanelMain:SetSize(PLUGIN.lootingPanelMain:GetWide(), PLUGIN.lootingPanelMain:GetTall() + 48)

	PLUGIN.widthdrawText = PLUGIN.lootingPanelMain:Add("DLabel")
	PLUGIN.widthdrawText:Dock(BOTTOM)
	PLUGIN.widthdrawText:DockMargin(0, 0, PLUGIN.lootingPanelMain:GetWide()/2, 0)
	PLUGIN.widthdrawText:SetTextColor(color_white)
	PLUGIN.widthdrawText:SetFont("nutGenericFont")

	PLUGIN.widthdrawEntry = PLUGIN.lootingPanelMain:Add("DTextEntry")
	PLUGIN.widthdrawEntry:Dock(BOTTOM)
	PLUGIN.widthdrawEntry:SetNumeric(true)
	PLUGIN.widthdrawEntry:DockMargin(PLUGIN.lootingPanelMain:GetWide()/2, 0, 0, 0)
	PLUGIN.widthdrawEntry:SetValue(PLUGIN:GetCurMoney() or 0)
	PLUGIN.widthdrawEntry.OnEnter = widthdrawMoney

	PLUGIN.widthdrawButton = PLUGIN.lootingPanelMain:Add("DButton")
	PLUGIN.widthdrawButton:Dock(BOTTOM)
	PLUGIN.widthdrawButton:DockMargin(PLUGIN.lootingPanelMain:GetWide()/2, 40, 0, -40)
	PLUGIN.widthdrawButton:SetTextColor( Color( 255, 255, 255 ) )
	PLUGIN.widthdrawButton:SetText("Widthdraw")
	PLUGIN.widthdrawButton.DoClick = widthdrawMoney

	nut.gui["inv"..inventory:getID()] = PLUGIN.lootingPanelMain

end

-- Stared action to open the inventory of a corpse
netstream.Hook("lootOpen", function(invId, money)

	local corpse = PLUGIN:GetCurEntity()
	local inventory = nut.item.inventories[invId]

	if ( IsValid(corpse) and inventory and isnumber(money) ) then

		PLUGIN:SetCurInventory(inventory)
		PLUGIN:DisplayInventory()
		
		PLUGIN:SetCorpseMoney(money)

	end

end)