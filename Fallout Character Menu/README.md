# Fallout Character Menu

This is for change the default character menu of NutScript by the Lazarus Community Fallout: New Vegas Menu

![alt text](https://image.ibb.co/bzkiD7/20180210134327_1.jpg "Menu")

## Instructions:

1) Add thoses addons:

-https://steamcommunity.com/sharedfiles/filedetails/?id=745887766
-https://steamcommunity.com/sharedfiles/filedetails/?id=746871240

2) Download schema.rar and paste the schema folder in garrysmod/gamemodes/yourgamemode/	NOT IN "nutscript" FOLDER !
3) Download resources.rar and paste the resources folder in garrysmod/gamemodes/yourgamemode/	NOT IN "nutscript" FOLDER !
4) Download cl_character.lua and paste in garrysmod/gamemodes/nutscript/gamemode/core/derma/ (Advice: Do a backup of the original cl_character.lua file)
5) Download sh_character.lua and paste in garrysmod/gamemodes/nutscript/gamemode/core/libs/ (Advice: Do a backup of the original sh_character.lua file)
6) Add in garrysmod/gamemodes/yourgamemode/schema/sh_schema.lua :

```lua
nut.util.include("cl_cinematics.lua")
nut.util.include("cl_charcreation.lua")
nut.util.include("cl_fonts.lua")
```
