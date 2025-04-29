-- CONFIG
local Webhook = "https://discord.com/api/webhooks/1366669467127382086/W-zfpbHnsXkpf8UZqzf9amT1nTYOBCOkKfwWJPa2ieIE81Jp-ZCKyq_lqyvc85ncfwa8"
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TPService = game:GetService("TeleportService")

-- UI TextLabel chính giữa màn hình
local screenGui = Instance.new("ScreenGui", game.CoreGui)
local textLabel = Instance.new("TextLabel", screenGui)
textLabel.AnchorPoint = Vector2.new(0.5, 0)
textLabel.Position = UDim2.new(0.5, 0, 0.05, 0)
textLabel.Size = UDim2.new(0, 350, 0, 40)
textLabel.TextScaled = true
textLabel.BackgroundTransparency = 1
textLabel.Font = Enum.Font.GothamBold
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextStrokeTransparency = 0.5
textLabel.Text = "Full Moon Notify🌕: Đang kiểm tra..."

-- Hàm gửi webhook
function sendFullMoonWebhook(jobId, moonPhase, players, remainingTime)
    local embed = {
        ["title"] = "**Full Moon Notify🌕**",
        ["color"] = 5814783,
        ["fields"] = {
            {["name"] = "⌛ Status:", ["value"] = remainingTime.." Minute(s)", ["inline"] = true},
            {["name"] = "🌕 Moon Phase:", ["value"] = tostring(moonPhase).."/5", ["inline"] = true},
            {["name"] = "👥 Players In Server:", ["value"] = tostring(players).."/12", ["inline"] = true},
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

    pcall(function()
        (syn and syn.request or http_request or request)({
            Url = Webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- Hàm kiểm tra Moon
function isFullMoon()
    local ok, result = pcall(function()
        return ReplicatedStorage.Remotes:FindFirstChild("CommF_"):InvokeServer("GetMoon")
    end)
    return ok and result or "nil"
end

-- Hop server ngẫu nhiên không trùng JobId hiện tại
function smartHop()
    local servers = ReplicatedStorage.__ServerBrowser:GetServers()
    local currentJob = game.JobId
    local tries = 0
    for _, s in pairs(servers) do
        if s ~= currentJob then
            ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", s)
            return
        end
        tries += 1
        if tries > 10 then break end
    end
end

-- Vòng lặp chính
while true do
    local moon = isFullMoon()
    textLabel.Text = "Full Moon Notify🌕: Moon Phase " .. tostring(moon)

    if moon == "FullMoon" then
        sendFullMoonWebhook(game.JobId, 5, #Players:GetPlayers(), "5")
        task.wait(3)
        smartHop()
    else
        task.wait(math.random(3, 5))
        smartHop()
    end
end
