-- Original English Script
-- Script ID: a4fd88e0b6df1a3daf91d54c667306b9
-- Migrated: 2025-09-11T13:21:13.972Z
-- Auto-migrated from encrypted storage to GitHub

local Fluent = loadstring(game:HttpGet("__URL_b59f8e95bb497baf__"))()
local SaveManager = loadstring(game:HttpGet("__URL_7077617bd6ecb683__"))()
local InterfaceManager = loadstring(game:HttpGet("__URL_a3c440fa7f792ac6__"))()

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")


local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

local ragdoll
repeat
    wait()
    if workspace:FindFirstChild(player.Name) and workspace[player.Name]:FindFirstChild("Ragdoll") then
        ragdoll = workspace[player.Name].Ragdoll.Default
    end
until ragdoll

local parts = {}
for _, part in pairs(ragdoll:GetChildren()) do
    if part:IsA("BasePart") then
        table.insert(parts, part)
    end
end

local boxSize = Vector3.new(50,30,50)
local walls = {}
local flingStrength = 300
local flingInterval = 0.03
local active = false
local spinning = false
local flingConnection
local boundsConnection
local boxCenter
local spinSpeed = 20
local autoBuyLeg = false
local autoBuyArm = false
local autoBuyTorso = false
local autoBuyHead = false

local PurchaseBoneUpgrade = ReplicatedStorage.Remotes.PurchaseBoneUpgrade

local afkConnections = {}

local function startAntiAFK()
    afkConnections[1] = game:GetService("Players").LocalPlayer.Idled:connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
    
    afkConnections[2] = RunService.Heartbeat:Connect(function()
        if math.random(1,600) == 1 then
            VirtualUser:MoveMouse(Vector2.new(math.random(-50,50), math.random(-50,50)))
        end
    end)
    
    afkConnections[3] = spawn(function()
        while wait(300) do
            keypress(0x20)
            wait(0.1)
            keyrelease(0x20)
        end
    end)
    
    afkConnections[4] = spawn(function()
        while wait(120) do
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(".", "All")
            wait(0.5)
        end
    end)
end

local function stopAntiAFK()
    for i, connection in pairs(afkConnections) do
        if connection then
            if type(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
        end
    end
    afkConnections = {}
end

local function updateBoxCenter()
    if ragdoll:FindFirstChild("HumanoidRootPart") then
        boxCenter = ragdoll.HumanoidRootPart.Position
    elseif ragdoll:FindFirstChild("Torso") then
        boxCenter = ragdoll.Torso.Position
    end
end

local function createWall(position, size)
    local wall = Instance.new("Part")
    wall.Name = "FlingWall"
    wall.Anchored = true
    wall.CanCollide = true
    wall.Transparency = 0.3
    wall.Material = Enum.Material.Neon
    wall.BrickColor = BrickColor.new("Bright blue")
    wall.Size = size
    wall.Position = position
    wall.Parent = workspace
    
    if size.X <= 3 then
        wall.Size = Vector3.new(5, size.Y, size.Z)
    elseif size.Y <= 3 then
        wall.Size = Vector3.new(size.X, 5, size.Z)
    elseif size.Z <= 3 then
        wall.Size = Vector3.new(size.X, size.Y, 5)
    end
    
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = wall
    selectionBox.Color3 = Color3.fromRGB(0, 150, 255)
    selectionBox.LineThickness = 0.2
    selectionBox.Transparency = 0.5
    selectionBox.Parent = wall
    
    table.insert(walls, wall)
end

local function generateWalls()
    updateBoxCenter()
    if not boxCenter then return end
    
    local s = boxSize/2
    createWall(boxCenter + Vector3.new(s.X, 0, 0), Vector3.new(2, boxSize.Y, boxSize.Z))
    createWall(boxCenter - Vector3.new(s.X, 0, 0), Vector3.new(2, boxSize.Y, boxSize.Z))
    createWall(boxCenter + Vector3.new(0, s.Y, 0), Vector3.new(boxSize.X, 2, boxSize.Z))
    createWall(boxCenter - Vector3.new(0, s.Y, 0), Vector3.new(boxSize.X, 2, boxSize.Z))
    createWall(boxCenter + Vector3.new(0, 0, s.Z), Vector3.new(boxSize.X, boxSize.Y, 2))
    createWall(boxCenter - Vector3.new(0, 0, s.Z), Vector3.new(boxSize.X, boxSize.Y, 2))
end

local function keepInBounds()
    local rootPart = ragdoll:FindFirstChild("HumanoidRootPart") or ragdoll:FindFirstChild("Torso")
    if not rootPart or not boxCenter then return end
    
    local buffer = 3
    local s = boxSize/2 - Vector3.new(buffer, buffer, buffer)
    local minBounds = boxCenter - s
    local maxBounds = boxCenter + s
    
    for _, part in ipairs(parts) do
        if part and part.Parent and part:IsA("BasePart") then
            local partPos = part.Position
            local needsCorrection = false
            local correctedPos = partPos
            
            if partPos.X < minBounds.X then 
                correctedPos = Vector3.new(minBounds.X + 1, correctedPos.Y, correctedPos.Z)
                needsCorrection = true
            elseif partPos.X > maxBounds.X then
                correctedPos = Vector3.new(maxBounds.X - 1, correctedPos.Y, correctedPos.Z)
                needsCorrection = true
            end
            
            if partPos.Y < minBounds.Y then
                correctedPos = Vector3.new(correctedPos.X, minBounds.Y + 1, correctedPos.Z)
                needsCorrection = true
            elseif partPos.Y > maxBounds.Y then
                correctedPos = Vector3.new(correctedPos.X, maxBounds.Y - 1, correctedPos.Z)
                needsCorrection = true
            end
            
            if partPos.Z < minBounds.Z then
                correctedPos = Vector3.new(correctedPos.X, correctedPos.Y, minBounds.Z + 1)
                needsCorrection = true
            elseif partPos.Z > maxBounds.Z then
                correctedPos = Vector3.new(correctedPos.X, correctedPos.Y, maxBounds.Z - 1)
                needsCorrection = true
            end
            
            if needsCorrection then
                part.CFrame = CFrame.new(correctedPos, correctedPos + (boxCenter - correctedPos).Unit)
                
                for _, obj in pairs(part:GetChildren()) do
                    if obj:IsA("BodyVelocity") and obj.Name ~= "Spinning" then
                        obj:Destroy()
                    end
                end
                
                local bounceDirection = (boxCenter - correctedPos).Unit
                local safeVelocity = bounceDirection * math.min(flingStrength, 400)
                
                local bounceForce = Instance.new("BodyVelocity")
                bounceForce.Velocity = safeVelocity
                bounceForce.MaxForce = Vector3.new(5e4, 5e4, 5e4)
                bounceForce.P = 8e4
                bounceForce.Parent = part
                Debris:AddItem(bounceForce, 0.2)
            end
        end
    end
end

local function startSpin()
    local rootPart = ragdoll:FindFirstChild("HumanoidRootPart") or ragdoll:FindFirstChild("Torso")
    if not rootPart then return end
    
    for i,v in pairs(rootPart:GetChildren()) do
        if v.Name == "Spinning" then
            v:Destroy()
        end
    end
    
    local Spin = Instance.new("BodyAngularVelocity")
    Spin.Name = "Spinning"
    Spin.Parent = rootPart
    Spin.MaxTorque = Vector3.new(0, math.huge, 0)
    Spin.AngularVelocity = Vector3.new(0, spinSpeed, 0)
    spinning = true
end

local function stopSpin()
    local rootPart = ragdoll:FindFirstChild("HumanoidRootPart") or ragdoll:FindFirstChild("Torso")
    if rootPart then
        for i,v in pairs(rootPart:GetChildren()) do
            if v.Name == "Spinning" then
                v:Destroy()
            end
        end
    end
    spinning = false
end

local function flingRagdoll()
    for _, part in ipairs(parts) do
        if part and part.Parent and part:IsA("BasePart") then
            local partPos = part.Position
            local buffer = 4
            local s = boxSize/2 - Vector3.new(buffer, buffer, buffer)
            local minBounds = boxCenter - s
            local maxBounds = boxCenter + s
            
            if partPos.X <= minBounds.X or partPos.X >= maxBounds.X or
               partPos.Y <= minBounds.Y or partPos.Y >= maxBounds.Y or
               partPos.Z <= minBounds.Z or partPos.Z >= maxBounds.Z then
                return
            end
            
            for _, obj in pairs(part:GetChildren()) do
                if obj:IsA("BodyVelocity") and obj.Name ~= "Spinning" then
                    obj:Destroy()
                end
            end
            
            local centerDirection = (boxCenter - partPos).Unit
            local randomDirection = Vector3.new(
                math.random(-100, 100)/100,
                math.random(-100, 100)/100,
                math.random(-100, 100)/100
            )
            
            local safeDirection = (centerDirection * 0.3 + randomDirection * 0.7).Unit
            local maxSafeForce = math.min(flingStrength, 600)
            local forceMultiplier = math.random(50, 100)/100
            local randomForce = safeDirection * (maxSafeForce * forceMultiplier)
            
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = randomForce
            bv.MaxForce = Vector3.new(6e4, 6e4, 6e4)
            bv.P = 5e4
            bv.Parent = part
            Debris:AddItem(bv, flingInterval * 1.5)
            
            if math.random() > 0.8 then
                local impulse = Instance.new("BodyVelocity")
                impulse.Velocity = Vector3.new(
                    math.random(-200, 200),
                    math.random(-150, 250),
                    math.random(-200, 200)
                )
                impulse.MaxForce = Vector3.new(3e4, 3e4, 3e4)
                impulse.P = 4e4
                impulse.Parent = part
                Debris:AddItem(impulse, 0.05)
            end
        end
    end
end

local function startFling()
    active = true
    generateWalls()
    startSpin()
    
    flingConnection = RunService.Heartbeat:Connect(function()
        if active then
            flingRagdoll()
        end
    end)
    
    boundsConnection = RunService.Heartbeat:Connect(function()
        if active then
            keepInBounds()
        end
    end)
end

local function stopFling()
    active = false
    
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    
    if boundsConnection then
        boundsConnection:Disconnect()
        boundsConnection = nil
    end
    
    stopSpin()
    
    for _, wall in ipairs(walls) do
        if wall and wall.Parent then
            wall:Destroy()
        end
    end
    walls = {}
    
    for _, part in ipairs(parts) do
        if part and part.Parent then
            for _, obj in pairs(part:GetChildren()) do
                if obj:IsA("BodyMover") then
                    obj:Destroy()
                end
            end
        end
    end
end

local autoBuyLoops = {}

local function startAutoBuy(partName)
    autoBuyLoops[partName] = spawn(function()
        while true do
            if partName == "Leg" and autoBuyLeg then
                PurchaseBoneUpgrade:FireServer("Leg")
            elseif partName == "Arm" and autoBuyArm then
                PurchaseBoneUpgrade:FireServer("Arm")
            elseif partName == "Torso" and autoBuyTorso then
                PurchaseBoneUpgrade:FireServer("Torso")
            elseif partName == "Head" and autoBuyHead then
                PurchaseBoneUpgrade:FireServer("Head")
            end
            wait(0.1)
        end
    end)
end

local function stopAutoBuy(partName)
    if autoBuyLoops[partName] then
        autoBuyLoops[partName] = nil
    end
end

local Window = Fluent:CreateWindow({
    Title = "COMBO_WICK",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(350, 250),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "activity" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    AntiAFK = Window:AddTab({ Title = "Anti AFK", Icon = "shield" })
}

Tabs.Main:AddToggle("BounceToggle", {
    Title = "Fast AutoFarm",
    Default = false,
    Callback = function(Value)
        if Value then
            startFling()
        else
            stopFling()
        end
    end
})

Tabs.Main:AddSlider("PowerSlider", {
    Title = "Power & Speed",
    Default = 300,
    Min = 100,
    Max = 1000,
    Rounding = 1,
    Callback = function(Value)
        flingStrength = Value
        spinSpeed = math.floor(Value / 15)
        if spinning then
            local rootPart = ragdoll:FindFirstChild("HumanoidRootPart") or ragdoll:FindFirstChild("Torso")
            if rootPart then
                for i,v in pairs(rootPart:GetChildren()) do
                    if v.Name == "Spinning" then
                        v.AngularVelocity = Vector3.new(0, spinSpeed, 0)
                    end
                end
            end
        end
    end
})

Tabs.Shop:AddToggle("AutoLeg", {
    Title = "Auto Buy Legs",
    Default = false,
    Callback = function(Value)
        autoBuyLeg = Value
        if Value then
            startAutoBuy("Leg")
        else
            stopAutoBuy("Leg")
        end
    end
})

Tabs.Shop:AddToggle("AutoArm", {
    Title = "Auto Buy Arms", 
    Default = false,
    Callback = function(Value)
        autoBuyArm = Value
        if Value then
            startAutoBuy("Arm")
        else
            stopAutoBuy("Arm")
        end
    end
})

Tabs.Shop:AddToggle("AutoTorso", {
    Title = "Auto Buy Torso",
    Default = false,
    Callback = function(Value)
        autoBuyTorso = Value
        if Value then
            startAutoBuy("Torso")
        else
            stopAutoBuy("Torso")
        end
    end
})

Tabs.Shop:AddToggle("AutoHead", {
    Title = "Auto Buy Head",
    Default = false,
    Callback = function(Value)
        autoBuyHead = Value
        if Value then
            startAutoBuy("Head")
        else
            stopAutoBuy("Head")
        end
    end
})

Tabs.AntiAFK:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = false,
    Callback = function(Value)
        if Value then
            startAntiAFK()
        else
            stopAntiAFK()
        end
    end
})

Window:SelectTab(1)

player.CharacterAdded:Connect(function()
    if active then
        stopFling()
    end
end)