local GroupId = 5444195
local AdminRank = 253
local whitelisted = {}
local Commands = {}
setmetatable(Commands, {__index = function(t, command) return function() print("Unknown command: \"" .. command .. "\"!") end end})

local function HandleAdminCommand(commandRemote, player, command, arguments)
	if player:GetRankInGroup(GroupId) < AdminRank then return end
	arguments.AdminRemote = commandRemote
	
	local message = Commands[command:lower()](player, arguments)
	if message then
		warn("[" .. command .. "] CommandError: " .. message)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	if player:GetRankInGroup(GroupId) < AdminRank and not whitelisted[tostring(player.UserId)] then return end
	
	local AdminGui = script.AdminGui:Clone()
	AdminGui.ExecuteCommand.OnServerEvent:Connect(function(...) HandleAdminCommand(AdminGui.ExecuteCommand, ...) end)
	AdminGui.Parent = player.PlayerGui
end)

for _, v in ipairs(script.Commands:GetChildren()) do Commands[v.Name:lower()] = require(v) end