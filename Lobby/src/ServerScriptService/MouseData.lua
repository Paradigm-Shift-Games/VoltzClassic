--Author: 4812571


local MouseRemote = game.ReplicatedStorage.Remotes.MouseData
local module = {}
local MouseData = {}

function OnRecieved(player, part, position, normal)
	if not MouseData[player] then MouseData[player] = {} end
	MouseData[player] = {part, position, normal}
end

module.GetMouse = function(player)
	if not MouseData[player] then return nil, nil, nil end
	return MouseData[player][1], MouseData[player][2], MouseData[player][3] 
end

MouseRemote.OnServerEvent:Connect(OnRecieved)
return module