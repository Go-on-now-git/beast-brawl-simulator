--[[
	BEAST BRAWL SIMULATOR - Local UI Client
	Displays coins, pets, level/XP, rebirth, and leaderboard
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents/Functions
local spinPetRemote = game.ReplicatedStorage:WaitForChild("SpinPet")
local petSpinResultRemote = game.ReplicatedStorage:WaitForChild("PetSpinResult")
local getLeaderboardRemote = game.ReplicatedStorage:WaitForChild("GetLeaderboard")
local getPlayerRankRemote = game.ReplicatedStorage:WaitForChild("GetPlayerRank")
local checkPassRemote = game.ReplicatedStorage:WaitForChild("CheckGamePass")

-- Create main UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Coins Display (top-left)
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "CoinsLabel"
coinsLabel.Size = UDim2.new(0, 200, 0, 50)
coinsLabel.Position = UDim2.new(0, 10, 0, 10)
coinsLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
coinsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
coinsLabel.TextSize = 24
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.Text = "Coins: 0"
coinsLabel.Parent = screenGui

-- Level Display (top-left, below coins)
local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "LevelLabel"
levelLabel.Size = UDim2.new(0, 200, 0, 40)
levelLabel.Position = UDim2.new(0, 10, 0, 70)
levelLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
levelLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
levelLabel.TextSize = 18
levelLabel.Font = Enum.Font.GothamBold
levelLabel.Text = "Level: 1"
levelLabel.Parent = screenGui

-- XP Bar
local xpBackground = Instance.new("Frame")
xpBackground.Name = "XPBackground"
xpBackground.Size = UDim2.new(0, 200, 0, 20)
xpBackground.Position = UDim2.new(0, 10, 0, 120)
xpBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
xpBackground.Parent = screenGui

local xpBar = Instance.new("Frame")
xpBar.Name = "XPBar"
xpBar.Size = UDim2.new(0, 0, 1, 0)
xpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
xpBar.Parent = xpBackground

-- Pet Inventory Panel (top-right)
local petPanel = Instance.new("Frame")
petPanel.Name = "PetPanel"
petPanel.Size = UDim2.new(0, 250, 0, 200)
petPanel.Position = UDim2.new(1, -260, 0, 10)
petPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
petPanel.BorderColor3 = Color3.fromRGB(100, 100, 100)
petPanel.Parent = screenGui

local petTitle = Instance.new("TextLabel")
petTitle.Name = "PetTitle"
petTitle.Size = UDim2.new(1, 0, 0, 30)
petTitle.Position = UDim2.new(0, 0, 0, 0)
petTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
petTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
petTitle.TextSize = 16
petTitle.Font = Enum.Font.GothamBold
petTitle.Text = "Pets: 0"
petTitle.Parent = petPanel

local petList = Instance.new("TextLabel")
petList.Name = "PetList"
petList.Size = UDim2.new(1, -10, 1, -50)
petList.Position = UDim2.new(0, 5, 0, 35)
petList.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
petList.TextColor3 = Color3.fromRGB(200, 200, 200)
petList.TextSize = 12
petList.Font = Enum.Font.GothamMonospace
petList.Text = "No pets yet"
petList.TextWrapped = true
petList.TextXAlignment = Enum.TextXAlignment.Left
petList.TextYAlignment = Enum.TextYAlignment.Top
petList.Parent = petPanel

-- Spin Button (center-bottom)
local spinButton = Instance.new("TextButton")
spinButton.Name = "SpinButton"
spinButton.Size = UDim2.new(0, 150, 0, 50)
spinButton.Position = UDim2.new(0.5, -75, 1, -70)
spinButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
spinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spinButton.TextSize = 18
spinButton.Font = Enum.Font.GothamBold
spinButton.Text = "SPIN PET"
spinButton.Parent = screenGui

-- Spin Result Display
local spinResultLabel = Instance.new("TextLabel")
spinResultLabel.Name = "SpinResult"
spinResultLabel.Size = UDim2.new(0, 300, 0, 100)
spinResultLabel.Position = UDim2.new(0.5, -150, 1, -190)
spinResultLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
spinResultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
spinResultLabel.TextSize = 16
spinResultLabel.Font = Enum.Font.GothamBold
spinResultLabel.Text = ""
spinResultLabel.TextWrapped = true
spinResultLabel.Visible = false
spinResultLabel.Parent = screenGui

-- Rebirth Button
local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.Size = UDim2.new(0, 150, 0, 50)
rebirthButton.Position = UDim2.new(1, -160, 1, -70)
rebirthButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthButton.TextSize = 16
rebirthButton.Font = Enum.Font.GothamBold
rebirthButton.Text = "REBIRTH"
rebirthButton.Parent = screenGui

-- Leaderboard Button
local leaderboardButton = Instance.new("TextButton")
leaderboardButton.Name = "LeaderboardButton"
leaderboardButton.Size = UDim2.new(0, 150, 0, 40)
leaderboardButton.Position = UDim2.new(0, 10, 1, -110)
leaderboardButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
leaderboardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
leaderboardButton.TextSize = 14
leaderboardButton.Font = Enum.Font.GothamBold
leaderboardButton.Text = "LEADERBOARD"
leaderboardButton.Parent = screenGui

-- Leaderboard Display
local leaderboardGui = Instance.new("Frame")
leaderboardGui.Name = "LeaderboardFrame"
leaderboardGui.Size = UDim2.new(0, 400, 0, 500)
leaderboardGui.Position = UDim2.new(0.5, -200, 0.5, -250)
leaderboardGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
leaderboardGui.Visible = false
leaderboardGui.Parent = screenGui

-- Add close button to leaderboard
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Parent = leaderboardGui

closeButton.MouseButton1Click:Connect(function()
	leaderboardGui.Visible = false
end)

local leaderboardList = Instance.new("TextLabel")
leaderboardList.Name = "LeaderboardList"
leaderboardList.Size = UDim2.new(1, -10, 1, -50)
leaderboardList.Position = UDim2.new(0, 5, 0, 40)
leaderboardList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
leaderboardList.TextColor3 = Color3.fromRGB(200, 200, 200)
leaderboardList.TextSize = 12
leaderboardList.Font = Enum.Font.GothamMonospace
leaderboardList.Text = "Loading..."
leaderboardList.TextWrapped = true
leaderboardList.TextXAlignment = Enum.TextXAlignment.Left
leaderboardList.TextYAlignment = Enum.TextYAlignment.Top
leaderboardList.Parent = leaderboardGui

-- Update UI function
local function updateUI()
	local stats = player:WaitForChild("leaderstats")
	
	coinsLabel.Text = "Coins: " .. stats.Coins.Value
	levelLabel.Text = "Level: " .. stats.Level.Value
end

-- Spin button clicked
spinButton.MouseButton1Click:Connect(function()
	spinPetRemote:FireServer()
	
	-- Wait for result
	local result = petSpinResultRemote:InvokeServer()
	if result then
		spinResultLabel.Text = "Got " .. result.displayName .. " Pet!\nMultiplier: " .. result.multiplier .. "x\nTotal Pets: " .. result.petsCount
		spinResultLabel.Visible = true
		
		-- Hide after 3 seconds
		task.wait(3)
		spinResultLabel.Visible = false
	end
end)

-- Leaderboard button clicked
leaderboardButton.MouseButton1Click:Connect(function()
	leaderboardGui.Visible = not leaderboardGui.Visible
	
	if leaderboardGui.Visible then
		-- Fetch leaderboard
		local leaderboard = getLeaderboardRemote:InvokeServer()
		local playerRank = getPlayerRankRemote:InvokeServer()
		
		local text = "=== TOP 100 PLAYERS ===\n\n"
		for i, entry in ipairs(leaderboard) do
			text = text .. i .. ". Player ID: " .. entry.userId .. " | Damage: " .. entry.totalDamage .. "\n"
		end
		
		text = text .. "\n=== YOUR STATS ===\nRank: " .. (playerRank.rank or "Unranked") .. "\nDamage: " .. playerRank.totalDamage
		
		leaderboardList.Text = text
	end
end)

-- Update UI periodically
while true do
	updateUI()
	task.wait(0.5)
end
