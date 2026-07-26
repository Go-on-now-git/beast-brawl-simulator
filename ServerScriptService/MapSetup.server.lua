-- MapSetup: Brain Rot Beast Brawl Map Generator
-- Generates terrain, trees, obstacles, decorations, and brain rot vibes

local workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

math.randomseed(12345)

-- BASEPLATE
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.CanCollide = true
baseplate.Size = Vector3.new(512, 4, 512)
baseplate.CFrame = CFrame.new(0, -2, 0)
baseplate.Material = Enum.Material.Grass
baseplate.BrickColor = BrickColor.new("Bright green")
baseplate.TopSurface = Enum.SurfaceType.Smooth
baseplate.BottomSurface = Enum.SurfaceType.Smooth
baseplate.Locked = true
baseplate.Parent = workspace

-- SPAWN LOCATION
local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnLocation"
spawn.Anchored = true
spawn.Size = Vector3.new(10, 1, 10)
spawn.CFrame = CFrame.new(0, 0.5, 0)
spawn.Neutral = true
spawn.Duration = 0
spawn.BrickColor = BrickColor.new("Bright yellow")
spawn.Material = Enum.Material.Neon
spawn.Parent = workspace

-- Floating "BEAST BRAWL" sign at spawn
local sign = Instance.new("Part")
sign.Name = "TitleSign"
sign.Anchored = true
sign.Size = Vector3.new(40, 8, 1)
sign.CFrame = CFrame.new(0, 20, -15)
sign.BrickColor = BrickColor.new("Hot pink")
sign.Material = Enum.Material.Neon
sign.Parent = workspace

local signGui = Instance.new("SurfaceGui")
signGui.Face = Enum.NormalId.Front
signGui.Parent = sign

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🦁 BEAST BRAWL 🦁"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = signGui

-- Tween sign color (brain rot rainbow effect)
spawn(function()
	local colors = {
		Color3.fromRGB(255, 0, 128),
		Color3.fromRGB(0, 255, 128),
		Color3.fromRGB(128, 0, 255),
		Color3.fromRGB(255, 128, 0),
		Color3.fromRGB(0, 128, 255),
	}
	local i = 1
	while true do
		local tween = TweenService:Create(sign, TweenInfo.new(0.5), {Color = colors[i]})
		tween:Play()
		tween.Completed:Wait()
		i = i % #colors + 1
	end
end)

-- TREE FUNCTION
local function makeTree(x, z, height, trunkColor, leafColor)
	height = height or math.random(8, 16)
	trunkColor = trunkColor or BrickColor.new("Reddish brown")
	leafColor = leafColor or BrickColor.new("Bright green")

	local trunk = Instance.new("Part")
	trunk.Anchored = true
	trunk.Size = Vector3.new(2, height, 2)
	trunk.CFrame = CFrame.new(x, height/2, z)
	trunk.BrickColor = trunkColor
	trunk.Material = Enum.Material.Wood
	trunk.Parent = workspace

	-- 3 layers of leaves
	for i = 1, 3 do
		local leaves = Instance.new("Part")
		leaves.Anchored = true
		local s = 10 - (i * 2)
		leaves.Size = Vector3.new(s, s * 0.6, s)
		leaves.CFrame = CFrame.new(x, height + (i * 3) - 2, z)
		leaves.Shape = Enum.PartType.Ball
		leaves.BrickColor = leafColor
		leaves.Material = Enum.Material.Neon
		leaves.Parent = workspace
	end
end

-- BRAIN ROT TREES — neon colors
local leafColors = {
	BrickColor.new("Lime green"),
	BrickColor.new("Bright blue"),
	BrickColor.new("Hot pink"),
	BrickColor.new("Bright orange"),
	BrickColor.new("Cyan"),
}

for i = 1, 60 do
	local angle = math.random() * math.pi * 2
	local dist = math.random(30, 200)
	local x = math.cos(angle) * dist
	local z = math.sin(angle) * dist
	local leafColor = leafColors[math.random(#leafColors)]
	makeTree(x, z, math.random(8, 20), nil, leafColor)
end

-- FLOATING ISLANDS (brain rot vibes)
local islandColors = {
	BrickColor.new("Hot pink"),
	BrickColor.new("Cyan"),
	BrickColor.new("Bright yellow"),
	BrickColor.new("Lime green"),
}
for i = 1, 8 do
	local island = Instance.new("Part")
	island.Anchored = true
	island.Size = Vector3.new(math.random(15, 40), 5, math.random(15, 40))
	island.CFrame = CFrame.new(
		math.random(-150, 150),
		math.random(40, 80),
		math.random(-150, 150)
	)
	island.BrickColor = islandColors[math.random(#islandColors)]
	island.Material = Enum.Material.Neon
	island.Parent = workspace

	-- Tree on island
	makeTree(island.CFrame.X, island.CFrame.Z, 6, nil, leafColors[math.random(#leafColors)])
end

-- RANDOM BOULDERS / OBSTACLES
for i = 1, 30 do
	local rock = Instance.new("Part")
	rock.Anchored = true
	local s = math.random(3, 10)
	rock.Size = Vector3.new(s, s * 0.7, s)
	rock.CFrame = CFrame.new(math.random(-200, 200), s * 0.35, math.random(-200, 200))
	rock.BrickColor = BrickColor.new("Dark grey")
	rock.Material = Enum.Material.Rock
	rock.Shape = Enum.PartType.Ball
	rock.Parent = workspace
end

-- NEON FLOOR RINGS (brain rot circles)
local ringColors = {Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255), Color3.fromRGB(255,255,0)}
for i = 1, 3 do
	local ring = Instance.new("Part")
	ring.Anchored = true
	local r = i * 60
	ring.Size = Vector3.new(r * 2 + 2, 0.5, r * 2 + 2)
	ring.CFrame = CFrame.new(0, -1.5, 0)
	ring.BrickColor = BrickColor.new("Bright yellow")
	ring.Material = Enum.Material.Neon
	ring.Transparency = 0.5
	ring.CanCollide = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Parent = workspace

	-- Tween color
	local col = ringColors[i]
	spawn(function()
		while true do
			local t = TweenService:Create(ring, TweenInfo.new(1 + i * 0.5), {Color = col, Transparency = 0.8})
			t:Play(); t.Completed:Wait()
			local t2 = TweenService:Create(ring, TweenInfo.new(1 + i * 0.5), {Color = Color3.fromRGB(255,255,255), Transparency = 0.3})
			t2:Play(); t2.Completed:Wait()
		end
	end)
end

-- RANDOM BRAIN ROT SIGNS
local brainrotText = {
	"💀 SKILL ISSUE 💀",
	"⚡ NO CAP FR FR ⚡",
	"🐺 ALPHA BRAWLER 🐺",
	"😤 GET REKT 😤",
	"🔥 BUSSIN HITS 🔥",
	"😂 L + RATIO 😂",
	"🦁 BEAST MODE 🦁",
	"💅 SLAY THE MAP 💅",
}

for i = 1, 8 do
	local angle = (i / 8) * math.pi * 2
	local dist = math.random(80, 140)
	local x = math.cos(angle) * dist
	local z = math.sin(angle) * dist

	local signPart = Instance.new("Part")
	signPart.Anchored = true
	signPart.Size = Vector3.new(20, 6, 1)
	signPart.CFrame = CFrame.new(x, 8, z) * CFrame.fromEulerAnglesXYZ(0, angle + math.pi, 0)
	signPart.BrickColor = BrickColor.new("Really black")
	signPart.Material = Enum.Material.Neon
	signPart.Parent = workspace

	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.Parent = signPart

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = brainrotText[i]
	lbl.TextColor3 = Color3.fromRGB(255, 255, 0)
	lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = sg
end

-- BORDER WALLS (so you don't walk off)
local borders = {
	{Vector3.new(512, 20, 4), Vector3.new(0, 10, 258)},
	{Vector3.new(512, 20, 4), Vector3.new(0, 10, -258)},
	{Vector3.new(4, 20, 512), Vector3.new(258, 10, 0)},
	{Vector3.new(4, 20, 512), Vector3.new(-258, 10, 0)},
}
for _, b in ipairs(borders) do
	local wall = Instance.new("Part")
	wall.Anchored = true
	wall.Size = b[1]
	wall.CFrame = CFrame.new(b[2])
	wall.Transparency = 0.7
	wall.BrickColor = BrickColor.new("Hot pink")
	wall.Material = Enum.Material.Neon
	wall.CanCollide = true
	wall.Parent = workspace
end

print("[MapSetup] 🦁 Brain Rot Beast Brawl map loaded! #StayAbove")
