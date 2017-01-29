PrefabFiles = {
	"alvika",
    "magicwand",
    "xiaohua",
    "xiaohua_fish",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/alvika.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/alvika.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/alvika.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/alvika.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/alvika_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/alvika_silho.xml" ),

    Asset( "IMAGE", "bigportraits/alvika.tex" ),
    Asset( "ATLAS", "bigportraits/alvika.xml" ),
	
	Asset( "IMAGE", "images/map_icons/alvika.tex" ),
	Asset( "ATLAS", "images/map_icons/alvika.xml" ),

    Asset( "IMAGE", "images/inventoryimages/magicwand.tex"),
    Asset( "ATLAS", "images/inventoryimages/magicwand.xml"),

    Asset( "IMAGE", "images/inventoryimages/xiaohua_fish.tex"),
    Asset( "ATLAS", "images/inventoryimages/xiaohua_fish.xml"),
}

-- The magicwand info
GLOBAL.STRINGS.NAMES.MAGICWAND = "Magicwand"
GLOBAL.STRINGS.RECIPE_DESC.MAGICWAND = "A magic stick"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAGICWAND = "Magicwand"

-- The Character select screen lines
GLOBAL.STRINGS.CHARACTER_TITLES.alvika = "Alvika"
GLOBAL.STRINGS.CHARACTER_NAMES.alvika = "Alvika"
GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS.alvika = "A magic girl \nstrengthen by magic cards"
GLOBAL.STRINGS.CHARACTER_QUOTES.alvika = "\"I will use magic to change the world\""

table.insert(GLOBAL.CHARACTER_GENDERS.MALE, "alvika")
AddMinimapAtlas("images/map_icons/alvika.xml")
AddModCharacter("alvika")

-- make goldnugget can be fuel
local function makeFuel(inst)
    if not inst.components.fuel then
        inst:AddComponent("fuel")
    end
    inst.components.fuel.fueltype = "ALVIKA_FUEL"
end
AddPrefabPostInit("goldnugget", makeFuel) 

--[[
function SpawnCreature(player)
    local x, y, z = player.Transform:GetWorldPosition()
    local creature = GLOBAL.SpawnPrefab("xiaohua_fish")
    creature.Transform:SetPosition( x, y, z )   
end
AddSimPostInit(SpawnCreature)
]]