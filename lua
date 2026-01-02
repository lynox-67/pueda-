-- =========================================================
-- LYNOX AUTO JOIN • VALUE ONLY (≥ minMoney)
-- =========================================================

-- ===== SERVICIOS =====
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

-- ===== CONFIG =====
local FILE = "lynox_config.json"
local DEFAULT = {
    minMoney = 50, -- MILLONES
    bind = "F6",
    filters = { maxPlayers = 35, minUptime = 120 }
}
local CONFIG = DEFAULT

if isfile and readfile and isfile(FILE) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(FILE))
    end)
    if ok and type(data) == "table" then CONFIG = data end
end

local function saveConfig()
    if writefile then writefile(FILE, HttpService:JSONEncode(CONFIG)) end
end

-- ===== ESTADO =====
getgenv().LYNOX = getgenv().LYNOX or {
    Running = false,
    Hops = 0,
    LastValue = 0,
    Logs = {},
    Visited = {},
    BadServers = {},
    StartTime = tick()
}

local LOAD_DELAY = 2.5

-- ===== UTIL =====
local function now() return os.date("%H:%M:%S") end
local function log(msg)
    table.insert(getgenv().LYNOX.Logs, ("[%s] %s"):format(now(), msg))
    if #getgenv().LYNOX.Logs > 7 then table.remove(getgenv().LYNOX.Logs, 1) end
end
local function avgHop()
    local t = tick() - getgenv().LYNOX.StartTime
    return getgenv().LYNOX.Hops > 0 and math.floor(t / getgenv().LYNOX.Hops) or 0
end

-- ===== SONIDO (≥ 80M) =====
local alert = Instance.new("Sound", workspace)
alert.SoundId = "rbxassetid://9118823101"
alert.Volume = 1

local _oldLog = log
function log(msg)
    _oldLog(msg)
    if msg:find("FOUND") and (getgenv().LYNOX.LastValue or 0) >= 80_000_000 then
        alert:Play()
    end
end

-- ===== SERVER FILTERS =====
local function serverIsValid()
    if CONFIG.filters then
        if #Players:GetPlayers() > (CONFIG.filters.maxPlayers or 35) then
            log("SERVER FULL → HOP")
            return false
        end
        if workspace.DistributedGameTime < (CONFIG.filters.minUptime or 120) then
            log("SERVER NEW → HOP")
            return false
        end
    end
    return true
end

-- ===== SCAN (VALUE ONLY) =====
local function findBestBrainrot()
    local best = 0
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("NumberValue") and v.Value > best then
            best = v.Value
        end
    end
    return best
end

-- ===== AUTO JOIN =====
local function hop()
    getgenv().LYNOX.Hops += 1
    TeleportService:Teleport(game.PlaceId, Player)
end

local function runAutoJoin()
    task.spawn(function()
        task.wait(LOAD_DELAY)
        if not getgenv().LYNOX.Running then return end

        if getgenv().LYNOX.BadServers[game.JobId] then
            log("BAD SERVER → HOP")
            hop(); return
        end

        if getgenv().LYNOX.Visited[game.JobId] then
            log("REPEAT SERVER → HOP")
            hop(); return
        end
        getgenv().LYNOX.Visited[game.JobId] = true

        if not serverIsValid() then
            getgenv().LYNOX.BadServers[game.JobId] = true
            hop(); return
        end

        local best = findBestBrainrot()
        getgenv().LYNOX.LastValue = best

        if best >= (CONFIG.minMoney * 1_000_000) then
            log(("FOUND %dM"):format(math.floor(best/1e6)))
        else
            log(("BEST %dM → HOP"):format(math.floor(best/1e6)))
            getgenv().LYNOX.BadServers[game.JobId] = true
            hop()
        end
    end)
end

-- ===== UI =====
local gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
gui.Name = "LynoxUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.34,0.42)
frame.Position = UDim2.fromScale(0.33,0.29)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local header = Instance.new("Frame", frame)
header.Size = UDim2.fromScale(1,0.14)
header.BackgroundColor3 = Color3.fromRGB(14,14,14)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.fromScale(0.8,1)
title.BackgroundTransparency = 1
title.Text = "LYNOX AUTO JOIN • VALUE ONLY"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(0,170,255)

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.fromScale(0.2,1)
minBtn.Position = UDim2.fromScale(0.8,0)
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextScaled = true
minBtn.BackgroundColor3 = Color3.fromRGB(28,28,28)
minBtn.TextColor3 = Color3.new(1,1,1)

local body = Instance.new("Frame", frame)
body.Position = UDim2.fromScale(0,0.14)
body.Size = UDim2.fromScale(1,0.86)
body.BackgroundTransparency = 1

local status = Instance.new("TextLabel", body)
status.Size = UDim2.fromScale(1,0.1)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamBold
status.TextScaled = true

local info = Instance.new("TextLabel", body)
info.Position = UDim2.fromScale(0,0.1)
info.Size = UDim2.fromScale(1,0.08)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextScaled = true
info.TextColor3 = Color3.fromRGB(200,200,200)

local startBtn = Instance.new("TextButton", body)
startBtn.Position = UDim2.fromScale(0.08,0.22)
startBtn.Size = UDim2.fromScale(0.36,0.14)
startBtn.Text = "START"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextScaled = true
startBtn.BackgroundColor3 = Color3.fromRGB(40,180,70)
startBtn.TextColor3 = Color3.new(1,1,1)

local stopBtn = Instance.new("TextButton", body)
stopBtn.Position = UDim2.fromScale(0.56,0.22)
stopBtn.Size = UDim2.fromScale(0.36,0.14)
stopBtn.Text = "STOP"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextScaled = true
stopBtn.BackgroundColor3 = Color3.fromRGB(180,45,45)
stopBtn.TextColor3 = Color3.new(1,1,1)

-- Quick buttons
local function makeQuick(text, x, value)
    local b = Instance.new("TextButton", body)
    b.Position = UDim2.fromScale(x,0.40)
    b.Size = UDim2.fromScale(0.18,0.1)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function()
        CONFIG.minMoney = value
        saveConfig()
        log("SET MIN "..value.."M")
        updateUI()
    end)
end
makeQuick("30M", 0.08, 30)
makeQuick("50M", 0.41, 50)
makeQuick("100M",0.74,100)

local logsBox = Instance.new("TextLabel", body)
logsBox.Position = UDim2.fromScale(0.08,0.54)
logsBox.Size = UDim2.fromScale(0.84,0.38)
logsBox.BackgroundColor3 = Color3.fromRGB(26,26,26)
logsBox.TextColor3 = Color3.fromRGB(210,210,210)
logsBox.Font = Enum.Font.Gotham
logsBox.TextScaled = true
logsBox.TextWrapped = true

-- ===== THEME (F8) =====
local THEME = {
    Dark  = {BG=Color3.fromRGB(18,18,18), H=Color3.fromRGB(14,14,14), A=Color3.fromRGB(0,170,255)},
    Light = {BG=Color3.fromRGB(235,235,235),H=Color3.fromRGB(210,210,210),A=Color3.fromRGB(0,120,255)}
}
local currentTheme = "Dark"
local function applyTheme()
    local t = THEME[currentTheme]
    frame.BackgroundColor3 = t.BG
    header.BackgroundColor3 = t.H
    title.TextColor3 = t.A
end
applyTheme()

-- ===== UI UPDATE =====
function updateUI()
    status.Text = getgenv().LYNOX.Running and "STATUS: RUNNING" or "STATUS: STOPPED"
    status.TextColor3 = getgenv().LYNOX.Running and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,90,90)
    info.Text = ("MIN: %dM | HOPS: %d | LAST: %dM | AVG: %ds")
        :format(CONFIG.minMoney, getgenv().LYNOX.Hops, math.floor((getgenv().LYNOX.LastValue or 0)/1e6), avgHop())
    logsBox.Text = (#getgenv().LYNOX.Logs>0) and table.concat(getgenv().LYNOX.Logs,"\n") or "—"
end

-- ===== EVENTS =====
startBtn.MouseButton1Click:Connect(function()
    getgenv().LYNOX.Running = true
    log("START")
    updateUI()
    runAutoJoin()
end)
stopBtn.MouseButton1Click:Connect(function()
    getgenv().LYNOX.Running = false
    log("STOP")
    updateUI()
end)

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode.Name == CONFIG.bind then
        getgenv().LYNOX.Running = not getgenv().LYNOX.Running
        log(getgenv().LYNOX.Running and "START (HOTKEY)" or "STOP (HOTKEY)")
        updateUI()
        if getgenv().LYNOX.Running then runAutoJoin() end
    elseif i.KeyCode == Enum.KeyCode.F8 then
        currentTheme = (currentTheme=="Dark") and "Light" or "Dark"
        applyTheme()
        log("THEME "..currentTheme)
    end
end)

local minimized, fullSize, miniSize = false, frame.Size, UDim2.fromScale(0.34,0.08)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    TweenService:Create(frame, TweenInfo.new(0.2), {Size = minimized and miniSize or fullSize}):Play()
    minBtn.Text = minimized and "+" or "—"
end)

-- INIT
log("READY • VALUE ONLY ≥ "..CONFIG.minMoney.."M")
updateUI()
