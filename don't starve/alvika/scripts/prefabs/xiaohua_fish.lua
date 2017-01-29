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
		return pt + offset
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
	end
end




local function StopRespawn(inst)
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
	if data then
		inst:MorphUpBell()
	end
	if data and data.respawntimeremaining then
		inst.respawntime = data.respawntimeremaining + GetTime()
	end
end

local function OnInspecte(inst)
	local statueglommerNum = c_countprefabs("statueglommer", true) or 0
	inst.components.talker:Say("there is "..statueglommerNum.." glommer")
end

local function GetStatus(inst)
    if inst.respawntask then
		return "WAITING"
    end
end

local function GetName(inst)
	if inst then 
		return "xiaohua_fish"
	end
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle", true)
    local xiaohua = TheSim:FindFirstEntityWithTag("xiaohua")
	if xiaohua and xiaohua.components.follower.leader ~= inst then
		xiaohua.components.follower:SetLeader(inst)
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

    inst.AnimState:SetBank("xiaohua_fish")
    inst.AnimState:SetBuild("xiaohua_fish")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/xiaohua_fish.xml"

	if SaveGameIndex:IsModeShipwrecked() then
		MakeInventoryFloatable(inst, "idle", "idle")
	end

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = OnInspecte
	inst.components.inspectable:RecordViews()

	inst:AddComponent("leader")
	inst.MorphUpBell = MorphUpBell

	inst:AddComponent("talker")
    inst.components.talker.fontsize = 20
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(1, 0.8, 0.65, 1)
    inst.components.talker.offset = Vector3(200,-250,0)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.OnDeath = OnDeath

    inst.displaynamefn = GetName

    inst:ListenForEvent("entity_death", function(world, data) OnDropped(inst, data.inst) end, GetWorld())
	inst.fixtask = inst:DoTaskInTime(1, function() Fixxiaohua(inst) end)

	return inst
end

return Prefab("common/inventory/xiaohua_fish", fn, assets)
