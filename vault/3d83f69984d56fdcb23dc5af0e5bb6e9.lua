-- Script_1755678018908
-- Script ID: 3d83f69984d56fdcb23dc5af0e5bb6e9
-- Migrated: 2025-09-11T12:58:20.423Z
-- Auto-migrated from encrypted storage to GitHub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local connections = {}
local objects = {}

local physicsWalkEnabled = false
local physicsWalkSpeed = 80
local grappleEnabled = false
local grappleHook = nil
local grappleConnection = nil
local godModeEnabled = false
local godConnection = nil
local antiRagdollEnabled = false
local antiRagdollConnections = {}
local antiRagdollOn = true
local antiRagdoll = true
local antiKnockback = true
local lastPosition = nil
local lastCFrame = nil

local physicsWalkBtn, godModeBtn, jobIdBtn, antiRagdollBtn

local function cleanupConnections()
    for _, connection in pairs(connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(connections)
end

local function cleanupObjects()
    for _, obj in pairs(objects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    table.clear(objects)
    
    if godConnection then 
        godConnection:Disconnect()
        godConnection = nil 
    end
    
    if grappleConnection then
        grappleConnection:Disconnect()
        grappleConnection = nil
    end
end

local function getCharacterComponents()
    local char = player.Character
    if not char then return nil, nil, nil end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    
    return char, humanoid, rootPart
end

local physicsWalkBV
local lastMovePosition = nil
local stuckTimer = 0
local STUCK_THRESHOLD = 0.5
local STUCK_DISTANCE = 0.5

local function resetPhysicsWalk()
    if physicsWalkBV then
        physicsWalkBV:Destroy()
        physicsWalkBV = nil
    end
    local char, humanoid, rootPart = getCharacterComponents()
    if char and humanoid and rootPart then
        physicsWalkBV = Instance.new("BodyVelocity")
        physicsWalkBV.MaxForce = Vector3.new(1e5, 0, 1e5)
        physicsWalkBV.Velocity = Vector3.new()
        physicsWalkBV.P = 1250
        physicsWalkBV.Parent = rootPart
        table.insert(objects, physicsWalkBV)
    end
end

local function applyPhysicsWalk()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        local hrp = char.HumanoidRootPart
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local moveDir = humanoid.MoveDirection
        
        if moveDir.Magnitude > 0 then
            if not physicsWalkBV or not physicsWalkBV.Parent then
                physicsWalkBV = Instance.new("BodyVelocity")
                physicsWalkBV.MaxForce = Vector3.new(1e5, 0, 1e5)
                physicsWalkBV.Velocity = Vector3.new()
                physicsWalkBV.P = 1250
                physicsWalkBV.Parent = hrp
                table.insert(objects, physicsWalkBV)
            end
            physicsWalkBV.Velocity = moveDir * physicsWalkSpeed
            
            if lastMovePosition then
                local distanceMoved = (hrp.Position - lastMovePosition).Magnitude
                if distanceMoved < STUCK_DISTANCE then
                    stuckTimer = stuckTimer + RunService.RenderStepped:Wait()
                    if stuckTimer >= STUCK_THRESHOLD then
                        resetPhysicsWalk()
                        stuckTimer = 0
                    end
                else
                    stuckTimer = 0
                end
            end
            lastMovePosition = hrp.Position
        else
            if physicsWalkBV then
                physicsWalkBV.Velocity = Vector3.new(0, 0, 0)
            end
            lastMovePosition = nil
            stuckTimer = 0
        end
    end
end

local function enableGodMode()
    local char, humanoid, rootPart = getCharacterComponents()
    if not char or not humanoid then return end
    
    if godModeEnabled then
        godConnection = humanoid.HealthChanged:Connect(function(health)
            if health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        
        local damageConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        
        table.insert(connections, damageConnection)
        
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local ff = Instance.new("ForceField")
                ff.Visible = false
                ff.Parent = part
                table.insert(objects, ff)
            end
        end
    else
        if godConnection then godConnection:Disconnect(); godConnection = nil end
        
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local ff = part:FindFirstChild("ForceField")
                if ff then ff:Destroy() end
            end
        end
    end
end

local function findGrappleHook()
    local backpack = player.Backpack
    local character = player.Character
    
    local hook = backpack:FindFirstChild("Grapple Hook")
    if hook then return hook end
    
    if character then
        hook = character:FindFirstChild("Grapple Hook")
        if hook then return hook end
    end
    
    return nil
end

local function autoEquipGrapple()
    if not grappleEnabled then return end
    
    local hook = findGrappleHook()
    if hook and hook.Parent == player.Backpack then
        local character, humanoid = getCharacterComponents()
        if humanoid then
            humanoid:EquipTool(hook)
            grappleHook = hook
        end
    end
end

local function autoLoop()
    if grappleConnection then
        grappleConnection:Disconnect()
        grappleConnection = nil
    end
    
    spawn(function()
        while grappleEnabled do
            local args = {[1] = 2}
            
            pcall(function()
                local net = ReplicatedStorage:WaitForChild("Packages", 1):WaitForChild("Net", 1):WaitForChild("RE/UseItem", 1)
                net:FireServer(unpack(args))
            end)
            
            wait(1)
        end
    end)
end

local function copyJobIdToClipboard()
    local jobId = game.JobId
    local placeId = game.PlaceId
    
    if jobId == "" then
        if setclipboard then
            setclipboard("-- Job ID not available in Studio mode")
        elseif toclipboard then
            toclipboard("-- Job ID not available in Studio mode")
        end
        return
    end
    
    local teleportScript = string.format([[game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")]], placeId, jobId)
    
    if setclipboard then
        setclipboard(teleportScript)
    elseif toclipboard then
        toclipboard(teleportScript)
    end
end

-- Auto copy on script execution
spawn(function()
    wait(2)
    copyJobIdToClipboard()
end)

local function dotool(tool)
    if tool:IsA("Tool") then
        -- Tool handling for anti-ragdoll
    elseif tool:IsA("BasePart") then
        table.insert(antiRagdollConnections, tool:GetPropertyChangedSignal("Anchored"):Connect(function()
            if tool.Anchored and antiRagdoll then
                tool.Anchored = false
            end
        end))
        
        table.insert(antiRagdollConnections, tool.ChildAdded:Connect(function(c)
            if c and (c:IsA("BallSocketConstraint") or c.Name == "Attachment" or c:IsA("HingeConstraint")) and c and c.Parent then
                if antiRagdoll then
                    c:Destroy()
                    local char, humanoid = getCharacterComponents()
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        humanoid.PlatformStand = false
                        workspace.CurrentCamera.CameraSubject = humanoid
                    end
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CanCollide = true
                    end
                    if tool:FindFirstChildWhichIsA("Motor6D") then
                        tool:FindFirstChildWhichIsA("Motor6D").Enabled = true
                    end
                    pcall(function()
                        require(player.PlayerScripts.PlayerModule.ControlModule):Enable()
                    end)
                    for i = 1, 10 do
                        task.wait()
                        tool.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end))
    elseif tool:IsA("Humanoid") then
        table.insert(antiRagdollConnections, tool.StateChanged:Connect(function()
            if antiRagdoll and (tool:GetState() == Enum.HumanoidStateType.Physics or tool:GetState() == Enum.HumanoidStateType.Ragdoll) then
                tool:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end))
    end
end

local function dochar(c)
    table.insert(antiRagdollConnections, c.ChildAdded:Connect(function(v)
        dotool(v)
    end))
    for i, v in pairs(c:GetChildren()) do
        dotool(v)
    end
end

local function enableAntiRagdoll()
    if antiRagdollEnabled then
        table.insert(antiRagdollConnections, player.CharacterAdded:Connect(dochar))
        if player.Character then
            dochar(player.Character)
        end
        
        coroutine.wrap(function()
            while antiRagdollOn do
                local s, e = pcall(function()
                    local char, humanoid, rootPart = getCharacterComponents()
                    if char and rootPart then
                        local currentCFrame = rootPart.CFrame
                        local currentPosition = rootPart.Position
                        
                        if antiKnockback and lastPosition then
                            local positionDifference = (currentPosition - lastPosition).Magnitude
                            local velocityMagnitude = rootPart.Velocity.Magnitude
                            
                            if positionDifference > 5 and velocityMagnitude > 20 then
                                rootPart.CFrame = lastCFrame
                                rootPart.Velocity = Vector3.new(0, 0, 0)
                                rootPart.RotVelocity = Vector3.new(0, 0, 0)
                            else
                                lastPosition = currentPosition
                                lastCFrame = currentCFrame
                            end
                        else
                            lastPosition = currentPosition
                            lastCFrame = currentCFrame
                        end
                        
                        if antiRagdoll then
                            if rootPart.Velocity.Magnitude > 50 then
                                rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
                            end
                            
                            if humanoid then
                                if humanoid:GetState() == Enum.HumanoidStateType.Physics or 
                                   humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                                end
                                humanoid.PlatformStand = false
                            end
                            
                            rootPart.CanCollide = true
                            if rootPart.Anchored then
                                rootPart.Anchored = false
                            end
                        end
                    end
                    
                    task.wait()
                end)
            end
        end)()
    else
        antiRagdollOn = false
        for _, v in pairs(antiRagdollConnections) do
            v:Disconnect()
        end
        table.clear(antiRagdollConnections)
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateSpeedHackGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
table.insert(objects, screenGui)

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 280)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 100, 100)
frameStroke.Thickness = 1
frameStroke.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -70, 1, 0)
titleText.Position = UDim2.new(0, 8, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "COMBO_WICK V1"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 4)
closeBtnCorner.Parent = closeBtn

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -60, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 80)
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar

local minimizeBtnCorner = Instance.new("UICorner")
minimizeBtnCorner.CornerRadius = UDim.new(0, 4)
minimizeBtnCorner.Parent = minimizeBtn

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 240)
scrollFrame.Parent = frame

local function createButton(name, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -15, 0, 30)
    btn.Position = UDim2.new(0, 8, 0, posY)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(100, 100, 100)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    return btn
end

local function createInputBox(placeholder, posY, defaultText)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, -15, 0, 25)
    tb.Position = UDim2.new(0, 8, 0, posY)
    tb.PlaceholderText = placeholder
    tb.Text = defaultText
    tb.TextColor3 = Color3.fromRGB(255,255,255)
    tb.BackgroundColor3 = Color3.fromRGB(50,50,50)
    tb.BorderSizePixel = 0
    tb.ClearTextOnFocus = false
    tb.Font = Enum.Font.Gotham
    tb.TextScaled = true
    tb.Parent = scrollFrame
    
    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 5)
    tbCorner.Parent = tb
    
    return tb
end

local function createLabel(text, posY)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -15, 0, 20)
    label.Position = UDim2.new(0, 8, 0, posY)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = scrollFrame
    return label
end

createLabel("=== MOVEMENT ===", 5)
physicsWalkBtn = createButton("Speed: OFF", 30)
godModeBtn = createButton("God Mode: OFF", 65)
antiRagdollBtn = createButton("Anti Ragdoll: OFF", 100)
createLabel("=== SPEED VALUES ===", 135)
local physicsWalkInput = createInputBox("Speed", 160, tostring(physicsWalkSpeed))
jobIdBtn = createButton("📋 COPY JOB ID", 190)
jobIdBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)

local function disableOtherMovementFeatures(exclude)
    if exclude ~= "physicsWalk" then
        physicsWalkEnabled = false
        physicsWalkBtn.Text = "Speed: OFF"
        physicsWalkBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        if physicsWalkBV then
            physicsWalkBV:Destroy()
            physicsWalkBV = nil
        end
    end
    if not physicsWalkEnabled then
        grappleEnabled = false
        if grappleConnection then
            grappleConnection:Disconnect()
            grappleConnection = nil
        end
    end
end

connections.physicsWalkBtn = physicsWalkBtn.MouseButton1Click:Connect(function()
    physicsWalkEnabled = not physicsWalkEnabled
    physicsWalkBtn.Text = physicsWalkEnabled and "Speed: ON" or "Speed: OFF"
    physicsWalkBtn.BackgroundColor3 = physicsWalkEnabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(70, 70, 70)
    physicsWalkSpeed = tonumber(physicsWalkInput.Text) or 50
    
    if physicsWalkEnabled then
        disableOtherMovementFeatures("physicsWalk")
        grappleEnabled = true
        autoLoop()
    else
        grappleEnabled = false
        if grappleConnection then
            grappleConnection:Disconnect()
            grappleConnection = nil
        end
        if physicsWalkBV then
            physicsWalkBV:Destroy()
            physicsWalkBV = nil
        end
    end
end)

connections.godModeBtn = godModeBtn.MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    godModeBtn.Text = godModeEnabled and "God Mode: ON" or "God Mode: OFF"
    godModeBtn.BackgroundColor3 = godModeEnabled and Color3.fromRGB(200, 100, 200) or Color3.fromRGB(70, 70, 70)
    enableGodMode()
end)

connections.antiRagdollBtn = antiRagdollBtn.MouseButton1Click:Connect(function()
    antiRagdollEnabled = not antiRagdollEnabled
    antiRagdollBtn.Text = antiRagdollEnabled and "Anti Ragdoll: ON" or "Anti Ragdoll: OFF"
    antiRagdollBtn.BackgroundColor3 = antiRagdollEnabled and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(70, 70, 70)
    antiRagdollOn = antiRagdollEnabled
    enableAntiRagdoll()
end)

connections.jobIdBtn = jobIdBtn.MouseButton1Click:Connect(function()
    copyJobIdToClipboard()
    
    local originalColor = jobIdBtn.BackgroundColor3
    local originalText = jobIdBtn.Text
    
    jobIdBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    jobIdBtn.Text = "✅ COPIED!"
    
    wait(1)
    
    jobIdBtn.BackgroundColor3 = originalColor
    jobIdBtn.Text = originalText
end)

local minimized = false
connections.closeBtn = closeBtn.MouseButton1Click:Connect(function()
    cleanupConnections()
    cleanupObjects()
    antiRagdollOn = false
    for _, v in pairs(antiRagdollConnections) do
        v:Disconnect()
    end
    table.clear(antiRagdollConnections)
end)

connections.minimizeBtn = minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    scrollFrame.Visible = not minimized
    frame.Size = minimized and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 280)
    minimizeBtn.Text = minimized and "□" or "_"
end)

connections.renderStepped = RunService.RenderStepped:Connect(function(dt)
    if physicsWalkEnabled then applyPhysicsWalk() end
    if grappleEnabled then 
        autoEquipGrapple()
    end
end)

connections.characterAdded = player.CharacterAdded:Connect(function(char)
    wait(2)
    
    physicsWalkBV = nil
    lastMovePosition = nil
    stuckTimer = 0
    
    if godModeEnabled then enableGodMode() end
    if grappleEnabled then 
        grappleHook = findGrappleHook()
        autoLoop()
    end
    if antiRagdollEnabled then enableAntiRagdoll() end
end)

connections.physicsWalkInput = physicsWalkInput.FocusLost:Connect(function() 
    local newValue = tonumber(physicsWalkInput.Text)
    if newValue and newValue > 0 and newValue <= 500 then
        physicsWalkSpeed = newValue
    else
        physicsWalkInput.Text = tostring(physicsWalkSpeed)
    end
end)

connections.playerRemoving = Players.PlayerRemoving:Connect(function(p)
    if p == player then
        antiRagdollOn = false
        for _, v in pairs(antiRagdollConnections) do
            v:Disconnect()
        end
        table.clear(antiRagdollConnections)
    end
end)