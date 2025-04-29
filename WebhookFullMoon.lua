--// CONFIG
local Webhook = "https://discord.com/api/webhooks/1366669467127382086/W-zfpbHnsXkpf8UZqzf9amT1nTYOBCOkKfwWJPa2ieIE81Jp-ZCKyq_lqyvc85ncfwa8"

--// FUNCTION SEND WEBHOOK
function sendFullMoonWebhook(jobId, moonPhase, players, remainingTime)
    local HttpService = game:GetService("HttpService")
    local playerCount = tostring(players).."/12"
    local embed = {
        ["title"] = "**Full Moon Notify**",
        ["description"] = "",
        ["color"] = 5814783,
        ["fields"] = {
            {
                ["name"] = "⌛ Status:",
                ["value"] = remainingTime.." Minute ( s )",
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

    local body = HttpService:JSONEncode(data)

    syn.request({
        Url = Webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = body
    })
end

--// CHECK FULL MOON & SEND
local function checkFullMoon()
    local rs = game:GetService("ReplicatedStorage")
    local moon = rs.Remotes:FindFirstChild("CommF_"):InvokeServer("GetMoon")
    if moon == "FullMoon" then
        local jobId = game.JobId
        local moonPhase = 5
        local players = #game:GetService("Players"):GetPlayers()
        local remainingTime = "5"
        sendFullMoonWebhook(jobId, moonPhase, players, remainingTime)
    end
end

--// START
checkFullMoon()
