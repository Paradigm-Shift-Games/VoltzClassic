-- Author: Styx


local loadingScreenData = workspace:WaitForChild("loadingScreenData")
local messageValue = loadingScreenData:WaitForChild("Message")
local percentValue = loadingScreenData:WaitForChild("Percent")
local LoadingScreenManager = {}
LoadingScreenManager.SetLoadingData = function(Message, Percent)
	messageValue.Value = Message
	percentValue.Value = math.clamp(Percent*100, 0, 100)/100
end
return LoadingScreenManager