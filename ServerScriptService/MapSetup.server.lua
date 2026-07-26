-- MapSetup: Beast Brawl VIRAL MAP — Cell Games Arena + Trending Roblox Meta 2026
-- Trending: brainrot collectibles, steal-defend, luck-based RNG, anime fighter arena, idle-grow

local workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

math.randomseed(os.time())

-- ============================================================
-- LIGHTING — Anime fighter vibes
-- ============================================================
Lighting.Brightness = 2
Lighting.ClockTime = 14
Lighting.FogEnd = 800
Lighting.FogColor = Color3.fromRGB(180, 120, 255)
Lighting.Ambient = Color3.fromRGB(80, 0, 120)
Lighting.OutdoorAmbient = Color3.fromRGB(120, 60, 180)

local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.8
bloom.Size = 24
bloom.Threshold = 0.95
bloom.Parent = Lighting

local colorCorrect = Instance.new("ColorCorrectionEffect")
colorCorrect.Saturation = 0.4
colorCorrect.Contrast = 0.2
colorCorrect.Parent = Lighting

-- ============================================================
-- BASEPLATE — Arena floor with grid lines
-- ============================================================
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.CanCollide = true
baseplate.Size = Vector3.new(512, 4, 512)
baseplate.CFrame = CFrame.new(0, -2, 0)
baseplate.Material = Enum.Material.SmoothPlastic
baseplate.Color = Color3.fromRGB(15, 15, 30)
baseplate.TopSurface = Enum.SurfaceType.Smooth
baseplate.Locked = true
baseplate.Parent = workspace

-- Neon grid overlay
for i = -10, 10 do
	local line = Instance.new("Part")
	line.Anchored = true
	line.CanCollide = false
	line.Size = Vector3.new(512, 0.2, 1)
	line.CFrame = CFrame.new(0, -0.1, i * 25)
	line.Color = Color3.fromRGB(0, 100, 255)
	line.Material = Enum.Material.Neon
	line.Transparency = 0.6
	line.Parent = workspace

	local line2 = Instance.new("Part")
	line2.Anchored = true
	line2.CanCollide = false
	line2.Size = Vector3.new(1, 0.2, 512)
	line2.CFrame = CFrame.new(i * 25, -0.1, 0)
	line2.Color = Color3.fromRGB(0, 100, 255)
	line2.Material = Enum.Material.Neon
	line2.Transparency = 0.6
	line2.Parent = workspace
end

-- ============================================================
-- SPAWN PLATFORM
-- ============================================================
local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnLocation"
spawn.Anchored = true
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, 0.5, 0)
spawn.Neutral = true
spawn.Duration = 0
spawn.Color = Color3.fromRGB(255, 200, 0)
spawn.Material = Enum.Material.Neon
spawn.Parent = workspace

-- ============================================================
-- CELL GAMES ARENA — Dragon Ball Z iconic ring
-- ============================================================
local arenaFolder = Instance.new("Folder")
arenaFolder.Name = "CellGamesArena"
arenaFolder.Parent = workspace

-- Main fighting platform
local platform = Instance.new("Part")
platform.Name = "CellPlatform"
platform.Anchored = true
platform.Size = Vector3.new(100, 3, 100)
platform.CFrame = CFrame.new(0, 1.5, -150)
platform.Material = Enum.Material.Concrete
platform.Color = Color3.fromRGB(200, 180, 140)
platform.TopSurface = Enum.SurfaceType.Smooth
platform.Parent = arenaFolder

-- Pillar corners (Cell Games style)
local pillarPositions = {
	{-48, -150}, {48, -150}, {-48, -102}, {48, -102},
}
for _, pos in ipairs(pillarPositions) do
	local pillar = Instance.new("Part")
	pillar.Anchored = true
	pillar.Size = Vector3.new(6, 30, 6)
	pillar.CFrame = CFrame.new(pos[1], 15, pos[2])
	pillar.Material = Enum.Material.Concrete
	pillar.Color = Color3.fromRGB(180, 160, 120)
	pillar.Parent = arenaFolder

	-- Pillar cap
	local cap = Instance.new("Part")
	cap.Anchored = true
	cap.Size = Vector3.new(8, 2, 8)
	cap.CFrame = CFrame.new(pos[1], 31, pos[2])
	cap.Material = Enum.Material.Concrete
	cap.Color = Color3.fromRGB(150, 130, 100)
	cap.Parent = arenaFolder
end

-- Ring ropes (neon)
local ropeColors = {Color3.fromRGB(255,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,255)}
for i, col in ipairs(ropeColors) do
	local h = 6 + i * 3
	-- North/South ropes
	for _, side in ipairs({{-150, 0}, {-102, 0}}) do
		local rope = Instance.new("Part")
		rope.Anchored = true
		rope.CanCollide = false
		rope.Size = Vector3.new(100, 0.5, 0.5)
		rope.CFrame = CFrame.new(0, h, side[1])
		rope.Color = col
		rope.Material = Enum.Material.Neon
		rope.Parent = arenaFolder
	end
	-- East/West ropes
	for _, side in ipairs({{-48, -126}, {48, -126}}) do
		local rope = Instance.new("Part")
		rope.Anchored = true
		rope.CanCollide = false
		rope.Size = Vector3.new(0.5, 0.5, 100)
		rope.CFrame = CFrame.new(side[1], h, side[2])
		rope.Color = col
		rope.Material = Enum.Material.Neon
		rope.Parent = arenaFolder
	end
end

-- "CELL GAMES ARENA" sign above the ring
local arenaSigns = Instance.new("Part")
arenaSigns.Anchored = true
arenaSigns.CanCollide = false
arenaSigns.Size = Vector3.new(60, 8, 1)
arenaSigns.CFrame = CFrame.new(0, 45, -100)
arenaSigns.Color = Color3.fromRGB(0, 200, 100)
arenaSigns.Material = Enum.Material.Neon
arenaSigns.Parent = arenaFolder

local arenaSg = Instance.new("SurfaceGui")
arenaSg.Face = Enum.NormalId.Front
arenaSg.Parent = arenaSigns

local arenaLbl = Instance.new("TextLabel")
arenaLbl.Size = UDim2.new(1, 0, 1, 0)
arenaLbl.BackgroundTransparency = 1
arenaLbl.Text = "⚔️ CELL GAMES ARENA ⚔️"
arenaLbl.TextColor3 = Color3.fromRGB(255, 255, 0)
arenaLbl.TextScaled = true
arenaLbl.Font = Enum.Font.GothamBold
arenaLbl.Parent = arenaSg

-- ============================================================
-- TRENDING: BRAINROT COLLECTIBLE ZONE
-- ============================================================
local brainrotZone = Instance.new("Part")
brainrotZone.Name = "BrainrotZone"
brainrotZone.Anchored = true
brainrotZone.Size = Vector3.new(80, 1, 80)
brainrotZone.CFrame = CFrame.new(150, 0, 0)
brainrotZone.Color = Color3.fromRGB(255, 0, 200)
brainrotZone.Material = Enum.Material.Neon
brainrotZone.Transparency = 0.5
brainrotZone.CanCollide = true
brainrotZone.Parent = workspace

local bz = Instance.new("Part")
bz.Anchored = true
bz.CanCollide = false
bz.Size = Vector3.new(60, 8, 1)
bz.CFrame = CFrame.new(150, 10, -38)
bz.Color = Color3.fromRGB(255, 0, 200)
bz.Material = Enum.Material.Neon
bz.Parent = workspace

local bzSg = Instance.new("SurfaceGui")
bzSg.Face = Enum.NormalId.Front
bzSg.Parent = bz

local bzLbl = Instance.new("TextLabel")
bzLbl.Size = UDim2.new(1, 0, 1, 0)
bzLbl.BackgroundTransparency = 1
bzLbl.Text = "🧠 BRAINROT ZONE 🧠"
bzLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
bzLbl.TextScaled = true
bzLbl.Font = Enum.Font.GothamBold
bzLbl.Parent = bzSg

-- Brainrot collectible orbs
local brainrotNames = {"Skibidi","Sigma","Rizz","Gyatt","Bussin","Slay","NoCap","Delulu","Mid","Valid"}
for i, name in ipairs(brainrotNames) do
	local angle = (i / #brainrotNames) * math.pi * 2
	local r = 25
	local orb = Instance.new("Part")
	orb.Name = "Brainrot_" .. name
	orb.Anchored = true
	orb.CanCollide = false
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(5, 5, 5)
	orb.CFrame = CFrame.new(150 + math.cos(angle) * r, 5, math.sin(angle) * r)
	orb.Material = Enum.Material.Neon
	orb.Color = Color3.fromHSV(i/#brainrotNames, 1, 1)
	orb.Parent = workspace

	-- Label
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(0, 80, 0, 30)
	bg.StudsOffset = Vector3.new(0, 4, 0)
	bg.AlwaysOnTop = false
	bg.Parent = orb

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBold
	lbl.Parent = bg

	-- Float animation
	spawn(function()
		while orb and orb.Parent do
			local t = TweenService:Create(orb, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
				CFrame = orb.CFrame + Vector3.new(0, 3, 0)
			})
			t:Play()
			wait(3)
		end
	end)
end

-- ============================================================
-- TRENDING: RNG LUCK MACHINE
-- ============================================================
local rngMachine = Instance.new("Part")
rngMachine.Name = "RNGMachine"
rngMachine.Anchored = true
rngMachine.Size = Vector3.new(15, 20, 15)
rngMachine.CFrame = CFrame.new(-150, 10, 0)
rngMachine.Color = Color3.fromRGB(255, 200, 0)
rngMachine.Material = Enum.Material.Neon
rngMachine.Parent = workspace

local rngSg = Instance.new("SurfaceGui")
rngSg.Face = Enum.NormalId.Front
rngSg.Parent = rngMachine

local rngLbl = Instance.new("TextLabel")
rngLbl.Size = UDim2.new(1, 0, 1, 0)
rngLbl.BackgroundTransparency = 1
rngLbl.Text = "🎰 RNG\nMACHINE\n🍀 SPIN!"
rngLbl.TextColor3 = Color3.fromRGB(0, 0, 0)
rngLbl.TextScaled = true
rngLbl.Font = Enum.Font.GothamBold
rngLbl.Parent = rngSg

-- ============================================================
-- TRENDING: ANIME FIGHTER PILLARS (Blade Ball / Type Soul vibes)
-- ============================================================
local pillarSpots = {
	{80, 80}, {-80, 80}, {80, -80}, {-80, -80},
	{0, 120}, {0, -120}, {120, 0}, {-120, 0}
}
local pillarColors = {
	Color3.fromRGB(255, 50, 50),
	Color3.fromRGB(50, 100, 255),
	Color3.fromRGB(50, 255, 100),
	Color3.fromRGB(255, 150, 0),
	Color3.fromRGB(200, 0, 255),
	Color3.fromRGB(0, 255, 255),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(255, 0, 150),
}
for i, pos in ipairs(pillarSpots) do
	local pillar = Instance.new("Part")
	pillar.Anchored = true
	pillar.Size = Vector3.new(4, math.random(15, 35), 4)
	pillar.CFrame = CFrame.new(pos[1], pillar.Size.Y/2, pos[2])
	pillar.Material = Enum.Material.Neon
	pillar.Color = pillarColors[i]
	pillar.Parent = workspace

	-- Glowing orb on top
	local top = Instance.new("Part")
	top.Anchored = true
	top.Shape = Enum.PartType.Ball
	top.Size = Vector3.new(6, 6, 6)
	top.CFrame = CFrame.new(pos[1], pillar.Size.Y + 3, pos[2])
	top.Material = Enum.Material.Neon
	top.Color = pillarColors[i]
	top.CanCollide = false
	top.Parent = workspace
end

-- ============================================================
-- VIRAL TITLE SIGN (rainbow, animated)
-- ============================================================
local titleSign = Instance.new("Part")
titleSign.Name = "TitleSign"
titleSign.Anchored = true
titleSign.CanCollide = false
titleSign.Size = Vector3.new(60, 10, 1)
titleSign.CFrame = CFrame.new(0, 30, 0)
titleSign.Material = Enum.Material.Neon
titleSign.Color = Color3.fromRGB(255, 0, 128)
titleSign.Parent = workspace

local sg = Instance.new("SurfaceGui")
sg.Face = Enum.NormalId.Front
sg.Parent = titleSign

local tl = Instance.new("TextLabel")
tl.Size = UDim2.new(1, 0, 1, 0)
tl.BackgroundTransparency = 1
tl.Text = "🦁 BEAST BRAWL SIMULATOR 🦁"
tl.TextColor3 = Color3.fromRGB(255, 255, 0)
tl.TextScaled = true
tl.Font = Enum.Font.GothamBold
tl.Parent = sg

-- Rainbow tween
spawn(function()
	local cols = {
		Color3.fromRGB(255,0,128), Color3.fromRGB(255,128,0),
		Color3.fromRGB(0,255,128), Color3.fromRGB(0,128,255),
		Color3.fromRGB(128,0,255),
	}
	local i = 1
	while true do
		TweenService:Create(titleSign, TweenInfo.new(0.4), {Color = cols[i]}):Play()
		wait(0.4)
		i = i % #cols + 1
	end
end)

-- ============================================================
-- BRAIN ROT SIGNS around map
-- ============================================================
local brainrotSigns = {
	"💀 SKILL ISSUE 💀", "⚡ SIGMA GRINDSET ⚡", "🐺 ALPHA BRAWLER 🐺",
	"😤 GET REKT 😤", "🔥 BUSSIN HITS 🔥", "😂 L + RATIO 😂",
	"💅 SLAY THE ARENA 💅", "🎯 NO CAP FR FR 🎯", "🦁 BEAST MODE ON 🦁",
	"🍀 RNG FAVORED YOU 🍀", "⚔️ CELL GAMES OPEN ⚔️", "🧠 STAY DELULU 🧠",
}
for i, txt in ipairs(brainrotSigns) do
	local angle = (i / #brainrotSigns) * math.pi * 2
	local dist = 200
	local sp = Instance.new("Part")
	sp.Anchored = true
	sp.CanCollide = false
	sp.Size = Vector3.new(22, 6, 1)
	sp.CFrame = CFrame.new(math.cos(angle)*dist, 8, math.sin(angle)*dist) * CFrame.fromEulerAnglesXYZ(0, angle+math.pi, 0)
	sp.Color = Color3.fromHSV(i/#brainrotSigns, 1, 1)
	sp.Material = Enum.Material.Neon
	sp.Parent = workspace

	local ssg = Instance.new("SurfaceGui")
	ssg.Face = Enum.NormalId.Front
	ssg.Parent = sp

	local slbl = Instance.new("TextLabel")
	slbl.Size = UDim2.new(1, 0, 1, 0)
	slbl.BackgroundTransparency = 1
	slbl.Text = txt
	slbl.TextColor3 = Color3.fromRGB(255,255,255)
	slbl.TextScaled = true
	slbl.Font = Enum.Font.GothamBold
	slbl.Parent = ssg
end

-- ============================================================
-- BORDER WALLS
-- ============================================================
local bords = {
	{Vector3.new(512,40,4), CFrame.new(0,20,258)},
	{Vector3.new(512,40,4), CFrame.new(0,20,-258)},
	{Vector3.new(4,40,512), CFrame.new(258,20,0)},
	{Vector3.new(4,40,512), CFrame.new(-258,20,0)},
}
for _, b in ipairs(bords) do
	local w = Instance.new("Part")
	w.Anchored = true
	w.Size = b[1]
	w.CFrame = b[2]
	w.Transparency = 0.8
	w.Color = Color3.fromRGB(0, 100, 255)
	w.Material = Enum.Material.Neon
	w.CanCollide = true
	w.Parent = workspace
end

print("[MapSetup] 🦁 Cell Games Arena + Viral Beast Brawl loaded! #StayAbove")
