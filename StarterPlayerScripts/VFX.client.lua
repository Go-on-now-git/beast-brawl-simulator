-- VFX.client.lua — Full Visual Effects System
-- Hit sparks, auras, trails, ambient particles, screen effects

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- AMBIENT PARTICLES on player (always on)
-- ============================================================
local function addAura(character)
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end

	-- Speed trail attachment
	local trailAtt0 = Instance.new("Attachment"); trailAtt0.Position = Vector3.new(0,1,0); trailAtt0.Parent = hrp
	local trailAtt1 = Instance.new("Attachment"); trailAtt1.Position = Vector3.new(0,-1,0); trailAtt1.Parent = hrp

	local trail = Instance.new("Trail")
	trail.Attachment0 = trailAtt0
	trail.Attachment1 = trailAtt1
	trail.Lifetime = 0.25
	trail.MinLength = 0.1
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,180,0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,50,200)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50,100,255)),
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Parent = hrp

	-- Ambient glow particles
	local glowAtt = Instance.new("Attachment"); glowAtt.Parent = hrp
	local particles = Instance.new("ParticleEmitter")
	particles.Attachment = glowAtt
	particles.Rate = 8
	particles.Lifetime = NumberRange.new(0.5, 1.2)
	particles.Speed = NumberRange.new(2, 6)
	particles.SpreadAngle = Vector2.new(360, 360)
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0),
	})
	particles.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,180,0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,50,0)),
	})
	particles.LightEmission = 0.8
	particles.RotSpeed = NumberRange.new(-90, 90)
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	particles.Parent = hrp
end

addAura(char)
player.CharacterAdded:Connect(addAura)

-- ============================================================
-- HIT SPARK VFX (fires on CoinSplatter event)
-- ============================================================
local combatFolder = ReplicatedStorage:WaitForChild("ArenaCombat", 8)

local function spawnHitSparks(worldPos, wasBlocked)
	-- Create a spark part at hit location
	local spark = Instance.new("Part")
	spark.Anchored = true
	spark.CanCollide = false
	spark.CastShadow = false
	spark.Size = Vector3.new(0.5,0.5,0.5)
	spark.CFrame = CFrame.new(worldPos)
	spark.Transparency = 1
	spark.Parent = workspace

	-- Spark particles
	local att = Instance.new("Attachment"); att.Parent = spark
	local pe = Instance.new("ParticleEmitter")
	pe.Attachment = att
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(0.2, 0.5)
	pe.Speed = NumberRange.new(15, 35)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 0),
	})
	pe.Color = wasBlocked and ColorSequence.new(Color3.fromRGB(100,180,255))
		or ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,200,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,80,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,100)),
		})
	pe.LightEmission = 1
	pe.RotSpeed = NumberRange.new(-360, 360)
	pe.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	pe.Parent = spark
	pe:Emit(wasBlocked and 8 or 20)

	-- Flash at hit point
	local flash = Instance.new("Part")
	flash.Anchored = true
	flash.CanCollide = false
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.new(3,3,3)
	flash.CFrame = CFrame.new(worldPos)
	flash.Color = wasBlocked and Color3.fromRGB(100,180,255) or Color3.fromRGB(255,150,0)
	flash.Material = Enum.Material.Neon
	flash.CastShadow = false
	flash.Parent = workspace

	TweenService:Create(flash, TweenInfo.new(0.15), {Size=Vector3.new(0.1,0.1,0.1), Transparency=1}):Play()
	game:GetService("Debris"):AddItem(flash, 0.2)
	game:GetService("Debris"):AddItem(spark, 0.6)
end

if combatFolder then
	local CoinSplatterEv = combatFolder:FindFirstChild("CoinSplatter")
	if CoinSplatterEv then
		CoinSplatterEv.OnClientEvent:Connect(function(worldPos, coins, damage, wasBlocked)
			spawnHitSparks(worldPos, wasBlocked)
		end)
	end
end

-- ============================================================
-- RUNNING SPEED LINES (brain rot fast VFX)
-- ============================================================
local humanoid = char:WaitForChild("Humanoid", 5)
local sgSpeed = Instance.new("ScreenGui"); sgSpeed.Name="SpeedLines"; sgSpeed.ResetOnSpawn=false; sgSpeed.Parent=playerGui

local speedFrame = Instance.new("ImageLabel")
speedFrame.Size = UDim2.new(1,0,1,0)
speedFrame.BackgroundTransparency = 1
speedFrame.Image = "rbxassetid://6034684950"
speedFrame.ImageTransparency = 1
speedFrame.ScaleType = Enum.ScaleType.Stretch
speedFrame.Parent = sgSpeed

player.CharacterAdded:Connect(function(c)
	char = c
	humanoid = c:WaitForChild("Humanoid",5)
end)

RunService.Heartbeat:Connect(function()
	if not humanoid then return end
	local speed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed
	local alpha = math.clamp((speed - 10) / 20, 0, 0.5)
	speedFrame.ImageTransparency = 1 - alpha
end)

-- ============================================================
-- AMBIENT MAP PARTICLES (sparkles floating around spawn)
-- ============================================================
local ambPart = Instance.new("Part")
ambPart.Anchored = true
ambPart.CanCollide = false
ambPart.Transparency = 1
ambPart.Size = Vector3.new(1,1,1)
ambPart.CFrame = CFrame.new(0,5,0)
ambPart.Parent = workspace

local ambAtt = Instance.new("Attachment"); ambAtt.Parent = ambPart
local ambPe = Instance.new("ParticleEmitter")
ambPe.Attachment = ambAtt
ambPe.Rate = 15
ambPe.Lifetime = NumberRange.new(3, 6)
ambPe.Speed = NumberRange.new(0, 3)
ambPe.SpreadAngle = Vector2.new(180, 180)
ambPe.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.1),
	NumberSequenceKeypoint.new(0.5, 0.3),
	NumberSequenceKeypoint.new(1, 0),
})
ambPe.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255,215,0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,100,200)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(100,150,255)),
})
ambPe.LightEmission = 0.9
ambPe.Rotation = NumberRange.new(0, 360)
ambPe.RotSpeed = NumberRange.new(-45, 45)
ambPe.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.5),
	NumberSequenceKeypoint.new(0.5, 0.1),
	NumberSequenceKeypoint.new(1, 1),
})
ambPe.Parent = ambPart

-- ============================================================
-- KILL VFX — explosion of coins + screen flash when you get a kill
-- ============================================================
local statsFolder = ReplicatedStorage:WaitForChild("PlayerStats", 8)
-- (hook into hit event for kill detection)

print("[VFX] ✨ Full VFX system loaded — sparks, aura, trail, particles, speed lines!")
