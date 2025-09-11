-- Protected Script (Portuguese)
-- Script ID: 2aa0851468c4314320b52158d2cb1b3e
-- Migrated: 2025-09-11T12:58:40.049Z
-- Auto-migrated from encrypted storage to GitHub

loadstring(game:HttpGet("__URL_6115ae2cb0f5ab5d__"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Fluent = loadstring(game:HttpGet("__URL_5575e0ae0c909aa9__"))()

local Window = Fluent:CreateWindow({
    Title = "COMBO_WICK",
    SubTitle = "Desfrute!",
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

local DefaultJoints = {
    ["Neck"] = { CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["LeftShoulder"] = { CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0) },
    ["RightShoulder"] = { CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0), CFrame.new(-0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
    ["LeftHip"] = { CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0) },
    ["RightHip"] = { CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0), CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
    ["Root"] = { CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["Waist"] = { CFrame.new(0, 0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, -0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["LeftShoulder"] = { CFrame.new(-0.15, 0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0.15, 0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["LeftElbow"] = { CFrame.new(0, -0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["LeftWrist"] = { CFrame.new(0, -0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["RightShoulder"] = { CFrame.new(0.15, 0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(-0.15, 0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["RightElbow"] = { CFrame.new(0, -0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["RightWrist"] = { CFrame.new(0, -0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0.2, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["LeftHip"] = { CFrame.new(-0.1, -0.15, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0.1, 0.15, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["LeftKnee"] = { CFrame.new(0, -0.3, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0.3, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["LeftAnkle"] = { CFrame.new(0, -0.15, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0.15, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["RightHip"] = { CFrame.new(0.1, -0.15, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(-0.1, 0.15, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["RightKnee"] = { CFrame.new(0, -0.3, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0.3, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) },
    ["RightAnkle"] = { CFrame.new(0, -0.15, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0.15, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) }
}

local AntiRagdoll = {}
local ragdollConnections = {}
local originalJoints = {}

function AntiRagdoll.RestoreJoint(joint)
    if not joint or not joint.Parent then return end
    
    local jointName = joint.Name
    local jointData = DefaultJoints[jointName]
    
    if jointData and joint:IsA("Motor6D") then
        joint.C0 = jointData[1]
        joint.C1 = jointData[2]
        joint.Enabled = true
        
        if joint.Part0 and joint.Part1 then
            joint.Part0.Anchored = false
            joint.Part1.Anchored = false
            joint.Part0.CanCollide = false
            joint.Part1.CanCollide = false
        end
    end
end

function AntiRagdoll.RestoreCharacter(character)
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
        
        if humanoid.Health <= 0 then
            humanoid.Health = humanoid.MaxHealth
        end
    end
    
    for _, joint in pairs(character:GetDescendants()) do
        if joint:IsA("Motor6D") then
            AntiRagdoll.RestoreJoint(joint)
        end
    end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Anchored = false
            part.CanCollide = false
            
            for _, constraint in pairs(part:GetChildren()) do
                if constraint:IsA("BallSocketConstraint") or 
                   constraint:IsA("HingeConstraint") or 
                   constraint:IsA("RodConstraint") or
                   constraint:IsA("UniversalConstraint") then
                    constraint:Destroy()
                end
            end
        end
    end
end

function AntiRagdoll.MonitorCharacter(character)
    if not character then return end
    
    for _, joint in pairs(character:GetDescendants()) do
        if joint:IsA("Motor6D") then
            originalJoints[joint] = {
                C0 = joint.C0,
                C1 = joint.C1,
                Enabled = joint.Enabled
            }
        end
    end
    
    local function checkRagdoll()
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and (humanoid.PlatformStand or humanoid:GetState() == Enum.HumanoidStateType.Physics) then
            AntiRagdoll.RestoreCharacter(character)
        end
        
        for _, joint in pairs(character:GetDescendants()) do
            if joint:IsA("Motor6D") and originalJoints[joint] then
                if not joint.Enabled or joint.Parent == nil then
                    AntiRagdoll.RestoreJoint(joint)
                end
            end
        end
    end
    
    ragdollConnections[#ragdollConnections + 1] = RunService.Heartbeat:Connect(checkRagdoll)
    
    ragdollConnections[#ragdollConnections + 1] = character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Motor6D") then
            originalJoints[descendant] = {
                C0 = descendant.C0,
                C1 = descendant.C1,
                Enabled = descendant.Enabled
            }
        end
    end)
    
    ragdollConnections[#ragdollConnections + 1] = character.DescendantRemoving:Connect(function(descendant)
        if descendant:IsA("Motor6D") then
            task.wait()
            AntiRagdoll.RestoreCharacter(character)
        end
    end)
end

function AntiRagdoll.Start()
    local function onCharacterAdded(character)
        character:WaitForChild("Humanoid")
        character:WaitForChild("HumanoidRootPart")
        
        task.wait(1)
        
        AntiRagdoll.MonitorCharacter(character)
    end
    
    if Player.Character then
        onCharacterAdded(Player.Character)
    end
    
    Player.CharacterAdded:Connect(onCharacterAdded)
end

AntiRagdoll.Start()

local Tab = Window:AddTab({
    Title = "Principal",
    Icon = "home"
})

Tab:AddParagraph({
    Title = "Status do Modo Deus O Modo Deus é ativado automaticamente ao carregar o script",
    Content = "Funciona melhor no modo Single Player"
})

local codes = {
    "200KLIKES",
    "Hugecode",
    "WDEV1",
    "WDEV2"
}

task.spawn(function()
    for _, code in ipairs(codes) do
        task.spawn(function()
            local args = {code}
            game:GetService("ReplicatedStorage").Packets.RedeemCode:InvokeServer(unpack(args))
        end)
        task.wait(0.5)
    end
end)

local TeleportSection = Tab:AddSection("Teleport Controls")
local CombatSection = Tab:AddSection("Combat Controls")
local MovementSection = Tab:AddSection("Movement Controls")
local ObjectiveSection = Tab:AddSection("Objective Automation")

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

local TeleportActive = false
local HeightOffset = CONFIG.DefaultHeightOffset
local teleportConnection
local TargetHead = true
local TeleportStats = {
    totalTeleports = 0,
    lastTarget = "None"
}
local DoorAvoidanceDistance = 15

local ObjectiveAutomationActive = false
local AutoTeleportWasEnabled = false
local AutoTeleportToggle

local Skill1Toggle, Skill2Toggle, Skill3Toggle, UltimateToggle, InfPerkActive = false, false, false, false, false
local AllSkillsToggle = false
local BufferSpamActive = false
local AutoSpinActive = false
local SpamRate = 0.05

local ByteNetReliable = ReplicatedStorage:WaitForChild("ByteNetReliable")

local SkillBuffers = {
    buffer.fromstring("\7\3\1"),
    buffer.fromstring("\7\5\1"),
    buffer.fromstring("\7\6\1"),
    buffer.fromstring("\7\7\1")
}
local bufferData = buffer.fromstring("\7\4\1")
local infPerkBuffer = buffer.fromstring("\11")

local doorCache = {}
local doorCacheTime = 0
local targetCache = {}
local targetCacheTime = 0
local CACHE_DURATION = 2

local function updateCharacterReferences()
    Character = Player.Character or Player.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end

local function teleportTo(target)
    if not target then return end
    
    local targetPosition
    if target:IsA("BasePart") then
        targetPosition = target.CFrame
    elseif target:IsA("Model") then
        local primaryPart = target.PrimaryPart
        if not primaryPart then
            for _, child in pairs(target:GetChildren()) do
                if child:IsA("BasePart") then
                    primaryPart = child
                    break
                end
            end
        end
        if primaryPart then
            targetPosition = primaryPart.CFrame
        end
    end
    
    if targetPosition then
        HumanoidRootPart.CFrame = targetPosition
    end
end

local function activatePrompt(prompt, targetObject, maxRetries)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    
    maxRetries = maxRetries or 10
    local attempts = 0
    local wasTriggered = false
    
    local connection
    connection = prompt.Triggered:Connect(function()
        wasTriggered = true
        print("SUCCESS! Proximity prompt was triggered!")
        
        if ObjectiveAutomationActive and AutoTeleportWasEnabled and AutoTeleportToggle then
            print("Re-enabling Auto Teleport...")
            AutoTeleportToggle:SetValue(true)
        end
        
        if connection then connection:Disconnect() end
    end)
    
    local function attemptActivation()
        attempts = attempts + 1
        print("ATTEMPTING ACTIVATION #" .. attempts .. " for " .. (targetObject.Name or "Unknown"))
        
        teleportTo(targetObject)
        task.wait(0.3)
        
        prompt.HoldDuration = 0
        prompt.Enabled = true
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 1000
        
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.1)
            prompt:InputHoldEnd()
        end)
        
        task.wait(0.2)
        
        pcall(function()
            fireproximityprompt(prompt)
        end)
        
        task.wait(0.2)
        
        pcall(function()
            for _, triggerConnection in pairs(getconnections(prompt.Triggered)) do
                triggerConnection:Fire()
            end
        end)
        
        task.wait(0.2)
        
        pcall(function()
            prompt.TriggerEnded:Fire()
        end)
        
        task.wait(1)
        
        if not wasTriggered and attempts < maxRetries then
            print("ATTEMPT #" .. attempts .. " FAILED! Retrying in 1 second...")
            task.wait(1)
            attemptActivation()
        elseif not wasTriggered then
            print("CRITICAL: Proximity prompt FAILED after " .. maxRetries .. " attempts!")
            
            if ObjectiveAutomationActive and AutoTeleportWasEnabled and AutoTeleportToggle then
                print("Re-enabling Auto Teleport after failed attempts...")
                AutoTeleportToggle:SetValue(true)
            end
            
            if connection then connection:Disconnect() end
        else
            print("Proximity prompt SUCCESS after " .. attempts .. " attempts!")
        end
    end
    
    attemptActivation()
end

local function setupGlobalListener(parent)
    parent.DescendantAdded:Connect(function(descendant)
        task.wait(0.1)
        
        if descendant.Name == "jarst_radio" then
            print("Found jarst_radio!")
            
            if TeleportActive and AutoTeleportToggle then
                print("Disabling Auto Teleport for jarst_radio objective...")
                AutoTeleportWasEnabled = true
                AutoTeleportToggle:SetValue(false)
            end
            
            print("Waiting 5 seconds for character to fully load...")
            task.wait(5)
            
            updateCharacterReferences()
            
            print("First teleport to radio...")
            teleportTo(descendant)
            task.wait(0.5)
            
            print("Second teleport to radio...")
            teleportTo(descendant)
            task.wait(0.5)
            
            local prompt = descendant:FindFirstChildOfClass("ProximityPrompt")
            if not prompt then
                for _, child in pairs(descendant:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        prompt = child
                        break
                    end
                end
            end
            
            if prompt then
                activatePrompt(prompt, descendant)
            else
                print("No proximity prompt found in jarst_radio")
            end
            
        elseif descendant.Name == "RadioObjective" then
            print("Found RadioObjective!")
            
            if TeleportActive and AutoTeleportToggle then
                print("Disabling Auto Teleport for RadioObjective...")
                AutoTeleportWasEnabled = true
                AutoTeleportToggle:SetValue(false)
            end
            
            print("Waiting 5 seconds for character to fully load...")
            task.wait(5)
            
            updateCharacterReferences()
            
            print("First teleport to RadioObjective...")
            teleportTo(descendant)
            task.wait(0.5)
            
            print("Second teleport to RadioObjective...")
            teleportTo(descendant)
            task.wait(0.5)
            
            local prompt = descendant:FindFirstChild("ProximityPrompt")
            if not prompt then
                for _, child in pairs(descendant:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        prompt = child
                        break
                    end
                end
            end
            
            if prompt then
                activatePrompt(prompt, descendant)
            else
                print("No proximity prompt found in RadioObjective")
            end
            
        elseif descendant.Name == "generator" then
            print("Found generator!")
            
            if TeleportActive and AutoTeleportToggle then
                print("Disabling Auto Teleport for generator objective...")
                AutoTeleportWasEnabled = true
                AutoTeleportToggle:SetValue(false)
            end
            
            print("Waiting 5 seconds for character to fully load...")
            task.wait(5)
            
            updateCharacterReferences()
            
            print("First teleport to generator...")
            teleportTo(descendant)
            task.wait(0.5)
            
            print("Second teleport to generator...")
            teleportTo(descendant)
            task.wait(0.5)

            print("Third teleport to generator...")
            teleportTo(descendant)
            task.wait(0.5)
            
            local prompt = descendant:FindFirstChildOfClass("ProximityPrompt")
            if not prompt then
                for _, child in pairs(descendant:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        prompt = child
                        break
                    end
                end
            end
            
            if prompt then
                activatePrompt(prompt, descendant)
            else
                print("No proximity prompt found in generator")
            end
            
        elseif descendant.Name == "HeliWall" then
            print("Found HeliWall! Setting up removal listener...")
            descendant.AncestryChanged:Connect(function()
                if not descendant.Parent then
                    print("HeliWall removed! Looking for HeliObjective...")
                    task.wait(0.5)
                    
                    local heliObj = nil
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == "HeliObjective" then
                            heliObj = obj
                            break
                        end
                    end
                    
                    if heliObj then
                        print("Found HeliObjective! Teleporting...")
                        teleportTo(heliObj)
                        task.wait(0.2)
                        
                        local heliPrompt = heliObj:FindFirstChild("ProximityPrompt")
                        if not heliPrompt then
                            for _, child in pairs(heliObj:GetDescendants()) do
                                if child:IsA("ProximityPrompt") then
                                    heliPrompt = child
                                    break
                                end
                            end
                        end
                        
                        if heliPrompt then
                            activatePrompt(heliPrompt, heliObj, 15)
                        else
                            print("No proximity prompt found in HeliObjective")
                            local clickDetector = heliObj:FindFirstChildOfClass("ClickDetector")
                            if clickDetector then
                                pcall(function()
                                    fireclickdetector(clickDetector)
                                end)
                            end
                        end
                    else
                        print("HeliObjective not found after HeliWall removal")
                    end
                end
            end)
        end
    end)
end

local function checkExisting()
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant.Name == "jarst_radio" then
            print("Found existing jarst_radio!")
            
            if TeleportActive and AutoTeleportToggle then
                print("Disabling Auto Teleport for existing jarst_radio objective...")
                AutoTeleportWasEnabled = true
                AutoTeleportToggle:SetValue(false)
            end
            
            print("Waiting 5 seconds for character to fully load...")
            task.wait(5)
            
            updateCharacterReferences()
            
            print("First teleport to existing radio...")
            teleportTo(descendant)
            task.wait(0.5)
            
            print("Second teleport to existing radio...")
            teleportTo(descendant)
            task.wait(0.5)
            
            local prompt = descendant:FindFirstChildOfClass("ProximityPrompt")
            if not prompt then
                for _, child in pairs(descendant:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        prompt = child
                        break
                    end
                end
            end
            
            if prompt then
                activatePrompt(prompt, descendant)
            end
            
        elseif descendant.Name == "RadioObjective" then
            print("Found existing RadioObjective!")
            
            if TeleportActive and AutoTeleportToggle then
                print("Disabling Auto Teleport for existing RadioObjective...")
                AutoTeleportWasEnabled = true
                AutoTeleportToggle:SetValue(false)
            end
            
            print("Waiting 5 seconds for character to fully load...")
            task.wait(5)
            
            updateCharacterReferences()
            
            print("First teleport to existing RadioObjective...")
            teleportTo(descendant)
            task.wait(0.5)
            
            print("Second teleport to existing RadioObjective...")
            teleportTo(descendant)
            task.wait(0.5)
            
            local prompt = descendant:FindFirstChild("ProximityPrompt")
            if not prompt then
                for _, child in pairs(descendant:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        prompt = child
                        break
                    end
                end
            end
            
            if prompt then
                activatePrompt(prompt, descendant)
            end
            
        elseif descendant.Name == "generator" then
            print("Found existing generator!")
            
            if TeleportActive and AutoTeleportToggle then
                print("Disabling Auto Teleport for existing generator objective...")
                AutoTeleportWasEnabled = true
                AutoTeleportToggle:SetValue(false)
            end
            
            print("Waiting 5 seconds for character to fully load...")
            task.wait(5)
            
            updateCharacterReferences()
            
            print("First teleport to existing generator...")
            teleportTo(descendant)
            task.wait(0.5)
            
            print("Second teleport to existing generator...")
            teleportTo(descendant)
            task.wait(0.5)

            print("Third teleport to existing generator...")
            teleportTo(descendant)
            task.wait(0.5)
            
            local prompt = descendant:FindFirstChildOfClass("ProximityPrompt")
            if not prompt then
                for _, child in pairs(descendant:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        prompt = child
                        break
                    end
                end
            end
            
            if prompt then
                activatePrompt(prompt, descendant)
            end
            
        elseif descendant.Name == "HeliWall" then
            print("Found existing HeliWall! Setting up removal listener...")
            descendant.AncestryChanged:Connect(function()
                if not descendant.Parent then
                    print("HeliWall removed!")
                    task.wait(0.5)
                    
                    local heliObj = nil
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == "HeliObjective" then
                            heliObj = obj
                            break
                        end
                    end
                    
                    if heliObj then
                        teleportTo(heliObj)
                        task.wait(0.2)
                        
                        local heliPrompt = heliObj:FindFirstChild("ProximityPrompt")
                        if not heliPrompt then
                            for _, child in pairs(heliObj:GetDescendants()) do
                                if child:IsA("ProximityPrompt") then
                                    heliPrompt = child
                                    break
                                end
                            end
                        end
                        
                        if heliPrompt then
                            activatePrompt(heliPrompt, heliObj, 5)
                        end
                    end
                end
            end)
        end
    end
end

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

local function setupInfiniteJump()
    local function enableInfiniteJump()
        local character = Player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        local connection
        connection = UserInputService.JumpRequest:Connect(function()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        
        character.AncestryChanged:Connect(function()
            if not character.Parent then
                connection:Disconnect()
            end
        end)
    end
    
    if Player.Character then
        enableInfiniteJump()
    end
    
    Player.CharacterAdded:Connect(enableInfiniteJump)
end

setupInfiniteJump()

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

ObjectiveSection:AddToggle("ObjectiveAutomation", {
    Title = "Conclusão Automática de Objetivos",
    Default = false,
    Callback = function(Value)
        ObjectiveAutomationActive = Value
        
        if Value then
            AutoTeleportWasEnabled = TeleportActive
            
            if TeleportActive and AutoTeleportToggle then
                print("Disabling Auto Teleport for objective automation...")
                AutoTeleportToggle:SetValue(false)
            end
            
            print("Setting up global listeners for all spawning objects...")
            setupGlobalListener(workspace)
            checkExisting()
            print("Script loaded! Monitoring for objectives...")
        else
            AutoTeleportWasEnabled = false
            print("Objective automation disabled.")
        end
    end
})

AutoTeleportToggle = TeleportSection:AddToggle("AutoTeleport", {
    Title = "Teletransporte automático",
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
    Title = "Cabeça Alvo (DESLIGADA = Pernas)",
    Default = true,
    Callback = function(Value)
        pcall(function()
            TargetHead = Value
        end)
    end
})

TeleportSection:AddSlider("HeightOffset", {
    Title = "Altura acima",
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

TeleportSection:AddButton({
    Title = "Mapear Dois Pontos Seguros",
    Callback = function()
        pcall(function()
            local Character = Player.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                Character.HumanoidRootPart.CFrame = CFrame.new(-98.7486877, 32.2496185, 0.000988006592, -1.1920929e-07, 0, -1.00000012, 0, -1.00000024, -0, -1.00000012, 0, -1.1920929e-07)
            end
        end)
    end
})

CombatSection:AddToggle("AllSkills", {
    Title = "Todas as Competências",
    Default = false,
    Callback = function(Value)
        pcall(function()
            AllSkillsToggle = Value
            Skill1Toggle = Value
            Skill2Toggle = Value
            Skill3Toggle = Value
            UltimateToggle = Value
        end)
    end
})

CombatSection:AddToggle("BufferSpam", {
    Title = "Ataque automático",
    Default = false,
    Callback = function(Value)
        pcall(function()
            BufferSpamActive = Value
        end)
    end
})

CombatSection:AddToggle("AutoSpin", {
    Title = "Jogada Arma Automática",
    Default = false,
    Callback = function(Value)
        pcall(function()
            AutoSpinActive = Value
        end)
    end
})

CombatSection:AddToggle("InfPerk", {
    Title = "Vantagem Infinita",
    Default = false,
    Callback = function(Value)
        pcall(function()
            InfPerkActive = Value
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

if doorSystemActive and not doorSystemConnection then
    doorSystemConnection = RunService.Heartbeat:Connect(checkDoorProximity)
end

Player.CharacterAdded:Connect(function(newCharacter)
    pcall(function()
        Character = newCharacter
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
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
            if UltimateToggle then
                pcall(function()
                    ByteNetReliable:FireServer(SkillBuffers[4], {0})
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

task.spawn(function()
    while true do
        pcall(function()
            if InfPerkActive then
                pcall(function()
                    ByteNetReliable:FireServer(infPerkBuffer)
                end)
                task.wait(5)
            else
                task.wait(1)
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
