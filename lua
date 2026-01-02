-- ===============================
-- LUMORA HUB - REAL & FUNCTIONAL
-- ===============================

-- SERVICES
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local placeId = game.PlaceId

local BrainrotEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BrainrotSpawned")
local BrainrotsFolder = workspace:WaitForChild("Brainrots")

-- ===============================
-- UI CREATION
-- ===============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "LumoraHub"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.25, 0.35)
main.Position = UDim2.fromScale(0.05, 0.3)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Name = "Main"

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,12)

local function makeButton(text, y)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.fromScale(0.9, 0.12)
	b.Position = UDim2.fromScale(0.05, y)
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	Instance.new("UICorner", b)
	return b
end

local function makeBox(placeholder, y)
	local t = Instance.new("TextBox", main)
	t.Size = UDim2.fromScale(0.42, 0.1)
	t.Position = UDim2.fromScale(placeholder == "MIN" and 0.05 or 0.53, y)
	t.PlaceholderText = placeholder
	t.BackgroundColor3 = Color3.fromRGB(30,30,30)
	t.TextColor3 = Color3.new(1,1,1)
	t.TextScaled = true
	t.Font = Enum.Font.Gotham
	Instance.new("UICorner", t)
	return t
end

local autoJoinBtn = makeButton("AUTO JOIN: OFF", 0.08)
local espPlayersBtn = makeButton("ESP PLAYERS: OFF", 0.24)
local espBrainrotsBtn = makeButton("ESP BRAINROTS: OFF", 0.40)

local minBox = makeBox("MIN VALUE", 0.58)
local maxBox = makeBox("MAX VALUE", 0.58)

-- ===============================
-- STATES
-- ===============================
local autoJoinEnabled = false
local espPlayersEnabled = false
local espBrainrotsEnabled = false

local minValue = 10_000_000
local maxValue = 4_000_000_000
local canTeleport = false

-- ===============================
-- AUTO JOIN
-- ===============================
autoJoinBtn.MouseButton1Click:Connect(function()
	autoJoinEnabled = not autoJoinEnabled
	autoJoinBtn.Text = autoJoinEnabled and "AUTO JOIN: ON" or "AUTO JOIN: OFF"
	autoJoinBtn.BackgroundColor3 = autoJoinEnabled and Color3.fromRGB(0,200,120) or Color3.fromRGB(200,60,60)
end)

task.spawn(function()
	while true do
		task.wait(6)
		if autoJoinEnabled and canTeleport then
			TeleportService:Teleport(placeId, player)
		end
	end
end)

BrainrotEvent.OnClientEvent:Connect(function(brainrot)
	canTeleport = brainrot.value >= minValue and brainrot.value <= maxValue
end)

-- ===============================
-- FILTER INPUTS
-- ===============================
minBox.FocusLost:Connect(function()
	local v = tonumber(minBox.Text)
	if v then minValue = v end
end)

maxBox.FocusLost:Connect(function()
	local v = tonumber(maxBox.Text)
	if v then maxValue = v end
end)

-- ===============================
-- ESP PLAYERS (REAL)
-- ===============================
local function addPlayerESP(char)
	if char:FindFirstChild("ESP_HL") then return end

	local hl = Instance.new("Highlight", char)
	hl.Name = "ESP_HL"
	hl.FillTransparency = 1
	hl.OutlineColor = Color3.fromRGB(255,0,0)

	local gui = Instance.new("BillboardGui", char.Head)
	gui.Name = "ESP_GUI"
	gui.Size = UDim2.fromScale(4,1)
	gui.StudsOffset = Vector3.new(0,3,0)
	gui.AlwaysOnTop = true

	local txt = Instance.new("TextLabel", gui)
	txt.Size = UDim2.fromScale(1,1)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.fromRGB(255,0,0)
	txt.TextStrokeTransparency = 0
	txt.TextScaled = true

	RunService.RenderStepped:Connect(function()
		if espPlayersEnabled and player.Character and char:FindFirstChild("HumanoidRootPart") then
			local d = math.floor((player.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
			txt.Text = char.Name.." ["..d.."m]"
			gui.Enabled = true
			hl.Enabled = true
		else
			gui.Enabled = false
			hl.Enabled = false
		end
	end)
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(addPlayerESP)
end)

for _,p in pairs(Players:GetPlayers()) do
	if p.Character then addPlayerESP(p.Character) end
	p.CharacterAdded:Connect(addPlayerESP)
end

espPlayersBtn.MouseButton1Click:Connect(function()
	espPlayersEnabled = not espPlayersEnabled
	espPlayersBtn.Text = espPlayersEnabled and "ESP PLAYERS: ON" or "ESP PLAYERS: OFF"
end)

-- ===============================
-- ESP BRAINROTS (REAL)
-- ===============================
local function formatValue(v)
	return v >= 1e9 and string.format("%.2fB",v/1e9)
		or v >= 1e6 and string.format("%.1fM",v/1e6)
		or tostring(v)
end

local function addBrainrotESP(br)
	if br.PrimaryPart:FindFirstChild("ESP_GUI") then return end

	local gui = Instance.new("BillboardGui", br.PrimaryPart)
	gui.Name = "ESP_GUI"
	gui.Size = UDim2.fromScale(4,1)
	gui.StudsOffset = Vector3.new(0,4,0)
	gui.AlwaysOnTop = true

	local txt = Instance.new("TextLabel", gui)
	txt.Size = UDim2.fromScale(1,1)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.fromRGB(0,255,255)
	txt.TextStrokeTransparency = 0
	txt.TextScaled = true

	RunService.RenderStepped:Connect(function()
		if espBrainrotsEnabled and br:FindFirstChild("Value") then
			txt.Text = br.Name.." ["..formatValue(br.Value.Value).."]"
			gui.Enabled = true
		else
			gui.Enabled = false
		end
	end)
end

for _,b in pairs(BrainrotsFolder:GetChildren()) do
	if b:IsA("Model") and b.PrimaryPart then
		addBrainrotESP(b)
	end
end

espBrainrotsBtn.MouseButton1Click:Connect(function()
	espBrainrotsEnabled = not espBrainrotsEnabled
	espBrainrotsBtn.Text = espBrainrotsEnabled and "ESP BRAINROTS: ON" or "ESP BRAINROTS: OFF"
end)
