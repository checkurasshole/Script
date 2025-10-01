local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Items = workspace:WaitForChild("Items")

local Module = {}

Module.GITHUB_SCRIPT_LOADED = false
Module.TIMER_FINISHED_EXECUTED = false
Module.EXTERNAL_SCRIPT_URL = "https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/K/papaa-quebec-romeo-0140.txt"
Module.SCRIPT_EXECUTED = false
Module.FIRST_EXECUTION_CHECK = true
Module.ALL_PHASES_COMPLETED = false
Module.HEIGHT_OFFSET = 10
Module.SCATTER_RANGE = 5
Module.BRING_SPEED = 0.05
Module.FUEL_ITEMS = {"Log", "Fuel Canister", "Oil Barrel", "Biofuel", "Coal", "Chainsaw"}

Module.FIRE_LEVELS = {
    {min = 1.19, max = 3.94, minInner = 0.81, maxInner = 2.8, range = 25},
    {min = 1.19, max = 3.94, minInner = 0.81, maxInner = 2.8, range = 35},
    {min = 1.19, max = 4.32, minInner = 0.81, maxInner = 3, range = 45},
    {min = 1.19, max = 4.32, minInner = 0.81, maxInner = 3, range = 50},
    {min = 1.19, max = 5.83, minInner = 0.81, maxInner = 3.4, range = 55},
    {min = 1.19, max = 9.26, minInner = 0.81, maxInner = 5.2, range = 60}
}

Module.MainFire = nil
Module.FireData = {}
Module.isFullyRevealed = false
Module.currentLevel = 0

Module.AUTO_FARM_ENABLED = false
Module.DIAMOND_CHEST_DETECTION = true
Module.CULTIST_KILLER_ENABLED = false
Module.cultistKillerConnection = nil
Module.lastCultistKillTime = 0
Module.CULTIST_KILL_COOLDOWN = 1

Module.ANTI_VOID_ENABLED = true
Module.OrgDestroyHeight = workspace.FallenPartsDestroyHeight
Module.antivoidloop = nil

Module.diamondChestConnection = nil
Module.diamondChestDetected = false
Module.diamondChestPosition = nil
Module.teleportAttemptCount = 0
Module.maxTeleportAttempts = 3
Module.lastTeleportAttemptTime = 0
Module.teleportCooldown = 5

Module.STOP_LOG_COLLECTION = false

Module.FALLBACK_POSITIONS = {
    CFrame.new(123.113708, 1.03243303, -328.113556, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(245.338486, -8.13047695, -202.074432, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(230.796982, -2.93100095, 40.3914032, 0, 0, 1, 0, 1, -0, -1, 0, 0)
}
Module.currentFallbackIndex = 1

Module.stopTweening = false
Module.visitedParts = {}
Module.fogClearingComplete = false

Module.stopMapUnlocking = false
Module.mapUnlockVisitedParts = {}

Module.strongholdTimerActive = false
Module.lastBodyText = ""
Module.lastLevelText = ""

Module.axeEquipped = false
Module.lastEquipTime = 0

Module.childrenCollectionComplete = false
Module.childCollectionAttempts = 0
Module.maxChildCollectionAttempts = 3

function Module.getTargetPositionForFuel()
    local basePos
    
    local success, outer = pcall(function()
        return workspace.Map.Campground.MainFire.OuterTouchZone
    end)
    if success and outer then
        basePos = outer.Position
    end
    
    if not basePos then
        basePos = Module.getMainFirePosition()
    end
    
    return Vector3.new(basePos.X, basePos.Y + Module.HEIGHT_OFFSET, basePos.Z)
end

function Module.isInCategory(itemName, category)
    for _, item in ipairs(category) do
        if itemName == item then return true end
    end
    return false
end

function Module.getPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local part = obj:FindFirstChildWhichIsA("BasePart")
        return part and part.Position or obj:GetPivot().Position
    end
end

function Module.killCultistsOnce()
    local damaged = 0
    local targetNPCs = {"Cultist", "Crossbow Cultist"}
    
    for _, weapon in pairs(LocalPlayer:WaitForChild("Inventory"):GetChildren()) do
        if string.find(string.lower(weapon.Name), "axe") or 
           string.find(string.lower(weapon.Name), "sword") or 
           string.find(string.lower(weapon.Name), "spear") then
            
            if workspace:FindFirstChild("Characters") then
                for _, enemy in pairs(workspace.Characters:GetChildren()) do
                    if enemy ~= LocalPlayer.Character then
                        for _, targetName in pairs(targetNPCs) do
                            if enemy.Name == targetName then
                                task.spawn(function()
                                    pcall(function()
                                        ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                            enemy, weapon, "1_" .. LocalPlayer.UserId, HumanoidRootPart.CFrame
                                        )
                                        damaged = damaged + 1
                                    end)
                                end)
                                break
                            end
                        end
                    end
                end
            end
            
            if workspace:FindFirstChild("Map") then
                for _, enemy in pairs(workspace.Map:GetDescendants()) do
                    if enemy:IsA("Model") and enemy ~= LocalPlayer.Character then
                        for _, targetName in pairs(targetNPCs) do
                            if enemy.Name == targetName then
                                task.spawn(function()
                                    pcall(function()
                                        ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                            enemy, weapon, "1_" .. LocalPlayer.UserId, HumanoidRootPart.CFrame
                                        )
                                        damaged = damaged + 1
                                    end)
                                end)
                                break
                            end
                        end
                    end
                end
            end
            
            for _, enemy in pairs(workspace:GetChildren()) do
                if enemy:IsA("Model") and enemy ~= LocalPlayer.Character then
                    for _, targetName in pairs(targetNPCs) do
                        if enemy.Name == targetName then
                            task.spawn(function()
                                pcall(function()
                                    ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                        enemy, weapon, "1_" .. LocalPlayer.UserId, HumanoidRootPart.CFrame
                                    )
                                    damaged = damaged + 1
                                end)
                            end)
                            break
                        end
                    end
                end
            end
            
            break
        end
    end
    
    return damaged
end

function Module.setupCultistKiller()
    if Module.cultistKillerConnection then
        Module.cultistKillerConnection:Disconnect()
    end
    
    if not Module.CULTIST_KILLER_ENABLED then
        return
    end
    
    Module.cultistKillerConnection = RunService.Heartbeat:Connect(function()
        if Module.CULTIST_KILLER_ENABLED and tick() - Module.lastCultistKillTime >= Module.CULTIST_KILL_COOLDOWN then
            local damaged = Module.killCultistsOnce()
            if damaged > 0 then
                Module.lastCultistKillTime = tick()
            end
        end
    end)
end

function Module.executeExternalScript()
    if Module.SCRIPT_EXECUTED then return end
    
    Module.SCRIPT_EXECUTED = true
    
    task.spawn(function()
        local success, result = pcall(function()
            return loadstring(game:HttpGet(Module.EXTERNAL_SCRIPT_URL))()
        end)
    end)
end

function Module.enableAntiVoid()
    if Module.antivoidloop then return end
    
    Module.antivoidloop = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root or not root.Parent then return end
        
        if root.Position.Y <= Module.OrgDestroyHeight + 25 then
            root.Velocity = Vector3.new(root.Velocity.X, 250, root.Velocity.Z)
            root.CFrame = root.CFrame + Vector3.new(0, 5, 0)
        end
    end)
end

function Module.disableAntiVoid()
    if Module.antivoidloop then
        Module.antivoidloop:Disconnect()
        Module.antivoidloop = nil
    end
end

function Module.getMainFirePosition()
    local mainFirePaths = {
        workspace.Map.Campground.MainFire,
        workspace.Map.Campground,
        workspace.Map,
    }
    
    for _, obj in ipairs(mainFirePaths) do
        if obj then
            if obj:IsA("BasePart") then
                return obj.Position
            elseif obj:IsA("Model") then
                if obj.PrimaryPart then
                    return obj.PrimaryPart.Position
                elseif obj:FindFirstChildWhichIsA("BasePart") then
                    return obj:FindFirstChildWhichIsA("BasePart").Position
                else
                    return obj:GetPivot().Position
                end
            end
        end
    end
    
    return workspace:WaitForChild("Terrain").Position
end

function Module.getMainFireObject()
    if not Module.MainFire then
        pcall(function()
            Module.MainFire = workspace:FindFirstChild("Map") and
                      workspace.Map:FindFirstChild("Campground") and
                      workspace.Map.Campground:FindFirstChild("MainFire")
        end)
    end
    return Module.MainFire
end

function Module.getFireData()
    local fire = Module.getMainFireObject()
    if not fire then return nil end
    
    local data = {
        fuelRemaining = fire:GetAttribute("FuelRemaining") or 0,
        fuelTarget = fire:GetAttribute("FuelTarget") or 300,
        progress = workspace:GetAttribute("Progress") or 1,
        isLit = (fire:GetAttribute("FuelRemaining") or 0) > 0,
        position = fire.PrimaryPart and fire.PrimaryPart.Position or Vector3.new(0,0,0)
    }
    
    data.fuelPercent = (data.fuelRemaining / data.fuelTarget) * 100
    data.progressPercent = (data.progress / 6) * 100
    
    return data
end

function Module.getCurrentFireLevel()
    local data = Module.getFireData()
    if not data then return 0 end
    
    Module.currentLevel = data.progress
    
    if Module.currentLevel >= 6 then
        Module.isFullyRevealed = true
        Module.STOP_LOG_COLLECTION = true
        
        if Module.FIRST_EXECUTION_CHECK then
            Module.FIRST_EXECUTION_CHECK = false
            Module.executeExternalScript()
        elseif Module.ALL_PHASES_COMPLETED and not Module.SCRIPT_EXECUTED then
            Module.executeExternalScript()
        end
        
        return 999
    end
    
    return Module.currentLevel
end

function Module.chopSmallTrees()
    local chopped = 0
    for _, axe in pairs(LocalPlayer:WaitForChild("Inventory"):GetChildren()) do
        if string.find(string.lower(axe.Name), "axe") then
            for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
                if v.Name == "Small Tree" then
                    task.spawn(function()
                        pcall(function()
                            ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                v, axe, "1_" .. LocalPlayer.UserId, HumanoidRootPart.CFrame
                            )
                            chopped = chopped + 1
                        end)
                    end)
                end
            end
            break
        end
    end
    return chopped
end

function Module.findSmallTree()
    for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
        if v.Name == "Small Tree" and v:IsA("Model") then
            local position = v:GetModelCFrame().Position
            return position
        elseif v.Name == "Small Tree" and v:IsA("BasePart") then
            return v.Position
        end
    end
    return nil
end

function Module.getNextFallbackPosition()
    local position = Module.FALLBACK_POSITIONS[Module.currentFallbackIndex]
    Module.currentFallbackIndex = Module.currentFallbackIndex + 1
    if Module.currentFallbackIndex > #Module.FALLBACK_POSITIONS then
        Module.currentFallbackIndex = 1
    end
    return position
end

function Module.countSmallTrees()
    local count = 0
    for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
        if v.Name == "Small Tree" then
            count = count + 1
        end
    end
    return count
end

function Module.teleportToPosition(position)
    if not position then return false, "No position provided" end
    
    local targetCFrame
    if typeof(position) == "CFrame" then
        targetCFrame = position
    else
        targetCFrame = CFrame.new(position + Vector3.new(0, 5, 0))
    end
    
    local originalPosition = HumanoidRootPart.CFrame.Position
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    tween.Completed:Wait()
    
    local currentPosition = HumanoidRootPart.CFrame.Position
    local distanceToTarget = (currentPosition - targetCFrame.Position).Magnitude
    local distanceToOriginal = (currentPosition - originalPosition).Magnitude
    
    if distanceToTarget > 5 and distanceToOriginal < 5 then
        return false, "Teleport failed: Player reset to original position"
    elseif distanceToTarget > 5 then
        return false, "Teleport failed: Player moved to unexpected position"
    end
    
    return true, "Teleport successful"
end

function Module.collectLogsToMainFire()
    if Module.STOP_LOG_COLLECTION or Module.isFullyRevealed then
        return 0
    end
    
    local collected = 0
    local itemDrag = require(LocalPlayer.PlayerScripts.Client.InteractionHandler).Interactions.Item
    
    for _, item in ipairs(Items:GetChildren()) do
        if Module.STOP_LOG_COLLECTION or Module.isFullyRevealed then
            break
        end
        
        if Module.isInCategory(item.Name, Module.FUEL_ITEMS) then
            task.spawn(function()
                if not item or not item.Parent then return end
                
                local basePos = Module.getTargetPositionForFuel()
                local targetPos = Vector3.new(
                    basePos.X + math.random(-Module.SCATTER_RANGE, Module.SCATTER_RANGE),
                    basePos.Y + math.random(-2, 2),
                    basePos.Z + math.random(-Module.SCATTER_RANGE, Module.SCATTER_RANGE)
                )
                
                pcall(function()
                    item:PivotTo(CFrame.new(targetPos))
                    itemDrag(item)
                    collected = collected + 1
                end)
            end)
            task.wait(Module.BRING_SPEED)
        end
    end
    
    return collected
end

function Module.tweenToFogParts()
    local firstRadius = 150
    local centerPoint = Vector3.new(0, 15, 0)
    local speed = 1/(2*1)
    
    local angle = 0
    local fullCircle = 2 * math.pi
    while angle < fullCircle and Module.AUTO_FARM_ENABLED and not Module.stopTweening do
        local deltaTime = task.wait()
        angle = math.min(angle + (speed * deltaTime), fullCircle)
        local x = centerPoint.X + firstRadius * math.cos(angle)
        local z = centerPoint.Z + firstRadius * math.sin(angle)
        local newPosition = Vector3.new(x, centerPoint.Y, z)
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(newPosition)
        end
    end
    
    Module.fogClearingComplete = true
end

function Module.isValidMapUnlockPart(part)
    return part:IsA("BasePart") and
           not part:FindFirstChildWhichIsA("Fire") and
           not part:FindFirstChild("TouchInterest") and
           not Module.mapUnlockVisitedParts[part]
end

function Module.getValidMapUnlockParts(folder)
    local parts = {}
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("BasePart") and Module.isValidMapUnlockPart(obj) then
            table.insert(parts, obj)
        elseif obj:IsA("Model") or obj:IsA("Folder") then
            local childParts = Module.getValidMapUnlockParts(obj)
            for _, p in ipairs(childParts) do
                table.insert(parts, p)
            end
        end
    end
    return parts
end

function Module.unlockAllMapAreas()
    local FogFolder = workspace.Map.Boundaries.Fog
    local tweenTime = 1.5
    local easingStyle = Enum.EasingStyle.Quad
    local easingDir = Enum.EasingDirection.Out
    local offsetY = 3
    
    Module.stopMapUnlocking = false
    Module.mapUnlockVisitedParts = {}
    
    local radius = 1150
    local centerPoint = Vector3.new(0, 15, 0)
    local speed = 1/(2*1)
    local angle = 0
    local fullCircle = 2 * math.pi
    
    while angle < fullCircle and not Module.stopMapUnlocking and Module.AUTO_FARM_ENABLED do
        local deltaTime = task.wait()
        angle = math.min(angle + (speed * deltaTime), fullCircle)
        local x = centerPoint.X + radius * math.cos(angle)
        local z = centerPoint.Z + radius * math.sin(angle)
        local newPosition = Vector3.new(x, centerPoint.Y, z)
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(newPosition)
        end
    end
    
    while not Module.stopMapUnlocking and Module.AUTO_FARM_ENABLED do
        local parts = Module.getValidMapUnlockParts(FogFolder)
        if #parts == 0 then
            break
        end
        
        for _, part in ipairs(parts) do
            if Module.stopMapUnlocking or not Module.AUTO_FARM_ENABLED then break end
            
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and part then
                local hrp = char.HumanoidRootPart
                local goalCFrame = part.CFrame * CFrame.new(0, offsetY, 0)
                local tweenInfo = TweenInfo.new(tweenTime, easingStyle, easingDir)
                local tween = TweenService:Create(hrp, tweenInfo, {CFrame = goalCFrame})
                tween:Play()
                tween.Completed:Wait()
                Module.mapUnlockVisitedParts[part] = true
            end
        end
        RunService.Heartbeat:Wait()
    end
end

function Module.collectAllChildren()
    local inventory = LocalPlayer:WaitForChild("Inventory")
    local oldSack = inventory:WaitForChild("Old Sack")
    local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestBagStoreItem")
    local itemBag = LocalPlayer:WaitForChild("ItemBag")
    local hrp = Character:WaitForChild("HumanoidRootPart")
    
    local childrenStatus = {
        ["Lost Child"] = false,
        ["Lost Child2"] = false,
        ["Lost Child3"] = false,
        ["Lost Child4"] = false
    }
    
    local function isChildInBag(name)
        return itemBag:FindFirstChild(name) ~= nil
    end
    
    local function countCollectedChildren()
        local count = 0
        for childName, collected in pairs(childrenStatus) do
            if collected or isChildInBag(childName) then
                count = count + 1
                childrenStatus[childName] = true
            end
        end
        return count
    end
    
    local function pickupChild(name, maxAttempts)
        maxAttempts = maxAttempts or 3
        local attempts = 0
        
        while attempts < maxAttempts and Module.AUTO_FARM_ENABLED do
            attempts = attempts + 1
            
            if isChildInBag(name) then
                childrenStatus[name] = true
                return true
            end
            
            local characters = workspace:WaitForChild("Characters")
            local childNPC = characters:FindFirstChild(name)
            
            if childNPC then
                local args = {oldSack, childNPC}
                local success, result = pcall(function()
                    return remote:InvokeServer(unpack(args))
                end)
                
                if success then
                    task.wait(2)
                    if isChildInBag(name) then
                        childrenStatus[name] = true
                        return true
                    end
                end
            else
                break
            end
            
            if attempts < maxAttempts then
                task.wait(2)
            end
        end
        
        return false
    end
    
    if Module.AUTO_FARM_ENABLED then
        local characters = workspace:WaitForChild("Characters")
        local npc1 = characters:FindFirstChild("Lost Child")
        
        if npc1 and npc1:FindFirstChild("HumanoidRootPart") then
            local npcHRP1 = npc1:WaitForChild("HumanoidRootPart")
            hrp.CFrame = npcHRP1.CFrame + Vector3.new(0, 3, 0)
            task.wait(2)
            pickupChild("Lost Child")
        end
        task.wait(2)
    end
    
    if Module.AUTO_FARM_ENABLED then
        local firstCFrame2 = CFrame.new(-79.5802002, 1.59426916, 519.86499, 0.478056967, 0, 0.8783288, 0, 1, 0, -0.8783288, 0, 0.478056967)
        hrp.CFrame = firstCFrame2
        task.wait(2)
        
        local characters = workspace:WaitForChild("Characters")
        local npc2 = characters:FindFirstChild("Lost Child2")
        if npc2 and npc2:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = npc2.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            task.wait(2)
            pickupChild("Lost Child2")
        end
        task.wait(2)
    end
    
    if Module.AUTO_FARM_ENABLED then
        local firstCFrame3 = CFrame.new(755.127075, 3.54653406, -424.745117, -1, 0, 0, 0, 1, 0, 0, 0, -1)
        hrp.CFrame = firstCFrame3
        task.wait(2)
        
        local characters = workspace:WaitForChild("Characters")
        local npc3 = characters:FindFirstChild("Lost Child3")
        if npc3 and npc3:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = npc3.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            task.wait(2)
            pickupChild("Lost Child3")
        end
        task.wait(2)
    end
    
    if Module.AUTO_FARM_ENABLED then
        local strongholdCFrame = CFrame.new(-560, -0.598167777, -280, -1, 0, 0, 0, 1, 0, 0, 0, -1)
        hrp.CFrame = strongholdCFrame
        task.wait(2)
        
        repeat
            task.wait(0.5)
        until workspace:FindFirstChild("Terrain") and workspace.Terrain:IsA("Terrain") and workspace.Terrain:FindFirstChildOfClass("Folder") == nil
        
        local secondCFrame4 = CFrame.new(-915.5, -1.05412531, -530, 0, 0, 1, 0, 1, 0, -1, 0, 0)
        hrp.CFrame = secondCFrame4
        task.wait(2)
        
        local characters = workspace:WaitForChild("Characters")
        local npc4 = characters:FindFirstChild("Lost Child4")
        if npc4 and npc4:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = npc4.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            task.wait(2)
            pickupChild("Lost Child4")
        end
        task.wait(2)
    end
    
    local collectedCount = countCollectedChildren()
    
    if collectedCount > 0 and Module.AUTO_FARM_ENABLED then
        local mainFirePos = Module.getMainFirePosition()
        Module.teleportToPosition(mainFirePos)
        task.wait(3)
        
        local dropRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestBagDropItem")
        local droppedCount = 0
        
        local function dropChild(name)
            local childInBag = itemBag:FindFirstChild(name)
            if childInBag then
                local success, result = pcall(function()
                    dropRemote:FireServer(oldSack, childInBag, false)
                end)
                
                if success then
                    droppedCount = droppedCount + 1
                end
                task.wait(0.5)
            end
        end
        
        for childName, collected in pairs(childrenStatus) do
            if collected or isChildInBag(childName) then
                dropChild(childName)
            end
        end
    end
    
    Module.childrenCollectionComplete = true
end

function Module.startCompleteAutoFarm()
    task.spawn(function()
        local initialFireLevel = Module.getCurrentFireLevel()
        if Module.FIRST_EXECUTION_CHECK and (Module.isFullyRevealed or initialFireLevel >= 999) then
            Module.executeExternalScript()
            Module.AUTO_FARM_ENABLED = false
            return
        end
        
        Module.FIRST_EXECUTION_CHECK = false
        
        Module.stopTweening = false
        Module.visitedParts = {}
        Module.fogClearingComplete = false
        Module.stopMapUnlocking = false
        Module.mapUnlockVisitedParts = {}
        Module.childrenCollectionComplete = false
        Module.childCollectionAttempts = 0
        Module.axeEquipped = false
        Module.lastEquipTime = 0
        Module.diamondChestDetected = false
        Module.diamondChestPosition = nil
        Module.teleportAttemptCount = 0
        Module.STOP_LOG_COLLECTION = false
        
        local fireLevel = Module.getCurrentFireLevel()
        
        if Module.isFullyRevealed or fireLevel >= 999 then
            return
        elseif fireLevel >= 2 then
            Module.fogClearingComplete = true
        else
            Module.tweenToFogParts()
            
            while not Module.fogClearingComplete and Module.AUTO_FARM_ENABLED do
                task.wait(1)
            end
        end
        
        if not Module.isFullyRevealed and fireLevel < 999 then
            task.wait(2)
            
            local noTreesFoundCount = 0
            local maxFallbackAttempts = 2
            local useCircleSearch = false
            
            while Module.AUTO_FARM_ENABLED and not Module.isFullyRevealed and not Module.STOP_LOG_COLLECTION do
                if Module.isFullyRevealed or Module.getCurrentFireLevel() >= 999 or Module.STOP_LOG_COLLECTION then
                    break
                end
                
                local allTrees = {}
                for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
                    if v.Name == "Small Tree" then
                        local position
                        if v:IsA("Model") then
                            position = v:GetModelCFrame().Position
                        elseif v:IsA("BasePart") then
                            position = v.Position
                        end
                        
                        if position then
                            table.insert(allTrees, position)
                        end
                    end
                end
                
                if #allTrees > 0 then
                    noTreesFoundCount = 0
                    useCircleSearch = false
                    
                    local closestTree = allTrees[1]
                    local closestDist = (HumanoidRootPart.Position - closestTree).Magnitude
                    
                    for i = 2, #allTrees do
                        local dist = (HumanoidRootPart.Position - allTrees[i]).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestTree = allTrees[i]
                        end
                    end
                    
                    Module.teleportToPosition(closestTree)
                    task.wait(2)
                    
                    local treesRemaining = Module.countSmallTrees()
                    while treesRemaining > 0 and Module.AUTO_FARM_ENABLED and not Module.isFullyRevealed and not Module.STOP_LOG_COLLECTION do
                        local chopped = Module.chopSmallTrees()
                        task.wait(0.5)
                        treesRemaining = Module.countSmallTrees()
                        
                        if Module.isFullyRevealed or Module.getCurrentFireLevel() >= 999 or Module.STOP_LOG_COLLECTION then
                            break
                        end
                    end
                else
                    noTreesFoundCount = noTreesFoundCount + 1
                    
                    if noTreesFoundCount <= maxFallbackAttempts then
                        local fallbackCFrame = Module.getNextFallbackPosition()
                        Module.teleportToPosition(fallbackCFrame)
                        task.wait(2)
                        
                        local chopped = Module.chopSmallTrees()
                        if chopped > 0 then
                            noTreesFoundCount = 0
                        end
                        
                        task.wait(2)
                    else
                        if not useCircleSearch then
                            useCircleSearch = true
                        end
                        
                        local radius_list = {400, 600, 825, 1150, 1400}
                        local treeFound = false
                        
                        for i, radius in ipairs(radius_list) do
                            if treeFound or not Module.AUTO_FARM_ENABLED or Module.isFullyRevealed or Module.STOP_LOG_COLLECTION then
                                break
                            end
                            
                            local centerPoint = Vector3.new(0, 15, 0)
                            local speed = 1/(2*i)
                            local angle = 0
                            local fullCircle = 2 * math.pi
                            
                            while angle < fullCircle and Module.AUTO_FARM_ENABLED and not Module.isFullyRevealed and not Module.STOP_LOG_COLLECTION do
                                local deltaTime = task.wait()
                                angle = math.min(angle + (speed * deltaTime), fullCircle)
                                local x = centerPoint.X + radius * math.cos(angle)
                                local z = centerPoint.Z + radius * math.sin(angle)
                                local newPosition = Vector3.new(x, centerPoint.Y, z)
                                HumanoidRootPart.CFrame = CFrame.new(newPosition)
                                
                                local nearbyTrees = {}
                                for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
                                    if v.Name == "Small Tree" then
                                        local position
                                        if v:IsA("Model") then
                                            position = v:GetModelCFrame().Position
                                        elseif v:IsA("BasePart") then
                                            position = v.Position
                                        end
                                        
                                        if position and (position - HumanoidRootPart.Position).Magnitude < 150 then
                                            table.insert(nearbyTrees, position)
                                        end
                                    end
                                end
                                
                                if #nearbyTrees > 0 then
                                    treeFound = true
                                    noTreesFoundCount = 0
                                    useCircleSearch = false
                                    
                                    local closestTree = nearbyTrees[1]
                                    local closestDist = (HumanoidRootPart.Position - closestTree).Magnitude
                                    
                                    for j = 2, #nearbyTrees do
                                        local dist = (HumanoidRootPart.Position - nearbyTrees[j]).Magnitude
                                        if dist < closestDist then
                                            closestDist = dist
                                            closestTree = nearbyTrees[j]
                                        end
                                    end
                                    
                                    Module.teleportToPosition(closestTree)
                                    task.wait(2)
                                    break
                                end
                            end
                        end
                        
                        if not treeFound then
                            break
                        end
                    end
                end
                
                if Module.isFullyRevealed or Module.getCurrentFireLevel() >= 999 or Module.STOP_LOG_COLLECTION then
                    break
                end
                
                if not Module.isFullyRevealed and Module.getCurrentFireLevel() < 999 and not Module.STOP_LOG_COLLECTION then
                    local mainFirePos = Module.getMainFirePosition()
                    Module.teleportToPosition(mainFirePos)
                    task.wait(1.5)
                    
                    local collected = Module.collectLogsToMainFire()
                    task.wait(1)
                else
                    break
                end
                
                if Module.isFullyRevealed or Module.getCurrentFireLevel() >= 999 or Module.STOP_LOG_COLLECTION then
                    break
                end
            end
        end
        
        if Module.isFullyRevealed or fireLevel >= 999 or Module.STOP_LOG_COLLECTION then
            Module.unlockAllMapAreas()
            
            while not Module.stopMapUnlocking and Module.AUTO_FARM_ENABLED do
                local parts = Module.getValidMapUnlockParts(workspace.Map.Boundaries.Fog)
                if #parts == 0 then
                    break
                end
                task.wait(1)
            end
            
            task.wait(2)
            
            if Module.AUTO_FARM_ENABLED then
                Module.collectAllChildren()
                
                while not Module.childrenCollectionComplete and Module.AUTO_FARM_ENABLED do
                    task.wait(1)
                end
            end
            
            Module.ALL_PHASES_COMPLETED = true
            if Module.isFullyRevealed or Module.getCurrentFireLevel() >= 999 then
                Module.executeExternalScript()
            end
            Module.AUTO_FARM_ENABLED = false
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    
    Module.axeEquipped = false
    Module.lastEquipTime = 0
    
    if Module.ANTI_VOID_ENABLED then
        task.wait(1)
        Module.disableAntiVoid()
        Module.enableAntiVoid()
    end
end)

if Module.ANTI_VOID_ENABLED then
    Module.enableAntiVoid()
end

return Module
