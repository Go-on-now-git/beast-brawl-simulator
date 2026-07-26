-- TokenCasino.server.lua
-- Players earn ArenaTokens from fighting, gamble them at the casino
-- Games: Coin Flip, Dice Roll, Slots

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvents
local casinoFolder = Instance.new("Folder")
casinoFolder.Name = "Casino"
casinoFolder.Parent = ReplicatedStorage

local GambleEvent = Instance.new("RemoteEvent")
GambleEvent.Name = "Gamble"
GambleEvent.Parent = casinoFolder

local TokenUpdate = Instance.new("RemoteEvent")
TokenUpdate.Name = "TokenUpdate"
TokenUpdate.Parent = casinoFolder

local EarnTokens = Instance.new("RemoteEvent")
EarnTokens.Name = "EarnTokens"
EarnTokens.Parent = casinoFolder

-- Token storage (in-memory)
local playerTokens = {}

local function getTokens(userId)
	return playerTokens[userId] or 0
end

local function setTokens(userId, amount)
	playerTokens[userId] = math.max(0, math.floor(amount))
end

local function addTokens(userId, amount)
	setTokens(userId, getTokens(userId) + amount)
end

-- Give tokens when players join (starter pack)
Players.PlayerAdded:Connect(function(player)
	playerTokens[player.UserId] = 100 -- 100 starter tokens
	wait(2)
	TokenUpdate:FireClient(player, getTokens(player.UserId))
end)

Players.PlayerRemoving:Connect(function(player)
	playerTokens[player.UserId] = nil
end)

-- Earn tokens from arena kills (server fires this)
EarnTokens.OnServerEvent:Connect(function(player, amount)
	addTokens(player.UserId, amount or 10)
	TokenUpdate:FireClient(player, getTokens(player.UserId))
end)

-- GAMBLE HANDLER
GambleEvent.OnServerEvent:Connect(function(player, gameType, betAmount)
	local userId = player.UserId
	local tokens = getTokens(userId)
	betAmount = math.floor(math.abs(betAmount or 0))

	-- Validation
	if betAmount <= 0 then
		GambleEvent:FireClient(player, "error", "Bet must be > 0", tokens)
		return
	end
	if betAmount > tokens then
		GambleEvent:FireClient(player, "error", "Not enough tokens! You have " .. tokens, tokens)
		return
	end
	if betAmount > 10000 then
		betAmount = 10000 -- cap per bet
	end

	local won = false
	local multiplier = 0
	local resultText = ""

	-- COIN FLIP (50/50, 2x)
	if gameType == "coinflip" then
		local flip = math.random(1, 2)
		won = flip == 1
		multiplier = 2
		resultText = won and "🪙 HEADS! YOU WIN!" or "🪙 TAILS! YOU LOSE!"

	-- DICE ROLL (win on 4,5,6 — ~50%, 2x)
	elseif gameType == "dice" then
		local roll = math.random(1, 6)
		won = roll >= 4
		multiplier = 2
		resultText = "🎲 Rolled " .. roll .. "! " .. (won and "WIN!" or "LOSE!")

	-- SLOTS (1/6 chance, 6x payout — brain rot)
	elseif gameType == "slots" then
		local slotEmojis = {"🦁","💎","7️⃣","🔥","⭐","💀"}
		local s1 = math.random(1,6)
		local s2 = math.random(1,6)
		local s3 = math.random(1,6)
		if s1 == s2 and s2 == s3 then
			won = true
			multiplier = 10
			resultText = slotEmojis[s1].." "..slotEmojis[s2].." "..slotEmojis[s3].." JACKPOT!! 10x!!"
		elseif s1 == s2 or s2 == s3 then
			won = true
			multiplier = 2
			resultText = slotEmojis[s1].." "..slotEmojis[s2].." "..slotEmojis[s3].." 2x Pair!"
		else
			won = false
			resultText = slotEmojis[s1].." "..slotEmojis[s2].." "..slotEmojis[s3].." No match. L."
		end

	-- DOUBLE OR NOTHING (25% chance, 4x)
	elseif gameType == "double" then
		local roll = math.random(1, 4)
		won = roll == 1
		multiplier = 4
		resultText = won and "💰 4x DOUBLE UP! SIGMA WIN!" or "😂 RATIO'D. L bozo."

	else
		GambleEvent:FireClient(player, "error", "Unknown game", tokens)
		return
	end

	-- Apply result
	if won then
		addTokens(userId, betAmount * (multiplier - 1))
	else
		addTokens(userId, -betAmount)
	end

	local newTotal = getTokens(userId)
	GambleEvent:FireClient(player, won and "win" or "lose", resultText, newTotal, betAmount, multiplier)
	TokenUpdate:FireClient(player, newTotal)

	print(string.format("[Casino] %s | %s | bet:%d | %s | tokens now:%d",
		player.Name, gameType, betAmount, won and "WIN" or "LOSE", newTotal))
end)

print("[TokenCasino] 🎰 Casino server ready — coin flip, dice, slots, double-or-nothing")
