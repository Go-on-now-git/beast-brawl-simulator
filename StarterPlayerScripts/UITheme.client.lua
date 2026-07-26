-- UITheme.client.lua
-- Unified aesthetic overhaul — dark premium with gold accents
-- Replaces all HUD elements with a clean, cohesive design system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- DESIGN TOKENS
-- ============================================================
local T = {
	bg          = Color3.fromRGB(10, 10, 18),       -- near-black panel bg
	bgCard      = Color3.fromRGB(18, 16, 32),       -- card surface
	bgHover     = Color3.fromRGB(28, 24, 48),       -- hover state
	accent      = Color3.fromRGB(255, 185, 30),     -- gold accent
	accentDim   = Color3.fromRGB(180, 120, 10),     -- muted gold
	red         = Color3.fromRGB(220, 50, 60),      -- danger
	green       = Color3.fromRGB(40, 200, 100),     -- success
	blue        = Color3.fromRGB(60, 140, 255),     -- info
	purple      = Color3.fromRGB(140, 60, 255),     -- premium
	textPrimary = Color3.fromRGB(240, 240, 255),    -- white-ish
	textMuted   = Color3.fromRGB(140, 135, 165),    -- muted
	border      = Color3.fromRGB(40, 35, 65),       -- subtle border
	radius      = UDim.new(0, 12),
	radiusSm    = UDim.new(0, 7),
	font        = Enum.Font.GothamBold,
	fontReg     = Enum.Font.Gotham,
}

local function corner(r, p) local c=Instance.new("UICorner");c.CornerRadius=r or T.radius;c.Parent=p end
local function stroke(c, t, p) local s=Instance.new("UIStroke");s.Color=c or T.border;s.Thickness=t or 1;s.Parent=p end
local function pad(px, py, p) local pd=Instance.new("UIPadding");pd.PaddingLeft=UDim.new(0,px);pd.PaddingRight=UDim.new(0,px);pd.PaddingTop=UDim.new(0,py or px);pd.PaddingBottom=UDim.new(0,py or px);pd.Parent=p end

local function makeLabel(props, parent)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = props.font or T.fontReg
	l.TextColor3 = props.color or T.textPrimary
	l.TextScaled = true
	l.Text = props.text or ""
	l.Size = props.size or UDim2.new(1,0,1,0)
	l.Position = props.pos or UDim2.new(0,0,0,0)
	l.TextXAlignment = props.align or Enum.TextXAlignment.Center
	l.Parent = parent
	return l
end

local function makeBtn(props, parent)
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = props.bg or T.bgCard
	b.Text = props.text or ""
	b.TextColor3 = props.color or T.textPrimary
	b.TextScaled = true
	b.Font = T.font
	b.BorderSizePixel = 0
	b.Size = props.size or UDim2.new(1,0,0,40)
	b.Position = props.pos or UDim2.new(0,0,0,0)
	b.Parent = parent
	corner(props.radius or T.radiusSm, b)
	if props.stroke then stroke(props.stroke, 1.5, b) end
	b.MouseEnter:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=T.bgHover}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=props.bg or T.bgCard}):Play()
	end)
	return b
end

-- ============================================================
-- MAIN SCREEN GUI
-- ============================================================
local sg = Instance.new("ScreenGui")
sg.Name = "MainHUD"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 10
sg.Parent = playerGui

-- ============================================================
-- RIGHT SIDEBAR — stacked pill buttons
-- ============================================================
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 140, 0, 0)
sidebar.Position = UDim2.new(1, -152, 0.5, -80)
sidebar.BackgroundTransparency = 1
sidebar.AutomaticSize = Enum.AutomaticSize.Y
sidebar.Parent = sg

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 6)
sideLayout.FillDirection = Enum.FillDirection.Vertical
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.Parent = sidebar

-- Token pill (top of sidebar)
local tokenPill = Instance.new("Frame")
tokenPill.Size = UDim2.new(1, 0, 0, 36)
tokenPill.BackgroundColor3 = T.bgCard
tokenPill.BorderSizePixel = 0
tokenPill.Parent = sidebar
corner(UDim.new(0,18), tokenPill)
stroke(T.accent, 1.5, tokenPill)

local tokenIcon = makeLabel({text="🎰", size=UDim2.new(0,28,1,0), pos=UDim2.new(0,6,0,0)}, tokenPill)
local tokenCount = makeLabel({text="0", size=UDim2.new(1,-38,1,0), pos=UDim2.new(0,34,0,0), font=T.font, color=T.accent, align=Enum.TextXAlignment.Left}, tokenPill)

-- ============================================================
-- SIDEBAR BUTTONS
-- ============================================================
local sideButtons = {}

local btnDefs = {
	{id="casino", icon="🎰", label="CASINO", color=T.accent,    bg=Color3.fromRGB(40,28,5)},
	{id="shop",   icon="⚔️", label="SHOP",   color=T.blue,     bg=Color3.fromRGB(5,20,50)},
	{id="ranks",  icon="🏆", label="RANKS",  color=T.purple,   bg=Color3.fromRGB(20,5,50)},
}

for _, def in ipairs(btnDefs) do
	local btn = Instance.new("TextButton")
	btn.Name = def.id.."Btn"
	btn.Size = UDim2.new(1,0,0,42)
	btn.BackgroundColor3 = def.bg
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.Parent = sidebar
	corner(UDim.new(0,10), btn)
	stroke(def.color, 1.2, btn)

	local icon = makeLabel({text=def.icon, size=UDim2.new(0,30,1,0), pos=UDim2.new(0,8,0,0)}, btn)
	local lbl  = makeLabel({text=def.label, size=UDim2.new(1,-40,1,0), pos=UDim2.new(0,38,0,0), font=T.font, color=def.color, align=Enum.TextXAlignment.Left}, btn)

	sideButtons[def.id] = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=T.bgHover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=def.bg}):Play()
	end)
end

-- Tremston-only admin button
if player.UserId == 11354660659 then
	local adminBtn = Instance.new("TextButton")
	adminBtn.Name = "adminBtn"
	adminBtn.Size = UDim2.new(1,0,0,42)
	adminBtn.BackgroundColor3 = Color3.fromRGB(50,5,5)
	adminBtn.Text = ""
	adminBtn.BorderSizePixel = 0
	adminBtn.Parent = sidebar
	corner(UDim.new(0,10), adminBtn)
	stroke(T.red, 1.2, adminBtn)
	makeLabel({text="👑", size=UDim2.new(0,30,1,0), pos=UDim2.new(0,8,0,0)}, adminBtn)
	makeLabel({text="ADMIN", size=UDim2.new(1,-40,1,0), pos=UDim2.new(0,38,0,0), font=T.font, color=T.red, align=Enum.TextXAlignment.Left}, adminBtn)
	sideButtons["admin"] = adminBtn
end

-- ============================================================
-- LEFT SIDEBAR — stats stack
-- ============================================================
local leftBar = Instance.new("Frame")
leftBar.Size = UDim2.new(0, 160, 0, 0)
leftBar.Position = UDim2.new(0, 10, 0.5, -90)
leftBar.BackgroundTransparency = 1
leftBar.AutomaticSize = Enum.AutomaticSize.Y
leftBar.Parent = sg

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 14)
leftLayout.Parent = leftBar

local function makeStatCard(icon, label, valueId)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 64)
	card.BackgroundColor3 = T.bgCard
	card.BorderSizePixel = 0
	card.Parent = leftBar
	corner(T.radius, card)
	stroke(T.border, 1, card)

	makeLabel({text=icon, size=UDim2.new(0,32,0,24), pos=UDim2.new(0,10,0,4)}, card)
	makeLabel({text=label, size=UDim2.new(1,-46,0,20), pos=UDim2.new(0,44,0,4), color=T.textMuted, align=Enum.TextXAlignment.Left}, card)
	local val = makeLabel({text="0", size=UDim2.new(1,-10,0,32), pos=UDim2.new(0,8,0,28), font=T.font, color=T.accent, align=Enum.TextXAlignment.Left}, card)
	return val
end

local dmgVal  = makeStatCard("⚔️", "DAMAGE", "damage")
local killVal = makeStatCard("💀", "KILLS", "kills")

-- ============================================================
-- TOP CENTER — game title strip (subtle, small)
-- ============================================================
local topStrip = Instance.new("Frame")
topStrip.Size = UDim2.new(0, 240, 0, 32)
topStrip.Position = UDim2.new(0.5, -120, 0, 8)
topStrip.BackgroundColor3 = T.bgCard
topStrip.BackgroundTransparency = 0.1
topStrip.BorderSizePixel = 0
topStrip.Parent = sg
corner(UDim.new(0,16), topStrip)
stroke(T.accent, 1, topStrip)

makeLabel({text="🦁  BEAST BRAWL  ⚔️", font=T.font, color=T.accent}, topStrip)

-- ============================================================
-- EQUIP BADGE (bottom left — shows current weapon/armor)
-- ============================================================
local equipBadge = Instance.new("Frame")
equipBadge.Size = UDim2.new(0, 200, 0, 44)
equipBadge.Position = UDim2.new(0, 10, 1, -56)
equipBadge.BackgroundColor3 = T.bgCard
equipBadge.BackgroundTransparency = 0.1
equipBadge.BorderSizePixel = 0
equipBadge.Parent = sg
corner(T.radius, equipBadge)
stroke(T.border, 1, equipBadge)

local equipLabel = makeLabel({text="👊 Fists  |  👕 None", color=T.textMuted, font=T.fontReg}, equipBadge)

-- ============================================================
-- TOKEN UPDATE HOOK
-- ============================================================
local casinoF = ReplicatedStorage:WaitForChild("Casino", 10)
if casinoF then
	local tu = casinoF:WaitForChild("TokenUpdate", 5)
	if tu then
		tu.OnClientEvent:Connect(function(tokens)
			tokenCount.Text = tostring(tokens)
		end)
	end
end

-- ============================================================
-- STATS UPDATE HOOK
-- ============================================================
local combatF = ReplicatedStorage:WaitForChild("ArenaCombat", 8)
local totalDmg, totalKills = 0, 0
if combatF then
	local hitEv = combatF:FindFirstChild("Hit")
	if hitEv then
		hitEv.OnClientEvent:Connect(function(damage)
			if damage and damage > 0 then
				totalDmg = totalDmg + damage
				dmgVal.Text = tostring(math.floor(totalDmg))
				-- flash
				TweenService:Create(dmgVal,TweenInfo.new(0.08),{TextColor3=T.accent}):Play()
				wait(0.08)
				TweenService:Create(dmgVal,TweenInfo.new(0.25),{TextColor3=T.textPrimary}):Play()
			end
		end)
	end
end

-- Load saved stats
local statsF = ReplicatedStorage:WaitForChild("PlayerStats", 8)
if statsF then
	local gs = statsF:FindFirstChild("GetStats")
	if gs then
		local data = gs:InvokeServer()
		if data then
			totalDmg = data.damage or 0
			totalKills = data.kills or 0
			dmgVal.Text = tostring(math.floor(totalDmg))
			killVal.Text = tostring(totalKills)
		end
	end
end

-- ============================================================
-- WIRE BUTTON CALLBACKS TO EXISTING PANELS
-- ============================================================
-- We expose the button references via _G so other scripts can wire them
_G.HUDButtons = sideButtons
_G.EquipLabel = equipLabel

-- Poll for existing panels and rewire their toggle buttons
spawn(function()
	wait(2)
	-- Find and hide old buttons from CasinoUI/ShopUI/LeaderboardUI
	for _, guiName in ipairs({"CasinoGui","ShopGui","LeaderboardGui","DamageCounterGui","SpeedLines"}) do
		local old = playerGui:FindFirstChild(guiName)
		if old then
			-- Hide only the old toggle buttons; keep panels alive
			for _, child in ipairs(old:GetChildren()) do
				if child:IsA("TextButton") then child.Visible = false end
			end
		end
	end

	-- Wire our new buttons to toggle existing panels
	local casinoGui = playerGui:FindFirstChild("CasinoGui")
	local shopGui   = playerGui:FindFirstChild("ShopGui")
	local lbGui     = playerGui:FindFirstChild("LeaderboardGui")
	local adminGui  = playerGui:FindFirstChild("AdminGui")

	if sideButtons.casino and casinoGui then
		local casinoPanel = casinoGui:FindFirstChild("CasinoPanel")
		sideButtons.casino.MouseButton1Click:Connect(function()
			if casinoPanel then casinoPanel.Visible = not casinoPanel.Visible end
		end)
	end

	if sideButtons.shop and shopGui then
		local shopPanel = shopGui:FindFirstChild("ShopPanel")
		sideButtons.shop.MouseButton1Click:Connect(function()
			if shopPanel then shopPanel.Visible = not shopPanel.Visible end
		end)
	end

	if sideButtons.ranks and lbGui then
		local lbPanel = lbGui:FindFirstChild("Frame") or lbGui:FindFirstChildOfClass("Frame")
		sideButtons.ranks.MouseButton1Click:Connect(function()
			if lbPanel then lbPanel.Visible = not lbPanel.Visible end
		end)
	end

	if sideButtons.admin and adminGui then
		local adminPanel = adminGui:FindFirstChild("Frame") or adminGui:FindFirstChildOfClass("Frame")
		sideButtons.admin.MouseButton1Click:Connect(function()
			if adminPanel then adminPanel.Visible = not adminPanel.Visible end
		end)
	end
end)

print("[UITheme] ✨ Clean premium HUD loaded!")
