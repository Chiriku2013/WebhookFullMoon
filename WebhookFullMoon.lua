--// CONFIG
local Webhook = "https://discord.com/api/webhooks/1366669467127382086/W-zfpbHnsXkpf8UZqzf9amT1nTYOBCOkKfwWJPa2ieIE81Jp-ZCKyq_lqyvc85ncfwa8"
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlaceId = game.PlaceId
local visited = {}
visited[game.JobId] = true -- đánh dấu server hiện tại đã vào

--// Moon phase format
local moonPhases = {
    "NewMoon", "WaxingCrescent", "FirstQuarter", "WaxingGibbous",
    "FullMoon", "WaningGibbous", "LastQuarter", "WaningCrescent"
}

--// Kiểm tra thời gian trong ngày (sáng hoặc tối)
function isNightTime()
    local hour = tonumber(os.date("%H"))
    return hour >= 18 or hour < 6 -- Kiểm tra nếu giờ là buổi tối (18:00 - 06:00)
end

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
            {["name"] = "📜 Script Join:", ["value"] = 'game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", "'..jobId..'")', ["inline"] = false},
            {["name"] = "Credit", ["value"] = "**MADE BY: CHIRIKU**", ["inline"] = false}
        },
        ["footer"] = {
            ["text"] = "MADE BY: CHIRIKU | "..os.date("Lúc %H:%M:%S")
        },
        ["thumbnail"] = {
            ["url"] = "https://upload.wikimedia.org/wikipedia/commons/3/3c/FullMoon2010.jpg"
        }
    }

    pcall(function()
        syn.request({
            Url = Webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                ["embeds"] = {embed},
                ["username"] = "Full Moon",
                ["avatar_url"] = "https://cdn.discordapp.com/emojis/1087739432068577280.webp"
            })
        })
    end)
end

--// Lấy Moon Phase
function getMoonPhase()
    local ok, result = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetMoon")
    end)
    
    -- Tránh lỗi nil và chỉ kiểm tra pha trăng nếu là buổi tối
    if ok and typeof(result) == "string" and isNightTime() then
        local index = getPhaseIndex(result)
        return result, index or 0
    end
    return "Unknown", 0
end

--// Kiểm tra xem pha trăng có phải là Full Moon không
function isFullMoon(phaseName, index)
    return phaseName == "FullMoon" and index == 5
end

--// Server Hop
function hopServer()
    local cursor = ""
    while true do
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
        local success, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if success and response and response.data then
            for _, server in ipairs(response.data) do
                -- Kiểm tra xem pha trăng của server có phải là Full Moon không
                local phaseName, index = getMoonPhase()
                if server.playing < server.maxPlayers and not visited[server.id] and server.id ~= game.JobId and isFullMoon(phaseName, index) then
                    visited[server.id] = true
                    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Chiriku2013/WebhookFullMoon/main/WebhookFullMoon.lua"))()')
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id)
                    return
                end
            end
            if not response.nextPageCursor then break else cursor = response.nextPageCursor end
        else
            break
        end
    end
end

--// MAIN
while task.wait(math.random(4, 6)) do
    local phaseName, index = getMoonPhase()
    TextLabel.Text = "Moon Phase: "..phaseName.." ("..index.."/8)"

    -- Kiểm tra nếu pha trăng là Full Moon và là buổi tối
    if isFullMoon(phaseName, index) and isNightTime() then
        sendWebhook(game.JobId, index, #Players:GetPlayers())
        task.wait(3)
    end

    hopServer()
end
