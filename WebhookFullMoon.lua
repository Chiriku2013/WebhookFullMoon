--// CONFIG
local Webhook = "https://discord.com/api/webhooks/1366669467127382086/W-zfpbHnsXkpf8UZqzf9amT1nTYOBCOkKfwWJPa2ieIE81Jp-ZCKyq_lqyvc85ncfwa8"
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlaceId = game.PlaceId
local visited = {}

--// Moon phase format
local moonPhases = {
    "NewMoon", "WaxingCrescent", "FirstQuarter", "WaxingGibbous",
    "FullMoon", "WaningGibbous", "LastQuarter", "WaningCrescent"
}
local function getPhaseIndex(name)
    for i, phase in ipairs(moonPhases) do
        if phase == name then return i end
    end
    return nil
end

--// UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FullMoonUI"
local TextLabel = Instance.new("TextLabel", ScreenGui)
TextLabel.Size = UDim2.new(0.6, 0, 0.08, 0)
TextLabel.Position = UDim2.new(0.2, 0, 0, 10)
TextLabel.BackgroundTransparency = 1
TextLabel.TextScaled = true
TextLabel.Font = Enum.Font.GothamBlack
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextStrokeTransparency = 0.2
TextLabel.Text = "Đang kiểm tra pha mặt trăng..."

--// Gửi Webhook
function sendWebhook(jobId, phaseIndex, players)
    local embed = {
        ["title"] = "**Full Moon Notify🌕**",
        ["color"] = 5814783,
        ["fields"] = {
            {["name"] = "🌕 Moon Phase:", ["value"] = tostring(phaseIndex).."/8", ["inline"] = true},
            {["name"] = "👥 Players:", ["value"] = tostring(players).."/12", ["inline"] = true},
            {["name"] = "🔗 Job ID:", ["value"] = jobId, ["inline"] = false},
            {["name"] = "📜 Script Join:", ["value"] = 'game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", "'..jobId..'")', ["inline"] = false}
        },
        ["footer"] = {["text"] = "CHIRIKU BOT | "..os.date("Lúc %H:%M:%S")},
        ["thumbnail"] = {["url"] = "https://upload.wikimedia.org/wikipedia/commons/3/3c/FullMoon2010.jpg"}
    }

    syn.request({
        Url = Webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({["embeds"] = {embed}, ["username"] = "Full Moon", ["avatar_url"] = "https://cdn.discordapp.com/emojis/1087739432068577280.webp"})
    })
end

--// Lấy Moon Phase
function getMoonPhase()
    local ok, result = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetMoon")
    end)
    if ok and typeof(result) == "string" then
        local index = getPhaseIndex(result)
        return result, index or 0
    end
    return "Unknown", 0
end

--// Server Hop
function hopServer()
    local cursor = ""
    while true do
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
        local data = HttpService:JSONDecode(game:HttpGet(url))
        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and not visited[server.id] and server.id ~= game.JobId then
                visited[server.id] = true
                queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Chiriku2013/WebhookFullMoon/main/WebhookFullMoon.lua"))()')
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id)
                return
            end
        end
        if not data.nextPageCursor then break else cursor = data.nextPageCursor end
    end
end

--// MAIN
while true do
    local name, index = getMoonPhase()
    TextLabel.Text = "Moon Phase: "..name.." ("..index.."/8)"
    
    if name == "FullMoon" and index == 5 then
        sendWebhook(game.JobId, index, #Players:GetPlayers())
        task.wait(2)
        hopServer()
    else
        task.wait(math.random(4, 6))
        hopServer()
    end
end
