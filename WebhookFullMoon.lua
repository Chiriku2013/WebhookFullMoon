-- Full Moon Notifier AutoHop | By Chiriku
-- Chỉ thông báo nếu server hiện tại là Full Moon, sau đó auto hop tiếp
-- Webhook gửi liên tục khi tìm thấy server Full Moon

--// CONFIG
local Webhook = "https://discord.com/api/webhooks/1366669467127382086/W-zfpbHnsXkpf8UZqzf9amT1nTYOBCOkKfwWJPa2ieIE81Jp-ZCKyq_lqyvc85ncfwa8"
local HttpService = game:GetService("HttpService")
local TPService = game:GetService("TeleportService")
local Players = game:GetService("Players")

--// FUNCTION SEND WEBHOOK
function sendFullMoonWebhook(jobId, moonPhase, players, remainingTime)
    local playerCount = tostring(players).."/12"
    local embed = {
        ["title"] = "**Full Moon Notify🌕**",
        ["description"] = "",
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
        ["username"] = "Full Moon Notifier",
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

--// CHECK FULL MOON
function checkFullMoon()
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes:FindFirstChild("CommF_"):InvokeServer("GetMoon")
    end)
    return success and result == "FullMoon", result
end

--// LOOP + AUTO HOP
while true do
    local isFull, moonState = checkFullMoon()
    local jobId = game.JobId
    local players = #Players:GetPlayers()
    local moonPhase = moonState == "FullMoon" and 5 or tonumber(string.match(tostring(moonState), "%d+")) or 0
    local remainingTime = moonPhase == 5 and "5" or tostring(5 - moonPhase)

    if isFull then
        sendFullMoonWebhook(jobId, moonPhase, players, remainingTime)
        wait(10) -- chờ 1 chút cho webhook gửi xong
    end

    -- Hop tiếp server
    local servers = game:GetService("HttpService"):JSONDecode(
        game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
    )
    for _, srv in pairs(servers.data) do
        if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
            TPService:TeleportToPlaceInstance(game.PlaceId, srv.id)
            return
        end
    end

    wait(5)
end
