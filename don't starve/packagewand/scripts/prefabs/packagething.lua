-- the thing which has be packed

require "prefabutil"

local assets =
{
	Asset("ANIM",  "anim/packagething.zip"),
    Asset("ATLAS", "images/inventoryimages/packagething.xml" ),
    Asset("IMAGE", "images/inventoryimages/packagething.tex" ),
}	

local function getName(inst)
	if inst.components.mypackage then
		return inst.components.mypackage:GetPrefab()
	else
		return "no name"
	end
end

local function ondeploy(inst, pt, deployer)
	local packedthing = nil
	if inst.components.mypackage then
		packedthing = SpawnPrefab(inst.components.mypackage:GetPrefab())
		inst.components.mypackage:UnPack(packedthing)
	else
		packedthing = SpawnPrefab("poop")
	end
	packedthing.Transform:SetPosition(pt:Get())
	inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)
	-- its size is 1
	MakeObstaclePhysics(inst, 1)

	local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "packagething.tex" )

	inst.AnimState:SetBank("packagething")
	inst.AnimState:SetBuild("packagething")
	inst.AnimState:PlayAnimation("idle")
	inst.Transform:SetScale(3,3,3)

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem.atlasname = "images/inventoryimages/packagething.xml"

	-- make it can deploy
	inst:AddComponent("deployable")
	local deployable = inst.components.deployable
	deployable.ondeploy = ondeploy

	-- to add custom component
	inst:AddComponent("mypackage")

	inst:AddTag("mypackagething")
	
	if _G.IsDLCEnabled(_G.REIGN_OF_GIANTS) then
		inst:AddComponent("waterproofer")
		inst.components.waterproofer.effectiveness = 0
	end

	inst.displaynamefn = getName

	return inst
end

return 	Prefab("common/inventory/packagething", fn, assets),
-- add preview animation
MakePlacer("common/packagething_placer", "packagething", "packagething", "idle")