PLUGIN.name = "Instakilling"
PLUGIN.author = "SuperMicronde"
PLUGIN.desc = "Instakilling when head or neck is shooted"

nut.config.add("instakilling", true, "Instakilling activated ?", nil, {
	category = "server"
})

hook.Add("EntityTakeDamage", "PlayerTakeDamageAtHead", function( target, dmg )
	
	if nut.config.get("instakilling", true) then
	
		local victimHealth = target:Health()
		
		if IsValid(target) && target:IsPlayer() && dmg:GetDamage() <= victimHealth && dmg:IsDamageType( DMG_BULLET ) then
			
			local shootPos = dmg:GetDamagePosition()
			local bonePos = target:GetBonePosition(target:LookupBone( "ValveBiped.Bip01_Head1" ))
			
			if shootPos:Distance(bonePos) < 9 then
				
				dmg:SetDamage( victimHealth + math.random( 1, 23 ))
			
			end
			
		end
		
	end	

end)
