-- =========================================================
-- LYNOX AUTO JOIN PREMIUM (MANUAL, SIN AUTO EXEC)
-- =========================================================

-- ===== SERVICIOS =====
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer

-- ===== ESTADO =====
getgenv().LYNOX = getgenv().LYNOX or {
    Running = false,
    MinBrainrotM = 40,
    Hops = 0,
    Logs = {}
}

local LOAD_DELAY = 3

-- ===== UI =====
local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "LynoxAutoJoinUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.32, 0.42)
frame.Position = UDim2.fromScale(0.34, 0.28)
frame.BackgroundColor3 = Color3.fromRGB(22,22,22)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- HEADER
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

-- BODY
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

-- BOTONES
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

-- ===== FUNCIONES =====
local function updateUI()
    if getgenv().LYNOX.Running then
        status.Text = "STATUS: RUNNING"
        status.TextColor3 = Color3.fromRGB(70,255,120)
    else
        status.Text = "STATUS: STOPPED"
        status.TextColor3 = Color3.fromRGB(255,80,80)
    end
    hopsLbl.Text = "HOPS: "..getgenv().LYNOX.Hops
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

        local ok = findBrainrot()
        if not ok then
            getgenv().LYNOX.Hops += 1
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

-- ===== INIT =====
updateUI()
