-- Author: 4812571

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SnapDataService = {}
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
        for _, v in obj:GetChildren() do
            tab[v.Name] = Recurse(v, root)
        end
        return tab     
    else
        return Offset(obj, root)
    end
end

function SnapDataService.GetSnaps()
	return Data
end

function SnapDataService:Start()
	for _, v in pairs(toRecurse) do
		for _, g in v:GetChildren() do
			if g:FindFirstChild("AdvancedAttachment") then
				Data[g.Name] = Recurse(g.AdvancedAttachment, g)
				g.AdvancedAttachment:Destroy()
			end
		end
	end

	event.OnServerInvoke = SnapDataService.GetSnaps
end

return SnapDataService
