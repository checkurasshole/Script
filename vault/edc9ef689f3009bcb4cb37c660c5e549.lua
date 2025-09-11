-- Protected Script (Italian)
-- Script ID: edc9ef689f3009bcb4cb37c660c5e549
-- Migrated: 2025-09-11T13:21:20.765Z
-- Auto-migrated from encrypted storage to GitHub

local Fluent = loadstring(game:HttpGet("__URL_5b1b25e7ca4ee358__"))()
local SaveManager = loadstring(game:HttpGet("__URL_2131249e7d67ebbe__"))()
local InterfaceManager = loadstring(game:HttpGet("__URL_552beeec0963115c__"))()

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Name = "ComboWickToggle"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "COMBO_WICK"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 12
ToggleButton.Active = true
ToggleButton.Draggable = true

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleButton

UIStroke.Parent = ToggleButton
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.Thickness = 2

ToggleButton.MouseEnter:Connect(function()
    local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    })
    tween:Play()
end)

ToggleButton.MouseLeave:Connect(function()
    local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    })
    tween:Play()
end)

local flingActive = false
local flingBox = Instance.new("Part")
flingBox.Anchored = true
flingBox.CanCollide = false
local flingStrength = 200
local walls = {}
local boxSize = Vector3.new(50, 30, 50)
local currentPower = 300
local boxCenter = nil
local containmentConnection = nil

local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local rootPart = getRoot()

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    rootPart = newChar:WaitForChild("HumanoidRootPart", 5)
end)

local autoBuyLeg = false
local autoBuyArm = false
local autoBuyTorso = false
local autoBuyHead = false
local PurchaseBoneUpgrade = ReplicatedStorage.Remotes.PurchaseBoneUpgrade
local afkConnections = {}
local autoBuyLoops = {}

-- Improved containment function
local function enforceContainment()
    if not rootPart or not boxCenter then return end
    
    local pos = rootPart.Position
    local halfSize = boxSize / 2
    local newPos = pos
    local needsCorrection = false
    
    -- Check each axis and clamp position
    if pos.X > boxCenter.X + halfSize.X - 5 then
        newPos = Vector3.new(boxCenter.X + halfSize.X - 5, newPos.Y, newPos.Z)
        needsCorrection = true
    elseif pos.X < boxCenter.X - halfSize.X + 5 then
        newPos = Vector3.new(boxCenter.X - halfSize.X + 5, newPos.Y, newPos.Z)
        needsCorrection = true
    end
    
    if pos.Y > boxCenter.Y + halfSize.Y - 5 then
        newPos = Vector3.new(newPos.X, boxCenter.Y + halfSize.Y - 5, newPos.Z)
        needsCorrection = true
    elseif pos.Y < boxCenter.Y - halfSize.Y + 5 then
        newPos = Vector3.new(newPos.X, boxCenter.Y - halfSize.Y + 5, newPos.Z)
        needsCorrection = true
    end
    
    if pos.Z > boxCenter.Z + halfSize.Z - 5 then
        newPos = Vector3.new(newPos.X, newPos.Y, boxCenter.Z + halfSize.Z - 5)
        needsCorrection = true
    elseif pos.Z < boxCenter.Z - halfSize.Z + 5 then
        newPos = Vector3.new(newPos.X, newPos.Y, boxCenter.Z - halfSize.Z + 5)
        needsCorrection = true
    end
    
    -- Apply correction with velocity dampening
    if needsCorrection then
        rootPart.CFrame = CFrame.new(newPos)
        -- Reduce velocity when hitting walls to prevent bouncing through
        local currentVel = rootPart.Velocity
        rootPart.Velocity = currentVel * 0.5
        rootPart.AngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function createWalls()
    if not rootPart then return end
    
    for _, wall in ipairs(walls) do
        if wall and wall.Parent then
            wall:Destroy()
        end
    end
    walls = {}
    
    boxCenter = rootPart.Position
    local s = boxSize/2
    
    -- Make walls much thicker (10 units instead of 2)
    local wallPositions = {
        {boxCenter + Vector3.new(s.X, 0, 0), Vector3.new(10, boxSize.Y, boxSize.Z)},
        {boxCenter - Vector3.new(s.X, 0, 0), Vector3.new(10, boxSize.Y, boxSize.Z)},
        {boxCenter + Vector3.new(0, s.Y, 0), Vector3.new(boxSize.X, 10, boxSize.Z)},
        {boxCenter - Vector3.new(0, s.Y, 0), Vector3.new(boxSize.X, 10, boxSize.Z)},
        {boxCenter + Vector3.new(0, 0, s.Z), Vector3.new(boxSize.X, boxSize.Y, 10)},
        {boxCenter - Vector3.new(0, 0, s.Z), Vector3.new(boxSize.X, boxSize.Y, 10)}
    }
    
    for _, wallData in ipairs(wallPositions) do
        local wall = Instance.new("Part")
        wall.Name = "FlingWall"
        wall.Anchored = true
        wall.CanCollide = true
        wall.Transparency = 0.3
        wall.Material = Enum.Material.ForceField
        wall.BrickColor = BrickColor.new("Bright blue")
        wall.Size = wallData[2]
        wall.Position = wallData[1]
        wall.Parent = workspace
        
        -- Add custom physics properties for better containment
        wall.CustomPhysicalProperties = PhysicalProperties.new(
            0.7,    -- Density
            0.5,    -- Friction
            0.2,    -- Elasticity (low to prevent bouncing)
            1,      -- FrictionWeight
            1       -- ElasticityWeight
        )
        
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Adornee = wall
        selectionBox.Color3 = Color3.fromRGB(0, 150, 255)
        selectionBox.LineThickness = 0.2
        selectionBox.Transparency = 0.5
        selectionBox.Parent = wall
        
        table.insert(walls, wall)
    end
end

local function removeWalls()
    for _, wall in ipairs(walls) do
        if wall and wall.Parent then
            wall:Destroy()
        end
    end
    walls = {}
    boxCenter = nil
end

-- Improved fling system with better containment
RunService.Heartbeat:Connect(function()
    if flingActive and rootPart and boxCenter then
        -- First enforce containment
        enforceContainment()
        
        -- Then apply fling force, but keep it more controlled
        local pos = rootPart.Position
        local randomOffset = Vector3.new(
            math.random(-8, 8),
            math.random(-8, 8), 
            math.random(-8, 8)
        )
        
        local targetPos = boxCenter + randomOffset
        local direction = (targetPos - pos).Unit
        
        -- Scale the force based on distance from center to create more natural movement
        local distanceFromCenter = (pos - boxCenter).Magnitude
        local maxDistance = (boxSize / 2).Magnitude
        local forceMultiplier = math.min(1, distanceFromCenter / maxDistance)
        
        local adjustedStrength = flingStrength * (0.3 + forceMultiplier * 0.7)
        rootPart.Velocity = direction * adjustedStrength
    end
end)

local function startFling()
    if not rootPart then
        rootPart = getRoot()
        if not rootPart then
            return false
        end
    end
    
    flingActive = true
    createWalls()
    
    flingBox.Transparency = 1
    flingBox.Size = Vector3.new(10, 10, 10)
    flingBox.Parent = workspace
    
    -- Start containment enforcement
    containmentConnection = RunService.Heartbeat:Connect(enforceContainment)
    
    return true
end

local function stopFling()
    flingActive = false
    removeWalls()
    
    if containmentConnection then
        containmentConnection:Disconnect()
        containmentConnection = nil
    end
    
    if flingBox and flingBox.Parent then
        flingBox.Parent = nil
    end
    
    if rootPart then
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.AngularVelocity = Vector3.new(0, 0, 0)
    end
end

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
    Main = Window:AddTab({ Title = "Principale", Icon = "activity" }),
    Shop = Window:AddTab({ Title = "Negozio", Icon = "shopping-cart" }),
    AntiAFK = Window:AddTab({ Title = "Nessun calcio", Icon = "shield" })
}

local guiVisible = true
local fluentGuis = {}

local function findAllFluentGuis()
    fluentGuis = {}
    
    for _, gui in pairs(game.CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= ScreenGui then
            local isFluentGui = false
            
            if gui.Name:lower():find("fluent") or gui.Name:lower():find("library") then
                isFluentGui = true
            end
            
            if gui:FindFirstChild("Main") then
                local main = gui.Main
                if main:FindFirstChild("Navigation") and main:FindFirstChild("TabContainer") then
                    isFluentGui = true
                end
            end
            
            for _, child in pairs(gui:GetDescendants()) do
                if child.Name == "Acrylic" or child.Name == "DropShadow" or 
                   (child:IsA("TextLabel") and child.Text == "COMBO_WICK") then
                    isFluentGui = true
                    break
                end
            end
            
            if isFluentGui then
                table.insert(fluentGuis, gui)
            end
        end
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    
    findAllFluentGuis()
    
    for _, gui in pairs(fluentGuis) do
        if gui and gui.Parent then
            gui.Enabled = guiVisible
        end
    end
    
    if guiVisible then
        ToggleButton.Text = "COMBO_WICK"
        UIStroke.Color = Color3.fromRGB(0, 150, 255)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    else
        ToggleButton.Text = "NASCOSTO"  
        UIStroke.Color = Color3.fromRGB(255, 100, 100)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    end
end)

Tabs.Main:AddToggle("BounceToggle", {
    Title = "Inizia",
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
    Title = "Potenza e velocità",
    Default = 300,
    Min = 100,
    Max = 1000,
    Rounding = 10,
    Callback = function(Value)
        flingStrength = Value
        currentPower = Value
    end
})

Tabs.Main:AddButton({
    Title = "- Potenza 50%",
    Description = "Decrease power by 50",
    Callback = function()
        currentPower = math.max(100, currentPower - 50)
        flingStrength = currentPower
    end
})

Tabs.Main:AddButton({
    Title = "Potenza= 50 %;",
    Description = "Increase power by 50",
    Callback = function()
        currentPower = math.min(1000, currentPower + 50)
        flingStrength = currentPower
    end
})

Tabs.Shop:AddToggle("AutoLeg", {
    Title = "Acquisto automatico gambe",
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
    Title = "Acquisto automatico di armi", 
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
    Title = "Acquisto automatico busto",
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
    Title = "Testa per acquisto automatico",
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

Tabs.AntiAFK:AddToggle("Anti Kick", {
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