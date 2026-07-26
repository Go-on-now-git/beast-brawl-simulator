--[[
	BEAST BRAWL SIMULATOR - Pet System
	Handles RNG pet machine, pet assignment, and damage multipliers
]]

local Players = game:GetService("Players")
local GameConfig = require(game.ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(game.ServerScriptService:WaitForChild("PlayerData"))

local PetSystem = {}

-- RemoteEvent for spinning the pet machine (client -> server)
local spinPetRemote = Instance.new("RemoteEvent")
spinPetRemote.Name = "SpinPet"
spinPetRemote.Parent = game.ReplicatedStorage

-- RemoteEvent for displaying pet spin result (server -> client)
local petSpinResultRemote = Instance.new("RemoteFunction")
petSpinResultRemote.Name = "PetSpinResult"
petSpinResultRemote.Parent = game.ReplicatedStorage

-- Weighted random pet selection
local function getWeightedRarity()
	local roll = math.random(1, 100)
	local cumulative = 0
	
	for _, rarityName in ipairs(GameConfig.PetRarityList) do
		local rarity = GameConfig.PetRarities[rarityName]
		cumulative = cumulative + rarity.weight
		
		if roll <= cumulative then
			return rarityName
		end
	end
	
	return "Common"  -- Fallback
end

-- Spin the pet machine
local function spinPet(player)
	local userId = player.UserId
	local stats = PlayerData:GetPlayerStats(userId)
	
	-- Free spins are available (no cost)
	-- Add 10 coins per spin if desired, or make it truly free
	
	-- Get random pet
	local rarity = getWeightedRarity()
	
	-- Add pet to player
	PlayerData:AddPet(userId, rarity)
	
	-- Get rarity color and info
	local rarityData = GameConfig.PetRarities[rarity]
	
	-- Send result to client
	return {
		rarity = rarity,
		displayName = rarityData.displayName,
		color = rarityData.color,
		multiplier = rarityData.multiplier,
		petsCount = #stats.pets + 1
	}
end

-- Handle spin pet requests
spinPetRemote.OnServerEvent:Connect(function(player)
	local result = spinPet(player)
	petSpinResultRemote:InvokeClient(player, result)
end)

-- Get current pet multiplier for a player
function PetSystem:GetPlayerMultiplier(userId)
	return PlayerData:GetPetMultiplier(userId)
end

-- Get player's pets
function PetSystem:GetPlayerPets(userId)
	local stats = PlayerData:GetPlayerStats(userId)
	return stats.pets or {}
end

-- Test function: add free pet to player (for testing)
function PetSystem:GivePet(userId, rarity)
	local player = Players:FindFirstChild(tostring(userId))
	if player then
		return PlayerData:AddPet(userId, rarity)
	end
	return nil
end

-- Initialize pet system on game start
print("Pet System initialized")

return PetSystem
