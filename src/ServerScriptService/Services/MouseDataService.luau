-- Author: 4812571

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MouseRemote = ReplicatedStorage.Events.MouseData
local data = {}

local MouseDataService = {}

function OnRecieved(player, part, position, normal)
	if not data[player] then data[player] = {} end
	data[player] = {part, position, normal}
end

function MouseDataService.GetMouse(player: Player)
	if not data[player] then
		return nil, nil, nil
	end

	return data[player][1], data[player][2], data[player][3]
end

MouseRemote.OnServerEvent:Connect(OnRecieved)

return MouseDataService