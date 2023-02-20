local Teams = game:GetService("Teams")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

local ChatService = require(ServerScriptService.Services.ChatService)
local DamageService = require(ServerScriptService.Services.DamageService)

--
local function Command(player, parameters)
	parameters = string.split(table.concat(parameters, " "), " ")
	if #parameters == 1 then
		for _, v in pairs(CollectionService:GetTagged(parameters[1])) do
			DamageService.Destroy(v)
		end		
	elseif #parameters == 2 then
		local team = Teams:FindFirstChild(parameters[2])
		if not team then 
			--ChatService.BroadcastToPlayer(player, "System", "Invalid team "..parameters[2]) 
			return
		end
		for _, v in pairs(CollectionService:GetTagged(parameters[1])) do
			if not v:FindFirstChild("Team") then continue end
			if v.Team.Value ~= team then continue end
			DamageService.Destroy(v)
		end		
	elseif #parameters > 2 then
		--ChatService.BroadcastToPlayer(player, "System", "Too many parameters"..parameters[2])
	end
end

return Command