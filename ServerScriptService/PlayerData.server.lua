-- PlayerData.server.lua — Persistent stats across sessions
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local db = DataStoreService:GetDataStore("BeastBrawl_v3")
local spendDb = DataStoreService:GetOrderedDataStore("BeastBrawl_TopSpenders")
local fightDb = DataStoreService:GetOrderedDataStore("BeastBrawl_TopFighters")

local statsFolder = Instance.new("Folder")
statsFolder.Name = "PlayerStats"
statsFolder.Parent = ReplicatedStorage

local GetStats   = Instance.new("RemoteFunction"); GetStats.Name = "GetStats";     GetStats.Parent = statsFolder
local UpdateStats = Instance.new("RemoteEvent");   UpdateStats.Name = "UpdateStats"; UpdateStats.Parent = statsFolder
local GetLB      = Instance.new("RemoteFunction"); GetLB.Name = "GetLeaderboard";  GetLB.Parent = statsFolder

local cache = {}

local function defaultData()
	return {tokens=100, kills=0, deaths=0, damage=0, tokensSpent=0, wins=0, losses=0, weapon="fists", armor="none", ownedWeapons={fists=true}, ownedArmors={none=true}}
end

local function load(player)
	local ok, data = pcall(function() return db:GetAsync("p_"..player.UserId) end)
	cache[player.UserId] = (ok and data) and data or defaultData()
	if not _G.playerTokens then _G.playerTokens = {} end
	_G.playerTokens[player.UserId] = cache[player.UserId].tokens
	UpdateStats:FireClient(player, cache[player.UserId])
end

local function save(player)
	local data = cache[player.UserId]
	if not data then return end
	data.tokens = _G.playerTokens and _G.playerTokens[player.UserId] or data.tokens
	pcall(function() db:SetAsync("p_"..player.UserId, data) end)
	pcall(function() spendDb:SetAsync("p_"..player.UserId, math.floor(data.tokensSpent or 0)) end)
	pcall(function() fightDb:SetAsync("p_"..player.UserId, math.floor(data.kills or 0)) end)
end

GetStats.OnServerInvoke = function(player) return cache[player.UserId] or defaultData() end

GetLB.OnServerInvoke = function(player, lbType)
	local store = lbType == "spenders" and spendDb or fightDb
	local ok, pages = pcall(function()
		return store:GetSortedAsync(false, 10)
	end)
	if not ok then return {} end
	local items = pages:GetCurrentPage()
	local result = {}
	for rank, entry in ipairs(items) do
		local name = "Player"
		pcall(function()
			name = game:GetService("Players"):GetNameFromUserIdAsync(tonumber(entry.key:sub(3)))
		end)
		table.insert(result, {rank=rank, name=name, value=entry.value})
	end
	return result
end

Players.PlayerAdded:Connect(function(p)
	load(p)
	-- Auto-save every 60s
	spawn(function()
		while p and p.Parent do wait(60); save(p) end
	end)
end)

Players.PlayerRemoving:Connect(function(p) save(p) end)
game:BindToClose(function() for _, p in ipairs(Players:GetPlayers()) do save(p) end end)

-- Expose cache for other scripts
_G.playerCache = cache
print("[PlayerData] 💾 Persistent stats + leaderboard ready!")
