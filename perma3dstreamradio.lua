PLUGIN.name = "PermaRadios"
PLUGIN.author = "SuperMicronde"
PLUGIN.desc = "Make the 3d stream radios permanent."

if StreamRadioLib then

nut.command.add("3dradioclean", {
	superAdminOnly = true,
	onRun = function (client, arguments)
		for k, ent in pairs( ents.FindByClass( "sent_streamradio" ) ) do
			ent:Remove()
		end
		client:notify("Cleanup done")
	end
})

function PLUGIN:LoadData()
	local savedTable = self:getData() or {}

	for k, v in ipairs(savedTable) do
		local ent = StreamRadioLib.SpawnRadio( v.ply, v.mdl, v.pos, v.ang, v.settings )
		
		if not IsValid( ent ) then return end
		local phys = ent:GetPhysicsObject( )

		if ( IsValid( phys ) ) then
			phys:EnableCollisions( not nocollide )
			phys:EnableMotion(false)
		end
		
	end
end
	
function PLUGIN:SaveData()
		
	local savedTable = {}

	for k, v in ipairs(ents.FindByClass("sent_streamradio")) do
		table.insert(savedTable, {ply = v.pl, mdl = v:GetModel(), pos = v:GetPos(), ang = v:GetAngles(), settings = v.SettingVar})
	end

	self:setData(savedTable)
end

end