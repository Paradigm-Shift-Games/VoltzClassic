local EffectService = {}
local Effects = {}
local ActiveEffects = {}
local m_ID = 0
local function GetID() m_ID = m_ID + 1 return m_ID end 

for _, v in script:GetChildren() do
	Effects[v.Name] = require(v)
end

function EffectService.CreateEffect(effectName, ...)
	local ID = GetID()
	ActiveEffects[ID] = Effects[effectName].Create(...)
	return ID
end

function EffectService.EndEffect(effectID)
	if not effectID then return end
	if not ActiveEffects[effectID] then return end
	ActiveEffects[effectID].End()
	ActiveEffects[effectID] = nil
end

function EffectService.FireEffect(effectName, ...)
	Effects[effectName].Fire(...)
end

function EffectService.SignalEffect(effectID, signal, ...)
	ActiveEffects[effectID][signal](...)
end

function EffectService.Update(delta)
	for _, v in pairs(ActiveEffects) do 
		if v.Update then v.Update(delta) end
	end
end

return EffectService
