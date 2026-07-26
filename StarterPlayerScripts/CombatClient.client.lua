--[[
	BEAST BRAWL SIMULATOR - Combat Client
	Client-side click/tap combat, attack nearest enemy, floating damage numbers
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

-- Wait for RemoteEvents/Functions
local attackRemote = game.ReplicatedStorage:WaitForChild("Attack")
local getEnemiesRemote = game.ReplicatedStorage:WaitForChild("GetEnemies")

-- Combat tracking
local lastAttackTime = 0
local attackCooldown = 0.2  -- 200ms between attacks

-- Create floating damage number
local function createDamageNumber(position, damage)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(0.5, 0.5, 0.5)
	part.CanCollide = false
	part.CFrame = CFrame.new(position)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Transparency = 0
	
	-- Create billboard GUI for damage text
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = part
	billboard.MaxDistance = 100
	billboard.Size = UDim2.new(4, 0, 2, 0)
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	textLabel.TextSize = 20
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = tostring(damage)
	textLabel.Parent = billboard
	
	billboard.Parent = part
	part.Parent = Workspace
	
	-- Animate floating up and fading
	local startTime = tick()
	local duration = 1  -- 1 second animation
	
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local elapsed = tick() - startTime
		local progress = math.min(elapsed / duration, 1)
		
		-- Move up
		part.CFrame = part.CFrame + Vector3.new(0, 0.1, 0)
		
		-- Fade out
		textLabel.TextTransparency = progress
		
		if progress >= 1 then
			conn:Disconnect()
			part:Destroy()
		end
	end)
end

-- Get nearest enemy to player
local function getNearestEnemy()
	local character = player.Character
	if not character then return nil end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end
	
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then return nil end
	
	local nearestEnemy = nil
	local nearestDistance = math.huge
	
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if enemy:IsA("BasePart") and enemy.Parent then
			local distance = (enemy.Position - humanoidRootPart.Position).Magnitude
			if distance < nearestDistance and distance < 50 then  -- 50 stud range
				nearestDistance = distance
				nearestEnemy = enemy
			end
		end
	end
	
	return nearestEnemy
end

-- Perform attack
local function attack()
	local now = tick()
	if now - lastAttackTime < attackCooldown then
		return  -- Still in cooldown
	end
	lastAttackTime = now
	
	local nearestEnemy = getNearestEnemy()
	if not nearestEnemy then
		return  -- No enemy in range
	end
	
	-- Send attack to server
	attackRemote:FireServer(nearestEnemy)
	
	-- Visual feedback
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		createDamageNumber(nearestEnemy.Position, math.random(10, 20))
	end
end

-- Click to attack
mouse.Button1Down:Connect(function()
	attack()
end)

-- Tap to attack (for mobile)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.Touch then
		attack()
	end
end)

-- Keyboard shortcut (spacebar to attack)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.Space then
		attack()
	end
end)

-- Display nearby enemies
local function displayEnemyCount()
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then return end
	
	local count = 0
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if enemy:IsA("BasePart") and enemy.Parent then
			local distance = (enemy.Position - humanoidRootPart.Position).Magnitude
			if distance < 50 then
				count = count + 1
			end
		end
	end
	
	return count
end

-- Auto-attack loop (optional: continuous attacks if held down)
local isAttacking = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.X then
		isAttacking = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.X then
		isAttacking = false
	end
end)

-- Continuous attack when X is held
spawn(function()
	while true do
		if isAttacking then
			attack()
		end
		task.wait(0.3)
	end
end)

print("Combat Client loaded - Click to attack, X to auto-attack")
