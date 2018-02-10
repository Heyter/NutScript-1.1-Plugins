# Fallout Character Menu

This is for change the default character menu of NutScript by the Lazarus Community Fallout: New Vegas Menu

![alt text](https://image.ibb.co/bzkiD7/20180210134327_1.jpg "Menu")

## Instructions:

1) Download schema.rar and paste the schema folder in garrysmod/gamemodes/yourgamemode/	NOT IN "nutscript" FOLDER !
2) Download resources.rar and paste the resources folder in garrysmod/gamemodes/yourgamemode/	NOT IN "nutscript" FOLDER !
3) Download cl_character.lua and paste in garrysmod/gamemodes/nutscript/gamemode/core/derma/ (Advice: Do a backup of the original cl_character.lua file)
4) Download sh_character.lua and paste in garrysmod/gamemodes/nutscript/gamemode/core/libs/ (Advice: Do a backup of the original sh_character.lua file)
5) Add in garrysmod/gamemodes/yourgamemode/schema/sh_schema.lua :

```lua
nut.util.include("cl_cinematics.lua")
nut.util.include("cl_charcreation.lua")
nut.util.include("cl_names.lua")
nut.util.include("sh_customization.lua")
nut.util.include("sh_hooks.lua") // (If its not already did)
nut.util.include("cl_fonts.lua")
```

6) Add in garrysmod/gamemodes/yourgamemode/schema/sh_hooks.lua (Create sh_hooks.lua if its not already did) :

```lua
player.FindByUserID = function(uid)
	for k, v in pairs(player.GetAll()) do
		if (v:UserID() == uid) then
			return v
		end
	end

	return nil
end

local playerMeta = FindMetaTable("Player")

function playerMeta:IsGhoul()
	return self:GetModel() == "models/lazarusroleplay/heads/ghoul_default.mdl"
end

function playerMeta:SetEyeMaterial(eyemat)
	local index, material = 3, nut.util.getMaterial("models/lazarus/shared/"..eyemat)
	if (self:GetGender() == "female") then
		index = 1
	end
end

SCHEMA.SkinTones = {}
SCHEMA.SkinTones["models/lazarusroleplay/heads/male_african.mdl"] = 3
SCHEMA.SkinTones["models/lazarusroleplay/heads/male_asian.mdl"] = 7
SCHEMA.SkinTones["models/lazarusroleplay/heads/male_caucasian.mdl"] = 1
SCHEMA.SkinTones["models/lazarusroleplay/heads/male_hispanic.mdl"] = 5
SCHEMA.SkinTones["models/lazarusroleplay/heads/female_african.mdl"] = 3
SCHEMA.SkinTones["models/lazarusroleplay/heads/female_asian.mdl"] = 7
SCHEMA.SkinTones["models/lazarusroleplay/heads/female_caucasian.mdl"] = 1
SCHEMA.SkinTones["models/lazarusroleplay/heads/female_hispanic.mdl"] = 5

SCHEMA.MutantModels = {}

SCHEMA.MutantModels["models/thespireroleplay/Fallout/Dogs/coyote.mdl"] = true
SCHEMA.MutantModels["models/thespireroleplay/Fallout/Dogs/dog.mdl"] = true
SCHEMA.MutantModels["models/thespireroleplay/Fallout/Dogs/mongrel.mdl"] = true
SCHEMA.MutantModels["models/thespireroleplay/Fallout/Dogs/rex.mdl"] = true
SCHEMA.MutantModels["models/thespireroleplay/Fallout/Dogs/rex_military.mdl"] = true
SCHEMA.MutantModels["models/thespireroleplay/Fallout/Dogs/rex_police.mdl"] = true
SCHEMA.MutantModels["models/thespireroleplay/Fallout/Dogs/vicious.mdl"] = true
SCHEMA.MutantModels["models/thespireroleplay/Fallout/Dogs/coyote.mdl"] = true
SCHEMA.MutantModels["models/fallout/supermutant.mdl"] = true
SCHEMA.MutantModels["models/fallout/supermutant_behemoth.mdl"] = true
SCHEMA.MutantModels["models/fallout/supermutant_heavy.mdl"] = true
SCHEMA.MutantModels["models/fallout/supermutant_light.mdl"] = true
SCHEMA.MutantModels["models/fallout/supermutant_medium.mdl"] = true
SCHEMA.MutantModels["models/fallout/supermutant_nightkin.mdl"] = true

function playerMeta:GetSkinTone()
	if SCHEMA.SkinTones[self:GetModel()] then
		return SCHEMA.SkinTones[self:GetModel()]
	elseif self.character then
		if self.character:GetData("facemap") then
			return self.character:GetData("facemap") - 1
		else
			return 0
		end
	else
		return 0
	end
end

function playerMeta:GetRace()
	local race = "caucasian"

	if (SCHEMA.SkinTones[self:GetModel()]) and (SCHEMA.SkinTones[self:GetModel()] == 3) then
		race = "african"
	elseif (SCHEMA.SkinTones[self:GetModel()]) and (SCHEMA.SkinTones[self:GetModel()] == 7) then
		race = "asian"
	elseif (SCHEMA.SkinTones[self:GetModel()]) and (SCHEMA.SkinTones[self:GetModel()] == 1) then
		race = "caucasian"
	elseif (SCHEMA.SkinTones[self:GetModel()]) and (SCHEMA.SkinTones[self:GetModel()] == 5) then
		race = "hispanic"
	end

	return race
end

function playerMeta:IsMutant()
	if (!self:IsRobot()) then
		if !SCHEMA.SkinTones[self:GetModel()] then
			return true
		end
	end
end
```
