require "behaviours/follow"
require "behaviours/faceentity"

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 10
local TARGET_FOLLOW_DIST = 8

local function GetFaceTargetFn(inst)
	return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
	return inst.components.follower.leader == target
end

local XiaoHua_Brain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function XiaoHua_Brain:OnStart()
	local root = PriorityNode({
		Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
	}, .25)
	self.bt = BT(self.inst, root)
end

return XiaoHua_Brain