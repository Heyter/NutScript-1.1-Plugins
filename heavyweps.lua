PLUGIN.name = "Heavy weapons"
PLUGIN.author = "SuperMicronde"
PLUGIN.desc = "Define weapons that slow you down"

PLUGIN.slowWeps = {
	// ["weapon class"] = number of the max speed when you carry the weapon
	["fo3_fatman"] = 130,
	["fo3_fatman_nuke"] = 130,
	["swep_flamethrower"] = 130,
}

local nextCheck = 0

function PLUGIN:Think()
	if CurTime() > nextCheck then
		nextCheck = CurTime() + 0.1
		self:checkWeapons()
	end
end

function PLUGIN:checkWeapons()
	if SERVER then
		for k, ply in pairs(player.GetAll()) do
			local wepClass = ply:GetActiveWeapon():GetClass()
		
			if self.slowWeps[wepClass] then
				ply:SetRunSpeed(self.slowWeps[wepClass])
			else
				ply:SetRunSpeed(nut.config.get("runSpeed"))
			end
		end
	else
		local wepClass = LocalPlayer():GetActiveWeapon():GetClass()
		
		if self.slowWeps[wepClass] then
			ply:SetRunSpeed(self.slowWeps[wepClass])
		else
			ply:SetRunSpeed(nut.config.get("runSpeed"))
		end
	end
end
