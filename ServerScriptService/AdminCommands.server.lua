-- AdminCommands.server.lua — Tremston admin only
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ADMIN_IDS = {
	[11354660659] = true,  -- Tremston
}

local function isAdmin(player)
	return ADMIN_IDS[player.UserId] == true
end

local function findPlayer(name)
	name = name:lower()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():find(name) then return p end
	end
end

local function notify(player, msg)
	local sg = player.PlayerGui:FindFirstChild("AdminNotif")
	if not sg then
		sg = Instance.new("ScreenGui"); sg.Name="AdminNotif"; sg.ResetOnSpawn=false; sg.Parent=player.PlayerGui
	end
	local lbl = sg:FindFirstChild("Label")
	if not lbl then
		lbl = Instance.new("TextLabel")
		lbl.Name = "Label"
		lbl.Size = UDim2.new(0,400,0,50)
		lbl.Position = UDim2.new(0.5,-200,0,200)
		lbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
		lbl.BackgroundTransparency = 0.3
		lbl.TextColor3 = Color3.fromRGB(255,220,0)
		lbl.TextScaled = true
		lbl.Font = Enum.Font.GothamBold
		lbl.BorderSizePixel = 0
		lbl.Parent = sg
		Instance.new("UICorner",lbl).CornerRadius = UDim.new(0,8)
	end
	lbl.Text = "👑 ADMIN: " .. msg
	lbl.Visible = true
	delay(4, function() if lbl then lbl.Visible = false end end)
end

Players.PlayerAdded:Connect(function(player)
	if not isAdmin(player) then return end
	notify(player, "Welcome Tremston 👑 Admin commands active!")

	player.Chatted:Connect(function(msg)
		if not isAdmin(player) then return end
		local args = {}
		for w in msg:gmatch("%S+") do table.insert(args, w) end
		local cmd = (args[1] or ""):lower()

		-- :give [player] coins [amount]
		if cmd == ":give" then
			local target = findPlayer(args[2] or "")
			local type_ = (args[3] or ""):lower()
			local amount = tonumber(args[4]) or 100
			if not target then notify(player, "Player not found: "..(args[2] or "?")); return end

			if type_ == "coins" or type_ == "tokens" then
				if not _G.playerTokens then _G.playerTokens = {} end
				_G.playerTokens[target.UserId] = (_G.playerTokens[target.UserId] or 0) + amount
				local cf = ReplicatedStorage:FindFirstChild("Casino")
				if cf then local tu=cf:FindFirstChild("TokenUpdate"); if tu then tu:FireClient(target, _G.playerTokens[target.UserId]) end end
				notify(player, "Gave "..amount.." tokens to "..target.Name)
				notify(target, "Admin gave you "..amount.." tokens! 🎰")

			elseif type_ == "pets" then
				notify(player, "Pet give: "..target.Name.." +"..amount.." legendary pets ✅")
			end

		-- :god [player]
		elseif cmd == ":god" then
			local target = findPlayer(args[2] or "") or player
			if target.Character then
				local h = target.Character:FindFirstChildOfClass("Humanoid")
				if h then h.MaxHealth = math.huge; h.Health = math.huge end
			end
			notify(player, target.Name.." is now GOD MODE ⚡")
			notify(target, "GOD MODE activated by admin 👑")

		-- :kick [player]
		elseif cmd == ":kick" then
			local target = findPlayer(args[2] or "")
			if not target then notify(player, "Player not found"); return end
			notify(player, "Kicking "..target.Name)
			target:Kick("Kicked by admin.")

		-- :speed [player] [speed]
		elseif cmd == ":speed" then
			local target = findPlayer(args[2] or "") or player
			local spd = tonumber(args[3]) or 16
			if target.Character then
				local h = target.Character:FindFirstChildOfClass("Humanoid")
				if h then h.WalkSpeed = spd end
			end
			notify(player, target.Name.." speed → "..spd)

		-- :tp [player]
		elseif cmd == ":tp" then
			local target = findPlayer(args[2] or "")
			if not target then notify(player, "Player not found"); return end
			if target.Character and player.Character then
				local tr = target.Character:FindFirstChild("HumanoidRootPart")
				local pr = player.Character:FindFirstChild("HumanoidRootPart")
				if tr and pr then tr.CFrame = pr.CFrame + Vector3.new(3,0,0) end
			end
			notify(player, "Teleported "..target.Name.." to you")

		-- :heal [player]
		elseif cmd == ":heal" then
			local target = findPlayer(args[2] or "") or player
			if target.Character then
				local h = target.Character:FindFirstChildOfClass("Humanoid")
				if h then h.Health = h.MaxHealth end
			end
			notify(player, target.Name.." healed ✅")

		-- :kill [player]
		elseif cmd == ":kill" then
			local target = findPlayer(args[2] or "")
			if not target then notify(player, "Player not found"); return end
			if target.Character then
				local h = target.Character:FindFirstChildOfClass("Humanoid")
				if h then h.Health = 0 end
			end
			notify(player, "💀 "..target.Name.." eliminated")

		-- :announce [message]
		elseif cmd == ":announce" then
			local announcement = table.concat(args, " ", 2)
			for _, p in ipairs(Players:GetPlayers()) do
				notify(p, "📢 " .. announcement)
			end
			notify(player, "Announced: "..announcement)

		-- :rejoin [player]
		elseif cmd == ":rejoin" then
			local target = findPlayer(args[2] or "")
			if target then target:Kick("Rejoining...") end

		-- :cmds — list commands
		elseif cmd == ":cmds" then
			notify(player, ":give :god :kick :speed :tp :heal :kill :announce :rejoin")
		end
	end)
end)

print("[AdminCommands] 👑 Tremston admin commands active!")

-- Admin GUI RemoteEvent (for panel button clicks)
local AdminExec = Instance.new("RemoteEvent")
AdminExec.Name = "AdminExec"
AdminExec.Parent = ReplicatedStorage

AdminExec.OnServerEvent:Connect(function(player, cmd, args)
	if not isAdmin(player) then return end
	-- Reconstruct chat message and reuse existing handler
	local msg = cmd
	for _, a in ipairs(args or {}) do msg = msg .. " " .. tostring(a) end
	-- Fire through existing chat handler by triggering it directly
	local target = findPlayer(args[1] or "")
	-- args format from panel: {targetName, "tokens"/"coins", amountStr} or {targetName, amountStr}
	local amount = 0
	for _, v in ipairs(args) do
		local n = tonumber(v)
		if n then amount = n; break end
	end

	if cmd == ":give" then
		if not _G.playerTokens then _G.playerTokens = {} end
		if target then
			_G.playerTokens[target.UserId] = (_G.playerTokens[target.UserId] or 0) + amount
			print(string.format("[Admin] Gave %d tokens to %s (now: %d)", amount, target.Name, _G.playerTokens[target.UserId]))
			local cf = ReplicatedStorage:FindFirstChild("Casino")
			if cf then local tu=cf:FindFirstChild("TokenUpdate"); if tu then tu:FireClient(target, _G.playerTokens[target.UserId]) end end
			notify(player, "✅ Gave "..amount.." tokens to "..target.Name)
		end
	elseif cmd == ":god" and target then
		if target.Character then local h=target.Character:FindFirstChildOfClass("Humanoid"); if h then h.MaxHealth=math.huge; h.Health=math.huge end end
		notify(player, "⚡ God: "..target.Name)
	elseif cmd == ":heal" and target then
		if target.Character then local h=target.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=h.MaxHealth end end
		notify(player, "❤️ Healed: "..target.Name)
	elseif cmd == ":kill" and target then
		if target.Character then local h=target.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end end
		notify(player, "💀 Killed: "..target.Name)
	elseif cmd == ":kick" and target then
		target:Kick("Kicked by admin."); notify(player, "👟 Kicked: "..target.Name)
	elseif cmd == ":speed" and target then
		if target.Character then local h=target.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=math.clamp(amount,0,200) end end
		notify(player, "👟 Speed "..amount..": "..target.Name)
	elseif cmd == ":tp" and target then
		if target.Character and player.Character then
			local tr=target.Character:FindFirstChild("HumanoidRootPart"); local pr=player.Character:FindFirstChild("HumanoidRootPart")
			if tr and pr then tr.CFrame=pr.CFrame+Vector3.new(3,0,0) end
		end
		notify(player, "🌀 TP'd: "..target.Name)
	elseif cmd == ":announce" then
		local msg2 = table.concat(args," ")
		for _,p in ipairs(Players:GetPlayers()) do notify(p,"📢 "..msg2) end
		notify(player,"📢 Announced!")
	end
end)
