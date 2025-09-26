getgenv().onelinegodmode = true local apply = function(char) char.Humanoid.Changed:Connect(function(property) if property == "Health" and char.Humanoid.Health < 100 and getgenv().onelinegodmode then game:GetService("ReplicatedStorage").RemoteEvents.DamagePlayer:FireServer(math.huge * -1) end end) end game.Players.LocalPlayer.CharacterAdded:Connect(function(character) apply(character) end) apply(game.Players.LocalPlayer.Character)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Items = workspace:WaitForChild("Items")
local client = require(LocalPlayer.PlayerScripts.Client)

local gameDetected = false
if workspace:FindFirstChild("Map") and workspace:FindFirstChild("Items") then
    gameDetected = true
end

-- Diamond Tracking Variables
local webhookUrl = ""
local userIdToPing = ""
local currentDiamonds = 0
local sessionGained = 0
local initialDiamonds = 0
local startTime = tick()
local lastDiamondNotificationTime = 0
local autoTeleportEnabled = false
local enableMentions = true
local enableUserPing = false

-- Circle Loop Variables
local circleLoopActive = false
local circleLoopConnection = nil
local noStrongholdFallbackEnabled = false
local manuallyStoppedLoop = false -- Add this to prevent auto-restart after manual stop

local CULTIST_KILLER_ENABLED = false
local cultistKillerConnection
local lastCultistKillTime = 0
local CULTIST_KILL_COOLDOWN = 1
local diamondChestConnection = nil
local diamondChestDetected = false
local diamondChestPosition = nil
local teleportAttemptCount = 0
local maxTeleportAttempts = 3
local lastTeleportAttemptTime = 0
local teleportCooldown = 2

-- Auto Equip Variables (keeping just the tracking function)
local inventoryItems = {}
local currentEquippedItem = "None"

-- Hotkey mappings for equipment
local hotkeys = {
    [1] = Enum.KeyCode.One,
    [2] = Enum.KeyCode.Two,
    [3] = Enum.KeyCode.Three,
    [4] = Enum.KeyCode.Four,
    [5] = Enum.KeyCode.Five,
    [6] = Enum.KeyCode.Six,
    [7] = Enum.KeyCode.Seven,
    [8] = Enum.KeyCode.Eight,
    [9] = Enum.KeyCode.Nine,
    [10] = Enum.KeyCode.Zero
}

local STRONGHOLD_COLORS = {
    Color3.fromRGB(195, 255, 0),
    Color3.fromRGB(255, 238, 0),
    Color3.fromRGB(255, 157, 0),
    Color3.fromRGB(255, 64, 0),
    Color3.fromRGB(255, 0, 0)
}

local StrongholdsData = {}
local Connections = {}
local UpdateConnection = nil
local lastOpenStrongholds = {}
local lastNotificationTime = {}
local NOTIFICATION_COOLDOWN = 30

local strongholds = {}
local timerConnections = {}
local notifications = true
local skipTimerEnabled = false
local skipTimerThreshold = 0
local hasSkippedThisSession = false

local function safeNotify(title, content, duration, notificationKey)
    duration = duration or 3
    notificationKey = notificationKey or (title .. content)
    
    local currentTime = tick()
    
    if lastNotificationTime[notificationKey] and (currentTime - lastNotificationTime[notificationKey]) < NOTIFICATION_COOLDOWN then
        return
    end
    
    lastNotificationTime[notificationKey] = currentTime
    
    Fluent:Notify({
        Title = title,
        Content = content,
        Duration = duration
    })
end

-- Diamond Functions
function getCurrentDiamonds()
    if LocalPlayer:GetAttribute("Diamonds") then
        return LocalPlayer:GetAttribute("Diamonds")
    end
    return 0
end

function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function createDiscordEmbed(diamondsGained)
    local embed = {
        title = "Diamond Alert!",
        description = string.format("**%s** just gained diamonds!", LocalPlayer.Name),
        color = 3447003,
        fields = {
            {
                name = "Current Diamonds",
                value = string.format("```%s```", tostring(currentDiamonds)),
                inline = true
            },
            {
                name = "Diamonds Gained",
                value = string.format("```+%s```", tostring(diamondsGained)),
                inline = true
            },
            {
                name = "Session Total",
                value = string.format("```+%s```", tostring(sessionGained)),
                inline = true
            },
            {
                name = "Session Time",
                value = string.format("```%s```", formatTime(tick() - startTime)),
                inline = true
            },
            {
                name = "Player",
                value = string.format("```%s```", LocalPlayer.Name),
                inline = false
            }
        },
        thumbnail = {
            url = "https://media.discordapp.net/attachments/1400825424535224511/1420864823675060275/2Q.png"
        },
        footer = {
            text = "Diamond Tracker • " .. os.date("%X")
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    return embed
end

function sendWebhook(diamondsGained)
    if webhookUrl == "" then return end
    
    local embed = createDiscordEmbed(diamondsGained)
    local content = ""
    
    if enableMentions then
        content = "@everyone"
    elseif enableUserPing and userIdToPing ~= "" then
        content = "<@" .. userIdToPing .. ">"
    end
    
    local data = {
        content = content,
        username = "Diamond Tracker",
        avatar_url = "https://media.discordapp.net/attachments/1400825424535224511/1420864823675060275/2Q.png",
        embeds = {embed}
    }
    
    local success, response = pcall(function()
        return http_request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success and response.StatusCode == 204 then
        Fluent:Notify({
            Title = "Webhook Sent",
            Content = string.format("Notified about +%d diamonds!", diamondsGained),
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Webhook Failed",
            Content = "Failed to send webhook message",
            Duration = 3
        })
    end
end

function sendTestWebhook()
    local embed = {
        title = "Test Message",
        description = "This is a test message from Diamond Tracker!",
        color = 65280,
        fields = {
            {
                name = "Status",
                value = "Webhook is working correctly!",
                inline = false
            },
            {
                name = "Player",
                value = LocalPlayer.Name,
                inline = false
            }
        },
        thumbnail = {
            url = "https://media.discordapp.net/attachments/1400825424535224511/1420864823675060275/2Q.png"
        },
        footer = {
            text = "Diamond Tracker Test • " .. os.date("%X")
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    local data = {
        username = "Diamond Tracker",
        avatar_url = "https://media.discordapp.net/attachments/1400825424535224511/1420864823675060275/2Q.png",
        embeds = {embed}
    }
    
    local success, response = pcall(function()
        return http_request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success and response.StatusCode == 204 then
        Fluent:Notify({
            Title = "Test Successful",
            Content = "Webhook is configured correctly!",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Test Failed",
            Content = "Webhook configuration error",
            Duration = 3
        })
    end
end

function onDiamondsChanged()
    local newDiamonds = getCurrentDiamonds()
    local currentTime = tick()
    
    if currentTime - lastDiamondNotificationTime < 1 then
        return
    end
    
    if newDiamonds > currentDiamonds then
        local diamondsGained = newDiamonds - currentDiamonds
        lastDiamondNotificationTime = currentTime
        
        sessionGained = newDiamonds - initialDiamonds
        
        sendWebhook(diamondsGained)
        
        Fluent:Notify({
            Title = "Diamonds Gained!",
            Content = string.format("You gained %d diamonds!", diamondsGained),
            Duration = 2
        })
        
        if autoTeleportEnabled then
            task.spawn(function()
                task.wait(3)
                TeleportService:Teleport(126509999114328)
            end)
        end
    end
    
    currentDiamonds = newDiamonds
end

-- Auto Equip Functions (keep only the tracking functions)
function updateInventory()
    inventoryItems = {}
    
    local inventory = LocalPlayer:FindFirstChild("Inventory")
    if inventory then
        for i, item in pairs(inventory:GetChildren()) do
            if item:IsA("Model") or item:IsA("Tool") then
                table.insert(inventoryItems, {
                    name = item.Name,
                    slot = i,
                    object = item
                })
            end
        end
    end
end

function getCurrentEquipped()
    local character = LocalPlayer.Character
    if character then
        local toolHandle = character:FindFirstChild("ToolHandle")
        if toolHandle then
            local originalItem = toolHandle:FindFirstChild("OriginalItem")
            if originalItem and originalItem.Value then
                currentEquippedItem = originalItem.Value.Name
                return
            end
        end
        
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            currentEquippedItem = tool.Name
            return
        end
    end
    
    currentEquippedItem = "None"
end

-- Function to validate if weapon is allowed
local function isAllowedWeapon(weaponName)
    local name = string.lower(weaponName)
    return string.find(name, "axe") or 
           string.find(name, "sword") or 
           string.find(name, "spear") or
           string.find(name, "morning star")
end

function ensureProperWeaponEquipped()
    updateInventory()
    
    -- Try slots 1-5 to find a weapon
    local slotsToTry = {2, 1, 3, 4, 5} -- Start with slot 2 as requested, then try others
    
    for _, slotNum in pairs(slotsToTry) do
        local keyCode = hotkeys[slotNum]
        if keyCode then
            -- Press the key
            game:GetService("VirtualInputManager"):SendKeyEvent(true, keyCode, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, keyCode, false, game)
            task.wait(0.5) -- Wait to see if something equipped
            
            -- Check what we have now
            getCurrentEquipped()
            
            -- If we now have something equipped that looks like a weapon, we're good
            if currentEquippedItem ~= "None" and isAllowedWeapon(currentEquippedItem) then
                safeNotify("Fallback Equipped", "Equipped " .. currentEquippedItem .. " from slot " .. slotNum, 3, "auto_equip_fallback")
                return true
            end
        end
    end
    
    -- If we still don't have a weapon, try slot 2 one more time and accept whatever happens
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Two, false, game)
    task.wait(0.5)
    
    getCurrentEquipped()
    if currentEquippedItem ~= "None" then
        safeNotify("Fallback Equipped", "Equipped " .. currentEquippedItem .. " from slot 2", 3, "auto_equip_final")
    else
        safeNotify("No Weapon Equipped", "Could not find suitable weapon - proceeding anyway", 3, "no_weapon_warning")
    end
    
    return true
end

-- Circle Loop Functions
local function doSingleCircleLoop(r, o, v)
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local rootPart = character.HumanoidRootPart
    local angle = 0
    local fullCircle = 2 * math.pi
    local startTime = tick()
    
    while angle < fullCircle and circleLoopActive do
        local deltaTime = task.wait()
        -- Add safety check for long loops
        if tick() - startTime > 300 then -- 5 minute timeout per circle
            break
        end
        
        if not circleLoopActive then
            break
        end
        
        angle = math.min(angle + (v * deltaTime), fullCircle)
        local x = o.X + r * math.cos(angle)
        local z = o.Z + r * math.sin(angle)
        local newPosition = Vector3.new(x, o.Y, z)
        rootPart.CFrame = CFrame.new(newPosition)
    end
    
    return circleLoopActive
end

local function startCircleLoopFallback()
    if circleLoopActive or manuallyStoppedLoop then
        return
    end
    
    circleLoopActive = true
    safeNotify("Circle Loop Started", "Searching for strongholds/diamond chest - will continue until found", 5, "circle_start")
    
    task.spawn(function()
        local radius_list = {
            [1] = 150,
            [2] = 400,
            [3] = 600,
            [4] = 825,
            [5] = 1150,
            [6] = 1400
        }
        
        local cycleCount = 0
        
        while circleLoopActive do
            cycleCount = cycleCount + 1
            
            for i, v in ipairs(radius_list) do
                if not circleLoopActive then
                    break
                end
                
                local success = doSingleCircleLoop(v, Vector3.new(0, 15, 0), 1/(2*i))
                if not success then
                    break
                end
                
                -- Check for strongholds or diamond chest after each circle
                local strongholdCount = #CollectionService:GetTagged("Stronghold")
                local diamondChestExists = workspace.Items:FindFirstChild("Stronghold Diamond Chest") ~= nil
                
                if strongholdCount > 0 or diamondChestExists then
                    local reason = strongholdCount > 0 and string.format("Found %d strongholds", strongholdCount) or "Diamond chest detected"
                    safeNotify("Target Found!", reason .. " - stopping circle loop after " .. cycleCount .. " cycles", 5, "target_found")
                    circleLoopActive = false
                    noStrongholdFallbackEnabled = false
                    break
                end
                
                task.wait(1) -- Brief pause between circles
            end
            
            -- If we completed all circles but still haven't found anything, continue searching
            if circleLoopActive then
                safeNotify("Search Cycle Complete", string.format("Cycle %d complete - continuing search...", cycleCount), 3, "cycle_complete_" .. cycleCount)
                task.wait(3) -- Brief pause before starting next cycle
            end
        end
        
        circleLoopActive = false
    end)
end

-- FIXED: Properly stop the circle loop and prevent auto-restart
local function stopCircleLoop()
    circleLoopActive = false
    manuallyStoppedLoop = true -- Prevent auto-restart
    
    -- Cancel the spawned task by setting the flag to false
    -- The loop will naturally exit when it checks circleLoopActive
    
    if circleLoopConnection then
        circleLoopConnection:Disconnect()
        circleLoopConnection = nil
    end
    
    safeNotify("Circle Loop Stopped", "Search pattern has been stopped and won't auto-restart", 3, "circle_stop")
end

local function checkForAutoCircleLoop()
    -- Don't auto-start if manually stopped
    if manuallyStoppedLoop then
        return
    end
    
    local strongholdCount = #CollectionService:GetTagged("Stronghold")
    local diamondChestExists = workspace.Items:FindFirstChild("Stronghold Diamond Chest") ~= nil
    
    -- Start circle loop if no strongholds AND no diamond chest detected
    if strongholdCount == 0 and not diamondChestExists and not circleLoopActive then
        safeNotify("No Strongholds or Diamond Chest", "Auto-starting circle loop search pattern", 5, "auto_circle_start")
        noStrongholdFallbackEnabled = true -- Auto-enable the fallback
        startCircleLoopFallback()
    -- Stop circle loop if strongholds OR diamond chest found
    elseif (strongholdCount > 0 or diamondChestExists) and circleLoopActive then
        local reason = strongholdCount > 0 and string.format("Found %d strongholds", strongholdCount) or "Diamond chest detected"
        safeNotify("Targets Found", reason .. " - stopping circle loop", 5, "targets_found")
        circleLoopActive = false -- Don't set manuallyStoppedLoop here, this is auto-stop
        manuallyStoppedLoop = false -- Reset manual stop flag when targets are found
    end
end

local function getPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local part = obj:FindFirstChildWhichIsA("BasePart")
        return part and part.Position or obj:GetPivot().Position
    end
end

-- Function to find valid weapon from inventory
local function findValidWeapon()
    for _, weapon in pairs(LocalPlayer:WaitForChild("Inventory"):GetChildren()) do
        if isAllowedWeapon(weapon.Name) then
            return weapon
        end
    end
    return nil
end

-- Enhanced cultist detection - checks if name contains "cultist" (case insensitive)
local function isCultist(name)
    return string.find(string.lower(name), "cultist") ~= nil
end

local function attackWithWeapon(weapon)
    if not weapon or not weapon.Parent then
        return 0
    end
    
    local attackCount = 0
    local successfulAttacks = 0
    
    -- Attack Characters folder NPCs
    if workspace:FindFirstChild("Characters") then
        for _, target in pairs(workspace.Characters:GetChildren()) do
            if target ~= LocalPlayer.Character and target:FindFirstChild("NPC") and target:HasTag("NPC") then
                if isCultist(target.Name) then
                    attackCount = attackCount + 1
                    task.spawn(function()
                        local success = pcall(function()
                            local hitId = tostring(tick()) .. "_" .. LocalPlayer.UserId
                            ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                target, 
                                weapon, 
                                hitId,
                                HumanoidRootPart.CFrame
                            )
                            successfulAttacks = successfulAttacks + 1
                        end)
                        if not success then
                            warn("Failed to attack target:", target.Name)
                        end
                    end)
                end
            end
        end
    end
    
    -- Attack Map descendants
    if workspace:FindFirstChild("Map") then
        for _, enemy in pairs(workspace.Map:GetDescendants()) do
            if enemy:IsA("Model") and enemy ~= LocalPlayer.Character then
                if isCultist(enemy.Name) then
                    attackCount = attackCount + 1
                    task.spawn(function()
                        local success = pcall(function()
                            local hitId = tostring(tick()) .. "_" .. LocalPlayer.UserId
                            ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                enemy, 
                                weapon, 
                                hitId,
                                HumanoidRootPart.CFrame
                            )
                            successfulAttacks = successfulAttacks + 1
                        end)
                        if not success then
                            warn("Failed to attack target:", enemy.Name)
                        end
                    end)
                end
            end
        end
    end
    
    -- Attack workspace children
    for _, enemy in pairs(workspace:GetChildren()) do
        if enemy:IsA("Model") and enemy ~= LocalPlayer.Character then
            if isCultist(enemy.Name) then
                attackCount = attackCount + 1
                task.spawn(function()
                    local success = pcall(function()
                        local hitId = tostring(tick()) .. "_" .. LocalPlayer.UserId
                        ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                            enemy, 
                            weapon, 
                            hitId,
                            HumanoidRootPart.CFrame
                        )
                        successfulAttacks = successfulAttacks + 1
                    end)
                    if not success then
                        warn("Failed to attack target:", enemy.Name)
                    end
                end)
            end
        end
    end
    
    return successfulAttacks
end

local function killCultistsOnce()
    local weapon = findValidWeapon()
    if not weapon then
        return 0
    end
    
    return attackWithWeapon(weapon)
end

local function setupCultistKiller()
    if cultistKillerConnection then
        cultistKillerConnection:Disconnect()
    end
    
    if not CULTIST_KILLER_ENABLED then
        return
    end
    
    cultistKillerConnection = RunService.Heartbeat:Connect(function()
        if CULTIST_KILLER_ENABLED and tick() - lastCultistKillTime >= CULTIST_KILL_COOLDOWN then
            local damaged = killCultistsOnce()
            if damaged > 0 then
                lastCultistKillTime = tick()
            end
        end
    end)
end

local function MoveDirect(root, targetPos)
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.zero
    bv.Parent = root

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not bv.Parent then
            conn:Disconnect()
            return
        end

        local direction = targetPos - root.Position
        local dist = direction.Magnitude

        if dist < 5 then
            bv:Destroy()
            conn:Disconnect()
        else
            bv.Velocity = direction.Unit * 42
        end
    end)
end

local function MoveToBase(root, targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = false
    })
    path:ComputeAsync(root.Position, targetPos)

    if path.Status ~= Enum.PathStatus.Success then
        return MoveDirect(root, targetPos)
    end

    local waypoints = path:GetWaypoints()
    local currentIndex = 1

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.zero
    bv.Parent = root

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not bv.Parent or currentIndex > #waypoints then
            bv:Destroy()
            conn:Disconnect()
            return
        end

        local wp = waypoints[currentIndex]
        local direction = wp.Position - root.Position
        local dist = direction.Magnitude

        if dist < 3 then
            currentIndex += 1
        else
            bv.Velocity = direction.Unit * 42
        end
    end)
end

local function executeDiamondChestSequence()
    pcall(function()
        -- Ensure proper weapon is equipped before starting
        ensureProperWeaponEquipped()
        task.wait(1)
        
        local humanoid = Character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 50

        local function enableNoclip()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        local function disableNoclip()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end

        enableNoclip()

        local chestRequestDetected = false
        
        if getrawmetatable then
            local mt = getrawmetatable(game)
            if mt and mt.__namecall then
                local oldNamecall = mt.__namecall
                if setreadonly then setreadonly(mt, false) end
                
                mt.__namecall = function(self, ...)
                    local method = getnamecallmethod and getnamecallmethod() or ""
                    local args = {...}

                    if method == "FireServer" and tostring(self):find("RequestOpenItemChest") then
                        chestRequestDetected = true
                    end

                    return oldNamecall(self, ...)
                end
                
                if setreadonly then setreadonly(mt, true) end
                
                local function restoreMetatable()
                    if setreadonly then setreadonly(mt, false) end
                    mt.__namecall = oldNamecall
                    if setreadonly then setreadonly(mt, true) end
                end
                
                task.spawn(function()
                    task.wait(30)
                    if not chestRequestDetected then
                        restoreMetatable()
                    end
                end)
            end
        end

        local strongholdChest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
        if strongholdChest then
            local proximityPrompt = strongholdChest.Main.ProximityAttachment.ProximityInteraction
            
            if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
                proximityPrompt.HoldDuration = 0
                proximityPrompt.RequiresLineOfSight = false
                proximityPrompt.MaxActivationDistance = math.huge
                
                if fireproximityprompt then
                    fireproximityprompt(proximityPrompt)
                else
                    proximityPrompt:InputHoldBegin()
                    proximityPrompt:InputHoldEnd()
                end
            end
        end
        
        task.wait(3)
        
        if chestRequestDetected then
            for attempt = 1, 3 do
                for _, item in pairs(workspace.Items:GetChildren()) do
                    pcall(function()
                        require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
                    end)
                end
                task.wait(1)
            end
            
            disableNoclip()
            return
        end

        local gate = workspace.Map.Landmarks.Stronghold.Functional.FinalGate

        if not gate:GetAttribute("OriginalY") then
            gate:SetAttribute("OriginalY", gate.WorldPivot.Y)
        end

        local lastState
        local gateOpenedDetected = false

        local gateMonitorConnection = task.spawn(function()
            while true do
                local originalY = gate:GetAttribute("OriginalY")
                local currentY = gate.WorldPivot.Y
                local state

                if currentY > originalY then
                    state = "OPEN"
                    if lastState ~= "OPEN" then
                        gateOpenedDetected = true
                        
                        CULTIST_KILLER_ENABLED = false
                        if cultistKillerConnection then
                            cultistKillerConnection:Disconnect()
                            cultistKillerConnection = nil
                        end
                        
                        task.wait(4)
                        
                        local strongholdChest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
                        if strongholdChest then
                            local proximityPrompt = strongholdChest.Main.ProximityAttachment.ProximityInteraction
                            
                            if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
                                proximityPrompt.HoldDuration = 0
                                proximityPrompt.RequiresLineOfSight = false
                                proximityPrompt.MaxActivationDistance = math.huge
                                
                                if fireproximityprompt then
                                    fireproximityprompt(proximityPrompt)
                                else
                                    proximityPrompt:InputHoldBegin()
                                    proximityPrompt:InputHoldEnd()
                                end
                            end
                        end
                        
                        task.wait(1)
                        
                        for attempt = 1, 3 do
                            for _, item in pairs(workspace.Items:GetChildren()) do
                                pcall(function()
                                    require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
                                end)
                            end
                            task.wait(1)
                        end
                    end
                else
                    state = "CLOSED"
                end

                if state ~= lastState then
                    lastState = state
                end

                task.wait(5)
            end
        end)

        local function MoveToPosition(root, targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = false
    })
    
    path:ComputeAsync(root.Position, targetPos)
    
    if path.Status ~= Enum.PathStatus.Success then
        return false
    end

    local waypoints = path:GetWaypoints()
    local currentIndex = 1
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not bv.Parent or currentIndex > #waypoints then
            if bv.Parent then bv:Destroy() end
            if conn then conn:Disconnect() end
            return
        end
        
        local wp = waypoints[currentIndex]
        local direction = wp.Position - root.Position
        local distance = direction.Magnitude
        
        -- Check if we're very close to the final target (shelf)
        local distanceToFinalTarget = (root.Position - targetPos).Magnitude
        
        if distanceToFinalTarget <= 8 then -- When close to shelf
            -- Instant stop and anchor
            bv.Velocity = Vector3.zero
            root.Anchored = true
            
            -- Brief pause then unanchor and position exactly
            task.wait(0.1)
            root.CFrame = CFrame.new(targetPos)
            root.Anchored = false
            
            -- Clean up
            if bv.Parent then bv:Destroy() end
            if conn then conn:Disconnect() end
            return
        end
        
        if distance < 4 then
            currentIndex = currentIndex + 1
        else
            bv.Velocity = direction.Unit * 100
        end
    end)
    
    return true
end

        local decoration = workspace.Map.Landmarks.Stronghold.Building.Interior:WaitForChild("Decoration")
        local barrel = decoration:FindFirstChild("Barrel") or decoration:GetChildren()[27]
        local barrelPos = getPos(barrel)

        if barrelPos then
            HumanoidRootPart.CFrame = CFrame.new(barrelPos + Vector3.new(0, 3, 0))
            task.wait(1)
        end

        local shelf = decoration:FindFirstChild("Shelf")
        local shelfPos = getPos(shelf)

        if shelfPos then
            local offsets = {
                Vector3.new(0,0,5), Vector3.new(5,0,0), Vector3.new(-5,0,0),
                Vector3.new(0,0,-5), Vector3.new(3,0,3), Vector3.new(-3,0,3)
            }
            
            for _, offset in ipairs(offsets) do
                if MoveToPosition(HumanoidRootPart, shelfPos + offset) then 
                    task.wait(2)
                    local currentDistance = (HumanoidRootPart.Position - shelfPos).Magnitude
                    if currentDistance <= 10 then
                        break
                    end
                end
                task.wait(1)
            end
            
            local finalDistance = (HumanoidRootPart.Position - shelfPos).Magnitude
            if finalDistance <= 10 then
                CULTIST_KILLER_ENABLED = true
                setupCultistKiller()
            end
        end

        task.wait(1)

        for _, item in pairs(workspace.Items:GetChildren()) do
            pcall(function()
                require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
            end)
        end
        
        task.wait(1)
        disableNoclip()
    end)
end

local function teleportToPosition(position)
    if not position then return false, "No position provided" end
    
    local targetCFrame
    if typeof(position) == "CFrame" then
        targetCFrame = position
    else
        targetCFrame = CFrame.new(position + Vector3.new(0, 5, 0))
    end
    
    local originalPosition = HumanoidRootPart.CFrame.Position
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    tween.Completed:Wait()
    
    local currentPosition = HumanoidRootPart.CFrame.Position
    local distanceToTarget = (currentPosition - targetCFrame.Position).Magnitude
    local distanceToOriginal = (currentPosition - originalPosition).Magnitude
    
    if distanceToTarget > 5 and distanceToOriginal < 5 then
        return false, "Teleport failed: Player reset to original position"
    elseif distanceToTarget > 5 then
        return false, "Teleport failed: Player moved to unexpected position"
    end
    
    return true, "Teleport successful"
end

local function attemptDiamondChestTeleport()
    if not diamondChestPosition then
        return false, "No diamond chest position stored"
    end
    
    local success, message = teleportToPosition(diamondChestPosition + Vector3.new(0, 5, 0))
    if not success then
        return false, message
    end
    
    task.wait(1)
    executeDiamondChestSequence()
    task.wait(1)
    
    local finalSuccess, finalMessage = teleportToPosition(diamondChestPosition + Vector3.new(0, 5, 0))
    
    if finalSuccess then
        return true, "Diamond chest sequence completed successfully"
    else
        return false, "Final teleport failed: " .. finalMessage
    end
end

local function setupEnhancedDiamondChestDetection()
    if diamondChestConnection then
        diamondChestConnection:Disconnect()
    end
    
    diamondChestConnection = Items.ChildAdded:Connect(function(child)
        if child.Name == "Stronghold Diamond Chest" then
            if child:IsA("Model") then
                diamondChestPosition = child:GetModelCFrame().Position
            elseif child:IsA("BasePart") then
                diamondChestPosition = child.Position
            end
            
            diamondChestDetected = true
            teleportAttemptCount = 0
            
            -- Stop circle loop if it's running since we found a diamond chest
            if circleLoopActive then
                stopCircleLoop()
            end
            
            safeNotify("DIAMOND CHEST DETECTED!", "Starting enhanced teleport sequence immediately!", 5, "chest_detected")
            
            task.spawn(function()
                task.wait(1)
                local success, message = attemptDiamondChestTeleport()
                if success then
                    safeNotify("Auto Diamond Chest Complete!", "Successfully completed diamond chest sequence!", 5, "chest_complete")
                else
                    safeNotify("Auto Diamond Chest Failed", message, 5, "chest_failed")
                end
            end)
        end
    end)
    
    -- Also monitor for diamond chest removal to potentially restart circle loop
    Items.ChildRemoved:Connect(function(child)
        if child.Name == "Stronghold Diamond Chest" then
            diamondChestDetected = false
            diamondChestPosition = nil
            
            -- Check if we need to restart circle loop after chest disappears
            task.wait(2)
            checkForAutoCircleLoop()
        end
    end)
    
    for _, child in ipairs(Items:GetChildren()) do
        if child.Name == "Stronghold Diamond Chest" and not diamondChestDetected then
            if child:IsA("Model") then
                diamondChestPosition = child:GetModelCFrame().Position
            elseif child:IsA("BasePart") then
                diamondChestPosition = child.Position
            end
            
            diamondChestDetected = true
            teleportAttemptCount = 0
            
            -- Stop circle loop if it's running since we found a diamond chest
            if circleLoopActive then
                stopCircleLoop()
            end
            
            safeNotify("DIAMOND CHEST ALREADY AVAILABLE!", "Auto-starting enhanced sequence!", 5, "chest_existing")
            
            task.spawn(function()
                task.wait(1)
                local success, message = attemptDiamondChestTeleport()
                if success then
                    safeNotify("Auto Diamond Chest Complete!", "Successfully completed diamond chest sequence!", 5, "chest_complete")
                else
                    safeNotify("Auto Diamond Chest Failed", message, 5, "chest_failed")
                end
            end)
            break
        end
    end
end

local function getStrongholdInfo(stronghold)
    local functional = stronghold:FindFirstChild("Functional")
    if not functional then return nil end
    
    local level = functional:GetAttribute("Level") or 1
    local openTime = functional:GetAttribute("OpenTime")
    local isOpen = false
    local timeLeft = 0
    
    if openTime then
        timeLeft = openTime - workspace:GetServerTimeNow()
        isOpen = timeLeft <= 0
    end
    
    local position = stronghold.PrimaryPart and stronghold.PrimaryPart.Position or stronghold:GetModelCFrame().Position
    
    local displayName = "The Cultist Stronghold"
    if stronghold.Name == "Stronghold" then
        displayName = "The Cultist Stronghold"
    end
    
    return {
        name = stronghold.Name,
        displayName = displayName,
        level = level,
        levelColor = STRONGHOLD_COLORS[level] or STRONGHOLD_COLORS[5],
        openTime = openTime,
        isOpen = isOpen,
        timeLeft = math.max(0, timeLeft),
        position = position,
        stronghold = stronghold,
        distance = nil,
        compassDir = nil
    }
end

local function calculateDistanceAndDirection(targetPos)
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
        return nil, nil
    end
    
    local playerPos = LocalPlayer.Character.PrimaryPart.Position
    local distance = (targetPos - playerPos).Magnitude
    local direction = (targetPos - playerPos).Unit
    
    local angle = math.atan2(direction.X, direction.Z)
    local degrees = math.deg(angle)
    if degrees < 0 then degrees = degrees + 360 end
    
    local compassDirections = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
    local directionIndex = math.floor((degrees + 22.5) / 45) % 8 + 1
    local compassDir = compassDirections[directionIndex]
    
    return distance, compassDir
end

local function formatStrongholdTime(seconds)
    if seconds <= 60 then
        return string.format("%02ds", math.floor(seconds))
    else
        local minutes = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02dm %02ds", minutes, secs)
    end
end

local function convertTime(seconds)
    if seconds <= 0 then
        return "OPEN NOW!"
    elseif seconds <= 60 then
        return string.format("%02ds", math.floor(seconds))
    elseif seconds <= 3600 then
        return string.format("%02dm %02ds", math.floor(seconds / 60), math.floor(seconds % 60))
    else
        return string.format("%02dh %02dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
    end
end

local function updateStrongholdsData()
    StrongholdsData = {}
    
    local strongholds_list = CollectionService:GetTagged("Stronghold")
    
    for _, stronghold in pairs(strongholds_list) do
        if stronghold.Name ~= "AlienMothership" then
            local data = getStrongholdInfo(stronghold)
            if data then
                local distance, compassDir = calculateDistanceAndDirection(data.position)
                data.distance = distance
                data.compassDir = compassDir
                table.insert(StrongholdsData, data)
                
                local strongholdKey = data.name .. "_" .. data.level
                local previouslyOpen = lastOpenStrongholds[strongholdKey]
                
                if data.isOpen and not previouslyOpen then
                    lastOpenStrongholds[strongholdKey] = true
                    
                    local strongholdChest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
                    
                    if strongholdChest then
                        safeNotify("STRONGHOLD & CHEST DETECTED!", 
                                  string.format("%s (Level %d) opened with diamond chest! Starting sequence...", 
                                                data.displayName, data.level), 
                                  5, 
                                  "stronghold_chest_" .. strongholdKey)
                        
                        task.spawn(function()
                            task.wait(2)
                            
                            if strongholdChest:IsA("Model") then
                                diamondChestPosition = strongholdChest:GetModelCFrame().Position
                            elseif strongholdChest:IsA("BasePart") then
                                diamondChestPosition = strongholdChest.Position
                            end
                            
                            local success, message = attemptDiamondChestTeleport()
                            if success then
                                safeNotify("Stronghold Auto Complete!", 
                                          "Successfully completed diamond chest sequence for opened stronghold!", 
                                          5, 
                                          "stronghold_success_" .. strongholdKey)
                            else
                                safeNotify("Stronghold Auto Failed", message, 5, "stronghold_fail_" .. strongholdKey)
                            end
                        end)
                    end
                    
                elseif not data.isOpen and previouslyOpen then
                    lastOpenStrongholds[strongholdKey] = false
                end
            end
        end
    end
    
    table.sort(StrongholdsData, function(a, b)
        if not a.distance then return false end
        if not b.distance then return true end
        return a.distance < b.distance
    end)
    
    -- Check for auto circle loop after updating data
    checkForAutoCircleLoop()
end

local function teleportToStronghold(strongholdData)
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
        return
    end
    
    local targetPosition = strongholdData.position + Vector3.new(0, 10, 0)
    LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(targetPosition)
    
    local statusText = strongholdData.isOpen and "OPEN" or ("Opens in " .. formatStrongholdTime(strongholdData.timeLeft))
    
    Fluent:Notify({
        Title = "Teleported!",
        Content = string.format("Teleported to %s (Level %d)\nStatus: %s", 
            strongholdData.displayName, strongholdData.level, statusText),
        Duration = 4
    })
end

local function createTimerDisplay(stronghold)
    local name = stronghold.Name
    local functional = stronghold:WaitForChild("Functional")
    
    strongholds[name] = {
        instance = stronghold,
        functional = functional,
        level = functional:GetAttribute("Level") or 1,
        openTime = functional:GetAttribute("OpenTime"),
        paragraph = nil,
        isOpen = false
    }
    
    local timerText = string.format("The Cultist Stronghold (Level %d) - Loading...", strongholds[name].level)
    
    local connection = functional:GetAttributeChangedSignal("OpenTime"):Connect(function()
        strongholds[name].openTime = functional:GetAttribute("OpenTime")
        strongholds[name].level = functional:GetAttribute("Level") or 1
    end)
    
    timerConnections[name] = connection
end

local function updateTimer(name)
    local stronghold = strongholds[name]
    if not stronghold or not stronghold.openTime then return end
    
    local timeRemaining = stronghold.openTime - workspace:GetServerTimeNow()
    local timeString = convertTime(timeRemaining)
    
    local statusIcon = timeRemaining <= 0 and "Open" or "Closed"
    local levelText = string.format("Level %d", stronghold.level)
    
    if skipTimerEnabled and not hasSkippedThisSession and timeRemaining > skipTimerThreshold then
        hasSkippedThisSession = true
        local thresholdMinutes = math.floor(skipTimerThreshold / 60)
        local thresholdSeconds = skipTimerThreshold % 60
        
        Fluent:Notify({
            Title = "Skipping Stronghold",
            Content = string.format("Timer (%s) exceeds %02d:%02d threshold. Teleporting...", timeString, thresholdMinutes, thresholdSeconds),
            Duration = 3
        })
        
        task.wait(1)
        
        local success, error = pcall(function()
            TeleportService:Teleport(126509999114328)
        end)
        
        if not success then
            Fluent:Notify({
                Title = "Teleport Failed",
                Content = "Could not teleport: " .. tostring(error),
                Duration = 5
            })
        end
        
        return
    end
    
    if timeRemaining <= 0 and not stronghold.isOpen then
        stronghold.isOpen = true
        hasSkippedThisSession = false
        if notifications then
            client.Sound.Play("StrongholdEnter")
        end
        Fluent:Notify({
            Title = "Stronghold Open!",
            Content = string.format("%s is now available!", name),
            Duration = 5
        })
    elseif timeRemaining > 0 then
        stronghold.isOpen = false
    end
end

local function onStrongholdAdded(stronghold)
    if stronghold.Name ~= "AlienMothership" then
        task.spawn(function()
            createTimerDisplay(stronghold)
        end)
        
        -- Stop circle loop and check if we need to restart it
        if circleLoopActive then
            stopCircleLoop()
        end
        
        -- Check the overall situation after adding stronghold
        task.wait(1)
        checkForAutoCircleLoop()
    end
end

local function onStrongholdRemoved(stronghold)
    local name = stronghold.Name
    if strongholds[name] then
        if timerConnections[name] then
            timerConnections[name]:Disconnect()
            timerConnections[name] = nil
        end
        strongholds[name] = nil
    end
end

local function setupUpdates()
    if UpdateConnection then
        UpdateConnection:Disconnect()
    end
    
    UpdateConnection = task.spawn(function()
        while true do
            updateStrongholdsData()
            task.wait(5)
        end
    end)
end

local function cleanup()
    -- Stop circle loop
    stopCircleLoop()
    
    if UpdateConnection then
        if typeof(UpdateConnection) == "RBXScriptConnection" then
            UpdateConnection:Disconnect()
        end
        UpdateConnection = nil
    end
    
    if diamondChestConnection then
        diamondChestConnection:Disconnect()
        diamondChestConnection = nil
    end
    
    if cultistKillerConnection then
        cultistKillerConnection:Disconnect()
        cultistKillerConnection = nil
    end
    
    for _, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    Connections = {}
    
    for name, connection in pairs(timerConnections) do
        connection:Disconnect()
    end
    timerConnections = {}
end

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "Stronghold and Diamond Hub",
    SubTitle = "Automatic diamond collection with notifications",
    TabWidth = 160,
    Size = UDim2.new(0, 480, 0, 350), 
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({ Title = "Main", Icon = "gem" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

-- UI Elements
local currentDiamondsLabel, sessionGainedLabel, sessionTimeLabel, CurrentItemLabel, StrongholdStatusLabel
local TeleportDropdown

-- ======
MainTab:AddSection("======")

currentDiamondsLabel = MainTab:AddParagraph({
    Title = "Total Diamonds",
    Content = "0"
})

sessionGainedLabel = MainTab:AddParagraph({
    Title = "Diamonds Gained",
    Content = "0"
})

sessionTimeLabel = MainTab:AddParagraph({
    Title = "Time Played",
    Content = "00:00:00"
})

CurrentItemLabel = MainTab:AddParagraph({
    Title = "Equipped Item",
    Content = "Item: " .. currentEquippedItem
})

StrongholdStatusLabel = MainTab:AddParagraph({
    Title = "Stronghold Status",
    Content = "Loading..."
})

-- ======
MainTab:AddSection("======")

local autoTeleportToggle = MainTab:AddToggle("AutoTeleport", {
    Title = "Auto Teleport After Diamonds",
    Description = "Automatically teleport when diamonds are received",
    Default = false
})

autoTeleportToggle:OnChanged(function(value)
    autoTeleportEnabled = value
    
    if value then
        Fluent:Notify({
            Title = "Auto Teleport Enabled",
            Content = "Will teleport after receiving diamonds",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Auto Teleport Disabled",
            Content = "Will not teleport after diamonds",
            Duration = 2
        })
    end
end)

local testWebhookButton = MainTab:AddButton({
    Title = "Test Discord Webhook",
    Callback = function()
        if webhookUrl ~= "" then
            sendTestWebhook()
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Please configure webhook URL in Settings first",
                Duration = 3
            })
        end
    end
})

-- ======
MainTab:AddSection("======")

MainTab:AddButton({
    Title = "Teleport to Nearest Open Stronghold",
    Callback = function()
        local nearestOpen = nil
        for _, data in pairs(StrongholdsData) do
            if data.isOpen and data.distance then
                nearestOpen = data
                break
            end
        end
        
        if nearestOpen then
            teleportToStronghold(nearestOpen)
        else
            Fluent:Notify({
                Title = "No Open Strongholds",
                Content = "All strongholds are currently closed",
                Duration = 3
            })
        end
    end
})

TeleportDropdown = MainTab:AddDropdown("TeleportSelect", {
    Title = "Select Stronghold to Teleport",
    Values = {"Click Refresh Data First"},
    Multi = false,
    Callback = function(Value)
        if Value == "Click Refresh Data First" then return end
        
        local selectedData = nil
        for _, data in pairs(StrongholdsData) do
            if data.name == Value then
                selectedData = data
                break
            end
        end
        
        if selectedData then
            teleportToStronghold(selectedData)
        end
    end
})

-- ======
MainTab:AddSection("======")

MainTab:AddButton({
    Title = "Start Diamond Chest Sequence",
    Callback = function()
        local found = false
        for _, child in ipairs(Items:GetChildren()) do
            if child.Name == "Stronghold Diamond Chest" then
                found = true
                local itemPosition
                if child:IsA("Model") then
                    itemPosition = child:GetModelCFrame().Position
                elseif child:IsA("BasePart") then
                    itemPosition = child.Position
                end
                
                if itemPosition then
                    diamondChestPosition = itemPosition
                    local success, message = attemptDiamondChestTeleport()
                    if success then
                        Fluent:Notify({
                            Title = "Diamond Chest Success",
                            Content = "All phases completed successfully",
                            Duration = 5
                        })
                    else
                        Fluent:Notify({
                            Title = "Diamond Chest Failed",
                            Content = message,
                            Duration = 5
                        })
                    end
                end
                break
            end
        end
        
        if not found then
            Fluent:Notify({
                Title = "No Diamond Chest",
                Content = "No Diamond Chest currently available",
                Duration = 3
            })
        end
    end
})

local CultistKillerToggle = MainTab:AddToggle("CultistKillerToggle", {
    Title = "Enable Cultist Killer",
    Description = "Automatically attack cultist enemies",
    Default = false,
    Callback = function(Value)
        CULTIST_KILLER_ENABLED = Value
        if Value then
            setupCultistKiller()
            safeNotify("Cultist Killer Enabled", "Now automatically attacking cultist enemies", 3, "cultist_enabled")
        else
            if cultistKillerConnection then
                cultistKillerConnection:Disconnect()
                cultistKillerConnection = nil
            end
            safeNotify("Cultist Killer Disabled", "Stopped automatic cultist killing", 3, "cultist_disabled")
        end
    end
})

-- ======
MainTab:AddSection("======")

MainTab:AddButton({
    Title = "Stop Circle Search",
    Callback = function()
        if circleLoopActive then
            circleLoopActive = false -- This stops the loop immediately
            manuallyStoppedLoop = true -- Prevent auto-restart
            safeNotify("Circle Search Stopped", "Search pattern has been stopped manually", 3, "circle_manual_stop")
        else
            Fluent:Notify({
                Title = "Circle Search Inactive",
                Content = "No circle search is currently running",
                Duration = 3
            })
        end
    end
})

-- Add button to reset the manual stop flag
MainTab:AddButton({
    Title = "Enable Auto Circle Search",
    Callback = function()
        manuallyStoppedLoop = false
        safeNotify("Auto Search Enabled", "Circle search can now start automatically when needed", 3, "auto_search_enabled")
        -- Check immediately if we need to start searching
        task.wait(1)
        checkForAutoCircleLoop()
    end
})

MainTab:AddButton({
    Title = "Refresh All Data",
    Callback = function()
        updateStrongholdsData()
        updateInventory()
        
        local strongholdNames = {}
        for _, data in pairs(StrongholdsData) do
            table.insert(strongholdNames, data.name)
        end
        
        if #strongholdNames > 0 then
            TeleportDropdown:SetValues(strongholdNames)
        end
        
        safeNotify("Data Refreshed", string.format("Updated %d strongholds and %d items", #StrongholdsData, #inventoryItems), 3, "data_refresh")
    end
})

-- Settings Tab
-- ======
SettingsTab:AddSection("======")

local webhookInput = SettingsTab:AddInput("WebhookURL", {
    Title = "Discord Webhook URL",
    Default = webhookUrl,
    Placeholder = "https://discord.com/api/webhooks/...",
    Numeric = false,
    Finished = false,
    Callback = function(value)
        webhookUrl = value
        Fluent:Notify({
            Title = "Webhook Updated",
            Content = "Webhook URL has been saved",
            Duration = 2
        })
    end
})

local userIdInput = SettingsTab:AddInput("UserID", {
    Title = "Discord User ID",
    Default = userIdToPing,
    Placeholder = "123456789012345678",
    Numeric = false,
    Finished = false,
    Callback = function(value)
        userIdToPing = value
        Fluent:Notify({
            Title = "User ID Updated",
            Content = "Discord User ID has been saved",
            Duration = 2
        })
    end
})

-- ======
SettingsTab:AddSection("======")

local enableMentionsToggle = SettingsTab:AddToggle("EnableMentions", {
    Title = "Enable Everyone Mentions",
    Description = "Mention everyone in Discord notifications",
    Default = enableMentions,
    Callback = function(value)
        enableMentions = value
    end
})

local enableUserPingToggle = SettingsTab:AddToggle("EnableUserPing", {
    Title = "Enable User Ping",
    Description = "Ping specific user in Discord notifications",
    Default = enableUserPing,
    Callback = function(value)
        enableUserPing = value
    end
})

local NotificationsToggle = SettingsTab:AddToggle("Notifications", {
    Title = "Enable Game Notifications",
    Description = "Show notifications in game",
    Default = true,
    Callback = function(value)
        notifications = value
    end
})

-- ======
SettingsTab:AddSection("======")

local skipTimerOptions = {}
for minutes = 0, 20 do
    for seconds = 0, 59, 15 do
        if minutes == 0 and seconds == 0 then
            table.insert(skipTimerOptions, "Disabled")
        else
            local timeValue = minutes * 60 + seconds
            local displayText = string.format("%02d:%02d", minutes, seconds)
            table.insert(skipTimerOptions, displayText)
        end
        if minutes == 20 and seconds > 0 then break end
    end
end

local SkipTimerDropdown = SettingsTab:AddDropdown("SkipTimer", {
    Title = "Skip Stronghold Timer When Above",
    Description = "Auto teleport when stronghold timer exceeds this time",
    Values = skipTimerOptions,
    Multi = false,
    Default = 1,
    Callback = function(value)
        if value == "Disabled" then
            skipTimerEnabled = false
            skipTimerThreshold = 0
            hasSkippedThisSession = false
        else
            skipTimerEnabled = true
            local minutes, seconds = value:match("(%d+):(%d+)")
            skipTimerThreshold = tonumber(minutes) * 60 + tonumber(seconds)
            hasSkippedThisSession = false
        end
    end
})

SettingsTab:AddButton({
    Title = "Reset Skip Status",
    Callback = function()
        hasSkippedThisSession = false
        Fluent:Notify({
            Title = "Skip Status Reset",
            Content = "Skip teleport can now trigger again",
            Duration = 3
        })
    end
})

-- ======
SettingsTab:AddSection("======")

local helpButton = SettingsTab:AddButton({
    Title = "Copy Discord User ID Instructions",
    Callback = function()
        setclipboard("1. Enable Developer Mode in Discord (Settings > Advanced > Developer Mode)\n2. Right-click on any user\n3. Click 'Copy User ID'\n4. Paste the ID in the field above")
        Fluent:Notify({
            Title = "Instructions Copied",
            Content = "Instructions copied to clipboard",
            Duration = 3
        })
    end
})

-- ======
SettingsTab:AddSection("======")

SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("StrongholdHub/configs")

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({
    "currentDiamondsLabel",
    "sessionGainedLabel", 
    "sessionTimeLabel",
    "CurrentItemLabel"
})

SaveManager:BuildConfigSection(SettingsTab)

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("StrongholdHub")
InterfaceManager:BuildInterfaceSection(SettingsTab)

-- Initialize and setup functions
local function initialize()
    for _, stronghold in pairs(CollectionService:GetTagged("Stronghold")) do
        onStrongholdAdded(stronghold)
    end
    
    CollectionService:GetInstanceAddedSignal("Stronghold"):Connect(onStrongholdAdded)
    CollectionService:GetInstanceRemovedSignal("Stronghold"):Connect(onStrongholdRemoved)
    
    -- Diamond tracking
    LocalPlayer.AttributeChanged:Connect(function(attribute)
        if attribute == "Diamonds" then
            task.wait(0.5)
            onDiamondsChanged()
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        for name, _ in pairs(strongholds) do
            updateTimer(name)
        end
        
        -- Update current equipped item display
        getCurrentEquipped()
        CurrentItemLabel:SetDesc("Item: " .. currentEquippedItem)
        
        -- Update stronghold status display
        local strongholdText = ""
        if #StrongholdsData == 0 then
            strongholdText = "No strongholds found"
        else
            -- Show up to 3 strongholds to avoid too much text
            local displayCount = math.min(3, #StrongholdsData)
            for i = 1, displayCount do
                local data = StrongholdsData[i]
                local status = data.isOpen and "OPEN" or formatStrongholdTime(data.timeLeft)
                local distance = data.distance and string.format("%.0fm %s", data.distance, data.compassDir) or "Unknown"
                local statusIcon = data.isOpen and "[OPEN]" or "[CLOSED]"
                
                strongholdText = strongholdText .. string.format("%s %s (L%d): %s | %s", 
                    statusIcon, data.name, data.level, status, distance)
                if i < displayCount then strongholdText = strongholdText .. "\n" end
            end
            
            if #StrongholdsData > 3 then
                strongholdText = strongholdText .. string.format("\n... and %d more", #StrongholdsData - 3)
            end
        end
        StrongholdStatusLabel:SetDesc(strongholdText)
        
        -- Update diamond and session info
        currentDiamondsLabel:SetDesc(tostring(currentDiamonds))
        sessionGainedLabel:SetDesc("+" .. tostring(sessionGained))
        
        local elapsedTime = tick() - startTime
        sessionTimeLabel:SetDesc(formatTime(elapsedTime))
    end)
    
    if client.Events and client.Events.StrongholdComplete then
        client.Events.StrongholdComplete:Connect(function(inFortress)
            if inFortress then
                Fluent:Notify({
                    Title = "Stronghold Completed!",
                    Content = "Great job! The stronghold will reopen later.",
                    Duration = 5
                })
            end
        end)
    end
    
    -- Auto refresh inventory every 10 seconds
    task.spawn(function()
        while true do
            task.wait(10)
            updateInventory()
        end
    end)
end

-- Main initialization
task.spawn(function()
    task.wait(3)
    
    -- Initialize diamond tracking
    initialDiamonds = getCurrentDiamonds()
    currentDiamonds = initialDiamonds
    
    setupEnhancedDiamondChestDetection()
    updateStrongholdsData()
    updateInventory()
    setupUpdates()
    initialize()
    
    local strongholdNames = {}
    for _, data in pairs(StrongholdsData) do
        table.insert(strongholdNames, data.name)
    end
    
    if #strongholdNames > 0 then
        TeleportDropdown:SetValues(strongholdNames)
    end
    
    if gameDetected then
        safeNotify("Enhanced Hub Loaded!", 
                  string.format("Stronghold + Diamond tracking enabled! Found %d strongholds", #StrongholdsData), 
                  5, 
                  "hub_loaded")
    else
        safeNotify("Warning", "Game may not be supported", 5, "game_warning")
    end
    
    -- Initial check for auto circle loop - this will automatically start if needed
    task.wait(2)
    checkForAutoCircleLoop()
end)

-- Auto-load config
task.spawn(function()
    task.wait(0.5)
    
    local success, err = pcall(function()
        if SaveManager.LoadAutoloadConfig then
            SaveManager:LoadAutoloadConfig()
        else
            local configs = SaveManager:GetConfigs()
            if configs and #configs > 0 then
                SaveManager:LoadConfig(configs[1])
            end
        end
    end)
    
    if success then
        Fluent:Notify({
            Title = "Config Loaded",
            Content = "Previous settings have been restored!",
            Duration = 3
        })
    else
        print("No previous config found or failed to load:", err)
    end
end)

game:BindToClose(cleanup)
