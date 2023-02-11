local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChatEvent = ReplicatedStorage:WaitForChild("Remotes").ChatMessage

ChatEvent.OnClientEvent:Connect(function(text, colour, font)
	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = text;
			Color = colour;
			Font = font;
		})
	end)
end)