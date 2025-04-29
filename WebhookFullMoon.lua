--// CONFIG
local Webhook = "https://discord.com/api/webhooks/1366669467127382086/W-zfpbHnsXkpf8UZqzf9amT1nTYOBCOkKfwWJPa2ieIE81Jp-ZCKyq_lqyvc85ncfwa8"
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// FUNCTION SEND WEBHOOK
function sendFullMoonWebhook(jobId, moonPhase, players, remainingTime)
    local playerCount = tostring(players).."/12"
    local embed = {
        ["title"] = "**Full Moon Notify🌕**",
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

--// CHECK FULL MOON & RETURN STATUS
function isFullMoon()
    local success, result = pcall(function()
        return ReplicatedStorage.Remotes:FindFirstChild("CommF_"):InvokeServer("GetMoon")
    end)

    -- Nếu không phải FullMoon hoặc là "nil" (trời sáng), trả về false
    if not success or result == nil or result ~= "FullMoon" then
        return false, result or "None"
    end
    return true, "FullMoon"
end

--// SERVER HOP
function serverHop()
    local success, result = pcall(function()
        local allServers = game:GetService("ReplicatedStorage").__ServerBrowser:GetServers()
        for _, server in ipairs(allServers) do
            local isFull, phase = isFullMoon()
            if isFull then
                -- Nếu tìm thấy Full Moon, nhảy vào server đó
                game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", server)
                return
            end
        end
    end)
end

--// START
while true do
    local isFull, phase = isFullMoon()

    -- Cập nhật giao diện
    textLabel.Text = "Full Moon Notify🌕: Moon Phase "..tostring(phase)

    if isFull then
        sendFullMoonWebhook(game.JobId, 5, #Players:GetPlayers(), "5")
        task.wait(2)
        serverHop() -- Nếu có Full Moon thì hop server
    else
        task.wait(math.random(3, 5)) -- Delay check nếu trời sáng (không phải full moon)
        serverHop() -- Nếu không có Full Moon thì hop sang server khác
    end
end
