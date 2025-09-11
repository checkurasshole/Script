-- Script_1754579661110
-- Script ID: 44f80bc4200bccb009cb28f4f20ed4fe
-- Migrated: 2025-09-11T12:58:16.142Z
-- Auto-migrated from encrypted storage to GitHub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Rayfield = loadstring(game:HttpGet('__URL_f6f7b6d592d5333e__'))()

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local folder = workspace:WaitForChild("Humanoids")

-- Anti-void variables
local OrgDestroyHeight = workspace.FallenPartsDestroyHeight
local antivoidloop = nil
local antivoidWasEnabled = false

-- Swim variables
local swimming = false
local oldgrav = workspace.Gravity
local swimbeat = nil
local gravReset = nil
local noclipConnection = nil
local isSwimmingToDestination = false
local swimDestination = Vector3.new(0, 0, 0)
local swimSpeed = 100
local processedPrompts = {}
local amberCollectionEnabled = false
local currentAmberTarget = nil
local isCollecting = false
local amberCollectionCoroutine = nil

local espEnabled = false
local highlightEnabled = false
local teleporting = false
local npcTeleportEnabled = false
local currentTarget = nil
local currentNPCTarget = nil
local playerIndex = 1
local targetMovingPlayers = true
local targetStillPlayers = true
local behindDistance = 5
local npcBehindDistance = 5
local walkspeedEnabled = false
local customWalkspeed = 16
local HumanModCons = {}
local activeESPElements = {}
local activeHighlights = {}
local npcTeleportConnection = nil
local Connections = {} -- Store all connections for cleanup

-- Anti-void functions
local function getRoot(character)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function enableAntiVoid()
    if antivoidloop then
        antivoidloop:Disconnect()
        antivoidloop = nil
    end
    antivoidloop = RunService.Stepped:Connect(function()
        local root = getRoot(localPlayer.Character)
        if root and root.Position.Y <= OrgDestroyHeight + 25 then
            root.Velocity = root.Velocity + Vector3.new(0, 250, 0)
        end
    end)
    Connections.antivoid = antivoidloop
end

local function disableAntiVoid()
    if antivoidloop then
        antivoidloop:Disconnect()
        antivoidloop = nil
        Connections.antivoid = nil
    end
end

local function fakeOut()
    local root = getRoot(localPlayer.Character)
    if not root then return end
    
    local oldpos = root.CFrame
    if antivoidloop then
        disableAntiVoid()
        antivoidWasEnabled = true
    end
    workspace.FallenPartsDestroyHeight = math.huge
    root.CFrame = CFrame.new(Vector3.new(0, OrgDestroyHeight - 25, 0))
    task.wait(1)
    root.CFrame = oldpos
    workspace.FallenPartsDestroyHeight = OrgDestroyHeight
    if antivoidWasEnabled then
        enableAntiVoid()
        antivoidWasEnabled = false
    end
end

-- Swim functions
local function noclip()
    local character = localPlayer.Character
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

local function enableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    noclipConnection = RunService.Stepped:Connect(noclip)
    Connections.noclip = noclipConnection
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
        Connections.noclip = nil
    end
    local character = localPlayer.Character
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = true
        end
    end
end

local function startSwim()
    if not swimming and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
        oldgrav = workspace.Gravity
        workspace.Gravity = 0
        local swimDied = function()
            workspace.Gravity = oldgrav
            swimming = false
            disableNoclip()
            Connections.swimDied = nil
        end
        local Humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        gravReset = Humanoid.Died:Connect(swimDied)
        Connections.swimDied = gravReset
        local enums = Enum.HumanoidStateType:GetEnumItems()
        table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
        for i, v in pairs(enums) do
            Humanoid:SetStateEnabled(v, false)
        end
        Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        swimbeat = RunService.Heartbeat:Connect(function()
            pcall(function()
                local hrp = localPlayer.Character.HumanoidRootPart
                local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                if isSwimmingToDestination then
                    local currentPos = hrp.Position
                    local direction = (swimDestination - currentPos).Unit
                    local distance = (swimDestination - currentPos).Magnitude
                    if distance < 5 then
                        isSwimmingToDestination = false
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    else
                        hrp.Velocity = direction * swimSpeed
                    end
                else
                    local moveVector = humanoid.MoveDirection
                    local camera = workspace.CurrentCamera
                    local cameraCFrame = camera.CFrame
                    local worldMoveVector = Vector3.new(0, 0, 0)
                    if moveVector.Magnitude > 0 then
                        local cameraRight = cameraCFrame.RightVector
                        local cameraForward = -cameraCFrame.LookVector
                        cameraRight = Vector3.new(cameraRight.X, 0, cameraRight.Z).Unit
                        cameraForward = Vector3.new(cameraForward.X, 0, cameraForward.Z).Unit
                        worldMoveVector = (cameraRight * moveVector.X + cameraForward * moveVector.Z)
                    end
                    local verticalMovement = 0
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        verticalMovement = 1
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        verticalMovement = -1
                    end
                    local finalMoveVector = Vector3.new(worldMoveVector.X, verticalMovement, worldMoveVector.Z)
                    if finalMoveVector.Magnitude > 0 then
                        hrp.Velocity = finalMoveVector.Unit * swimSpeed
                    else
                        hrp.Velocity = hrp.Velocity * 0.9
                    end
                end
            end)
        end)
        Connections.swimbeat = swimbeat
        enableNoclip()
        swimming = true
        return true
    end
    return false
end

local function stopSwim()
    if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
        workspace.Gravity = oldgrav
        swimming = false
        isSwimmingToDestination = false
        if gravReset then
            gravReset:Disconnect()
            gravReset = nil
            Connections.swimDied = nil
        end
        if swimbeat then
            swimbeat:Disconnect()
            swimbeat = nil
            Connections.swimbeat = nil
        end
        disableNoclip()
        local Humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        local enums = Enum.HumanoidStateType:GetEnumItems()
        table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
        for i, v in pairs(enums) do
            Humanoid:SetStateEnabled(v, true)
        end
    end
end

local function swimToDestination(targetPosition)
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local hrp = character.HumanoidRootPart
    local currentPos = hrp.Position
    local skyPosition = Vector3.new(currentPos.X, currentPos.Y + 100, currentPos.Z)
    hrp.CFrame = CFrame.new(skyPosition)
    isSwimmingToDestination = true
    swimDestination = targetPosition
    if not swimming then
        startSwim()
    end
end

local function getHumanoidRootPart(model)
    return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
end

local function isPlayerMoving(player)
    if not player or not player.Character or not player.Character:FindFirstChild("Humanoid") then
        return false
    end
    return player.Character.Humanoid.MoveDirection.Magnitude > 0.1
end

local function isPlayerDead(player)
    return not player or
           not player.Character or
           not player.Character:FindFirstChild("Humanoid") or
           player.Character.Humanoid.Health <= 0
end

local function setWalkspeed(speed)
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        local Char = localPlayer.Character
        local Human = Char:FindFirstChildWhichIsA("Humanoid")
        local function WalkSpeedChange()
            if Char and Human and walkspeedEnabled then
                Human.WalkSpeed = speed
            end
        end
        WalkSpeedChange()
        HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and nil) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
        Connections.wsLoop = HumanModCons.wsLoop
        HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and nil) or localPlayer.CharacterAdded:Connect(function(nChar)
            Char, Human = nChar, nChar:WaitForChild("Humanoid")
            character = nChar
            hrp = nChar:WaitForChild("HumanoidRootPart")
            WalkSpeedChange()
            HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and nil) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
            Connections.wsLoop = HumanModCons.wsLoop
        end)
        Connections.wsCA = HumanModCons.wsCA
    end
end

local function toggleWalkspeed(value)
    walkspeedEnabled = value
    if value then
        setWalkspeed(customWalkspeed)
    else
        if HumanModCons.wsLoop then
            HumanModCons.wsLoop:Disconnect()
            HumanModCons.wsLoop = nil
            Connections.wsLoop = nil
        end
        if HumanModCons.wsCA then
            HumanModCons.wsCA:Disconnect()
            HumanModCons.wsCA = nil
            Connections.wsCA = nil
        end
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            localPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end

local function updateWalkspeed(value)
    customWalkspeed = value
    if walkspeedEnabled then
        setWalkspeed(customWalkspeed)
    end
end

local function removeESP(model)
    local billboard = model:FindFirstChild("NPC_ESP")
    if billboard then
        billboard:Destroy()
    end
    activeESPElements[model] = nil
end

local function removeHighlight(model)
    local highlight = model:FindFirstChild("NPC_Highlight")
    if highlight then
        highlight:Destroy()
    end
    activeHighlights[model] = nil
end

local function applyESP(model)
    if not model:IsA("Model") or not model:FindFirstChild("Humanoid") or not string.find(model.Name, "Goat") then return end
    if model:FindFirstChild("NPC_ESP") then return end
    local humanoid = model:FindFirstChild("Humanoid")
    local root = getHumanoidRootPart(model)
    if not root then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NPC_ESP"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 80, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = model.Name
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard
    billboard.Parent = root
    activeESPElements[model] = billboard
    local connection
    connection = humanoid.Died:Connect(function()
        billboard:Destroy()
        activeESPElements[model] = nil
        if connection then
            Connections["ESP_" .. tostring(model)] = nil
            connection:Disconnect()
        end
    end)
    Connections["ESP_" .. tostring(model)] = connection
end

local function applyHighlight(model)
    if not model:IsA("Model") or not model:FindFirstChild("Humanoid") or not string.find(model.Name, "Goat") then return end
    if model:FindFirstChild("NPC_Highlight") then return end
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "NPC_Highlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(100, 150, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model
    activeHighlights[model] = highlight
    local connection
    connection = humanoid.Died:Connect(function()
        highlight:Destroy()
        activeHighlights[model] = nil
        if connection then
            Connections["Highlight_" .. tostring(model)] = nil
            connection:Disconnect()
        end
    end)
    Connections["Highlight_" .. tostring(model)] = connection
end

local function toggleESP(value)
    espEnabled = value
    if value then
        for _, model in pairs(folder:GetChildren()) do
            applyESP(model)
        end
    else
        for model, billboard in pairs(activeESPElements) do
            if billboard and billboard.Parent then
                billboard:Destroy()
            end
            if Connections["ESP_" .. tostring(model)] then
                Connections["ESP_" .. tostring(model)]:Disconnect()
                Connections["ESP_" .. tostring(model)] = nil
            end
        end
        activeESPElements = {}
        for _, model in pairs(folder:GetChildren()) do
            removeESP(model)
        end
    end
end

local function toggleHighlight(value)
    highlightEnabled = value
    if value then
        for _, model in pairs(folder:GetChildren()) do
            applyHighlight(model)
        end
    else
        for model, highlight in pairs(activeHighlights) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
            if Connections["Highlight_" .. tostring(model)] then
                Connections["Highlight_" .. tostring(model)]:Disconnect()
                Connections["Highlight_" .. tostring(model)] = nil
            end
        end
        activeHighlights = {}
        for _, model in pairs(folder:GetChildren()) do
            removeHighlight(model)
        end
    end
end

local function getValidPlayers()
    local players = Players:GetPlayers()
    local validPlayers = {}
    for _, player in pairs(players) do
        if player ~= localPlayer and 
           player.Character and 
           player.Character:FindFirstChild("HumanoidRootPart") and 
           player.Character:FindFirstChild("Humanoid") and
           player.Character.Humanoid.Health > 0 then
            local isMoving = isPlayerMoving(player)
            if (isMoving and targetMovingPlayers) or (not isMoving and targetStillPlayers) then
                table.insert(validPlayers, player)
            end
        end
    end
    return validPlayers
end

local function getNextTarget()
    local validPlayers = getValidPlayers()
    if #validPlayers == 0 then
        return nil
    end
    
    -- Cycle through players properly
    playerIndex = ((playerIndex - 1) % #validPlayers) + 1
    return validPlayers[playerIndex]
end

local function anchorToPlayer(targetPlayer)
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    local targetLookVector = targetRoot.CFrame.LookVector
    if targetHumanoid and targetHumanoid.MoveDirection.Magnitude > 0.1 then
        local moveDirection = targetHumanoid.MoveDirection
        targetLookVector = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
    end
    local behindPosition = targetRoot.Position - (targetLookVector * behindDistance)
    behindPosition = Vector3.new(behindPosition.X, targetRoot.Position.Y, behindPosition.Z)
    local newCFrame = CFrame.lookAt(behindPosition, targetRoot.Position)
    localPlayer.Character.HumanoidRootPart.CFrame = newCFrame
    localPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    localPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
    localPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    localPlayer.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    return true
end

local function teleportLoop()
    if not teleporting then return end
    if not currentTarget or isPlayerDead(currentTarget) then
        currentTarget = getNextTarget()
        if currentTarget then
            anchorToPlayer(currentTarget)
        else
            task.wait(1)
            return
        end
    end
    if localPlayer.Character and currentTarget.Character then
        local myPosition = localPlayer.Character.HumanoidRootPart.Position
        local targetPosition = currentTarget.Character.HumanoidRootPart.Position
        local targetLookVector = currentTarget.Character.HumanoidRootPart.CFrame.LookVector
        local intendedPosition = targetPosition - (targetLookVector * behindDistance)
        local distanceFromIntended = (myPosition - intendedPosition).Magnitude
        if distanceFromIntended > 2 then
            anchorToPlayer(currentTarget)
        end
    end
end

local function getClosestNPC()
    local closest = nil
    local shortestDist = math.huge
    for _, npc in pairs(folder:GetChildren()) do
        if npc:IsA("Model") and npc.Name == "Goat" and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
            local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = npc
            end
        end
    end
    return closest
end

local function anchorToNPC(targetNPC)
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local targetRoot = targetNPC:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return false
    end
    local dir = -(targetRoot.CFrame.LookVector) * npcBehindDistance
    hrp.CFrame = CFrame.new(targetRoot.Position + dir, targetRoot.Position)
    hrp.Velocity = Vector3.new(0, 0, 0)
    hrp.RotVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    return true
end

local function npcTeleportLoop()
    if not npcTeleportEnabled then return end
    if not currentNPCTarget or not currentNPCTarget:IsDescendantOf(workspace) or currentNPCTarget.Humanoid.Health <= 0 then
        currentNPCTarget = getClosestNPC()
        if not currentNPCTarget then
            return
        end
    end
    if hrp and currentNPCTarget.HumanoidRootPart then
        anchorToNPC(currentNPCTarget)
    end
end

local function toggleNPCTeleport(value)
    npcTeleportEnabled = value
    if value then
        currentNPCTarget = getClosestNPC()
        if currentNPCTarget then
            anchorToNPC(currentNPCTarget)
        end
        npcTeleportConnection = RunService.Heartbeat:Connect(function()
            npcTeleportLoop()
        end)
        Connections.npcTeleport = npcTeleportConnection
    else
        currentNPCTarget = nil
        if npcTeleportConnection then
            npcTeleportConnection:Disconnect()
            npcTeleportConnection = nil
            Connections.npcTeleport = nil
        end
    end
end

local function switchToNextNPC()
    local allNPCs = {}
    for _, npc in pairs(folder:GetChildren()) do
        if npc:IsA("Model") and npc.Name == "Goat" and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
            table.insert(allNPCs, npc)
        end
    end
    if #allNPCs == 0 then
        return nil
    elseif #allNPCs == 1 then
        return allNPCs[1]
    else
        for _, npc in pairs(allNPCs) do
            if npc ~= currentNPCTarget then
                return npc
            end
        end
        return allNPCs[1]
    end
end

local function deepSearchProximityPrompts(obj, path)
    local prompts = {}
    path = path or obj.Name
    if obj:IsA("ProximityPrompt") then
        table.insert(prompts, {prompt = obj, path = path, parent = obj.Parent})
        return prompts
    end
    for _, child in pairs(obj:GetChildren()) do
        local childPath = path .. "." .. child.Name
        local childPrompts = deepSearchProximityPrompts(child, childPath)
        for _, promptData in pairs(childPrompts) do
            table.insert(prompts, promptData)
        end
    end
    return prompts
end

local function getBestPosition(obj)
    local function findPartPosition(searchObj)
        if searchObj:IsA("BasePart") then
            return searchObj.Position
        elseif searchObj:IsA("Model") and searchObj.PrimaryPart then
            return searchObj.PrimaryPart.Position
        else
            for _, child in pairs(searchObj:GetChildren()) do
                if child:IsA("BasePart") then
                    return child.Position
                end
            end
        end
        return nil
    end
    local pos = findPartPosition(obj)
    if pos then return pos end
    local current = obj.Parent
    while current and current ~= Workspace do
        pos = findPartPosition(current)
        if pos then return pos end
        current = current.Parent
    end
    return nil
end

local function getAllAmberPrompts()
    local itemSpawn = Workspace:FindFirstChild("ItemSpawn")
    if not itemSpawn then
        return {}
    end
    local amber = itemSpawn:FindFirstChild("Amber")
    if not amber then
        return {}
    end
    local allPrompts = {}
    for _, child in pairs(amber:GetChildren()) do
        if child.Name == "AmberSpawn" then
            local prompts = deepSearchProximityPrompts(child)
            for _, promptData in pairs(prompts) do
                local promptId = tostring(promptData.prompt)
                if not processedPrompts[promptId] and promptData.prompt.Parent and promptData.prompt.Enabled then
                    table.insert(allPrompts, promptData)
                end
            end
        end
    end
    return allPrompts
end

-- FIXED AMBER COLLECTION FUNCTIONS
local function fireProximityPrompt(promptData)
    if not fireproximityprompt then
        return false
    end
    
    local prompt = promptData.prompt
    local promptId = tostring(prompt)
    
    -- Check if prompt still exists and is enabled
    if not prompt.Parent or not prompt.Enabled then
        processedPrompts[promptId] = true
        return false
    end
    
    local targetPosition = getBestPosition(prompt)
    if not targetPosition then
        processedPrompts[promptId] = true
        return false
    end
    
    -- Start swimming to the target
    if not swimming then
        startSwim()
        task.wait(0.2)
    end
    
    -- Move to the target position
    swimToDestination(targetPosition)
    
    -- Wait for arrival with timeout
    local timeoutCounter = 0
    local maxTimeout = 50 -- 5 seconds at 0.1 intervals
    
    while isSwimmingToDestination and timeoutCounter < maxTimeout do
        task.wait(0.1)
        timeoutCounter = timeoutCounter + 1
        
        -- Update hrp reference if character changed
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            hrp = localPlayer.Character.HumanoidRootPart
        end
    end
    
    -- Check if we're close enough and prompt still exists
    if hrp and prompt.Parent and prompt.Enabled then
        local distance = (hrp.Position - targetPosition).Magnitude
        
        if distance < 20 then
            -- Try multiple firing methods for better reliability
            local success = false
            
            -- Method 1: Direct fire
            pcall(function()
                fireproximityprompt(prompt, 0, true)
                success = true
            end)
            
            task.wait(0.05)
            
            -- Method 2: If still exists, try again
            if prompt.Parent and prompt.Enabled and not success then
                pcall(function()
                    fireproximityprompt(prompt)
                    success = true
                end)
            end
            
            task.wait(0.05)
            
            -- Method 3: Final attempt with different parameters
            if prompt.Parent and prompt.Enabled and not success then
                pcall(function()
                    fireproximityprompt(prompt, prompt.HoldDuration or 0)
                    success = true
                end)
            end
        end
    end
    
    -- Mark as processed regardless of success to avoid infinite loops
    processedPrompts[promptId] = true
    task.wait(0.1)
    
    return true
end

local function amberCollectionLoop()
    if not amberCollectionEnabled or isCollecting then 
        return 
    end
    
    isCollecting = true
    
    local availablePrompts = getAllAmberPrompts()
    
    if #availablePrompts > 0 then
        -- Sort by distance to collect closest ones first
        if hrp then
            table.sort(availablePrompts, function(a, b)
                local posA = getBestPosition(a.prompt)
                local posB = getBestPosition(b.prompt)
                if posA and posB then
                    local distA = (hrp.Position - posA).Magnitude
                    local distB = (hrp.Position - posB).Magnitude
                    return distA < distB
                end
                return false
            end)
        end
        
        currentAmberTarget = availablePrompts[1]
        fireProximityPrompt(currentAmberTarget)
    else
        -- Reset processed prompts when no more are available
        processedPrompts = {}
        currentAmberTarget = nil
        stopSwim()
        task.wait(1)
    end
    
    isCollecting = false
end

local function toggleAmberCollection(value)
    amberCollectionEnabled = value
    if value then
        processedPrompts = {}
        currentAmberTarget = nil
        amberCollectionCoroutine = task.spawn(function()
            while amberCollectionEnabled do
                pcall(function()
                    amberCollectionLoop()
                end)
                task.wait(0.3)
            end
        end)
    else
        amberCollectionEnabled = false
        currentAmberTarget = nil
        isCollecting = false
        stopSwim()
        if amberCollectionCoroutine then
            task.cancel(amberCollectionCoroutine)
            amberCollectionCoroutine = nil
        end
    end
end

-- Cleanup function
local function cleanup()
    -- Disconnect all stored connections
    for key, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
            Connections[key] = nil
        end
    end
    -- Stop swim and clear connections
    stopSwim()
    -- Clear walkspeed connections
    toggleWalkspeed(false)
    -- Clear NPC teleport
    toggleNPCTeleport(false)
    -- Clear amber collection
    toggleAmberCollection(false)
    -- Clear ESP and highlights
    toggleESP(false)
    toggleHighlight(false)
    -- Clear teleporting
    teleporting = false
    currentTarget = nil
    -- Disable anti-void
    disableAntiVoid()
end

-- Event Connections
Connections.childAdded = folder.ChildAdded:Connect(function(model)
    task.wait(0.2)
    if espEnabled then
        applyESP(model)
    end
    if highlightEnabled then
        applyHighlight(model)
    end
end)

Connections.charAdded = localPlayer.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    if walkspeedEnabled then
        task.wait(1)
        setWalkspeed(customWalkspeed)
    end
    if swimming then
        task.wait(1)
        startSwim()
    end
end)

Connections.charRemoving = localPlayer.CharacterRemoving:Connect(function()
    stopSwim()
end)

Connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
    if teleporting and currentTarget == player then
        currentTarget = getNextTarget()
        if currentTarget then
            anchorToPlayer(currentTarget)
        end
    end
end)

Connections.teleportLoop = RunService.Heartbeat:Connect(function()
    if teleporting and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        teleportLoop()
    end
end)

-- Rayfield GUI
local Window = Rayfield:CreateWindow({
    Name = "COMBO_WICK",
    Icon = 12345678901,
    LoadingTitle = "Divertiti!",
    LoadingSubtitle = "By COMBO_WICK",
    Theme = "Ocean",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ComboChronicle",
        FileName = "NPCConfig"
    }
})

local Tab = Window:CreateTab("Principale", nil)
local AmberTab = Window:CreateTab("Collezione Ambra", nil)
local UtilityTab = Window:CreateTab("Servizi di pubblica utilità", nil)

-- Utility Tab (Anti-Void)
UtilityTab:CreateSection("Anti-Voide")
UtilityTab:CreateToggle({
    Name = "Abilita Anti-Voide",
    CurrentValue = false,
    Flag = "AntiVoidToggle",
    Callback = function(value)
        if value then
            enableAntiVoid()
        else
            disableAntiVoid()
        end
    end
})

UtilityTab:CreateButton({
    Name = "Fake Out (Teletrasporto sot...",
    Callback = function()
        fakeOut()
    end
})

-- Main Tab
Tab:CreateSection("Walkspeed")
Tab:CreateToggle({
    Name = "Abilita velocità di camminata",
    CurrentValue = false,
    Flag = "WalkspeedToggle",
    Callback = function(value)
        toggleWalkspeed(value)
    end
})
Tab:CreateSlider({
    Name = "Valore velocità di camminata",
    Range = {1, 500},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "WalkspeedSlider",
    Callback = function(value)
        updateWalkspeed(value)
    end
})

Tab:CreateSection("Allevamento automatico di a...")
Tab:CreateToggle({
    Name = "Abilita nome ESP",
    CurrentValue = false,
    Flag = "ESPNameToggle",
    Callback = function(value)
        toggleESP(value)
    end
})
Tab:CreateToggle({
    Name = "Abilita evidenziazione ESP",
    CurrentValue = false,
    Flag = "ESPHighlightToggle",
    Callback = function(value)
        toggleHighlight(value)
    end
})
Tab:CreateToggle({
    Name = "Teletrasportati ai PNG Capra",
    CurrentValue = false,
    Flag = "NPCTeleportToggle",
    Callback = function(value)
        toggleNPCTeleport(value)
    end
})
Tab:CreateSlider({
    Name = "Distanza PNG dietro",
    Range = {1, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 5,
    Flag = "NPCBehindDistanceSlider",
    Callback = function(value)
        npcBehindDistance = value
        if npcTeleportEnabled and currentNPCTarget then
            anchorToNPC(currentNPCTarget)
        end
    end
})
Tab:CreateButton({
    Name = "Prossimo obiettivo PNG",
    Callback = function()
        if npcTeleportEnabled then
            local newTarget = switchToNextNPC()
            if newTarget then
                currentNPCTarget = newTarget
                anchorToNPC(currentNPCTarget)
            end
        end
    end
})

Tab:CreateSection("AutoFarm del giocatore")
Tab:CreateToggle({
    Name = "Teletrasporta ai giocatori",
    CurrentValue = false,
    Flag = "TeleportToggle",
    Callback = function(value)
        teleporting = value
        if teleporting then
            playerIndex = 0 -- Reset index when starting
            currentTarget = getNextTarget()
            if currentTarget then
                anchorToPlayer(currentTarget)
            end
        else
            currentTarget = nil
        end
    end
})
Tab:CreateToggle({
    Name = "Giocatori in movimento bers...",
    CurrentValue = true,
    Flag = "TargetMovingToggle",
    Callback = function(value)
        targetMovingPlayers = value
        if not targetMovingPlayers and not targetStillPlayers then
            targetStillPlayers = true
        end
    end
})
Tab:CreateToggle({
    Name = "Target giocatori fermi",
    CurrentValue = true,
    Flag = "TargetStillToggle",
    Callback = function(value)
        targetStillPlayers = value
        if not targetMovingPlayers and not targetStillPlayers then
            targetMovingPlayers = true
        end
    end
})
Tab:CreateSlider({
    Name = "Distanza dietro il nemico",
    Range = {1, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 5,
    Flag = "BehindDistanceSlider",
    Callback = function(value)
        behindDistance = value
        if teleporting and currentTarget then
            anchorToPlayer(currentTarget)
        end
    end
})
Tab:CreateButton({
    Name = "Il prossimo obiettivo.",
    Callback = function()
        if teleporting then
            local validPlayers = getValidPlayers()
            if #validPlayers > 0 then
                currentTarget = getNextTarget()
                if currentTarget then
                    anchorToPlayer(currentTarget)
                end
            end
        end
    end
})

AmberTab:CreateSection("Amber AutoFarm")
AmberTab:CreateToggle({
    Name = "Abilita Collezione Ambra",
    CurrentValue = false,
    Flag = "AmberCollectionToggle",
    Callback = function(value)
        toggleAmberCollection(value)
    end
})

-- Cleanup on script end
game:BindToClose(cleanup)

Rayfield:LoadConfiguration()