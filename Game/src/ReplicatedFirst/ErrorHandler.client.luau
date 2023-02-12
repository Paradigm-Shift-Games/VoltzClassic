local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local ErrorRemote = Events:WaitForChild("MessageRemote")
local function OnError(ErrorCode, StackTrace, Script)
	ErrorRemote:FireServer(ErrorCode, StackTrace)
end

local function OnServerMessage(Sender, Message)
	print("[SERVER]", Sender..":", Message)
end


ErrorRemote.OnClientEvent:Connect(OnServerMessage)
game:GetService("ScriptContext").Error:Connect(OnError)