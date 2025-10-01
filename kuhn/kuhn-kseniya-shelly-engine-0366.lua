-- StrongholdModule.lua - Upload this to your GitHub repository
local Module = {}

-- Services
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

-- Variables
Module.webhookUrl = ""
Module.userIdToPing = ""
Module.currentDiamonds = 0
Module.sessionGained = 0
Module.initialDiamonds = 0
Module.startTime = tick()
Module.lastDiamondNotificationTime = 0
Module.autoTeleportEnabled = false
Module.enableMentions = true
Module.enableUserPing = false

Module.circleLoopActive = false
Module.circleLoopConnection = nil
Module.noStrongholdFallbackEnabled = false
Module.manuallyStoppedLoop = false

Module.CULTIST_KILLER_ENABLED = false
Module.cultistKillerConnection = nil
Module.lastCultistKillTime = 0
Module.CULTIST_KILL_COOLDOWN = 1
Module.diamondChestConnection = nil
Module.diamondChestDetected = false
Module.diamondChestPosition = nil
Module.teleportAttemptCount = 0
Module.maxTeleportAttempts = 3
Module.lastTeleportAttemptTime = 0
Module.teleportCooldown = 2

Module.inventoryItems = {}
Module.currentEquippedItem = "None"

Module.hotkeys = {
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

Module.STRONGHOLD_COLORS = {
    Color3.fromRGB(195, 255, 0),
    Color3.fromRGB(255, 238, 0),
    Color3.fromRGB(255, 157, 0),
    Color3.fromRGB(255, 64, 0),
    Color3.fromRGB(255, 0, 0)
}

Module.StrongholdsData = {}
Module.Connections = {}
Module.UpdateConnection = nil
Module.lastOpenStrongholds = {}
Module.lastNotificationTime = {}
Module.NOTIFICATION_COOLDOWN = 30

Module.strongholds = {}
Module.timerConnections = {}
Module.notifications = true
Module.skipTimerEnabled = false
Module.skipTimerThreshold = 0
Module.hasSkippedThisSession = false

Module.Fluent = nil

-- Utility Functions
function Module.safeNotify(title, content, duration, notificationKey)
    if not Module.Fluent then return end
    
    duration = duration or 3
    notificationKey = notificationKey or (title .. content)
    
    local currentTime = tick()
    
    if Module.lastNotificationTime[notificationKey] and (currentTime - Module.lastNotificationTime[notificationKey]) < Module.NOTIFICATION_COOLDOWN then
        return
    end
    
    Module.lastNotificationTime[notificationKey] = currentTime
    
    Module.Fluent:Notify({
        Title = title,
        Content = content,
        Duration = duration
    })
end

function Module.getCurrentDiamonds()
    if LocalPlayer:GetAttribute("Diamonds") then
        return LocalPlayer:GetAttribute("Diamonds")
    end
    return 0
end

function Module.formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function Module.createDiscordEmbed(diamondsGained)
    local embed = {
        title = "Diamond Alert!",
        description = string.format("**%s** just gained diamonds!", LocalPlayer.Name),
        color = 3447003,
        fields = {
            {
                name = "Current Diamonds",
                value = string.format("```%s```", tostring(Module.currentDiamonds)),
                inline = true
            },
            {
                name = "Diamonds Gained",
                value = string.format("```+%s```", tostring(diamondsGained)),
                inline = true
            },
            {
                name = "Session Total",
                value = string.format("```+%s```", tostring(Module.sessionGained)),
                inline = true
            },
            {
                name = "Session Time",
                value = string.format("```%s```", Module.formatTime(tick() - Module.startTime)),
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

function Module.sendWebhook(diamondsGained)
    if Module.webhookUrl == "" then return end
    
    local embed = Module.createDiscordEmbed(diamondsGained)
    local content = ""
    
    if Module.enableMentions then
        content = "@everyone"
    elseif Module.enableUserPing and Module.userIdToPing ~= "" then
        content = "<@" .. Module.userIdToPing .. ">"
    end
    
    local data = {
        content = content,
        username = "Diamond Tracker",
        avatar_url = "https://media.discordapp.net/attachments/1400825424535224511/1420864823675060275/2Q.png",
        embeds = {embed}
    }
    
    local success, response = pcall(function()
        return http_request({
            Url = Module.webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success and response.StatusCode == 204 then
        Module.safeNotify("Webhook Sent", string.format("Notified about +%d diamonds!", diamondsGained), 3, "webhook_sent")
    else
        Module.safeNotify("Webhook Failed", "Failed to send webhook message", 3, "webhook_failed")
    end
end

function Module.sendTestWebhook()
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
            Url = Module.webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success and response.StatusCode == 204 then
        Module.safeNotify("Test Successful", "Webhook is configured correctly!", 3, "test_success")
    else
        Module.safeNotify("Test Failed", "Webhook configuration error", 3, "test_failed")
    end
end

function Module.onDiamondsChanged()
    local newDiamonds = Module.getCurrentDiamonds()
    local currentTime = tick()
    
    if currentTime - Module.lastDiamondNotificationTime < 1 then
        return
    end
    
    if newDiamonds > Module.currentDiamonds then
        local diamondsGained = newDiamonds - Module.currentDiamonds
        Module.lastDiamondNotificationTime = currentTime
        
        Module.sessionGained = newDiamonds - Module.initialDiamonds
        
        Module.sendWebhook(diamondsGained)
        
        Module.safeNotify("Diamonds Gained!", string.format("You gained %d diamonds!", diamondsGained), 2, "diamonds_gained")
        
        if Module.autoTeleportEnabled then
            task.spawn(function()
                task.wait(3)
                TeleportService:Teleport(126509999114328)
            end)
        end
    end
    
    Module.currentDiamonds = newDiamonds
end

function Module.updateInventory()
    Module.inventoryItems = {}
    
    local inventory = LocalPlayer:FindFirstChild("Inventory")
    if inventory then
        for i, item in pairs(inventory:GetChildren()) do
            if item:IsA("Model") or item:IsA("Tool") then
                table.insert(Module.inventoryItems, {
                    name = item.Name,
                    slot = i,
                    object = item
                })
            end
        end
    end
end

function Module.getCurrentEquipped()
    local character = LocalPlayer.Character
    if character then
        local toolHandle = character:FindFirstChild("ToolHandle")
        if toolHandle then
            local originalItem = toolHandle:FindFirstChild("OriginalItem")
            if originalItem and originalItem.Value then
                Module.currentEquippedItem = originalItem.Value.Name
                return
            end
        end
        
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            Module.currentEquippedItem = tool.Name
            return
        end
    end
    
    Module.currentEquippedItem = "None"
end

local function isAllowedWeapon(weaponName)
    local name = string.lower(weaponName)
    return string.find(name, "axe") or 
           string.find(name, "sword") or 
           string.find(name, "spear") or
           string.find(name, "morning star")
end

function Module.ensureProperWeaponEquipped()
    Module.updateInventory()
    
    local slotsToTry = {2, 1, 3, 4, 5}
    
    for _, slotNum in pairs(slotsToTry) do
        local keyCode = Module.hotkeys[slotNum]
        if keyCode then
            game:GetService("VirtualInputManager"):SendKeyEvent(true, keyCode, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, keyCode, false, game)
            task.wait(0.5)
            
            Module.getCurrentEquipped()
            
            if Module.currentEquippedItem ~= "None" and isAllowedWeapon(Module.currentEquippedItem) then
                Module.safeNotify("Fallback Equipped", "Equipped " .. Module.currentEquippedItem .. " from slot " .. slotNum, 3, "auto_equip_fallback")
                return true
            end
        end
    end
    
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Two, false, game)
    task.wait(0.5)
    
    Module.getCurrentEquipped()
    if Module.currentEquippedItem ~= "None" then
        Module.safeNotify("Fallback Equipped", "Equipped " .. Module.currentEquippedItem .. " from slot 2", 3, "auto_equip_final")
    else
        Module.safeNotify("No Weapon Equipped", "Could not find suitable weapon - proceeding anyway", 3, "no_weapon_warning")
    end
    
    return true
end

local function doSingleCircleLoop(r, o, v)
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local rootPart = character.HumanoidRootPart
    local angle = 0
    local fullCircle = 2 * math.pi
    local startTime = tick()
    
    while angle < fullCircle and Module.circleLoopActive do
        local deltaTime = task.wait()
        if tick() - startTime > 300 then
            break
        end
        
        if not Module.circleLoopActive then
            break
        end
        
        angle = math.min(angle + (v * deltaTime), fullCircle)
        local x = o.X + r * math.cos(angle)
        local z = o.Z + r * math.sin(angle)
        local newPosition = Vector3.new(x, o.Y, z)
        rootPart.CFrame = CFrame.new(newPosition)
    end
    
    return Module.circleLoopActive
end

function Module.startCircleLoopFallback()
    if Module.circleLoopActive or Module.manuallyStoppedLoop then
        return
    end
    
    Module.circleLoopActive = true
    Module.safeNotify("Circle Loop Started", "Searching for strongholds/diamond chest - will continue until found", 5, "circle_start")
    
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
        
        while Module.circleLoopActive do
            cycleCount = cycleCount + 1
            
            for i, v in ipairs(radius_list) do
                if not Module.circleLoopActive then
                    break
                end
                
                local success = doSingleCircleLoop(v, Vector3.new(0, 15, 0), 1/(2*i))
                if not success then
                    break
                end
                
                local strongholdCount = #CollectionService:GetTagged("Stronghold")
                local diamondChestExists = workspace.Items:FindFirstChild("Stronghold Diamond Chest") ~= nil
                
                if strongholdCount > 0 or diamondChestExists then
                    local reason = strongholdCount > 0 and string.format("Found %d strongholds", strongholdCount) or "Diamond chest detected"
                    Module.safeNotify("Target Found!", reason .. " - stopping circle loop after " .. cycleCount .. " cycles", 5, "target_found")
                    Module.circleLoopActive = false
                    Module.noStrongholdFallbackEnabled = false
                    break
                end
                
                task.wait(1)
            end
            
            if Module.circleLoopActive then
                Module.safeNotify("Search Cycle Complete", string.format("Cycle %d complete - continuing search...", cycleCount), 3, "cycle_complete_" .. cycleCount)
                task.wait(3)
            end
        end
        
        Module.circleLoopActive = false
    end)
end

function Module.stopCircleLoop()
    Module.circleLoopActive = false
    Module.manuallyStoppedLoop = true
    
    if Module.circleLoopConnection then
        Module.circleLoopConnection:Disconnect()
        Module.circleLoopConnection = nil
    end
    
    Module.safeNotify("Circle Loop Stopped", "Search pattern has been stopped and won't auto-restart", 3, "circle_stop")
end

function Module.checkForAutoCircleLoop()
    if Module.manuallyStoppedLoop then
        return
    end
    
    local strongholdCount = #CollectionService:GetTagged("Stronghold")
    local diamondChestExists = workspace.Items:FindFirstChild("Stronghold Diamond Chest") ~= nil
    
    if strongholdCount == 0 and not diamondChestExists and not Module.circleLoopActive then
        Module.safeNotify("No Strongholds or Diamond Chest", "Auto-starting circle loop search pattern", 5, "auto_circle_start")
        Module.noStrongholdFallbackEnabled = true
        Module.startCircleLoopFallback()
    elseif (strongholdCount > 0 or diamondChestExists) and Module.circleLoopActive then
        local reason = strongholdCount > 0 and string.format("Found %d strongholds", strongholdCount) or "Diamond chest detected"
        Module.safeNotify("Targets Found", reason .. " - stopping circle loop", 5, "targets_found")
        Module.circleLoopActive = false
        Module.manuallyStoppedLoop = false
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

local function findValidWeapon()
    for _, weapon in pairs(LocalPlayer:WaitForChild("Inventory"):GetChildren()) do
        if isAllowedWeapon(weapon.Name) then
            return weapon
        end
    end
    return nil
end

local function isCultist(name)
    return string.find(string.lower(name), "cultist") ~= nil
end

local function attackWithWeapon(weapon)
    if not weapon or not weapon.Parent then
        return 0
    end
    
    local attackCount = 0
    local successfulAttacks = 0
    
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

function Module.setupCultistKiller()
    if Module.cultistKillerConnection then
        Module.cultistKillerConnection:Disconnect()
    end
    
    if not Module.CULTIST_KILLER_ENABLED then
        return
    end
    
    Module.cultistKillerConnection = RunService.Heartbeat:Connect(function()
        if Module.CULTIST_KILLER_ENABLED and tick() - Module.lastCultistKillTime >= Module.CULTIST_KILL_COOLDOWN then
            local damaged = killCultistsOnce()
            if damaged > 0 then
                Module.lastCultistKillTime = tick()
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

function Module.executeDiamondChestSequence()
    pcall(function()
        Module.ensureProperWeaponEquipped()
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

        local function checkForNearbyCultists()
            local cultistsFound = {}
            local playerPosition = HumanoidRootPart.Position
            local searchRadius = 100
            
            if workspace:FindFirstChild("Characters") then
                for _, target in pairs(workspace.Characters:GetChildren()) do
                    if target ~= LocalPlayer.Character and target:FindFirstChild("NPC") and target:HasTag("NPC") then
                        if isCultist(target.Name) then
                            local targetPosition = getPos(target)
                            if targetPosition and (targetPosition - playerPosition).Magnitude <= searchRadius then
                                table.insert(cultistsFound, target)
                            end
                        end
                    end
                end
            end
            
            if workspace:FindFirstChild("Map") then
                for _, enemy in pairs(workspace.Map:GetDescendants()) do
                    if enemy:IsA("Model") and enemy ~= LocalPlayer.Character then
                        if isCultist(enemy.Name) then
                            local targetPosition = getPos(enemy)
                            if targetPosition and (targetPosition - playerPosition).Magnitude <= searchRadius then
                                table.insert(cultistsFound, enemy)
                            end
                        end
                    end
                end
            end
            
            for _, enemy in pairs(workspace:GetChildren()) do
                if enemy:IsA("Model") and enemy ~= LocalPlayer.Character then
                    if isCultist(enemy.Name) then
                        local targetPosition = getPos(enemy)
                        if targetPosition and (targetPosition - playerPosition).Magnitude <= searchRadius then
                            table.insert(cultistsFound, enemy)
                        end
                    end
                end
            end
            
            return cultistsFound
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
        
        local nearbyCultists = checkForNearbyCultists()
        if #nearbyCultists > 0 then
            Module.safeNotify("CULTISTS DETECTED!", 
                      string.format("Found %d cultists nearby! Skipping pathfinding, starting auto-kill!", #nearbyCultists), 
                      5, 
                      "cultists_detected_skip")
            
            Module.CULTIST_KILLER_ENABLED = true
            Module.setupCultistKiller()
            
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
                        
                        Module.CULTIST_KILLER_ENABLED = false
                        if Module.cultistKillerConnection then
                            Module.cultistKillerConnection:Disconnect()
                            Module.cultistKillerConnection = nil
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
            
            local function tweenToNextWaypoint()
                if currentIndex > #waypoints then
                    return
                end
                
                local wp = waypoints[currentIndex]
                local direction = wp.Position - root.Position
                local distance = direction.Magnitude
                
                local distanceToFinalTarget = (root.Position - targetPos).Magnitude
                
                if distanceToFinalTarget <= 8 then
                    local finalTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local finalTween = TweenService:Create(root, finalTweenInfo, {CFrame = CFrame.new(targetPos)})
                    
                    finalTween:Play()
                    finalTween.Completed:Wait()
                    return
                end
                
                if distance < 4 then
                    currentIndex = currentIndex + 1
                    tweenToNextWaypoint()
                else
                    local tweenTime = distance / 100
                    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(wp.Position)})
                    
                    tween:Play()
                    tween.Completed:Wait()
                    
                    currentIndex = currentIndex + 1
                    tweenToNextWaypoint()
                end
            end
            
            tweenToNextWaypoint()
            
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
                    if currentDistance <= 15 then
                        print("✅ Close enough to shelf! Distance: " .. math.floor(currentDistance) .. " - stopping attempts")
                        break
                    end
                end
                task.wait(1)
            end
            
            local finalDistance = (HumanoidRootPart.Position - shelfPos).Magnitude
            if finalDistance <= 15 then
                Module.CULTIST_KILLER_ENABLED = true
                Module.setupCultistKiller()
                
                local strongholdChest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
                if strongholdChest then
                    local chestPosition
                    if strongholdChest:IsA("Model") then
                        chestPosition = strongholdChest:GetModelCFrame().Position
                    elseif strongholdChest:IsA("BasePart") then
                        chestPosition = strongholdChest.Position
                    end
                    
                    if chestPosition then
                        HumanoidRootPart.CFrame = CFrame.new(chestPosition + Vector3.new(0, 5, 0))
                    end
                end
            end
        end

        for _, item in pairs(workspace.Items:GetChildren()) do
            pcall(function()
                require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
            end)
        end
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

function Module.attemptDiamondChestTeleport()
    if not Module.diamondChestPosition then
        return false, "No diamond chest position stored"
    end
    
    local success, message = teleportToPosition(Module.diamondChestPosition + Vector3.new(0, 5, 0))
    if not success then
        return false, message
    end
    
    task.wait(1)
    Module.executeDiamondChestSequence()
    task.wait(1)
    
    local finalSuccess, finalMessage = teleportToPosition(Module.diamondChestPosition + Vector3.new(0, 5, 0))
    
    if finalSuccess then
        return true, "Diamond chest sequence completed successfully"
    else
        return false, "Final teleport failed: " .. finalMessage
    end
end

function Module.setupEnhancedDiamondChestDetection()
    if Module.diamondChestConnection then
        Module.diamondChestConnection:Disconnect()
    end
    
    Module.diamondChestConnection = Items.ChildAdded:Connect(function(child)
        if child.Name == "Stronghold Diamond Chest" then
            if child:IsA("Model") then
                Module.diamondChestPosition = child:GetModelCFrame().Position
            elseif child:IsA("BasePart") then
                Module.diamondChestPosition = child.Position
            end
            
            Module.diamondChestDetected = true
            Module.teleportAttemptCount = 0
            
            if Module.circleLoopActive then
                Module.stopCircleLoop()
            end
            
            Module.safeNotify("DIAMOND CHEST DETECTED!", "Starting enhanced teleport sequence immediately!", 5, "chest_detected")
            
            task.spawn(function()
                task.wait(1)
                local success, message = Module.attemptDiamondChestTeleport()
                if success then
                    Module.safeNotify("Auto Diamond Chest Complete!", "Successfully completed diamond chest sequence!", 5, "chest_complete")
                else
                    Module.safeNotify("Auto Diamond Chest Failed", message, 5, "chest_failed")
                end
            end)
        end
    end)
    
    Items.ChildRemoved:Connect(function(child)
        if child.Name == "Stronghold Diamond Chest" then
            Module.diamondChestDetected = false
            Module.diamondChestPosition = nil
            
            task.wait(2)
            Module.checkForAutoCircleLoop()
        end
    end)
    
    for _, child in ipairs(Items:GetChildren()) do
        if child.Name == "Stronghold Diamond Chest" and not Module.diamondChestDetected then
            if child:IsA("Model") then
                Module.diamondChestPosition = child:GetModelCFrame().Position
            elseif child:IsA("BasePart") then
                Module.diamondChestPosition = child.Position
            end
            
            Module.diamondChestDetected = true
            Module.teleportAttemptCount = 0
            
            if Module.circleLoopActive then
                Module.stopCircleLoop()
            end
            
            Module.safeNotify("DIAMOND CHEST ALREADY AVAILABLE!", "Auto-starting enhanced sequence!", 5, "chest_existing")
            
            task.spawn(function()
                task.wait(1)
                local success, message = Module.attemptDiamondChestTeleport()
                if success then
                    Module.safeNotify("Auto Diamond Chest Complete!", "Successfully completed diamond chest sequence!", 5, "chest_complete")
                else
                    Module.safeNotify("Auto Diamond Chest Failed", message, 5, "chest_failed")
                end
            end)
            break
        end
    end
end

function Module.getStrongholdInfo(stronghold)
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
        levelColor = Module.STRONGHOLD_COLORS[level] or Module.STRONGHOLD_COLORS[5],
        openTime = openTime,
        isOpen = isOpen,
        timeLeft = math.max(0, timeLeft),
        position = position,
        stronghold = stronghold,
        distance = nil,
        compassDir = nil
    }
end

function Module.calculateDistanceAndDirection(targetPos)
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

function Module.formatStrongholdTime(seconds)
    if seconds <= 60 then
        return string.format("%02ds", math.floor(seconds))
    else
        local minutes = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02dm %02ds", minutes, secs)
    end
end

function Module.convertTime(seconds)
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

function Module.updateStrongholdsData()
    Module.StrongholdsData = {}
    
    local strongholds_list = CollectionService:GetTagged("Stronghold")
    
    for _, stronghold in pairs(strongholds_list) do
        if stronghold.Name ~= "AlienMothership" then
            local data = Module.getStrongholdInfo(stronghold)
            if data then
                local distance, compassDir = Module.calculateDistanceAndDirection(data.position)
                data.distance = distance
                data.compassDir = compassDir
                table.insert(Module.StrongholdsData, data)
                
                local strongholdKey = data.name .. "_" .. data.level
                local previouslyOpen = Module.lastOpenStrongholds[strongholdKey]
                
                if data.isOpen and not previouslyOpen then
                    Module.lastOpenStrongholds[strongholdKey] = true
                    
                    local strongholdChest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
                    
                    if strongholdChest then
                        Module.safeNotify("STRONGHOLD & CHEST DETECTED!", 
                                  string.format("%s (Level %d) opened with diamond chest! Starting sequence...", 
                                                data.displayName, data.level), 
                                  5, 
                                  "stronghold_chest_" .. strongholdKey)
                        
                        task.spawn(function()
                            task.wait(2)
                            
                            if strongholdChest:IsA("Model") then
                                Module.diamondChestPosition = strongholdChest:GetModelCFrame().Position
                            elseif strongholdChest:IsA("BasePart") then
                                Module.diamondChestPosition = strongholdChest.Position
                            end
                            
                            local success, message = Module.attemptDiamondChestTeleport()
                            if success then
                                Module.safeNotify("Stronghold Auto Complete!", 
                                          "Successfully completed diamond chest sequence for opened stronghold!", 
                                          5, 
                                          "stronghold_success_" .. strongholdKey)
                            else
                                Module.safeNotify("Stronghold Auto Failed", message, 5, "stronghold_fail_" .. strongholdKey)
                            end
                        end)
                    end
                    
                elseif not data.isOpen and previouslyOpen then
                    Module.lastOpenStrongholds[strongholdKey] = false
                end
            end
        end
    end
    
    table.sort(Module.StrongholdsData, function(a, b)
        if not a.distance then return false end
        if not b.distance then return true end
        return a.distance < b.distance
    end)
    
    Module.checkForAutoCircleLoop()
end

function Module.teleportToStronghold(strongholdData)
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
        return
    end
    
    local targetPosition = strongholdData.position + Vector3.new(0, 10, 0)
    LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(targetPosition)
    
    local statusText = strongholdData.isOpen and "OPEN" or ("Opens in " .. Module.formatStrongholdTime(strongholdData.timeLeft))
    
    Module.safeNotify("Teleported!", string.format("Teleported to %s (Level %d)\nStatus: %s", 
        strongholdData.displayName, strongholdData.level, statusText), 4, "teleport_success")
end

function Module.createTimerDisplay(stronghold)
    local name = stronghold.Name
    local functional = stronghold:WaitForChild("Functional")
    
    Module.strongholds[name] = {
        instance = stronghold,
        functional = functional,
        level = functional:GetAttribute("Level") or 1,
        openTime = functional:GetAttribute("OpenTime"),
        paragraph = nil,
        isOpen = false
    }
    
    local connection = functional:GetAttributeChangedSignal("OpenTime"):Connect(function()
        Module.strongholds[name].openTime = functional:GetAttribute("OpenTime")
        Module.strongholds[name].level = functional:GetAttribute("Level") or 1
    end)
    
    Module.timerConnections[name] = connection
end

function Module.updateTimer(name)
    local stronghold = Module.strongholds[name]
    if not stronghold or not stronghold.openTime then return end
    
    local timeRemaining = stronghold.openTime - workspace:GetServerTimeNow()
    local timeString = Module.convertTime(timeRemaining)
    
    if Module.skipTimerEnabled and not Module.hasSkippedThisSession and timeRemaining > Module.skipTimerThreshold then
        Module.hasSkippedThisSession = true
        local thresholdMinutes = math.floor(Module.skipTimerThreshold / 60)
        local thresholdSeconds = Module.skipTimerThreshold % 60
        
        Module.safeNotify("Skipping Stronghold", string.format("Timer (%s) exceeds %02d:%02d threshold. Teleporting...", timeString, thresholdMinutes, thresholdSeconds), 3, "skip_threshold")
        
        task.wait(1)
        
        local success, error = pcall(function()
            TeleportService:Teleport(126509999114328)
        end)
        
        if not success then
            Module.safeNotify("Teleport Failed", "Could not teleport: " .. tostring(error), 5, "teleport_error")
        end
        
        return
    end
    
    if timeRemaining <= 0 and not stronghold.isOpen then
        stronghold.isOpen = true
        Module.hasSkippedThisSession = false
        if Module.notifications then
            client.Sound.Play("StrongholdEnter")
        end
        Module.safeNotify("Stronghold Open!", string.format("%s is now available!", name), 5, "stronghold_open_" .. name)
    elseif timeRemaining > 0 then
        stronghold.isOpen = false
    end
end

function Module.onStrongholdAdded(stronghold)
    if stronghold.Name ~= "AlienMothership" then
        task.spawn(function()
            Module.createTimerDisplay(stronghold)
        end)
        
        if Module.circleLoopActive then
            Module.stopCircleLoop()
        end
        
        task.wait(1)
        Module.checkForAutoCircleLoop()
    end
end

function Module.onStrongholdRemoved(stronghold)
    local name = stronghold.Name
    if Module.strongholds[name] then
        if Module.timerConnections[name] then
            Module.timerConnections[name]:Disconnect()
            Module.timerConnections[name] = nil
        end
        Module.strongholds[name] = nil
    end
end

function Module.setupUpdates()
    if Module.UpdateConnection then
        Module.UpdateConnection:Disconnect()
    end
    
    Module.UpdateConnection = task.spawn(function()
        while true do
            Module.updateStrongholdsData()
            task.wait(5)
        end
    end)
end

function Module.cleanup()
    Module.stopCircleLoop()
    
    if Module.UpdateConnection then
        if typeof(Module.UpdateConnection) == "RBXScriptConnection" then
            Module.UpdateConnection:Disconnect()
        end
        Module.UpdateConnection = nil
    end
    
    if Module.diamondChestConnection then
        Module.diamondChestConnection:Disconnect()
        Module.diamondChestConnection = nil
    end
    
    if Module.cultistKillerConnection then
        Module.cultistKillerConnection:Disconnect()
        Module.cultistKillerConnection = nil
    end
    
    for _, connection in pairs(Module.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    Module.Connections = {}
    
    for name, connection in pairs(Module.timerConnections) do
        connection:Disconnect()
    end
    Module.timerConnections = {}
end

return Module
