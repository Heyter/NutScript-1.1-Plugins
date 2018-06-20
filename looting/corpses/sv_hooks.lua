local PLUGIN = PLUGIN

-- Make player loot on death
function PLUGIN:DoPlayerDeath( victim, attacker, dmg )

	local char = victim:getChar()

	if ( not char ) then return end

	local corpse = PLUGIN:MakeCorpseFromVictim(victim)

	if ( IsValid(corpse) ) then
		hook.Run("OnCorpseCreated", corpse, victim, char)

		if ( victim:IsOnFire() ) then
			corpse:Ignite(8)
		end
	end

end

-- Disable player's default corpses
function PLUGIN:PlayerDeath( victim, inflictor, attacker )

	local OldRagdoll = victim:GetRagdollEntity()
	if ( IsValid(OldRagdoll) ) then OldRagdoll:Remove() end

end

-- Aplly victim movement on corpse
function PLUGIN:SetupBones(corpse, victim)

	local victim_vel = victim:GetVelocity() / 5
	local num = corpse:GetPhysicsObjectCount() - 1

	for i = 0, num do
		local physObj = corpse:GetPhysicsObjectNum(i)

		if ( IsValid(physObj) ) then
			if ( victim_vel ) then
				physObj:SetVelocity(victim_vel)
			end

			local boneId = corpse:TranslatePhysBoneToBone(i)
			if ( boneId ) then
				local pos, ang = victim:GetBonePosition(boneId)

				physObj:SetPos(pos)
				physObj:SetAngles(ang)
			end
		end
	end
	
end

-- Make a little prop to carry the corpse from Hands swep
function PLUGIN:MakeHandle(ent)

	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	-- Prop hitbox
	local prop = ents.Create("prop_physics")
	prop:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	prop:SetPos(ent:GetPos())
	prop:SetCollisionGroup(COLLISION_GROUP_WORLD)
	prop:SetNoDraw(true)
	
	prop:Spawn()
	prop:Activate()

	prop:AttachTo(ent)

end

-- Create a corpse from a victim
function PLUGIN:MakeCorpseFromVictim(victim)

	-- Make the corpse
	local corpse = ents.Create("prop_ragdoll")
	corpse:SetNW2Bool("isLootCorpse", true)
	victim:CloneVarsOn(corpse)

	-- Spawn the corpse
	corpse:Spawn()
	corpse:Activate()

	-- Setup the bones
	PLUGIN:SetupBones(corpse, victim)

	-- Use a prop as hitbox to save net bandwidth
	PLUGIN:MakeHandle(corpse)

	return corpse

end