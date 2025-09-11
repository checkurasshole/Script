-- Protected Script (Spanish)
-- Script ID: ef59ea4f2cefdd98b4071b3663482646
-- Migrated: 2025-09-11T13:21:33.356Z
-- Auto-migrated from encrypted storage to GitHub

-- Deep Hook Speed Coil Script with GUI
-- Purchases and hooks into speed methods
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local TARGET_SPEED = 72
local hookActive = false
local speedConnection = nil

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedCoilGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 0
title.Text = "Gancho de bobina de velocidad"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Inactive"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = mainFrame

-- Speed display
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 70)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 72"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.SourceSans
speedLabel.Parent = mainFrame

-- Speed input
local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0, 60, 0, 25)
speedInput.Position = UDim2.new(0, 230, 0, 70)
speedInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
speedInput.BorderSizePixel = 0
speedInput.Text = "72"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextScaled = true
speedInput.Font = Enum.Font.SourceSans
speedInput.Parent = mainFrame

-- Toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Activar el gancho de velocidad"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = mainFrame

-- Info label
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 30)
infoLabel.Position = UDim2.new(0, 10, 0, 150)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Conmutar las manijas comprar + equipar automáticamente"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.SourceSans
infoLabel.Parent = mainFrame

-- Function to check if Speed Coil is in inventory
local function hasSpeedCoil()
    return (player.Backpack:FindFirstChild("Speed Coil") or 
            (player.Character and player.Character:FindFirstChild("Speed Coil")))
end

-- Function to equip Speed Coil
local function equipSpeedCoil()
    local speedCoil = player.Backpack:FindFirstChild("Speed Coil")
    if speedCoil and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:EquipTool(speedCoil)
        print("Speed Coil equipped")
        return true
    end
    return false
end

-- Function to purchase Speed Coil
local function purchaseSpeedCoil()
    local args = {
        [1] = "Speed Coil"
    }
    
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Packages", 9e9):WaitForChild("Net", 9e9):WaitForChild("RF/CoinsShopService/RequestBuy", 9e9):InvokeServer(unpack(args))
    end)
    
    if success then
        print("Speed Coil purchased successfully")
        return true
    else
        warn("Failed to purchase Speed Coil: " .. tostring(result))
        return false
    end
end

-- Function to hook humanoid speed
local function hookHumanoidSpeed(humanoid)
    if not humanoid then return end
    
    -- Continuous speed enforcement
    if speedConnection then
        speedConnection:Disconnect()
    end
    
    speedConnection = RunService.Heartbeat:Connect(function()
        if hookActive and humanoid.WalkSpeed ~= TARGET_SPEED then
            humanoid.WalkSpeed = TARGET_SPEED
        end
    end)
    
    -- Property changed hook
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hookActive and humanoid.WalkSpeed ~= TARGET_SPEED then
            humanoid.WalkSpeed = TARGET_SPEED
        end
    end)
end

-- Function to activate speed hook
local function activateSpeedHook()
    -- Check if we have Speed Coil, if not buy it
    if not hasSpeedCoil() then
        print("Speed Coil not found, purchasing...")
        if not purchaseSpeedCoil() then
            warn("Failed to purchase Speed Coil")
            return false
        end
        wait(1) -- Wait for purchase to process
    end
    
    -- Equip Speed Coil
    if not equipSpeedCoil() then
        wait(0.5) -- Small delay and retry
        if not equipSpeedCoil() then
            warn("Failed to equip Speed Coil")
            return false
        end
    end
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        hookActive = true
        player.Character.Humanoid.WalkSpeed = TARGET_SPEED
        hookHumanoidSpeed(player.Character.Humanoid)
        
        statusLabel.Text = "Status: Active"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        toggleButton.Text = "Desactivar el gancho de velocidad"
        print("Speed hook activated - Speed set to " .. TARGET_SPEED)
        return true
    end
    return false
end

-- Function to deactivate speed hook
local function deactivateSpeedHook()
    hookActive = false
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    -- Unequip Speed Coil
    if player.Character and player.Character:FindFirstChild("Speed Coil") then
        player.Character.Humanoid:UnequipTools()
    end
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
    
    statusLabel.Text = "Status: Inactive"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleButton.Text = "Activar el gancho de velocidad"
    print("Speed hook deactivated")
end

-- Toggle button functionality
toggleButton.MouseButton1Click:Connect(function()
    if not hookActive then
        activateSpeedHook()
    else
        deactivateSpeedHook()
    end
end)

-- Buy button functionality (removed)

-- Speed input functionality
speedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed then
        TARGET_SPEED = newSpeed
        speedLabel.Text = "Speed: " .. TARGET_SPEED
        
        -- Update speed if hook is active
        if hookActive and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = TARGET_SPEED
        end
    else
        speedInput.Text = tostring(TARGET_SPEED)
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function()
    wait(2)
    if hookActive then
        -- Re-equip Speed Coil if hook was active
        if hasSpeedCoil() then
            equipSpeedCoil()
        else
            -- Re-purchase and equip if not in inventory
            if purchaseSpeedCoil() then
                wait(1)
                equipSpeedCoil()
            end
        end
        
        hookHumanoidSpeed(player.Character:WaitForChild("Humanoid"))
        player.Character.Humanoid.WalkSpeed = TARGET_SPEED
    end
end)

-- Make GUI draggable
local dragging = false
local dragStart = nil
local startPos = nil

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

title.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("Speed Coil GUI loaded - Click toggle to purchase and activate")