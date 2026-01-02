-- LUMORA STYLE AUTO JOIN + SERVER SPAM
-- STEAL A BRAINROT

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ================= CONFIG =================
local MIN_PLAYERS = 1
local MAX_PLAYERS = 8
local SPAM_DELAY = 1.5

-- RANGO ACTIVO
local RANGE_MIN = 1_000_000
local RANGE_MAX = 5_000_000

-- SERVERS VISITADOS
local Visited = {}

-- ================= UI =================
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"
))()

local Window = Library.CreateLib("Lumora Auto Joiner", "DarkTheme")
local Tab = Window:NewTab("Auto Join")
local Section = Tab:NewSection("Brainrot Range")

local function SetRange(min, max)
    RANGE_MIN = min
    RANGE_MAX = max
end

Section:NewToggle("1M - 5M", "", function(s)
    if s then SetRange(1e6, 5e6) end
end)

Section:NewToggle("5M - 10M", "", function(s)
    if s then SetRange(5e6, 10e6) end
end)

Section:NewToggle("10M - 50M", "", function(s)
    if s then SetRange(10e6, 50e6) end
end)

Section:NewToggle("50M - 100M", "", function(s)
    if s then SetRange(50e6, 100e6) end
end)

Section:NewToggle("100M - 500M", "", function(s)
    if s then SetRange(100e6, 500e6) end
end)

Section:NewToggle("500M - 1B", "", function(s)
    if s then SetRange(500e6, 1e9) end
end)

Section:NewToggle("1B+", "", function(s)
    if s then SetRange(1e9, math.huge) end
end)

-- ================= SERVER HOP =================
local function ServerHop()
    local success, res = pcall(function()
        return game:HttpGet(
            "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?limit=100&sortOrder=Asc"
        )
    end)
    if not success then return end

    local data = HttpService:JSONDecode(res)
    if not data or not data.data then return end

    for _, server in pairs(data.data) do
        if not Visited[server.id]
            and server.playing >= MIN_PLAYERS
            and server.playing <= MAX_PLAYERS then

            Visited[server.id] = true
            TeleportService:TeleportToPlaceInstance(
                PlaceId,
                server.id,
                Player
            )
            return
        end
    end
end

-- ================= SCAN BRAINROTS =================
local function ScanBrainrots()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("brain") then
            local value =
                obj:FindFirstChild("Value") or
                obj:FindFirstChild("Price") or
                obj:FindFirstChild("Money")

            if value and value:IsA("NumberValue") then
                if value.Value >= RANGE_MIN and value.Value <= RANGE_MAX then
                    warn("✅ BRAINROT ENCONTRADO:", value.Value)
                    return true
                end
            end
        end
    end
    return false
end

-- ================= LOOP INFINITO =================
task.spawn(function()
    task.wait(6)

    while true do
        local found = ScanBrainrots()
        if found then
            warn("🎉 SERVER BUENO, AUTO JOIN DETENIDO")
            break
        else
            warn("❌ NO CUMPLE, CAMBIANDO SERVER...")
            task.wait(SPAM_DELAY)
            ServerHop()
            break
        end
    end
end)
