local assets=
{ 
    Asset("ANIM", "anim/magichat.zip"),
    Asset("ANIM", "anim/magichat_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/magichat.xml"),
    Asset("IMAGE", "images/inventoryimages/magichat.tex"),
}

local prefabs = 
{
}

local function fn()

    local function OnEquip(inst, owner) 
        owner.AnimState:OverrideSymbol("swap_hat", "magichat_swap", "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")
        print('A')
        if owner:HasTag("player") then
            print('B')
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAIR")
        end
    end

    local function OnUnequip(inst, owner) 
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAIR")
        end
    end

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("magichat")
    anim:SetBuild("magichat")
    anim:PlayAnimation("idle")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "magichat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/magichat.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    return inst
end

return  Prefab("common/inventory/magichat", fn, assets, prefabs)