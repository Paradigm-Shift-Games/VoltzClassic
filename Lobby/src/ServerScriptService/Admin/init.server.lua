warn("Admin Initializing")

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local Commands = {}
local commandString = "!"
local GroupID = 5444195
local AdminRank = 253

local function findPlayerFromPartialName(partial)
	if game.Players:FindFirstChild(partial) then return game.Players[partial] end
	
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:match("^" .. partial) then return player end
	end

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():match("^" .. partial:lower()) then return player end
	end

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():gmatch(partial:lower()) then return player end
	end
end

local function onPlayerChatted(player, message, recipient)
	if recipient then return end -- Ignore whispers
	if player:GetRankInGroup(GroupID) < AdminRank then return end --Ignore non admins
	if message:sub(1, commandString:len()):lower() ~= commandString:lower() then return end -- Ignore non commands
	
	local command = message:sub(commandString:len() + 1, message:len()) --Grab everything after command string
	print("User:", player, "Attempted to fire command", command)
	local keyword = command:split(" ")[1]:lower()
	
	if not Commands[keyword] then warn("Invalid Admin Command:", keyword) return end
	
	local commandParams = command:sub(keyword:len() + 2, command:len()):split(" ")
	
	Commands[keyword](player, commandParams)
end

local function onPlayerAdded(player)
	player.Chatted:Connect(function (...) onPlayerChatted(player, ...) end)	
end

for _, player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
for _, v in ipairs(script.Commands:GetChildren()) do Commands[v.Name:lower()] = require(v) end

Players.PlayerAdded:Connect(onPlayerAdded)