-- WeaponVisuals.server.lua
-- Spawns visual weapon model on player's character when equipped
-- Applies correct damage multipliers per weapon

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipVisual = Instance.new("RemoteEvent")
EquipVisual.Name = "EquipVisual"
EquipVisual.Parent = ReplicatedStorage:FindFirstChild("Shop") or ReplicatedStorage

-- Weapon visual definitions {color, size, shape, offset}
local WEAPON_VISUALS = {
	fists      = nil, -- no tool
	sword      = {Color3.fromRGB(180,180,200), Vector3.new(0.3,3,0.3),   "Block",    Vector3.new(1.5,0,0)},
	axe        = {Color3.fromRGB(150,150,150), Vector3.new(0.4,2.5,0.8), "Block",    Vector3.new(1.5,0,0)},
	katana     = {Color3.fromRGB(200,220,255), Vector3.new(0.15,3.5,0.15),"Block",   Vector3.new(1.5,0,0)},
	scythe     = {Color3.fromRGB(80,0,120),    Vector3.new(0.2,4,0.2),   "Block",    Vector3.new(1.5,0,0)},
	laser      = {Color3.fromRGB(0,255,255),   Vector3.new(0.3,2,0.3),   "Block",    Vector3.new(1.5,0,0)},
	celestial  = {Color3.fromRGB(255,215,0),   Vector3.new(0.25,3.8,0.25),"Block",   Vector3.new(1.5,0,0)},
	-- Wild items
	raygun     = {Color3.fromRGB(0,255,100),   Vector3.new(0.4,1.5,0.4), "Block",    Vector3.new(1.5,0,0)},
	noob_tube  = {Color3.fromRGB(80,60,30),    Vector3.new(0.5,2,0.5),   "Cylinder", Vector3.new(1.5,0,0)},
	nuke       = {Color3.fromRGB(255,50,0),    Vector3.new(0.8,0.8,0.8), "Ball",     Vector3.new(1.5,0,0)},
	banana     = {Color3.fromRGB(255,220,0),   Vector3.new(0.3,1.5,0.5), "Block",    Vector3.new(1.5,0,0)},
}

-- Armor visual (color tint on character)
local ARMOR_COLORS = {
	none      = nil,
	leather   = Color3.fromRGB(120,80,40),
	chain     = Color3.fromRGB(160,160,170),
	iron      = Color3.fromRGB(130,130,145),
	gold      = Color3.fromRGB(255,200,50),
	shadow    = Color3.fromRGB(30,0,60),
	celestial = Color3.fromRGB(200,180,255),
}

local function clearWeapon(char)
	for _, obj in ipairs(char:GetChildren()) do
		if obj.Name == "EquippedWeapon" then obj:Destroy() end
	end
end

local function applyWeapon(char, weaponId)
	clearWeapon(char)
	local vis = WEAPON_VISUALS[weaponId]
	if not vis then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local part = Instance.new("Part")
	part.Name = "EquippedWeapon"
	part.Size = vis[2]
	part.Color = vis[1]
	part.Material = Enum.Material.Neon
	part.CanCollide = false
	part.CastShadow = false

	-- Glow effect
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = part
	selectionBox.Color3 = vis[1]
	selectionBox.LineThickness = 0.02
	selectionBox.Parent = part

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = part
	weld.Parent = part

	part.CFrame = hrp.CFrame * CFrame.new(vis[4]) * CFrame.Angles(0, 0, math.rad(-30))
	part.Parent = char

	-- Weapon name billboard
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(0,100,0,20)
	bg.StudsOffset = Vector3.new(0, 4, 0)
	bg.AlwaysOnTop = false
	bg.Parent = part

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = weaponId:upper()
	lbl.TextColor3 = vis[1]
	lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = bg
end

local function applyArmor(char, armorId)
	local col = ARMOR_COLORS[armorId]
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "EquippedWeapon" and part.Name ~= "HumanoidRootPart" then
			if col then
				part.Color = col
				part.Material = armorId == "shadow" and Enum.Material.Neon or Enum.Material.SmoothPlastic
			end
		end
	end
end

-- Apply on equip
local shopF = ReplicatedStorage:WaitForChild("Shop", 10)
if shopF then
	local equipEvent = shopF:FindFirstChild("EquipItem") or shopF:WaitForChild("EquipItem", 5)
	if equipEvent then
		equipEvent.OnServerEvent:Connect(function(player, itemType, itemId)
			wait(0.2)
			local char = player.Character
			if not char then return end
			if itemType == "weapon" then applyWeapon(char, itemId)
			elseif itemType == "armor" then applyArmor(char, itemId) end
		end)
	end
end

-- Apply on respawn
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		wait(1)
		local cache = _G.playerCache and _G.playerCache[player.UserId]
		if cache then
			applyWeapon(char, cache.weapon or "fists")
			applyArmor(char, cache.armor or "none")
		end
	end)
end)

print("[WeaponVisuals] ⚔️ Weapon display + armor colors active!")
