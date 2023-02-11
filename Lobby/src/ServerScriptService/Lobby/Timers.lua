local RunService = game:GetService("RunService")
local Displays = {}

--for _, Display in pairs(workspace:WaitForChild("Lobby"):WaitForChild("Displays"):GetChildren()) do

--end

local TimeRemaining = 1 * 60
local TimerIsRunning = false
local BoundFunction = nil
local TimerService = {}

local function setTime(index, text)
	for _, displayInfo in pairs(Displays[index] or {}) do
		displayInfo.timeLabel.Text = text
	end
end

local function setLabel(index, label)
	for _, displayInfo in pairs(Displays[index] or {}) do
		displayInfo.teamLabel.Text = label
	end
end
	
TimerService.RegisterDisplay = function(index, model)
	if not Displays[index] then Displays[index] = {} end
	local billBoard = model:WaitForChild("Part"):WaitForChild("billBoard")
	local mainFrame = billBoard:WaitForChild("mainFrame")
	Displays[index][model] = {
		timeLabel = mainFrame:WaitForChild("timeLabel");
		teamLabel = mainFrame:WaitForChild("teamName");
	}
end
	
TimerService.SetTimers = function(amount)
	TimeRemaining = amount
	
	--Calculate Displaya
	local minutes = math.floor(TimeRemaining / 60)
	local seconds = math.ceil(TimeRemaining % 60)
	
	--Set Displays
	local text = tostring(minutes)..":"..(seconds < 10 and "0"..tostring(seconds) or tostring(seconds))
	for index, _ in pairs(Displays) do setTime(index, text) end
end

TimerService.SetLabel = function(index, label)
	Displays[index].teamLabel.Text = label
end

return TimerService