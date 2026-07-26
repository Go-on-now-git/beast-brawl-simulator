-- AdminPanel.client.lua — Tremston-only clickable admin UI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Only show for Tremston
if player.UserId ~= 11354660659 then return end

local sg = Instance.new("ScreenGui"); sg.Name="AdminGui"; sg.ResetOnSpawn=false; sg.Parent=playerGui

-- Toggle button (below shop button, top right)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,140,0,44)
toggleBtn.Position = UDim2.new(1,-155,0,110)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
toggleBtn.Text = "👑 ADMIN"
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = sg
Instance.new("UICorner",toggleBtn).CornerRadius = UDim.new(0,12)

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,340,0,560)
panel.Position = UDim2.new(1,-360,0,160)
panel.BackgroundColor3 = Color3.fromRGB(15,5,5)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = sg
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,14)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1,0,0,48)
header.BackgroundColor3 = Color3.fromRGB(180,0,0)
header.Text = "👑 ADMIN PANEL — TREMSTON"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.TextScaled = true
header.Font = Enum.Font.GothamBold
header.BorderSizePixel = 0
header.Parent = panel
Instance.new("UICorner",header).CornerRadius = UDim.new(0,14)

-- Player selector
local playerLabel = Instance.new("TextLabel")
playerLabel.Size = UDim2.new(1,-16,0,28)
playerLabel.Position = UDim2.new(0,8,0,52)
playerLabel.BackgroundTransparency = 1
playerLabel.Text = "TARGET PLAYER:"
playerLabel.TextColor3 = Color3.fromRGB(180,180,180)
playerLabel.TextXAlignment = Enum.TextXAlignment.Left
playerLabel.TextScaled = true
playerLabel.Font = Enum.Font.Gotham
playerLabel.Parent = panel

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1,-16,0,80)
playerScroll.Position = UDim2.new(0,8,0,80)
playerScroll.BackgroundColor3 = Color3.fromRGB(30,10,10)
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.CanvasSize = UDim2.new(0,0,0,0)
playerScroll.Parent = panel
Instance.new("UICorner",playerScroll).CornerRadius = UDim.new(0,8)
Instance.new("UIListLayout",playerScroll).Padding = UDim.new(0,2)

local selectedTarget = nil
local playerBtns = {}

local function refreshPlayers()
	for _,b in ipairs(playerScroll:GetChildren()) do
		if b:IsA("TextButton") then b:Destroy() end
	end
	playerBtns = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local pb = Instance.new("TextButton")
		pb.Size = UDim2.new(1,0,0,28)
		pb.BackgroundColor3 = selectedTarget == p.Name and Color3.fromRGB(180,0,0) or Color3.fromRGB(50,20,20)
		pb.Text = (p == player and "👑 " or "👤 ") .. p.Name
		pb.TextColor3 = Color3.fromRGB(255,255,255)
		pb.TextScaled = true
		pb.Font = Enum.Font.GothamBold
		pb.BorderSizePixel = 0
		pb.Parent = playerScroll
		Instance.new("UICorner",pb).CornerRadius = UDim.new(0,4)
		pb.MouseButton1Click:Connect(function()
			selectedTarget = p.Name
			refreshPlayers()
		end)
		table.insert(playerBtns, pb)
	end
	playerScroll.CanvasSize = UDim2.new(0,0,0,#Players:GetPlayers()*30)
end

refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(function() wait(0.1); refreshPlayers() end)

-- Amount input
local amtLabel = Instance.new("TextLabel")
amtLabel.Size = UDim2.new(0.4,-4,0,30)
amtLabel.Position = UDim2.new(0,8,0,168)
amtLabel.BackgroundTransparency = 1
amtLabel.Text = "AMOUNT:"
amtLabel.TextColor3 = Color3.fromRGB(180,180,180)
amtLabel.TextXAlignment = Enum.TextXAlignment.Left
amtLabel.TextScaled = true
amtLabel.Font = Enum.Font.Gotham
amtLabel.Parent = panel

local amtBox = Instance.new("TextBox")
amtBox.Size = UDim2.new(0.55,0,0,30)
amtBox.Position = UDim2.new(0.43,0,0,168)
amtBox.BackgroundColor3 = Color3.fromRGB(40,15,15)
amtBox.Text = "1000"
amtBox.TextColor3 = Color3.fromRGB(255,255,255)
amtBox.TextScaled = true
amtBox.Font = Enum.Font.GothamBold
amtBox.BorderSizePixel = 0
amtBox.Parent = panel
Instance.new("UICorner",amtBox).CornerRadius = UDim.new(0,6)

-- Status bar
local statusBar = Instance.new("TextLabel")
statusBar.Size = UDim2.new(1,-16,0,28)
statusBar.Position = UDim2.new(0,8,0,204)
statusBar.BackgroundColor3 = Color3.fromRGB(30,15,0)
statusBar.Text = "Select a player and action"
statusBar.TextColor3 = Color3.fromRGB(255,200,0)
statusBar.TextScaled = true
statusBar.Font = Enum.Font.Gotham
statusBar.BorderSizePixel = 0
statusBar.Parent = panel
Instance.new("UICorner",statusBar).CornerRadius = UDim.new(0,6)

local function setStatus(msg, col)
	statusBar.Text = msg
	statusBar.TextColor3 = col or Color3.fromRGB(255,200,0)
end

-- Command buttons
local COMMANDS = {
	{label="💰 Give Tokens",  cmd=":give", args=function() return {selectedTarget,"tokens",amtBox.Text} end, col=Color3.fromRGB(200,140,0)},
	{label="⚡ God Mode",     cmd=":god",  args=function() return {selectedTarget} end,                      col=Color3.fromRGB(0,150,255)},
	{label="❤️ Heal",         cmd=":heal", args=function() return {selectedTarget} end,                      col=Color3.fromRGB(0,180,80)},
	{label="💀 Kill",         cmd=":kill", args=function() return {selectedTarget} end,                      col=Color3.fromRGB(200,0,0)},
	{label="👟 Speed",        cmd=":speed",args=function() return {selectedTarget,amtBox.Text} end,          col=Color3.fromRGB(100,100,255)},
	{label="🌀 Teleport",     cmd=":tp",   args=function() return {selectedTarget} end,                      col=Color3.fromRGB(150,0,200)},
	{label="👟 Kick",         cmd=":kick", args=function() return {selectedTarget} end,                      col=Color3.fromRGB(255,60,0)},
	{label="📢 Announce",     cmd=":announce",args=function() return {amtBox.Text} end,                     col=Color3.fromRGB(255,100,200)},
}

local COLS = 2
for i, cmd in ipairs(COMMANDS) do
	local row = math.ceil(i/COLS)
	local col = ((i-1) % COLS)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.5,-6,0,46)
	btn.Position = UDim2.new(col*0.5, col==0 and 8 or 2, 0, 236 + (row-1)*52)
	btn.BackgroundColor3 = cmd.col
	btn.Text = cmd.label
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent = panel
	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)

	btn.MouseButton1Click:Connect(function()
		if not selectedTarget and cmd.cmd ~= ":announce" then
			setStatus("❌ Select a target first!", Color3.fromRGB(255,80,80))
			return
		end
		local args = cmd.args()
		local chatMsg = cmd.cmd
		for _, a in ipairs(args) do chatMsg = chatMsg .. " " .. tostring(a) end
		player:SetAttribute("AdminCmd", chatMsg)
		setStatus("✅ " .. cmd.label .. " → " .. (selectedTarget or "all"), Color3.fromRGB(100,255,100))
		-- Fire via chat
		-- We use a RemoteEvent approach instead
		local adminF = ReplicatedStorage:FindFirstChild("AdminExec")
		if adminF then adminF:FireServer(cmd.cmd, args) end
	end)
end

-- Close btn
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1,-16,0,36)
closeBtn.Position = UDim2.new(0,8,1,-44)
closeBtn.BackgroundColor3 = Color3.fromRGB(60,20,20)
closeBtn.Text = "✖ CLOSE"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = panel
Instance.new("UICorner",closeBtn).CornerRadius = UDim.new(0,8)

local open = false
toggleBtn.MouseButton1Click:Connect(function()
	open = not open
	panel.Visible = open
	if open then refreshPlayers() end
	TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
		BackgroundColor3 = open and Color3.fromRGB(255,50,50) or Color3.fromRGB(180,0,0)
	}):Play()
end)
closeBtn.MouseButton1Click:Connect(function()
	open = false; panel.Visible = false
end)

print("[AdminPanel] 👑 Tremston admin GUI loaded!")
