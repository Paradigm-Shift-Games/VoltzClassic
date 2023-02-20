-- Author: Styx

local ScriptContext = game:GetService("ScriptContext")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DiscordService = require(game:WaitForChild("ServerScriptService"):WaitForChild("Services"):WaitForChild("DiscordService"))

local Events = ReplicatedStorage:WaitForChild("Events")
local MessageRemote = Events:WaitForChild("MessageRemote")

function GetStackTraceName(stackTrace)
	local TabToReturn = {}
	local ToReturn = string.gmatch(stackTrace, "%b.,")
	while true do
		local It = ToReturn()
		if It ~= nil then
			It = string.sub(It, 2, string.len(It)-1)
			table.insert(TabToReturn, It)
		else
			break
		end
	end
	return TabToReturn
end

local module = {}
--[[
--module--

bool AutoReport
--Autoreporter setting

void function Report(string message)
reports string, make it use traceback to automatically know the caller :)
can be used by client, if used by client, fire string via remote instead.

void function MessageClient(Player player, string sender,string message)
prints message on client: [Server/sender: message]
]]
local connection = nil
module.AutoReport = true

module.ReportedErrors = {}

function module.ReportError(ErrorCode, StackTrace, ScriptObject, IsClient)
	if ScriptObject == script then return end
	
	if module.ReportedErrors[ErrorCode] then
		module.ReportedErrors[ErrorCode] += 1 
		return
	end
	module.ReportedErrors[ErrorCode] = 1
	
	local NewMessage = DiscordService.Content.New()
	local name = StackTrace:split(",")[1]
	if not name then return end
	local NewEmbed = DiscordService.Embed.New()
	NewEmbed:SetTitle((IsClient and "Client" or "Server") .. " / " .. name)
	NewEmbed:SetDescription(ErrorCode .. "\n\n**Trace:**\n" .. StackTrace)
	NewMessage:AddEmbed(NewEmbed)
	DiscordService.SendContent("errorHook", NewMessage)
end

function module.MessageClient(Player, sender, message)
	MessageRemote:FireClient(Player, sender, message)
end

local function ClientReport(Player, ErrorCode, StackTrace)
	ErrorCode = Player.UserId.."/"..Player.Name.."\n"..ErrorCode
	module.ReportError(ErrorCode, StackTrace, nil, true)
end
MessageRemote.OnServerEvent:Connect(ClientReport)

local meta = {}
function meta.__newindex(tab, index, value)
	if index == "AutoReport" then
		if value then
			connection = ScriptContext.Error:Connect(module.ReportError)
		elseif connection ~= nil then
			connection:Disconnect()
		end
	end
	rawset(tab, index, value)
end

if module.AutoReport then
	connection = ScriptContext.Error:Connect(module.ReportError)
end

return setmetatable(module, meta)