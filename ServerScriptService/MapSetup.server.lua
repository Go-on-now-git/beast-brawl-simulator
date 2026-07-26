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

-- ============================================================
-- TOKEN CASINO BUILDING
-- ============================================================
local casinoBuilding = Instance.new("Part")
casinoBuilding.Name = "CasinoBuilding"
casinoBuilding.Anchored = true
casinoBuilding.Size = Vector3.new(40, 25, 40)
casinoBuilding.CFrame = CFrame.new(-150, 12.5, -150)
casinoBuilding.Color = Color3.fromRGB(80, 0, 120)
casinoBuilding.Material = Enum.Material.Neon
casinoBuilding.Transparency = 0.3
casinoBuilding.Parent = workspace

-- Casino roof
local roof = Instance.new("Part")
roof.Anchored = true
roof.Size = Vector3.new(46, 3, 46)
roof.CFrame = CFrame.new(-150, 26.5, -150)
roof.Color = Color3.fromRGB(255, 150, 0)
roof.Material = Enum.Material.Neon
roof.Parent = workspace

-- Casino sign
local casinoSign = Instance.new("Part")
casinoSign.Anchored = true
casinoSign.CanCollide = false
casinoSign.Size = Vector3.new(35, 10, 1)
casinoSign.CFrame = CFrame.new(-150, 20, -129)
casinoSign.Color = Color3.fromRGB(255, 180, 0)
casinoSign.Material = Enum.Material.Neon
casinoSign.Parent = workspace

local csg = Instance.new("SurfaceGui")
csg.Face = Enum.NormalId.Front
csg.Parent = casinoSign

local clbl = Instance.new("TextLabel")
clbl.Size = UDim2.new(1, 0, 1, 0)
clbl.BackgroundTransparency = 1
clbl.Text = "🎰 TOKEN CASINO\n💰 BET YOUR TOKENS! 💰"
clbl.TextColor3 = Color3.fromRGB(255, 255, 255)
clbl.TextScaled = true
clbl.Font = Enum.Font.GothamBold
clbl.Parent = clbl.Parent or csg
clbl.Parent = csg

-- Proximity sign (press E hint)
local proxSign = Instance.new("Part")
proxSign.Anchored = true
proxSign.CanCollide = false
proxSign.Size = Vector3.new(20, 5, 1)
proxSign.CFrame = CFrame.new(-150, 5, -128)
proxSign.Transparency = 0.2
proxSign.Color = Color3.fromRGB(50, 50, 50)
proxSign.Parent = workspace

local psg = Instance.new("SurfaceGui")
psg.Face = Enum.NormalId.Front
psg.Parent = proxSign

local plbl = Instance.new("TextLabel")
plbl.Size = UDim2.new(1, 0, 1, 0)
plbl.BackgroundTransparency = 1
plbl.Text = "🎰 Press CASINO button to gamble!"
plbl.TextColor3 = Color3.fromRGB(255, 220, 0)
plbl.TextScaled = true
plbl.Font = Enum.Font.Gotham
plbl.Parent = psg

print("[MapSetup] 🎰 Casino building added!")

-- ============================================================
-- VIRAL BORDER — Rotating neon rainbow wall they can't stop watching
-- ============================================================
local borderFolder = Instance.new("Folder")
borderFolder.Name = "ViralBorder"
borderFolder.Parent = workspace

local BORDER = 256
local BORDER_H = 60
local SEGMENTS = 64
local borderParts = {}

-- Build segmented border (all 4 sides, each side = 16 parts)
local sides = {
	{axis="X", sign=1,  face="Z", size=Vector3.new(BORDER/SEGMENTS*4, BORDER_H, 4)},
	{axis="X", sign=-1, face="Z", size=Vector3.new(BORDER/SEGMENTS*4, BORDER_H, 4)},
	{axis="Z", sign=1,  face="X", size=Vector3.new(4, BORDER_H, BORDER/SEGMENTS*4)},
	{axis="Z", sign=-1, face="X", size=Vector3.new(4, BORDER_H, BORDER/SEGMENTS*4)},
}

for sIdx, side in ipairs(sides) do
	for i = 1, SEGMENTS/4 do
		local pos
		local t = (i - 0.5) / (SEGMENTS/4)
		local coord = (t - 0.5) * BORDER
		if side.axis == "X" then
			pos = Vector3.new(coord, BORDER_H/2, side.sign * BORDER/2)
		else
			pos = Vector3.new(side.sign * BORDER/2, BORDER_H/2, coord)
		end

		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = true
		p.Size = side.size
		p.CFrame = CFrame.new(pos)
		p.Material = Enum.Material.Neon
		p.Transparency = 0.2
		p.CastShadow = false
		p.Parent = borderFolder
		table.insert(borderParts, {part=p, index=(sIdx-1)*(SEGMENTS/4)+i})
	end
end

-- Rainbow wave animation — each segment shifts hue based on position + time
spawn(function()
	local t = 0
	while true do
		t = t + 0.04
		for _, data in ipairs(borderParts) do
			local hue = ((data.index / #borderParts) + t * 0.3) % 1
			data.part.Color = Color3.fromHSV(hue, 1, 1)
			-- Pulse transparency
			data.part.Transparency = 0.1 + math.abs(math.sin(t * 2 + data.index * 0.3)) * 0.5
		end
		wait(0.03)
	end
end)

-- Corner pillars at border — massive neon obelisks
local corners = {{BORDER/2,BORDER/2},{-BORDER/2,BORDER/2},{BORDER/2,-BORDER/2},{-BORDER/2,-BORDER/2}}
for _, c in ipairs(corners) do
	local obelisk = Instance.new("Part")
	obelisk.Anchored = true
	obelisk.Size = Vector3.new(8, 100, 8)
	obelisk.CFrame = CFrame.new(c[1], 50, c[2])
	obelisk.Material = Enum.Material.Neon
	obelisk.Color = Color3.fromRGB(255,255,255)
	obelisk.CanCollide = true
	obelisk.Parent = borderFolder

	-- Spinning orb on top
	local orb = Instance.new("Part")
	orb.Anchored = true
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(14,14,14)
	orb.CFrame = CFrame.new(c[1], 105, c[2])
	orb.Material = Enum.Material.Neon
	orb.CanCollide = false
	orb.Parent = borderFolder

	-- Orb color pulse
	spawn(function()
		local h = math.random()
		while orb and orb.Parent do
			h = (h + 0.01) % 1
			orb.Color = Color3.fromHSV(h, 1, 1)
			obelisk.Color = Color3.fromHSV((h+0.5)%1, 1, 1)
			wait(0.05)
		end
	end)
end

print("[MapSetup] 🌈 Viral rainbow border active!")

-- ============================================================
-- BEAST BRAWL LOGO FUNCTION — stamp it EVERYWHERE
-- ============================================================
local LOGO_COLOR = Color3.fromRGB(255, 180, 0)  -- gold brand color
local LOGO_BG    = Color3.fromRGB(0, 0, 0)

local function stampLogo(parent, face, size, pos, cframe, scale)
	scale = scale or 1
	local sign = Instance.new("Part")
	sign.Anchored = true
	sign.CanCollide = false
	sign.Size = size or Vector3.new(20 * scale, 6 * scale, 0.2)
	sign.CFrame = cframe or CFrame.new(pos)
	sign.Color = LOGO_BG
	sign.Material = Enum.Material.Neon
	sign.Transparency = 0.1
	sign.Parent = parent or workspace

	local sg = Instance.new("SurfaceGui")
	sg.Face = face or Enum.NormalId.Front
	sg.PixelsPerStud = 50
	sg.Parent = sign

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1,0,1,0)
	bg.BackgroundColor3 = LOGO_BG
	bg.BorderSizePixel = 0
	bg.Parent = sg

	-- BB logo mark
	local logo = Instance.new("TextLabel")
	logo.Size = UDim2.new(0.3, 0, 1, 0)
	logo.Position = UDim2.new(0, 0, 0, 0)
	logo.BackgroundTransparency = 1
	logo.Text = "🦁"
	logo.TextScaled = true
	logo.Font = Enum.Font.GothamBold
	logo.Parent = bg

	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(0.7, 0, 0.6, 0)
	name.Position = UDim2.new(0.3, 0, 0, 0)
	name.BackgroundTransparency = 1
	name.Text = "BEAST BRAWL"
	name.TextColor3 = LOGO_COLOR
	name.TextScaled = true
	name.Font = Enum.Font.GothamBold
	name.Parent = bg

	local tagline = Instance.new("TextLabel")
	tagline.Size = UDim2.new(0.7, 0, 0.4, 0)
	tagline.Position = UDim2.new(0.3, 0, 0.6, 0)
	tagline.BackgroundTransparency = 1
	tagline.Text = "⚔️ #StayAbove ⚔️"
	tagline.TextColor3 = Color3.fromRGB(255,255,255)
	tagline.TextScaled = true
	tagline.Font = Enum.Font.Gotham
	tagline.Parent = bg

	return sign
end

-- Stamp logos around the map
-- Near spawn
stampLogo(workspace, Enum.NormalId.Front, nil, nil,
	CFrame.new(0, 4, -20), 1.2)
stampLogo(workspace, Enum.NormalId.Front, nil, nil,
	CFrame.new(0, 4, 20) * CFrame.Angles(0, math.pi, 0), 1.2)

-- On Cell Games Arena back wall
stampLogo(workspace, Enum.NormalId.Front, Vector3.new(30,8,0.2), nil,
	CFrame.new(0, 12, -200), 1)

-- On casino building sides
stampLogo(workspace, Enum.NormalId.Front, Vector3.new(25,7,0.2), nil,
	CFrame.new(-150, 20, -115) * CFrame.Angles(0,0,0), 1)

-- Giant floor logo (center of map, visible from above)
local floorLogo = Instance.new("Part")
floorLogo.Anchored = true
floorLogo.CanCollide = false
floorLogo.Size = Vector3.new(60,0.1,20)
floorLogo.CFrame = CFrame.new(0, -1.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
floorLogo.Color = Color3.fromRGB(0,0,0)
floorLogo.Material = Enum.Material.Neon
floorLogo.Transparency = 0.2
floorLogo.Parent = workspace

local floorSg = Instance.new("SurfaceGui")
floorSg.Face = Enum.NormalId.Top
floorSg.PixelsPerStud = 60
floorSg.Parent = floorLogo

local floorLbl = Instance.new("TextLabel")
floorLbl.Size = UDim2.new(1,0,1,0)
floorLbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
floorLbl.BackgroundTransparency = 0
floorLbl.Text = "🦁  BEAST BRAWL  🦁"
floorLbl.TextColor3 = LOGO_COLOR
floorLbl.TextScaled = true
floorLbl.Font = Enum.Font.GothamBold
floorLbl.Parent = floorSg

-- ============================================================
-- BEAST BRAWL SHOPPING MALL
-- ============================================================
local mallFolder = Instance.new("Folder")
mallFolder.Name = "ShoppingMall"
mallFolder.Parent = workspace

local MALL_X, MALL_Z = 0, 200
local MALL_W, MALL_D, MALL_H = 120, 60, 20

-- Mall exterior shell
local mallFloor = Instance.new("Part")
mallFloor.Anchored = true
mallFloor.Size = Vector3.new(MALL_W, 1, MALL_D)
mallFloor.CFrame = CFrame.new(MALL_X, 0.5, MALL_Z)
mallFloor.Color = Color3.fromRGB(220, 220, 230)
mallFloor.Material = Enum.Material.SmoothPlastic
mallFloor.Parent = mallFolder

-- Roof
local mallRoof = Instance.new("Part")
mallRoof.Anchored = true
mallRoof.Size = Vector3.new(MALL_W+2, 1, MALL_D+2)
mallRoof.CFrame = CFrame.new(MALL_X, MALL_H+0.5, MALL_Z)
mallRoof.Color = Color3.fromRGB(40,40,80)
mallRoof.Material = Enum.Material.Neon
mallRoof.Transparency = 0.3
mallRoof.Parent = mallFolder

-- Walls
local walls = {
	{Vector3.new(MALL_W, MALL_H, 1), CFrame.new(MALL_X, MALL_H/2, MALL_Z - MALL_D/2)},  -- front (entrance)
	{Vector3.new(MALL_W, MALL_H, 1), CFrame.new(MALL_X, MALL_H/2, MALL_Z + MALL_D/2)},  -- back
	{Vector3.new(1, MALL_H, MALL_D), CFrame.new(MALL_X - MALL_W/2, MALL_H/2, MALL_Z)},  -- left
	{Vector3.new(1, MALL_H, MALL_D), CFrame.new(MALL_X + MALL_W/2, MALL_H/2, MALL_Z)},  -- right
}
for i, w in ipairs(walls) do
	local wall = Instance.new("Part")
	wall.Anchored = true
	wall.Size = w[1]
	wall.CFrame = w[2]
	wall.Color = Color3.fromRGB(230,230,240)
	wall.Material = Enum.Material.SmoothPlastic
	wall.Transparency = i == 1 and 0.6 or 0  -- front wall semi-transparent (glass entrance)
	wall.Parent = mallFolder
end

-- Entrance archway cutout label
local entrancePart = Instance.new("Part")
entrancePart.Anchored = true
entrancePart.CanCollide = false
entrancePart.Size = Vector3.new(30, 10, 0.5)
entrancePart.CFrame = CFrame.new(MALL_X, 5, MALL_Z - MALL_D/2 - 0.3)
entrancePart.Color = Color3.fromRGB(255,180,0)
entrancePart.Material = Enum.Material.Neon
entrancePart.Parent = mallFolder

local entSg = Instance.new("SurfaceGui")
entSg.Face = Enum.NormalId.Front
entSg.Parent = entrancePart
local entLbl = Instance.new("TextLabel")
entLbl.Size = UDim2.new(1,0,1,0)
entLbl.BackgroundTransparency = 1
entLbl.Text = "🦁 BEAST BRAWL MALL ⚔️\n🛒 Weapons • Skins • Gamble"
entLbl.TextColor3 = Color3.fromRGB(0,0,0)
entLbl.TextScaled = true
entLbl.Font = Enum.Font.GothamBold
entLbl.Parent = entSg

-- Mall interior neon floor strips
for i = -2, 2 do
	local strip = Instance.new("Part")
	strip.Anchored = true
	strip.CanCollide = false
	strip.Size = Vector3.new(2, 0.1, MALL_D - 4)
	strip.CFrame = CFrame.new(MALL_X + i * 20, 0.55, MALL_Z)
	strip.Color = Color3.fromHSV(math.abs(i)/3, 1, 1)
	strip.Material = Enum.Material.Neon
	strip.Parent = mallFolder
end

-- SHOP STALLS inside mall (5 weapon stalls + 1 gamble stall)
local STALLS = {
	{name="⚔️ Swords & Axes",   pos=Vector3.new(MALL_X-45, 1, MALL_Z-10), col=Color3.fromRGB(150,150,200)},
	{name="🔫 Guns & Lasers",   pos=Vector3.new(MALL_X-20, 1, MALL_Z-10), col=Color3.fromRGB(0,200,255)},
	{name="💀 Legendary Shop",  pos=Vector3.new(MALL_X+5,  1, MALL_Z-10), col=Color3.fromRGB(180,0,255)},
	{name="🛡️ Armor Shop",      pos=Vector3.new(MALL_X+30, 1, MALL_Z-10), col=Color3.fromRGB(80,200,80)},
	{name="🎰 Weapon Gamble",   pos=Vector3.new(MALL_X-20, 1, MALL_Z+15), col=Color3.fromRGB(255,150,0)},
	{name="👗 Skins & Fits",    pos=Vector3.new(MALL_X+10, 1, MALL_Z+15), col=Color3.fromRGB(255,50,150)},
}

for _, stall in ipairs(STALLS) do
	-- Counter
	local counter = Instance.new("Part")
	counter.Anchored = true
	counter.Size = Vector3.new(16, 3, 8)
	counter.CFrame = CFrame.new(stall.pos)
	counter.Color = stall.col
	counter.Material = Enum.Material.Neon
	counter.Transparency = 0.2
	counter.Parent = mallFolder

	-- Sign above stall
	local stallSign = Instance.new("Part")
	stallSign.Anchored = true
	stallSign.CanCollide = false
	stallSign.Size = Vector3.new(16, 4, 0.2)
	stallSign.CFrame = CFrame.new(stall.pos + Vector3.new(0, 5.5, -4))
	stallSign.Color = Color3.fromRGB(0,0,0)
	stallSign.Material = Enum.Material.Neon
	stallSign.Parent = mallFolder

	local ssg = Instance.new("SurfaceGui")
	ssg.Face = Enum.NormalId.Front
	ssg.Parent = stallSign

	local slbl = Instance.new("TextLabel")
	slbl.Size = UDim2.new(1,0,1,0)
	slbl.BackgroundTransparency = 1
	slbl.Text = stall.name
	slbl.TextColor3 = stall.col
	slbl.TextScaled = true
	slbl.Font = Enum.Font.GothamBold
	slbl.Parent = ssg

	-- BB logo on counter face
	local counterSg = Instance.new("SurfaceGui")
	counterSg.Face = Enum.NormalId.Front
	counterSg.Parent = counter

	local cLbl = Instance.new("TextLabel")
	cLbl.Size = UDim2.new(1,0,1,0)
	cLbl.BackgroundTransparency = 1
	cLbl.Text = "🦁 Open Shop ⚔️\n[Press ⚔️ SHOP]"
	cLbl.TextColor3 = Color3.fromRGB(255,255,255)
	cLbl.TextScaled = true
	cLbl.Font = Enum.Font.GothamBold
	cLbl.Parent = counterSg

	-- Display weapon above counter (decorative)
	local display = Instance.new("Part")
	display.Anchored = true
	display.CanCollide = false
	display.Shape = Enum.PartType.Ball
	display.Size = Vector3.new(2.5,2.5,2.5)
	display.CFrame = CFrame.new(stall.pos + Vector3.new(0, 4, 0))
	display.Color = stall.col
	display.Material = Enum.Material.Neon
	display.Parent = mallFolder

	-- Rotate display item
	spawn(function()
		local t = 0
		while display and display.Parent do
			t = t + 0.03
			display.CFrame = CFrame.new(stall.pos + Vector3.new(0, 4 + math.sin(t) * 0.5, 0))
				* CFrame.Angles(0, t, 0)
			wait(0.03)
		end
	end)
end

-- Stamp logo inside mall (back wall)
stampLogo(mallFolder, Enum.NormalId.Front, Vector3.new(50, 8, 0.2), nil,
	CFrame.new(MALL_X, 10, MALL_Z + MALL_D/2 - 1), 1.5)

-- Skylight (glass ceiling center panel)
local skylight = Instance.new("Part")
skylight.Anchored = true
skylight.Size = Vector3.new(40, 0.2, 20)
skylight.CFrame = CFrame.new(MALL_X, MALL_H + 0.2, MALL_Z)
skylight.Color = Color3.fromRGB(150, 200, 255)
skylight.Material = Enum.Material.Glass
skylight.Transparency = 0.4
skylight.Parent = mallFolder

print("[MapSetup] 🦁 Shopping Mall + Logo system loaded! #StayAbove")
