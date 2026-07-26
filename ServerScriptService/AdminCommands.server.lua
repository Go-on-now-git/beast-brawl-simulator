--[[
	BEAST BRAWL SIMULATOR - Admin Commands
	Admin command system with security checks
]]

local Players = game:GetService("Players")
local GameConfig = require(game.ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(game.ServerScriptService:WaitForChild("PlayerData"))
local PetSystem = require(game.ServerScriptService:WaitForChild("PetSystem"))

local AdminCommands = {}

-- Check if player is admin
local function isAdmin(userId)
	for _, adminId in ipairs(GameConfig.AdminUserIds) do
		if adminId == userId then
			return true
		end
	end
	return false
end

-- Parse admin command
local function parseCommand(message)
	local parts = {}
	for part in message:gmatch("%S+") do
		table.insert(parts, part)
	end
	return parts
end

-- Execute admin commands
local function executeCommand(player, commandParts)
	if #commandParts == 0 then return end
	
	local command = string.lower(commandParts[1])
	
	-- :give [player] [coins/pets] [amount]
	if command == ":give" then
		if #commandParts < 4 then
			player:Kick("Usage: :give [player] [coins/pets] [amount]")
			return
		end
		
		local targetName = commandParts[2]
		local giveType = string.lower(commandParts[3])
		local amount = tonumber(commandParts[4])
		
		local target = Players:FindFirstChild(targetName)
		if not target then
			player:Kick("Player not found: " .. targetName)
			return
		end
		
		if giveType == "coins" then
			PlayerData:AddCoins(target.UserId, amount)
			print("[ADMIN] " .. player.Name .. " gave " .. amount .. " coins to " .. target.Name)
		elseif giveType == "pets" then
			for _ = 1, amount do
				PetSystem:GivePet(target.UserId, "Legendary")
			end
			print("[ADMIN] " .. player.Name .. " gave " .. amount .. " Legendary pets to " .. target.Name)
		end
		return
	end
	
	-- :god [player] (make invincible)
	if command == ":god" then
		if #commandParts < 2 then
			player:Kick("Usage: :god [player]")
			return
		end
		
		local targetName = commandParts[2]
		local target = Players:FindFirstChild(targetName)
		if not target then
			player:Kick("Player not found: " .. targetName)
			return
		end
		
		-- Give massive health/damage boost
		local stats = PlayerData:GetPlayerStats(target.UserId)
		stats.level = 999
		print("[ADMIN] " .. player.Name .. " made " .. target.Name .. " god mode")
		return
	end
	
	-- :kick [player]
	if command == ":kick" then
		if #commandParts < 2 then
			player:Kick("Usage: :kick [player]")
			return
		end
		
		local targetName = commandParts[2]
		local target = Players:FindFirstChild(targetName)
		if not target then
			player:Kick("Player not found: " .. targetName)
			return
		end
		
		target:Kick("Kicked by admin: " .. player.Name)
		print("[ADMIN] " .. player.Name .. " kicked " .. target.Name)
		return
	end
	
	-- :speed [player] [number]
	if command == ":speed" then
		if #commandParts < 3 then
			player:Kick("Usage: :speed [player] [num]")
			return
		end
		
		local targetName = commandParts[2]
		local speed = tonumber(commandParts[3]) or 16
		
		local target = Players:FindFirstChild(targetName)
		if not target or not target.Character then
			player:Kick("Player not found: " .. targetName)
			return
		end
		
		-- Set humanoid walk speed
		local humanoid = target.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = speed
		end
		print("[ADMIN] " .. player.Name .. " set " .. target.Name .. " speed to " .. speed)
		return
	end
	
	-- :tp [player] (teleport to admin)
	if command == ":tp" then
		if #commandParts < 2 then
			player:Kick("Usage: :tp [player]")
			return
		end
		
		local targetName = commandParts[2]
		local target = Players:FindFirstChild(targetName)
		if not target or not target.Character then
			player:Kick("Player not found: " .. targetName)
			return
		end
		
		-- Teleport player to admin
		if player.Character and target.Character then
			target.Character:MoveTo(player.Character.PrimaryPart.Position + Vector3.new(5, 0, 0))
		end
		print("[ADMIN] " .. player.Name .. " teleported " .. target.Name)
		return
	end
	
	-- :rejoin [player]
	if command == ":rejoin" then
		if #commandParts < 2 then
			player:Kick("Usage: :rejoin [player]")
			return
		end
		
		local targetName = commandParts[2]
		local target = Players:FindFirstChild(targetName)
		if not target then
			player:Kick("Player not found: " .. targetName)
			return
		end
		
		target:Kick("You have been asked to rejoin. Please rejoin the game.")
		print("[ADMIN] " .. player.Name .. " told " .. target.Name .. " to rejoin")
		return
	end
end

-- Chat handler
Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	-- Create stat values
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats
	
	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = 1
	level.Parent = leaderstats
	
	local kills = Instance.new("IntValue")
	kills.Name = "Kills"
	kills.Value = 0
	kills.Parent = leaderstats
	
	-- Update leaderstats when data changes
	game:GetService("RunService").Heartbeat:Connect(function()
		local stats = PlayerData:GetPlayerStats(player.UserId)
		coins.Value = stats.coins
		level.Value = stats.level
		kills.Value = stats.kills
	end)
end)

-- Admin command chat detection
Players.PlayerAdded:Connect(function(player)
	if isAdmin(player.UserId) then
		print("[ADMIN] Admin player joined: " .. player.Name .. " (ID: " .. player.UserId .. ")")
		
		-- Listen for chat with admin prefix
		local chatRemote = Instance.new("RemoteEvent")
		chatRemote.Name = "AdminChat"
		chatRemote.Parent = game.ReplicatedStorage
		
		chatRemote.OnServerEvent:Connect(function(p, message)
			if p.UserId == player.UserId and message:sub(1, 1) == ":" then
				local commandParts = parseCommand(message)
				executeCommand(player, commandParts)
			end
		end)
	end
end)

print("Admin Commands initialized")

return AdminCommands
