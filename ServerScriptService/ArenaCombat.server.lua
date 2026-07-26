-- ArenaCombat.server.lua
-- Arena betting, attack/block, coin splatter on hit

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local combatFolder = Instance.new("Folder")
combatFolder.Name = "ArenaCombat"
combatFolder.Parent = ReplicatedStorage

local AttackEvent    = Instance.new("RemoteEvent"); AttackEvent.Name = "Attack";     AttackEvent.Parent = combatFolder
local BlockEvent     = Instance.new("RemoteEvent"); BlockEvent.Name = "Block";       BlockEvent.Parent = combatFolder
local HitEvent       = Instance.new("RemoteEvent"); HitEvent.Name = "Hit";           HitEvent.Parent = combatFolder
local BetEvent       = Instance.new("RemoteEvent"); BetEvent.Name = "PlaceBet";      BetEvent.Parent = combatFolder
local BetResult      = Instance.new("RemoteEvent"); BetResult.Name = "BetResult";    BetResult.Parent = combatFolder
local CoinSplatter   = Instance.new("RemoteEvent"); CoinSplatter.Name = "CoinSplatter"; CoinSplatter.Parent = combatFolder
local ArenaUpdate    = Instance.new("RemoteEvent"); ArenaUpdate.Name = "ArenaUpdate"; ArenaUpdate.Parent = combatFolder

-- Player state
local blocking = {}
local cooldowns = {}
local arenaBets = {} -- {challenger=userId, opponent=userId, amount=n, accepted=false}

local ATTACK_COOLDOWN = 0.4
local BASE_DAMAGE = 15
local BLOCK_REDUCTION = 0.65
local HIT_COIN_LOSS = 10 -- coins lost per hit from enemy

local function getTokens(userId)
	if not _G.playerTokens then _G.playerTokens = {} end
	return _G.playerTokens[userId] or 0
end
local function addTokens(userId, amount)
	if not _G.playerTokens then _G.playerTokens = {} end
	_G.playerTokens[userId] = math.max(0, ((_G.playerTokens[userId] or 0) + amount))
	local p = Players:GetPlayerByUserId(userId)
	if p then
		local cf = ReplicatedStorage:FindFirstChild("Casino")
		if cf then
			local tu = cf:FindFirstChild("TokenUpdate")
			if tu then tu:FireClient(p, _G.playerTokens[userId]) end
		end
	end
end

-- BLOCK toggle
BlockEvent.OnServerEvent:Connect(function(player, isBlocking)
	blocking[player.UserId] = isBlocking
end)

-- ATTACK handler
AttackEvent.OnServerEvent:Connect(function(attacker, targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local aId = attacker.UserId

	-- Cooldown check
	if cooldowns[aId] and (tick() - cooldowns[aId]) < ATTACK_COOLDOWN then return end
	cooldowns[aId] = tick()

	local attackerChar = attacker.Character
	local targetChar = targetPlayer.Character
	if not attackerChar or not targetChar then return end

	-- Range check (must be within 12 studs)
	local attackerRoot = attackerChar:FindFirstChild("HumanoidRootPart")
	local targetRoot   = targetChar:FindFirstChild("HumanoidRootPart")
	if not attackerRoot or not targetRoot then return end
	if (attackerRoot.Position - targetRoot.Position).Magnitude > 12 then return end

	local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
	if not targetHumanoid or targetHumanoid.Health <= 0 then return end

	-- Calculate damage
	local dmg = BASE_DAMAGE
	-- Weapon damage multiplier from equipped weapon
	local WEAPON_DAMAGE = {
		fists=1.0, sword=1.8, axe=2.5, katana=2.2, scythe=3.5,
		laser=4.0, raygun=5.0, noob_tube=7.0, nuke=9.0, banana=1.5, celestial=8.0
	}
	local equip = _G.playerEquipment and _G.playerEquipment[aId] or {}
	local weaponMult = WEAPON_DAMAGE[equip.weapon or "fists"] or 1.0
	dmg = dmg * weaponMult

	-- Armor defense reduction
	local ARMOR_DEF = {none=0,leather=0.1,chain=0.2,iron=0.3,gold=0.4,shadow=0.45,celestial=0.6}
	local targetEquip = _G.playerEquipment and _G.playerEquipment[targetPlayer.UserId] or {}
	local defMult = 1.0 - (ARMOR_DEF[targetEquip.armor or "none"] or 0)
	dmg = dmg * defMult

	-- Block reduction
	if blocking[targetPlayer.UserId] then
		dmg = dmg * (1 - BLOCK_REDUCTION)
	end

	dmg = math.floor(dmg)
	targetHumanoid:TakeDamage(dmg)

	-- Coin loss on hit
	local coinLoss = math.min(HIT_COIN_LOSS, getTokens(targetPlayer.UserId))
	if coinLoss > 0 then
		addTokens(targetPlayer.UserId, -coinLoss)
		addTokens(aId, math.floor(coinLoss * 0.5)) -- attacker gets half
	end

	-- Fire coin splatter to ALL clients near target
	CoinSplatter:FireAllClients(targetRoot.Position, coinLoss, dmg, blocking[targetPlayer.UserId])

	-- Fire hit event to attacker (confirm hit)
	HitEvent:FireClient(attacker, dmg, coinLoss, blocking[targetPlayer.UserId])
	HitEvent:FireClient(targetPlayer, -dmg, -coinLoss, false)

	-- Arena bet resolution on kill
	if targetHumanoid.Health <= 0 then
		for betId, bet in pairs(arenaBets) do
			if (bet.challenger == aId and bet.opponent == targetPlayer.UserId) or
			   (bet.opponent == aId and bet.challenger == targetPlayer.UserId) then
				if bet.accepted then
					local winner = aId
					local loser  = targetPlayer.UserId
					local prize  = bet.amount * 2
					addTokens(winner, prize)
					addTokens(loser, -bet.amount)
					local wp = Players:GetPlayerByUserId(winner)
					local lp = Players:GetPlayerByUserId(loser)
					if wp then BetResult:FireClient(wp, true,  "🏆 BET WON! +" .. prize .. " tokens!") end
					if lp then BetResult:FireClient(lp, false, "💀 BET LOST! -" .. bet.amount .. " tokens!") end
					arenaBets[betId] = nil
				end
				break
			end
		end
	end
end)

-- ARENA BET handler
BetEvent.OnServerEvent:Connect(function(challenger, targetPlayer, amount)
	amount = math.floor(math.abs(amount or 0))
	if amount <= 0 or amount > getTokens(challenger.UserId) then
		BetResult:FireClient(challenger, false, "Not enough tokens!")
		return
	end
	if not targetPlayer or targetPlayer == challenger then return end

	local betId = challenger.UserId .. "_" .. targetPlayer.UserId
	arenaBets[betId] = {
		challenger = challenger.UserId,
		opponent   = targetPlayer.UserId,
		amount     = amount,
		accepted   = false,
		time       = tick()
	}

	-- Notify opponent
	BetResult:FireClient(targetPlayer, nil, "⚔️ " .. challenger.Name .. " bets " .. amount .. " tokens on a fight! Use /accept to confirm!")
	BetResult:FireClient(challenger, nil, "Bet sent! Waiting for " .. targetPlayer.Name .. "...")
end)

-- Clean stale bets every 60s
spawn(function()
	while true do
		wait(60)
		local now = tick()
		for id, bet in pairs(arenaBets) do
			if now - bet.time > 120 then arenaBets[id] = nil end
		end
	end
end)

Players.PlayerRemoving:Connect(function(p)
	blocking[p.UserId] = nil
	cooldowns[p.UserId] = nil
end)

print("[ArenaCombat] ⚔️ Combat, blocking, coin loss, arena betting ready!")
