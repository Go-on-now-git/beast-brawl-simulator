-- ShopSystem.server.lua
-- Weapons, Armor, and Robux → Token purchases

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Developer Product IDs for Robux → Tokens (set these in Creator Dashboard)
-- Dashboard: Create > Monetization > Developer Products
local ROBUX_PRODUCTS = {
	[0000000001] = {tokens = 500,   label = "500 Tokens"},   -- Replace IDs!
	[0000000002] = {tokens = 1200,  label = "1,200 Tokens"},
	[0000000003] = {tokens = 3000,  label = "3,000 Tokens"},
	[0000000004] = {tokens = 8000,  label = "8,000 Tokens"},
	[0000000005] = {tokens = 25000, label = "25,000 Tokens"},
}

-- Weapon definitions
local WEAPONS = {
	{id="fists",     name="👊 Fists",       cost=0,     damage=1.0,  speed=1.0,  desc="Default. Free.",         owned=true},
	{id="sword",     name="⚔️ Iron Sword",  cost=200,   damage=1.8,  speed=1.1,  desc="Slash damage +80%"},
	{id="axe",       name="🪓 War Axe",     cost=500,   damage=2.5,  speed=0.9,  desc="Massive damage, slow"},
	{id="katana",    name="🗡️ Katana",      cost=900,   damage=2.2,  speed=1.5,  desc="Fast slashes, anime"},
	{id="scythe",    name="💀 Death Scythe",cost=1800,  damage=3.5,  speed=1.2,  desc="Sigma weapon fr fr"},
	{id="laser",     name="⚡ Laser Gun",   cost=3500,  damage=4.0,  speed=1.8,  desc="Pew pew no cap"},
	{id="celestial", name="🌟 Celestial Blade",cost=10000,damage=8.0,speed=2.0, desc="Legendary. Bussin."},
}

-- Armor definitions
local ARMORS = {
	{id="none",     name="👕 No Armor",     cost=0,    defense=0,   speed=1.0,  desc="Default. Risky.",  owned=true},
	{id="leather",  name="🥋 Leather",      cost=150,  defense=0.1, speed=1.0,  desc="10% damage reduction"},
	{id="chain",    name="⛓️ Chainmail",    cost=400,  defense=0.2, speed=0.95, desc="20% reduction"},
	{id="iron",     name="🛡️ Iron Armor",   cost=800,  defense=0.3, speed=0.9,  desc="30% reduction"},
	{id="gold",     name="✨ Gold Armor",   cost=1500, defense=0.4, speed=0.88, desc="Flexing AND tanky"},
	{id="shadow",   name="🌑 Shadow Cloak", cost=3000, defense=0.45,speed=1.1,  desc="Fast AND protected"},
	{id="celestial",name="🌟 Celestial",   cost=9000, defense=0.6, speed=1.05, desc="God tier. No cap."},
}

-- Player equipment state
local playerEquipment = {}
local playerOwnedItems = {}

local function getEquipment(userId)
	if not playerEquipment[userId] then
		playerEquipment[userId] = {weapon = "fists", armor = "none"}
	end
	return playerEquipment[userId]
end

local function getOwned(userId)
	if not playerOwnedItems[userId] then
		playerOwnedItems[userId] = {weapons = {fists=true}, armors = {none=true}}
	end
	return playerOwnedItems[userId]
end

-- Shop folder in ReplicatedStorage
local shopFolder = Instance.new("Folder")
shopFolder.Name = "Shop"
shopFolder.Parent = ReplicatedStorage

local BuyItem = Instance.new("RemoteEvent")
BuyItem.Name = "BuyItem"
BuyItem.Parent = shopFolder

local EquipItem = Instance.new("RemoteEvent")
EquipItem.Name = "EquipItem"
EquipItem.Parent = shopFolder

local ShopResult = Instance.new("RemoteEvent")
ShopResult.Name = "ShopResult"
ShopResult.Parent = shopFolder

local GetShopData = Instance.new("RemoteFunction")
GetShopData.Name = "GetShopData"
GetShopData.Parent = shopFolder

local GetEquipment = Instance.new("RemoteFunction")
GetEquipment.Name = "GetEquipment"
GetEquipment.Parent = shopFolder

-- Get casino tokens (from TokenCasino module)
local function getTokens(userId)
	local casinoFolder = ReplicatedStorage:FindFirstChild("Casino")
	-- Tokens stored in TokenCasino — use shared table via _G (simple approach)
	return _G.playerTokens and _G.playerTokens[userId] or 0
end

local function spendTokens(userId, amount)
	if not _G.playerTokens then _G.playerTokens = {} end
	local current = _G.playerTokens[userId] or 0
	if current < amount then return false end
	_G.playerTokens[userId] = current - amount
	-- Fire token update
	local player = Players:GetPlayerByUserId(userId)
	if player then
		local casinoF = ReplicatedStorage:FindFirstChild("Casino")
		if casinoF then
			local tu = casinoF:FindFirstChild("TokenUpdate")
			if tu then tu:FireClient(player, _G.playerTokens[userId]) end
		end
	end
	return true
end

-- BUY item handler
BuyItem.OnServerEvent:Connect(function(player, itemType, itemId)
	local userId = player.UserId
	local owned = getOwned(userId)
	local items = itemType == "weapon" and WEAPONS or ARMORS
	local ownedCat = itemType == "weapon" and owned.weapons or owned.armors

	-- Find item
	local item
	for _, w in ipairs(items) do
		if w.id == itemId then item = w; break end
	end
	if not item then
		ShopResult:FireClient(player, false, "Item not found")
		return
	end
	if ownedCat[itemId] then
		ShopResult:FireClient(player, false, "Already owned!")
		return
	end
	if not spendTokens(userId, item.cost) then
		ShopResult:FireClient(player, false, "Not enough tokens! Need " .. item.cost)
		return
	end

	ownedCat[itemId] = true
	ShopResult:FireClient(player, true, "Bought " .. item.name .. "!", itemType, itemId)
	print(string.format("[Shop] %s bought %s %s", player.Name, itemType, itemId))
end)

-- EQUIP item handler
EquipItem.OnServerEvent:Connect(function(player, itemType, itemId)
	local userId = player.UserId
	local owned = getOwned(userId)
	local ownedCat = itemType == "weapon" and owned.weapons or owned.armors

	if not ownedCat[itemId] then
		ShopResult:FireClient(player, false, "You don't own that!")
		return
	end

	local equip = getEquipment(userId)
	if itemType == "weapon" then equip.weapon = itemId
	else equip.armor = itemId end

	ShopResult:FireClient(player, true, "Equipped!", itemType, itemId)
end)

-- GetShopData function
GetShopData.OnServerInvoke = function(player)
	return {weapons = WEAPONS, armors = ARMORS}
end

GetEquipment.OnServerInvoke = function(player)
	local owned = getOwned(player.UserId)
	local equip = getEquipment(player.UserId)
	return {owned = owned, equipped = equip}
end

-- ROBUX → TOKENS via Developer Products
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local product = ROBUX_PRODUCTS[receiptInfo.ProductId]
	if not product then return Enum.ProductPurchaseDecision.NotProcessedYet end

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

	-- Give tokens
	if not _G.playerTokens then _G.playerTokens = {} end
	_G.playerTokens[player.UserId] = (_G.playerTokens[player.UserId] or 0) + product.tokens

	-- Notify player
	local casinoF = ReplicatedStorage:FindFirstChild("Casino")
	if casinoF then
		local tu = casinoF:FindFirstChild("TokenUpdate")
		if tu then tu:FireClient(player, _G.playerTokens[player.UserId]) end
	end

	ShopResult:FireClient(player, true, "💰 +" .. product.tokens .. " Tokens added! Thanks! 🦁")
	print(string.format("[Shop] %s purchased %s tokens via Robux", player.Name, product.tokens))
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Init tokens shared table
Players.PlayerAdded:Connect(function(player)
	if not _G.playerTokens then _G.playerTokens = {} end
	_G.playerTokens[player.UserId] = (_G.playerTokens[player.UserId] or 0) + 100
end)

Players.PlayerRemoving:Connect(function(player)
	playerEquipment[player.UserId] = nil
	playerOwnedItems[player.UserId] = nil
end)

print("[ShopSystem] ⚔️ Weapon & Armor shop + Robux purchases ready!")
