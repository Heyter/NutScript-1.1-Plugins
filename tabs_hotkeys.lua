PLUGIN.name = "Quick Tabs"
PLUGIN.author = "SuperMicronde"
PLUGIN.desc = "This plugin adds quick tabs key"

PLUGIN.DefaultKeys = {
	[KEY_F2] = "inv"
}


if (CLIENT) then

function PLUGIN:GetNutMenu()
	if !IsValid(nut.gui.menu) && LocalPlayer():getChar() then
		nut.gui.menu = vgui.Create("nutMenu")
	end
	
	return nut.gui.menu
end

function PLUGIN:PlayerButtonDown( client, button )
	local bind = self.DefaultKeys[button]
	
	if bind then
		local menu = self:GetNutMenu()

		if IsValid(menu) then
			menu:SetAlpha(255)
			menu.title:SetAlpha(255)
			menu.panel:SetAlpha(255)
			menu:setActiveTab(bind)
		end
	end
end

end