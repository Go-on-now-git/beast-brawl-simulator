--[[
	BEAST BRAWL SIMULATOR - Player Data Management
	Handles DataStore save/load and player statistics tracking
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local GameConfig = require(game.ReplicatedStorage:WaitForChild("GameConfig"))

local PlayerData = {}
PlayerData.playerStats = {}  -- In-memory cache: {playerId -> playerData}

-- Initialize DataStore
local playerDataStore = DataStoreService:GetDataStore(GameConfig.PlayerDataStoreName)

-- Default player data structure
local function getDefaultPlayerData()
	return {
		coins = 0,
		pets = {},  -- {rarity, level} entries
		level = 1,
		xp = 0,
		rebirths = 0,
		totalDamage = 0,
		kills = 0,
		lastSaved = tick()
	}
end

-- Load player data from DataStore
function PlayerData:LoadPlayerData(userId)
	local success, data = pcall(function()
		return playerDataStore:GetAsync("Player_" .. userId)
	end)
	
	if success then
		if data then
			return data
		else
			return getDefaultPlayerData()
		end
	else
		warn("Failed to load data for player " .. userId .. ": " .. tostring(data))
		return getDefaultPlayerData()
	end
end

-- Save player data to DataStore
function PlayerData:SavePlayerData(userId, data)
	data.lastSaved = tick()
	
	local success, err = pcall(function()
		playerDataStore:SetAsync("Player_" .. userId, data)
	end)
	
	if not success then
		warn("Failed to save data for player " .. userId .. ": " .. tostring(err))
	end
end

-- Get player stats (from in-memory cache)
function PlayerData:GetPlayerStats(userId)
	return self.playerStats[userId] or getDefaultPlayerData()
end

-- Update player coins
function PlayerData:AddCoins(userId, amount)
	if not self.playerStats[userId] then return end
	self.playerStats[userId].coins = self.playerStats[userId].coins + amount
end

-- Update total damage
function PlayerData:AddDamage(userId, amount)
	if not self.playerStats[userId] then return end
	self.playerStats[userId].totalDamage = self.playerStats[userId].totalDamage + amount
end

-- Increment kills
function PlayerData:AddKill(userId)
	if not self.playerStats[userId] then return end
	self.playerStats[userId].kills = self.playerStats[userId].kills + 1
end

-- Add XP and level up
function PlayerData:AddXP(userId, amount)
	if not self.playerStats[userId] then return end
	
	local stats = self.playerStats[userId]
	stats.xp = stats.xp + amount
	
	-- Check for level up
	local totalXPNeeded = 0
	for i = 1, stats.level - 1 do
		totalXPNeeded = totalXPNeeded + (GameConfig.LevelXPThresholds[i] or 10000)
	end
	
	while stats.xp >= (GameConfig.LevelXPThresholds[stats.level] or 10000) do
		stats.xp = stats.xp - (GameConfig.LevelXPThresholds[stats.level] or 10000)
		stats.level = stats.level + 1
		-- Emit level up event
		game.ReplicatedStorage:FindFirstChild("LevelUp"):FireClient(game.Players:FindFirstChild(userId), stats.level)
	end
end

-- Add pet to player
function PlayerData:AddPet(userId, rarity)
	if not self.playerStats[userId] then return end
	
	local pet = {
		rarity = rarity,
		level = 1
	}
	table.insert(self.playerStats[userId].pets, pet)
	return pet
end

-- Get pet damage multiplier
function PlayerData:GetPetMultiplier(userId)
	if not self.playerStats[userId] or #self.playerStats[userId].pets == 0 then
		return 1
	end
	
	local multiplier = 1
	for _, pet in ipairs(self.playerStats[userId].pets) do
		local rarityData = GameConfig.PetRarities[pet.rarity]
		if rarityData then
			multiplier = multiplier * rarityData.multiplier
		end
	end
	return multiplier
end

-- Handle rebirth
function PlayerData:Rebirth(userId)
	if not self.playerStats[userId] then return false end
	
	local stats = self.playerStats[userId]
	
	-- Check if player has enough coins
	if stats.coins < GameConfig.RebirthCost then
		return false
	end
	
	-- Deduct coins and increase rebirth count
	stats.coins = stats.coins - GameConfig.RebirthCost
	stats.rebirths = stats.rebirths + 1
	
	-- Reset but keep rebirths
	local rebirths = stats.rebirths
	stats = getDefaultPlayerData()
	stats.rebirths = rebirths
	
	self.playerStats[userId] = stats
	return true
end

-- Handle player join
Players.PlayerAdded:Connect(function(player)
	local userId = player.UserId
	
	-- Load data from DataStore
	local data = PlayerData:LoadPlayerData(userId)
	PlayerData.playerStats[userId] = data
	
	print("Loaded data for player: " .. player.Name .. " (ID: " .. userId .. ")")
end)

-- Handle player leave (autosave)
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	
	if PlayerData.playerStats[userId] then
		PlayerData:SavePlayerData(userId, PlayerData.playerStats[userId])
		PlayerData.playerStats[userId] = nil
		print("Saved and removed player data: " .. player.Name)
	end
end)

-- Autosave every 30 seconds
game:GetService("RunService").Heartbeat:Connect(function()
	local now = tick()
	for userId, stats in pairs(PlayerData.playerStats) do
		if now - stats.lastSaved > 30 then
			PlayerData:SavePlayerData(userId, stats)
		end
	end
end)

return PlayerData
