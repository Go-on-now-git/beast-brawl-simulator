-- CombatArena.client.lua
-- Attack, block, coin splatter, arena betting, ding sounds

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local SoundService     = game:GetService("SoundService")
local RunService       = game:GetService("RunService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera    = workspace.CurrentCamera

local combatFolder = ReplicatedStorage:WaitForChild("ArenaCombat", 10)
if not combatFolder then return end

local AttackEvent  = combatFolder:WaitForChild("AttackEvent") or combatFolder:WaitForChild("Attack")
local BlockEvent   = combatFolder:WaitForChild("BlockEvent")  or combatFolder:WaitForChild("Block")
local HitEvent     = combatFolder:WaitForChild("HitEvent")    or combatFolder:WaitForChild("Hit")
local BetEvent     = combatFolder:WaitForChild("PlaceBet")
local BetResult    = combatFolder:WaitForChild("BetResult")
local CoinSplatter = combatFolder:WaitForChild("CoinSplatter")

-- ============================================================
-- SOUNDS
-- ============================================================
local function makeSound(id, vol, pitch)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Volume = vol or 0.7
	s.PlaybackSpeed = pitch or 1.0
	s.Parent = SoundService
	return s
end

local hitSound1    = makeSound(5273862860, 0.9, 1.2)  -- ding!
local hitSound2    = makeSound(5273862860, 0.9, 1.4)  -- higher ding!
local hitSound3    = makeSound(5273862860, 0.9, 1.6)  -- highest ding!
local blockSound   = makeSound(6042053626, 0.8, 0.8)  -- clank
local coinTink     = makeSound(9120387661, 0.6, 1.5)  -- coin tink
local swingSound   = makeSound(5028557988, 0.5, 1.3)  -- whoosh swing
local bigHitSound  = makeSound(1837452708, 0.7, 1.0)  -- big impact
local deathSound   = makeSound(3744371592, 0.8, 0.9)  -- game over

local hitSounds = {hitSound1, hitSound2, hitSound3}
local hitCombo  = 0
local lastHitTime = 0

-- ============================================================
-- SCREEN GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatArenaGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Combat instructions (bottom left corner)
local instructions = Instance.new("Frame")
instructions.Size = UDim2.new(0, 200, 0, 80)
instructions.Position = UDim2.new(0, 10, 1, -95)
instructions.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
instructions.BackgroundTransparency = 0.3
instructions.BorderSizePixel = 0
instructions.Parent = screenGui
Instance.new("UICorner", instructions).CornerRadius = UDim.new(0, 8)

local instrLabel = Instance.new("TextLabel")
instrLabel.Size = UDim2.new(1, 0, 1, 0)
instrLabel.BackgroundTransparency = 1
instrLabel.Text = "🖱️ CLICK = Attack\n⌨️ Q = Block\n⌨️ B [name] [amt] = Bet"
instrLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
instrLabel.TextScaled = true
instrLabel.Font = Enum.Font.Gotham
instrLabel.Parent = instructions

-- Block indicator
local blockFrame = Instance.new("Frame")
blockFrame.Size = UDim2.new(0, 120, 0, 36)
blockFrame.Position = UDim2.new(0.5, -60, 1, -45)
blockFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
blockFrame.BackgroundTransparency = 1
blockFrame.BorderSizePixel = 0
blockFrame.Parent = screenGui
Instance.new("UICorner", blockFrame).CornerRadius = UDim.new(0, 8)

local blockLabel = Instance.new("TextLabel")
blockLabel.Size = UDim2.new(1, 0, 1, 0)
blockLabel.BackgroundTransparency = 1
blockLabel.Text = "🛡️ BLOCKING"
blockLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
blockLabel.TextScaled = true
blockLabel.Font = Enum.Font.GothamBold
blockLabel.Visible = false
blockLabel.Parent = blockFrame

-- Bet notification label (top center)
local betNotif = Instance.new("TextLabel")
betNotif.Size = UDim2.new(0, 400, 0, 44)
betNotif.Position = UDim2.new(0.5, -200, 0, 70)
betNotif.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
betNotif.BackgroundTransparency = 0.2
betNotif.Text = ""
betNotif.TextColor3 = Color3.fromRGB(255, 255, 255)
betNotif.TextScaled = true
betNotif.Font = Enum.Font.GothamBold
betNotif.Visible = false
betNotif.BorderSizePixel = 0
betNotif.Parent = screenGui
Instance.new("UICorner", betNotif).CornerRadius = UDim.new(0, 10)

-- ============================================================
-- COIN SPLATTER EFFECT
-- ============================================================
local function spawnCoinSplatter(worldPos, coinAmount, damage, wasBlocked)
	coinAmount = math.max(1, coinAmount or 5)
	local count = math.min(coinAmount, 12) -- cap visual coins

	-- Screen shake on big hits
	if damage and damage > 20 and not wasBlocked then
		local orig = camera.CFrame
		for i = 1, 4 do
			camera.CFrame = orig * CFrame.new(
				math.random(-2,2)*0.08,
				math.random(-1,1)*0.06, 0
			)
			wait(0.03)
		end
		camera.CFrame = orig
	end

	-- Convert world position to screen position
	local screenPos, onScreen = camera:WorldToScreenPoint(worldPos)
	if not onScreen then return end

	-- Spawn coin labels
	for i = 1, count do
		local coin = Instance.new("TextLabel")
		coin.Size = UDim2.new(0, 28, 0, 28)
		coin.Position = UDim2.new(0, screenPos.X + math.random(-30, 30),
		                          0, screenPos.Y + math.random(-20, 10))
		coin.BackgroundTransparency = 1
		coin.Text = "🪙"
		coin.TextScaled = true
		coin.Font = Enum.Font.GothamBold
		coin.ZIndex = 50
		coin.Parent = screenGui

		-- Fly outward and fade
		local angle = math.random() * math.pi * 2
		local dist  = math.random(40, 100)
		local targetX = screenPos.X + math.cos(angle) * dist
		local targetY = screenPos.Y + math.sin(angle) * dist - 60

		TweenService:Create(coin, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position    = UDim2.new(0, targetX, 0, targetY),
			TextTransparency = 1,
		}):Play()

		coinTink:Play()
		game:GetService("Debris"):AddItem(coin, 0.7)
	end

	-- Floating damage + coin loss text
	local dmgLabel = Instance.new("TextLabel")
	dmgLabel.Size = UDim2.new(0, 160, 0, 40)
	dmgLabel.Position = UDim2.new(0, screenPos.X - 80, 0, screenPos.Y - 40)
	dmgLabel.BackgroundTransparency = 1
	dmgLabel.Text = (wasBlocked and "🛡️ " or "-") .. (damage or 0) .. " HP  -" .. coinAmount .. "🪙"
	dmgLabel.TextColor3 = wasBlocked and Color3.fromRGB(100,180,255) or Color3.fromRGB(255, 80, 80)
	dmgLabel.TextScaled = true
	dmgLabel.Font = Enum.Font.GothamBold
	dmgLabel.ZIndex = 51
	dmgLabel.Parent = screenGui

	TweenService:Create(dmgLabel, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, screenPos.X - 80, 0, screenPos.Y - 90),
		TextTransparency = 1,
	}):Play()
	game:GetService("Debris"):AddItem(dmgLabel, 1.1)
end

CoinSplatter.OnClientEvent:Connect(function(worldPos, coins, damage, wasBlocked)
	spawnCoinSplatter(worldPos, coins, damage, wasBlocked)
	-- Ding ding ding on hit
	local now = tick()
	if now - lastHitTime < 0.8 then
		hitCombo = math.min(hitCombo + 1, 3)
	else
		hitCombo = 1
	end
	lastHitTime = now
	hitSounds[hitCombo]:Play()

	if wasBlocked then
		blockSound:Play()
	end
end)

-- Hit confirmation (to attacker)
HitEvent.OnClientEvent:Connect(function(damage, coins, wasBlocked)
	if damage > 0 then
		-- attacker feedback: small swing + ding
		swingSound:Play()
		if damage > 25 then bigHitSound:Play() end
	end
end)

-- ============================================================
-- BLOCK MECHANIC — Q key
-- ============================================================
local isBlocking = false

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Q then
		isBlocking = true
		BlockEvent:FireServer(true)
		blockLabel.Visible = true
		TweenService:Create(blockFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
		blockSound:Play()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Q then
		isBlocking = false
		BlockEvent:FireServer(false)
		blockLabel.Visible = false
		TweenService:Create(blockFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
	end
end)

-- ============================================================
-- ATTACK — Click nearest player
-- ============================================================
local attackCooldown = false

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and
	   input.KeyCode ~= Enum.KeyCode.E then return end
	if attackCooldown then return end

	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Find nearest player within 12 studs
	local nearest, nearestDist = nil, 12
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
			if otherRoot then
				local dist = (root.Position - otherRoot.Position).Magnitude
				if dist < nearestDist then
					nearest = other
					nearestDist = dist
				end
			end
		end
	end

	if nearest then
		swingSound:Play()
		attackCooldown = true
		AttackEvent:FireServer(nearest)
		wait(0.35)
		attackCooldown = false
	end
end)

-- ============================================================
-- ARENA BETTING — Chat command: /bet [player] [amount]
-- ============================================================
player.Chatted:Connect(function(msg)
	local args = msg:lower():split(" ")
	if args[1] == "/bet" or args[1] == "b" then
		local targetName = args[2]
		local amount = tonumber(args[3]) or 100

		local targetPlayer
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name:lower():find(targetName or "") and p ~= player then
				targetPlayer = p
				break
			end
		end

		if targetPlayer then
			BetEvent:FireServer(targetPlayer, amount)
			betNotif.Text = "⚔️ Bet of " .. amount .. " 🪙 sent to " .. targetPlayer.Name .. "!"
		else
			betNotif.Text = "❌ Player not found: " .. (targetName or "?")
		end
		betNotif.Visible = true
		TweenService:Create(betNotif, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
		delay(3, function()
			TweenService:Create(betNotif, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
			wait(0.5); betNotif.Visible = false
		end)
	end
end)

-- Bet result notifications
BetResult.OnClientEvent:Connect(function(won, msg)
	betNotif.Text = msg or ""
	betNotif.BackgroundColor3 = won == true and Color3.fromRGB(0,180,80) or
	                             won == false and Color3.fromRGB(200,30,30) or
	                             Color3.fromRGB(255,150,0)
	betNotif.Visible = true
	TweenService:Create(betNotif, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()

	if won == true then
		hitSound3:Play()
	elseif won == false then
		deathSound:Play()
	end

	delay(4, function()
		TweenService:Create(betNotif, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
		wait(0.5); betNotif.Visible = false
	end)
end)

print("[CombatArena] ⚔️ Attack, block, coin splatter, arena betting loaded!")
