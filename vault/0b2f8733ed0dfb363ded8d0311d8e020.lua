-- Protected Script (French)
-- Script ID: 0b2f8733ed0dfb363ded8d0311d8e020
-- Migrated: 2025-09-11T13:21:31.579Z
-- Auto-migrated from encrypted storage to GitHub

local Rayfield = loadstring(game:HttpGet('__URL_9f1f6df31d3f2b19__'))()
local Window = Rayfield:CreateWindow({
    Name = "ComboChronique Vault de guerre dans le désert",
    Icon = 12345678901,
    LoadingTitle = "Chargement de ComboChronique Vault",
    LoadingSubtitle = "By COMBO_WICK | Bang.E.Line",
    Theme = "Ocean"
})

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Toggles
local aimbotEnabled = false
local autoLockEnabled = false
local walkspeedEnabled = false
local jumpBoostEnabled = false
local fovCircleEnabled = false

-- Variables
local espEnabled = false
local hitboxEnabled = false
local fovRadius = 100
local aimPart = "Head" -- Options: "Head", "Torso", "Random"
local smoothingFactor = 5 -- Higher = slower and smoother aiming
local walkspeedValue = 16 -- Default Roblox walkspeed
local jumpPowerValue = 50 -- Default Roblox jump power
local originalWalkspeed = 16
local originalJumpPower = 50

-- FOV Circle
local FOVCircle = nil

-- Memory Management Arrays
local espConnections = {}
local hitboxConnections = {}
local playerConnections = {}
local cleanupTasks = {}

-- Hitbox tracking
local hitboxedPlayers = {} -- Track which players have hitboxes applied
local hitboxUpdateConnection = nil

-- Constant Colors
local ENEMY_ESP_COLOR = Color3.fromRGB(255, 0, 0) -- Bright red for enemies
local TEAMMATE_ESP_COLOR = Color3.fromRGB(0, 255, 0) -- Bright green for teammates

-- Memory Leak Management
local function addToCleanup(connection, category)
    if not cleanupTasks[category] then
        cleanupTasks[category] = {}
    end
    table.insert(cleanupTasks[category], connection)
end

local function cleanupCategory(category)
    if cleanupTasks[category] then
        for _, connection in pairs(cleanupTasks[category]) do
            if connection and typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            elseif connection and typeof(connection) == "Instance" then
                connection:Destroy()
            end
        end
        cleanupTasks[category] = {}
    end
end

local function cleanupAll()
    for category, _ in pairs(cleanupTasks) do
        cleanupCategory(category)
    end
end

-- FOV Circle Functions
local function createFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 100
    FOVCircle.Radius = fovRadius
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Visible = fovCircleEnabled
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
end

local function updateFOVCircle()
    if FOVCircle and fovCircleEnabled then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVCircle.Radius = fovRadius
        FOVCircle.Visible = true
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
end

-- Initialize FOV Circle
createFOVCircle()

-- Update FOV Circle position
local fovUpdateConnection = RunService.RenderStepped:Connect(updateFOVCircle)
addToCleanup(fovUpdateConnection, "fov")

-- Movement Functions
local function updateWalkspeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if walkspeedEnabled then
            humanoid.WalkSpeed = walkspeedValue
        else
            humanoid.WalkSpeed = originalWalkspeed
        end
    end
end

local function updateJumpPower()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if jumpBoostEnabled then
            humanoid.JumpPower = jumpPowerValue
        else
            humanoid.JumpPower = originalJumpPower
        end
    end
end

-- Store original values when character spawns
local function storeOriginalValues()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        originalWalkspeed = humanoid.WalkSpeed
        originalJumpPower = humanoid.JumpPower
    end
end

-- Apply movement modifications when character respawns
local charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    wait(0.1) -- Small delay to ensure humanoid is fully loaded
    storeOriginalValues()
    updateWalkspeed()
    updateJumpPower()
end)
addToCleanup(charAddedConnection, "player")

-- Apply to current character if it exists
if LocalPlayer.Character then
    storeOriginalValues()
    updateWalkspeed()
    updateJumpPower()
end

-- Function to determine if a player is a teammate
local function isTeammate(player)
    local localPlayer = game.Players.LocalPlayer
    return player.Team == localPlayer.Team -- True if same team, false otherwise
end

-- FIXED HITBOX SYSTEM
-- Function to apply hitbox modifications ONLY to enemies
local function adjustHitbox(character, player)
    if not character or not player or not hitboxEnabled then return end
    
    -- Only apply hitbox to enemies, never to teammates
    if isTeammate(player) then 
        -- Remove hitbox from teammates if they switched teams
        removeHitbox(character)
        hitboxedPlayers[player] = nil
        return 
    end

    -- Skip if already modified and still valid
    if hitboxedPlayers[player] and CollectionService:HasTag(character, "HitboxModified") then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart.Size == Vector3.new(10, 10, 10) then
            return -- Already properly modified
        end
    end

    -- Apply hitbox to HumanoidRootPart
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.Size = Vector3.new(10, 10, 10)
        rootPart.Transparency = 0.7
        rootPart.CanCollide = false
        rootPart.Material = Enum.Material.ForceField
        rootPart.Color = Color3.fromRGB(255, 0, 0)
    end

    -- Apply hitbox to Head
    local head = character:FindFirstChild("Head")
    if head then
        head.Size = Vector3.new(9, 9, 9)
        head.Transparency = 0.7
        head.CanCollide = false
        head.Material = Enum.Material.ForceField
        head.Color = Color3.fromRGB(255, 0, 0)
    end
    
    -- Mark as modified to prevent double-processing
    CollectionService:AddTag(character, "HitboxModified")
    hitboxedPlayers[player] = true
    
    print("Applied hitbox to: " .. player.Name) -- Debug
end

-- Function to remove hitbox modifications
local function removeHitbox(character)
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if rootPart then
        rootPart.Size = Vector3.new(2, 2, 1)
        rootPart.Transparency = 0
        rootPart.CanCollide = true
        rootPart.Material = Enum.Material.Plastic
        rootPart.Color = Color3.fromRGB(163, 162, 165)
    end
    
    if head then
        head.Size = Vector3.new(1, 1, 1)
        head.Transparency = 0
        head.CanCollide = true
        head.Material = Enum.Material.Plastic
        head.Color = Color3.fromRGB(255, 184, 148)
    end
    
    if CollectionService:HasTag(character, "HitboxModified") then
        CollectionService:RemoveTag(character, "HitboxModified")
    end
end

-- Continuous hitbox maintenance system
local function maintainHitboxes()
    if not hitboxEnabled then return end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not isTeammate(player) then
                -- Apply hitbox to enemies
                adjustHitbox(player.Character, player)
            else
                -- Remove hitbox from teammates
                if hitboxedPlayers[player] then
                    removeHitbox(player.Character)
                    hitboxedPlayers[player] = nil
                end
            end
        end
    end
end

-- Function to monitor a player with memory management
local function monitorPlayer(player)
    -- Skip monitoring for local player
    if player == LocalPlayer then return end

    -- Clean up existing connections for this player
    if playerConnections[player] then
        for _, connection in pairs(playerConnections[player]) do
            if connection then
                connection:Disconnect()
            end
        end
    end
    playerConnections[player] = {}

    -- Apply hitbox to existing character (only if enabled and enemy)
    if hitboxEnabled and player.Character and not isTeammate(player) then
        adjustHitbox(player.Character, player)
    end

    -- Apply ESP to existing character
    if espEnabled and player.Character then
        addESP(player.Character, isTeammate(player))
    end

    -- Listen for respawns
    local charAddedConn = player.CharacterAdded:Connect(function(character)
        -- Wait a bit for character to fully load
        task.wait(0.5)
        
        if hitboxEnabled and not isTeammate(player) then
            adjustHitbox(character, player)
        end
        
        if espEnabled then
            addESP(character, isTeammate(player))
        end
    end)
    
    -- Listen for team changes
    local teamChangedConn = player:GetPropertyChangedSignal("Team"):Connect(function()
        if player.Character then
            if hitboxEnabled then
                if not isTeammate(player) then
                    adjustHitbox(player.Character, player)
                else
                    removeHitbox(player.Character)
                    hitboxedPlayers[player] = nil
                end
            end
            
            if espEnabled then
                addESP(player.Character, isTeammate(player))
            end
        end
    end)
    
    playerConnections[player] = {charAddedConn, teamChangedConn}
end

-- Function to add ESP to a character with health bar and memory management
local function addESP(character, isTeammate)
    if not character or not character:FindFirstChild("Head") then return end
    
    -- Remove existing ESP to prevent duplicates and memory leaks
    local existingHighlight = character:FindFirstChild("ESP_Highlight")
    if existingHighlight then
        existingHighlight:Destroy()
    end
    
    -- Create highlight ESP
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    -- Set colors based on team
    if isTeammate then
        highlight.FillColor = TEAMMATE_ESP_COLOR
        highlight.OutlineColor = Color3.new(0, 1, 0) -- Green outline for teammates
    else
        highlight.FillColor = ENEMY_ESP_COLOR
        highlight.OutlineColor = Color3.new(1, 0, 0) -- Red outline for enemies
    end
    
    highlight.Parent = character
    addToCleanup(highlight, "esp")
end

-- Helper Functions for Aimbot
local function getClosestEnemyTarget()
    local localPlayer = game.Players.LocalPlayer
    local mouse = localPlayer:GetMouse()
    local camera = workspace.CurrentCamera
    local closestDistance = fovRadius
    local closestPlayer = nil

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(aimPart) then
            -- Make sure it's an enemy, not a teammate
            if not isTeammate(player) then
                local targetPart = player.Character[aimPart]
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                -- Skip dead players
                if humanoid and humanoid.Health <= 0 then continue end
                
                local screenPosition, onScreen = camera:WorldToScreenPoint(targetPart.Position)

                if onScreen then
                    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = targetPart
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function aimAtTarget(target)
    if target then
        local camera = workspace.CurrentCamera
        local targetPosition = target.Position
        local currentPosition = camera.CFrame.Position

        local direction = (targetPosition - currentPosition).Unit
        local newCFrame = CFrame.new(currentPosition, currentPosition + direction)

        -- Apply smoothing
        camera.CFrame = camera.CFrame:Lerp(newCFrame, 1 / smoothingFactor)
    end
end

-- Main Aimbot Loop
local aimbotConnection = task.spawn(function()
    while task.wait() do
        if aimbotEnabled then
            local target = getClosestEnemyTarget()
            if target and autoLockEnabled then
                aimAtTarget(target)
            elseif target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                aimAtTarget(target)
            end
        end
    end
end)

-- Monitor all players currently in the game
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= LocalPlayer then
        monitorPlayer(player)
    end
end

-- Monitor new players joining
local playerAddedConnection = game.Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        monitorPlayer(player)
    end
end)
addToCleanup(playerAddedConnection, "player")

-- Clean up when players leave
local playerLeavingConnection = game.Players.PlayerRemoving:Connect(function(player)
    if playerConnections[player] then
        for _, connection in pairs(playerConnections[player]) do
            if connection then
                connection:Disconnect()
            end
        end
        playerConnections[player] = nil
    end
    
    -- Clean up hitbox tracking
    if hitboxedPlayers[player] then
        hitboxedPlayers[player] = nil
    end
end)
addToCleanup(playerLeavingConnection, "player")

-- FIXED: Continuously maintain hitboxes and ESP
local updateLoopConnection = task.spawn(function()
    while task.wait(1) do -- Check every second
        -- Maintain hitboxes for all enemy players
        maintainHitboxes()
        
        -- Update player ESP
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if espEnabled then
                    addESP(player.Character, isTeammate(player))
                end
            end
        end
    end
end)

-- Additional hitbox maintenance loop (more frequent)
hitboxUpdateConnection = task.spawn(function()
    while task.wait(0.5) do -- Check every 0.5 seconds for hitboxes
        if hitboxEnabled then
            maintainHitboxes()
        end
    end
end)

-- Free Pass Function (Door Bypass)
local function enableFreePass()
    local success, error = pcall(function()
        local settlers = workspace:WaitForChild("Map"):WaitForChild("World"):WaitForChild("Bases"):WaitForChild("Settlers", 5)
        if not settlers then return end
        
        -- Function to make part walk-through
        local function makePartWalkThrough(part)
            if not part:IsA("BasePart") then return end
            -- Remove scripts and touch stuff
            for _, obj in ipairs(part:GetChildren()) do
                if obj:IsA("TouchTransmitter") or obj.Name == "TouchInterest" then
                    obj:Destroy()
                elseif obj:IsA("Script") or obj:IsA("LocalScript") then
                    obj:Destroy()
                end
            end
            -- Set properties to allow walking through
            part.CanCollide = false
            part.CanTouch = false
            part.Touched:Connect(function() end)
            -- Re-apply properties if game tries to reset them
            part.Changed:Connect(function()
                part.CanCollide = false
                part.CanTouch = false
            end)
        end
        
        -- Automatically detect door parts
        for _, obj in ipairs(settlers:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("door") or obj.Name == "GP Door") then
                makePartWalkThrough(obj)
            end
        end
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Erreur de passage libre",
            Content = "Some doors couldn't be modified: " .. tostring(error),
            Duration = 5
        })
    else
        Rayfield:Notify({
            Title = "Free Pass Activé",
            Content = "Le contournement de la porte s'est activé avec succès",
            Duration = 3
        })
    end
end

-- Memory Management Function
local function performCleanup()
    -- Clean up dead references
    for category, items in pairs(cleanupTasks) do
        for i = #items, 1, -1 do
            local item = items[i]
            if not item or (typeof(item) == "Instance" and not item.Parent) then
                table.remove(items, i)
            end
        end
    end
    
    -- Force garbage collection
    task.wait()
    collectgarbage("collect")
end

-- Run cleanup every 30 seconds
local cleanupConnection = task.spawn(function()
    while true do
        task.wait(30)
        performCleanup()
    end
end)

-- Main Tab
local mainTab = Window:CreateTab("Principales", 4483362458)

-- Note about premium scripts
mainTab:CreateLabel("Premium scripts involved: Gun Mods, Kill All Players, TP to Death Position, ETC", 4483362458, Color3.fromRGB(255, 255, 255), false)

-- Toggle for enabling/disabling ESP
mainTab:CreateToggle({
    Name = "Activer ESP",
    CurrentValue = false,
    Flag = "espToggle",
    Callback = function(value)
        espEnabled = value
        if espEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    addESP(player.Character, isTeammate(player))
                end
            end
        else
            -- Clean up ESP
            cleanupCategory("esp")
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local highlight = player.Character:FindFirstChild("ESP_Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
})

-- FIXED: Toggle for enabling/disabling Hitbox
mainTab:CreateToggle({
    Name = "Activer Ennemy Hitbox",
    CurrentValue = false,
    Flag = "hitboxToggle",
    Callback = function(value)
        hitboxEnabled = value
        if hitboxEnabled then
            -- Apply hitboxes to all current enemy players
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= LocalPlayer and not isTeammate(player) and player.Character then
                    adjustHitbox(player.Character, player)
                end
            end
            
            Rayfield:Notify({
                Title = "Ennemi Hitbox activé",
                Content = "Hitboxes appliqués à tous les ennemis",
                Duration = 3
            })
        else
            -- Remove all hitboxes
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    removeHitbox(player.Character)
                end
            end
            -- Clear tracking
            hitboxedPlayers = {}
            
            Rayfield:Notify({
                Title = "Ennemy Hitbox désactivé",
                Content = "Toutes les boîtes à boutons supprimées",
                Duration = 3
            })
        end
    end
})

-- Added button for Free Pass
mainTab:CreateButton({
    Name = "Opérations spéciales débloquées",
    Callback = function()
        enableFreePass()
    end,
})

-- Movement Tab
local movementTab = Window:CreateTab("Mouvement", "person-standing")

-- Walkspeed Toggle
movementTab:CreateToggle({
    Name = "Activer la vitesse de marche personnalisée",
    CurrentValue = false,
    Flag = "walkspeedToggle",
    Callback = function(value)
        walkspeedEnabled = value
        updateWalkspeed()
        
        if value then
            Rayfield:Notify({
                Title = "Vitesse de marche activée",
                Content = "Custom walkspeed activated: " .. walkspeedValue,
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Vitesse de marche désactivée",
                Content = "Réinitialisation de la vitesse de marche à la normale",
                Duration = 3
            })
        end
    end,
})

-- Walkspeed Slider
movementTab:CreateSlider({
    Name = "Valeur de la vitesse de marche",
    Range = {16, 500},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = walkspeedValue,
    Flag = "walkspeedSlider",
    Callback = function(value)
        walkspeedValue = value
        if walkspeedEnabled then
            updateWalkspeed()
        end
    end,
})

-- Jump Boost Toggle
movementTab:CreateToggle({
    Name = "Activer le boost de saut",
    CurrentValue = false,
    Flag = "jumpBoostToggle",
    Callback = function(value)
        jumpBoostEnabled = value
        updateJumpPower()
        
        if value then
            Rayfield:Notify({
                Title = "Sauter le boost activé",
                Content = "Custom jump power activated: " .. jumpPowerValue,
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Insuffisance du bonus de saut",
                Content = "Réinitialisation de la puissance de saut à la normale",
                Duration = 3
            })
        end
    end,
})

-- Jump Power Slider
movementTab:CreateSlider({
    Name = "Valeur de la puissance de saut",
    Range = {50, 500},
    Increment = 5,
    Suffix = " Power",
    CurrentValue = jumpPowerValue,
    Flag = "jumpPowerSlider",
    Callback = function(value)
        jumpPowerValue = value
        if jumpBoostEnabled then
            updateJumpPower()
        end
    end,
})

-- Reset Movement Button
movementTab:CreateButton({
    Name = "Réinitialiser tous les mouvements",
    Callback = function()
        walkspeedEnabled = false
        jumpBoostEnabled = false
        updateWalkspeed()
        updateJumpPower()
        
        Rayfield:Notify({
            Title = "Réinitialisation des mouvements",
            Content = "Toutes les modifications de mouvement ont été désactivées",
            Duration = 3
        })
    end,
})

-- Aimbot Tab
local aimbotTab = Window:CreateTab("Aimateur+", "crosshair")

aimbotTab:CreateToggle({
    Name = "Activer l'Aimbot",
    CurrentValue = false,
    Flag = "aimbotToggle",
    Callback = function(value)
        aimbotEnabled = value
        
        if value then
            Rayfield:Notify({
                Title = "Aimbot activé",
                Content = "Aimbot est maintenant actif",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Handicapés de l'Aimbot",
                Content = "L'Aimbot a été éteint.",
                Duration = 3
            })
        end
    end,
})

aimbotTab:CreateToggle({
    Name = "Activer Auto-Lock",
    CurrentValue = false,
    Flag = "autoLockToggle",
    Callback = function(value)
        autoLockEnabled = value
        
        if value then
            Rayfield:Notify({
                Title = "Auto-Lock activé",
                Content = "Verrouillage automatique de la cible activé",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Désactivé automatique", 
                Content = "Visage manuel requis (maintenez le clic droit)",
                Duration = 3
            })
        end
    end,
})

aimbotTab:CreateToggle({
    Name = "Afficher le cercle FOV",
    CurrentValue = false,
    Flag = "fovCircleToggle",
    Callback = function(value)
        fovCircleEnabled = value
        if FOVCircle then
            FOVCircle.Visible = value
        end
        
        if value then
            Rayfield:Notify({
                Title = "Cercle FOV activé",
                Content = "Le cercle FOV est maintenant visible",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "FOV Circle Handicapés",
                Content = "Le cercle FOV a été caché",
                Duration = 3
            })
        end
    end,
})

aimbotTab:CreateSlider({
    Name = "Rayon FOV",
    Range = {50, 300},
    Increment = 10,
    Suffix = " FOV",
    CurrentValue = fovRadius,
    Flag = "fovSlider",
    Callback = function(value)
        fovRadius = value
        if FOVCircle then
            FOVCircle.Radius = value
        end
    end,
})

aimbotTab:CreateDropdown({
    Name = "Cible Os",
    Options = {"Head", "Torso", "Random"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "targetBoneDropdown",
    Callback = function(options)
        aimPart = options[1]
        
        Rayfield:Notify({
            Title = "Cible modifiée",
            Content = "Now targeting: " .. aimPart,
            Duration = 3
        })
    end,
})

aimbotTab:CreateSlider({
    Name = "Facteur de lissage",
    Range = {1, 10},
    Increment = 1,
    Suffix = " Smooth",
    CurrentValue = smoothingFactor,
    Flag = "smoothingSlider",
    Callback = function(value)
        smoothingFactor = value
    end,
})

-- Auto-cleanup when GUI is destroyed
local guiDestroyed = false
local function onGuiDestroyed()
    if not guiDestroyed then
        guiDestroyed = true
        cleanupAll()
        if FOVCircle then
            FOVCircle:Remove()
        end
        -- Clean up hitbox tracking
        hitboxedPlayers = {}
    end
end

-- Hook into window destruction
if Window and Window.Destroy then
    local originalDestroy = Window.Destroy
    Window.Destroy = function(...)
        onGuiDestroyed()
        return originalDestroy(...)
    end
end