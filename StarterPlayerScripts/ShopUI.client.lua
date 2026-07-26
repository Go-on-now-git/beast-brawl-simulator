-- ShopUI.client.lua — Weapon & Armor Shop + Robux Token Bundles

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local shopFolder = ReplicatedStorage:WaitForChild("Shop", 10)
if not shopFolder then return end

local BuyItem = shopFolder:WaitForChild("BuyItem")
local EquipItem = shopFolder:WaitForChild("EquipItem")
local ShopResult = shopFolder:WaitForChild("ShopResult")
local GetShopData = shopFolder:WaitForChild("GetShopData")
local GetEquipment = shopFolder:WaitForChild("GetEquipment")

local shopData = GetShopData:InvokeServer()
local equipData = GetEquipment:InvokeServer()
local currentTab = "weapons"

-- Robux token bundles (match your DevProduct IDs in Creator Dashboard)
local ROBUX_BUNDLES = {
	{label="🎰 500 Tokens",   robux=25,  productId=0000000001},
	{label="🎰 1,200 Tokens", robux=50,  productId=0000000002},
	{label="🎰 3,000 Tokens", robux=100, productId=0000000003},
	{label="🎰 8,000 Tokens", robux=250, productId=0000000004},
	{label="🎰 25,000 Tokens",robux=700, productId=0000000005},
}

-- ============================================================
-- SCREEN GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Shop open button
local shopBtn = Instance.new("TextButton")
shopBtn.Size = UDim2.new(0, 140, 0, 44)
shopBtn.Position = UDim2.new(1, -150, 1, -115)
shopBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 255)
shopBtn.Text = "⚔️ SHOP"
shopBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
shopBtn.TextScaled = true
shopBtn.Font = Enum.Font.GothamBold
shopBtn.BorderSizePixel = 0
shopBtn.Parent = screenGui
Instance.new("UICorner", shopBtn).CornerRadius = UDim.new(0, 12)

-- Equip display HUD
local equipHud = Instance.new("Frame")
equipHud.Size = UDim2.new(0, 200, 0, 55)
equipHud.Position = UDim2.new(0, 10, 1, -70)
equipHud.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
equipHud.BorderSizePixel = 0
equipHud.Parent = screenGui
Instance.new("UICorner", equipHud).CornerRadius = UDim.new(0, 10)

local equipLabel = Instance.new("TextLabel")
equipLabel.Size = UDim2.new(1, 0, 1, 0)
equipLabel.BackgroundTransparency = 1
equipLabel.Text = "⚔️ Fists | 👕 No Armor"
equipLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
equipLabel.TextScaled = true
equipLabel.Font = Enum.Font.GothamBold
equipLabel.Parent = equipHud

-- ============================================================
-- SHOP PANEL
-- ============================================================
local panel = Instance.new("Frame")
panel.Name = "ShopPanel"
panel.Size = UDim2.new(0, 480, 0, 580)
panel.Position = UDim2.new(0.5, -240, 0.5, -290)
panel.BackgroundColor3 = Color3.fromRGB(12, 8, 28)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

-- Header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(50, 180, 255)
header.Text = "⚔️  BEAST BRAWL SHOP  ⚔️"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.TextScaled = true
header.Font = Enum.Font.GothamBold
header.BorderSizePixel = 0
header.Parent = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

-- Tab buttons
local tabData = {
	{name="weapons", label="⚔️ Weapons"},
	{name="armors",  label="🛡️ Armor"},
	{name="robux",   label="💎 Robux"},
}
local tabBtns = {}
for i, t in ipairs(tabData) do
	local tb = Instance.new("TextButton")
	tb.Size = UDim2.new(0, 148, 0, 36)
	tb.Position = UDim2.new(0, 8 + (i-1)*157, 0, 55)
	tb.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
	tb.Text = t.label
	tb.TextColor3 = Color3.fromRGB(255,255,255)
	tb.TextScaled = true
	tb.Font = Enum.Font.GothamBold
	tb.BorderSizePixel = 0
	tb.Parent = panel
	Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
	tabBtns[t.name] = tb
end

-- Scroll frame for items
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -16, 1, -140)
scrollFrame.Position = UDim2.new(0, 8, 0, 98)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scrollFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 35)
statusLabel.Position = UDim2.new(0, 8, 1, -42)
statusLabel.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
statusLabel.Text = "Select an item to buy or equip"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.BorderSizePixel = 0
statusLabel.Parent = panel
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 8)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 44, 0, 35)
closeBtn.Position = UDim2.new(1, -50, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
closeBtn.Text = "✖"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = panel
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- ============================================================
-- ITEM ROW BUILDER
-- ============================================================
local function clearScroll()
	for _, c in ipairs(scrollFrame:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
end

local function buildRow(item, itemType, owned, equipped)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -8, 0, 64)
	row.BackgroundColor3 = equipped and Color3.fromRGB(30, 60, 30) or Color3.fromRGB(25, 20, 45)
	row.BorderSizePixel = 0
	row.Parent = scrollFrame
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	-- Item name
	local nameL = Instance.new("TextLabel")
	nameL.Size = UDim2.new(0.55, 0, 0.5, 0)
	nameL.Position = UDim2.new(0, 8, 0, 0)
	nameL.BackgroundTransparency = 1
	nameL.Text = item.name
	nameL.TextColor3 = equipped and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 255, 255)
	nameL.TextXAlignment = Enum.TextXAlignment.Left
	nameL.TextScaled = true
	nameL.Font = Enum.Font.GothamBold
	nameL.Parent = row

	-- Desc
	local descL = Instance.new("TextLabel")
	descL.Size = UDim2.new(0.55, 0, 0.5, 0)
	descL.Position = UDim2.new(0, 8, 0.5, 0)
	descL.BackgroundTransparency = 1
	descL.Text = item.desc
	descL.TextColor3 = Color3.fromRGB(160, 160, 200)
	descL.TextXAlignment = Enum.TextXAlignment.Left
	descL.TextScaled = true
	descL.Font = Enum.Font.Gotham
	descL.Parent = row

	-- Cost
	local costL = Instance.new("TextLabel")
	costL.Size = UDim2.new(0.2, 0, 1, 0)
	costL.Position = UDim2.new(0.55, 0, 0, 0)
	costL.BackgroundTransparency = 1
	costL.Text = item.cost == 0 and "FREE" or ("🎰 " .. item.cost)
	costL.TextColor3 = Color3.fromRGB(255, 200, 0)
	costL.TextScaled = true
	costL.Font = Enum.Font.GothamBold
	costL.Parent = row

	-- Action button
	local actionBtn = Instance.new("TextButton")
	actionBtn.Size = UDim2.new(0.2, -4, 0.7, 0)
	actionBtn.Position = UDim2.new(0.8, 2, 0.15, 0)
	actionBtn.BorderSizePixel = 0
	actionBtn.TextScaled = true
	actionBtn.Font = Enum.Font.GothamBold
	actionBtn.Parent = row
	Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

	if equipped then
		actionBtn.Text = "✅ ON"
		actionBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
		actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	elseif owned then
		actionBtn.Text = "EQUIP"
		actionBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
		actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		actionBtn.MouseButton1Click:Connect(function()
			EquipItem:FireServer(itemType, item.id)
		end)
	else
		actionBtn.Text = "BUY"
		actionBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
		actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		actionBtn.MouseButton1Click:Connect(function()
			BuyItem:FireServer(itemType, item.id)
		end)
	end

	return row
end

local function buildRobuxRow(bundle)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -8, 0, 64)
	row.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
	row.BorderSizePixel = 0
	row.Parent = scrollFrame
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local nameL = Instance.new("TextLabel")
	nameL.Size = UDim2.new(0.6, 0, 1, 0)
	nameL.Position = UDim2.new(0, 8, 0, 0)
	nameL.BackgroundTransparency = 1
	nameL.Text = bundle.label
	nameL.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameL.TextXAlignment = Enum.TextXAlignment.Left
	nameL.TextScaled = true
	nameL.Font = Enum.Font.GothamBold
	nameL.Parent = row

	local priceL = Instance.new("TextLabel")
	priceL.Size = UDim2.new(0.2, 0, 1, 0)
	priceL.Position = UDim2.new(0.6, 0, 0, 0)
	priceL.BackgroundTransparency = 1
	priceL.Text = "R$ " .. bundle.robux
	priceL.TextColor3 = Color3.fromRGB(0, 200, 100)
	priceL.TextScaled = true
	priceL.Font = Enum.Font.GothamBold
	priceL.Parent = row

	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0.18, -4, 0.7, 0)
	buyBtn.Position = UDim2.new(0.81, 2, 0.15, 0)
	buyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
	buyBtn.Text = "BUY"
	buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyBtn.TextScaled = true
	buyBtn.Font = Enum.Font.GothamBold
	buyBtn.BorderSizePixel = 0
	buyBtn.Parent = row
	Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 6)

	buyBtn.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(player, bundle.productId)
	end)

	return row
end

-- ============================================================
-- REFRESH SHOP
-- ============================================================
local function refreshShop()
	clearScroll()
	equipData = GetEquipment:InvokeServer()
	local owned = equipData.owned
	local equipped = equipData.equipped

	if currentTab == "weapons" then
		for _, w in ipairs(shopData.weapons) do
			local isOwned = owned.weapons[w.id]
			local isEquipped = equipped.weapon == w.id
			buildRow(w, "weapon", isOwned, isEquipped)
		end
	elseif currentTab == "armors" then
		for _, a in ipairs(shopData.armors) do
			local isOwned = owned.armors[a.id]
			local isEquipped = equipped.armor == a.id
			buildRow(a, "armor", isOwned, isEquipped)
		end
	elseif currentTab == "robux" then
		for _, b in ipairs(ROBUX_BUNDLES) do
			buildRobuxRow(b)
		end
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)

	-- Update equip HUD
	local wName = "Fists"
	local aName = "No Armor"
	for _, w in ipairs(shopData.weapons) do
		if w.id == equipped.weapon then wName = w.name end
	end
	for _, a in ipairs(shopData.armors) do
		if a.id == equipped.armor then aName = a.name end
	end
	equipLabel.Text = wName .. " | " .. aName

	-- Highlight active tab
	for name, btn in pairs(tabBtns) do
		btn.BackgroundColor3 = name == currentTab
			and Color3.fromRGB(50, 180, 255)
			or  Color3.fromRGB(40, 40, 80)
	end
end

-- ============================================================
-- EVENTS
-- ============================================================
local shopOpen = false

shopBtn.MouseButton1Click:Connect(function()
	shopOpen = not shopOpen
	panel.Visible = shopOpen
	if shopOpen then refreshShop() end
end)

closeBtn.MouseButton1Click:Connect(function()
	shopOpen = false
	panel.Visible = false
end)

for _, t in ipairs(tabData) do
	tabBtns[t.name].MouseButton1Click:Connect(function()
		currentTab = t.name
		refreshShop()
	end)
end

ShopResult.OnClientEvent:Connect(function(success, msg, itemType, itemId)
	statusLabel.Text = (success and "✅ " or "❌ ") .. msg
	statusLabel.TextColor3 = success and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,80,80)
	if success and itemType then
		refreshShop()
	end
	-- Fade back
	delay(3, function()
		statusLabel.Text = "Select an item to buy or equip"
		statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	end)
end)

print("[ShopUI] ⚔️ Shop UI loaded!")
