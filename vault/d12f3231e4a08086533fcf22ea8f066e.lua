-- Protected Script (French)
-- Script ID: d12f3231e4a08086533fcf22ea8f066e
-- Migrated: 2025-09-11T12:58:24.534Z
-- Auto-migrated from encrypted storage to GitHub

loadstring(game:HttpGet("__URL_7ab5a164bc78b242__"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("__URL_c782a8c1dccd7c6a__"))()

local Window = Fluent:CreateWindow({
    Title = "_COMBO WICK",
    SubTitle = "Amusez-vous bien !",
    TabWidth = 120,
    Size = UDim2.fromOffset(450, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ToggleGui"
ScreenGui.Parent = game.CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(1, -60, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ToggleButton.Text = "GUI"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextScaled = true
ToggleButton.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = ToggleButton

local isVisible = true

ToggleButton.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    Window.Root.Visible = isVisible
end)

local isDragging = false
local dragStart, startPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

local Tab = Window:AddTab({
    Title = "Principales",
    Icon = "home"
})

Tab:AddParagraph({
    Title = "État du mode Dieu Le mode Dieu est automatiquement activé sur le chargement d...",
    Content = "Fonctionne le mieux en seul joueur"
})

local TeleportSection = Tab:AddSection("Teleport Controls")
local MovementSection = Tab:AddSection("Movement Controls")
local CombatSection = Tab:AddSection("Combat Controls")

local CONFIG = {
    DefaultHeightOffset = 6,
    MinHeightOffset = -50,
    MaxHeightOffset = 12,
    MaxTeleportDistance = 500,
    SafetyDistance = 50,
}

local processedDoors = {}
local doorSystemConnection
local doorSystemActive = true

local noclipEnabled = false
local noclipConnection = nil

local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1
local flyKeyDown, flyKeyUp
local velocityHandlerName = "VelocityHandler_" .. math.random(1000, 9999)
local gyroHandlerName = "GyroHandler_" .. math.random(1000, 9999)
local mfly1, mfly2

local TeleportActive = false
local HeightOffset = CONFIG.DefaultHeightOffset
local teleportConnection
local TargetHead = true
local TeleportStats = {
    totalTeleports = 0,
    lastTarget = "None"
}
local DoorAvoidanceDistance = 15

local Skill1Toggle, Skill2Toggle, Skill3Toggle = false, false, false
local BufferSpamActive = false
local AutoSpinActive = false
local SpamRate = 0.05

local ByteNetReliable = ReplicatedStorage:WaitForChild("ByteNetReliable")

local SkillBuffers = {
    buffer.fromstring("\7\3\1"),
    buffer.fromstring("\7\5\1"),
    buffer.fromstring("\7\6\1"),
}
local bufferData = buffer.fromstring("\7\4\1")

local doorCache = {}
local doorCacheTime = 0
local targetCache = {}
local targetCacheTime = 0
local CACHE_DURATION = 2

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function isValidPosition(position)
    if not position then return false end
    
    if position.Y < -1000 then return false end
    
    if math.abs(position.X) > 10000 or math.abs(position.Z) > 10000 then return false end
    
    return true
end

local function getModules()
    local gameCore = game.ReplicatedFirst:WaitForChild("GameCore", 5)
    local shared = gameCore:WaitForChild("Shared", 5)
    local enumeration = require(gameCore:WaitForChild("Enumeration"))
    local doorAnimTypes = require(gameCore:FindFirstChild("DoorAnimTypes", true))
    
    return enumeration, doorAnimTypes
end

local function playDoorAnimation(door, animType)
    local enumeration, doorAnimTypes = getModules()
    local animFunction = doorAnimTypes[enumeration.levelDoorAnimationTypes[animType or "Default"]]
    
    for _, part in ipairs(door:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent == door then
            part.CanCollide = false
        end
    end
    
    if animFunction then
        spawn(function()
            animFunction(door)
        end)
    end
end

local function checkDoorProximity()
    if not doorSystemActive then return end
    
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local rootPart = Character.HumanoidRootPart
    local playerPos = rootPart.Position
    local velocity = rootPart.AssemblyLinearVelocity.Magnitude / 7.5
    local detectionRadius = 6 + velocity
    
    for _, door in pairs(CollectionService:GetTagged("LEVELDOOR")) do
        if not door:GetAttribute("locked") and not processedDoors[door] then
            local doorPos = door:GetPivot().Position
            local distance = (playerPos - doorPos).Magnitude
            
            if distance <= detectionRadius then
                processedDoors[door] = true
                
                local animType = door:GetAttribute("AnimType") or "Default"
                playDoorAnimation(door, animType)
                
                spawn(function()
                    wait(3)
                    processedDoors[door] = nil
                end)
            end
        end
    end
end

local function blockActivationPackets()
    pcall(function()
        local gameCore = game.ReplicatedFirst:WaitForChild("GameCore", 5)
        local shared = gameCore:WaitForChild("Shared", 5)
        local byteNetPackets = shared:WaitForChild("ByteNetPackets", 5)
        local packets = require(byteNetPackets)
        
        if packets and packets.packets and packets.packets.activateDoor then
            packets.packets.activateDoor.send = function() end
        end
    end)
end

local function toggleNoclip(enabled)
    noclipEnabled = enabled
    
    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local character = Player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        local character = Player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function sFLY(vfly)
    pcall(function()
        local plr = Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
            humanoid = char:FindFirstChildOfClass("Humanoid")
        end

        if flyKeyDown or flyKeyUp then
            flyKeyDown:Disconnect()
            flyKeyUp:Disconnect()
        end

        local T = getRoot(char)
        local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        local SPEED = 0

        local function FLY()
            FLYING = true
            local BG = Instance.new('BodyGyro')
            local BV = Instance.new('BodyVelocity')
            BG.P = 9e4
            BG.Parent = T
            BV.Parent = T
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = T.CFrame
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            task.spawn(function()
                repeat task.wait()
                    local camera = workspace.CurrentCamera
                    if not vfly and humanoid then
                        humanoid.PlatformStand = true
                    end

                    if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                        SPEED = iyflyspeed * 50
                    elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                        SPEED = 0
                    end
                    if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                        BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                        lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                    elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                        BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                    else
                        BV.Velocity = Vector3.new(0, 0, 0)
                    end
                    BG.CFrame = camera.CFrame
                until not FLYING
                CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                SPEED = 0
                BG:Destroy()
                BV:Destroy()

                if humanoid then humanoid.PlatformStand = false end
            end)
        end

        flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then
                CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
            elseif input.KeyCode == Enum.KeyCode.S then
                CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
            elseif input.KeyCode == Enum.KeyCode.A then
                CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
            elseif input.KeyCode == Enum.KeyCode.D then
                CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
            elseif input.KeyCode == Enum.KeyCode.E and QEfly then
                CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
            elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
                CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
            end
            pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
        end)

        flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then
                CONTROL.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then
                CONTROL.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then
                CONTROL.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then
                CONTROL.R = 0
            elseif input.KeyCode == Enum.KeyCode.E then
                CONTROL.Q = 0
            elseif input.KeyCode == Enum.KeyCode.Q then
                CONTROL.E = 0
            end
        end)
        FLY()
    end)
end

local function NOFLY()
    pcall(function()
        FLYING = false
        if flyKeyDown or flyKeyUp then 
            flyKeyDown:Disconnect() 
            flyKeyUp:Disconnect() 
        end
        if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
            Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
        end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
    end)
end

local function CleanupMemory()
    pcall(function()
        if #targetCache > 100 then
            local toRemove = #targetCache - 50
            for i = 1, toRemove do
                table.remove(targetCache, 1)
            end
        end
        
        if doorCacheTime + 10 < tick() then
            doorCache = {}
            doorCacheTime = tick()
        end
        
        collectgarbage("step", 100)
    end)
end

local function IsMobAlive(entity)
    if not entity or not entity.Parent then
        return false
    end
    
    local head = entity:FindFirstChild("Head")
    if not head then return false end
    
    local entityHealth = head:FindFirstChild("EntityHealth")
    if not entityHealth then return false end
    
    local healthBar = entityHealth:FindFirstChild("HealthBar")
    if not healthBar then return false end
    
    local bar = healthBar:FindFirstChild("Bar")
    if not bar then return false end
    
    if bar:IsA("Frame") and bar.Size.X.Scale <= 0.01 then
        return false
    end
    
    if bar:IsA("Frame") and bar.BackgroundColor3 == Color3.fromRGB(255, 0, 0) and bar.Size.X.Scale <= 0.1 then
        return false
    end
    
    return true
end

local function GetAllDoors()
    local currentTime = tick()
    if currentTime - doorCacheTime < CACHE_DURATION and #doorCache > 0 then
        return doorCache
    end
    
    doorCache = {}
    
    local function addDoorPosition(doorObj, doorName)
        local doorPosition = nil
        
        if doorObj:IsA("BasePart") then
            doorPosition = doorObj.Position
        elseif doorObj:IsA("Model") then
            local primaryPart = doorObj.PrimaryPart
            if primaryPart then
                doorPosition = primaryPart.Position
            else
                local doorPart = doorObj:FindFirstChild("Door") or 
                                doorObj:FindFirstChild("Handle") or
                                doorObj:FindFirstChild("Part") or
                                doorObj:FindFirstChild("Main")
                
                if doorPart and doorPart:IsA("BasePart") then
                    doorPosition = doorPart.Position
                else
                    for _, child in pairs(doorObj:GetChildren()) do
                        if child:IsA("BasePart") then
                            doorPosition = child.Position
                            break
                        end
                    end
                end
            end
        end
        
        if doorPosition then
            table.insert(doorCache, {
                name = doorName,
                position = doorPosition,
                object = doorObj
            })
        end
    end
    
    local schoolFolder = workspace:FindFirstChild("School")
    if schoolFolder then
        local doorsFolder = schoolFolder:FindFirstChild("Doors")
        if doorsFolder then
            for _, doorObj in pairs(doorsFolder:GetChildren()) do
                if string.find(doorObj.Name:lower(), "door") then
                    addDoorPosition(doorObj, doorObj.Name)
                end
            end
        end
    end
    
    doorCacheTime = currentTime
    return doorCache
end

local function IsNearDoor(position, doors)
    for _, door in pairs(doors) do
        local distance = (position - door.position).Magnitude
        if distance <= DoorAvoidanceDistance then
            return true, door.name, distance
        end
    end
    return false, nil, nil
end

local function GetBestMobTarget()
    local Character = Player.Character
    if not Character then return nil end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return nil end
    
    local entitiesFolder = workspace:FindFirstChild("Entities")
    if not entitiesFolder then return nil end
    
    local entityCount = 0
    local aliveCount = 0
    local safeTargets = {}
    local doorTargets = {}
    local playerPos = HumanoidRootPart.Position
    local doors = GetAllDoors()
    
    local targetParts = TargetHead and {"Head", "Torso", "HumanoidRootPart"} or {"Left Leg", "Right Leg", "Torso", "HumanoidRootPart"}
    
    for _, entity in pairs(entitiesFolder:GetChildren()) do
        if entity.Name ~= "Entities" and entity ~= Character then
            entityCount = entityCount + 1
            
            if not IsMobAlive(entity) then
                continue
            end
            
            aliveCount = aliveCount + 1
            
            for _, partName in ipairs(targetParts) do
                local targetPart = entity:FindFirstChild(partName)
                if targetPart and targetPart:IsA("BasePart") then
                    local distance = (targetPart.Position - playerPos).Magnitude
                    
                    if distance <= CONFIG.MaxTeleportDistance then
                        local targetPos = targetPart.Position
                        
                        if not isValidPosition(targetPos) then
                            continue
                        end
                        
                        local target = {
                            part = targetPart,
                            entity = entity,
                            distance = distance,
                            partName = partName,
                            position = targetPos
                        }
                        
                        local isNearDoor, doorName, doorDistance = IsNearDoor(targetPos, doors)
                        
                        if isNearDoor then
                            target.nearDoor = true
                            target.doorName = doorName
                            target.doorDistance = doorDistance
                            table.insert(doorTargets, target)
                        else
                            table.insert(safeTargets, target)
                        end
                    end
                    break
                end
            end
        end
    end
    
    table.sort(safeTargets, function(a, b) return a.distance < b.distance end)
    table.sort(doorTargets, function(a, b) return a.distance < b.distance end)
    
    local bestTarget = nil
    
    if #safeTargets > 0 then
        bestTarget = safeTargets[1]
    elseif #doorTargets > 0 then
        bestTarget = doorTargets[1]
    else
        return nil
    end
    
    TeleportStats.lastTarget = bestTarget.entity.Name
    return bestTarget.position
end

local function TeleportToMob()
    local Character = Player.Character
    if not Character then return end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    
    local targetPosition = GetBestMobTarget()
    if not targetPosition then return end
    
    local finalPosition = targetPosition + Vector3.new(0, HeightOffset, 0)
    
    if not isValidPosition(finalPosition) then
        return
    end
    
    local currentPos = HumanoidRootPart.Position
    local distance = (currentPos - finalPosition).Magnitude
    
    if distance > CONFIG.MaxTeleportDistance * 2 then
        return
    end
    
    HumanoidRootPart.CFrame = CFrame.new(finalPosition)
    
    TeleportStats.totalTeleports = TeleportStats.totalTeleports + 1
    
    CleanupMemory()
end

TeleportSection:AddToggle("AutoTeleport", {
    Title = "Téléport automatique",
    Default = false,
    Callback = function(Value)
        pcall(function()
            TeleportActive = Value
            
            if TeleportActive then
                teleportConnection = RunService.Heartbeat:Connect(function()
                    TeleportToMob()
                end)
            else
                if teleportConnection then
                    teleportConnection:Disconnect()
                    teleportConnection = nil
                end
            end
        end)
    end
})

TeleportSection:AddToggle("TargetPart", {
    Title = "Tête cible (OFF = Jambes)",
    Default = true,
    Callback = function(Value)
        pcall(function()
            TargetHead = Value
        end)
    end
})

TeleportSection:AddSlider("HeightOffset", {
    Title = "Hauteur au-dessus de BOT",
    Min = CONFIG.MinHeightOffset,
    Max = CONFIG.MaxHeightOffset,
    Default = CONFIG.DefaultHeightOffset,
    Rounding = 1,
    Callback = function(Value)
        pcall(function()
            HeightOffset = Value
        end)
    end
})

TeleportSection:AddDropdown("DoorAvoidance", {
    Title = "Distance d'évitement des portes",
    Values = {"5", "10", "15", "25", "50"},
    Multi = false,
    Default = "15",
    Callback = function(Value)
        pcall(function()
            DoorAvoidanceDistance = tonumber(Value)
            doorCache = {}
            doorCacheTime = 0
        end)
    end
})

TeleportSection:AddButton({
    Title = "Rafraîchir les cibles",
    Callback = function()
        pcall(function()
            doorCache = {}
            targetCache = {}
            doorCacheTime = 0
            targetCacheTime = 0
            GetBestMobTarget()
        end)
    end
})

MovementSection:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        pcall(function()
            toggleNoclip(Value)
        end)
    end
})

MovementSection:AddToggle("Fly", {
    Title = "Vol (WASD + Q/E)",
    Default = false,
    Callback = function(Value)
        pcall(function()
            if Value then
                NOFLY()
                wait()
                sFLY()
            else
                NOFLY()
            end
        end)
    end
})

MovementSection:AddSlider("FlySpeed", {
    Title = "Vitesse de vol",
    Min = 1,
    Max = 10,
    Default = 1,
    Rounding = 1,
    Callback = function(Value)
        pcall(function()
            iyflyspeed = Value
        end)
    end
})

CombatSection:AddToggle("Skill1Spam", {
    Title = "Compétence 1 Spam",
    Default = false,
    Callback = function(Value)
        pcall(function()
            Skill1Toggle = Value
        end)
    end
})

CombatSection:AddToggle("Skill2Spam", {
    Title = "Compétence 2 Spam",
    Default = false,
    Callback = function(Value)
        pcall(function()
            Skill2Toggle = Value
        end)
    end
})

CombatSection:AddToggle("Skill3Spam", {
    Title = "Compétence 3 pourriel",
    Default = false,
    Callback = function(Value)
        pcall(function()
            Skill3Toggle = Value
        end)
    end
})

CombatSection:AddToggle("BufferSpam", {
    Title = "Attaque automatique",
    Default = false,
    Callback = function(Value)
        pcall(function()
            BufferSpamActive = Value
        end)
    end
})

CombatSection:AddToggle("AutoSpin", {
    Title = "Tourner automatiquement",
    Default = false,
    Callback = function(Value)
        pcall(function()
            AutoSpinActive = Value
        end)
    end
})

if doorSystemActive and not doorSystemConnection then
    doorSystemConnection = RunService.Heartbeat:Connect(checkDoorProximity)
end

Player.CharacterAdded:Connect(function(newCharacter)
    pcall(function()
        wait(1)
        GetBestMobTarget()
    end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    pcall(function()
        if input.KeyCode == Enum.KeyCode.T then
            TeleportToMob()
        end
    end)
end)

task.spawn(function()
    while true do
        pcall(function()
            CleanupMemory()
        end)
        task.wait(5)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if Skill1Toggle then
                pcall(function()
                    ByteNetReliable:FireServer(SkillBuffers[1], {tick()})
                end)
            end
            if Skill2Toggle then
                pcall(function()
                    ByteNetReliable:FireServer(SkillBuffers[2], {tick()})
                end)
            end
            if Skill3Toggle then
                pcall(function()
                    ByteNetReliable:FireServer(SkillBuffers[3], {tick()})
                end)
            end
        end)
        task.wait(SpamRate)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if BufferSpamActive then
                pcall(function()
                    local dynamicNumber = tick()
                    ByteNetReliable:FireServer(bufferData, {dynamicNumber})
                end)
                task.wait(SpamRate)
            else
                task.wait(0.1)
            end
        end)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if AutoSpinActive then
                pcall(function()
                    local args = {
                        [1] = 1,
                        [3] = true,
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packets", 9e9):WaitForChild("WeaponSpin", 9e9):InvokeServer(unpack(args))
                end)
                task.wait(1)
            else
                task.wait(0.1)
            end
        end)
    end
end)

pcall(function()
    blockActivationPackets()
end)

task.wait(1)
pcall(function()
    GetBestMobTarget()
end)