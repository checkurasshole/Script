-- Diamond Chest Core Module - Complete Version
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Items = workspace:WaitForChild("Items")

-- Settings
local AUTO_TELEPORT_ENABLED = false
local CULTIST_KILLER_ENABLED = false
local cultistKillerConnection
local lastCultistKillTime = 0
local CULTIST_KILL_COOLDOWN = 1
local diamondChestPosition = nil
local diamondChestConnection = nil

-- Simple notification
local function notify(title, content, duration)
    if _G.Fluent then
        _G.Fluent:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3
        })
    else
        print("[" .. title .. "] " .. content)
    end
end

-- Get position helper
local function getPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local part = obj:FindFirstChildWhichIsA("BasePart")
        return part and part.Position or obj:GetPivot().Position
    end
end

-- Cultist killer functions
local function killCultistsOnce()
    local damaged = 0
    local targetNPCs = {"Cultist", "Crossbow Cultist"}
    
    for _, weapon in pairs(LocalPlayer:WaitForChild("Inventory"):GetChildren()) do
        if string.find(string.lower(weapon.Name), "axe") or 
           string.find(string.lower(weapon.Name), "sword") or 
           string.find(string.lower(weapon.Name), "spear") then
            
            -- Search in workspace Characters
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
            
            -- Also search in Map descendants
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
            
            -- Search in workspace root for any Cultist models
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

local function setupCultistKiller()
    if cultistKillerConnection then
        cultistKillerConnection:Disconnect()
    end
    
    if not CULTIST_KILLER_ENABLED then
        return
    end
    
    cultistKillerConnection = RunService.Heartbeat:Connect(function()
        if CULTIST_KILLER_ENABLED and tick() - lastCultistKillTime >= CULTIST_KILL_COOLDOWN then
            local damaged = killCultistsOnce()
            if damaged > 0 then
                lastCultistKillTime = tick()
            end
        end
    end)
end

-- Auto teleport after success
local function performAutoTeleport()
    if AUTO_TELEPORT_ENABLED then
        notify("Auto Teleport", "Waiting 3 seconds before teleporting to target server...", 3)
        task.wait(3)
        
        notify("Auto Teleport", "Teleporting to server 126509999114328...", 2)
        
        pcall(function()
            TeleportService:Teleport(126509999114328)
        end)
    end
end

-- Enhanced Diamond Chest Sequence Function with all the original logic
local function executeDiamondChestSequence()
    pcall(function()
        -- Update character references
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        
        -- Set movement speed for the entire sequence
        local humanoid = Character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 50

        -- Define noclip functions for wall clipping during navigation
        local function enableNoclip()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false -- Disable collision for all body parts
                end
            end
        end

        local function disableNoclip()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true -- Re-enable collision (except HumanoidRootPart)
                end
            end
        end

        -- Enable noclip at the start of the sequence
        enableNoclip()

        -- Metatable Hook Setup for Chest Detection
        local chestRequestDetected = false
        
        if getrawmetatable then
            local mt = getrawmetatable(game)
            if mt and mt.__namecall then
                local oldNamecall = mt.__namecall
                if setreadonly then setreadonly(mt, false) end
                
                mt.__namecall = function(self, ...)
                    local method = getnamecallmethod and getnamecallmethod() or ""
                    local args = {...}

                    if method == "FireServer" and tostring(self):find("RequestOpenItemChest") then
                        print("RequestOpenItemChest fired with:", unpack(args))
                        chestRequestDetected = true
                    end

                    return oldNamecall(self, ...)
                end
                
                if setreadonly then setreadonly(mt, true) end
                
                local function restoreMetatable()
                    if setreadonly then setreadonly(mt, false) end
                    mt.__namecall = oldNamecall
                    if setreadonly then setreadonly(mt, true) end
                end
                
                task.spawn(function()
                    task.wait(30)
                    if not chestRequestDetected then
                        restoreMetatable()
                    end
                end)
            end
        end

        -- Initial Chest Proximity Prompt Interaction
        local strongholdChest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
        if strongholdChest then
            local proximityPrompt = strongholdChest.Main.ProximityAttachment.ProximityInteraction
            
            if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
                notify("Firing Diamond Chest Proximity Prompt", "Found and firing the diamond chest proximity prompt...", 3)
                
                proximityPrompt.HoldDuration = 0
                proximityPrompt.RequiresLineOfSight = false
                proximityPrompt.MaxActivationDistance = math.huge
                
                if fireproximityprompt then
                    fireproximityprompt(proximityPrompt)
                else
                    proximityPrompt:InputHoldBegin()
                    proximityPrompt:InputHoldEnd()
                end
            else
                notify("Proximity Prompt Not Found", "Could not find the diamond chest proximity prompt", 3)
            end
        else
            notify("Diamond Chest Not Found", "Could not find the Stronghold Diamond Chest", 3)
        end
        
        -- Wait 3 seconds to give the metatable hook time to detect chest opening
        task.wait(3)
        
        -- Chest Opened Scenario (Detected by Listener)
        if chestRequestDetected then
            notify("Chest Request Detected!", "Chest opened! Collecting diamonds multiple times...", 5)
            
            for attempt = 1, 3 do
                notify("Diamond Collection Attempt " .. attempt, "Collecting all diamonds from opened chest...", 2)
                
                for _, item in pairs(workspace.Items:GetChildren()) do
                    pcall(function()
                        require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
                    end)
                end
                
                task.wait(1)
            end
            
            notify("Diamond Collection Complete", "Finished collecting diamonds from opened chest", 3)
            disableNoclip()
            
            -- Perform auto teleport if enabled
            performAutoTeleport()
            
            return true -- SUCCESS - Exit function
        end

        -- Chest Didn't Open - Continue with Gate Monitoring
        notify("No Chest Request Detected", "Running gate monitoring script and proceeding with shelf sequence...", 3)
        
        -- Enhanced gate monitoring script with gate opening detection
        local gate = workspace.Map.Landmarks.Stronghold.Functional.FinalGate

        if not gate:GetAttribute("OriginalY") then
            gate:SetAttribute("OriginalY", gate.WorldPivot.Y)
        end

        local lastState
        local gateOpenedDetected = false

        -- Start gate monitoring in separate thread
        task.spawn(function()
            while true do
                local originalY = gate:GetAttribute("OriginalY")
                local currentY = gate.WorldPivot.Y
                local state

                if currentY > originalY then
                    state = "OPEN"
                    if lastState ~= "OPEN" then
                        gateOpenedDetected = true
                        
                        notify("GATE OPENED DETECTED!", "Gate has opened! Stopping cultist killer and preparing chest interaction...", 5)
                        
                        -- Critical: Disable Cultist Killer When Gate Opens
                        CULTIST_KILLER_ENABLED = false
                        if cultistKillerConnection then
                            cultistKillerConnection:Disconnect()
                            cultistKillerConnection = nil
                        end
                        
                        task.wait(4)
                        
                        notify("Re-firing Chest Proximity", "Gate is open, attempting chest interaction again...", 3)
                        
                        -- Fire Proximity Prompt Again After Gate Opens
                        local strongholdChest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
                        if strongholdChest then
                            local proximityPrompt = strongholdChest.Main.ProximityAttachment.ProximityInteraction
                            
                            if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
                                proximityPrompt.HoldDuration = 0
                                proximityPrompt.RequiresLineOfSight = false
                                proximityPrompt.MaxActivationDistance = math.huge
                                
                                if fireproximityprompt then
                                    fireproximityprompt(proximityPrompt)
                                else
                                    proximityPrompt:InputHoldBegin()
                                    proximityPrompt:InputHoldEnd()
                                end
                            end
                        end
                        
                        task.wait(1)
                        
                        -- Collect Diamonds After Gate Opens
                        for attempt = 1, 3 do
                            notify("Gate Open Diamond Collection " .. attempt, "Collecting diamonds after gate opened...", 2)
                            
                            for _, item in pairs(workspace.Items:GetChildren()) do
                                pcall(function()
                                    require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
                                end)
                            end
                            
                            task.wait(1)
                        end
                        
                        -- Perform auto teleport after gate opened diamond collection
                        performAutoTeleport()
                    end
                else
                    state = "CLOSED"
                end

                if state ~= lastState then
                    print("Gate is " .. state .. " at Y:", currentY)
                    lastState = state
                end

                task.wait(5)
            end
        end)

        -- Shelf Pathfinding Sequence (Original Functionality)
        local function MoveToPosition(root, targetPos)
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true,
                AgentCanClimb = false
            })
            
            path:ComputeAsync(root.Position, targetPos)
            
            if path.Status ~= Enum.PathStatus.Success then
                return false
            end

            local waypoints = path:GetWaypoints()
            local currentIndex = 1
            
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bv.Velocity = Vector3.zero
            bv.Parent = root
            
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if not bv.Parent or currentIndex > #waypoints then
                    if bv.Parent then bv:Destroy() end
                    if conn then conn:Disconnect() end
                    return
                end
                
                local wp = waypoints[currentIndex]
                local direction = wp.Position - root.Position
                local distance = direction.Magnitude
                
                if distance < 4 then
                    currentIndex = currentIndex + 1
                else
                    bv.Velocity = direction.Unit * 100
                end
            end)
            
            return true
        end

        -- Navigate to barrel position first
        local decoration = workspace.Map.Landmarks.Stronghold.Building.Interior:WaitForChild("Decoration")
        local barrel = decoration:FindFirstChild("Barrel") or decoration:GetChildren()[27]
        local barrelPos = getPos(barrel)

        if barrelPos then
            HumanoidRootPart.CFrame = CFrame.new(barrelPos + Vector3.new(0, 3, 0))
            task.wait(1)
        end

        -- Navigate to shelf using multiple position attempts
        local shelf = decoration:FindFirstChild("Shelf")
        local shelfPos = getPos(shelf)

        if shelfPos then
            local offsets = {
                Vector3.new(0,0,5), Vector3.new(5,0,0), Vector3.new(-5,0,0),
                Vector3.new(0,0,-5), Vector3.new(3,0,3), Vector3.new(-3,0,3)
            }
            
            for _, offset in ipairs(offsets) do
                if MoveToPosition(HumanoidRootPart, shelfPos + offset) then 
                    task.wait(2)
                    local currentDistance = (HumanoidRootPart.Position - shelfPos).Magnitude
                    if currentDistance <= 10 then
                        print("Successfully reached the shelf! Distance: " .. math.floor(currentDistance))
                        break
                    else
                        print("Failed to reach shelf, trying next position...")
                    end
                end
                task.wait(1)
            end
            
            local finalDistance = (HumanoidRootPart.Position - shelfPos).Magnitude
            if finalDistance <= 10 then
                print("SHELF REACHED SUCCESSFULLY!")
                
                -- Activate Cultist Killer After Successful Shelf Reach
                CULTIST_KILLER_ENABLED = true
                setupCultistKiller()
                
                notify("Cultist Killer Activated", "Auto killing cultists after successful shelf reach", 3)
            else
                print("Could not reach shelf. Final distance: " .. math.floor(finalDistance))
            end
        end

        task.wait(1)

        -- Final Cleanup and Diamond Collection
        for _, item in pairs(workspace.Items:GetChildren()) do
            pcall(function()
                require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
            end)
        end
        
        task.wait(1)
        disableNoclip()
        
        -- Perform auto teleport after successful completion
        performAutoTeleport()
        
        return true
    end)
    
    return false
end

-- Teleport to position function
local function teleportToPosition(position)
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

-- Enhanced Diamond Chest Teleportation with Sequence Integration
local function attemptDiamondChestTeleport()
    if not diamondChestPosition then
        return false, "No diamond chest position stored"
    end
    
    local success, message = teleportToPosition(diamondChestPosition + Vector3.new(0, 5, 0))
    if not success then
        return false, message
    end
    
    notify("Diamond Chest - Phase 1", "Initial teleport successful, starting enhanced sequence...", 3)
    
    task.wait(1)
    notify("Diamond Chest - Phase 2", "Executing pathfinding sequence and chest interaction...", 3)
    
    executeDiamondChestSequence()
    
    task.wait(1)
    notify("Diamond Chest - Phase 3", "Final teleport back to diamond chest position...", 3)
    
    local finalSuccess, finalMessage = teleportToPosition(diamondChestPosition + Vector3.new(0, 5, 0))
    
    if finalSuccess then
        notify("DIAMOND CHEST SEQUENCE COMPLETE!", "All phases completed successfully! Diamond chest interaction finished.", 5)
        return true, "Diamond chest sequence completed successfully"
    else
        return false, "Final teleport failed: " .. finalMessage
    end
end

-- Diamond Chest Detection System with AUTO TELEPORT
local function setupDiamondChestDetection()
    if diamondChestConnection then
        diamondChestConnection:Disconnect()
    end
    
    diamondChestConnection = Items.ChildAdded:Connect(function(child)
        if child.Name == "Stronghold Diamond Chest" then
            if child:IsA("Model") then
                diamondChestPosition = child:GetModelCFrame().Position
            elseif child:IsA("BasePart") then
                diamondChestPosition = child.Position
            end
            
            notify("DIAMOND CHEST DETECTED!", "Starting enhanced teleport sequence immediately!", 5)
            
            task.spawn(function()
                local success, message = attemptDiamondChestTeleport()
                if success then
                    notify("Auto Diamond Chest Complete!", "Successfully completed diamond chest sequence!", 5)
                else
                    notify("Auto Diamond Chest Failed", message, 5)
                end
            end)
        end
    end)
    
    -- Check for existing diamond chests and AUTO START
    for _, child in ipairs(Items:GetChildren()) do
        if child.Name == "Stronghold Diamond Chest" then
            if child:IsA("Model") then
                diamondChestPosition = child:GetModelCFrame().Position
            elseif child:IsA("BasePart") then
                diamondChestPosition = child.Position
            end
            
            notify("DIAMOND CHEST ALREADY AVAILABLE!", "Auto-starting enhanced sequence!", 5)
            
            task.spawn(function()
                task.wait(1)
                local success, message = attemptDiamondChestTeleport()
                if success then
                    notify("Auto Diamond Chest Complete!", "Successfully completed diamond chest sequence!", 5)
                else
                    notify("Auto Diamond Chest Failed", message, 5)
                end
            end)
            break
        end
    end
end

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

-- Setup global functions
_G.DiamondChestTool = {
    execute = function()
        local found = false
        for _, child in ipairs(Items:GetChildren()) do
            if child.Name == "Stronghold Diamond Chest" then
                found = true
                local itemPosition
                if child:IsA("Model") then
                    itemPosition = child:GetModelCFrame().Position
                elseif child:IsA("BasePart") then
                    itemPosition = child.Position
                end
                
                if itemPosition then
                    diamondChestPosition = itemPosition
                    
                    notify("External Script Trigger", "Diamond chest sequence triggered by external script!", 3)
                    
                    local success, message = attemptDiamondChestTeleport()
                    if success then
                        notify("External Trigger Success", "Diamond chest sequence completed successfully!", 5)
                        return true
                    else
                        notify("External Trigger Failed", message, 5)
                        return false
                    end
                end
                break
            end
        end
        
        if not found then
            notify("External Trigger Failed", "No Diamond Chest available for external trigger", 3)
            return false
        end
    end,
    
    setAutoTeleport = function(enabled)
        AUTO_TELEPORT_ENABLED = enabled
        notify("Auto Teleport Toggle", "Auto teleport after success: " .. (enabled and "ENABLED" or "DISABLED"), 3)
        return AUTO_TELEPORT_ENABLED
    end,
    
    getAutoTeleportStatus = function()
        return AUTO_TELEPORT_ENABLED
    end
}

-- Initialize
setupDiamondChestDetection()

print("Diamond Chest Tool Loaded - Complete Version")
print("Usage: _G.DiamondChestTool.execute()")
print("Auto Teleport: _G.DiamondChestTool.setAutoTeleport(true/false)")
print("Auto detection enabled - will run when diamond chest spawns")
