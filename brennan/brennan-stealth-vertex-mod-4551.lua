-- Diamond Chest Core Module - Simple Version
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
local diamondChestPosition = nil

-- Simple notification
local function notify(title, content)
    if _G.Fluent then
        _G.Fluent:Notify({Title = title, Content = content, Duration = 3})
    else
        print("[" .. title .. "] " .. content)
    end
end

-- Get position helper
local function getPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local part = obj:FindFirstChildWhichIsA("BasePart")
        return part and part.Position or obj:GetPivot().Position
    end
end

-- Cultist killer
local function killCultists()
    local damaged = 0
    for _, weapon in pairs(LocalPlayer:WaitForChild("Inventory"):GetChildren()) do
        if string.find(string.lower(weapon.Name), "axe") or 
           string.find(string.lower(weapon.Name), "sword") or 
           string.find(string.lower(weapon.Name), "spear") then
            
            for _, enemy in pairs(workspace:GetDescendants()) do
                if enemy:IsA("Model") and enemy ~= LocalPlayer.Character and 
                   (enemy.Name == "Cultist" or enemy.Name == "Crossbow Cultist") then
                    pcall(function()
                        ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                            enemy, weapon, "1_" .. LocalPlayer.UserId, HumanoidRootPart.CFrame
                        )
                        damaged = damaged + 1
                    end)
                end
            end
            break
        end
    end
    return damaged
end

local function setupCultistKiller()
    if cultistKillerConnection then cultistKillerConnection:Disconnect() end
    if not CULTIST_KILLER_ENABLED then return end
    
    cultistKillerConnection = RunService.Heartbeat:Connect(function()
        if CULTIST_KILLER_ENABLED and tick() - lastCultistKillTime >= 1 then
            if killCultists() > 0 then
                lastCultistKillTime = tick()
            end
        end
    end)
end

-- Auto teleport after success
local function doAutoTeleport()
    if AUTO_TELEPORT_ENABLED then
        notify("Auto Teleport", "Teleporting in 3 seconds...")
        task.wait(3)
        pcall(function() TeleportService:Teleport(126509999114328) end)
    end
end

-- Main diamond chest sequence
local function executeDiamondChestSequence()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    local humanoid = Character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = 50

    -- Noclip functions
    local function enableNoclip()
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    local function disableNoclip()
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end

    enableNoclip()

    -- Metatable hook for chest detection
    local chestOpened = false
    if getrawmetatable then
        local mt = getrawmetatable(game)
        if mt and mt.__namecall then
            local oldNamecall = mt.__namecall
            if setreadonly then setreadonly(mt, false) end
            
            mt.__namecall = function(self, ...)
                local method = getnamecallmethod and getnamecallmethod() or ""
                if method == "FireServer" and tostring(self):find("RequestOpenItemChest") then
                    chestOpened = true
                end
                return oldNamecall(self, ...)
            end
            
            if setreadonly then setreadonly(mt, true) end
        end
    end

    -- Fire chest prompt
    local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
    if chest then
        local prompt = chest.Main.ProximityAttachment.ProximityInteraction
        if prompt then
            notify("Diamond Chest", "Firing proximity prompt...")
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = math.huge
            
            if fireproximityprompt then
                fireproximityprompt(prompt)
            else
                prompt:InputHoldBegin()
                prompt:InputHoldEnd()
            end
        end
    end
    
    task.wait(3)

    -- If chest opened, collect diamonds and exit
    if chestOpened then
        notify("Success", "Chest opened! Collecting diamonds...")
        for i = 1, 3 do
            for _, item in pairs(workspace.Items:GetChildren()) do
                pcall(function()
                    require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
                end)
            end
            task.wait(1)
        end
        disableNoclip()
        doAutoTeleport()
        return
    end

    -- Gate monitoring
    local gate = workspace.Map.Landmarks.Stronghold.Functional.FinalGate
    if not gate:GetAttribute("OriginalY") then
        gate:SetAttribute("OriginalY", gate.WorldPivot.Y)
    end

    task.spawn(function()
        local lastState = nil
        while true do
            local originalY = gate:GetAttribute("OriginalY")
            local currentY = gate.WorldPivot.Y
            local state = currentY > originalY and "OPEN" or "CLOSED"

            if state == "OPEN" and lastState ~= "OPEN" then
                notify("Gate Opened", "Stopping cultists and re-firing chest...")
                CULTIST_KILLER_ENABLED = false
                if cultistKillerConnection then
                    cultistKillerConnection:Disconnect()
                    cultistKillerConnection = nil
                end

                task.wait(4)
                
                -- Re-fire chest prompt
                local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
                if chest then
                    local prompt = chest.Main.ProximityAttachment.ProximityInteraction
                    if prompt then
                        prompt.HoldDuration = 0
                        prompt.RequiresLineOfSight = false
                        prompt.MaxActivationDistance = math.huge
                        
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            prompt:InputHoldBegin()
                            prompt:InputHoldEnd()
                        end
                    end
                end

                task.wait(1)

                -- Collect diamonds
                for i = 1, 3 do
                    for _, item in pairs(workspace.Items:GetChildren()) do
                        pcall(function()
                            require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
                        end)
                    end
                    task.wait(1)
                end

                doAutoTeleport()
                break
            end
            lastState = state
            task.wait(5)
        end
    end)

    -- Pathfinding to shelf
    local function moveToPosition(root, targetPos)
        local path = PathfindingService:CreatePath({
            AgentRadius = 2, AgentHeight = 5, AgentCanJump = true
        })
        path:ComputeAsync(root.Position, targetPos)
        
        if path.Status ~= Enum.PathStatus.Success then return false end

        local waypoints = path:GetWaypoints()
        local currentIndex = 1
        
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Velocity = Vector3.zero
        bv.Parent = root
        
        local conn = RunService.Heartbeat:Connect(function()
            if not bv.Parent or currentIndex > #waypoints then
                if bv.Parent then bv:Destroy() end
                conn:Disconnect()
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

    -- Navigate to shelf
    local decoration = workspace.Map.Landmarks.Stronghold.Building.Interior:WaitForChild("Decoration")
    local barrel = decoration:FindFirstChild("Barrel") or decoration:GetChildren()[27]
    local barrelPos = getPos(barrel)

    if barrelPos then
        HumanoidRootPart.CFrame = CFrame.new(barrelPos + Vector3.new(0, 3, 0))
        task.wait(1)
    end

    local shelf = decoration:FindFirstChild("Shelf")
    local shelfPos = getPos(shelf)

    if shelfPos then
        local offsets = {
            Vector3.new(0,0,5), Vector3.new(5,0,0), Vector3.new(-5,0,0),
            Vector3.new(0,0,-5), Vector3.new(3,0,3), Vector3.new(-3,0,3)
        }
        
        for _, offset in ipairs(offsets) do
            if moveToPosition(HumanoidRootPart, shelfPos + offset) then 
                task.wait(2)
                local currentDistance = (HumanoidRootPart.Position - shelfPos).Magnitude
                if currentDistance <= 10 then
                    print("Reached shelf! Distance: " .. math.floor(currentDistance))
                    break
                end
            end
            task.wait(1)
        end
        
        local finalDistance = (HumanoidRootPart.Position - shelfPos).Magnitude
        if finalDistance <= 10 then
            CULTIST_KILLER_ENABLED = true
            setupCultistKiller()
            notify("Cultist Killer", "Activated after reaching shelf")
        end
    end

    -- Final diamond collection
    for _, item in pairs(workspace.Items:GetChildren()) do
        pcall(function()
            require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
        end)
    end
    
    task.wait(1)
    disableNoclip()
    doAutoTeleport()
end

-- Teleport function
local function teleportToChest()
    if not diamondChestPosition then
        notify("Error", "No diamond chest position stored")
        return false
    end
    
    local targetCFrame = CFrame.new(diamondChestPosition + Vector3.new(0, 5, 0))
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    tween.Completed:Wait()
    
    task.wait(1)
    executeDiamondChestSequence()
    return true
end

-- Auto detection
local function setupAutoDetection()
    Items.ChildAdded:Connect(function(child)
        if child.Name == "Stronghold Diamond Chest" then
            if child:IsA("Model") then
                diamondChestPosition = child:GetModelCFrame().Position
            elseif child:IsA("BasePart") then
                diamondChestPosition = child.Position
            end
            
            notify("Auto Detection", "Diamond chest detected! Starting sequence...")
            task.spawn(teleportToChest)
        end
    end)
    
    -- Check existing chests
    for _, child in ipairs(Items:GetChildren()) do
        if child.Name == "Stronghold Diamond Chest" then
            if child:IsA("Model") then
                diamondChestPosition = child:GetModelCFrame().Position
            elseif child:IsA("BasePart") then
                diamondChestPosition = child.Position
            end
            
            notify("Auto Detection", "Existing diamond chest found!")
            task.spawn(function()
                task.wait(1)
                teleportToChest()
            end)
            break
        end
    end
end

-- Character respawn
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
                if child:IsA("Model") then
                    diamondChestPosition = child:GetModelCFrame().Position
                elseif child:IsA("BasePart") then
                    diamondChestPosition = child.Position
                end
                teleportToChest()
                break
            end
        end
        if not found then
            notify("Error", "No diamond chest available")
        end
    end,
    
    setAutoTeleport = function(enabled)
        AUTO_TELEPORT_ENABLED = enabled
        notify("Auto Teleport", enabled and "ENABLED" or "DISABLED")
    end
}

-- Initialize
setupAutoDetection()

print("Diamond Chest Tool Loaded")
print("Usage: _G.DiamondChestTool.execute()")
print("Auto Teleport: _G.DiamondChestTool.setAutoTeleport(true/false)")
