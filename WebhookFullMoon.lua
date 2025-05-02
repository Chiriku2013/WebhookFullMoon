local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local webhook = "https://fe874317-1a34-47f4-9c99-29295a76d5c8-00-19hdq2tcg3p9t.sisko.replit.dev/fullmoon" -- Thay bằng link của bạn

function getMoonPhase()
	local success, phase = pcall(function()
		return require(game.ReplicatedStorage.Util.Moon).phase
	end)
	return success and phase or 0
end

function sendWebhook(phase)
	local data = {
		moon_phase = phase,
		players = #Players:GetPlayers(),
		jobid = game.JobId,
		status = "FULL MOON!"
	}

	HttpService:PostAsync(webhook, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
end

function smartHop()
	local servers = {}
	local req = syn.request({
		Url = "https://games.roblox.com/v1/games/2753915549/servers/Public?sortOrder=Desc&limit=100",
		Method = "GET"
	})
	local body = HttpService:JSONDecode(req.Body)
	for _, server in pairs(body.data) do
		if server.playing < server.maxPlayers then
			table.insert(servers, server.id)
		end
	end
	if #servers > 0 then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
	end
end

task.wait(5) -- đợi game load

local phase = getMoonPhase()
if phase == 5 then
	sendWebhook(phase)
else
	smartHop()
end
