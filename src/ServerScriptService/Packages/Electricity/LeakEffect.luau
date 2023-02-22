local CollectionService = game:GetService("CollectionService")
local ElectricHook = require(game.ServerScriptService.Packages.Electricity.Classes.NetworkObjects.Hook)

local module = {}


local parts = {}
local activeParts = {}
local enabledParts = {}
local hooks = {}

local function GetLeakCount(structure)
	local leakCount = 0
	if structure:FindFirstChild("Connectors") then
		for _, v in ipairs(structure.Connectors:GetChildren()) do
			if CollectionService:HasTag(v.Object.Value, "Blueprint") or not v.Object.Value then leakCount += 1 end
		end
	end
	return leakCount
end

function AddLeak(node, part)
	if activeParts[part] then return end
	script.Emitter:Clone().Parent = part.Xenon
	script.Sound  :Clone().Parent = part.Xenon
	script.Light  :Clone().Parent = part.Xenon
	
	-- Hooks
	hooks[part] = {}
	local activatedHook = ElectricHook.New("Activated")
	activatedHook:Connect(function() EnableLeaks(part.Xenon) end)
	activatedHook:BindNode(node)
	
	local deactivatedHook = ElectricHook.New("Deactivated")
	deactivatedHook:Connect(function() DisableLeaks(part.Xenon) end)
	deactivatedHook:BindNode(node)
	
	hooks[part][activatedHook] = true
	hooks[part][deactivatedHook] = true
	activeParts[part] = true
end

function RemoveLeak(node, part)
	if not activeParts[part] then return end
	for hook, _ in pairs(hooks[part]) do hook:Unbind() end
	part.Xenon.Emitter:Destroy()
	part.Xenon.Sound  :Destroy()
	part.Xenon.Light  :Destroy()
	hooks[part] = nil
	enabledParts[part] = nil
	activeParts[part] = nil
end

function EnableLeaks(xenon)
	if enabledParts[xenon.parent] then return end
	xenon.Emitter.Enabled = true
	xenon.Sound.Playing = true
	xenon.Light.Enabled = true
	xenon.BrickColor = BrickColor.new("Electric blue")
	enabledParts[xenon.Parent] = true
end

function DisableLeaks(xenon)
	if not enabledParts[xenon.parent] then return end
	xenon.Emitter.Enabled = false
	xenon.Sound.Playing = false
	xenon.Light.Enabled = false
	xenon.BrickColor = BrickColor.new("Black")
	enabledParts[xenon.parent] = false
end

function module.UpdateLeaks(node)
	local structure = node.structure
	
	if CollectionService:HasTag(structure, "NoLeaks") then return end
	
	-- Initalize Leakparts
	if not parts[structure] then
		parts[structure] = {}
		activeParts[structure] = {}
		if structure:FindFirstChild("Connectors") then
			for _, v in ipairs(structure.Connectors:GetChildren()) do parts[structure][v] = true end
		end
	end
	
	
	-- Count leaks
	local leakCount = 0
	for part, _ in pairs(parts[structure]) do
		local isLeaking = not part.Object.Value or CollectionService:HasTag(part.Object.Value, "Blueprint")
		if isLeaking then leakCount += 1 end
		
		-- Add/Remove leak effects
		if part:FindFirstChild("Xenon") then
			if isLeaking then AddLeak(node, part) else RemoveLeak(node, part) end
		end
	end
	
	node.leaks = leakCount
end

function module.Clean(node)
	for part, _ in pairs(parts[node.structure] or {}) do
		RemoveLeak(part)
	end

	parts[node.structure] = nil
end

return module