-- CasinoUI.client.lua — Token Casino HUD + Gambling Interface

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for casino remotes
local casinoFolder = ReplicatedStorage:WaitForChild("Casino", 10)
if not casinoFolder then return end

local GambleEvent = casinoFolder:WaitForChild("Gamble")
local TokenUpdate = casinoFolder:WaitForChild("TokenUpdate")

local currentTokens = 0
local casinoOpen = false
local betAmount = 50

-- ============================================================
-- MAIN SCREEN GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CasinoGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Token HUD (top right)
local tokenHud = Instance.new("Frame")
tokenHud.Name = "TokenHud"
tokenHud.Size = UDim2.new(0, 180, 0, 50)
tokenHud.Position = UDim2.new(1, -190, 0, 120)
tokenHud.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
tokenHud.BorderSizePixel = 0
screenGui.Parent = playerGui

local hudRound = Instance.new("UICorner")
hudRound.CornerRadius = UDim.new(0, 10)
hudRound.Parent = tokenHud

local tokenLabel = Instance.new("TextLabel")
tokenLabel.Size = UDim2.new(1, 0, 1, 0)
tokenLabel.BackgroundTransparency = 1
tokenLabel.Text = "🎰 Tokens: 0"
tokenLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
tokenLabel.TextScaled = true
tokenLabel.Font = Enum.Font.GothamBold
tokenLabel.Parent = tokenHud
tokenHud.Parent = screenGui

-- Casino button
local casinoBtn = Instance.new("TextButton")
casinoBtn.Size = UDim2.new(0, 140, 0, 44)
casinoBtn.Position = UDim2.new(1, -150, 1, -60)
casinoBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
casinoBtn.Text = "🎰 CASINO"
casinoBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
casinoBtn.TextScaled = true
casinoBtn.Font = Enum.Font.GothamBold
casinoBtn.BorderSizePixel = 0
casinoBtn.Parent = screenGui

local btnRound = Instance.new("UICorner")
btnRound.CornerRadius = UDim.new(0, 12)
btnRound.Parent = casinoBtn

-- ============================================================
-- CASINO PANEL
-- ============================================================
local casinoPanel = Instance.new("Frame")
casinoPanel.Name = "CasinoPanel"
casinoPanel.Size = UDim2.new(0, 400, 0, 520)
casinoPanel.Position = UDim2.new(0.5, -200, 0.5, -260)
casinoPanel.BackgroundColor3 = Color3.fromRGB(15, 10, 30)
casinoPanel.BorderSizePixel = 0
casinoPanel.Visible = false
casinoPanel.Parent = screenGui

local panelRound = Instance.new("UICorner")
panelRound.CornerRadius = UDim.new(0, 16)
panelRound.Parent = casinoPanel

-- Title
local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, 0, 0, 55)
panelTitle.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
panelTitle.Text = "🎰 TOKEN CASINO 🎰"
panelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
panelTitle.TextScaled = true
panelTitle.Font = Enum.Font.GothamBold
panelTitle.BorderSizePixel = 0
panelTitle.Parent = casinoPanel

local titleRound = Instance.new("UICorner")
titleRound.CornerRadius = UDim.new(0, 16)
titleRound.Parent = panelTitle

-- Token display in panel
local panelTokens = Instance.new("TextLabel")
panelTokens.Size = UDim2.new(1, -20, 0, 35)
panelTokens.Position = UDim2.new(0, 10, 0, 60)
panelTokens.BackgroundTransparency = 1
panelTokens.Text = "Your Tokens: 0"
panelTokens.TextColor3 = Color3.fromRGB(255, 200, 0)
panelTokens.TextScaled = true
panelTokens.Font = Enum.Font.GothamBold
panelTokens.Parent = casinoPanel

-- Bet amount row
local betLabel = Instance.new("TextLabel")
betLabel.Size = UDim2.new(0, 80, 0, 35)
betLabel.Position = UDim2.new(0, 10, 0, 100)
betLabel.BackgroundTransparency = 1
betLabel.Text = "BET:"
betLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
betLabel.TextScaled = true
betLabel.Font = Enum.Font.Gotham
betLabel.Parent = casinoPanel

local betBox = Instance.new("TextBox")
betBox.Size = UDim2.new(0, 120, 0, 35)
betBox.Position = UDim2.new(0, 95, 0, 100)
betBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
betBox.Text = "50"
betBox.TextColor3 = Color3.fromRGB(255, 255, 255)
betBox.TextScaled = true
betBox.Font = Enum.Font.GothamBold
betBox.BorderSizePixel = 0
betBox.Parent = casinoPanel

local betBoxRound = Instance.new("UICorner")
betBoxRound.CornerRadius = UDim.new(0, 8)
betBoxRound.Parent = betBox

-- Quick bet buttons
local quickBets = {{"10", 10}, {"50", 50}, {"100", 100}, {"ALL IN", nil}}
for i, qb in ipairs(quickBets) do
	local qBtn = Instance.new("TextButton")
	qBtn.Size = UDim2.new(0, 80, 0, 30)
	qBtn.Position = UDim2.new(0, 10 + (i-1)*88, 0, 142)
	qBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
	qBtn.Text = qb[1]
	qBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	qBtn.TextScaled = true
	qBtn.Font = Enum.Font.GothamBold
	qBtn.BorderSizePixel = 0
	qBtn.Parent = casinoPanel

	local qRound = Instance.new("UICorner")
	qRound.CornerRadius = UDim.new(0, 8)
	qRound.Parent = qBtn

	qBtn.MouseButton1Click:Connect(function()
		if qb[2] then
			betBox.Text = tostring(qb[2])
		else
			betBox.Text = tostring(currentTokens)
		end
	end)
end

-- Result display
local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1, -20, 0, 60)
resultLabel.Position = UDim2.new(0, 10, 0, 180)
resultLabel.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
resultLabel.Text = "Place a bet and spin!"
resultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
resultLabel.TextScaled = true
resultLabel.Font = Enum.Font.GothamBold
resultLabel.BorderSizePixel = 0
resultLabel.TextWrapped = true
resultLabel.Parent = casinoPanel

local resultRound = Instance.new("UICorner")
resultRound.CornerRadius = UDim.new(0, 10)
resultRound.Parent = resultLabel

-- Game buttons
local games = {
	{"🪙 COIN FLIP", "coinflip", Color3.fromRGB(255, 200, 0), "50/50 · 2x payout"},
	{"🎲 DICE ROLL", "dice", Color3.fromRGB(100, 200, 255), "Win on 4-6 · 2x"},
	{"🎰 SLOTS", "slots", Color3.fromRGB(255, 100, 200), "Jackpot = 10x!"},
	{"💰 DOUBLE UP", "double", Color3.fromRGB(100, 255, 100), "25% chance · 4x"},
}

for i, g in ipairs(games) do
	local row = math.ceil(i/2)
	local col = ((i-1) % 2)
	local gBtn = Instance.new("TextButton")
	gBtn.Size = UDim2.new(0, 180, 0, 60)
	gBtn.Position = UDim2.new(0, 10 + col*195, 0, 245 + (row-1)*70)
	gBtn.BackgroundColor3 = g[3]
	gBtn.Text = g[1]
	gBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	gBtn.TextScaled = true
	gBtn.Font = Enum.Font.GothamBold
	gBtn.BorderSizePixel = 0
	gBtn.Parent = casinoPanel

	local gRound = Instance.new("UICorner")
	gRound.CornerRadius = UDim.new(0, 10)
	gRound.Parent = gBtn

	local gDesc = Instance.new("TextLabel")
	gDesc.Size = UDim2.new(1, 0, 0.4, 0)
	gDesc.Position = UDim2.new(0, 0, 0.6, 0)
	gDesc.BackgroundTransparency = 1
	gDesc.Text = g[4]
	gDesc.TextColor3 = Color3.fromRGB(50, 50, 50)
	gDesc.TextScaled = true
	gDesc.Font = Enum.Font.Gotham
	gDesc.Parent = gBtn

	gBtn.MouseButton1Click:Connect(function()
		local bet = tonumber(betBox.Text) or 50
		resultLabel.Text = "🎲 Rolling..."
		resultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		GambleEvent:FireServer(g[2], bet)
	end)
end

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 370, 0, 40)
closeBtn.Position = UDim2.new(0, 15, 0, 465)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
closeBtn.Text = "✖ CLOSE"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = casinoPanel

local closeRound = Instance.new("UICorner")
closeRound.CornerRadius = UDim.new(0, 10)
closeRound.Parent = closeBtn

-- ============================================================
-- EVENT HANDLERS
-- ============================================================
casinoBtn.MouseButton1Click:Connect(function()
	casinoOpen = not casinoOpen
	casinoPanel.Visible = casinoOpen
end)

closeBtn.MouseButton1Click:Connect(function()
	casinoOpen = false
	casinoPanel.Visible = false
end)

TokenUpdate.OnClientEvent:Connect(function(tokens)
	currentTokens = tokens
	tokenLabel.Text = "🎰 Tokens: " .. tokens
	panelTokens.Text = "Your Tokens: " .. tokens
end)

GambleEvent.OnClientEvent:Connect(function(result, message, newTokens, bet, mult)
	currentTokens = newTokens or currentTokens

	if result == "win" then
		resultLabel.Text = "✅ " .. (message or "WIN!")
		resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		TweenService:Create(resultLabel, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 80, 0)}):Play()
		wait(0.2)
		TweenService:Create(resultLabel, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 20, 50)}):Play()
	elseif result == "lose" then
		resultLabel.Text = "❌ " .. (message or "LOSE!")
		resultLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		TweenService:Create(resultLabel, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 0, 0)}):Play()
		wait(0.2)
		TweenService:Create(resultLabel, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 20, 50)}):Play()
	else
		resultLabel.Text = "⚠️ " .. (message or "Error")
		resultLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	end
end)

print("[CasinoUI] 🎰 Casino UI loaded!")
