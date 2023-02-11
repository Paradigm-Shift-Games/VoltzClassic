local RunService = game:GetService("RunService")
local TeamRemote = game.ReplicatedStorage.Remotes.RequestJoin

--Player
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
local NeutralTeam = game.Teams["No Team"]

--Floors
local floors = {}
for _, v in pairs(workspace.Lobby.Pods:GetChildren()) do table.insert(floors, v:WaitForChild("Floor")) end

--Telemetry
local reportInterval = 0.5
local lastReportTime = 0
local lastMessage
local connection

--RaycastParams
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = floors
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

function Update()
	local raycastResult = workspace:Raycast(Character.HumanoidRootPart.Position, Vector3.new(0, -16, 0), raycastParams)
	
	local teamDetected
	if raycastResult then
		local pod = raycastResult.Instance.Parent
		teamDetected = pod.Team.Value	
	else
		teamDetected = NeutralTeam
	end
	
	if LocalPlayer.Team ~= teamDetected and (lastMessage ~= teamDetected or lastReportTime + reportInterval < tick()) then
		lastReportTime = tick()
		lastMessage = teamDetected
		TeamRemote:FireServer(teamDetected)
		print("Requesting to Join", teamDetected, "Team")
	end
end


connection = RunService.Heartbeat:Connect(Update)

Character:WaitForChild("Humanoid").Died:Connect(function() connection:Disconnect() TeamRemote:FireServer(NeutralTeam) end)