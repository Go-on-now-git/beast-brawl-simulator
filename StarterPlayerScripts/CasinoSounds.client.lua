-- CasinoSounds.client.lua
-- Full dopamine sound system for gambling UI
-- Uses Roblox free audio asset IDs

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- SOUND ASSET IDs (Roblox free audio library)
-- ============================================================
local SOUNDS = {
	-- Casino / slot machine
	slotSpin      = 5936700645,   -- slot machine spinning
	slotClick     = 6042053626,   -- reel click
	coinDrop      = 9120387661,   -- coins dropping
	coinShower    = 5999594896,   -- big coin shower
	jackpot       = 3744371592,   -- jackpot alarm
	bigWin        = 1837452708,   -- big win fanfare
	smallWin      = 5273862860,   -- small win ding
	lose          = 5273827590,   -- lose buzzer
	diceRoll      = 6190537375,   -- dice rolling
	cardFlip      = 6192066136,   -- card flip whoosh
	chipStack     = 4760980203,   -- chip stacking
	casinoAmb     = 3846831227,   -- casino ambient loop
	uiClick       = 6042053626,   -- button click
	uiHover       = 5273862860,   -- hover ping
	countdown     = 4612430999,   -- suspense countdown
	drumroll      = 1845697584,   -- drumroll
	popUp         = 5028557988,   -- popup whoosh
	levelUp       = 4612430999,   -- level up chime
	allIn         = 3744371592,   -- all in dramatic
	doublePing    = 5028557988,   -- double up ping
}

-- ============================================================
-- SOUND PLAYER
-- ============================================================
local soundFolder = Instance.new("Folder")
soundFolder.Name = "CasinoSounds"
soundFolder.Parent = SoundService

local soundCache = {}

local function playSound(soundId, volume, pitch)
	volume = volume or 0.7
	pitch = pitch or 1.0

	local cached = soundCache[soundId]
	if not cached then
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://" .. soundId
		s.Volume = volume
		s.PlaybackSpeed = pitch
		s.Parent = soundFolder
		soundCache[soundId] = s
		cached = s
	end

	cached.Volume = volume
	cached.PlaybackSpeed = pitch
	cached:Play()
	return cached
end

-- Ambient casino loop
local ambSound = Instance.new("Sound")
ambSound.SoundId = "rbxassetid://" .. SOUNDS.casinoAmb
ambSound.Volume = 0.15
ambSound.Looped = true
ambSound.Parent = SoundService

-- ============================================================
-- WAIT FOR CASINO GUI
-- ============================================================
local casinoGui = playerGui:WaitForChild("CasinoGui", 15)
if not casinoGui then
	-- Try again after short delay
	wait(3)
	casinoGui = playerGui:FindFirstChild("CasinoGui")
	if not casinoGui then return end
end

local casinoPanel = casinoGui:FindFirstChild("CasinoPanel")
local casinoBtn = casinoGui:FindFirstChild("TextButton") or casinoGui:FindFirstChildOfClass("TextButton")

-- Play ambient when casino opens
if casinoBtn then
	casinoBtn.MouseButton1Click:Connect(function()
		if casinoPanel and casinoPanel.Visible then
			ambSound:Play()
		else
			ambSound:Stop()
		end
		playSound(SOUNDS.popUp, 0.5, 1.1)
	end)
end

-- ============================================================
-- GAMBLING RESULT SOUNDS
-- ============================================================
local casinoFolder = ReplicatedStorage:WaitForChild("Casino", 10)
if not casinoFolder then return end
local GambleEvent = casinoFolder:WaitForChild("Gamble")

-- Hook all game buttons for anticipation sounds
if casinoPanel then
	for _, btn in ipairs(casinoPanel:GetDescendants()) do
		if btn:IsA("TextButton") and btn.Name ~= "CloseBtn" then
			btn.MouseButton1Click:Connect(function()
				local txt = btn.Text or ""
				if txt:find("FLIP") then
					playSound(SOUNDS.cardFlip, 0.8, 1.0)
					playSound(SOUNDS.countdown, 0.4, 1.5)
				elseif txt:find("DICE") then
					playSound(SOUNDS.diceRoll, 0.9, 1.0)
				elseif txt:find("SLOT") then
					playSound(SOUNDS.slotSpin, 0.9, 1.0)
					-- Rapid click sequence for slot reels
					for i = 1, 6 do
						delay(i * 0.12, function()
							playSound(SOUNDS.slotClick, 0.5, 0.9 + (i * 0.05))
						end)
					end
				elseif txt:find("DOUBLE") then
					playSound(SOUNDS.drumroll, 0.7, 1.0)
				elseif txt:find("ALL IN") then
					playSound(SOUNDS.allIn, 1.0, 0.9)
				else
					playSound(SOUNDS.chipStack, 0.5, 1.0)
				end
			end)

			btn.MouseEnter:Connect(function()
				playSound(SOUNDS.uiClick, 0.2, 1.4)
			end)
		end
	end
end

-- ============================================================
-- WIN / LOSE REACTION SOUNDS + SCREEN EFFECTS
-- ============================================================
GambleEvent.OnClientEvent:Connect(function(result, message, newTokens, bet, mult)
	if result == "win" then
		if message and (message:find("JACKPOT") or message:find("10x")) then
			-- MEGA jackpot sequence
			playSound(SOUNDS.jackpot, 1.0, 1.0)
			wait(0.3)
			playSound(SOUNDS.coinShower, 0.9, 1.0)
			wait(0.2)
			playSound(SOUNDS.bigWin, 1.0, 1.0)

			-- Jackpot screen flash
			local flash = Instance.new("Frame")
			flash.Size = UDim2.new(1, 0, 1, 0)
			flash.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
			flash.BackgroundTransparency = 0.3
			flash.ZIndex = 100
			flash.BorderSizePixel = 0
			flash.Parent = playerGui:FindFirstChildOfClass("ScreenGui") or playerGui

			-- Jackpot text
			local jackLabel = Instance.new("TextLabel")
			jackLabel.Size = UDim2.new(1, 0, 0.3, 0)
			jackLabel.Position = UDim2.new(0, 0, 0.35, 0)
			jackLabel.BackgroundTransparency = 1
			jackLabel.Text = "🎰 JACKPOT!! 🎰\n💰 " .. (mult or "") .. "x WIN! 💰"
			jackLabel.TextColor3 = Color3.fromRGB(255, 50, 0)
			jackLabel.TextScaled = true
			jackLabel.Font = Enum.Font.GothamBold
			jackLabel.ZIndex = 101
			jackLabel.Parent = flash

			-- Shake effect
			local orig = flash.Position
			for i = 1, 8 do
				flash.Position = UDim2.new(math.random(-2,2)*0.005, 0, math.random(-2,2)*0.005, 0)
				wait(0.05)
			end
			flash.Position = orig

			TweenService:Create(flash, TweenInfo.new(1.5), {BackgroundTransparency = 1}):Play()
			TweenService:Create(jackLabel, TweenInfo.new(1.2), {TextTransparency = 1}):Play()
			wait(1.5)
			flash:Destroy()

		elseif mult and mult >= 4 then
			-- Big win
			playSound(SOUNDS.bigWin, 0.9, 1.0)
			playSound(SOUNDS.coinShower, 0.7, 1.1)

			local flash = Instance.new("Frame")
			flash.Size = UDim2.new(1, 0, 1, 0)
			flash.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
			flash.BackgroundTransparency = 0.6
			flash.ZIndex = 100
			flash.BorderSizePixel = 0
			flash.Parent = playerGui:FindFirstChildOfClass("ScreenGui") or playerGui
			TweenService:Create(flash, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
			wait(0.8); flash:Destroy()

		else
			-- Normal win
			playSound(SOUNDS.smallWin, 0.8, 1.0)
			playSound(SOUNDS.coinDrop, 0.6, 1.2)

			local flash = Instance.new("Frame")
			flash.Size = UDim2.new(1, 0, 1, 0)
			flash.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
			flash.BackgroundTransparency = 0.75
			flash.ZIndex = 100
			flash.BorderSizePixel = 0
			flash.Parent = playerGui:FindFirstChildOfClass("ScreenGui") or playerGui
			TweenService:Create(flash, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
			wait(0.5); flash:Destroy()
		end

		-- Floating +tokens popup
		if bet then
			local popup = Instance.new("TextLabel")
			popup.Size = UDim2.new(0, 200, 0, 50)
			popup.Position = UDim2.new(0.5, -100, 0.5, 0)
			popup.BackgroundTransparency = 1
			popup.Text = "+" .. tostring((mult or 2) * bet - bet) .. " 🎰"
			popup.TextColor3 = Color3.fromRGB(255, 215, 0)
			popup.TextScaled = true
			popup.Font = Enum.Font.GothamBold
			popup.ZIndex = 102
			popup.Parent = playerGui:FindFirstChildOfClass("ScreenGui") or playerGui
			TweenService:Create(popup, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = UDim2.new(0.5, -100, 0.3, 0), TextTransparency = 1}):Play()
			wait(1.2); popup:Destroy()
		end

	elseif result == "lose" then
		playSound(SOUNDS.lose, 0.8, 0.9)

		-- Red flash
		local flash = Instance.new("Frame")
		flash.Size = UDim2.new(1, 0, 1, 0)
		flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		flash.BackgroundTransparency = 0.75
		flash.ZIndex = 100
		flash.BorderSizePixel = 0
		flash.Parent = playerGui:FindFirstChildOfClass("ScreenGui") or playerGui

		-- Screen shake
		for i = 1, 5 do
			flash.Position = UDim2.new(math.random(-1,1)*0.01, 0, math.random(-1,1)*0.01, 0)
			wait(0.04)
		end
		flash.Position = UDim2.new(0,0,0,0)
		TweenService:Create(flash, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		wait(0.4); flash:Destroy()

		-- Floating -tokens
		if bet then
			local popup = Instance.new("TextLabel")
			popup.Size = UDim2.new(0, 200, 0, 50)
			popup.Position = UDim2.new(0.5, -100, 0.5, 0)
			popup.BackgroundTransparency = 1
			popup.Text = "-" .. tostring(bet) .. " 💀"
			popup.TextColor3 = Color3.fromRGB(255, 80, 80)
			popup.TextScaled = true
			popup.Font = Enum.Font.GothamBold
			popup.ZIndex = 102
			popup.Parent = playerGui:FindFirstChildOfClass("ScreenGui") or playerGui
			TweenService:Create(popup, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = UDim2.new(0.5, -100, 0.3, 0), TextTransparency = 1}):Play()
			wait(1.0); popup:Destroy()
		end
	end
end)

print("[CasinoSounds] 🔊 Dopamine sound system loaded!")
