--Author: 4812571

local module = {}
local ActionRemote = game.ReplicatedStorage.Remotes.Action
local boundActions
local bound = {}

module.Bind = function(action, func)
	if not bound[action] then bound[action] = {} end
	table.insert(bound[action], func)
end

function OnRecieve(player, action, state)
	if not bound[action] then return end
	for _, v in pairs(bound[action]) do
		v(player, state)
	end
end

ActionRemote.OnServerEvent:Connect(OnRecieve)

return module