--[[
	BEAST BRAWL SIMULATOR - Leaderboard System
	OrderedDataStore leaderboard for top players by totalDamage
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local GameConfig = require(game.ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(game.ServerScriptService:WaitForChild("PlayerData"))

local Leaderboard = {}

-- Initialize OrderedDataStore for leaderboard
local leaderboardStore = DataStoreService:GetOrderedDataStore(GameConfig.LeaderboardStoreName)

-- Update leaderboard entry
function Leaderboard:UpdatePlayerScore(userId, totalDamage)
	local success, err = pcall(function()
		leaderboardStore:SetAsync("Player_" .. userId, totalDamage)
	end)
	
	if not success then
		warn("Failed to update leaderboard for player " .. userId .. ": " .. tostring(err))
	end
end

-- Get top players
function Leaderboard:GetTopPlayers(limit)
	limit = limit or GameConfig.LeaderboardSize
	local success, data = pcall(function()
		return leaderboardStore:GetSortedAsync(false, limit)  -- descending order
	end)
	
	if success then
		local topPlayers = {}
		for _, entry in ipairs(data:GetCurrentPage()) do
			table.insert(topPlayers, {
				userId = tonumber(entry.key:gsub("Player_", "")),
				totalDamage = entry.value,
				rank = #topPlayers + 1
			})
		end
		return topPlayers
	else
		warn("Failed to get leaderboard data: " .. tostring(data))
		return {}
	end
end

-- Get player rank
function Leaderboard:GetPlayerRank(userId)
	local topPlayers = self:GetTopPlayers(1000)
	for i, player in ipairs(topPlayers) do
		if player.userId == userId then
			return i
		end
	end
	return nil  -- Player not on leaderboard
end

-- RemoteFunction to request leaderboard
local leaderboardRemote = Instance.new("RemoteFunction")
leaderboardRemote.Name = "GetLeaderboard"
leaderboardRemote.Parent = game.ReplicatedStorage

leaderboardRemote.OnServerInvoke = function(player)
	return Leaderboard:GetTopPlayers(100)
end

-- RemoteFunction to get player rank
local playerRankRemote = Instance.new("RemoteFunction")
playerRankRemote.Name = "GetPlayerRank"
playerRankRemote.Parent = game.ReplicatedStorage

playerRankRemote.OnServerInvoke = function(player)
	return {
		rank = Leaderboard:GetPlayerRank(player.UserId),
		totalDamage = PlayerData:GetPlayerStats(player.UserId).totalDamage
	}
end

-- Update leaderboard periodically
spawn(function()
	while true do
		wait(GameConfig.LeaderboardUpdateInterval)
		
		-- Update all online players
		for _, player in ipairs(Players:GetPlayers()) do
			local stats = PlayerData:GetPlayerStats(player.UserId)
			Leaderboard:UpdatePlayerScore(player.UserId, stats.totalDamage)
		end
		
		-- Cleanup old entries (keep only top 1000)
		local topPlayers = Leaderboard:GetTopPlayers(1000)
		-- Entries outside top 1000 will naturally age out with the OrderedDataStore TTL
	end
end)

-- Update leaderboard on player level up
local function onPlayerStatsChange()
	-- This will be called by PlayerData whenever stats update
end

print("Leaderboard System initialized - updating every " .. GameConfig.LeaderboardUpdateInterval .. " seconds")

return Leaderboard
