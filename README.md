# Beast Brawl Simulator - Complete Roblox Game Package

A full-featured fighting simulator game for Roblox with pets, progression, and economy systems.

## Features

✅ **Fighting Simulator** - Players fight spawning enemies to earn coins
✅ **Free Pet Machine** - RNG-based pet drops with 5 rarity tiers
✅ **Damage Multipliers** - Pets provide stacking damage bonuses
✅ **Coin Economy** - Earn coins, spend on spins and upgrades
✅ **Rebirth System** - Reset stats for permanent multiplier boost
✅ **Level Progression** - 11+ levels with stat points per level
✅ **Leaderboard** - Top 100 players ranked by total damage (OrderedDataStore)
✅ **Admin Commands** - Full command suite for game management
✅ **Game Pass Integration** - VIP, AutoCollect, StarterPack passes
✅ **DataStore Persistence** - Auto-save every 30 seconds

---

## Installation Instructions

### 1. **Create the Game Structure**

In Roblox Studio, set up this folder structure:

```
ServerScriptService/
├── GameManager.server.lua
├── PetSystem.server.lua
├── PlayerData.server.lua
├── AdminCommands.server.lua
├── Leaderboard.server.lua
└── GamePasses.server.lua

StarterPlayer/
└── StarterPlayerScripts/
    ├── LocalUI.client.lua
    └── CombatClient.client.lua

ReplicatedStorage/
└── GameConfig.lua
```

### 2. **Copy Files**

1. Open Roblox Studio and create a new place
2. In **ServerScriptService**, insert a new **Script** for each server file
3. In **StarterPlayer > StarterPlayerScripts**, insert **LocalScripts** for client files
4. In **ReplicatedStorage**, insert a **ModuleScript** named `GameConfig`
5. Copy-paste the respective code from each file

### 3. **Configure Admin UserIds**

Edit **GameConfig.lua** (in ReplicatedStorage):

```lua
GameConfig.AdminUserIds = {
    YOUR_USER_ID  -- Replace 0 with your Roblox UserId
}
```

To find your UserId:
- Join any Roblox game
- Open DevTools (F9 in game)
- Type: `print(game.Players.LocalPlayer.UserId)` in the command bar
- Copy the number that appears

### 4. **Create Game Passes** (Optional)

1. In Roblox Creator Dashboard, go to your game
2. Create 3 game passes:
   - **VIP** (2x coins, exclusive pet, daily bonus)
   - **AutoCollect** (pets auto-fight without player)
   - **StarterPack** (1000 coins + rare pet)
3. Copy each Game Pass ID into **GameConfig.lua**:

```lua
GameConfig.GamePassIds = {
    VIP = 12345678,           -- Replace with your VIP pass ID
    AutoCollect = 87654321,   -- Replace with your AutoCollect pass ID
    StarterPack = 11223344    -- Replace with your StarterPack pass ID
}
```

### 5. **Set Up Workspace** (One-time Setup)

The game automatically creates:
- ✅ A folder called "Enemies" in Workspace (for spawning enemies)
- ✅ DataStores (no manual setup needed)
- ✅ Remote Events/Functions (no manual setup needed)

### 6. **Test the Game**

1. Click **Play** in Roblox Studio
2. You should see:
   - Coins display (top-left)
   - Level/XP bar
   - Pets inventory (top-right)
   - Spin button (center-bottom)
   - Combat system (click to attack enemies)

---

## Admin Commands

If you're an admin (UserId in AdminUserIds), you can use these commands in chat:

```
:give [player] coins [amount]      # Give coins to a player
:give [player] pets [amount]       # Give rare pets to a player
:god [player]                      # Make player invincible
:kick [player]                     # Kick a player from the game
:speed [player] [number]           # Set player walk speed
:tp [player]                       # Teleport player to you
:rejoin [player]                   # Force player to rejoin
```

**Examples:**
```
:give john coins 5000
:give jane pets 10
:god bob
:kick hacker
```

---

## Pet Rarity Tiers

| Rarity | Chance | Multiplier | Color |
|--------|--------|-----------|-------|
| **Common** | 50% | 1.1x | Gray |
| **Uncommon** | 25% | 1.3x | Green |
| **Rare** | 15% | 1.8x | Blue |
| **Epic** | 8% | 2.5x | Purple |
| **Legendary** | 2% | 5x | Gold |

**Multipliers stack:** If you have 2 Legendary pets, your damage is `5 × 5 = 25x`

---

## Game Progression

### Level System
- **Level 1:** 0 XP
- **Level 2:** 10 XP
- **Level 3:** 25 XP
- **Level 4:** 50 XP
- **Level 5:** 100 XP
- Each subsequent level doubles the XP requirement
- Each level grants 5 stat points (currently unused, but available for expansion)

### Rebirth System
- **Cost:** 10,000 coins
- **Effect:** Reset level/coins, gain 1.2x permanent multiplier
- **Goal:** Rebirths allow for "soft resets" with progression boost

### Coin Economy
- **Base reward:** 10 coins per enemy defeated
- **Affected by:** Pet multipliers, VIP (2x), damage dealt
- **Spend on:** Pet spins, rebirth, future upgrades

---

## Script Overview

### **GameConfig.lua** (ReplicatedStorage)
Central configuration file. Contains:
- Pet rarity definitions with weights and multipliers
- Enemy stats (health, damage, spawn rate)
- Level XP thresholds
- Admin UserIds list
- Game Pass IDs
- DataStore names

**Key Variables:**
```lua
GameConfig.PetRarities          -- Rarity table with multipliers
GameConfig.AdminUserIds         -- List of admin UserIds (EDIT THIS)
GameConfig.GamePassIds          -- Game Pass IDs (EDIT THIS)
GameConfig.RebirthCost          -- 10,000 coins
```

---

### **PlayerData.server.lua** (ServerScriptService)
Handles all player statistics and DataStore operations.

**Functions:**
- `LoadPlayerData(userId)` - Loads from DataStore
- `SavePlayerData(userId, data)` - Saves to DataStore
- `GetPlayerStats(userId)` - Get in-memory player stats
- `AddCoins(userId, amount)` - Award coins
- `AddDamage(userId, amount)` - Track total damage
- `AddKill(userId)` - Increment kill counter
- `AddXP(userId, amount)` - Add XP and auto-level up
- `AddPet(userId, rarity)` - Give pet to player
- `GetPetMultiplier(userId)` - Calculate total multiplier
- `Rebirth(userId)` - Execute rebirth

**DataStore Schema:**
```lua
{
    coins = 0,
    pets = {{rarity = "Legendary", level = 1}},
    level = 1,
    xp = 0,
    rebirths = 0,
    totalDamage = 0,
    kills = 0,
    lastSaved = tick()
}
```

---

### **PetSystem.server.lua** (ServerScriptService)
Manages the RNG pet machine and pet mechanics.

**Functions:**
- `GetPlayerMultiplier(userId)` - Get combined pet multiplier
- `GetPlayerPets(userId)` - Return pet list
- `GivePet(userId, rarity)` - Add pet (for admin use)

**Remote Events:**
- `SpinPet` - Client requests pet spin
- `PetSpinResult` - Server returns spin result

---

### **GameManager.server.lua** (ServerScriptService)
Main game loop, enemy spawning, and combat resolution.

**Features:**
- Auto-spawns enemies every 5 seconds
- Despawns enemies after 5 minutes
- Calculates damage with multipliers
- Awards coins and XP on enemy defeat
- Tracks player kills

**Remote Events:**
- `Attack` - Client sends attack data
- `GetEnemies` - Client requests enemy list

---

### **Leaderboard.server.lua** (ServerScriptService)
OrderedDataStore leaderboard by total damage.

**Features:**
- Updates every 60 seconds
- Keeps top 100 players
- Gets player rank in real-time

**Remote Functions:**
- `GetLeaderboard` - Returns top 100
- `GetPlayerRank` - Returns player's rank and damage

---

### **AdminCommands.server.lua** (ServerScriptService)
Admin command system with security.

**Commands:**
- `:give [player] coins [amount]`
- `:give [player] pets [amount]`
- `:god [player]`
- `:kick [player]`
- `:speed [player] [number]`
- `:tp [player]`
- `:rejoin [player]`

**Security:** Only users in `AdminUserIds` can execute commands.

---

### **GamePasses.server.lua** (ServerScriptService)
MarketplaceService integration for game passes.

**Passes:**
- **VIP:** 2x coin multiplier
- **AutoCollect:** Pets fight automatically
- **StarterPack:** 1000 coins + Rare pet on first purchase

**Functions:**
- `PlayerOwnsPass(userId, passName)` - Check ownership
- `GetVIPMultiplier(userId)` - Get VIP multiplier (1 or 2)

---

### **LocalUI.client.lua** (StarterPlayer > StarterPlayerScripts)
Main UI for players. Displays:
- Coin counter
- Level and XP bar
- Pet inventory
- Spin button
- Rebirth button
- Leaderboard viewer

**UI Elements:**
- Top-left: Coins, Level, XP bar
- Top-right: Pet inventory panel
- Center-bottom: Spin button, Rebirth button
- Leaderboard: Toggle with button

---

### **CombatClient.client.lua** (StarterPlayer > StarterPlayerScripts)
Client-side combat system.

**Controls:**
- **Click/Tap:** Attack nearest enemy (50-stud range)
- **X Key:** Hold for auto-attack
- **Space:** Single attack

**Features:**
- Finds nearest enemy within 50 studs
- Shows floating damage numbers
- 200ms cooldown between attacks
- Works on desktop and mobile

---

## DataStore Setup

The game uses two DataStores:
1. **BeastBrawl_PlayerData** - Standard DataStore for player stats
2. **BeastBrawl_Leaderboard** - OrderedDataStore for leaderboard

⚠️ **Important:** DataStores only work in **published games**. To test locally:
1. Use Roblox Studio's Test Mode (**Play** button)
2. DataStore will save/load in test mode
3. Data persists across play sessions

---

## Troubleshooting

### **Enemies Not Spawning**
- Check if ServerScriptService scripts are running
- Verify Workspace folder "Enemies" exists
- Check console for errors (Cmd+Shift+L on Mac, F9 on Windows)

### **UI Not Showing**
- Verify LocalUI.client.lua is in StarterPlayer > StarterPlayerScripts
- Check if ScreenGui is being created
- Ensure game.ReplicatedStorage has GameConfig module

### **DataStore Not Saving**
- Game must be **published** for DataStore to work
- Check if you have appropriate API access
- Look for DataStore errors in Output console

### **Admin Commands Not Working**
- Verify your UserId is in GameConfig.AdminUserIds
- Find your UserId: Join game → F9 → `print(game.Players.LocalPlayer.UserId)`
- Check if you're testing in Studio (DataStore may be isolated)

### **Leaderboard Empty**
- Leaderboard updates every 60 seconds
- Play for a few minutes and wait
- Check if enemies are spawning and being defeated

---

## Customization

### Change Enemy Spawn Rate
Edit **GameConfig.lua**:
```lua
GameConfig.EnemyStats.spawnRate = 3  -- Spawn every 3 seconds (faster)
```

### Change Pet Drop Rates
Edit **GameConfig.lua**:
```lua
GameConfig.PetRarities.Legendary.weight = 10  -- 10% chance instead of 2%
```

### Change Coin Rewards
Edit **GameConfig.lua**:
```lua
GameConfig.CoinReward = 25  -- 25 coins per enemy instead of 10
```

### Add More Rarity Tiers
Edit **GameConfig.lua**:
```lua
GameConfig.PetRarities.Divine = {
    weight = 0.5,
    multiplier = 10,
    color = Color3.fromRGB(255, 0, 255),
    displayName = "Divine"
}
-- Add to PetRarityList:
GameConfig.PetRarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Divine"}
```

---

## Performance Notes

- **Enemy Limit:** No hard limit, but performance depends on your server
- **Update Rate:** UI updates 2x per second, enemies spawn every 5 seconds
- **DataStore Calls:** Capped at 30 saves per second (Roblox limit)
- **Leaderboard:** Updates every 60 seconds to avoid excessive DataStore calls

---

## Future Expansion Ideas

- 🎯 Passive income system
- 🎯 Pet breeding/evolution
- 🎯 Boss enemies with special rewards
- 🎯 Daily quests and challenges
- 🎯 Trading system between players
- 🎯 Prestige levels
- 🎯 Pet inventory management UI
- 🎯 Sound effects and animations
- 🎯 Mobile UI optimization

---

## Support

- **Roblox Creator Hub:** https://create.roblox.com
- **Roblox API Docs:** https://developer.roblox.com
- **Studio Debugging:** F9 in game or Cmd+Shift+L on Mac

---

## License

This package is provided as-is for your Roblox game. Feel free to modify and distribute.

---

**Created:** 2024 | **Version:** 1.0 | **Last Updated:** 2024
