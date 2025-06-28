-- Movement Protection Script - Direct Override Version (Clean)
-- Upload this file to GitHub as "movement.lua"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
    enabled = true,
    debugMode = false
}

-- Raw input tracking
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

-- Force movement override
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
    
    -- Calculate movement direction
    local moveVector = Vector3.new(0, 0, 0)
    
    if rawInputs.W then
        moveVector = moveVector + lookVector
    end
    if rawInputs.S then
        moveVector = moveVector - lookVector
    end
    if rawInputs.A then
        moveVector = moveVector - rightVector
    end
    if rawInputs.D then
        moveVector = moveVector + rightVector
    end
    
    -- Normalize movement
    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit
    end
    
    -- Destroy interfering objects
    for _, obj in pairs(rootPart:GetChildren()) do
        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyAngularVelocity") then
            if obj.Name ~= "OVERRIDE_MOVEMENT" then
                obj:Destroy()
            end
        end
    end
    
    -- Create/update movement
    local bodyVel = rootPart:FindFirstChild("OVERRIDE_MOVEMENT")
    if not bodyVel then
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "OVERRIDE_MOVEMENT"
        bodyVel.MaxForce = Vector3.new(4000, 0, 4000)
        bodyVel.Parent = rootPart
    end
    
    -- Apply movement
    local walkSpeed = 16
    if humanoid and humanoid.WalkSpeed > 0 and humanoid.WalkSpeed < 100 then
        walkSpeed = humanoid.WalkSpeed
    end
    
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
                game:GetService("Debris"):AddItem(jumpForce, 0.3)
            end
        end
    end
end

-- Input capture
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

-- Connect events
UserInputService.InputBegan:Connect(captureInput)
UserInputService.InputEnded:Connect(releaseInput)

-- Character setup
local function setupCharacter(character)
    character:WaitForChild("HumanoidRootPart")
    character:WaitForChild("Humanoid")
    
    local rootPart = character.HumanoidRootPart
    for _, obj in pairs(rootPart:GetChildren()) do
        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") then
            if obj.Name ~= "OVERRIDE_MOVEMENT" then
                obj:Destroy()
            end
        end
    end
end

-- Connect to characters
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- Main loop
local connection = RunService.Heartbeat:Connect(forceMovement)

-- Cleanup function
local function cleanup()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    local character, humanoid, rootPart = getCharacterParts()
    if rootPart then
        local bodyVel = rootPart:FindFirstChild("OVERRIDE_MOVEMENT")
        if bodyVel then
            bodyVel:Destroy()
        end
        local jumpVel = rootPart:FindFirstChild("OVERRIDE_JUMP")
        if jumpVel then
            jumpVel:Destroy()
        end
    end
    
    -- Reset input states
    rawInputs.W = false
    rawInputs.A = false
    rawInputs.S = false
    rawInputs.D = false
    rawInputs.Space = false
end

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