local assets =
{
    Asset("ATLAS", "images/inventoryimages/xiaohua_fish.xml"),
    Asset("ANIM", "anim/xiaohua_fish.zip"),
}

local SPAWN_DIST = 30

local trace = function() end

local function RebuildTile(inst)
    if inst.components.inventoryitem:IsHeld() then
        local owner = inst.components.inventoryitem.owner
        inst.components.inventoryitem:RemoveFromOwner(true)
        if owner.components.container then
            owner.components.container:GiveItem(inst)
        elseif owner.components.inventory then
            owner.components.inventory:GiveItem(inst)
        end
    end
end

local function MorphUpBell(inst)
    RebuildTile(inst)
    local xiaohua = TheSim:FindFirstEntityWithTag("xiaohua")
    if xiaohua then
        if xiaohua.components.follower.leader ~= GetPlayer() then
            xiaohua.components.follower:SetLeader(GetPlayer())
        end
	end
end

local function GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST
	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

local function Spawnxiaohua(inst)
    local pt = Vector3(inst.Transform:GetWorldPosition())
    trace("    near", pt)
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt then
        trace("    at", spawn_pt)
        local xiaohua = SpawnPrefab("xiaohua")
        if xiaohua then
            xiaohua.Physics:Teleport(spawn_pt:Get())
            xiaohua:FacePoint(pt.x, pt.y, pt.z)
            return xiaohua
        end
    else
--        trace("chester_eyebone - SpawnChester: Couldn't find a suitable spawn point for chester")
    end
end

local function StopRespawn(inst)
--    trace("chester_eyebone - StopRespawn")
    if inst.respawntask then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
end

local function Rebindxiaohua(inst, xiaohua)
    local xiaohua = TheSim:FindFirstEntityWithTag("xiaohua")
    if xiaohua then
        inst.AnimState:PlayAnimation("idle", true)
        inst:ListenForEvent("death", function() inst:OnDeath() end, xiaohua)
        if xiaohua.components.follower.leader ~= GetPlayer() then
            xiaohua.components.follower:SetLeader(GetPlayer())
        end
        return true
    end
end

local function onequip(inst, owner)
--	owner.AnimState:ClearOverrideSymbol("swap_object")
--	owner.AnimState:Hide("ARM_carry")
--	owner.AnimState:Show("ARM_normal")
	owner.AnimState:OverrideSymbol("swap_object", "swap_xiaohua_fish", "swap_xiaohua_fish")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function Respawnxiaohua(inst)
    StopRespawn(inst)
    local xiaohua = TheSim:FindFirstEntityWithTag("xiaohua")
    if not xiaohua then
        xiaohua = Spawnxiaohua(inst)
    end
    Rebindxiaohua(inst, xiaohua)
end

local function StartRespawn(inst, time)
    StopRespawn(inst)
    local respawntime = time or 0
    if respawntime then
        inst.respawntask = inst:DoTaskInTime(respawntime, function() Respawnxiaohua(inst) end)
        inst.respawntime = GetTime() + respawntime
        inst.AnimState:PlayAnimation("idle", true)
    end
end

local function OnDeath(inst)
    StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME)
end

local function Fixxiaohua(inst)
	inst.fixtask = nil
	if GetWorld():HasTag("volcano") then
	inst:AddTag("chester_eyebone")
	elseif GetWorld():HasTag("shipwrecked") then
	inst:AddTag("chester_eyebone")
	else
	inst:RemoveTag("chester_eyebone")
	end

	if not Rebindxiaohua(inst) then
        inst.AnimState:PlayAnimation("idle", true)
		if inst.components.inventoryitem.owner then
			local time_remaining = 0
			local time = GetTime()
			if inst.respawntime and inst.respawntime > time then
				time_remaining = inst.respawntime - time		
			end
			StartRespawn(inst, time_remaining)
		end
	end
end

local function OnPutInInventory(inst)
	if not inst.fixtask then
		inst.fixtask = inst:DoTaskInTime(1, function() Fixxiaohua(inst) end)	
	end
end

local function OnSave(inst, data)
    local time = GetTime()
    if inst.respawntime and inst.respawntime > time then
        data.respawntimeremaining = inst.respawntime - time
    end
end

local function OnLoad(inst, data)
    if data then inst:MorphUpBell() end
    if data and data.respawntimeremaining then
		inst.respawntime = data.respawntimeremaining + GetTime()
	end
end

local function onuseapple(inst)
	local player = GetPlayer()
	local pigkingnum = c_countprefabs("pigking", true) or 0
	local statueglommernum = c_countprefabs("statueglommer", true) or 0
	local tallbirdnestnum = c_countprefabs("tallbirdnest", true) or 0
	local walrus_campnum = c_countprefabs("walrus_camp", true) or 0
	local houndmoundnum = c_countprefabs("houndmound", true) or 0
	local rabbithousenum = c_countprefabs("rabbithouse", true) or 0
	local mandrakenum = c_countprefabs("mandrake", true) or 0
	local bishopnum = c_countprefabs("bishop", true) or 0
	local canenum = c_countprefabs("cane", true) or 0
	local livingtreenum = c_countprefabs("livingtree", true) or 0
	local ancient_altarnum = c_countprefabs("ancient_altar", true) or 0
	local mermhouse_fishernum = c_countprefabs("mermhouse_fisher", true) or 0
	local livingjungletreenum = c_countprefabs("livingjungletree", true) or 0
	local volcanostaffnum = c_countprefabs("volcanostaff", true) or 0
--	player.components.talker.colour = Vector3(1, 0.75, 1, 1)
--	player.components.talker.fontsize = 24
		inst.components.talker:Say(
		"\n"..TUNING.THERE.."["..pigkingnum.."]"..TUNING.THERE1..
		"\n"..TUNING.THERE.."["..statueglommernum.."]"..TUNING.THERE2..
		"\n"..TUNING.THERE.."["..tallbirdnestnum.."]"..TUNING.THERE3..
		"\n"..TUNING.THERE.."["..walrus_campnum.."]"..TUNING.THERE4..
		"\n"..TUNING.THERE.."["..houndmoundnum.."]"..TUNING.THERE5..
		"\n"..TUNING.THERE.."["..rabbithousenum.."]"..TUNING.THERE6..
		"\n"..TUNING.THERE.."["..mandrakenum.."]"..TUNING.THERE7..
		"\n"..TUNING.THERE.."["..bishopnum.."]"..TUNING.THERE8..
		"\n"..TUNING.THERE.."["..canenum.."]"..TUNING.THERE9..
		"\n"..TUNING.THERE.."["..livingtreenum.."]"..TUNING.THERE10..
		"\n"..TUNING.THERE.."["..ancient_altarnum.."]"..TUNING.THERE11..
		"\n"..TUNING.THERE.."["..mermhouse_fishernum.."]"..TUNING.THERE12..
		"\n"..TUNING.THERE.."["..livingjungletreenum.."]"..TUNING.THERE13..
		"\n"..TUNING.THERE.."["..volcanostaffnum.."]"..TUNING.THERE14)
end

local function GetStatus(inst)
    if inst.respawntask then
		return "WAITING"
    end
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle", true)
    local xiaohua = TheSim:FindFirstEntityWithTag("xiaohua")
	if xiaohua and xiaohua.components.follower.leader ~= inst then
		xiaohua.components.follower:SetLeader(inst)
		xiaohua.components.combat:SetTarget(nil)
	end
end

local function ondeaths(inst, deadthing)
    if inst and deadthing and deadthing.components.yiyucast then
    local xiaohua = TheSim:FindFirstEntityWithTag("xiaohua")
	if xiaohua and xiaohua.components.follower.leader ~= inst then
		xiaohua.components.follower:SetLeader(inst)
		xiaohua.components.combat:SetTarget(nil)
	end
	end
end

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("xiaohua_fish.tex")
	
	inst.entity:AddSoundEmitter()

    inst:AddTag("xiaohua_fish")
    inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")
    inst:AddTag("follower_leash")

    MakeInventoryPhysics(inst)
	
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize( 1, .5 )
    
    inst.AnimState:SetBank("xiaohua_fish")
    inst.AnimState:SetBuild("xiaohua_fish")
    inst.AnimState:PlayAnimation("idle", true)

	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("yiyu")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/xiaohua_fish.xml"

if SaveGameIndex:IsModeShipwrecked() then
	MakeInventoryFloatable(inst, "idle", "idle")
end
--	inst:AddComponent("equippable")
--	inst.components.equippable:SetOnEquip(onequip)
--	inst.components.equippable:SetOnUnequip(onunequip)
--	inst.components.equippable.equipstack = true

--	inst:AddComponent("useableitem")
--	inst.components.useableitem:SetOnUseFn(onuseapple)
--	inst.components.useableitem:SetCanInteractFn(function() if inst.components.equippable:IsEquipped() then return true end end)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = onuseapple
	inst.components.inspectable:RecordViews()

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 24
	inst.components.talker.offset = Vector3(0,-800,0)
    inst.components.talker.colour = Vector3(0.75, 0.85, 1, 1)

    inst:AddComponent("leader")
--	inst.MorphNormalBell = MorphNormalBell
	inst.MorphUpBell = MorphUpBell

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.OnDeath = OnDeath

    inst:ListenForEvent("entity_death", function(world, data) OnDropped(inst, data.inst) end, GetWorld())
	inst.fixtask = inst:DoTaskInTime(1, function() Fixxiaohua(inst) end)

    return inst
end

return Prefab( "common/inventory/xiaohua_fish", fn, assets)
