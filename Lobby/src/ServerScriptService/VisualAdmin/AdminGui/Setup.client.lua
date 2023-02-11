-- Written by Sheikh

local ContextActionService = game:GetService("ContextActionService")

local Execute = script.Parent.ExecuteCommand
local ExecuteFunction

local ColourPalette = {
	Input      = Color3.fromRGB( 48,  48,  88);
	Text       = Color3.fromRGB(255, 255, 255);
	Button     = Color3.fromRGB( 43, 191, 213);
	Background = Color3.fromRGB( 11,  11,  25);
}

local Commands = {
	["Kill"] = {
		Arguments = {
			["Player"] = "Playerbox";
			["Camera"] = "CharacterViewportFrame";
		};
	};
	["Kick"] = {
		Arguments = {
			["Player"] = "Playerbox";
			["Camera"] = "CharacterViewportFrame";
			["Reason"] = "Textarea";
		};
	};
	["Ban"] = {
		Arguments = {
			["Player"] = "Playerbox";
			["UserId"] = "Textbox";
			["Reason"] = "Textarea";
		};
	};
	["Unban"] = {
		Arguments = {
			["UserId"] = "Textbox";
		};
	};
	["Watch"] = {
		Arguments = {
			["Player"] = "Playerbox";
		};
	};
	["Bring"] = {
		Arguments = {
			["Player"] = "Playerbox";
		};
	};
	["Teleport To"] = {
		Arguments = {
			["Player"] = "Playerbox";
		};
	};
	["Free Camera"] = {
		Arguments = {};
	};
	["Launch"] = {
		Arguments = {};
	};
	["Follow Player"] = {
		Arguments = {
			["Username or UserId"] = "Textbox";
		};
	};
	["Give"] = {
		Arguments = {
			["Player"] = "Playerbox";
			["Tool"] = "Textbox";
		};
	};
}

local function FindPlayerFromPartialName(partial)
	if game.Players:FindFirstChild(partial) then return game.Players[partial] end
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:sub(1, partial:len()) == partial then return player end
	end
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():sub(1, partial:len()) == partial:lower() then return player end
	end
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():gmatch(partial)() then return player end
	end
end

local UIComponents = {
	["Textbox"] = function(title, placeholder)
		local Frame = Instance.new("Frame")
		Frame.Name = title
		Frame.BackgroundTransparency = 1
		Frame.BorderSizePixel = 0

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.Name
		ListLayout.Parent = Frame

		local Entry = Instance.new("TextBox")
		Entry.Name = "2. Entry"
		Entry.BackgroundColor3 = ColourPalette.Input
		Entry.Size = UDim2.new(1, 0, 0, 40)
		Entry.TextColor3 = ColourPalette.Text
		Entry.TextSize = 18
		Entry.Text = ""
		Entry.Font = Enum.Font.RobotoMono
		Entry.PlaceholderText = placeholder or "Type here..."

		local EntryCorner = Instance.new("UICorner")
		EntryCorner.CornerRadius = UDim.new(0, 12);
		EntryCorner.Parent = Entry;

		Entry.Parent = Frame

		local Title = Instance.new("TextLabel")
		Title.Name = "1. Title"
		Title.BackgroundTransparency = 1
		Title.BorderSizePixel = 0
		Title.Font = Enum.Font.RobotoMono
		Title.TextSize = 20
		Title.Size = UDim2.new(1, 0, 0, 40)
		Title.Text = title
		Title.TextColor3 = ColourPalette.Text
		Title.Parent = Frame

		return Frame;
	end;
	["Textarea"] = function(title, placeholder)
		local Frame = Instance.new("Frame")
		Frame.Name = title
		Frame.BackgroundTransparency = 1
		Frame.BorderSizePixel = 0

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.Name
		ListLayout.Parent = Frame

		local Entry = Instance.new("TextBox")
		Entry.Name = "2. Entry"
		Entry.BackgroundColor3 = ColourPalette.Input
		Entry.Size = UDim2.new(1, 0, 0, 100)
		Entry.TextColor3 = ColourPalette.Text
		Entry.TextSize = 18
		Entry.TextXAlignment = Enum.TextXAlignment.Left
		Entry.TextYAlignment = Enum.TextYAlignment.Top
		Entry.Text = ""
		Entry.TextTruncate = Enum.TextTruncate.AtEnd
		Entry.TextWrapped = true
		Entry.Font = Enum.Font.RobotoMono
		Entry.PlaceholderText = placeholder or "Type here..."

		local EntryCorner = Instance.new("UICorner")
		EntryCorner.CornerRadius = UDim.new(0, 12);
		EntryCorner.Parent = Entry;

		local EntryPadding = Instance.new("UIPadding")
		EntryPadding.PaddingTop    = UDim.new(0, 7.5)
		EntryPadding.PaddingLeft   = UDim.new(0, 7.5)
		EntryPadding.PaddingRight  = UDim.new(0, 7.5)
		EntryPadding.PaddingBottom = UDim.new(0, 7.5)
		EntryPadding.Parent = Entry

		Entry.Parent = Frame

		local Title = Instance.new("TextLabel")
		Title.Name = "1. Title"
		Title.BackgroundTransparency = 1
		Title.BorderSizePixel = 0
		Title.Font = Enum.Font.RobotoMono
		Title.TextSize = 20
		Title.Size = UDim2.new(1, 0, 0, 40)
		Title.Text = title
		Title.TextColor3 = ColourPalette.Text
		Title.Parent = Frame

		return Frame;
	end;
	["Playerbox"] = function(title, placeholder)
		local Frame = Instance.new("Frame")
		Frame.Name = title
		Frame.BackgroundTransparency = 1
		Frame.BorderSizePixel = 0

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.Name
		ListLayout.Parent = Frame

		local Target = Instance.new("TextLabel")
		Target.Name = "3. Target"
		Target.BackgroundTransparency = 1
		Target.BorderSizePixel = 0
		Target.Font = Enum.Font.RobotoMono
		Target.TextSize = 20
		Target.Size = UDim2.new(1, 0, 0, 40)
		Target.Text = "No Match"
		Target.TextColor3 = ColourPalette.Text
		Target.Parent = Frame

		local Entry = Instance.new("TextBox")
		Entry.Name = "2. Entry"
		Entry.BackgroundColor3 = ColourPalette.Input
		Entry.Size = UDim2.new(1, 0, 0, 40)
		Entry.TextColor3 = ColourPalette.Text
		Entry.TextSize = 18
		Entry.Text = ""
		Entry.Font = Enum.Font.RobotoMono
		Entry.PlaceholderText = placeholder or "Type here..."

		local EntryCorner = Instance.new("UICorner")
		EntryCorner.CornerRadius = UDim.new(0, 12);
		EntryCorner.Parent = Entry;

		Entry:GetPropertyChangedSignal("Text"):Connect(function()
			if Entry.Text == "" then Target.Text = "No Match" return end

			local player = FindPlayerFromPartialName(Entry.Text);
			if player then
				Target.Text = "Best Match: " .. player.Name
			else
				Target.Text = "No Match"
				return
			end
		end)

		Entry.Parent = Frame

		local Title = Instance.new("TextLabel")
		Title.Name = "1. Title"
		Title.BackgroundTransparency = 1
		Title.BorderSizePixel = 0
		Title.Font = Enum.Font.RobotoMono
		Title.TextSize = 20
		Title.Size = UDim2.new(1, 0, 0, 40)
		Title.Text = title
		Title.TextColor3 = ColourPalette.Text
		Title.Parent = Frame

		return Frame;
	end;
}
setmetatable(UIComponents, {__index = function(_, title) 
	return function(title)
		return {Parent = nil}
	end 
end})

local AdminGui = script.Parent
local CommandPanel = AdminGui.Window.Body.Commands
local CommandTitle = AdminGui.Window.Body.Main.Title
local ExecuteButton = AdminGui.Window.Body.Main.Execute
local ParameterPanel = AdminGui.Window.Body.Main.Parameters

local function SetupCommands()
	local commandPanelHeight = 0
	for command, details in pairs(Commands) do
		local button = Instance.new("TextButton")
		button.BackgroundTransparency = 1
		button.BorderSizePixel = 0
		button.Size = UDim2.new(1, 0, 0, 50)
		button.Text = command
		button.TextColor3 = ColourPalette.Text
		button.TextSize = 18
		button.Font = Enum.Font.RobotoMono

		button.MouseEnter:Connect(function()
			button.BackgroundTransparency = 0.99
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundTransparency = 1
		end)
		button.MouseButton1Click:Connect(function()
			button.BackgroundTransparency = 1
			LoadParameterLayout(command)
		end)

		button.Parent = CommandPanel
		commandPanelHeight += button.AbsoluteSize.Y
	end
	CommandPanel.CanvasSize = UDim2.new(CommandPanel.Size.X.Scale, 0, 0, commandPanelHeight + 5);
end

function LoadParameterLayout(command)
	ParameterPanel:ClearAllChildren()

	CommandTitle.Text = command
	ExecuteButton.Visible = true

	local GridLayout = Instance.new("UIGridLayout")
	GridLayout.CellPadding = UDim2.new(0.1, 0, 0.1, 0)
	GridLayout.CellSize = UDim2.new(0.4, 0, 0.5, 0)
	GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	GridLayout.Parent = ParameterPanel

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 10)
	Padding.Parent = ParameterPanel

	for name, component in pairs(Commands[command].Arguments) do
		local element = UIComponents[component](name)
		element.Parent = ParameterPanel
	end
	
	ParameterPanel.Size = UDim2.new(1, 0, 0, math.max(320, math.ceil((#ParameterPanel:GetChildren() - 2) / 2) * 240 + 40))
	ParameterPanel.Parent.CanvasSize = UDim2.new(0.8, 0, 0, ParameterPanel.AbsoluteSize.Y + 160)
	
	if ExecuteFunction then ExecuteFunction:Disconnect() end
	ExecuteFunction = ExecuteButton.MouseButton1Click:Connect(function()
		-- extract arguments
		local arguments = {}
		for argument, component in pairs(Commands[command].Arguments) do
			if component == "Textbox" or component == "Textarea" or component:match("^Select:") then
				arguments[argument] = ParameterPanel[argument]["2. Entry"].Text
			elseif component == "Playerbox" then
				arguments[argument] = game.Players[ParameterPanel[argument]["3. Target"].Text:split(": ")[2] or game.Players.LocalPlayer.Name]
			end
		end
		Execute:FireServer(command, arguments)
	end)

end

SetupCommands()

Execute.OnClientEvent:Connect(function(command, arguments)
	if not command then return end
	command = command:lower()
	
	if command == "watch" then
		AdminGui.Enabled = false
		game.Workspace.CurrentCamera.CameraSubject = arguments.Player.Character:WaitForChild("Humanoid")

		local watch
		watch = arguments.Player.CharacterAdded:Connect(function(character)
			game.Workspace.CurrentCamera.CameraSubject = arguments.Player.Character:WaitForChild("Humanoid")
		end)

		local ReturnGui = Instance.new("ScreenGui")
		ReturnGui.ResetOnSpawn = false
		ReturnGui.Name = "UnwatchGui"

		local unwatch = Instance.new("TextButton")
		unwatch.Text = "Finish Watching"
		unwatch.TextSize = 20
		unwatch.BorderSizePixel = 0
		unwatch.BackgroundColor3 = ColourPalette.Button
		unwatch.Font = Enum.Font.RobotoMono
		unwatch.TextColor3 = ColourPalette.Text
		unwatch.Size = UDim2.new(0, 300, 0, 70)
		unwatch.Position = UDim2.new(0.5, -150, 1, -170)

		unwatch.MouseButton1Click:Connect(function()
			ReturnGui:Destroy()
			AdminGui.Enabled = true
			game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
		end)

		local unwatchCorner = Instance.new("UICorner")
		unwatchCorner.CornerRadius = UDim.new(0, 12)
		unwatchCorner.Parent = unwatch

		unwatch.Parent = ReturnGui

		ReturnGui.Parent = AdminGui.Parent
	elseif command == "free camera" then
		AdminGui.Enabled = false
		local toggleFreeCamera = game.Players.LocalPlayer.PlayerGui.FreeCamera.CameraControl.Toggle
		toggleFreeCamera:Fire()
		
		local ReturnGui = Instance.new("ScreenGui")
		ReturnGui.ResetOnSpawn = false
		ReturnGui.Name = "ReturnGui"

		local back = Instance.new("TextButton")
		back.Text = "Return"
		back.TextSize = 20
		back.BorderSizePixel = 0
		back.BackgroundColor3 = ColourPalette.Button
		back.Font = Enum.Font.RobotoMono
		back.TextColor3 = ColourPalette.Text
		back.Size = UDim2.new(0, 300, 0, 70)
		back.Position = UDim2.new(0.5, -150, 1, -170)

		back.MouseButton1Click:Connect(function()
			ReturnGui:Destroy()
			AdminGui.Enabled = true
			toggleFreeCamera:Fire()
		end)

		local backCorner = Instance.new("UICorner")
		backCorner.CornerRadius = UDim.new(0, 12)
		backCorner.Parent = back

		back.Parent = ReturnGui

		ReturnGui.Parent = AdminGui.Parent
	end
end)

ContextActionService:BindAction("Toggle Admin Panel", function(name, state, input)
	if state ~= Enum.UserInputState.Begin then return end
	AdminGui.Enabled = not AdminGui.Enabled
end, false, Enum.KeyCode.L)