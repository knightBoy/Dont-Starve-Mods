require("recipe")

local MakePlayerCharacter = require "prefabs/player_common"

local assets = {

        Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),

        Asset( "IMAGE", "images/tabs/alvikatab.tex"),
        Asset( "ATLAS", "images/tabs/alvikatab.xml"),

        Asset( "ANIM", "anim/alvika.zip" ),
}
local prefabs = {}
local start_inv = {
	"xiaohua_fish"
}

local function common_postinit(inst)
    -- choose which sounds this character will play
    inst.soundsname = "willow"

    -- Minimap icon
    inst.MiniMapEntity:SetIcon( "alvika.tex" )  
end

local fn = function(inst)
	-- Stats	
	inst.components.health:SetMaxHealth(150)
	inst.components.hunger:SetMax(150)
	inst.components.sanity:SetMax(100)
	
	-- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 1
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
	-- Movement speed (optional)
	inst.components.locomotor.walkspeed = 5
	inst.components.locomotor.runspeed = 6

    -- Add magic wand recipe
    --local alvikatab = {str = "Alvika", sort=999, icon = "alvikatab.tex", icon_atlas = "images/tabs/alvikatab.xml"}
    --inst.components.builder:AddRecipeTab(alvikatab)
    local magicwand = Recipe("magicwand", {Ingredient("log", 4), Ingredient("rocks", 4), Ingredient("bluegem", 1)}, RECIPETABS.WAR, {SCIENCE = 0})
    magicwand.atlas = "images/inventoryimages/magicwand.xml"
    
end

return MakePlayerCharacter("alvika", prefabs, assets, common_postinit, fn, start_inv)
