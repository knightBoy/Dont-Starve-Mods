require "prefabutil"
local brain = require "brains/xiaohuabrain"
require "stategraphs/SGxiaohua"

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets = {
	Asset("anim", "anim/xiaohua.zip"),
	Asset("ANIM", "anim/ui_chest_3x3.zip"),
}

local prefabs =
{
	"lightbulb",
    "chester_eyebone",
    "die_fx",
    "chesterlight",
    "sparklefx",
}

local slotpos_3x3 = {}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(slotpos_3x3, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
    end
end

local function OnOpen(inst)
	if not inst.components.health:IsDead() then
        inst.sg:GoToState("open")
    end
end

local function OnClose(inst)
	if not inst.components.health:IsDead() then
        inst.sg:GoToState("idle")
    end
end

local function OnStopFollowing(inst)
	inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
	inst:AddTag("companion")
end

local function ondeath(inst, deadthing)
    if inst and deadthing then
    	local xiaohua_fish = TheSim:FindFirstEntityWithTag("xiaohua_fish")
		if inst.components.follower.leader ~= xiaohua_fish then
			inst.components.follower:SetLeader(xiaohua_fish)
		end
	end
end

local function create_xiaohua()
	local inst = CreateEntity()

	inst:AddTag("companion")
	inst:AddTag("scarytoprey")
	inst:AddTag("notraptrigger")
	inst:AddTag("cattoy")
	inst:AddTag("xiaohua")
	inst:AddTag("noauradamage")

	inst.entity:AddTransform()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
	inst.entity:AddLightWatcher()

	--local minimap = inst.entity:AddMiniMapEntity()
	--minimap:SetIcon("xiaohua.png")

	inst.entity:AddAnimState()
	inst.AnimState:SetBank("xiaohua")
	inst.AnimState:SetBuild("xiaohua")

	inst.entity:AddSoundEmitter()

	MakeCharacterPhysics(inst, 10, .5)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.WORLD)
	inst.Physics:CollidesWith(COLLISION.OBSTACLES)
	inst.Physics:CollidesWith(COLLISION.CHARACTERS)

	inst:AddComponent("named")
	inst.components.named:SetName("xiaohua")

	inst.Transform:SetFourFaced()

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = 8
	inst.components.locomotor.runspeed = 10

	inst:AddComponent("talker")
    inst.components.talker.fontsize = 20
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(1, 0.8, 0.65, 1)
    inst.components.talker.offset = Vector3(200,-250,0)

    inst:AddComponent("container")
    --[[
    inst.components.container:SetNumSlots(#slotpos_3x3)
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.widgetslotpos = slotpos_3x3
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 160
    inst.components.container.canbeopened = true
	]]
	inst.components.container:WidgetSetup("chester")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose

    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("knownlocations")

    inst.entity:AddLight()
	inst.Light:SetFalloff(.5)
	inst.Light:SetIntensity(.5)
	inst.Light:SetRadius(.75)
	inst.Light:SetColour(180/255, 195/255, 50/255)
	inst.Light:Enable(true) 

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(500)
	inst.components.health.fire_damage_scale = 0
	inst.components.health.canmurder = false
	inst.components.health:SetInvincible(true)

	inst:SetStateGraph("SGxiaohua")

	local brain = require "brains/xiaohuabrain"
	inst:SetBrain(brain)

	inst:ListenForEvent( "daytime", function() inst.Light:Enable(false) end , GetWorld() )
	inst:ListenForEvent( "dusktime", function() inst.Light:Enable(true) end , GetWorld() )
	inst:ListenForEvent("entity_death", function(world, data) ondeath(inst, data.inst) end, GetWorld())

	inst:DoTaskInTime(1.5, function(inst) 
		if not TheSim:FindFirstEntityWithTag("xiaohua_fish") then
			inst:Remove()
		end
	end)

	return inst
end

return Prefab("common/xiaohua", create_xiaohua, assets, prefabs)