-- Advanced Glow ESP System with Invisible Player Detection
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Global ESP Configuration
_G.ESP_CONFIG = _G.ESP_CONFIG or {
    enabled = true,
    showNames = true,
    showInvisible = true,
    glowColor = Color3.fromRGB(0, 255, 0), -- Green for visible players
    invisibleColor = Color3.fromRGB(255, 0, 255), -- Magenta for invisible players
    nameColor = Color3.fromRGB(255, 255, 255),
    invisibleNameColor = Color3.fromRGB(255, 100, 255),
    nameSize = 14,
    invisiblePrefix = "[INVIS] ",
    showDistance = true,
    maxDistance = 1000 -- Max distance to show ESP
}

local ESP_CONFIG = _G.ESP_CONFIG
local trackedPlayers = {}
local invisiblePlayers = {}

-- Function to check if a player is invisible
local function isPlayerInvisible(character)
    if not character then return false end
    
    -- Method 1: Check transparency of body parts
    local bodyParts = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    local invisibleParts = 0
    local totalParts = 0
    
    for _, partName in pairs(bodyParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            totalParts = totalParts + 1
            if part.Transparency >= 0.9 then
                invisibleParts = invisibleParts + 1
            end
        end
    end
    
    -- If most body parts are transparent, player is likely invisible
    if totalParts > 0 and invisibleParts / totalParts >= 0.7 then
        return true
    end
    
    -- Method 2: Check for common invisibility tools/accessories
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") or item:IsA("Accessory") then
            local itemName = item.Name:lower()
            if itemName:find("invisible") or itemName:find("invis") or itemName:find("ghost") then
                return true
            end
        end
    end
    
    -- Method 3: Check if humanoid has specific states
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- Check for PlatformStand (common in invisibility scripts)
        if humanoid.PlatformStand then
            return true
        end
    end
    
    -- Method 4: Check if character is at unusual positions (like under the map)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local position = rootPart.Position
        if position.Y < -100 then -- Likely under the map
            return true
        end
    end
    
    return false
end

-- Function to get distance between local player and target
local function getDistance(character)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return math.huge end
    
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
    return math.floor(distance)
end

-- Function to add ESP to a character
local function addESP(character, player)
    if not ESP_CONFIG.enabled then return end
    if not character or not character:FindFirstChild("Head") then return end
    if character:FindFirstChild("ESP_Highlight") then return end -- Already has ESP
    
    local isInvisible = isPlayerInvisible(character)
    
    -- Skip if invisible detection is disabled and player is invisible
    if isInvisible and not ESP_CONFIG.showInvisible then return end
    
    -- Track invisible players
    if isInvisible then
        invisiblePlayers[player.UserId] = true
    else
        invisiblePlayers[player.UserId] = false
    end
    
    -- Choose colors based on visibility
    local glowColor = isInvisible and ESP_CONFIG.invisibleColor or ESP_CONFIG.glowColor
    local nameColor = isInvisible and ESP_CONFIG.invisibleNameColor or ESP_CONFIG.nameColor
    
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = character
    highlight.FillColor = glowColor
    highlight.FillTransparency = isInvisible and 0.5 or 0.7
    highlight.OutlineColor = glowColor
    highlight.OutlineTransparency = isInvisible and 0.1 or 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    -- Add name label if enabled
    if ESP_CONFIG.showNames then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if rootPart and humanoid and not rootPart:FindFirstChild("ESP_Name") then
            local gui = Instance.new("BillboardGui")
            gui.Name = "ESP_Name"
            gui.Size = UDim2.new(0, 200, 0, 50)
            gui.StudsOffset = Vector3.new(0, 3, 0)
            gui.AlwaysOnTop = true
            gui.Parent = rootPart
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            
            local displayName = humanoid.DisplayName or player.Name or "Unknown"
            if isInvisible then
                displayName = ESP_CONFIG.invisiblePrefix .. displayName
            end
            
            nameLabel.Text = displayName
            nameLabel.TextColor3 = nameColor
            nameLabel.TextSize = ESP_CONFIG.nameSize
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Parent = gui
            
            -- Add distance label if enabled
            if ESP_CONFIG.showDistance then
                local distanceLabel = Instance.new("TextLabel")
                distanceLabel.Name = "DistanceLabel"
                distanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
                distanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
                distanceLabel.BackgroundTransparency = 1
                distanceLabel.Text = getDistance(character) .. "m"
                distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                distanceLabel.TextSize = ESP_CONFIG.nameSize - 2
                distanceLabel.TextStrokeTransparency = 0.5
                distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                distanceLabel.Font = Enum.Font.Gotham
                distanceLabel.Parent = gui
            end
        end
    end
end

-- Function to remove ESP from character
local function removeESP(character)
    if not character then return end
    
    local highlight = character:FindFirstChild("ESP_Highlight")
    if highlight then
        highlight:Destroy()
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local nameGui = rootPart:FindFirstChild("ESP_Name")
        if nameGui then
            nameGui:Destroy()
        end
    end
end

-- Function to remove all ESP
local function removeAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            removeESP(player.Character)
        end
    end
end

-- Function to add ESP to all current players
local function addAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local distance = getDistance(player.Character)
            if distance <= ESP_CONFIG.maxDistance then
                addESP(player.Character, player)
            end
        end
    end
end

-- Function to monitor a single player
local function monitorPlayer(player)
    if player == LocalPlayer then return end
    
    trackedPlayers[player.UserId] = player
    
    -- Add ESP to current character
    if player.Character then
        local distance = getDistance(player.Character)
        if distance <= ESP_CONFIG.maxDistance then
            addESP(player.Character, player)
        end
    end
    
    -- Add ESP when character respawns
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5) -- Wait for character to fully load
        local distance = getDistance(character)
        if distance <= ESP_CONFIG.maxDistance then
            addESP(character, player)
        end
    end)
end

-- Monitor all existing players
for _, player in pairs(Players:GetPlayers()) do
    monitorPlayer(player)
end

-- Monitor new players joining
Players.PlayerAdded:Connect(function(player)
    monitorPlayer(player)
end)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
    trackedPlayers[player.UserId] = nil
    invisiblePlayers[player.UserId] = nil
end)

-- Continuous monitoring and updating
task.spawn(function()
    while task.wait(0.5) do -- Check every 0.5 seconds for better performance
        if ESP_CONFIG.enabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local distance = getDistance(player.Character)
                    local hasESP = player.Character:FindFirstChild("ESP_Highlight")
                    
                    -- Add ESP if within range and doesn't have it
                    if distance <= ESP_CONFIG.maxDistance and not hasESP then
                        addESP(player.Character, player)
                    -- Remove ESP if out of range and has it
                    elseif distance > ESP_CONFIG.maxDistance and hasESP then
                        removeESP(player.Character)
                    -- Update existing ESP for invisible status changes
                    elseif hasESP then
                        local wasInvisible = invisiblePlayers[player.UserId]
                        local isNowInvisible = isPlayerInvisible(player.Character)
                        
                        -- If visibility status changed, refresh ESP
                        if wasInvisible ~= isNowInvisible then
                            removeESP(player.Character)
                            task.wait(0.1)
                            addESP(player.Character, player)
                        end
                        
                        -- Update distance if enabled
                        if ESP_CONFIG.showDistance then
                            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                            if rootPart then
                                local nameGui = rootPart:FindFirstChild("ESP_Name")
                                if nameGui then
                                    local distanceLabel = nameGui:FindFirstChild("DistanceLabel")
                                    if distanceLabel then
                                        distanceLabel.Text = distance .. "m"
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Global toggle functions
_G.toggleESP = function()
    ESP_CONFIG.enabled = not ESP_CONFIG.enabled
    if ESP_CONFIG.enabled then
        addAllESP()
    else
        removeAllESP()
    end
    return ESP_CONFIG.enabled
end

_G.enableESP = function()
    ESP_CONFIG.enabled = true
    addAllESP()
    return true
end

_G.disableESP = function()
    ESP_CONFIG.enabled = false
    removeAllESP()
    return false
end

_G.toggleNames = function()
    ESP_CONFIG.showNames = not ESP_CONFIG.showNames
    -- Refresh all ESP
    removeAllESP()
    if ESP_CONFIG.enabled then
        task.wait(0.1)
        addAllESP()
    end
    return ESP_CONFIG.showNames
end

_G.toggleInvisible = function()
    ESP_CONFIG.showInvisible = not ESP_CONFIG.showInvisible
    -- Refresh all ESP
    removeAllESP()
    if ESP_CONFIG.enabled then
        task.wait(0.1)
        addAllESP()
    end
    return ESP_CONFIG.showInvisible
end

_G.toggleDistance = function()
    ESP_CONFIG.showDistance = not ESP_CONFIG.showDistance
    -- Refresh all ESP
    removeAllESP()
    if ESP_CONFIG.enabled then
        task.wait(0.1)
        addAllESP()
    end
    return ESP_CONFIG.showDistance
end

_G.updateESPColor = function(newColor)
    ESP_CONFIG.glowColor = newColor
    -- Refresh all ESP with new color
    if ESP_CONFIG.enabled then
        removeAllESP()
        task.wait(0.1)
        addAllESP()
    end
end

_G.updateInvisibleColor = function(newColor)
    ESP_CONFIG.invisibleColor = newColor
    -- Refresh all ESP with new color
    if ESP_CONFIG.enabled then
        removeAllESP()
        task.wait(0.1)
        addAllESP()
    end
end

_G.setMaxDistance = function(distance)
    ESP_CONFIG.maxDistance = distance
    -- Refresh all ESP
    if ESP_CONFIG.enabled then
        removeAllESP()
        task.wait(0.1)
        addAllESP()
    end
end

_G.getInvisiblePlayers = function()
    local invisible = {}
    for userId, isInvis in pairs(invisiblePlayers) do
        if isInvis then
            local player = Players:GetPlayerByUserId(userId)
            if player then
                table.insert(invisible, player.Name)
            end
        end
    end
    return invisible
end

print("Advanced ESP System with Invisible Detection loaded!")
print("Functions:")
print("  _G.enableESP(), _G.disableESP(), _G.toggleESP()")
print("  _G.toggleNames(), _G.toggleInvisible(), _G.toggleDistance()")
print("  _G.updateESPColor(color), _G.updateInvisibleColor(color)")
print("  _G.setMaxDistance(studs), _G.getInvisiblePlayers()")
print("Invisible players will show in MAGENTA with [INVIS] prefix!")

return _G.ESP_CONFIG
