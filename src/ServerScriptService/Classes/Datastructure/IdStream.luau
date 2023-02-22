-- Author: 4812571

-- Id Stream Class
local IdStream = {}
IdStream.__index = IdStream

function IdStream:Next()
	self.top += 1
	return self.top
end

-- Service
local module = {}

function module.New()
	local object = {
		top = 0;
	}
	
	return setmetatable(object, IdStream)
end

return module