-- =========================================================
-- LYNOX AUTO JOIN PREMIUM (LOCAL, SIN BOTS)
-- =========================================================

-- ===== SERVICIOS =====
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer

-- ===== SETTINGS (SESSION) =====
getgenv().LYNOX = getgenv().LYNOX or {
    Running = false,
    AutoStart = true,
    MinBrainrotM = 40, -- en MILLONES
    Hops = 0,
    Logs = {}
}

local LOAD_DELAY = 3

-- ===== UI BASE =====
local gui = Instance.new("ScreenGui")
gui.Name = "LynoxAutoJoinUI"
gui.ResetOnSpawn = false
gui.Parent = Player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.32, 0.42)
frame.Position = UDim2.fromScale(0.34, 0.28)
frame.BackgroundColor3 = Color3.fromRGB(22,22,22)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- ===== HEADER =====
local header = Instance.new("Frame", frame)
header.Size = UDim2.fromScale(1,0.14)
header.BackgroundColor3 = Color3.fromRGB(16,16,16)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.fromScale(0.75,1)
title.Text = "LYNOX AUTO JOIN • PREMIUM"
title.TextColor3 = Color3.fromRGB(0,170,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.fromScale(0.25,1)
minimizeBtn.Position = UDim2.fromScale(0.75,0)
minimizeBtn.Text = "—"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(28,28,28)
minimizeBtn.TextColor3 = Color3.fromRGB(220,220,220)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextScaled = true

-- ===== BODY =====
local body = Instance.new("Frame", frame)
body.Position = UDim2.fromScale(0,0.14)
body.Size = UDim2.fromScale(1,0.86)
body.BackgroundTransparency = 1

local status = Instance.new("TextLabel", body)
status.Position = UDim2.fromScale(0,0.02)
status.Size = UDim2.fromScale(1,0.12)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamBold
status.TextScaled = true

local hopsLbl = Instance.new("TextLabel", body)
hopsLbl.Position = UDim2.fromScale(0,0.14)
hopsLbl.Size = UDim2.fromScale(1,0.1)
hopsLbl.BackgroundTransparency = 1
hopsLbl.Font = Enum.Font.Gotham
hopsLbl.TextColor3 = Color3.fromRGB(200,200,200)
hopsLbl.TextScaled = true

-- ===== START / STOP =====
local startBtn = Instance.new("TextButton", body)
startBtn.Position = UDim2.fromScale(0.08,0.26)
startBtn.Size = UDim2.fromScale(0.36,0.16)
startBtn.Text = "START"
startBtn.BackgroundColor3 = Color3.fromRGB(45,180,70)
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextScaled = true

local stopBtn = Instance.new("TextButton", body)
stopBtn.Position = UDim2.fromScale(0.56,0.26)
stopBtn.Size = UDim2.fromScale(0.36,0.16)
stopBtn.Text = "STOP"
stopBtn.BackgroundColor3 = Color3.fromRGB(180,45,45)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextScaled = true

-- ===== SETTINGS =====
local settingsTitle = Instance.new("TextLabel", body)
settingsTitle.Position = UDim2.fromScale(0,0.45)
settingsTitle.Size = UDim2.fromScale(1,0.08)
settingsTitle.Text = "SETTINGS"
settingsTitle.TextColor3 = Color3.fromRGB(0,170,255)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextScaled = true

-- Slider (Min Brainrot en M)
local sliderBg = Instance.new("Frame", body)
sliderBg.Position = UDim2.fromScale(0.08,0.55)
sliderBg.Size = UDim2.fromScale(0.84,0.06)
sliderBg.BackgroundColor3 = Color3.fromRGB(35,35,35)
sliderBg.BorderSizePixel = 0

local sliderFill = Instance.new("Frame", sliderBg)
sliderFill.Size = UDim2.fromScale(0.4,1)
sliderFill.BackgroundColor3 = Color3.fromRGB(0,170,255)
sliderFill.BorderSizePixel = 0

local sliderLabel = Instance.new("TextLabel", body)
sliderLabel.Position = UDim2.fromScale(0.08,0.62)
sliderLabel.Size = UDim2.fromScale(0.84,0.08)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextColor3 = Color3.fromRGB(220,220,220)
sliderLabel.TextScaled = true

-- AutoStart Toggle
local autoBtn = Instance.new("TextButton", body)
autoBtn.Position = UDim2.fromScale(0.08,0.72)
autoBtn.Size = UDim2.fromScale(0.84,0.1)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextScaled = true

-- ===== LOGS =====
local logsTitle = Instance.new("TextLabel", body)
logsTitle.Position = UDim2.fromScale(0,0.84)
logsTitle.Size = UDim2.fromScale(1,0.08)
logsTitle.Text = "LOGS (SERVERS)"
logsTitle.TextColor3 = Color3.fromRGB(0,170,255)
logsTitle.BackgroundTransparency = 1
logsTitle.Font = Enum.Font.GothamBold
logsTitle.TextScaled = true

local logsBox = Instance.new("TextLabel", body)
logsBox.Position = UDim2.fromScale(0.08,0.92)
logsBox.Size = UDim2.fromScale(0.84,0.06)
logsBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
logsBox.TextColor3 = Color3.fromRGB(200,200,200)
logsBox.Font = Enum.Font.Gotham
logsBox.TextScaled = true
logsBox.TextWrapped = true

-- ===== FUNCIONES =====
local function updateUI()
    if getgenv().LYNOX.Running then
        status.Text = "STATUS: RUNNING"
        status.TextColor3 = Color3.fromRGB(70,255,120)
        startBtn.BackgroundColor3 = Color3.fromRGB(30,140,60)
    else
        status.Text = "STATUS: STOPPED"
        status.TextColor3 = Color3.fromRGB(255,80,80)
        startBtn.BackgroundColor3 = Color3.fromRGB(45,180,70)
    end

    hopsLbl.Text = "HOPS: "..getgenv().LYNOX.Hops
    sliderLabel.Text = "MIN BRAINROT: "..getgenv().LYNOX.MinBrainrotM.."M"

    autoBtn.Text = "AUTO START: "..(getgenv().LYNOX.AutoStart and "ON" or "OFF")
    autoBtn.BackgroundColor3 = getgenv().LYNOX.AutoStart
        and Color3.fromRGB(40,150,40)
        or Color3.fromRGB(120,120,120)

    logsBox.Text = (#getgenv().LYNOX.Logs > 0)
        and getgenv().LYNOX.Logs[#getgenv().LYNOX.Logs]
        or "—"
end

local function findBrainrot()
    local minValue = getgenv().LYNOX.MinBrainrotM * 1_000_000
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("NumberValue") and v.Value >= minValue then
            return true, v.Value
        end
    end
    return false
end

local function runAutoJoin()
    task.spawn(function()
        task.wait(LOAD_DELAY)
        if not getgenv().LYNOX.Running then return end

        local ok, value = findBrainrot()
        if ok then
            table.insert(getgenv().LYNOX.Logs, "FOUND: "..math.floor(value/1_000_000).."M")
            updateUI()
        else
            getgenv().LYNOX.Hops += 1
            table.insert(getgenv().LYNOX.Logs, "HOP "..getgenv().LYNOX.Hops)
            updateUI()
            TeleportService:Teleport(game.PlaceId, Player)
        end
    end)
end

-- ===== EVENTOS =====
startBtn.MouseButton1Click:Connect(function()
    getgenv().LYNOX.Running = true
    updateUI()
    runAutoJoin()
end)

stopBtn.MouseButton1Click:Connect(function()
    getgenv().LYNOX.Running = false
    updateUI()
end)

autoBtn.MouseButton1Click:Connect(function()
    getgenv().LYNOX.AutoStart = not getgenv().LYNOX.AutoStart
    updateUI()
end)

-- Slider input
sliderBg.InputBegan:Connect(function(i)
    if i.UserInputType.Name == "MouseButton1" then
        local x = math.clamp((i.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.fromScale(x,1)
        getgenv().LYNOX.MinBrainrotM = math.max(10, math.floor(x * 100))
        updateUI()
    end
end)

-- ===== MINIMIZAR =====
local minimized = false
local fullSize = frame.Size
local miniSize = UDim2.fromScale(0.32, 0.08)

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    frame.Size = minimized and miniSize or fullSize
    minimizeBtn.Text = minimized and "+" or "—"
end)

-- ===== AUTO START =====
updateUI()
if getgenv().LYNOX.AutoStart then
    getgenv().LYNOX.Running = true
    updateUI()
    runAutoJoin()
end
