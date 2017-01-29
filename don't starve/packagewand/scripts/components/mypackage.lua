-- the class for pack function

local MyPackage = Class(function(self, inst)
	self.inst = inst
	-- user can register callback function for the component
	self.package = nil

	self.packfn = nil
	self.unPackfn = nil
	self.canBePackedfn = nil
end)

-- register functions
function MyPackage:SetPackfn(fn)
	self.packfn = fn
end

function MyPackage:SetUnPackfn(fn)
	self.unPackfn = fn
end

function MyPackage:SetCanBePackedfn(fn)
	self.canBePackedfn = fn
end
-- end register functions


-- core function
function MyPackage:GetPrefab()
	if self.package ~= nil then
		return self.package.prefab .. ""
	end
	return nil
end

function MyPackage:CanBePacked(target)
	if target == nil then
		return false
	end
	local custom_result = true
	if self.canBePacked then
		custom_result = self.canBePackedfn(target)
	end
	if custom_result then
		return target.IsValid() and (not target:IsInLimbo())
            and (not target.components.teleporter)
            and not(
                    target:HasTag("teleportato")
                    or target:HasTag("irreplaceable")
                    or target:HasTag("player")
                    or target:HasTag("nonpackable")
            )
	end
	return false
end


function MyPackage:Pack(target)
	--if not target or not self.CanBePacked(target) then 
	if false then
		return false
	else
		-- save data
		self.package = {prefab = target.prefab}
		self.package.data, self.package.refs = target:GetPersistData()
		return true
	end
end

function MyPackage:UnPack(target)
	if target then
		-- load data
		local newents = {}
		if self.package.refs then
			for _, guid in ipairs(self.package.refs) do
				newents[guid] = {entity = _G.Ents[guid]}
			end
		end

		target:SetPersistData(self.package.data, newents)
		target:LoadPostPass(newents, self.package.data)
		self.package = nil
		return true
	else
		return false
	end
end

function MyPackage:OnSave()
	if self.package then
		return {package = self.package}, self.package.refs
	end	
end

function MyPackage:OnLoad(data)
	if data and data.package then
		self.package = data.package
	end
end

return MyPackage
