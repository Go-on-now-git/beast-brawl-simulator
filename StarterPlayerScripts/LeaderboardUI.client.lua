-- LeaderboardUI.client.lua — Top Fighters + Top Spenders (Donor Board)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local statsFolder = ReplicatedStorage:WaitForChild("PlayerStats", 10)
if not statsFolder then return end
local GetLB = statsFolder:WaitForChild("GetLeaderboard")

local sg = Instance.new("ScreenGui"); sg.Name="LeaderboardGui"; sg.ResetOnSpawn=false; sg.Parent=playerGui

-- Toggle button (top left)
local lbBtn = Instance.new("TextButton")
lbBtn.Size = UDim2.new(0,130,0,40)
lbBtn.Position = UDim2.new(0,10,0,10)
lbBtn.BackgroundColor3 = Color3.fromRGB(255,180,0)
lbBtn.Text = "🏆 RANKS"
lbBtn.TextColor3 = Color3.fromRGB(0,0,0)
lbBtn.TextScaled = true
lbBtn.Font = Enum.Font.GothamBold
lbBtn.BorderSizePixel = 0
lbBtn.Parent = sg
Instance.new("UICorner",lbBtn).CornerRadius = UDim.new(0,10)

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,360,0,440)
panel.Position = UDim2.new(0,10,0,58)
panel.BackgroundColor3 = Color3.fromRGB(10,8,25)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = sg
Instance.new("UICorner",panel).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,45)
title.BackgroundColor3 = Color3.fromRGB(255,180,0)
title.Text = "🏆 BEAST BRAWL RANKINGS"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Parent = panel
Instance.new("UICorner",title).CornerRadius = UDim.new(0,14)

-- Tab buttons
local tabs = {{"⚔️ Top Fighters","fighters"},{"💰 Top Spenders","spenders"}}
local tabBtns = {}
for i,t in ipairs(tabs) do
	local tb = Instance.new("TextButton")
	tb.Size = UDim2.new(0.5,-6,0,34)
	tb.Position = UDim2.new((i-1)*0.5, i==1 and 4 or 2, 0, 48)
	tb.BackgroundColor3 = Color3.fromRGB(40,40,80)
	tb.Text = t[1]; tb.TextColor3 = Color3.fromRGB(255,255,255)
	tb.TextScaled = true; tb.Font = Enum.Font.GothamBold; tb.BorderSizePixel = 0
	tb.Parent = panel
	Instance.new("UICorner",tb).CornerRadius = UDim.new(0,8)
	tabBtns[t[2]] = tb
end

-- List frame
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1,-12,1,-100)
listFrame.Position = UDim2.new(0,6,0,88)
listFrame.BackgroundTransparency = 1
listFrame.Parent = panel

local medals = {"🥇","🥈","🥉","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣","🔟"}

local function buildList(lbType)
	for _,c in ipairs(listFrame:GetChildren()) do c:Destroy() end
	local data = GetLB:InvokeServer(lbType)
	if #data == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1,0,0,40)
		empty.BackgroundTransparency = 1
		empty.Text = "No data yet — go fight! ⚔️"
		empty.TextColor3 = Color3.fromRGB(180,180,180)
		empty.TextScaled = true
		empty.Font = Enum.Font.Gotham
		empty.Parent = listFrame
		return
	end
	for i,entry in ipairs(data) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1,0,0,32)
		row.Position = UDim2.new(0,0,0,(i-1)*36)
		row.BackgroundColor3 = i==1 and Color3.fromRGB(50,40,10) or Color3.fromRGB(20,18,40)
		row.BorderSizePixel = 0
		row.Parent = listFrame
		Instance.new("UICorner",row).CornerRadius = UDim.new(0,6)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1,-8,1,0)
		lbl.Position = UDim2.new(0,4,0,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = (medals[i] or "#"..i).."  "..entry.name.."   "..entry.value..(lbType=="fighters" and " kills" or " tokens spent")
		lbl.TextColor3 = i==1 and Color3.fromRGB(255,215,0) or Color3.fromRGB(220,220,255)
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextScaled = true
		lbl.Font = i<=3 and Enum.Font.GothamBold or Enum.Font.Gotham
		lbl.Parent = row
	end
	-- highlight active tab
	for k,tb in pairs(tabBtns) do
		tb.BackgroundColor3 = k==lbType and Color3.fromRGB(255,180,0) or Color3.fromRGB(40,40,80)
		tb.TextColor3 = k==lbType and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
	end
end

local open = false
local curTab = "fighters"
lbBtn.MouseButton1Click:Connect(function()
	open = not open; panel.Visible = open
	if open then buildList(curTab) end
end)
for _,t in ipairs(tabs) do
	tabBtns[t[2]].MouseButton1Click:Connect(function()
		curTab = t[2]; buildList(curTab)
	end)
end

print("[LeaderboardUI] 🏆 Rankings loaded!")
