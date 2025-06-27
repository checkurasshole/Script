-- Simple Glow ESP System (GitHub Version)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Global ESP Configuration
_G.ESP_CONFIG = _G.ESP_CONFIG or {
    enabled = true,
    showNames = true,
    glowColor = Color3.fromRGB(0, 255, 0), -- Green color
    nameColor = Color3.fromRGB(255, 255, 255),
    nameSize = 14
}

local ESP_CONFIG = _G.ESP_CONFIG

-- Function to add ESP to a character
local function addESP(character)
    if not ESP_CONFIG.enabled then return end
    if not character or not character:FindFirstChild("Head") then return end
    if character:FindFirstChild("ESP_Highlight") then return end -- Already has ESP
    
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = character
    highlight.FillColor = ESP_CONFIG.glowColor
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = ESP_CONFIG.glowColor
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    -- Add name label if enabled
    if ESP_CONFIG.showNames then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if rootPart and humanoid and not rootPart:FindFirstChild("ESP_Name") then
            local gui = Instance.new("BillboardGui")
            gui.Name = "ESP_Name"
            gui.Size = UDim2.new(0, 200, 0, 30)
            gui.StudsOffset = Vector3.new(0, 3, 0)
            gui.AlwaysOnTop = true
            gui.Parent = rootPart
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = humanoid.DisplayName or "Unknown"
            nameLabel.TextColor3 = ESP_CONFIG.nameColor
            nameLabel.TextSize = ESP_CONFIG.nameSize
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Parent = gui
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
            addESP(player.Character)
        end
    end
end

-- Function to monitor a single player
local function monitorPlayer(player)
    if player == LocalPlayer then return end
    
    -- Add ESP to current character
    if player.Character then
        addESP(player.Character)
    end
    
    -- Add ESP when character respawns
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5) -- Wait for character to fully load
        addESP(character)
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

-- Continuously check for any missed players or characters
task.spawn(function()
    while task.wait(1) do
        if ESP_CONFIG.enabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    addESP(player.Character)
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

_G.updateESPColor = function(newColor)
    ESP_CONFIG.glowColor = newColor
    -- Refresh all ESP with new color
    if ESP_CONFIG.enabled then
        removeAllESP()
        task.wait(0.1)
        addAllESP()
    end
end

print("ESP System loaded and ready!")
print("Functions: _G.enableESP(), _G.disableESP(), _G.toggleESP(), _G.toggleNames()")

return _G.ESP_CONFIG