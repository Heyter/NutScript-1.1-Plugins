# Fallout Character Menu (NOT DONE DONT DOWNLOAD)

DONT DOWNLOAD BRUDDA ITS NOT DONE

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
