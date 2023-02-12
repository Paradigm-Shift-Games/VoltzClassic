-- Author: 4812571

local ReplicatedStorage = game:GetService("ReplicatedStorage")



local module = {}
Data = {}
local event = ReplicatedStorage.Events.SnapData
local generated = false
local toRecurse = {
	workspace.Objects;
}

function Offset(part, root)
	local primary = root.PrimaryPart
	if not primary then warn(root:GetFullName().." Has no PrimaryPart!") return end
	return part.CFrame:ToObjectSpace(primary.CFrame)
end

function Recurse(obj, root)
    if obj:IsA("Folder") then
        local tab = {}
        for _, v in pairs(obj:GetChildren()) do
            tab[v.Name] = Recurse(v, root)
        end
        return tab     
    else
        return Offset(obj, root)
    end
end


module.Generate = function()
	for _, v in pairs(toRecurse) do
		for _, g in pairs(v:GetChildren()) do
			if g:FindFirstChild("AdvancedAttachment") then
				Data[g.Name] = Recurse(g.AdvancedAttachment, g)
				g.AdvancedAttachment:Destroy()
			end
		end
	end
end

module.GetSnaps = function()
	return Data
end

event.OnServerInvoke = module.GetSnaps

return module
