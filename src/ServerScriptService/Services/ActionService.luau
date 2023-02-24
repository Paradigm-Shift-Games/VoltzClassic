-- Author: 4812571

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActionService = {}
local ActionRemote = ReplicatedStorage.Events.Action
local bound = {}

function ActionService.Bind(action, func)
	if not bound[action] then
		bound[action] = {}
	end

	table.insert(bound[action], func)
end

function ActionService:Start()
	ActionRemote.OnServerEvent:Connect(function(player, action, state)
		if not bound[action] then return end

		for _, v in bound[action] do
			v(player, state)
		end
	end)
end

return ActionService