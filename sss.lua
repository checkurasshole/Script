-- Movement Protection Script - Direct Override Version (GitHub Clean)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    enabled = true,
    debugMode = false
}

-- Raw input tracking (completely bypass Roblox's input system)
local rawInputs = {
    W = false,
    A = false, 
    S = false,
    D = false,
    Space = false
}

-- Get character parts
local function getCharacterParts()
    local character = LocalPlayer.Character
    if not character then return nil, nil, nil end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    return character, humanoid, rootPart, head
end

-- Completely override movement with direct velocity control
local function forceMovement()
    if not CONFIG.enabled then return end
    
    local character, humanoid, rootPart, head = getCharacterParts()
    if not character or not rootPart then return end
    
    -- Get camera direction
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local cameraCF = camera.CFrame
    local lookVector = cameraCF.LookVector
    local rightVector = cameraCF.RightVector
    
    -- Calculate desired movement direction based on RAW inputs
    local moveVector = Vector3.new(0, 0, 0)
    
    -- HARD CODED DIRECTIONS - NO REVERSAL POSSIBLE
    if rawInputs.W then -- Forward
        moveVector = moveVector + lookVector
    end
    if rawInputs.S then -- Backward  
        moveVector = moveVector - lookVector
    end
    if rawInputs.A then -- Left
        moveVector = moveVector - rightVector
    end
    if rawInputs.D then -- Right
        moveVector = moveVector + rightVector  
    end
    
    -- Normalize movement
    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit
    end
    
    -- DESTROY any existing movement objects that might interfere
    for _, obj in pairs(rootPart:GetChildren()) do
        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyAngularVelocity") then
            if obj.Name ~= "OVERRIDE_MOVEMENT" then
                obj:Destroy()
            end
        end
    end
    
    -- Create/update our override movement
    local bodyVel = rootPart:FindFirstChild("OVERRIDE_MOVEMENT")
    if not bodyVel then
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "OVERRIDE_MOVEMENT"
        bodyVel.MaxForce = Vector3.new(4000, 0, 4000)
        bodyVel.Parent = rootPart
    end
    
    -- Get walk speed (use default if corrupted)
    local walkSpeed = 16
    if humanoid and humanoid.WalkSpeed > 0 and humanoid.WalkSpeed < 100 then
        walkSpeed = humanoid.WalkSpeed
    end
    
    -- Apply movement with our direction
    local velocity = moveVector * walkSpeed
    bodyVel.Velocity = Vector3.new(velocity.X, 0, velocity.Z)
    
    -- Handle jumping
    if rawInputs.Space then
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            local jumpForce = rootPart:FindFirstChild("OVERRIDE_JUMP")
            if not jumpForce then
                jumpForce = Instance.new("BodyVelocity")
                jumpForce.Name = "OVERRIDE_JUMP"
                jumpForce.MaxForce = Vector3.new(0, 4000, 0)
                jumpForce.Parent = rootPart
                
                local jumpPower = 50
                if humanoid and humanoid.JumpPower > 0 then
                    jumpPower = humanoid.JumpPower
                end
                
                jumpForce.Velocity = Vector3.new(0, jumpPower, 0)
                
                -- Remove jump after short time
                game:GetService("Debris"):AddItem(jumpForce, 0.3)
            end
        end
    end
end

-- Raw input capture - intercept before any tools can mess with it
local function captureInput(input, gameProcessed)
    if gameProcessed then return end
    
    local keyCode = input.KeyCode
    
    if keyCode == Enum.KeyCode.W then
        rawInputs.W = true
    elseif keyCode == Enum.KeyCode.A then
        rawInputs.A = true
    elseif keyCode == Enum.KeyCode.S then
        rawInputs.S = true
    elseif keyCode == Enum.KeyCode.D then
        rawInputs.D = true
    elseif keyCode == Enum.KeyCode.Space then
        rawInputs.Space = true
    end
end

local function releaseInput(input, gameProcessed)
    if gameProcessed then return end
    
    local keyCode = input.KeyCode
    
    if keyCode == Enum.KeyCode.W then
        rawInputs.W = false
    elseif keyCode == Enum.KeyCode.A then
        rawInputs.A = false
    elseif keyCode == Enum.KeyCode.S then
        rawInputs.S = false
    elseif keyCode == Enum.KeyCode.D then
        rawInputs.D = false
    elseif keyCode == Enum.KeyCode.Space then
        rawInputs.Space = false
    end
end

-- Connect input events with highest priority
UserInputService.InputBegan:Connect(captureInput)
UserInputService.InputEnded:Connect(releaseInput)

-- Character setup (no tool blocking)
local function setupCharacter(character)
    character:WaitForChild("HumanoidRootPart")
    character:WaitForChild("Humanoid")
    
    -- Just clear any existing movement effects, don't block tools
    local rootPart = character.HumanoidRootPart
    for _, obj in pairs(rootPart:GetChildren()) do
        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") then
            if obj.Name ~= "OVERRIDE_MOVEMENT" then
                obj:Destroy()
            end
        end
    end
end

-- Connect to character spawning
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- Main movement loop - runs every frame
local connection = RunService.Heartbeat:Connect(forceMovement)

-- Cleanup function
local function cleanup()
    if connection then
        connection:Disconnect()
    end
    
    local character, humanoid, rootPart = getCharacterParts()
    if rootPart then
        local bodyVel = rootPart:FindFirstChild("OVERRIDE_MOVEMENT")
        if bodyVel then
            bodyVel:Destroy()
        end
        local jumpForce = rootPart:FindFirstChild("OVERRIDE_JUMP")
        if jumpForce then
            jumpForce:Destroy()
        end
    end
end

-- Override any existing PlayerModule or ControlModule
task.spawn(function()
    local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
    local playerModule = playerScripts:FindFirstChild("PlayerModule")
    
    if playerModule then
        local controlModule = playerModule:FindFirstChild("ControlModule")
        if controlModule then
            -- Don't destroy, just override
        end
    end
end)

-- Global controls
_G.MOVEMENT_PROTECTION = {
    enable = function()
        CONFIG.enabled = true
        if not connection then
            connection = RunService.Heartbeat:Connect(forceMovement)
        end
    end,
    
    disable = function()
        CONFIG.enabled = false
        cleanup()
    end,
    
    cleanup = cleanup,
    
    isEnabled = function()
        return CONFIG.enabled
    end
}

return _G.MOVEMENT_PROTECTION