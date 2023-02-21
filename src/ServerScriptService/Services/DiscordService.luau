-- Author: Styx

local HttpService = game:GetService("HttpService")

local webhookLinks = {
	["errorHook"] = "https://discordapp.com/api/webhooks/660694264711217152/r60iTViDdLe4mWdWIGFmdmSoU9Fe2tWeTkohUSX-ggnZ1M8wen3Xm7GSVjUyMRhbYtj5";
	["winHook"] = "https://discordapp.com/api/webhooks/672597377139343360/8tFZe031l2lOqr2JNMoFgkCX4XP1VLYgaYiVOpTY-iQ4yOaD4heLCccz9u0_Fb7wFOln";
}

--[[ Embed ]]--
local Embed = {}
Embed.__index = Embed
function Embed.New()
	return setmetatable({}, Embed)
end

function Embed:SetTitle(newTitle)
	self.title = newTitle
end

function Embed:SetDescription(newDescription)
	self.description = newDescription;
end

function Embed:SetUrl(urlString)
	self.url = urlString
end

function Embed:SetColor(colorCode)
	self.color = colorCode
end

function Embed:_getData()
	return self
end

--[[ Content ]]--
local Content = {}
Content.__index = Content
function Content.New(name)
	local self = {}
	self.username = name
	self.embeds = {}
	return setmetatable(self, Content)
end

function Content:AddEmbed(embed)
	table.insert(self.embeds, embed:_getData())
end

function Content:SetContent(contentString)
	self.content = contentString
end

function Content:SetAvatar(avatarUrl)
	self.avatar_url = avatarUrl
end

function Content:EnableTts()
	self.tts = true
end

function Content:_getData()
	return self
end

--[[ DiscordService ]]--
local DiscordService = {}
DiscordService.Embed = Embed
DiscordService.Content = Content
function DiscordService.SendContent(hookName, content)
	local hook = webhookLinks[hookName]
	if hook == nil then error(hookName.." is not a valid hookName!") end
	
	local successful, err = pcall(HttpService.PostAsync, HttpService, hook, HttpService:JSONEncode(content:_getData()))
	if not successful then warn(err) end
end

return DiscordService