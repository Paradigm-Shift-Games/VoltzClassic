--Author: 4812571

local module = {}

DefaultTeamData = {
	[1] = {
		teamName = "Red";
		teamColor = BrickColor.new("Really red");
	};
	[2] = {
		teamName = "Green";
		teamColor = BrickColor.new("Bright green");
	};
	[3] = {
		teamName = "Yellow";
		teamColor = BrickColor.new("Cool yellow");
	};
	[4] = {
		teamName = "Orange";
		teamColor = BrickColor.new("Neon orange");
	};
	[5] = {
		teamName = "Blue";
		teamColor = BrickColor.new("Really blue");
	};
}

local function InitializePod(pod)
	local podNumber = tonumber(pod.Name)
	
	--Create Values
	pod.Team.Value = script.Team:Clone()
	pod.Team.Value.Parent = game.Teams
	pod.Team.Value.Name = DefaultTeamData[podNumber]["teamName"]
	pod.Team.Value.TeamColor = DefaultTeamData[podNumber]["teamColor"]
	pod.Team.Value:FindFirstChild("Pod").Value = pod
end

module.InitializePods = function()
	for _, v in pairs(game.Workspace.Lobby.Pods:GetChildren()) do InitializePod(v) end
end

return module
