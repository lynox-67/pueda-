-- =========================
-- LUMORA HUB - FULL PRO
-- =========================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local placeId = game.PlaceId

-- REMOTES / FOLDERS
local BrainrotEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BrainrotSpawned")
local BrainrotsFolder = workspace:WaitForChild("Brainrots")

-- =========================
-- UI
-- =========================
local gui = script.Parent
local main = gui:WaitForChild("Main")

local AutoJoinBtn = main.AutoJoinButton
local EspPlayersBtn = main.EspPlayersButton
local EspBrainrotsBtn = main.EspBrainrotsButton

-- =========================
-- CONFIG
-- =========================
local ESP_BRAINROT_MIN = 10_000_000
local AUTOJOIN_MIN = 10_000_000
local AUTOJOIN_MAX = 4_000_000_000
local TELEPORT_DELAY = 6

-- =========================
-- COLORS (LUMORA)
-- =========================
local RED   = Color3.fromRGB(255,60,60)
local GREEN = Color3.fromRGB(0,200,120)
local GRAY  = Color3.fromRGB(120,120,120)
local CYAN  = Color3.fromRGB(0,220,255)

-- =========================
-- STATES
-- =========================
local manualEnabled = false
local canTeleport = false
local espPlayersEnabled = false
local espBrainrotsEnabled = false

-- =========================
-- AUTO JOIN BUTTON
-- =========================
AutoJoinBtn.Text = "AUTO JOIN: OFF"
AutoJoinBtn.BackgroundColor3 = RED

AutoJoinBtn.MouseButton1Click:Connect(function()
	manualEnabled = not manualEnabled
	if not manualEnabled then
		AutoJoinBtn.Text = "AUTO JOIN: OFF"
		AutoJoinBtn.BackgroundColor3 = RED
	end
end)

task.spawn(function()
	while true do
		task.wait(TELEPORT_DELAY)
		if manualEnabled and canTeleport then
			AutoJoinBtn.Text = "AUTO JOIN: ON"
			AutoJoinBtn.BackgroundColor3 = GREEN
			TeleportService:Teleport(placeId, player)
		elseif manualEnabled then
			AutoJoinBtn.Text = "AUTO JOIN: WAIT"
			AutoJoinBtn.BackgroundColor3 = GRAY
		end
	end
end)

BrainrotEvent.OnClientEvent:Connect(function(brainrot)
	if brainrot.value >= AUTOJOIN_MIN and brainrot.value <= AUTOJOIN_MAX then
		canTeleport = true
	else
		canTeleport = false
	end
end)

-- =========================
-- ESP PLAYERS (BOX + NAME + DIST)
-- =========================
local playerESP = {}

local function createPlayerESP(plr)
	if playerESP[plr] then return end

	local box = Drawing.new("Square")
	box.Color = RED
	box.Thickness = 2
	box.Filled = false

	local name = Drawing.new("Text")
	name.Color = RED
	name.Size = 14
	name.Center = true
	name.Outline = true

	local dist = Drawing.new("Text")
	dist.Color = RED
	dist.Size = 12
	dist.Center = true
	dist.Outline = true

	playerESP[plr] = {box=box, name=name, dist=dist}
end

EspPlayersBtn.MouseButton1Click:Connect(function()
	espPlayersEnabled = not espPlayersEnabled
	EspPlayersBtn.Text = espPlayersEnabled and "ESP PLAYERS: ON" or "ESP PLAYERS: OFF"
end)

-- =========================
-- ESP BRAINROTS (NAME + VALUE + FILTER)
-- =========================
local brainrotESP = {}

local function formatValue(v)
	if v >= 1e9 then
		return string.format("%.2fB", v/1e9)
	elseif v >= 1e6 then
		return string.format("%.1fM", v/1e6)
	else
		return tostring(v)
	end
end

local function createBrainrotESP(br)
	if brainrotESP[br] then return end
	local t = Drawing.new("Text")
	t.Color = CYAN
	t.Size = 14
	t.Center = true
	t.Outline = true
	brainrotESP[br] = t
end

EspBrainrotsBtn.MouseButton1Click:Connect(function()
	espBrainrotsEnabled = not espBrainrotsEnabled
	EspBrainrotsBtn.Text = espBrainrotsEnabled and "ESP BRAINROTS: ON" or "ESP BRAINROTS: OFF"
end)

-- =========================
-- RENDER LOOP
-- =========================
RunService.RenderStepped:Connect(function()
	-- PLAYERS ESP
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if espPlayersEnabled then
				createPlayerESP(plr)
				local hrp = plr.Character.HumanoidRootPart
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				local d = playerESP[plr]

				if onScreen then
					local scale = math.clamp(1 / (pos.Z / 50), 0.6, 2)
					local size = Vector2.new(40, 60) * scale

					d.box.Size = size
					d.box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
					d.box.Visible = true

					d.name.Text = plr.Name
					d.name.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 14)
					d.name.Visible = true

					local my = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if my then
						local dist = math.floor((my.Position - hrp.Position).Magnitude)
						d.dist.Text = dist .. "m"
						d.dist.Position = Vector2.new(pos.X, pos.Y + size.Y/2 + 2)
						d.dist.Visible = true
					end
				else
					for _,v in pairs(d) do v.Visible = false end
				end
			else
				if playerESP[plr] then
					for _,v in pairs(playerESP[plr]) do v.Visible = false end
				end
			end
		end
	end

	-- BRAINROTS ESP (WITH FILTER)
	for _,br in ipairs(BrainrotsFolder:GetChildren()) do
		if br:IsA("Model") and br.PrimaryPart and br:FindFirstChild("Value") then
			local value = br.Value.Value
			if espBrainrotsEnabled and value >= ESP_BRAINROT_MIN then
				createBrainrotESP(br)
				local pos, onScreen = Camera:WorldToViewportPoint(br.PrimaryPart.Position)
				local t = brainrotESP[br]

				if onScreen then
					t.Text = br.Name .. " [" .. formatValue(value) .. "]"
					t.Position = Vector2.new(pos.X, pos.Y - 20)
					t.Visible = true
				else
					t.Visible = false
				end
			else
				if brainrotESP[br] then
					brainrotESP[br].Visible = false
				end
			end
		end
	end
end)
