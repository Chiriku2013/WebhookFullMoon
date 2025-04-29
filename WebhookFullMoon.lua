--// CONFIG
local Webhook = "https://discord.com/api/webhooks/1366669467127382086/W-zfpbHnsXkpf8UZqzf9amT1nTYOBCOkKfwWJPa2ieIE81Jp-ZCKyq_lqyvc85ncfwa8"
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0.5, 0, 0, 40)
label.Position = UDim2.new(0.25, 0, 0, 0)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.4
label.Text = "Full Moon Notify🌕: Checking..."

--// Server cache
local visited = {}

--// Send Webhook
function sendWebhook(jobId, phase, playerCount)
	local data = {
		["embeds"] = {{
			["title"] = "**Full Moon Notify🌕**",
			["color"] = 5814783,
			["fields"] = {
				{["name"] = "🌕 Moon Phase", ["value"] = tostring(phase), ["inline"] = true},
				{["name"] = "👥 Players", ["value"] = tostring(playerCount).."/12", ["inline"] = true},
				{["name"] = "🔗 Job ID", ["value"] = jobId, ["inline"] = false},
				{["name"] = "📜 Script Join", ["value"] = 'game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", "'..jobId..'")'}
			},
			["footer"] = {["text"] = "MADE BY: CHIRIKU | "..os.date("Hôm nay lúc %H:%M")},
			["thumbnail"] = {["url"] = "https://upload.wikimedia.org/wikipedia/commons/3/3c/FullMoon2010.jpg"}
		}},
		["username"] = "Full Moon",
		["avatar_url"] = "https://cdn.discordapp.com/emojis/1087739432068577280.webp"
	}
	pcall(function()
		syn.request({
			Url = Webhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode(data)
		})
	end)
end

--// Get Moon
function getMoonPhase()
	local ok, result = pcall(function()
		return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetMoon")
	end)
	if ok then
		return result
	else
		return nil
	end
end

--// Smart Hop
function smartHop()
	local servers = ReplicatedStorage.__ServerBrowser:GetServers()
	for _, srv in pairs(servers) do
		if not visited[srv] then
			visited[srv] = true
			ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", srv)
			break
		end
	end
end

--// Main
while true do
	local moon = getMoonPhase()

	if moon == "FullMoon" then
		label.Text = "Full Moon Notify🌕: FULL MOON!!!"
		sendWebhook(game.JobId, moon, #Players:GetPlayers())
		task.wait(2)
		smartHop()
	elseif type(moon) == "string" then
		label.Text = "Full Moon Notify🌕: "..moon
		task.wait(math.random(3, 5))
		smartHop()
	elseif type(moon) == "number" then
		label.Text = "Full Moon Notify🌕: Phase "..moon.."/5"
		task.wait(math.random(3, 5))
		smartHop()
	else
		label.Text = "Full Moon Notify🌕: Trời sáng hoặc không xác định"
		task.wait(math.random(3, 5))
		smartHop()
	end
end
