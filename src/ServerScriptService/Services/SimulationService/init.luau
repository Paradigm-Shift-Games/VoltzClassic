-- Author: 4812571

local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

local MicroBinder = {}
MicroBinder.__index = MicroBinder

function MicroBinder.new(tagName, class)
	local self = setmetatable({}, MicroBinder)
	self._bound = {}
	self.TagName = tagName
	self.Class = class
	return self
end

function MicroBinder:_bind(instance)
	self._bound[instance] = self.Class.new(instance)
end

function MicroBinder:_unbind(instance)
	if self._bound[instance] then
		self._bound[instance]:Destroy()
	end

	self._bound[instance] = nil
end

function MicroBinder:Start()
	for _, instance in CollectionService:GetTagged(self.TagName) do
		self:_bind(instance)
	end

	CollectionService:GetInstanceAddedSignal(self.TagName):Connect(function(instance)
		self:_bind(instance)
	end)

	CollectionService:GetInstanceRemovedSignal(self.TagName):Connect(function(instance)
		self:_unbind(instance)
	end)
end

function MicroBinder:GetAll()
	return self._bound
end

local SimulationService = {}

local simulationClasses = {}
local binders = {}

function SimulationService.Init()
	for _, v in script:GetChildren() do
		simulationClasses[v.Name] = require(v)
	end

	for className, class in simulationClasses do
		binders[className] = MicroBinder.new(className, class)
	end

	for _, binder in binders do
		binder:Start()
	end
end

SimulationService.Init()

function SimulationService.Run(deltaTime)
	for _, binder in binders do
		for _, object in binder:GetAll() do
			if object.Update then
				object:Update(deltaTime)
			end
		end
	end

	for _, class in simulationClasses do
		if class.StaticUpdate then
			class.StaticUpdate(deltaTime)
		end
	end
end

return SimulationService