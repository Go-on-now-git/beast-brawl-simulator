--[[
	BEAST BRAWL SIMULATOR - Game Manager
	Main game loop, enemy spawning, combat resolution, coin rewards
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GameConfig = require(game.ReplicatedStorage:WaitForChild("GameConfig"))
local PlayerData = require(game.ServerScriptService:WaitForChild("PlayerData"))
local PetSystem = require(game.ServerScriptService:WaitForChild("PetSystem"))

local GameManager = {}
GameManager.enemies = {}  -- Track active enemies
GameManager.playerCombat = {}  -- Track player combat state

-- Create enemy folder if not exists
local enemiesFolder = Workspace:FindFirstChild("Enemies")
if not enemiesFolder then
	enemiesFolder = Instance.new("Folder")
	enemiesFolder.Name = "Enemies"
	enemiesFolder.Parent = Workspace
end

-- Create an enemy instance
local function createEnemy()
	local enemy = Instance.new("Part")
	enemy.Name = "Enemy"
	enemy.Shape = Enum.PartType.Ball
	enemy.Size = Vector3.new(2, 2, 2)
	enemy.Color = Color3.fromRGB(255, 0, 0)
	enemy.CanCollide = true
	enemy.TopSurface = Enum.SurfaceType.Smooth
	enemy.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Spawn at random location
	local spawnX = math.random(-50, 50)
	local spawnZ = math.random(-50, 50)
	enemy.Position = Vector3.new(spawnX, 5, spawnZ)
	
	enemy.Parent = enemiesFolder
	
	-- Add health value to enemy
	local healthValue = Instance.new("IntValue")
	healthValue.Name = "Health"
	healthValue.Value = GameConfig.EnemyStats.health
	healthValue.Parent = enemy
	
	-- Add humanoid for consistency
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = enemy
	humanoid.MaxHealth = GameConfig.EnemyStats.health
	humanoid.Health = GameConfig.EnemyStats.health
	
	return enemy
end

-- Damage enemy
local function damageEnemy(enemy, damage)
	local health = enemy:FindFirstChild("Health")
	if health then
		health.Value = health.Value - damage
		if health.Value <= 0 then
			return true  -- Enemy defeated
		end
	end
	return false
end

-- Handle enemy defeat
local function defeatEnemy(enemy, defeatedBy)
	-- Award coins and XP
	local stats = PlayerData:GetPlayerStats(defeatedBy.UserId)
	
	-- Calculate damage multiplier
	local multiplier = PetSystem:GetPlayerMultiplier(defeatedBy.UserId)
	local coinReward = math.floor(GameConfig.CoinReward * multiplier)
	
	-- Award coins
	PlayerData:AddCoins(defeatedBy.UserId, coinReward)
	PlayerData:AddDamage(defeatedBy.UserId, math.floor(GameConfig.EnemyStats.baseDamage * multiplier))
	PlayerData:AddKill(defeatedBy.UserId)
	PlayerData:AddXP(defeatedBy.UserId, 10)
	
	-- Remove enemy
	enemy:Destroy()
	GameManager.enemies[enemy] = nil
end

-- Spawn enemies periodically
spawn(function()
	while true do
		wait(GameConfig.EnemyStats.spawnRate)
		
		local enemy = createEnemy()
		GameManager.enemies[enemy] = {
			health = GameConfig.EnemyStats.health,
			spawnTime = tick()
		}
	end
end)

-- Remove despawned enemies
spawn(function()
	while true do
		wait(5)
		
		local now = tick()
		for enemy, data in pairs(GameManager.enemies) do
			if enemy.Parent == nil or (now - data.spawnTime) > GameConfig.EnemyStats.despawnTime then
				GameManager.enemies[enemy] = nil
				if enemy.Parent then
					enemy:Destroy()
				end
			end
		end
	end
end)

-- RemoteEvent for player attack
local attackRemote = Instance.new("RemoteEvent")
attackRemote.Name = "Attack"
attackRemote.Parent = game.ReplicatedStorage

-- Handle attack requests from clients
attackRemote.OnServerEvent:Connect(function(player, enemyHit)
	if not enemyHit or enemyHit.Parent ~= enemiesFolder then
		return  -- Invalid enemy
	end
	
	-- Get player stats
	local stats = PlayerData:GetPlayerStats(player.UserId)
	
	-- Calculate damage (base + multiplier)
	local multiplier = PetSystem:GetPlayerMultiplier(player.UserId)
	local baseDamage = GameConfig.EnemyStats.baseDamage * (1 + stats.level * 0.5)
	local finalDamage = math.floor(baseDamage * multiplier)
	
	-- Deal damage
	local defeated = damageEnemy(enemyHit, finalDamage)
	
	if defeated then
		defeatEnemy(enemyHit, player)
	end
end)

-- RemoteFunction to get all enemies
local getEnemiesRemote = Instance.new("RemoteFunction")
getEnemiesRemote.Name = "GetEnemies"
getEnemiesRemote.Parent = game.ReplicatedStorage

getEnemiesRemote.OnServerInvoke = function(player)
	local enemyList = {}
	for enemy, _ in pairs(GameManager.enemies) do
		if enemy.Parent then
			table.insert(enemyList, {
				position = enemy.Position,
				health = enemy:FindFirstChild("Health").Value
			})
		end
	end
	return enemyList
end

print("Game Manager initialized - enemies spawning")

return GameManager
