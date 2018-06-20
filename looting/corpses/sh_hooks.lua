function PLUGIN:EyeTrace(client)

	local data = {}
	data.filter = client
	data.start = client:GetShootPos()
	data.endpos = data.start + client:GetAimVector()*80

	return util.TraceLine(data).Entity

end

local Entity = FindMetaTable("Entity")

function Entity:IsCorpse()

	return self:GetNW2Bool("isLootCorpse")

end