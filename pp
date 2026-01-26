local Module = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

Module.player = Players.LocalPlayer
Module.character = nil
Module.rootPart = nil
Module.camera = workspace.CurrentCamera

Module.farmActive = false
Module.huntActive = false
Module.babyDinoActive = false
Module.flightActive = false
Module.lockCamera = false
Module.SAFETY_MULTIPLIER = 1.5
Module.MIN_SAFE_DISTANCE = 250
Module.TELEPORT_HEIGHT = 20
Module.targetType = "All"
Module.cameraCFrame = nil
Module.flightSpeed = 50

Module.bodyVelocity = nil
Module.bodyGyro = nil

Module.lastRefresh = 0

Module.playerRadiusCache = {}
Module.playerPositions = {}

function Module.updateCharacter()
	Module.character = Module.player.Character
	if Module.character then
		Module.rootPart = Module.character:FindFirstChild("HumanoidRootPart") or Module.character:FindFirstChildWhichIsA("BasePart")
	end
end

Module.updateCharacter()

Module.player.CharacterAdded:Connect(function(char)
	Module.character = char
	Module.rootPart = nil
	
	task.wait(0.1)
	Module.rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
	
	if Module.bodyVelocity then
		Module.bodyVelocity:Destroy()
		Module.bodyVelocity = nil
	end
	if Module.bodyGyro then
		Module.bodyGyro:Destroy()
		Module.bodyGyro = nil
	end
	
	if Module.flightActive then
		Module.enableFlight()
	end
end)

function Module.formatGrowth(num)
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(math.floor(num))
	end
end

function Module.updateStats(growthLabel, rankLabel)
	if Module.character and Module.character:GetAttribute("Growth") then
		local growth = Module.character:GetAttribute("Growth")
		growthLabel:SetText("Growth : " .. Module.formatGrowth(growth))
		
		local allPlayers = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				table.insert(allPlayers, {p = p, g = p.Character:GetAttribute("Growth") or 0})
			end
		end
		
		table.sort(allPlayers, function(a, b) return a.g > b.g end)
		
		for rank, data in ipairs(allPlayers) do
			if data.p == Module.player then
				rankLabel:SetText(string.format("Rank : #%d/%d", rank, #allPlayers))
				return
			end
		end
	end
end

function Module.getPlayerRadius(character)
	if not character then return Module.MIN_SAFE_DISTANCE end
	
	local foodRadiusPart = character:FindFirstChild("FoodCollectionRadius", true)
	if foodRadiusPart then
		if foodRadiusPart:IsA("BasePart") then
			local size = foodRadiusPart.Size
			local radius = math.max(size.X, size.Y, size.Z)
			return radius * Module.SAFETY_MULTIPLIER
		elseif foodRadiusPart:IsA("NumberValue") or foodRadiusPart:IsA("IntValue") then
			return foodRadiusPart.Value * Module.SAFETY_MULTIPLIER
		end
	end
	
	local attrRadius = character:GetAttribute("FoodCollectionRadius")
	if attrRadius then
		return attrRadius * Module.SAFETY_MULTIPLIER
	end
	
	return Module.MIN_SAFE_DISTANCE
end

function Module.updateRadiusCache()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Module.player and p.Character then
			local radius = Module.getPlayerRadius(p.Character)
			Module.playerRadiusCache[p.UserId] = math.max(radius, Module.MIN_SAFE_DISTANCE)
			
			local r = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart")
			if r then
				Module.playerPositions[p.UserId] = r.Position
			end
		end
	end
end

function Module.isSafeFromAllPlayers(pos)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Module.player and p.Character then
			local r = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart")
			if r then
				local safeDistance = Module.playerRadiusCache[p.UserId] or Module.MIN_SAFE_DISTANCE
				local distance = (pos - r.Position).Magnitude
				
				if distance < safeDistance then
					return false
				end
			end
		end
	end
	return true
end

function Module.willPositionBecomeSafe(pos)
	if not Module.rootPart then return false end
	
	local myCurrentPos = Module.rootPart.Position
	
	for userId, lastPos in pairs(Module.playerPositions) do
		local p = Players:GetPlayerByUserId(userId)
		if p and p.Character then
			local r = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart")
			if r then
				local currentPos = r.Position
				local movementVector = currentPos - lastPos
				local predictedPos = currentPos + movementVector
				
				local safeDistance = Module.playerRadiusCache[userId] or Module.MIN_SAFE_DISTANCE
				local predictedDistance = (pos - predictedPos).Magnitude
				
				if predictedDistance < safeDistance then
					return false
				end
			end
		end
	end
	
	return true
end

function Module.matchesTarget(name)
	local n = name:lower()
	
	if Module.targetType == "Meats" then
		return n:find("meat")
	elseif Module.targetType == "Eggs" then
		return n:find("egg")
	elseif Module.targetType == "Nests" then
		return n:find("nest")
	elseif Module.targetType == "All" then
		return n:find("meat") or n:find("egg") or n:find("nest")
	end
	
	return false
end

function Module.getAllItems()
	local items = {}
	
	for _, obj in ipairs(workspace:GetChildren()) do
		if Module.matchesTarget(obj.Name) then
			local pos
			
			if obj:IsA("Model") then
				local isPChar = false
				for _, p in ipairs(Players:GetPlayers()) do
					if p.Character == obj then
						isPChar = true
						break
					end
				end
				if isPChar then continue end
				
				if obj.Name:lower():find("egg") and #obj:GetChildren() == 0 then
					continue
				end
				
				if not obj.PrimaryPart then
					local part = obj:FindFirstChildWhichIsA("BasePart")
					if part then obj.PrimaryPart = part else continue end
				end
				pos = obj.PrimaryPart.Position
			elseif obj:IsA("BasePart") then
				pos = obj.Position
			end
			
			if pos and Module.isSafeFromAllPlayers(pos) and Module.willPositionBecomeSafe(pos) then
				table.insert(items, pos)
			end
		end
		
		for _, child in ipairs(obj:GetChildren()) do
			if Module.matchesTarget(child.Name) then
				local pos
				
				if child:IsA("Model") then
					if child.Name:lower():find("egg") and #child:GetChildren() == 0 then
						continue
					end
					
					if not child.PrimaryPart then
						local part = child:FindFirstChildWhichIsA("BasePart")
						if part then child.PrimaryPart = part else continue end
					end
					pos = child.PrimaryPart.Position
				elseif child:IsA("BasePart") then
					pos = child.Position
				end
				
				if pos and Module.isSafeFromAllPlayers(pos) and Module.willPositionBecomeSafe(pos) then
					table.insert(items, pos)
				end
			end
		end
	end
	
	return items
end

function Module.getNearestItem()
	if not Module.rootPart then return nil end
	
	local currentTime = tick()
	local allItems = {}
	
	if currentTime - Module.lastRefresh > 0.3 then
		allItems = Module.getAllItems()
		Module.lastRefresh = currentTime
	else
		return nil
	end
	
	if #allItems == 0 then
		return nil
	end
	
	local myPos = Module.rootPart.Position
	local nearest = nil
	local nearestDist = math.huge
	
	for _, itemPos in ipairs(allItems) do
		local dist = (myPos - itemPos).Magnitude
		if dist < nearestDist then
			nearestDist = dist
			nearest = itemPos
		end
	end
	
	return nearest
end

function Module.findWeakerPlayer()
	if not Module.character or not Module.rootPart then return nil end
	local myGrowth = Module.character:GetAttribute("Growth") or 0
	local targets = {}
	
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Module.player and p.Character then
			local theirGrowth = p.Character:GetAttribute("Growth") or 0
			if theirGrowth < myGrowth then
				local r = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart")
				if r then
					table.insert(targets, {pos = r.Position, dist = (Module.rootPart.Position - r.Position).Magnitude})
				end
			end
		end
	end
	
	table.sort(targets, function(a, b) return a.dist < b.dist end)
	
	return targets[1] and targets[1].pos or nil
end

function Module.findBabyDino()
	local baby = workspace:FindFirstChild("BabyDino")
	if baby then
		local part = baby:FindFirstChild("HumanoidRootPart") or baby:FindFirstChildWhichIsA("BasePart")
		if part then
			return part.Position
		end
	end
	return nil
end

function Module.enableFlight()
	if not Module.rootPart then return end
	
	if Module.bodyVelocity then
		Module.bodyVelocity:Destroy()
	end
	if Module.bodyGyro then
		Module.bodyGyro:Destroy()
	end
	
	Module.bodyVelocity = Instance.new("BodyVelocity")
	Module.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	Module.bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	Module.bodyVelocity.Parent = Module.rootPart
	
	Module.bodyGyro = Instance.new("BodyGyro")
	Module.bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	Module.bodyGyro.P = 9e4
	Module.bodyGyro.Parent = Module.rootPart
end

function Module.disableFlight()
	if Module.bodyVelocity then
		Module.bodyVelocity:Destroy()
		Module.bodyVelocity = nil
	end
	if Module.bodyGyro then
		Module.bodyGyro:Destroy()
		Module.bodyGyro = nil
	end
end

function Module.startLoop()
	RunService.Heartbeat:Connect(function()
		Module.updateRadiusCache()
	end)
	
	RunService.RenderStepped:Connect(function()
		if not Module.rootPart or not Module.rootPart.Parent then
			Module.updateCharacter()
			return
		end
		
		if Module.flightActive and Module.bodyVelocity and Module.bodyGyro then
			if not Module.bodyVelocity.Parent or not Module.bodyGyro.Parent then
				Module.enableFlight()
			end
			if Module.bodyVelocity and Module.bodyGyro then
				Module.bodyGyro.CFrame = Module.camera.CFrame
				Module.bodyVelocity.Velocity = Module.camera.CFrame.LookVector * Module.flightSpeed
			end
		end
		
		if Module.babyDinoActive then
			local target = Module.findBabyDino()
			if target then
				local newPos = target + Vector3.new(0, Module.TELEPORT_HEIGHT, 0)
				Module.rootPart.CFrame = CFrame.new(newPos)
			end
		elseif Module.huntActive then
			local target = Module.findWeakerPlayer()
			if target then
				local newPos = target + Vector3.new(0, Module.TELEPORT_HEIGHT, 0)
				Module.rootPart.CFrame = CFrame.new(newPos)
			end
		elseif Module.farmActive then
			local target = Module.getNearestItem()
			if target and Module.isSafeFromAllPlayers(target) and Module.willPositionBecomeSafe(target) then
				if Module.lockCamera then
					if not Module.cameraCFrame then
						Module.cameraCFrame = Module.camera.CFrame
						Module.camera.CameraType = Enum.CameraType.Scriptable
					end
					Module.camera.CFrame = Module.cameraCFrame
				end
				local newPos = target + Vector3.new(0, Module.TELEPORT_HEIGHT, 0)
				Module.rootPart.CFrame = CFrame.new(newPos)
			else
				if Module.lockCamera and Module.cameraCFrame then
					Module.camera.CameraType = Enum.CameraType.Custom
					Module.cameraCFrame = nil
				end
			end
		end
	end)
end

function Module.cleanup()
	Module.farmActive = false
	Module.huntActive = false
	Module.babyDinoActive = false
	Module.flightActive = false
	Module.lockCamera = false
	Module.camera.CameraType = Enum.CameraType.Custom
	Module.cameraCFrame = nil
	if Module.bodyVelocity then Module.bodyVelocity:Destroy() end
	if Module.bodyGyro then Module.bodyGyro:Destroy() end
end

return Module