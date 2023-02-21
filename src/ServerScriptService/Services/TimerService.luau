local TimerService = {}

local timersIndex = {}
local timers = {}

local enabled = true

function TimerService.Start(str)
	if not enabled then return end
	if not timersIndex[str] then
		timersIndex[str] = #timers + 1
		timers[#timers + 1] = {time = os.clock(), name = str}	
	else
		timers[timersIndex[str]] = {time = os.clock(), name = str}
	end
end

function TimerService.Record(str)
	if not enabled then return end
	local index = timersIndex[str]
	timers[index].time = os.clock() - timers[index].time
end

TimerService.Post = function()
	for _, v in ipairs(timers) do
		local postStr = ""
		local indentCount = #string.split(v.name) - 1
		for i = 1, indentCount do postStr = postStr.."\t" end
		print(postStr..v.name, v.time * 1000)
	end
end

TimerService.Enable = function()
	enabled = true
end

TimerService.Disable = function()
	enabled = false
end

TimerService.Toggle = function()
	if enabled then TimerService.Disable() else TimerService.Enable() end
end

return TimerService
