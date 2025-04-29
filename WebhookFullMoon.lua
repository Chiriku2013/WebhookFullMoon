--// CONFIG
getgenv().Webhook = "https://discord.com/api/webhooks/1366669467127382086/W-zfpbHnsXkpf8UZqzf9amT1nTYOBCOkKfwWJPa2ieIE81Jp-ZCKyq_lqyvc85ncfwa8"

--// SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// SERVER TRACKING
local checkedServers = {}
checkedServers[game.JobId] = true

--// TEXTLABEL STATUS
local screenGui = Instance.new("ScreenGui", game.CoreGui)
local textLabel = Instance.new("TextLabel", screenGui)
textLabel.Size = UDim2.new(0.4, 0, 0.07, 0)
textLabel.Position = UDim2.new(0.3, 0, 0.01, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.Font = Enum.Font.GothamBold
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextStrokeTransparency = 0.5
textLabel.Text = "Full Moon Notify🌕: Checking..."

--// FUNCTION SEND WEBHOOK
function sendFullMoonWebhook(jobId, moonPhase, players, remainingTime)
    local playerCount = tostring(players).."/12"
    local embed = {
        ["title"] = "**Full Moon Notify🌕**",
        ["color"] = 5814783,
        ["fields"] = {
            {
                ["name"] = "⌛ Status:",
                ["value"] = remainingTime.." Minute(s)",
                ["inline"] = true
            },
            {
                ["name"] = "🌕 Moon Phase:",
                ["value"] = tostring(moonPhase).."/5",
                ["inline"] = true
            },
            {
                ["name"] = "👥 Players In Server:",
                ["value"] = playerCount,
                ["inline"] = true
            },
            {
                ["name"] = "🔗 Job ID:",
                ["value"] = jobId,
                ["inline"] = false
            },
            {
                ["name"] = "📜 Script Join:",
                ["value"] = 'game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", "'..jobId..'")',
                ["inline"] = false
            }
        },
        ["footer"] = {
            ["text"] = "MADE BY: CHIRIKU | "..os.date("Hôm nay lúc %H:%M")
        },
        ["thumbnail"] = {
            ["url"] = "https://upload.wikimedia.org/wikipedia/commons/3/3c/FullMoon2010.jpg"
        }
    }

    local data = {
        ["embeds"] = {embed},
        ["username"] = "Full Moon",
        ["avatar_url"] = "https://cdn.discordapp.com/emojis/1087739432068577280.webp"
    }

    pcall(function()
        syn.request({
            Url = getgenv().Webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

--// CHECK FULL MOON
function isFullMoon()
    local success, result = pcall(function()
        return ReplicatedStorage.Remotes:FindFirstChild("CommF_"):InvokeServer("GetMoon")
    end)
    return success and result == "FullMoon", result
end

--// SMART SERVER HOP
function serverHop()
    local servers = {}
    local response = game:HttpGet("https://games.roblox.com/v1/games/2753915549/servers/Public?limit=100&sortOrder=Desc")
    local data = HttpService:JSONDecode(response)

    for _, server in pairs(data.data) do
        if server.playing < server.maxPlayers and not checkedServers[server.id] then
            checkedServers[server.id] = true
            TeleportService:TeleportToPlaceInstance(2753915549, server.id)
            break
        end
    end
end

--// MAIN LOOP
while true do
    local fullMoon, phase = isFullMoon()
    textLabel.Text = "Full Moon Notify🌕: Moon Phase "..tostring(phase).."/5"

    if fullMoon then
        sendFullMoonWebhook(game.JobId, 5, #Players:GetPlayers(), "5")
        task.wait(2) -- Chờ nhẹ để đảm bảo webhook gửi
        serverHop()
    else
        task.wait(math.random(3, 5)) -- Delay 3–5s nếu không phải Full Moon
        serverHop()
    end
end
