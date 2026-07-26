-- DamageCounter.client.lua — Live damage counter HUD
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local sg = Instance.new("ScreenGui"); sg.Name="DamageCounterGui"; sg.ResetOnSpawn=false; sg.Parent=playerGui

-- Main counter frame (left side, below token HUD)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,180,0,120)
frame.Position = UDim2.new(0,10,0.5,10)
frame.BackgroundColor3 = Color3.fromRGB(10,8,25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = sg
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,28)
title.BackgroundColor3 = Color3.fromRGB(200,0,80)
title.Text = "⚔️ DAMAGE"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Parent = frame
Instance.new("UICorner",title).CornerRadius = UDim.new(0,10)

local totalLabel = Instance.new("TextLabel")
totalLabel.Size = UDim2.new(1,0,0,40)
totalLabel.Position = UDim2.new(0,0,0,28)
totalLabel.BackgroundTransparency = 1
totalLabel.Text = "0"
totalLabel.TextColor3 = Color3.fromRGB(255,80,80)
totalLabel.TextScaled = true
totalLabel.Font = Enum.Font.GothamBold
totalLabel.Parent = frame

local sessionLabel = Instance.new("TextLabel")
sessionLabel.Size = UDim2.new(1,0,0,24)
sessionLabel.Position = UDim2.new(0,0,0,68)
sessionLabel.BackgroundTransparency = 1
sessionLabel.Text = "This session: 0"
sessionLabel.TextColor3 = Color3.fromRGB(160,160,200)
sessionLabel.TextScaled = true
sessionLabel.Font = Enum.Font.Gotham
sessionLabel.Parent = frame

local killLabel = Instance.new("TextLabel")
killLabel.Size = UDim2.new(1,0,0,24)
killLabel.Position = UDim2.new(0,0,0,92)
killLabel.BackgroundTransparency = 1
killLabel.Text = "Kills: 0"
killLabel.TextColor3 = Color3.fromRGB(255,150,0)
killLabel.TextScaled = true
killLabel.Font = Enum.Font.GothamBold
killLabel.Parent = frame

-- Tracking vars
local totalDamage = 0
local sessionDamage = 0
local kills = 0

-- Animate counter when damage lands
local function addDamage(amount)
	sessionDamage = sessionDamage + math.abs(amount)
	totalDamage = totalDamage + math.abs(amount)
	totalLabel.Text = tostring(math.floor(totalDamage))
	sessionLabel.Text = "This session: " .. math.floor(sessionDamage)

	-- Flash red on hit
	TweenService:Create(totalLabel, TweenInfo.new(0.08), {TextColor3=Color3.fromRGB(255,255,0)}):Play()
	wait(0.08)
	TweenService:Create(totalLabel, TweenInfo.new(0.2), {TextColor3=Color3.fromRGB(255,80,80)}):Play()

	-- Scale bounce
	TweenService:Create(frame, TweenInfo.new(0.08), {Size=UDim2.new(0,195,0,125)}):Play()
	wait(0.08)
	TweenService:Create(frame, TweenInfo.new(0.15), {Size=UDim2.new(0,180,0,120)}):Play()
end

local function addKill()
	kills = kills + 1
	killLabel.Text = "Kills: " .. kills
	TweenService:Create(killLabel, TweenInfo.new(0.1), {TextColor3=Color3.fromRGB(255,50,50)}):Play()
	wait(0.1)
	TweenService:Create(killLabel, TweenInfo.new(0.3), {TextColor3=Color3.fromRGB(255,150,0)}):Play()
end

-- Hook into HitEvent
local combatFolder = ReplicatedStorage:WaitForChild("ArenaCombat", 8)
if combatFolder then
	local HitEvent = combatFolder:FindFirstChild("Hit") or combatFolder:WaitForChild("Hit",5)
	if HitEvent then
		HitEvent.OnClientEvent:Connect(function(damage, coins, wasBlocked)
			if damage and damage > 0 then
				addDamage(damage)
			end
		end)
	end
end

-- Load career total from PlayerStats
local statsFolder = ReplicatedStorage:WaitForChild("PlayerStats", 8)
if statsFolder then
	local GetStats = statsFolder:FindFirstChild("GetStats")
	if GetStats then
		local data = GetStats:InvokeServer()
		if data then
			totalDamage = data.damage or 0
			kills = data.kills or 0
			totalLabel.Text = tostring(math.floor(totalDamage))
			killLabel.Text = "Kills: " .. kills
		end
	end
end

print("[DamageCounter] ⚔️ Damage counter active!")
