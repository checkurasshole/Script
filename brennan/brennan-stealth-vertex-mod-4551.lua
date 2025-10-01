-- StrongholdModule.lua - Upload this to your GitHub repository
local Module = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Items = workspace:WaitForChild("Items")

-- Settings
local HEIGHT_OFFSET = 10
local SCATTER_RANGE = 5
local BRING_SPEED = 0.05
local FUEL_ITEMS = {"Log", "Fuel Canister", "Oil Barrel", "Biofuel", "Coal", "Chainsaw"}
local FIRE_LEVELS = {
    {min = 1.19, max = 3.94, minInner = 0.81, maxInner = 2.8, range = 25},
    {min = 1.19, max = 3.94, minInner = 0.81, maxInner = 2.8, range = 35},
    {min = 1.19, max = 4.32, minInner = 0.81, maxInner = 3, range = 45},
    {min = 1.19, max = 4.32, minInner = 0.81, maxInner = 3, range = 50},
    {min = 1.19, max = 5.83, minInner = 0.81, maxInner = 3.4, range = 55},
    {min = 1.19, max = 9.26, minInner = 0.81, maxInner = 5.2, range = 60}
}
local FALLBACK_POSITIONS = {
    CFrame.new(123.113708, 1.03243303, -328.113556, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(245.338486, -8.13047695, -202.074432, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(230.796982, -2.93100095, 40.3914032, 0, 0, 1, 0, 1, -0, -1, 0, 0)
}
local STOP_LOG_COLLECTION = false
local isFullyRevealed = false
local currentLevel = 0
local AUTO_FARM_ENABLED = false
local DIAMOND_CHEST_DETECTION = true
local CULTIST_KILLER_ENABLED = false
local cultistKillerConnection
local lastCultistKillTime = 0
local CULTIST_KILL_COOLDOWN = 1
local ANTI_VOID_ENABLED = true
local OrgDestroyHeight = workspace.FallenPartsDestroyHeight
local antivoidloop = nil
local diamondChestConnection = nil
local diamondChestDetected = false
local diamondChestPosition = nil
local teleportAttemptCount = 0
local maxTeleportAttempts = 3
local lastTeleportAttemptTime = 0
local teleportCooldown = 5
local MainFire = nil
local FireData = {}
local currentFallbackIndex = 1
local stopTweening = false
local visitedParts = {}
local fogClearingComplete = false
local stopMapUnlocking = false
local mapUnlockVisitedParts = {}
local strongholdTimerActive = false
local lastBodyText = ""
local lastLevelText = ""
local axeEquipped = false
local lastEquipTime = 0
local childrenCollectionComplete = false
local childCollectionAttempts = 0
local maxChildCollectionAttempts = 3
local rainDetectionActive = false
local isRaining = false
local lastRainCheck = 0
local GITHUB_SCRIPT_LOADED = false
local TIMER_FINISHED_EXECUTED = false
local EXTERNAL_SCRIPT_URL = "https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/K/papaa-quebec-romeo-0140.txt"
local SCRIPT_EXECUTED = false
local FIRST_EXECUTION_CHECK = true
local ALL_PHASES_COMPLETED = false

function Module.getTargetPositionForFuel()
    local basePos
    local success, outer = pcall(function()
        return workspace.Map.Campground.MainFire.OuterTouchZone
    end)
    if success and outer then
        basePos = outer.Position
    end
    if not basePos then
        basePos = Module.getMainFirePosition()
    end
    return Vector3.new(basePos.X, basePos.Y + HEIGHT_OFFSET, basePos.Z)
end

function Module.isInCategory(itemName, category)
    for _, item in ipairs(category) do
        if itemName == item then return true end
    end
    return false
end

function Module.getPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local part = obj:FindFirstChildWhichIsA("BasePart")
        return part and part.Position or obj:GetPivot().Position
    end
end

function Module.killCultistsOnce()
    local damaged = 0
    local targetNPCs = {"Cultist", "Crossbow Cultist"}
    for _, weapon in pairs(LocalPlayer:WaitForChild("Inventory"):GetChildren()) do
        if string.find(string.lower(weapon.Name), "axe") or 
           string.find(string.lower(weapon.Name), "sword") or 
           string.find(string.lower(weapon.Name), "spear") then
            if workspace:FindFirstChild("Characters") then
                for _, enemy in pairs(workspace.Characters:GetChildren()) do
                    if enemy ~= LocalPlayer.Character then
                        for _, targetName in pairs(targetNPCs) do
                            if enemy.Name == targetName then
                                task.spawn(function()
                                    pcall(function()
                                        ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                            enemy, weapon, "1_" .. LocalPlayer.UserId, HumanoidRootPart.CFrame
                                        )
                                        damaged = damaged + 1
                                    end)
                                end)
                                break
                            end
                        end
                    end
                end
            end
            if workspace:FindFirstChild("Map") then
                for _, enemy in pairs(workspace.Map:GetDescendants()) do
                    if enemy:IsA("Model") and enemy ~= LocalPlayer.Character then
                        for _, targetName in pairs(targetNPCs) do
                            if enemy.Name == targetName then
                                task.spawn(function()
                                    pcall(function()
                                        ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                            enemy, weapon, "1_" .. LocalPlayer.UserId, HumanoidRootPart.CFrame
                                        )
                                        damaged = damaged + 1
                                    end)
                                end)
                                break
                            end
                        end
                    end
                end
            end
            for _, enemy in pairs(workspace:GetChildren()) do
                if enemy:IsA("Model") and enemy ~= LocalPlayer.Character then
                    for _, targetName in pairs(targetNPCs) do
                        if enemy.Name == targetName then
                            task.spawn(function()
                                pcall(function()
                                    ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                        enemy, weapon, "1_" .. LocalPlayer.UserId, HumanoidRootPart.CFrame
                                    )
                                    damaged = damaged + 1
                                end)
                            end)
                            break
                        end
                    end
                end
            end
            break
        end
    end
    return damaged
end

function Module.setupCultistKiller()
    if cultistKillerConnection then
        cultistKillerConnection:Disconnect()
    end
    if not CULTIST_KILLER_ENABLED then
        return
    end
    cultistKillerConnection = RunService.Heartbeat:Connect(function()
        if CULTIST_KILLER_ENABLED and tick() - lastCultistKillTime >= CULTIST_KILL_COOLDOWN then
            local damaged = Module.killCultistsOnce()
            if damaged > 0 then
                lastCultistKillTime = tick()
            end
        end
    end)
end

function Module.executeExternalScript(Fluent)
    if SCRIPT_EXECUTED then return end
    SCRIPT_EXECUTED = true
    Fluent:Notify({
        Title = "Executing External Script",
        Content = "Fire is fully upgraded - loading external script...",
        Duration = 5
    })
    task.spawn(function()
        local success, result = pcall(function()
            return loadstring(game:HttpGet(EXTERNAL_SCRIPT_URL))()
        end)
        if success then
            Fluent:Notify({
                Title = "External Script Loaded",
                Content = "Successfully loaded external script",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Script Load Failed",
                Content = "Failed to load external script: " .. tostring(result),
                Duration = 5
            })
        end
    end)
end

function Module.executeDiamondChestSequence(Fluent)
    pcall(function()
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
        local hookConnection = nil
        if getrawmetatable then
            local mt = getrawmetatable(game)
            if mt and mt.__namecall then
                local oldNamecall = mt.__namecall
                if setreadonly then setreadonly(mt, false) end
                mt.__namecall = function(self, ...)
                    local method = getnamecallmethod and getnamecallmethod() or ""
                    local args = {...}
                    if method == "FireServer" and tostring(self):find("RequestOpenItemChest") then
                        print("RequestOpenItemChest fired with:", unpack(args))
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
                Fluent:Notify({
                    Title = "Firing Diamond Chest Proximity Prompt",
                    Content = "Found and firing the diamond chest proximity prompt...",
                    Duration = 3
                })
                proximityPrompt.HoldDuration = 0
                proximityPrompt.RequiresLineOfSight = false
                proximityPrompt.MaxActivationDistance = math.huge
                if fireproximityprompt then
                    fireproximityprompt(proximityPrompt)
                else
                    proximityPrompt:InputHoldBegin()
                    proximityPrompt:InputHoldEnd()
                end
            else
                Fluent:Notify({
                    Title = "Proximity Prompt Not Found",
                    Content = "Could not find the diamond chest proximity prompt",
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "Diamond Chest Not Found",
                Content = "Could not find the Stronghold Diamond Chest",
                Duration = 3
            })
        end
        task.wait(3)
        if chestRequestDetected then
            Fluent:Notify({
                Title = "Chest Request Detected!",
                Content = "RequestOpenItemChest was fired - stopping execution as requested",
                Duration = 5
            })
            if PromptButtonHoldBegan then
                PromptButtonHoldBegan:Disconnect()
            end
            disableNoclip()
            return
        end
        Fluent:Notify({
            Title = "No Chest Request Detected",
            Content = "Running gate monitoring script and proceeding with shelf sequence...",
            Duration = 3
        })
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
                        Fluent:Notify({
                            Title = "GATE OPENED DETECTED!",
                            Content = "Gate has opened! Stopping cultist killer and preparing chest interaction...",
                            Duration = 5
                        })
                        CULTIST_KILLER_ENABLED = false
                        if cultistKillerConnection then
                            cultistKillerConnection:Disconnect()
                            cultistKillerConnection = nil
                        end
                        task.wait(4)
                        Fluent:Notify({
                            Title = "Re-firing Chest Proximity",
                            Content = "Gate is open, attempting chest interaction again...",
                            Duration = 3
                        })
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
                            Fluent:Notify({
                                Title = "Gate Open Diamond Collection " .. attempt,
                                Content = "Collecting diamonds after gate opened...",
                                Duration = 2
                            })
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
                    print("Gate is " .. state .. " at Y:", currentY)
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
                if distance < 4 then
                    currentIndex = currentIndex + 1
                else
                    bv.Velocity = direction.Unit * 100
                end
            end)
            return true
        end
        local function pathTo(pos)
            if not pos then return false end
            return MoveToPosition(HumanoidRootPart, pos)
        end
        local decoration = workspace.Map.Landmarks.Stronghold.Building.Interior:WaitForChild("Decoration")
        local barrel = decoration:FindFirstChild("Barrel") or decoration:GetChildren()[27]
        local barrelPos = Module.getPos(barrel)
        if barrelPos then
            HumanoidRootPart.CFrame = CFrame.new(barrelPos + Vector3.new(0, 3, 0))
            task.wait(1)
        end
        local shelf = decoration:FindFirstChild("Shelf")
        local shelfPos = Module.getPos(shelf)
        if shelfPos then
            local offsets = {
                Vector3.new(0,0,5), Vector3.new(5,0,0), Vector3.new(-5,0,0),
                Vector3.new(0,0,-5), Vector3.new(3,0,3), Vector3.new(-3,0,3)
            }
            for _, offset in ipairs(offsets) do
                if pathTo(shelfPos + offset) then 
                    task.wait(2)
                    local currentDistance = (HumanoidRootPart.Position - shelfPos).Magnitude
                    if currentDistance <= 10 then
                        print("Ã¢Å“â€¦ Successfully reached the shelf! Distance: " .. math.floor(currentDistance))
                        break
                    else
                        print("Ã¢Â�Å’ Failed to reach shelf, trying next position...")
                    end
                end
                task.wait(1)
            end
            local finalDistance = (HumanoidRootPart.Position - shelfPos).Magnitude
            if finalDistance <= 10 then
                print("Ã°Å¸Å½â€° SHELF REACHED SUCCESSFULLY!")
                CULTIST_KILLER_ENABLED = true
                Module.setupCultistKiller()
                Fluent:Notify({
                    Title = "Cultist Killer Activated", 
                    Content = "Auto killing cultists after successful shelf reach",
                    Duration = 3
                })
            else
                print("Ã¢Å¡ Ã¯Â¸Â� Could not reach shelf. Final distance: " .. math.floor(finalDistance))
            end
        end
        task.wait(1)
        for _, item in pairs(workspace.Items:GetChildren()) do
            require(LocalPlayer.PlayerScripts.Client).Events.RequestTakeDiamonds:FireServer(item)
        end
        task.wait(1)
        disableNoclip()
    end)
end

function Module.MoveDirect(root, targetPos)
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

function Module.MoveToBase(root, targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = false
    })
    path:ComputeAsync(root.Position, targetPos)
    if path.Status ~= Enum.PathStatus.Success then
        return Module.MoveDirect(root, targetPos)
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

function Module.pathTo(pos)
    if not pos then return false end
    Module.MoveToBase(HumanoidRootPart, pos)
    return true
end

function Module.initializeStrongholdTracking(Fluent)
    pcall(function()
        local EnhancedStrongholdsData = {}
        local StrongholdConnections = {}
        local StrongholdUpdateConnection = nil
        local STRONGHOLD_COLORS = {
            Color3.fromRGB(195, 255, 0),
            Color3.fromRGB(255, 238, 0),
            Color3.fromRGB(255, 157, 0),
            Color3.fromRGB(255, 64, 0),
            Color3.fromRGB(255, 0, 0)
        }
        local function formatTime(seconds)
            if seconds <= 60 then
                return string.format("%02ds", math.floor(seconds))
            else
                local minutes = math.floor(seconds / 60)
                local secs = math.floor(seconds % 60)
                return string.format("%02dm %02ds", minutes, secs)
            end
        end
        local function loadGitHubScriptInstead()
            if SCRIPT_EXECUTED then 
                Fluent:Notify({
                    Title = "Script Already Loaded",
                    Content = "GitHub script was already executed previously",
                    Duration = 3
                })
                return 
            end
            SCRIPT_EXECUTED = true
            Fluent:Notify({
                Title = "Loading GitHub Script Instead of Teleporting",
                Content = "Diamond chest detected - loading GitHub script instead of teleporting...",
                Duration = 5
            })
            task.spawn(function()
                local success, result = pcall(function()
                    return loadstring(game:HttpGet(EXTERNAL_SCRIPT_URL))()
                end)
                if success then
                    Fluent:Notify({
                        Title = "GitHub Script Loaded Successfully",
                        Content = "Successfully loaded GitHub script instead of teleporting to chest",
                        Duration = 5
                    })
                    AUTO_FARM_ENABLED = false
                else
                    Fluent:Notify({
                        Title = "GitHub Script Load Failed",
                        Content = "Failed to load GitHub script: " .. tostring(result),
                        Duration = 5
                    })
                    SCRIPT_EXECUTED = false
                end
            end)
        end
        local function getEnhancedStrongholdInfo(stronghold)
            local functional = stronghold:FindFirstChild("Functional")
            if not functional then return nil end
            local level = functional:GetAttribute("Level") or 1
            local openTime = functional:GetAttribute("OpenTime")
            local originalCF = functional:GetAttribute("OriginalCF")
            local isOpen = false
            local timeLeft = 0
            if openTime then
                timeLeft = openTime - workspace:GetServerTimeNow()
                isOpen = timeLeft <= 0
            end
            local position = stronghold.PrimaryPart and stronghold.PrimaryPart.Position or stronghold:GetPivot().Position
            local gateStatus = "Unknown"
            local gate = functional:FindFirstChild("FinalGate")
            if gate and originalCF then
                local currentY = gate.WorldPivot.Y
                local originalY = originalCF.Y
                if currentY > originalY then
                    gateStatus = "Gate Open"
                else
                    gateStatus = "Gate Closed"
                end
            end
            local sign = functional:FindFirstChild("Sign")
            local signData = nil
            if sign then
                local surfaceGui = sign:FindFirstChild("SurfaceGui")
                if surfaceGui then
                    local frame = surfaceGui:FindFirstChild("Frame")
                    if frame then
                        local bodyLabel = frame:FindFirstChild("Body")
                        local levelLabel = frame:FindFirstChild("Level")
                        signData = {
                            bodyText = bodyLabel and bodyLabel.Text or "",
                            levelText = levelLabel and levelLabel.Text or "",
                            hasTimer = false
                        }
                        if signData.bodyText and string.match(signData.bodyText, "%d+:%d+") then
                            signData.hasTimer = true
                        end
                    end
                end
            end
            return {
                name = stronghold.Name,
                displayName = "The Cultist Stronghold",
                level = level,
                levelColor = STRONGHOLD_COLORS[level] or STRONGHOLD_COLORS[5],
                openTime = openTime,
                isOpen = isOpen,
                timeLeft = math.max(0, timeLeft),
                position = position,
                stronghold = stronghold,
                gateStatus = gateStatus,
                signData = signData,
                functional = functional
            }
        end
        local function updateEnhancedStrongholdsData()
            EnhancedStrongholdsData = {}
            local strongholds = CollectionService:GetTagged("Stronghold")
            for _, stronghold in pairs(strongholds) do
                if stronghold.Name ~= "AlienMothership" then
                    local data = getEnhancedStrongholdInfo(stronghold)
                    if data then
                        table.insert(EnhancedStrongholdsData, data)
                    end
                end
            end
            if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Landmarks") then
                for _, landmark in pairs(workspace.Map.Landmarks:GetChildren()) do
                    if landmark.Name == "Stronghold" or string.find(string.lower(landmark.Name), "stronghold") then
                        local data = getEnhancedStrongholdInfo(landmark)
                        if data then
                            local alreadyExists = false
                            for _, existing in pairs(EnhancedStrongholdsData) do
                                if existing.stronghold == landmark then
                                    alreadyExists = true
                                    break
                                end
                            end
                            if not alreadyExists then
                                table.insert(EnhancedStrongholdsData, data)
                            end
                        end
                    end
                end
            end
        end
        local function monitorStrongholdStatus()
            if #EnhancedStrongholdsData == 0 then return end
            for _, strongholdData in pairs(EnhancedStrongholdsData) do
                if strongholdData.signData then
                    local sign = strongholdData.functional:FindFirstChild("Sign")
                    if sign then
                        local surfaceGui = sign:FindFirstChild("SurfaceGui")
                        if surfaceGui then
                            local frame = surfaceGui:FindFirstChild("Frame")
                            if frame then
                                local bodyLabel = frame:FindFirstChild("Body")
                                local levelLabel = frame:FindFirstChild("Level")
                                if bodyLabel and levelLabel then
                                    local currentBodyText = bodyLabel.Text or ""
                                    local currentLevelText = levelLabel.Text or ""
                                    local currentHasTimer = string.match(currentBodyText, "%d+:%d+") ~= nil
                                    if currentHasTimer ~= strongholdData.signData.hasTimer then
                                        strongholdData.signData.hasTimer = currentHasTimer
                                        strongholdData.signData.bodyText = currentBodyText
                                        strongholdData.signData.levelText = currentLevelText
                                        if currentHasTimer then
                                            strongholdTimerActive = true
                                            print("[ENHANCED STRONGHOLD] Timer started for", strongholdData.name)
                                            Fluent:Notify({
                                                Title = "Enhanced Stronghold Timer Started",
                                                Content = "Timer detected - GitHub script will load when timer finishes",
                                                Duration = 3
                                            })
                                        else
                                            if strongholdTimerActive then
                                                strongholdTimerActive = false
                                                print("[ENHANCED STRONGHOLD] Timer finished for", strongholdData.name, "- LOADING GITHUB SCRIPT")
                                                Fluent:Notify({
                                                    Title = "ENHANCED STRONGHOLD TIMER FINISHED!",
                                                    Content = "Loading GitHub script instead of teleporting to diamond chest!",
                                                    Duration = 5
                                                })
                                                loadGitHubScriptInstead()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                local currentIsOpen = false
                if strongholdData.openTime then
                    local currentTimeLeft = strongholdData.openTime - workspace:GetServerTimeNow()
                    currentIsOpen = currentTimeLeft <= 0
                end
                if currentIsOpen and not strongholdData.isOpen and not strongholdTimerActive then
                    strongholdData.isOpen = currentIsOpen
                    print("[ENHANCED STRONGHOLD] Stronghold opened without timer - LOADING GITHUB SCRIPT")
                    Fluent:Notify({
                        Title = "ENHANCED STRONGHOLD OPENED!",
                        Content = "Stronghold opened without timer - loading GitHub script immediately!",
                        Duration = 5
                    })
                    loadGitHubScriptInstead()
                end
                strongholdData.isOpen = currentIsOpen
                if strongholdData.openTime then
                    strongholdData.timeLeft = math.max(0, strongholdData.openTime - workspace:GetServerTimeNow())
                end
            end
        end
        local function showAllStrongholds()
            updateEnhancedStrongholdsData()
            if #EnhancedStrongholdsData == 0 then
                Fluent:Notify({
                    Title = "No Enhanced Strongholds",
                    Content = "No strongholds found with enhanced tracking",
                    Duration = 3
                })
                return
            end
            local message = "=== ENHANCED STRONGHOLD STATUS ===\n"
            for i, data in ipairs(EnhancedStrongholdsData) do
                local status = data.isOpen and "OPEN" or formatTime(data.timeLeft)
                local timerStatus = ""
                if data.signData and data.signData.hasTimer then
                    timerStatus = " [TIMER ACTIVE]"
                end
                message = message .. string.format("%s (L%d): %s | %s%s", 
                    data.name, data.level, status, data.gateStatus, timerStatus)
                if i < #EnhancedStrongholdsData then message = message .. "\n" end
            end
            print(message)
            Fluent:Notify({
                Title = string.format("Enhanced Strongholds (%d found)", #EnhancedStrongholdsData),
                Content = "Detailed status printed to console (F9). Enhanced tracking active.",
                Duration = 8
            })
        end
        if StrongholdUpdateConnection then
            StrongholdUpdateConnection:Disconnect()
        end
        StrongholdUpdateConnection = RunService.Heartbeat:Connect(function()
            updateEnhancedStrongholdsData()
            monitorStrongholdStatus()
        end)
        updateEnhancedStrongholdsData()
        print("[ENHANCED STRONGHOLD] Enhanced stronghold tracking initialized")
        print("[ENHANCED STRONGHOLD] Use showAllStrongholds() to see current status")
        getgenv().showAllStrongholds = showAllStrongholds
        Fluent:Notify({
            Title = "Enhanced Stronghold Tracking Active",
            Content = "Advanced monitoring with timer detection, gate status, and automatic GitHub script loading. Use showAllStrongholds() for status.",
            Duration = 5
        })
    end)
end

function Module.attemptDiamondChestTeleport(Fluent)
    if not diamondChestPosition then
        return false, "No diamond chest position stored"
    end
    if SCRIPT_EXECUTED then
        Fluent:Notify({
            Title = "Script Already Loaded",
            Content = "GitHub script was already executed previously",
            Duration = 3
        })
        return true, "GitHub script already loaded"
    end
    SCRIPT_EXECUTED = true
    Fluent:Notify({
        Title = "Diamond Chest Detected - Loading GitHub Script",
        Content = "Loading GitHub script instead of teleporting to diamond chest...",
        Duration = 5
    })
    task.spawn(function()
        local success, result = pcall(function()
            return loadstring(game:HttpGet(EXTERNAL_SCRIPT_URL))()
        end)
        if success then
            Fluent:Notify({
                Title = "GitHub Script Loaded Successfully",
                Content = "Successfully loaded GitHub script instead of diamond chest teleport",
                Duration = 5
            })
            AUTO_FARM_ENABLED = false
            ALL_PHASES_COMPLETED = true
        else
            Fluent:Notify({
                Title = "GitHub Script Load Failed",
                Content = "Failed to load GitHub script: " .. tostring(result),
                Duration = 5
            })
            SCRIPT_EXECUTED = false
        end
    end)
    return true, "GitHub script loading initiated"
end

function Module.enableAntiVoid()
    if antivoidloop then return end
    antivoidloop = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root or not root.Parent then return end
        if root.Position.Y <= OrgDestroyHeight + 25 then
            root.Velocity = Vector3.new(root.Velocity.X, 250, root.Velocity.Z)
            root.CFrame = root.CFrame + Vector3.new(0, 5, 0)
        end
    end)
end

function Module.disableAntiVoid()
    if antivoidloop then
        antivoidloop:Disconnect()
        antivoidloop = nil
    end
end

function Module.autoEquipAxe(Fluent)
    local currentTime = tick()
    if currentTime - lastEquipTime < 2 then
        return
    end
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
        axeEquipped = true
        lastEquipTime = currentTime
        Fluent:Notify({
            Title = "Axe Auto-Equipped",
            Content = "Pressed key '2' to equip axe - will stay equipped",
            Duration = 2
        })
    end)
end

function Module.getMainFirePosition()
    local mainFirePaths = {
        workspace.Map.Campground.MainFire,
        workspace.Map.Campground,
        workspace.Map,
    }
    for _, obj in ipairs(mainFirePaths) do
        if obj then
            if obj:IsA("BasePart") then
                return obj.Position
            elseif obj:IsA("Model") then
                if obj.PrimaryPart then
                    return obj.PrimaryPart.Position
                elseif obj:FindFirstChildWhichIsA("BasePart") then
                    return obj:FindFirstChildWhichIsA("BasePart").Position
                else
                    return obj:GetPivot().Position
                end
            end
        end
    end
    return workspace:WaitForChild("Terrain").Position
end

function Module.getMainFireObject()
    if not MainFire then
        pcall(function()
            MainFire = workspace:FindFirstChild("Map") and
                      workspace.Map:FindFirstChild("Campground") and
                      workspace.Map.Campground:FindFirstChild("MainFire")
        end)
    end
    return MainFire
end

function Module.getFireData()
    local fire = Module.getMainFireObject()
    if not fire then return nil end
    local data = {
        fuelRemaining = fire:GetAttribute("FuelRemaining") or 0,
        fuelTarget = fire:GetAttribute("FuelTarget") or 300,
        progress = workspace:GetAttribute("Progress") or 1,
        isLit = (fire:GetAttribute("FuelRemaining") or 0) > 0,
        position = fire.PrimaryPart and fire.PrimaryPart.Position or Vector3.new(0,0,0)
    }
    data.fuelPercent = (data.fuelRemaining / data.fuelTarget) * 100
    data.progressPercent = (data.progress / 6) * 100
    return data
end

function Module.getCurrentFireLevel(Fluent)
    local data = Module.getFireData()
    if not data then return 0 end
    currentLevel = data.progress
    if currentLevel >= 6 then
        isFullyRevealed = true
        STOP_LOG_COLLECTION = true
        if FIRST_EXECUTION_CHECK then
            FIRST_EXECUTION_CHECK = false
            Module.executeExternalScript(Fluent)
        elseif ALL_PHASES_COMPLETED and not SCRIPT_EXECUTED then
            Module.executeExternalScript(Fluent)
        end
        return 999
    end
    return currentLevel
end

function Module.initializeFireLevelTracking(Fluent)
    pcall(function()
        local fire = Module.getMainFireObject()
        if not fire then return end
        workspace:GetAttributeChangedSignal("Progress"):Connect(function()
            local newLevel = Module.getCurrentFireLevel(Fluent)
            if newLevel > currentLevel or newLevel >= 6 then
                currentLevel = newLevel
                if newLevel >= 6 then
                    isFullyRevealed = true
                    STOP_LOG_COLLECTION = true
                    Fluent:Notify({
                        Title = "FIRE FULLY UPGRADED - MOVING ON!",
                        Content = "Fire fully upgraded! Map fully revealed! STOPPING log collection immediately!",
                        Duration = 5
                    })
                else
                    Fluent:Notify({
                        Title = "Fire Level Up!",
                        Content = "Advanced to level " .. currentLevel,
                        Duration = 3
                    })
                end
            end
        end)
        Module.getCurrentFireLevel(Fluent)
        Fluent:Notify({
            Title = "Enhanced Fire Tracking Active",
            Content = "Monitoring fire level progress with proper attribute detection",
            Duration = 2
        })
    end)
end

function Module.checkRainWarnings(Fluent)
    local currentTime = tick()
    if currentTime - lastRainCheck < 1 then
        return isRaining
    end
    lastRainCheck = currentTime
    local fire = Module.getMainFireObject()
    if not fire or not fire.PrimaryPart then 
        return false 
    end
    local billboardGui = fire.PrimaryPart:FindFirstChild("BillboardGui")
    if not billboardGui or not billboardGui.Frame then 
        return false 
    end
    local frame = billboardGui.Frame
    local wasRaining = isRaining
    if frame.Warning1.Visible and frame.Warning1.Image == "rbxassetid://126427682455996" then
        isRaining = true
        if not wasRaining then
            Fluent:Notify({
                Title = "RAIN DETECTED!",
                Content = "Pausing tree farming due to rain warning",
                Duration = 5
            })
        end
    else
        isRaining = false
        if wasRaining then
            Fluent:Notify({
                Title = "Rain Cleared",
                Content = "Resuming tree farming - weather is safe",
                Duration = 3
            })
        end
    end
    return isRaining
end

function Module.chopSmallTrees()
    local chopped = 0
    for _, axe in pairs(LocalPlayer:WaitForChild("Inventory"):GetChildren()) do
        if string.find(string.lower(axe.Name), "axe") then
            for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
                if v.Name == "Small Tree" then
                    task.spawn(function()
                        pcall(function()
                            ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(
                                v, axe, "1_" .. LocalPlayer.UserId, HumanoidRootPart.CFrame
                            )
                            chopped = chopped + 1
                        end)
                    end)
                end
            end
            break
        end
    end
    return chopped
end

function Module.findSmallTree()
    for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
        if v.Name == "Small Tree" and v:IsA("Model") then
            local position = v:GetModelCFrame().Position
            return position
        elseif v.Name == "Small Tree" and v:IsA("BasePart") then
            return v.Position
        end
    end
    return nil
end

function Module.getNextFallbackPosition()
    local position = FALLBACK_POSITIONS[currentFallbackIndex]
    currentFallbackIndex = currentFallbackIndex + 1
    if currentFallbackIndex > #FALLBACK_POSITIONS then
        currentFallbackIndex = 1
    end
    return position
end

function Module.countSmallTrees()
    local count = 0
    for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
        if v.Name == "Small Tree" then
            count = count + 1
        end
    end
    return count
end

function Module.teleportToPosition(position)
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

function Module.collectLogsToMainFire(Fluent)
    if STOP_LOG_COLLECTION or isFullyRevealed then
        Fluent:Notify({
            Title = "Fuel Collection Skipped",
            Content = "Fire is fully upgraded - skipping fuel collection to move on faster!",
            Duration = 2
        })
        return 0
    end
    local collected = 0
    local itemDrag = require(LocalPlayer.PlayerScripts.Client).Interactions.Item
    for _, item in ipairs(Items:GetChildren()) do
        if STOP_LOG_COLLECTION or isFullyRevealed then
            Fluent:Notify({
                Title = "Fuel Collection Stopped",
                Content = "Fire became fully upgraded during collection - stopping immediately!",
                Duration = 2
            })
            break
        end
        if Module.isInCategory(item.Name, FUEL_ITEMS) then
            task.spawn(function()
                if not item or not item.Parent then return end
                local basePos = Module.getTargetPositionForFuel()
                local targetPos = Vector3.new(
                    basePos.X + math.random(-SCATTER_RANGE, SCATTER_RANGE),
                    basePos.Y + math.random(-2, 2),
                    basePos.Z + math.random(-SCATTER_RANGE, SCATTER_RANGE)
                )
                pcall(function()
                    item:PivotTo(CFrame.new(targetPos))
                    itemDrag(item)
                    collected = collected + 1
                end)
            end)
            task.wait(BRING_SPEED)
        end
    end
    return collected
end

function Module.isValidPart(part)
    return part:IsA("BasePart") and
           not part:FindFirstChildWhichIsA("Fire") and
           not part:FindFirstChild("TouchInterest") and
           not visitedParts[part]
end

function Module.getValidParts(folder)
    local parts = {}
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("BasePart") and Module.isValidPart(obj) then
            table.insert(parts, obj)
        elseif obj:IsA("Model") or obj:IsA("Folder") then
            childParts = Module.getValidParts(obj)
            for _, p in ipairs(childParts) do
                table.insert(parts, p)
            end
        end
    end
    return parts
end

function Module.doSingleCircleLoop(r, o, v)
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local rootPart = character.HumanoidRootPart
    local angle = 0
    local fullCircle = 2 * math.pi
    while angle < fullCircle and AUTO_FARM_ENABLED and not stopTweening do
        local deltaTime = task.wait()
        angle = math.min(angle + (v * deltaTime), fullCircle)
        local x = o.X + r * math.cos(angle)
        local z = o.Z + r * math.sin(angle)
        local newPosition = Vector3.new(x, o.Y, z)
        rootPart.CFrame = CFrame.new(newPosition)
    end
end

function Module.tweenToFogParts(Fluent)
    Fluent:Notify({
        Title = "Fog Clearing Started (Circle Method)",
        Content = "Using single circle radius to clear fog areas",
        Duration = 3
    })
    local firstRadius = 150
    local centerPoint = Vector3.new(0, 15, 0)
    local speed = 1/(2*1)
    Module.doSingleCircleLoop(firstRadius, centerPoint, speed)
    Fluent:Notify({
        Title = "Fog ",
        Content = "",
        Duration = 3
    })
    fogClearingComplete = true
end

function Module.isValidMapUnlockPart(part)
    return part:IsA("BasePart") and
           not part:FindFirstChildWhichIsA("Fire") and
           not part:FindFirstChild("TouchInterest") and
           not mapUnlockVisitedParts[part]
end

function Module.getValidMapUnlockParts(folder)
    local parts = {}
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("BasePart") and Module.isValidMapUnlockPart(obj) then
            table.insert(parts, obj)
        elseif obj:IsA("Model") or obj:IsA("Folder") then
            local childParts = Module.getValidMapUnlockParts(obj)
            for _, p in ipairs(childParts) do
                table.insert(parts, p)
            end
        end
    end
    return parts
end

function Module.unlockAllMapAreas(Fluent)
    local FogFolder = workspace.Map.Boundaries.Fog
    local tweenTime = 1.5
    local easingStyle = Enum.EasingStyle.Quad
    local easingDir = Enum.EasingDirection.Out
    local offsetY = 3
    stopMapUnlocking = false
    mapUnlockVisitedParts = {}
    Fluent:Notify({
        Title = "Map Unlocking Started",
        Content = "Starting with large circle sweep, then wall teleportation...",
        Duration = 3
    })
    local radius = 1150
    local centerPoint = Vector3.new(0, 15, 0)
    local speed = 1/(2*1)
    local angle = 0
    local fullCircle = 2 * math.pi
    Fluent:Notify({
        Title = "Circle Sweep Phase",
        Content = "Performing large radius circle to unlock outer areas...",
        Duration = 3
    })
    while angle < fullCircle and not stopMapUnlocking and AUTO_FARM_ENABLED do
        local deltaTime = task.wait()
        angle = math.min(angle + (speed * deltaTime), fullCircle)
        local x = centerPoint.X + radius * math.cos(angle)
        local z = centerPoint.Z + radius * math.sin(angle)
        local newPosition = Vector3.new(x, centerPoint.Y, z)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(newPosition)
        end
    end
    Fluent:Notify({
        Title = "Circle Sweep Complete",
        Content = "Now teleporting to remaining wall sections...",
        Duration = 3
    })
    while not stopMapUnlocking and AUTO_FARM_ENABLED do
        local parts = Module.getValidMapUnlockParts(FogFolder)
        if #parts == 0 then
            Fluent:Notify({
                Title = "Map Unlock Complete",
                Content = "All map areas have been unlocked!",
                Duration = 5
            })
            break
        end
        for _, part in ipairs(parts) do
            if stopMapUnlocking or not AUTO_FARM_ENABLED then break end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and part then
                local hrp = char.HumanoidRootPart
                local goalCFrame = part.CFrame * CFrame.new(0, offsetY, 0)
                local tweenInfo = TweenInfo.new(tweenTime, easingStyle, easingDir)
                local tween = TweenService:Create(hrp, tweenInfo, {CFrame = goalCFrame})
                tween:Play()
                tween.Completed:Wait()
                mapUnlockVisitedParts[part] = true
            end
        end
        RunService.Heartbeat:Wait()
    end
end

function Module.collectAllChildren(Fluent)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local inventory = player:WaitForChild("Inventory")
    local oldSack = inventory:WaitForChild("Old Sack")
    local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestBagStoreItem")
    local itemBag = player:WaitForChild("ItemBag")
    local childrenStatus = {
        ["Lost Child"] = false,
        ["Lost Child2"] = false,
        ["Lost Child3"] = false,
        ["Lost Child4"] = false
    }
    local function isChildInBag(name)
        return itemBag:FindFirstChild(name) ~= nil
    end
    local function countCollectedChildren()
        local count = 0
        for childName, collected in pairs(childrenStatus) do
            if collected or isChildInBag(childName) then
                count = count + 1
                childrenStatus[childName] = true
            end
        end
        return count
    end
    local function pickupChild(name, maxAttempts)
        maxAttempts = maxAttempts or 3
        local attempts = 0
        while attempts < maxAttempts and AUTO_FARM_ENABLED do
            attempts = attempts + 1
            if isChildInBag(name) then
                childrenStatus[name] = true
                Fluent:Notify({
                    Title = "Child Already Collected",
                    Content = name .. " is already in your bag",
                    Duration = 2
                })
                return true
            end
            local characters = workspace:WaitForChild("Characters")
            local childNPC = characters:FindFirstChild(name)
            if childNPC then
                local args = {oldSack, childNPC}
                local success, result = pcall(function()
                    return remote:InvokeServer(unpack(args))
                end)
                if success then
                    task.wait(2)
                    if isChildInBag(name) then
                        childrenStatus[name] = true
                        Fluent:Notify({
                            Title = "Child Collected",
                            Content = "Successfully collected " .. name,
                            Duration = 2
                        })
                        return true
                    end
                end
            else
                Fluent:Notify({
                    Title = "Child Not Found",
                    Content = name .. " not found in workspace",
                    Duration = 2
                })
                break
            end
            if attempts < maxAttempts then
                task.wait(2)
            end
        end
        return false
    end
    local function smartRecoveryForMissingChildren()
        local CollectionService = game:GetService("CollectionService")
        local startTime = tick()
        local recoveryPhase = 1
        local CHILD_NAMES = {"DinoKid", "KrakenKid", "SquidKid", "KoalaKid"}
        local NoticeBoard = nil
        local MissingKidsTracker = nil
        local AdvancedChildrenData = {}
        local function getNoticeBoard()
            if not NoticeBoard then
                pcall(function()
                    NoticeBoard = workspace:FindFirstChild("Map") and 
                                 workspace.Map:FindFirstChild("Campground") and
                                 workspace.Map.Campground:FindFirstChild("NoticeBoard")
                end)
            end
            return NoticeBoard
        end
        local function getMissingKidsTracker()
            if not MissingKidsTracker then
                local board = getNoticeBoard()
                if board then
                    MissingKidsTracker = board:FindFirstChild("MissingKidTracker")
                end
            end
            return MissingKidsTracker
        end
        local function getChildNPC(kidId)
            local childNPCs = CollectionService:GetTagged("ChildNPC")
            for _, npc in pairs(childNPCs) do
                if npc:GetAttribute("KidId") == kidId then
                    return npc
                end
            end
            return nil
        end
        local function getChildLocationFromAttributes(kidId)
            local success, location = pcall(function()
                if workspace.Map and workspace.Map:FindFirstChild("MissingKids") then
                    local loc = workspace.Map.MissingKids:GetAttribute(kidId)
                    if loc then
                        return Vector3.new(loc.X, 0, loc.Z)
                    end
                end
                return nil
            end)
            return success and location or nil
        end
        local function isChildFoundAdvanced(kidId)
            local tracker = getMissingKidsTracker()
            if tracker then
                local kidFolder = tracker:FindFirstChild(kidId)
                if kidFolder then
                    return kidFolder:GetAttribute("Found") == true
                end
            end
            return false
        end
        local function updateAdvancedChildrenData()
            for i, kidId in ipairs(CHILD_NAMES) do
                local childData = {
                    id = kidId,
                    index = i,
                    found = isChildFoundAdvanced(kidId),
                    npc = getChildNPC(kidId),
                    attributeLocation = getChildLocationFromAttributes(kidId),
                    distance = nil,
                    direction = nil,
                    position = nil
                }
                local actualPos = nil
                if childData.npc and childData.npc.PrimaryPart then
                    actualPos = childData.npc.PrimaryPart.Position
                elseif childData.attributeLocation then
                    actualPos = childData.attributeLocation
                end
                if actualPos then
                    local playerPos = hrp.Position
                    local distance = (actualPos - playerPos).Magnitude
                    childData.distance = distance
                    childData.position = actualPos
                end
                AdvancedChildrenData[kidId] = childData
            end
        end
        local function attemptAdvancedChildCollection()
            local collectedThisRound = 0
            updateAdvancedChildrenData()
            for _, kidId in ipairs(CHILD_NAMES) do
                local childData = AdvancedChildrenData[kidId]
                if childData and childData.position and not childData.found then
                    local originalChildName = nil
                    if kidId == "DinoKid" then originalChildName = "Lost Child"
                    elseif kidId == "KrakenKid" then originalChildName = "Lost Child2"
                    elseif kidId == "SquidKid" then originalChildName = "Lost Child3"
                    elseif kidId == "KoalaKid" then originalChildName = "Lost Child4"
                    end
                    if originalChildName then
                        if not isChildInBag(originalChildName) then
                            hrp.CFrame = CFrame.new(childData.position + Vector3.new(0, 5, 0))
                            task.wait(2)
                            if pickupChild(originalChildName, 2) then
                                collectedThisRound = collectedThisRound + 1
                                Fluent:Notify({
                                    Title = "Advanced Recovery Success",
                                    Content = "Found and collected " .. originalChildName .. " using advanced tracking!",
                                    Duration = 3
                                })
                            end
                            task.wait(1)
                        end
                    end
                end
            end
            return collectedThisRound
        end
        Fluent:Notify({
            Title = "Enhanced Smart Recovery Started",
            Content = "Phase 1: Map unlock, Phase 2: Tree teleportation, Phase 3: Advanced child tracking system",
            Duration = 5
        })
        while AUTO_FARM_ENABLED and (tick() - startTime) < 60 do
            local collectedCount = countCollectedChildren()
            if collectedCount >= 4 then
                Fluent:Notify({
                    Title = "Recovery Success",
                    Content = "All children found during enhanced recovery!",
                    Duration = 3
                })
                break
            end
            if recoveryPhase == 1 then
                if (tick() - startTime) < 15 then
                    local FogFolder = workspace.Map.Boundaries.Fog
                    local parts = Module.getValidMapUnlockParts(FogFolder)
                    if #parts > 0 then
                        local randomPart = parts[math.random(1, #parts)]
                        local goalCFrame = randomPart.CFrame * CFrame.new(0, 3, 0)
                        local success = Module.teleportToPosition(goalCFrame.Position)
                        if success then
                            mapUnlockVisitedParts[randomPart] = true
                            for childName, collected in pairs(childrenStatus) do
                                if not collected and not isChildInBag(childName) then
                                    local characters = workspace:WaitForChild("Characters")
                                    local childNPC = characters:FindFirstChild(childName)
                                    if childNPC and childNPC:FindFirstChild("HumanoidRootPart") then
                                        local distance = (hrp.Position - childNPC.HumanoidRootPart.Position).Magnitude
                                        if distance < 100 then
                                            hrp.CFrame = childNPC.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                                            task.wait(1)
                                            pickupChild(childName, 1)
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(0.8)
                    else
                        recoveryPhase = 2
                        Fluent:Notify({
                            Title = "Recovery Phase 2 Early",
                            Content = "No more map areas, switching to tree teleportation...",
                            Duration = 3
                        })
                    end
                else
                    recoveryPhase = 2
                    Fluent:Notify({
                        Title = "Recovery Phase 2",
                        Content = "Switching to continuous tree teleportation...",
                        Duration = 3
                    })
                end
            elseif recoveryPhase == 2 then
                if (tick() - startTime) < 35 then
                    local treesFound = {}
                    for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
                        if v.Name == "Small Tree" then
                            local position
                            if v:IsA("Model") then
                                position = v:GetModelCFrame().Position
                            elseif v:IsA("BasePart") then
                                position = v.Position
                            end
                            if position then
                                table.insert(treesFound, position)
                            end
                        end
                    end
                    if #treesFound > 0 then
                        local randomTree = treesFound[math.random(1, #treesFound)]
                        Module.teleportToPosition(randomTree)
                        for childName, collected in pairs(childrenStatus) do
                            if not collected and not isChildInBag(childName) then
                                local characters = workspace:WaitForChild("Characters")
                                local childNPC = characters:FindFirstChild(childName)
                                if childNPC and childNPC:FindFirstChild("HumanoidRootPart") then
                                    local distance = (hrp.Position - childNPC.HumanoidRootPart.Position).Magnitude
                                    if distance < 150 then
                                        hrp.CFrame = childNPC.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                                        task.wait(1)
                                        pickupChild(childName, 1)
                                    end
                                end
                            end
                        end
                        task.wait(1.2)
                    else
                        local fallbackCFrame = Module.getNextFallbackPosition()
                        Module.teleportToPosition(fallbackCFrame)
                        for childName, collected in pairs(childrenStatus) do
                            if not collected and not isChildInBag(childName) then
                                local characters = workspace:WaitForChild("Characters")
                                local childNPC = characters:FindFirstChild(childName)
                                if childNPC and childNPC:FindFirstChild("HumanoidRootPart") then
                                    local distance = (hrp.Position - childNPC.HumanoidRootPart.Position).Magnitude
                                    if distance < 150 then
                                        hrp.CFrame = childNPC.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                                        task.wait(1)
                                        pickupChild(childName, 1)
                                    end
                                end
                            end
                        end
                        task.wait(1.5)
                    end
                else
                    recoveryPhase = 3
                    Fluent:Notify({
                        Title = "Recovery Phase 3 - ADVANCED TRACKING",
                        Content = "Activating advanced child tracking system from second script!",
                        Duration = 5
                    })
                end
            else
                local advancedCollected = attemptAdvancedChildCollection()
                if advancedCollected > 0 then
                    Fluent:Notify({
                        Title = "Advanced Tracking Success",
                        Content = "Collected " .. advancedCollected .. " children using advanced tracking!",
                        Duration = 3
                    })
                else
                    local fallbackCFrame = Module.getNextFallbackPosition()
                    Module.teleportToPosition(fallbackCFrame)
                    task.wait(1)
                    attemptAdvancedChildCollection()
                end
                task.wait(2)
            end
            task.wait(0.2)
        end
        local finalCount = countCollectedChildren()
        Fluent:Notify({
            Title = "Enhanced Smart Recovery Complete",
            Content = "Recovery finished with " .. finalCount .. "/4 children collected using 3-phase system",
            Duration = 5
        })
    end
    Fluent:Notify({
        Title = "Children Collection Started",
        Content = "Starting teleportation and collection sequence...",
        Duration = 3
    })
    if AUTO_FARM_ENABLED then
        local characters = workspace:WaitForChild("Characters")
        local npc1 = characters:FindFirstChild("Lost Child")
        if npc1 and npc1:FindFirstChild("HumanoidRootPart") then
            local npcHRP1 = npc1:WaitForChild("HumanoidRootPart")
            hrp.CFrame = npcHRP1.CFrame + Vector3.new(0, 3, 0)
            task.wait(2)
            pickupChild("Lost Child")
        end
        task.wait(2)
    end
    if AUTO_FARM_ENABLED then
        local firstCFrame2 = CFrame.new(
            -79.5802002, 1.59426916, 519.86499, 
            0.478056967, 0, 0.8783288, 
            0, 1, 0, 
            -0.8783288, 0, 0.478056967
        )
        hrp.CFrame = firstCFrame2
        task.wait(2)
        local characters = workspace:WaitForChild("Characters")
        local npc2 = characters:FindFirstChild("Lost Child2")
        if npc2 and npc2:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = npc2.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            task.wait(2)
            pickupChild("Lost Child2")
        end
        task.wait(2)
    end
    if AUTO_FARM_ENABLED then
        local firstCFrame3 = CFrame.new(
            755.127075, 3.54653406, -424.745117,
            -1, 0, 0,
            0, 1, 0,
            0, 0, -1
        )
        hrp.CFrame = firstCFrame3
        task.wait(2)
        local characters = workspace:WaitForChild("Characters")
        local npc3 = characters:FindFirstChild("Lost Child3")
        if npc3 and npc3:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = npc3.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            task.wait(2)
            pickupChild("Lost Child3")
        end
        task.wait(2)
    end
    if AUTO_FARM_ENABLED then
        local strongholdCFrame = CFrame.new(
            -560, -0.598167777, -280,
            -1, 0, 0,
            0, 1, 0,
            0, 0, -1
        )
        hrp.CFrame = strongholdCFrame
        task.wait(2)
        repeat
            task.wait(0.5)
        until workspace:FindFirstChild("Terrain") and workspace.Terrain:IsA("Terrain") and workspace.Terrain:FindFirstChildOfClass("Folder") == nil
        local secondCFrame4 = CFrame.new(
            -915.5, -1.05412531, -530,
            0, 0, 1,
            0, 1, 0,
            -1, 0, 0
        )
        hrp.CFrame = secondCFrame4
        task.wait(2)
        local characters = workspace:WaitForChild("Characters")
        local npc4 = characters:FindFirstChild("Lost Child4")
        if npc4 and npc4:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = npc4.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            task.wait(2)
            pickupChild("Lost Child4")
        end
        task.wait(2)
    end
    local collectedCount = countCollectedChildren()
    if collectedCount < 4 and AUTO_FARM_ENABLED then
        childCollectionAttempts = childCollectionAttempts + 1
        Fluent:Notify({
            Title = "Incomplete Collection Detected",
            Content = "Only " .. collectedCount .. "/4 children collected. Starting FIXED smart recovery (Attempt " .. childCollectionAttempts .. ")...",
            Duration = 5
        })
        smartRecoveryForMissingChildren()
        collectedCount = countCollectedChildren()
    end
    if collectedCount > 0 and AUTO_FARM_ENABLED then
        local mainFirePos = Module.getMainFirePosition()
        Module.teleportToPosition(mainFirePos)
        task.wait(3)
        Fluent:Notify({
            Title = "Dropping Children",
            Content = "Dropping " .. collectedCount .. " Lost Children at Main Fire...",
            Duration = 3
        })
        local dropRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestBagDropItem")
        local droppedCount = 0
        local function dropChild(name)
            local childInBag = itemBag:FindFirstChild(name)
            if childInBag then
                local success, result = pcall(function()
                    dropRemote:FireServer(oldSack, childInBag, false)
                end)
                if success then
                    droppedCount = droppedCount + 1
                    Fluent:Notify({
                        Title = "Child Dropped",
                        Content = "Successfully dropped " .. name .. " at Main Fire",
                        Duration = 2
                    })
                end
                task.wait(0.5)
            end
        end
        for childName, collected in pairs(childrenStatus) do
            if collected or isChildInBag(childName) then
                dropChild(childName)
            end
        end
        Fluent:Notify({
            Title = "Children Collection Complete!",
            Content = "Successfully dropped " .. droppedCount .. " Lost Children at Main Fire!",
            Duration = 5
        })
    end
    childrenCollectionComplete = true
end

function Module.startCompleteAutoFarm(Fluent)
    task.spawn(function()
        local initialFireLevel = Module.getCurrentFireLevel(Fluent)
        if FIRST_EXECUTION_CHECK and (isFullyRevealed or initialFireLevel >= 999) then
            Module.executeExternalScript(Fluent)
            AUTO_FARM_ENABLED = false
            return
        end
        FIRST_EXECUTION_CHECK = false
        stopTweening = false
        visitedParts = {}
        fogClearingComplete = false
        stopMapUnlocking = false
        mapUnlockVisitedParts = {}
        childrenCollectionComplete = false
        childCollectionAttempts = 0
        axeEquipped = false
        lastEquipTime = 0
        diamondChestDetected = false
        diamondChestPosition = nil
        teleportAttemptCount = 0
        STOP_LOG_COLLECTION = false
        for _, child in ipairs(Items:GetChildren()) do
            if child.Name == "Stronghold Diamond Chest" then
                if child:IsA("Model") then
                    diamondChestPosition = child:GetModelCFrame().Position
                elseif child:IsA("BasePart") then
                    diamondChestPosition = child.Position
                end
                diamondChestDetected = true
                teleportAttemptCount = 0
            end
        end
        local fireLevel = Module.getCurrentFireLevel(Fluent)
        if isFullyRevealed or fireLevel >= 999 then
            if diamondChestDetected and not strongholdTimerActive then
                local success, message = Module.attemptDiamondChestTeleport(Fluent)
                if success then
                    ALL_PHASES_COMPLETED = true
                    if isFullyRevealed or Module.getCurrentFireLevel(Fluent) >= 999 then
                        Module.executeExternalScript(Fluent)
                    end
                    AUTO_FARM_ENABLED = false
                    return
                else
                    teleportAttemptCount = teleportAttemptCount + 1
                    lastTeleportAttemptTime = tick()
                end
            end
        elseif fireLevel >= 2 then
            fogClearingComplete = true
        else
            Module.tweenToFogParts(Fluent)
            while not fogClearingComplete and AUTO_FARM_ENABLED do
                task.wait(1)
            end
        end
        if not isFullyRevealed and fireLevel < 999 then
            rainDetectionActive = true
            Module.autoEquipAxe(Fluent)
            task.wait(2)
            local noTreesFoundCount = 0
            local maxFallbackAttempts = 2
            local useCircleSearch = false
            while AUTO_FARM_ENABLED and not isFullyRevealed and not STOP_LOG_COLLECTION do
                if isFullyRevealed or Module.getCurrentFireLevel(Fluent) >= 999 or STOP_LOG_COLLECTION then
                    break
                end
                if rainDetectionActive and Module.checkRainWarnings(Fluent) then
                    while isRaining and AUTO_FARM_ENABLED and not isFullyRevealed and not STOP_LOG_COLLECTION do
                        task.wait(2)
                        Module.checkRainWarnings(Fluent)
                        if isFullyRevealed or Module.getCurrentFireLevel(Fluent) >= 999 or STOP_LOG_COLLECTION then
                            break
                        end
                    end
                    if not AUTO_FARM_ENABLED or isFullyRevealed or STOP_LOG_COLLECTION then
                        break
                    end
                    continue
                end
                local allTrees = {}
                for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
                    if v.Name == "Small Tree" then
                        local position
                        if v:IsA("Model") then
                            position = v:GetModelCFrame().Position
                        elseif v:IsA("BasePart") then
                            position = v.Position
                        end
                        if position then
                            table.insert(allTrees, position)
                        end
                    end
                end
                if #allTrees > 0 then
                    noTreesFoundCount = 0
                    useCircleSearch = false
                    local closestTree = allTrees[1]
                    local closestDist = (HumanoidRootPart.Position - closestTree).Magnitude
                    for i = 2, #allTrees do
                        local dist = (HumanoidRootPart.Position - allTrees[i]).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestTree = allTrees[i]
                        end
                    end
                    Module.teleportToPosition(closestTree)
                    task.wait(2)
                    local treesRemaining = Module.countSmallTrees()
                    while treesRemaining > 0 and AUTO_FARM_ENABLED and not isFullyRevealed and not STOP_LOG_COLLECTION do
                        local chopped = Module.chopSmallTrees()
                        task.wait(0.5)
                        treesRemaining = Module.countSmallTrees()
                        if isFullyRevealed or Module.getCurrentFireLevel(Fluent) >= 999 or STOP_LOG_COLLECTION then
                            break
                        end
                    end
                else
                    noTreesFoundCount = noTreesFoundCount + 1
                    if noTreesFoundCount <= maxFallbackAttempts then
                        local fallbackCFrame = Module.getNextFallbackPosition()
                        Module.teleportToPosition(fallbackCFrame)
                        task.wait(2)
                        local chopped = Module.chopSmallTrees()
                        if chopped > 0 then
                            noTreesFoundCount = 0
                        end
                        task.wait(2)
                    else
                        if not useCircleSearch then
                            useCircleSearch = true
                        end
                        local radius_list = {400, 600, 825, 1150, 1400}
                        local treeFound = false
                        for i, radius in ipairs(radius_list) do
                            if treeFound or not AUTO_FARM_ENABLED or isFullyRevealed or STOP_LOG_COLLECTION then
                                break
                            end
                            local centerPoint = Vector3.new(0, 15, 0)
                            local speed = 1/(2*i)
                            local angle = 0
                            local fullCircle = 2 * math.pi
                            while angle < fullCircle and AUTO_FARM_ENABLED and not isFullyRevealed and not STOP_LOG_COLLECTION do
                                local deltaTime = task.wait()
                                angle = math.min(angle + (speed * deltaTime), fullCircle)
                                local x = centerPoint.X + radius * math.cos(angle)
                                local z = centerPoint.Z + radius * math.sin(angle)
                                local newPosition = Vector3.new(x, centerPoint.Y, z)
                                HumanoidRootPart.CFrame = CFrame.new(newPosition)
                                local nearbyTrees = {}
                                for _, v in pairs(workspace:WaitForChild("Map"):GetDescendants()) do
                                    if v.Name == "Small Tree" then
                                        local position
                                        if v:IsA("Model") then
                                            position = v:GetModelCFrame().Position
                                        elseif v:IsA("BasePart") then
                                            position = v.Position
                                        end
                                        if position and (position - HumanoidRootPart.Position).Magnitude < 150 then
                                            table.insert(nearbyTrees, position)
                                        end
                                    end
                                end
                                if #nearbyTrees > 0 then
                                    treeFound = true
                                    noTreesFoundCount = 0
                                    useCircleSearch = false
                                    local closestTree = nearbyTrees[1]
                                    local closestDist = (HumanoidRootPart.Position - closestTree).Magnitude
                                    for j = 2, #nearbyTrees do
                                    local dist = (HumanoidRootPart.Position - nearbyTrees[j]).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closestTree = nearbyTrees[j]
                                    end
                                end
                                Module.teleportToPosition(closestTree)
                                task.wait(2)
                                local treesRemaining = Module.countSmallTrees()
                                while treesRemaining > 0 and AUTO_FARM_ENABLED and not isFullyRevealed and not STOP_LOG_COLLECTION do
                                    local chopped = Module.chopSmallTrees()
                                    task.wait(0.5)
                                    treesRemaining = Module.countSmallTrees()
                                    if isFullyRevealed or Module.getCurrentFireLevel(Fluent) >= 999 or STOP_LOG_COLLECTION then
                                        break
                                    end
                                end
                                break
                            end
                        end
                        if not treeFound then
                            noTreesFoundCount = noTreesFoundCount + 1
                            if noTreesFoundCount > maxFallbackAttempts then
                                local fallbackCFrame = Module.getNextFallbackPosition()
                                Module.teleportToPosition(fallbackCFrame)
                                task.wait(2)
                            end
                        end
                    end
                end
                local collected = Module.collectLogsToMainFire(Fluent)
                if collected > 0 then
                    Fluent:Notify({
                        Title = "Fuel Collected",
                        Content = "Moved " .. collected .. " fuel items to Main Fire",
                        Duration = 2
                    })
                end
                task.wait(1)
                if isFullyRevealed or Module.getCurrentFireLevel(Fluent) >= 999 or STOP_LOG_COLLECTION then
                    break
                end
            end
        end
        if AUTO_FARM_ENABLED and not isFullyRevealed then
            Module.unlockAllMapAreas(Fluent)
            task.wait(2)
        end
        if AUTO_FARM_ENABLED then
            Module.collectAllChildren(Fluent)
            task.wait(2)
        end
        if AUTO_FARM_ENABLED and diamondChestDetected and not strongholdTimerActive then
            local success, message = Module.attemptDiamondChestTeleport(Fluent)
            if success then
                ALL_PHASES_COMPLETED = true
                Fluent:Notify({
                    Title = "Diamond Chest Sequence Initiated",
                    Content = message,
                    Duration = 5
                })
            else
                Fluent:Notify({
                    Title = "Diamond Chest Teleport Failed",
                    Content = message .. " (Attempt " .. teleportAttemptCount .. "/" .. maxTeleportAttempts .. ")",
                    Duration = 5
                })
                teleportAttemptCount = teleportAttemptCount + 1
                lastTeleportAttemptTime = tick()
                if teleportAttemptCount >= maxTeleportAttempts then
                    Fluent:Notify({
                        Title = "Max Teleport Attempts Reached",
                        Content = "Failed to teleport to diamond chest after " .. maxTeleportAttempts .. " attempts",
                        Duration = 5
                    })
                end
            end
        end
        if AUTO_FARM_ENABLED and not ALL_PHASES_COMPLETED then
            Module.executeDiamondChestSequence(Fluent)
            ALL_PHASES_COMPLETED = true
        end
        Fluent:Notify({
            Title = "Auto Farm Completed",
            Content = "All farming phases completed or stopped",
            Duration = 5
        })
        AUTO_FARM_ENABLED = false
    end)
end

function Module.initialize(Fluent)
    AUTO_FARM_ENABLED = true
    Module.initializeFireLevelTracking(Fluent)
    Module.initializeStrongholdTracking(Fluent)
    if ANTI_VOID_ENABLED then
        Module.enableAntiVoid()
    end
    if DIAMOND_CHEST_DETECTION then
        diamondChestConnection = Items.ChildAdded:Connect(function(child)
            if child.Name == "Stronghold Diamond Chest" then
                if child:IsA("Model") then
                    diamondChestPosition = child:GetModelCFrame().Position
                elseif child:IsA("BasePart") then
                    diamondChestPosition = child.Position
                end
                diamondChestDetected = true
                teleportAttemptCount = 0
                Fluent:Notify({
                    Title = "Diamond Chest Detected",
                    Content = "Stronghold Diamond Chest found - preparing sequence",
                    Duration = 5
                })
                if not strongholdTimerActive then
                    Module.attemptDiamondChestTeleport(Fluent)
                end
            end
        end)
    end
    Module.startCompleteAutoFarm(Fluent)
end

function Module.stop()
    AUTO_FARM_ENABLED = false
    STOP_LOG_COLLECTION = true
    stopTweening = true
    stopMapUnlocking = true
    if cultistKillerConnection then
        cultistKillerConnection:Disconnect()
        cultistKillerConnection = nil
    end
    if diamondChestConnection then
        diamondChestConnection:Disconnect()
        diamondChestConnection = nil
    end
    Module.disableAntiVoid()
end

return Module
