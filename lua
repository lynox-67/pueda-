-- AUTO JOIN REAL - ESTILO LUMORA

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local PlaceId = game.PlaceId

-- CONFIG
local MIN_PLAYERS = 1
local MAX_PLAYERS = 5

local Cursor = ""

repeat
    local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    if Cursor ~= "" then
        url = url .. "&cursor=" .. Cursor
    end

    local data = HttpService:JSONDecode(game:HttpGet(url))

    for _, server in ipairs(data.data) do
        if server.playing >= MIN_PLAYERS and server.playing <= MAX_PLAYERS then
            TeleportService:TeleportToPlaceInstance(
                PlaceId,
                server.id,
                Players.LocalPlayer
            )
            return
        end
    end

    Cursor = data.nextPageCursor or ""
until Cursor == ""
