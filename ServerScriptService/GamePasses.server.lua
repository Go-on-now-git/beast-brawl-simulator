--[[
	BEAST BRAWL SIMULATOR - Game Pass System
	MarketplaceService integration for VIP, AutoCollect, StarterPack
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local GameConfig = require(game.ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(game.ServerScriptService:WaitForChild("PlayerData"))
local PetSystem = require(game.ServerScriptService:WaitForChild("PetSystem"))

local GamePasses = {}
GamePasses.playerPasses = {}  -- Track owned passes: {userId -> {VIP, AutoCollect, StarterPack}}

-- Check if player owns a game pass
function GamePasses:PlayerOwnsPass(userId, passName)
	local passId = GameConfig.GamePassIds[passName]
	
	-- Return false if pass ID is placeholder (0)
	if passId == 0 then
		return false
	end
	
	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, passId)
	end)
	
	if success then
		return owns
	else
		warn("Failed to check game pass ownership for " .. userId .. ": " .. tostring(owns))
		return false
	end
end

-- Handle game pass purchase
local function onGamePassPurchased(player, passName)
	local userId = player.UserId
	
	if passName == "VIP" then
		-- Give VIP benefits: 2x coins, exclusive pet, daily bonus
		print("[GAMEPASS] " .. player.Name .. " purchased VIP")
		-- VIP multiplier is handled in client UI
		
	elseif passName == "AutoCollect" then
		-- Pets auto-fight without player
		print("[GAMEPASS] " .. player.Name .. " purchased AutoCollect")
		-- AutoCollect logic handled in combat client
		
	elseif passName == "StarterPack" then
		-- 1000 coins + rare pet on first purchase
		PlayerData:AddCoins(userId, 1000)
		PetSystem:GivePet(userId, "Rare")
		print("[GAMEPASS] " .. player.Name .. " purchased StarterPack - gave 1000 coins + rare pet")
	end
end

-- RemoteEvent for game pass purchase requests
local purchasePassRemote = Instance.new("RemoteEvent")
purchasePassRemote.Name = "PurchaseGamePass"
purchasePassRemote.Parent = game.ReplicatedStorage

purchasePassRemote.OnServerEvent:Connect(function(player, passName)
	if GameConfig.GamePassIds[passName] == 0 then
		player:Kick("Game pass ID not configured: " .. passName)
		return
	end
	
	-- Trigger purchase prompt on client (client handles actual purchase)
	print("Purchase requested for: " .. passName .. " by " .. player.Name)
end)

-- Handle player join - cache their owned passes
Players.PlayerAdded:Connect(function(player)
	local userId = player.UserId
	GamePasses.playerPasses[userId] = {}
	
	-- Check all passes asynchronously
	for passName, passId in pairs(GameConfig.GamePassIds) do
		if passId ~= 0 then  -- Skip placeholder IDs
			task.spawn(function()
				if GamePasses:PlayerOwnsPass(userId, passName) then
					GamePasses.playerPasses[userId][passName] = true
					onGamePassPurchased(player, passName)
				end
			end)
		end
	end
end)

-- Listen for purchase prompts
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(userId, gamePassId, purchased)
	local player = Players:GetUserIdFromCharacter(userId) and Players:FindFirstChild(tostring(userId))
	if not player then return end
	
	if purchased then
		-- Determine which pass was purchased
		for passName, passId in pairs(GameConfig.GamePassIds) do
			if passId == gamePassId then
				onGamePassPurchased(player, passName)
				break
			end
		end
	end
end)

-- RemoteFunction to check pass ownership
local checkPassRemote = Instance.new("RemoteFunction")
checkPassRemote.Name = "CheckGamePass"
checkPassRemote.Parent = game.ReplicatedStorage

checkPassRemote.OnServerInvoke = function(player, passName)
	return GamePasses:PlayerOwnsPass(player.UserId, passName)
end

-- Get VIP multiplier
function GamePasses:GetVIPMultiplier(userId)
	if GamePasses:PlayerOwnsPass(userId, "VIP") then
		return 2  -- 2x coins
	end
	return 1
end

print("Game Pass System initialized")

return GamePasses
