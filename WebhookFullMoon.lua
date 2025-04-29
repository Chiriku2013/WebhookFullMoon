--// CONFIG
local Webhook = "https://discord.com/api/webhooks/1366669467127382086/W-zfpbHnsXkpf8UZqzf9amT1nTYOBCOkKfwWJPa2ieIE81Jp-ZCKyq_lqyvc85ncfwa8"
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

--// GUI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Label = Instance.new("TextLabel", ScreenGui)
Label.Size = UDim2.new(0.5, 0, 0, 50)
Label.Position = UDim2.new(0.25, 0, 0, 0)
Label.BackgroundTransparency = 1
Label.TextScaled = true
Label.Font = Enum.Font.GothamBold
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextStrokeTransparency = 0.5
Label.Text = "Full Moon Notify🌕: Checking..."

--// SERVER HISTORY
local visited = {}

--// SEND WEBHOOK
function sendWebhook(jobId, moonPhase, playerCount)
	local embed = {
		["title"] = "**Full Moon Notify🌕**",
		["color"] = 5814783,
		["fields"] = {
			{["name"] = "🌕 Moon Phase:", ["value"] = tostring(moonPhase), ["inline"] = true},
			{["name"] = "👥 Players:", ["value"] = tostring(playerCount).."/12", ["inline"] = true},
			{["name"] = "🔗 Job ID:", ["value"] = jobId, ["inline"] = false},
			{["name"] = "📜 Script Join:", ["value"] = 'game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", "'..jobId..'")', ["inline"] = false}
		},
		["footer"] = {["text"] = "MADE BY: CHIRIKU | "..os.date("Hôm nay lúc %H:%M")},
		["thumbnail"] = {["url"] = "https://upload.wikimedia.org/wikipedia/commons/3/3c/FullMoon2010.jpg"}
	}
	local data = {
		["embeds"] = {embed},
		["username"] = "Full Moon",
		["avatar_url"] = "https://cdn.discordapp.com/emojis/1087739432068577280.webp"
	}
	local body = HttpService:JSONEncode(data)
	pcall(function()
		syn.request({
			Url = Webhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = body
		})
	end)
end

--// CHECK MOON
function getMoonPhase()
	local success, result = pcall(function()
		return ReplicatedStorage.Remotes:FindFirstChild("CommF_"):InvokeServer("GetMoon")
	end)
	if success then
		return result
	else
		return "Error"
	end
end

--// SMART HOP
function hopServer()
	local servers = ReplicatedStorage:WaitForChild("__ServerBrowser"):GetServers()
	for _, server in pairs(servers) do
		if not visited[server] then
			visited[server] = true
			ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", server)
			break
		end
	end
end

--// MAIN LOOP
while true do
	local moon = getMoonPhase()
	if moon == "FullMoon" then
		Label.Text = "Full Moon Notify🌕: FULL MOON!!!"
		sendWebhook(game.JobId, "FullMoon", #Players:GetPlayers())
		task.wait(2)
		hopServer()
	elseif moon == nil then
		Label.Text = "Full Moon Notify🌕: Đang trời sáng"
		task.wait(math.random(3, 5))
		hopServer()
	else
		Label.Text = "Full Moon Notify🌕: Moon Phase "..tostring(moon)
		task.wait(math.random(3, 5))
		hopServer()
	end
end
