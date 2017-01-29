
local assets=
{
	Asset("ANIM", "anim/pitchfork.zip"),
	Asset("ANIM", "anim/swap_pitchfork.zip"),
	Asset("IMAGE", "images/inventoryimages/fertilize.tex"),
	Asset("ATLAS", "images/inventoryimages/fertilize.xml"),
}

local function onfinished(inst)
	inst:Remove()
end

-- find a crop to fertilize at the position of pt
local function findCrops(inst, pt)
	for k,val in pairs(TheSim:FindEntities(pt.x, pt.y, pt.z, 3)) do
          if val.components.pickable or val.components.harvestable or val.components.hackable then
            return val
          end
    end
    return nil
end

local function GetFertilizerPrefab(fertilizer,owner)
  local obj    = fertilizer[1]
  local prefab = obj.prefab
  obj.components.stackable:SetStackSize(obj.components.stackable:StackSize()-1)

  for k,v in pairs(fertilizer) do
    if v.components.stackable:StackSize() < 1 then
      owner.components.inventory:RemoveItem(v, true)
    end
  end

  return SpawnPrefab(prefab)
end

local function FilterFertilizers(item, fertilizers)
  for k,v in pairs(fertilizers) do
    if item.prefab == v and item.components.stackable:StackSize() > 0 then
      return true
    end
  end
  return false
end

local function GetFertilizer(fertilizers, owner)
  local inv = owner.components.inventory
  local items = inv:FindItems(function (item) return FilterFertilizers(item, fertilizers) end)
  return items
end

local function CanBeFertilized(plant, fertilizer)
  if plant.components then
    if plant.components.pickable and plant.components.pickable:CanBeFertilized() == true then
      return true
    elseif plant.components.hackable and plant.components.hackable:CanBeFertilized() == true then
      return true
    else
      return false
    end
  end
end

local function FertilizePlant(inst, fertilizers, plant, owner)
  local fertilizer = GetFertilizer(fertilizers, owner)
    if #fertilizer ~= 0 and CanBeFertilized(plant, fertilizer) == true then
      if plant.components.pickable then
        plant.components.pickable:Fertilize(GetFertilizerPrefab(fertilizer, owner))
      elseif plant.components.hackable then
        plant.components.hackable:Fertilize(GetFertilizerPrefab(fertilizer, owner))
      end
      inst.components.finiteuses:Use(.25)
    end
end

-- Fertilize plants
local function fertilize(inst, owner)
	local fertilizer = {'guano', 'poop', 'spoiled_food'}
	local position = owner:GetPosition()
  local plant = nil
	plant = findCrops(inst, position)
	if plant then
		  FertilizePlant(inst, fertilizer, plant,owner)
	end
end

local function onequip(inst, owner) 
    inst.task = inst:DoPeriodicTask(.5, function() fertilize(inst, owner) end)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")   

    owner.AnimState:OverrideSymbol("swap_object", "swap_pitchfork", "swap_pitchfork")  
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    if inst.task then 
      inst.task:Cancel() 
      inst.task = nil 
    end
end
	
	
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeInventoryPhysics(inst)
	if IsDLCEnabled(CAPY_DLC) then
	   MakeInventoryFloatable(inst, "idle_water", "idle")
  end
	
	anim:SetBank("pitchfork")
	anim:SetBuild("pitchfork")
	anim:PlayAnimation("idle")
	inst.AnimState:SetMultColour(0/255,255/255,255/255,1)
	
	inst:AddTag("sharp")
	
  inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.PITCHFORK_USES)
	inst.components.finiteuses:SetUses(TUNING.PITCHFORK_USES)
	inst.components.finiteuses:SetOnFinished( onfinished) 
	
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.PITCHFORK_DAMAGE)
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/fertilize.xml"
  inst.components.inventoryitem.imagename = "fertilize"

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	
	return inst
end

return Prefab( "common/inventory/smartfertilizer", fn, assets)
	   