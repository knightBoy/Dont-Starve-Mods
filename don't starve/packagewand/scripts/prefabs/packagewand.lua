local assets=
{
    Asset("ANIM",  "anim/packagewand.zip"),
    Asset("ANIM",  "anim/swap_packagewand.zip"),
    Asset("IMAGE", "images/inventoryimages/packagething.tex"),
    Asset("ATLAS", "images/inventoryimages/packagething.xml"),
}

local prefabs =
{
}
    
local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_packagewand", "swap_packagewand")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
    -- can walk faster
    local walkspeed = owner.components.locomotor.walkspeed * 1.2;
    owner.components.locomotor.walkspeed = walkspeed
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    local walkspeed = owner.components.locomotor.walkspeed / 1.2;
    owner.components.locomotor.walkspeed = walkspeed
end

-- to pack things	
local function pack(staff, target, pos)
	if target and target:IsValid() then
		--local targetpos = target:GetPosition()
    	local packagething = SpawnPrefab("packagething")
        if packagething.components.mypackage then
            packagething.components.mypackage:Pack(target)
        end
    	if packagething then
			local targetPos = target:GetPosition()
			packagething.Transform:SetPosition(targetPos:Get())
			target:Remove()
            staff.components.finiteuses:Use(10)
		end
	end    
end

-- juge a structure can be packed or not
local function canBePacked(staff, caster, target)
    if target then
    	if target:HasTag("character") or target:HasTag("companion") or target:HasTag("mypackagething") 
    		or target.components.teleporter then
    		return false
    	else
    		return true
    	end
    else
    	return false
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "packagewand.tex" )
    
    -- set idle animation
    anim:SetBank("packagewand")
    anim:SetBuild("packagewand")
    anim:PlayAnimation("idle")

    inst:AddTag("sharp")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(30)
	
    -- add finiteuses components
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)
    inst.components.finiteuses:SetOnFinished(inst.Remove) 

    -- can inspect
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/packagewand.xml"

    --inst:AddComponent("mypackage")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
    -- add spellcaster components
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(pack)
    inst.components.spellcaster:SetSpellTestFn(canBePacked)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = true
    
    return inst
end

return Prefab( "common/inventory/packagewand", fn, assets, prefabs) 