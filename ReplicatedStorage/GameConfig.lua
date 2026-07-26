--[[
	BEAST BRAWL SIMULATOR - Game Configuration
	Central config for pets, enemies, progression, and game passes
]]

local GameConfig = {}

-- PET RARITY TABLE
-- Format: {name, weight (out of 100), multiplier, color}
GameConfig.PetRarities = {
	Common = {
		weight = 50,
		multiplier = 1.1,
		color = Color3.fromRGB(100, 100, 100),  -- Gray
		displayName = "Common"
	},
	Uncommon = {
		weight = 25,
		multiplier = 1.3,
		color = Color3.fromRGB(0, 255, 0),  -- Green
		displayName = "Uncommon"
	},
	Rare = {
		weight = 15,
		multiplier = 1.8,
		color = Color3.fromRGB(0, 100, 255),  -- Blue
		displayName = "Rare"
	},
	Epic = {
		weight = 8,
		multiplier = 2.5,
		color = Color3.fromRGB(200, 0, 255),  -- Purple
		displayName = "Epic"
	},
	Legendary = {
		weight = 2,
		multiplier = 5,
		color = Color3.fromRGB(255, 200, 0),  -- Gold
		displayName = "Legendary"
	}
}

-- Ordered list for weighted random selection
GameConfig.PetRarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary"}

-- ENEMY CONFIGURATION
GameConfig.EnemyStats = {
	health = 50,
	baseDamage = 5,
	spawnRate = 5,  -- Spawn every 5 seconds
	despawnTime = 300  -- 5 minutes
}

-- LEVEL PROGRESSION
GameConfig.LevelXPThresholds = {
	10, 25, 50, 100, 200, 400, 800, 1600, 3200, 6400  -- XP needed for levels 2-11
	-- Continue pattern: each level doubles
}
GameConfig.LevelUpStatPoints = 5  -- Points awarded per level

-- REBIRTH SYSTEM
GameConfig.RebirthCost = 10000  -- Coins needed to rebirth
GameConfig.RebirthMultiplier = 1.2  -- Multiplier per rebirth

-- GAME PASS IDs (Replace 0 with actual game pass IDs after creating them)
GameConfig.GamePassIds = {
	VIP = 0,           -- 2x coins, exclusive pet, daily bonus
	AutoCollect = 0,   -- Pets auto-fight without player
	StarterPack = 0    -- 1000 coins + rare pet on first purchase
}

-- ADMIN USER IDs (Replace 0 with actual admin UserId)
GameConfig.AdminUserIds = {
	11354660659   -- Tremston (sole admin)
}

-- COIN REWARDS
GameConfig.CoinReward = 10  -- Base coin per enemy defeated
GameConfig.BossReward = 100  -- Bonus for defeating boss enemy

-- LEADERBOARD
GameConfig.LeaderboardUpdateInterval = 60  -- Update every 60 seconds
GameConfig.LeaderboardSize = 100  -- Top 100 players

-- PET DAMAGE SCALING
GameConfig.PetDamagePerLevel = 0.5  -- Additional multiplier per pet level

-- DATASTORE NAMES
GameConfig.PlayerDataStoreName = "BeastBrawl_PlayerData"
GameConfig.LeaderboardStoreName = "BeastBrawl_Leaderboard"

return GameConfig
