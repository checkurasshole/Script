local Module = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

Module.player = Players.LocalPlayer
Module.character = nil
Module.rootPart = nil
Module.camera = workspace.CurrentCamera

Module.farmActive = false
Module.huntActive = false
Module.babyDinoActive = false
Module.flightActive = false
Module.lockCamera = false

-- Reduced safety settings - more aggressive farming
Module.SAFETY_MULTIPLIER = 1.1
Module.MIN_SAFE_DISTANCE = 80
Module.BASE_SCAN_RADIUS = 200 -- Start scanning nearby
Module.MAX_SCAN_RADIUS = 500 -- Max scan distance
Module.EXTENDED_SCAN_RADIUS = 1000 -- For finding next farming zone
Module.currentScanRadius = 200 -- Dynamic scan radius

Module.TELEPORT_HEIGHT = 20
Module.targetType = "All"
Module.cameraCFrame = nil
Module.flightSpeed = 50
Module.movementMode = "Auto"

Module.bodyVelocity = nil
Module.bodyGyro = nil

Module.itemCache = {}
Module.lastCacheUpdate = 0
Module.CACHE_REFRESH_TIME = 3
Module.noItemsFoundCount = 0 -- Track how many times we found nothing
Module.MAX_NO_ITEMS_BEFORE_RELOCATE = 3

Module.playerRadiusCache = {}
Module.playerPositions = {}

Module.swimming = false
Module.swimSpeed = 100
Module.swimDestination = Vector3.new(0, 0, 0)
Module.isSwimmingToDestination = false
Module.oldGravity = workspace.Gravity
Module.swimBeat = nil
Module.gravReset = nil
Module.noclipConnection = nil

Module.isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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
	
	if Module.swimming then
		Module.stopSwim()
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

function Module.getAllFoodRadiusParts(character)
	local parts = {}
	for _, desc in ipairs(character:GetDescendants()) do
		if desc.Name == "FoodCollectionRadius" and desc:IsA("BasePart") then
			table.insert(parts, desc)
		end
	end
	return parts
end

function Module.getPlayerRadius(character)
	if not character then return Module.MIN_SAFE_DISTANCE end
	
	local foodParts = Module.getAllFoodRadiusParts(character)
	
	if #foodParts > 0 then
		local largestRadius = 0
		
		for _, part in ipairs(foodParts) do
			local size = part.Size
			local radius = math.max(size.X, size.Y, size.Z)
			if radius > largestRadius then
				largestRadius = radius
			end
		end
		
		if largestRadius > 0 then
			return largestRadius * Module.SAFETY_MULTIPLIER
		end
	end
	
	local foodRadiusPart = character:FindFirstChild("FoodCollectionRadius", true)
	if foodRadiusPart and (foodRadiusPart:IsA("NumberValue") or foodRadiusPart:IsA("IntValue")) then
		return foodRadiusPart.Value * Module.SAFETY_MULTIPLIER
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

-- Scan for items within a given radius
function Module.scanItemsInRadius(radius)
	if not Module.rootPart then return {} end
	
	local items = {}
	local myPos = Module.rootPart.Position
	
	local function addItem(obj)
		local pos
		
		if obj:IsA("Model") then
			local isPChar = false
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Character == obj then
					isPChar = true
					break
				end
			end
			if isPChar then return end
			
			local part = obj:FindFirstChildWhichIsA("BasePart", true)
			if part then
				pos = part.Position
			end
		elseif obj:IsA("BasePart") then
			pos = obj.Position
		end
		
		if pos then
			local distance = (myPos - pos).Magnitude
			
			if distance <= radius and Module.isSafeFromAllPlayers(pos) then
				table.insert(items, {pos = pos, dist = distance})
			end
		end
	end
	
	for _, obj in ipairs(workspace:GetDescendants()) do
		if Module.matchesTarget(obj.Name) then
			addItem(obj)
		end
	end
	
	table.sort(items, function(a, b) return a.dist < b.dist end)
	
	return items
end

-- Find the nearest cluster of items to relocate to
function Module.findNearestItemCluster()
	if not Module.rootPart then return nil end
	
	local myPos = Module.rootPart.Position
	local allItems = {}
	
	for _, obj in ipairs(workspace:GetDescendants()) do
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
				if isPChar then goto continue end
				
				local part = obj:FindFirstChildWhichIsA("BasePart", true)
				if part then
					pos = part.Position
				end
			elseif obj:IsA("BasePart") then
				pos = obj.Position
			end
			
			if pos then
				local distance = (myPos - pos).Magnitude
				-- Look for items beyond current scan radius but within extended range
				if distance > Module.currentScanRadius and distance <= Module.EXTENDED_SCAN_RADIUS then
					if Module.isSafeFromAllPlayers(pos) then
						table.insert(allItems, {pos = pos, dist = distance})
					end
				end
			end
			
			::continue::
		end
	end
	
	if #allItems == 0 then return nil end
	
	-- Sort by distance and return closest
	table.sort(allItems, function(a, b) return a.dist < b.dist end)
	
	return allItems[1].pos
end

function Module.updateItemCache()
	Module.itemCache = Module.scanItemsInRadius(Module.currentScanRadius)
	Module.lastCacheUpdate = tick()
	
	-- If we found items, reset the no-items counter
	if #Module.itemCache > 0 then
		Module.noItemsFoundCount = 0
		-- Gradually reduce scan radius back to base when finding items
		if Module.currentScanRadius > Module.BASE_SCAN_RADIUS then
			Module.currentScanRadius = math.max(Module.BASE_SCAN_RADIUS, Module.currentScanRadius - 50)
		end
	else
		Module.noItemsFoundCount = Module.noItemsFoundCount + 1
		
		-- Expand scan radius if we're not finding anything
		if Module.currentScanRadius < Module.MAX_SCAN_RADIUS then
			Module.currentScanRadius = math.min(Module.MAX_SCAN_RADIUS, Module.currentScanRadius + 100)
		end
	end
end

function Module.getNextTarget()
	if not Module.rootPart then return nil end
	
	local currentTime = tick()
	local shouldRefresh = (currentTime - Module.lastCacheUpdate > Module.CACHE_REFRESH_TIME) or #Module.itemCache == 0
	
	if shouldRefresh then
		Module.updateItemCache()
	end
	
	-- If we have items in cache, return the closest one
	if #Module.itemCache > 0 then
		local closestItem = Module.itemCache[1]
		table.remove(Module.itemCache, 1)
		return closestItem.pos
	end
	
	-- If no items found after multiple attempts, try to relocate to a new farming zone
	if Module.noItemsFoundCount >= Module.MAX_NO_ITEMS_BEFORE_RELOCATE then
		local newZone = Module.findNearestItemCluster()
		if newZone then
			Module.noItemsFoundCount = 0
			Module.currentScanRadius = Module.BASE_SCAN_RADIUS
			return newZone
		end
	end
	
	return nil
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

function Module.noclip()
	if not Module.character then return end
	for _, part in pairs(Module.character:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			part.CanCollide = false
		end
	end
end

function Module.enableNoclip()
	if Module.noclipConnection then
		Module.noclipConnection:Disconnect()
		Module.noclipConnection = nil
	end
	Module.noclipConnection = RunService.Stepped:Connect(Module.noclip)
end

function Module.disableNoclip()
	if Module.noclipConnection then
		Module.noclipConnection:Disconnect()
		Module.noclipConnection = nil
	end
	if not Module.character then return end
	for _, part in pairs(Module.character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.CanCollide = true
		end
	end
end

function Module.startSwim()
	if not Module.swimming and Module.character and Module.character:FindFirstChildWhichIsA("Humanoid") then
		Module.oldGravity = workspace.Gravity
		workspace.Gravity = 0
		
		local swimDied = function()
			workspace.Gravity = Module.oldGravity
			Module.swimming = false
			Module.disableNoclip()
		end
		
		local Humanoid = Module.character:FindFirstChildWhichIsA("Humanoid")
		Module.gravReset = Humanoid.Died:Connect(swimDied)
		
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, false)
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		
		Module.swimBeat = RunService.Heartbeat:Connect(function()
			pcall(function()
				local hrp = Module.character.HumanoidRootPart
				
				if Module.isSwimmingToDestination then
					local currentPos = hrp.Position
					local direction = (Module.swimDestination - currentPos).Unit
					local distance = (Module.swimDestination - currentPos).Magnitude
					
					if distance < 5 then
						Module.isSwimmingToDestination = false
						hrp.Velocity = Vector3.new(0, 0, 0)
					else
						hrp.Velocity = direction * Module.swimSpeed
					end
				end
			end)
		end)
		
		Module.enableNoclip()
		Module.swimming = true
		return true
	end
	return false
end

function Module.stopSwim()
	if Module.character and Module.character:FindFirstChildWhichIsA("Humanoid") then
		workspace.Gravity = Module.oldGravity
		Module.swimming = false
		Module.isSwimmingToDestination = false
		
		if Module.gravReset then
			Module.gravReset:Disconnect()
			Module.gravReset = nil
		end
		if Module.swimBeat then
			Module.swimBeat:Disconnect()
			Module.swimBeat = nil
		end
		
		Module.disableNoclip()
		
		local Humanoid = Module.character:FindFirstChildWhichIsA("Humanoid")
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, true)
		end
	end
end

function Module.swimToDestination(targetPosition)
	if not Module.character or not Module.character:FindFirstChild("HumanoidRootPart") then
		return
	end
	
	local hrp = Module.character.HumanoidRootPart
	local currentPos = hrp.Position
	local skyPosition = Vector3.new(currentPos.X, currentPos.Y + 100, currentPos.Z)
	hrp.CFrame = CFrame.new(skyPosition)
	
	Module.isSwimmingToDestination = true
	Module.swimDestination = targetPosition
	
	if not Module.swimming then
		Module.startSwim()
	end
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

function Module.shouldUseSwim()
	if Module.movementMode == "Swim" then
		return true
	elseif Module.movementMode == "Teleport" then
		return false
	else
		return Module.isMobile
	end
end

function Module.moveToTarget(targetPosition)
	if Module.shouldUseSwim() then
		Module.swimToDestination(targetPosition)
	else
		if Module.rootPart then
			if Module.lockCamera then
				if not Module.cameraCFrame then
					Module.cameraCFrame = Module.camera.CFrame
					Module.camera.CameraType = Enum.CameraType.Scriptable
				end
				Module.camera.CFrame = Module.cameraCFrame
			end
			Module.rootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, Module.TELEPORT_HEIGHT, 0))
		end
	end
end

function Module.startLoop()
	RunService.Heartbeat:Connect(function()
		Module.updateRadiusCache()
	end)
	
	local lastTeleport = 0
	
	RunService.Heartbeat:Connect(function()
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
		
		local now = tick()
		if not Module.shouldUseSwim() then
			if now - lastTeleport < 0.05 then return end
		end
		
		if Module.babyDinoActive then
			local target = Module.findBabyDino()
			if target then
				Module.moveToTarget(target)
				lastTeleport = now
			end
		elseif Module.huntActive then
			local target = Module.findWeakerPlayer()
			if target then
				Module.moveToTarget(target)
				lastTeleport = now
			end
		elseif Module.farmActive then
			local target = Module.getNextTarget()
			if target then
				Module.moveToTarget(target)
				lastTeleport = now
			else
				if not Module.shouldUseSwim() and Module.lockCamera and Module.cameraCFrame then
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
	Module.currentScanRadius = Module.BASE_SCAN_RADIUS
	Module.noItemsFoundCount = 0
	if Module.bodyVelocity then Module.bodyVelocity:Destroy() end
	if Module.bodyGyro then Module.bodyGyro:Destroy() end
	Module.stopSwim()
end

return Module