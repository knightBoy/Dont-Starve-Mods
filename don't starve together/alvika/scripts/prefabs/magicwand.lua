local assets=
{
    Asset("ANIM", "anim/magicwand.zip"),
    Asset("ANIM", "anim/swap_magicwand.zip"),
  
    Asset("ATLAS", "images/inventoryimages/magicwand.xml"), 
    Asset("IMAGE", "images/inventoryimages/magicwand.tex"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_magicwand", "swap_magicwand")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 

end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

-- when attack
local function onattack(inst, attacker, target)
    inst.components.fueled:DoDelta(-1)
end

-- upgrades
local function applyupgrades(inst)
    local max_level = 15
    local upgrades = math.min(max_level, inst.level)
    local attackadd = upgrades * 2
    inst.components.weapon:SetDamage(inst.initDamage + attackadd)
end

-- when kill entity
local function onkill(inst, data)
    if data then
        local kill_inst = data.inst
        local inst_max_health = kill_inst.components.health.maxhealth
        if math.random() < (inst_max_health - inst.level * 20)/600 then
            inst.level = inst.level + 1
            applyupgrades(inst)
            inst.components.talker:Say("magicwand levle "..inst.level)
        end
    end 
end

-- before the prefab load, get the data
local function onPreLoad(inst, data)
    if data then
        if data.level then
            inst.level = data.level
            applyupgrades(inst)
        end
        if data.nofuel then
            inst.nofuel = data.nofuel
        end
    end
end

-- when load, upgrade the prefab
local function onLoad(inst, data)
    if inst.nofuel == true then
        inst.components.weapon:SetDamage(5)
    end
end

-- save data
local function onSave(inst, data)
    data.level = inst.level
    data.nofuel = inst.nofuel
end

-- when fuel depleted
local function onDepleted(inst, data)
    inst.components.weapon:SetDamage(5)
    inst.components.talker:Say("There is no fuel")
end

-- take fuel
local function onTakefuel(inst, item, data)
    inst.components.fueled:DoDelta(25)
    if inst.nofuel == true then
        inst.nofuel = false
        applyupgrades(inst)
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    --add in minimap
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("magicwand.tex")

    anim:SetBank("magicwand")
    anim:SetBuild("magicwand")
    anim:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("alvikaweapon")

    inst.initDamage = 30
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(inst.initDamage)
    inst:ListenForEvent("onattacker",onattack)
    inst.components.weapon.onattack = onattack

    -- when kill entity
    inst:ListenForEvent("entity_death", function(wrld, data) onkill(inst, data) end, GetWorld())

    --inst:AddComponent("finiteuses")
    --inst.components.finiteuses:SetMaxUses(200)
    --inst.components.finiteuses:SetUses(200)
    --inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")
    --inst.components.inspectable:SetDescription("a sharp sword")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/magicwand.xml"

	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    -- add a talker
    inst:AddComponent("talker")
    inst.components.talker.fontsize = 20
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(1, 0.8, 0.65, 1)
    inst.components.talker.offset = Vector3(200,-250,0)
    inst.components.talker.symbol = "swap_object"

    -- can add fuel
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "NIGHTMARE"
    --inst.components.fueled.fueltype = "ALVIKA_FUEL"
    inst.components.fueled:InitializeFuelLevel(100)
    inst.components.fueled:SetDepletedFn(onDepleted)
    inst.components.fueled.ontakefuelfn = onTakefuel
    inst.components.fueled.accepting = true
    inst.components.fueled:StopConsuming() 

    -- initalize level
    inst.level = 0
    applyupgrades(inst)

    -- is no fuel
    inst.nofuel = false

    -- attach callback function
    inst.OnLoad = onLoad
    inst.OnSave = onSave
    inst.OnPreLoad = onPreLoad

	return inst
end
	

return Prefab( "common/inventory/magicwand", fn, assets) 
