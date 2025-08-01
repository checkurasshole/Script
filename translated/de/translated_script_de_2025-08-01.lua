local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "COMBO_DOCHT",
    SubTitle = "Für Mobilgeräte optimiert",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Hauptfunktionen", Icon = "target" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Server = Window:AddTab({ Title = "Server-Skripte", Icon = "server" }),
    Watcher = Window:AddTab({ Title = "Brainrot Watcher", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Einstellungen", Icon = "settings" })
}

local Options = Fluent.Options

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local JobId = game.JobId
local Plots = Workspace:WaitForChild("Plots")

local plotTracersEnabled = false
local autoRebirthEnabled = false
local spinEnabled = false
local autoHitEnabled = false
local antiTrapEnabled = false
local speedCoilEnabled = false
local TARGET_SPEED = 70
local speedHookActive = false
local espLoaded = false
local currentESPStatus = false
local autoLockEnabled = false
local autoLockScriptLoaded = false

local spinConnection = nil
local autoHitConnection = nil
local antiTrapConnection = nil
local speedConnection = nil
local plotMonitorConnections = {} -- Track all plot monitoring connections
local tracers = {}
local remoteEventPath = {"Packages", "Net", "RE/BeeLauncher/Shoot"}
local remoteEventParent = nil

-- Connection tracking for cleanup
local allConnections = {}
local function trackConnection(connection)
    if connection then
        table.insert(allConnections, connection)
    end
    return connection
end

local ESP_GITHUB_URL = 'https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/super_scaryw.lua'
local AUTO_LOCK_SCRIPT_URL = 'https://gist.githubusercontent.com/checkurasshole/0807f2476f4bc0d56a9bbe3e9b9ecc54/raw/79169df5f5761dbdda6ae5f4ae31a796b4fe24e3/lock'

local WATCHER_CONFIG = {
    enabled = false,
    selectedBrainrots = {"Lucky Block"},
    watchAll = false,
    discordWebhook = "",
    scanInterval = 5,
    webhookCooldown = 10,
    highestValueEnabled = false
}

local brainrots = {
    'Lucky Block',
    'La Vacca Saturno Saturnita',
    'Sammyni Spiderini',
    'Torrtuginni Dragonfrutini',
    'Los Tralaleritos',
    'Las Tralaleritas',
    'Graipuss Medussi',
    'Pot Hotspot',
    'La Grande Combinazione',
    'Garama and Madundung',
    'Brainrot God',
    'Cocofanto Elefanto',
    'Gattatino Nyanino',
    'Girafa Celestre',
    'Matteo',
    'Tralalero Tralala',
    'Odin Din Din Dun',
    'Unclito Samito',
    'Trenostruzzo Turbo 3000',
    'Tigroligre Frutonni',
    'Orcalero Orcala',
    'Noobini Pizzanini',
}

local trackedAnimals = {}
local foundAnimals = {}
local animalCounts = {}
local lastWebhookTime = 0
local pendingWebhook = false
local watcherConnection = nil

-- Auto Lock Script Functions with fixed GUI management
local function loadAutoLockScript()
    local success, result = pcall(function()
        local scriptContent = game:HttpGet(AUTO_LOCK_SCRIPT_URL)
        
        -- Inject the GUI cleanup fix into the auto lock script
        local fixedScript = scriptContent:gsub(
            "(if currentTime %- warningShownTime < 2 then)",
            "if currentTime - warningShownTime < 2 then"
        )
        
        -- Add proper GUI cleanup when timer resets or goes above 10 seconds
        fixedScript = fixedScript:gsub(
            "(if remainingTime <= 10 and remainingTime > 0 then)",
            [[
            if remainingTime <= 10 and remainingTime > 0 then
                -- Show warning GUI
            elseif remainingTime > 10 or remainingTime <= 0 then
                -- Hide/cleanup warning GUI when timer resets or goes above 10 seconds
                if warningGui and warningGui.Parent then
                    warningGui:Destroy()
                    warningGui = nil
                end
                warningShown = false
                warningShownTime = 0
            end
            
            if remainingTime <= 10 and remainingTime > 0 then]]
        )
        
        loadstring(fixedScript)()
        return true
    end)
    
    if success then
        autoLockScriptLoaded = true
        return true
    else
        return false
    end
end

local function toggleAutoLock(value)
    autoLockEnabled = value
    
    if not autoLockScriptLoaded then
        if not loadAutoLockScript() then
            return false
        end
        task.wait(1)
    end
    
    if value then
        if _G.AUTO_LOCK_FUNCTIONS then
            _G.AUTO_LOCK_FUNCTIONS.start()
        else
            autoLockScriptLoaded = false
            return false
        end
    else
        if _G.AUTO_LOCK_FUNCTIONS then
            _G.AUTO_LOCK_FUNCTIONS.stop()
            -- Also cleanup any remaining GUI elements
            if _G.AUTO_LOCK_FUNCTIONS.cleanup then
                _G.AUTO_LOCK_FUNCTIONS.cleanup()
            end
        end
    end
    
    return true
end

local function getOwnPlot()
    for _, plot in pairs(Plots:GetChildren()) do
        local ownerTag = plot:FindFirstChild("Owner")
        if ownerTag and ownerTag.Value == LocalPlayer then
            return plot
        end
    end
    return nil
end

local ownPlot = getOwnPlot()

-- Server Join Function
local function joinServerFromInput(input)
    if not input or input == "" then
        return
    end
    
    input = input:gsub("%s+", "")
    
    local placeIdMatch = input:match("TeleportToPlaceInstance%((%d+)")
    local jobIdMatch = input:match('TeleportToPlaceInstance%(%d+,%s*"([^"]+)"')
    
    if placeIdMatch and jobIdMatch then
        local placeIdNum = tonumber(placeIdMatch)
        if placeIdNum then
            local success, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(placeIdNum, jobIdMatch)
            end)
        end
    elseif input:match("^[a-fA-F0-9%-]+$") and #input >= 32 then
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, input)
        end)
    end
end

local function autoRebirth()
    while autoRebirthEnabled do
        local args = {}
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Packages", 9e9):WaitForChild("Net", 9e9):WaitForChild("RF/Rebirth/RequestRebirth", 9e9):InvokeServer(unpack(args))
        end)
        task.wait(3)
    end
end

local Camera = Workspace.CurrentCamera

local function createTracer(index, targetPart)
    if tracers[index] then return end

    local text = Drawing.new("Text")
    text.Size = 30
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    text.Font = 18
    text.Color = Color3.new(1, 1, 1)
    text.Visible = false

    tracers[index] = {
        text = text,
        part = targetPart,
        connection = nil
    }

    tracers[index].connection = trackConnection(RunService.Heartbeat:Connect(function()
        if not targetPart or not targetPart:IsDescendantOf(Workspace) then
            text.Visible = false
            return
        end

        local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if onScreen then
            text.Position = Vector2.new(pos.X, pos.Y - 15)
            text.Visible = true
        else
            text.Visible = false
        end
    end))
end

local function updateTracerText(index, text)
    if tracers[index] then
        tracers[index].text.Text = text
        tracers[index].text.Color = Color3.new(1, 1, 1) -- White color for all timers
    end
end

local function removeTracer(index)
    if tracers[index] then
        local tracer = tracers[index]
        if tracer.text then
            tracer.text:Remove()
            tracer.text = nil
        end
        if tracer.connection then
            tracer.connection:Disconnect()
            tracer.connection = nil
        end
        tracers[index] = nil
    end
end

-- Fixed plot monitoring with proper cleanup
local function monitorPlot(plot)
    if plot == ownPlot then return end
    
    local plotId = tostring(plot)
    
    -- Clean up existing monitor for this plot
    if plotMonitorConnections[plotId] then
        task.cancel(plotMonitorConnections[plotId])
        plotMonitorConnections[plotId] = nil
    end
    
    plotMonitorConnections[plotId] = task.spawn(function()
        local index = plotId
        
        while plot:IsDescendantOf(Workspace) and plotTracersEnabled do
            local success, err = pcall(function()
                local purchases = plot:FindFirstChild("Purchases")
                local block = purchases and purchases:FindFirstChild("PlotBlock")
                local main = block and block:FindFirstChild("Main")
                local gui = main and main:FindFirstChild("BillboardGui")
                local timerLabel = gui and gui:FindFirstChild("RemainingTime")
                
                -- Check if timer exists and is visible
                if timerLabel and timerLabel:IsA("TextLabel") and timerLabel.Visible then
                    local timeText = timerLabel.Text or ""
                    local time = tonumber(timeText:match("%d+"))
                    
                    if time and time >= 0 then
                        -- Timer found - show it
                        createTracer(index, main)
                        updateTracerText(index, time .. "s")
                    else
                        -- Invalid timer - remove tracer
                        removeTracer(index)
                    end
                else
                    -- No timer visible - remove tracer
                    removeTracer(index)
                end
            end)
            
            if not success then
                removeTracer(index)
                break
            end
            task.wait(1) -- Check every second
        end
        removeTracer(index)
        plotMonitorConnections[plotId] = nil
    end)
end

-- Fixed plot tracer cleanup
local function cleanupPlotTracers()
    -- Clean up all tracers
    for index, _ in pairs(tracers) do
        removeTracer(index)
    end
    
    -- Clean up all plot monitoring connections
    for plotId, connection in pairs(plotMonitorConnections) do
        if connection then
            task.cancel(connection)
        end
        plotMonitorConnections[plotId] = nil
    end
    
    plotMonitorConnections = {}
end

local function startPlotTracers()
    -- Clean up existing tracers first
    cleanupPlotTracers()
    
    -- Monitor all existing plots
    for _, plot in ipairs(Plots:GetChildren()) do
        if plot ~= ownPlot then
            task.wait(0.1) -- Small delay to prevent lag
            monitorPlot(plot)
        end
    end
    
    -- Monitor new plots that get added
    local childAddedConnection = Plots.ChildAdded:Connect(function(newPlot)
        if plotTracersEnabled and newPlot ~= ownPlot then
            task.wait(2) -- Wait for plot to fully load before monitoring
            monitorPlot(newPlot)
        end
    end)
    trackConnection(childAddedConnection)
    
    -- Also monitor when plots get removed
    local childRemovedConnection = Plots.ChildRemoved:Connect(function(removedPlot)
        local plotId = tostring(removedPlot)
        if plotMonitorConnections[plotId] then
            task.cancel(plotMonitorConnections[plotId])
            plotMonitorConnections[plotId] = nil
        end
        removeTracer(plotId)
    end)
    trackConnection(childRemovedConnection)
end

local function performJumpBoost(boostAmount)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoid and rootPart then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        bodyVelocity.Velocity = Vector3.new(0, boostAmount, 0)
        bodyVelocity.Parent = rootPart
        game:GetService("Debris"):AddItem(bodyVelocity, 0.5)
    end
end

local function toggleSpin(value)
    spinEnabled = value
    if spinEnabled then
        if not spinConnection then
            spinConnection = trackConnection(RunService.Heartbeat:Connect(function()
                if spinEnabled then
                    local args = {}
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Packages", 9e9):WaitForChild("Net", 9e9):WaitForChild("RE/RainbowSpinWheelService/Spin", 9e9):FireServer(unpack(args))
                    end)
                    task.wait(0.2)
                end
            end))
        end
    else
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
    end
end

local function toggleAutoHit(value)
    autoHitEnabled = value
    if autoHitEnabled then
        if not autoHitConnection then
            autoHitConnection = trackConnection(RunService.Heartbeat:Connect(function()
                if autoHitEnabled then
                    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    task.wait(0.2)
                end
            end))
        end
    else
        if autoHitConnection then
            autoHitConnection:Disconnect()
            autoHitConnection = nil
        end
    end
end

local function giveAllTools()
    local itemsFolder = ReplicatedStorage:WaitForChild("Items")
    for _, item in pairs(itemsFolder:GetChildren()) do
        if item:IsA("Tool") then
            local clone = item:Clone()
            clone.Parent = LocalPlayer:WaitForChild("Backpack")
        end
    end
end

local function hasSpeedCoil()
    return (LocalPlayer.Backpack:FindFirstChild("Speed Coil") or 
            (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Speed Coil")))
end

local function equipSpeedCoil()
    local speedCoil = LocalPlayer.Backpack:FindFirstChild("Speed Coil")
    if speedCoil and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:EquipTool(speedCoil)
        return true
    end
    return false
end

local function purchaseSpeedCoil()
    local args = { [1] = "Speed Coil" }
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Packages", 9e9):WaitForChild("Net", 9e9):WaitForChild("RF/CoinsShopService/RequestBuy", 9e9):InvokeServer(unpack(args))
    end)
    return success
end

local function hookHumanoidSpeed(humanoid)
    if not humanoid then return end
    
    if speedConnection then
        speedConnection:Disconnect()
    end
    
    speedConnection = trackConnection(RunService.Heartbeat:Connect(function()
        if speedHookActive and humanoid.WalkSpeed ~= TARGET_SPEED then
            humanoid.WalkSpeed = TARGET_SPEED
        end
    end))
    
    local speedChangedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if speedHookActive and humanoid.WalkSpeed ~= TARGET_SPEED then
            humanoid.WalkSpeed = TARGET_SPEED
        end
    end)
    trackConnection(speedChangedConnection)
end

local function activateSpeedHook()
    if not hasSpeedCoil() then
        if not purchaseSpeedCoil() then
            return false
        end
        task.wait(1)
    end
    
    if not equipSpeedCoil() then
        task.wait(0.5)
        if not equipSpeedCoil() then
            return false
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        speedHookActive = true
        LocalPlayer.Character.Humanoid.WalkSpeed = TARGET_SPEED
        hookHumanoidSpeed(LocalPlayer.Character.Humanoid)
        return true
    end
    return false
end

local function deactivateSpeedHook()
    speedHookActive = false
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Speed Coil") then
        LocalPlayer.Character.Humanoid:UnequipTools()
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end

local function loadESPFromGitHub()
    local success, result = pcall(function()
        return game:HttpGet(ESP_GITHUB_URL)
    end)

    if success and result then
        local espFunction, loadError = loadstring(result)
        if espFunction then
            local executeSuccess, executeError = pcall(espFunction)
            if executeSuccess then
                espLoaded = true
                return true
            end
        end
    end

    espLoaded = false
    return false
end

local function enableESP()
    if not espLoaded then
        if not loadESPFromGitHub() then
            return false
        end
    end

    if _G.enableESP then
        currentESPStatus = _G.enableESP()
        return true
    end
    return false
end

local function disableESP()
    if _G.disableESP then
        currentESPStatus = not _G.disableESP()
        return true
    end
    return false
end

local function disableTraps()
    while antiTrapEnabled do
        pcall(function()
            for _, trap in pairs(Workspace:GetChildren()) do
                if trap:IsA("Model") and trap.Name == "Trap" then
                    for _, part in pairs(trap:GetDescendants()) do
                        if part:IsA("TouchTransmitter") or part:IsA("TouchInterest") then
                            part:Destroy()
                        end
                    end
                end
            end
        end)
        task.wait(5)
    end
end

local function buyItem(itemName)
    local args = { [1] = itemName }
    pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Packages", 9e9)
            :WaitForChild("Net", 9e9)
            :WaitForChild("RF/CoinsShopService/RequestBuy", 9e9)
            :InvokeServer(unpack(args))
    end)
end

local suffixes = {
    k = 1e3,
    m = 1e6,
    b = 1e9,
    t = 1e12
}

local function isInMovingAnimals(instance)
    return instance:IsDescendantOf(Workspace:FindFirstChild("MovingAnimals") or Instance.new("Folder"))
end

local function parsePrice(text)
    text = text:lower():gsub("[^%d%.kmbt]", "")
    local num = tonumber(text:match("[%d%.]+")) or 0
    local suffix = text:match("[kmbt]")
    return suffix and (num * suffixes[suffix]) or num
end

-- Fixed ESP cleanup function
local function clearOldESPs()
    for _, highlight in ipairs(Workspace:GetDescendants()) do
        if highlight:IsA("Highlight") and highlight.Name:match("^TopAnimalHighlight%d$") then
            highlight:Destroy()
        end
        if highlight:IsA("BillboardGui") and highlight.Name:match("^TopAnimalLabel%d$") then
            highlight:Destroy()
        end
    end
end

local function insertTopAnimal(topAnimals, animal)
    for i, a in ipairs(topAnimals) do
        if animal.price > a.price then
            table.insert(topAnimals, i, animal)
            if #topAnimals > 3 then
                table.remove(topAnimals)
            end
            return
        end
    end
    if #topAnimals < 3 then
        table.insert(topAnimals, animal)
    end
end

local function addESP(animal, index)
    if not animal.animalModel then return end
    
    local highlight = Instance.new("Highlight")
    local colors = {
        Color3.fromRGB(255, 215, 0),
        Color3.fromRGB(192, 192, 192),
        Color3.fromRGB(205, 127, 50)
    }
    highlight.FillColor = colors[index] or Color3.new(1,1,0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.FillTransparency = 0.75
    highlight.Adornee = animal.animalModel
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Name = "TopTierHighlight"..index
    highlight.Parent = animal.animalModel

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 220, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Name = "TopTierLabel"..index
    billboard.Parent = animal.animalModel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.TextColor3 = colors[index] or Color3.new(1,1,0)
    label.Font = Enum.Font.SourceSansBold
    label.Text = string.format("#%d: %s | %s", index, animal.name, animal.rawPrice)
    label.Parent = billboard
end

-- Optimized highest value pet scanning with better performance
local function scanHighestValuePets()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then 
        return 
    end
    
    -- Clear old ESPs first to prevent accumulation
    clearOldESPs()
    
    local topAnimals = {}
    local plotList = plots:GetChildren()
    
    -- Process in smaller batches with more frequent yields
    for i = 1, #plotList do
        local plot = plotList[i]
        
        -- Yield every 3 plots instead of 5 to reduce lag spikes
        if i % 3 == 0 then
            task.wait()
        end
        
        local success = pcall(function()
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, podium in ipairs(podiums:GetChildren()) do
                    local base = podium:FindFirstChild("Base")
                    if base then
                        local spawn = base:FindFirstChild("Spawn")
                        if spawn then
                            local attachment = spawn:FindFirstChild("Attachment")
                            if attachment then
                                local overhead = attachment:FindFirstChild("AnimalOverhead")
                                if overhead and not isInMovingAnimals(overhead) then
                                    local displayName = overhead:FindFirstChild("DisplayName")
                                    local price = overhead:FindFirstChild("Price")

                                    if displayName and price and displayName:IsA("TextLabel") and price:IsA("TextLabel") then
                                        local realPrice = parsePrice(price.Text)
                                        if realPrice > 5000 then -- Increased threshold to reduce processing
                                            insertTopAnimal(topAnimals, {
                                                price = realPrice,
                                                name = displayName.Text,
                                                rawPrice = price.Text,
                                                plot = plot.Name,
                                                overhead = overhead,
                                                animalModel = podium:FindFirstChildWhichIsA("Model", true) or podium
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- Add ESP for top animals
    for i, animal in ipairs(topAnimals) do
        addESP(animal, i)
    end
end

local function sendDiscordWebhook(includeServerInfo)
    if WATCHER_CONFIG.discordWebhook == "" or not WATCHER_CONFIG.discordWebhook:find("discord.com/api/webhooks") then 
        return 
    end
    
    local animalList = {}
    local totalFound = 0
    
    if includeServerInfo then
        -- Send current server info
        local joinScript = 'game:GetService("TeleportService"):TeleportToPlaceInstance(' .. PlaceId .. ', "' .. JobId .. '")'
        
        local embed = {
            {
                title = "Server Information",
                description = "Current server details:\n\n**Server ID:** " .. JobId .. "\n\n**Join Command:**\n```lua\n" .. joinScript .. "\n```",
                color = 3447003, -- Blue color
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
        
        local payload = {
            embeds = embed
        }
        
        task.spawn(function()
            pcall(function()
                local jsonPayload = HttpService:JSONEncode(payload)
                
                local httpRequest = nil
                if syn and syn.request then
                    httpRequest = syn.request
                elseif http_request then
                    httpRequest = http_request
                elseif request then
                    httpRequest = request
                else
                    return
                end
                
                httpRequest({
                    Url = WATCHER_CONFIG.discordWebhook,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = jsonPayload
                })
            end)
        end)
        return
    end
    
    if next(animalCounts) == nil then
        return 
    end
    
    for animalName, count in pairs(animalCounts) do
        if count > 1 then
            table.insert(animalList, animalName .. " x" .. count)
        else
            table.insert(animalList, animalName)
        end
        totalFound = totalFound + count
    end
    
    local joinScript = 'game:GetService("TeleportService"):TeleportToPlaceInstance(' .. PlaceId .. ', "' .. JobId .. '")'
    
    local embed = {
        {
            title = "BRAINROT ALERT",
            description = totalFound .. " animals found:\n\n" .. table.concat(animalList, "\n") .. "\n\n**Join Server:**\n```lua\n" .. joinScript .. "\n```",
            color = 16711680,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    local payload = {
        content = "@everyone",
        embeds = embed
    }
    
    task.spawn(function()
        local success, response = pcall(function()
            local jsonPayload = HttpService:JSONEncode(payload)
            
            local httpRequest = nil
            
            if syn and syn.request then
                httpRequest = syn.request
            elseif http_request then
                httpRequest = http_request
            elseif request then
                httpRequest = request
            else
                error("No HTTP request function available")
            end
            
            return httpRequest({
                Url = WATCHER_CONFIG.discordWebhook,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonPayload
            })
        end)
        
        -- Clear references to prevent memory leaks
        animalCounts = {}
        pendingWebhook = false
    end)
end

local function getAnimalDisplayName(animal)
    local success, displayName = pcall(function()
        return animal.HumanoidRootPart.Info.AnimalOverhead.DisplayName.Text
    end)
    
    if success and displayName then
        return displayName
    end
    return nil
end

-- Fixed isTargetBrainrot function
local function isTargetBrainrot(displayName)
    if WATCHER_CONFIG.watchAll then
        -- When watchAll is true, check if the animal is in the brainrots list
        for _, brainrot in pairs(brainrots) do
            if displayName == brainrot then
                return true
            end
        end
        return false
    else
        -- When watchAll is false, check selected brainrots
        for _, selectedBrainrot in pairs(WATCHER_CONFIG.selectedBrainrots) do
            if displayName == selectedBrainrot then
                return true
            end
        end
        return false
    end
end

-- Improved scanAnimals with better memory management
local function scanAnimals()
    if not WATCHER_CONFIG.enabled then return end
    
    local movingAnimals = Workspace:FindFirstChild("MovingAnimals")
    if not movingAnimals then return end
    
    local player = Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local currentAnimals = {}
    local newAnimalsFound = false
    local animalsToCheck = movingAnimals:GetChildren()
    
    local batchSize = 10 -- Further reduced batch size
    local processed = 0
    
    -- Clear invalid references from trackedAnimals
    for animal, _ in pairs(trackedAnimals) do
        if not animal.Parent then
            trackedAnimals[animal] = nil
        end
    end
    
    for i, animal in pairs(animalsToCheck) do
        if processed >= batchSize then
            task.wait()
            processed = 0
        end
        
        if animal:IsA("Model") and animal:FindFirstChild("HumanoidRootPart") then
            local displayName = getAnimalDisplayName(animal)
            
            if displayName and isTargetBrainrot(displayName) then
                currentAnimals[animal] = true
                
                if not trackedAnimals[animal] then
                    trackedAnimals[animal] = true
                    newAnimalsFound = true
                    
                    table.insert(foundAnimals, {
                        animal = animal,
                        name = displayName,
                        foundTime = tick()
                    })
                    
                    animalCounts[displayName] = (animalCounts[displayName] or 0) + 1
                end
            end
        end
        processed = processed + 1
    end
    
    -- Clean up old animal references
    for animal, _ in pairs(trackedAnimals) do
        if not animal.Parent or not currentAnimals[animal] then
            trackedAnimals[animal] = nil
        end
    end
    
    -- Clean up foundAnimals array periodically to prevent memory buildup
    if #foundAnimals > 50 then
        local newFoundAnimals = {}
        for i = #foundAnimals - 25, #foundAnimals do
            if foundAnimals[i] then
                table.insert(newFoundAnimals, foundAnimals[i])
            end
        end
        foundAnimals = newFoundAnimals
    end
    
    if newAnimalsFound and not pendingWebhook then
        local currentTime = tick()
        if currentTime - lastWebhookTime >= WATCHER_CONFIG.webhookCooldown then
            lastWebhookTime = currentTime
            pendingWebhook = true
            
            task.wait(3)
            sendDiscordWebhook(false)
        end
    end
end

-- Copy Job ID Function
local function copyJobId()
    if setclipboard then
        setclipboard(JobId)
    end
end

-- Comprehensive cleanup function
local function cleanupAll()
    -- Disconnect all tracked connections
    for _, connection in pairs(allConnections) do
        if connection and connection.Disconnect then
            connection:Disconnect()
        end
    end
    allConnections = {}
    
    -- Clean up tracers
    cleanupPlotTracers()
    
    -- Clean up individual connections
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    if autoHitConnection then
        autoHitConnection:Disconnect()
        autoHitConnection = nil
    end
    if antiTrapConnection then
        task.cancel(antiTrapConnection)
        antiTrapConnection = nil
    end
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    if watcherConnection then
        task.cancel(watcherConnection)
        watcherConnection = nil
    end
    
    -- Clean up ESP
    if currentESPStatus then
        disableESP()
    end
    clearOldESPs()
    
    -- Clean up auto lock with proper GUI cleanup
    if _G.AUTO_LOCK_FUNCTIONS then
        _G.AUTO_LOCK_FUNCTIONS.cleanup()
        -- Additional cleanup for any remaining warning GUIs
        for _, gui in pairs(Players.LocalPlayer.PlayerGui:GetChildren()) do
            if gui.Name:match("AutoLockWarning") or gui.Name:match("BaseLockWarning") then
                gui:Destroy()
            end
        end
    end
    
    -- Clear all data tables
    trackedAnimals = {}
    foundAnimals = {}
    animalCounts = {}
    tracers = {}
    plotMonitorConnections = {}
    
    -- Reset all flags
    plotTracersEnabled = false
    autoRebirthEnabled = false
    spinEnabled = false
    autoHitEnabled = false
    antiTrapEnabled = false
    speedCoilEnabled = false
    speedHookActive = false
    currentESPStatus = false
    autoLockEnabled = false
    WATCHER_CONFIG.enabled = false
end

-- UI Creation
do
    -- Auto Lock Section at the top of Main tab
    local AutoLockSection = Tabs.Main:AddSection("Base Auto Lock")
    
    local AutoLock = Tabs.Main:AddToggle("AutoLock", {
        Title = "Automatische Sperre",
        Description = "Automatically warns when your base is about to unlock",
        Default = false
    })
    
    AutoLock:OnChanged(function(Value)
        local success = toggleAutoLock(Value)
        if not success then
            AutoLock:SetValue(false)
        end
    end)
    
    local PlotSection = Tabs.Main:AddSection("Plot Functions")
    
    local PlotTracers = Tabs.Main:AddToggle("PlotTracers", {
        Title = "Alle Basistimer anzeigen",
        Description = "Shows timers for all protected bases (existing and new)",
        Default = false
    })
    
    PlotTracers:OnChanged(function(Value)
        plotTracersEnabled = Value
        if Value then
            task.spawn(startPlotTracers)
        else
            cleanupPlotTracers()
        end
    end)
    
    -- Server Join Section
    local ServerSection = Tabs.Main:AddSection("Server Functions")
    
    local ServerJoinInput = Tabs.Main:AddInput("ServerJoinInput", {
        Title = "Server beitreten",
        Description = "Enter server ID or full teleport command",
        Placeholder = "fa6c7b16-b276-403a-b5ea-fb2712b6881b or full command",
        Numeric = false,
        Finished = true,
        Callback = function(Value)
            joinServerFromInput(Value)
        end
    })
    
    local AutoRebirthSection = Tabs.Main:AddSection("Auto Features")
    
    local AutoRebirth = Tabs.Main:AddToggle("AutoRebirth", {
        Title = "Automatische Wiedergeburt",
        Description = "Automatically rebirth your character",
        Default = false
    })
    
    AutoRebirth:OnChanged(function(Value)
        autoRebirthEnabled = Value
        if Value then
            task.spawn(autoRebirth)
        end
    end)
    
    local Spin = Tabs.Main:AddToggle("Spin", {
        Title = "Automatischer Spin",
        Description = "Automatically spin the wheel",
        Default = false
    })
    
    Spin:OnChanged(function(Value)
        toggleSpin(Value)
    end)
    
    local AutoHit = Tabs.Main:AddToggle("AutoHit", {
        Title = "Auto-Treffer",
        Description = "Automatically use equipped tools",
        Default = false
    })
    
    AutoHit:OnChanged(function(Value)
        toggleAutoHit(Value)
    end)
    
    local SpeedSection = Tabs.Main:AddSection("Speed")
    
    local SpeedCoil = Tabs.Main:AddToggle("SpeedCoil", {
        Title = "- Speed Hack",
        Description = "Automatically equip and maintain speed coil",
        Default = false
    })
    
    SpeedCoil:OnChanged(function(Value)
        if Value then
            local success = activateSpeedHook()
            if success then
                speedCoilEnabled = true
            else
                SpeedCoil:SetValue(false)
            end
        else
            speedCoilEnabled = false
            deactivateSpeedHook()
        end
    end)
    
    local ESPSection = Tabs.Main:AddSection("ESP & Visual")
    
    local ESP = Tabs.Main:AddToggle("ESP", {
        Title = "ESP aktivieren",
        Description = "Shows player locations through walls",
        Default = false
    })
    
    ESP:OnChanged(function(Value)
        if Value then
            local success = enableESP()
            if not success then
                ESP:SetValue(false)
            else
                currentESPStatus = true
            end
        else
            disableESP()
            currentESPStatus = false
        end
    end)
    
    local ShowNames = Tabs.Main:AddToggle("ShowNames", {
        Title = "Spielernamen anzeigen",
        Description = "Display player names in ESP",
        Default = true
    })
    
    ShowNames:OnChanged(function(Value)
        if espLoaded and _G.toggleNames then
            _G.toggleNames()
        end
    end)
    
    local ShowInvisible = Tabs.Main:AddToggle("ShowInvisible", {
        Title = "Unsichtbare Spieler anzeigen",
        Description = "Show players using invisibility cloak",
        Default = true
    })
    
    ShowInvisible:OnChanged(function(Value)
        if espLoaded and _G.toggleInvisible then
            _G.toggleInvisible()
        end
    end)
    
    local ProtectionSection = Tabs.Main:AddSection("Protection")
    
    local AntiTrap = Tabs.Main:AddToggle("AntiTrap", {
        Title = "Anti-Falle + Anti-Biene",
        Description = "Prevents trap and bee launcher damage",
        Default = false
    })
    
    AntiTrap:OnChanged(function(Value)
        antiTrapEnabled = Value
        if Value then
            if not antiTrapConnection then
                antiTrapConnection = task.spawn(disableTraps)
            end
        else
            if antiTrapConnection then
                task.cancel(antiTrapConnection)
                antiTrapConnection = nil
            end
        end
    end)
    
    local UtilitySection = Tabs.Main:AddSection("Utility")
    
    Tabs.Main:AddButton({
        Title = "Hochsprung-Boost",
        Description = "Perform a high jump",
        Callback = function()
            performJumpBoost(50)
        end
    })
    
    Tabs.Main:AddButton({
        Title = "Super-Sprung-Boost",
        Description = "Perform an extremely high jump",
        Callback = function()
            performJumpBoost(100)
        end
    })
    
    Tabs.Main:AddButton({
        Title = "Alle Tools",
        Description = "Add all available tools to inventory",
        Callback = function()
            giveAllTools()
        end
    })

    -- Shop Tab
    local ShopItems = Tabs.Shop:AddSection("Shop Items")
    
    local shopItems = {
        {"Invisibility Cloak", "Become invisible to other players"},
        {"Quantum Cloner", "Clone yourself"},
        {"Medusa's Head", "Turn players to stone"},
        {"All Seeing Sentry", "Detect invisible players"},
        {"Rainbowrath Sword", "Powerful rainbow sword"},
        {"Body Swap Potion", "Swap bodies with another player"},
        {"Web Slinger", "Swing around like Spider-Man"},
        {"Trap", "Place traps for other players"}
    }
    
    for _, item in pairs(shopItems) do
        Tabs.Shop:AddButton({
            Title = "Kauf, kaufen, kauf, kaufe, ..." .. item[1],
            Description = item[2],
            Callback = function()
                buyItem(item[1])
            end
        })
    end

    -- Server Scripts Tab
    local ServerScriptsSection = Tabs.Server:AddSection("Server Functions")
    
    Tabs.Server:AddButton({
        Title = "Auftrags-ID kopieren",
        Description = "Copy current server Job ID to clipboard",
        Callback = function()
            copyJobId()
        end
    })
    
    local ServerInfoSection = Tabs.Server:AddSection("Server Information")
    
    local ServerInfoParagraph = Tabs.Server:AddParagraph({
        Title = "Aktuelle Serverdetails",
        Content = "Place ID: " .. PlaceId .. "\nJob ID: " .. JobId
    })

    -- Watcher Tab
    local WatcherSettings = Tabs.Watcher:AddSection("Watcher Settings")
    
    local WebhookInput = Tabs.Watcher:AddInput("WebhookInput", {
        Title = "Discord-Webhook-URL",
        Description = "Enter your Discord webhook URL for notifications",
        Placeholder = "https://discord.com/api/webhooks/...",
        Numeric = false,
        Finished = true,
        Callback = function(Value)
            WATCHER_CONFIG.discordWebhook = Value
            print("Webhook set to: " .. (Value ~= "" and "***WEBHOOK_SET***" or "EMPTY"))
        end
    })
    
    local WatcherToggle = Tabs.Watcher:AddToggle("WatcherToggle", {
        Title = "Beobachter aktivieren",
        Description = "Start scanning for rare animals",
        Default = false
    })
    
    WatcherToggle:OnChanged(function(Value)
        WATCHER_CONFIG.enabled = Value
        
        if Value then
            if not watcherConnection then
                watcherConnection = task.spawn(function()
                    while WATCHER_CONFIG.enabled do
                        local success, err = pcall(scanAnimals)
                        if not success then
                            -- Handle errors gracefully
                        end
                        task.wait(WATCHER_CONFIG.scanInterval)
                    end
                end)
            end
        else
            if watcherConnection then
                task.cancel(watcherConnection)
                watcherConnection = nil
            end
        end
    end)
    
    local WatchAll = Tabs.Watcher:AddToggle("WatchAll", {
        Title = "Alle Brainrots ansehen",
        Description = "Monitor all brainrot animals instead of selected ones",
        Default = false
    })
    
    WatchAll:OnChanged(function(Value)
        WATCHER_CONFIG.watchAll = Value
        -- Clear current tracking when switching modes
        trackedAnimals = {}
        animalCounts = {}
    end)
    
    -- Changed from toggle to button for highest value pets
    Tabs.Watcher:AddButton({
        Title = "Höchster Wert",
        Description = "Find and highlight the 3 most expensive pets on server",
        Callback = function()
            scanHighestValuePets()
        end
    })
    
    Tabs.Watcher:AddButton({
        Title = "Clear PET ESP",
        Description = "Remove all pet ESP highlights",
        Callback = function()
            clearOldESPs()
        end
    })
    
    local BrainrotDropdown = Tabs.Watcher:AddDropdown("BrainrotDropdown", {
        Title = "Brainrots auswählen",
        Description = "Choose which brainrot animals to monitor",
        Values = brainrots,
        Multi = true,
        Default = {"Lucky Block"},
    })
    
    BrainrotDropdown:OnChanged(function(Values)
        WATCHER_CONFIG.selectedBrainrots = Values
        -- Clear current tracking when changing selection
        trackedAnimals = {}
        animalCounts = {}
    end)
    
    local WatcherActions = Tabs.Watcher:AddSection("Actions")
    
    Tabs.Watcher:AddButton({
        Title = "Gefundene Liste löschen",
        Description = "Reset the list of found animals",
        Callback = function()
            foundAnimals = {}
            trackedAnimals = {}
            animalCounts = {}
        end
    })
    
    Tabs.Watcher:AddButton({
        Title = "Test Webhook",
        Description = "Send a test notification to Discord",
        Callback = function()
            if WATCHER_CONFIG.discordWebhook == "" then
                return
            end
            
            animalCounts = {["Test Animal"] = 1, ["Another Test"] = 2}
            if #foundAnimals == 0 then
                table.insert(foundAnimals, {name = "Test", foundTime = tick()})
            end
            
            sendDiscordWebhook(false)
        end
    })
    
    Tabs.Watcher:AddButton({
        Title = "Serverinfo",
        Description = "Send current server information to Discord",
        Callback = function()
            if WATCHER_CONFIG.discordWebhook == "" then
                return
            end
            
            sendDiscordWebhook(true)
        end
    })
    
    local WatcherStatus = Tabs.Watcher:AddSection("Status")
    
    local StatusParagraph = Tabs.Watcher:AddParagraph({
        Title = "Beobachterstatus",
        Content = "Status: Inactive\nFound: 0 animals\nWebhook: Not Set"
    })
    
    -- Status update with memory cleanup
    local statusUpdateConnection = task.spawn(function()
        while true do
            task.wait(5)
            
            local status = WATCHER_CONFIG.enabled and "Active" or "Inactive"
            local foundCount = #foundAnimals
            local webhookStatus = (WATCHER_CONFIG.discordWebhook ~= "" and WATCHER_CONFIG.discordWebhook:find("discord.com/api/webhooks")) 
                and "Connected" or "Not Set"
            local watchMode = WATCHER_CONFIG.watchAll and "All Brainrots" or "Selected Only"
            local autoLockStatus = autoLockEnabled and "Active" or "Inactive"
            
            StatusParagraph:SetDesc("Status: " .. status .. "\nFound: " .. foundCount .. " animals\nWebhook: " .. webhookStatus .. "\nWatch Mode: " .. watchMode .. "\nAuto Lock: " .. autoLockStatus)
            
            -- Periodic memory cleanup
            collectgarbage("collect")
        end
    end)
    trackConnection(statusUpdateConnection)

    -- Settings Tab
    local InterfaceSection = Tabs.Settings:AddSection("Interface")
    
    InterfaceSection:AddColorpicker("InterfaceColor", {
        Title = "Benutzeroberfläche Farbe",
        Description = "Change the UI accent color",
        Default = Color3.fromRGB(0, 255, 140)
    })
    
    InterfaceSection:AddKeybind("ToggleKeybind", {
        Title = "UI Keybind umschalten",
        Mode = "Toggle",
        Default = "LeftControl",
        Callback = function(Value)
        end,
        ChangedCallback = function(New)
        end
    })
    
    local ConfigSection = Tabs.Settings:AddSection("Configuration")
    
    ConfigSection:AddButton({
        Title = "Einstellungen zurücksetzen",
        Description = "Reset all settings to default",
        Callback = function()
            for name, toggle in pairs(Options) do
                if toggle.SetValue then
                    toggle:SetValue(false)
                end
            end
        end
    })
    
    -- Add cleanup button
    ConfigSection:AddButton({
        Title = "Bereinigung erzwingen",
        Description = "Force cleanup all connections and memory",
        Callback = function()
            cleanupAll()
        end
    })
end

-- Improved cleanup on player leaving with better error handling
local playerRemovingConnection = trackConnection(game.Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanupAll()
    end
end))

-- Bee Launcher Protection System
local function getBeeLauncherRemote()
    local current = ReplicatedStorage
    for i = 1, #remoteEventPath - 1 do
        current = current:FindFirstChild(remoteEventPath[i])
        if not current then return nil end
    end
    return current:FindFirstChild(remoteEventPath[#remoteEventPath])
end

local function getRemoteEventParent()
    local current = ReplicatedStorage
    for i = 1, #remoteEventPath - 1 do
        current = current:FindFirstChild(remoteEventPath[i])
        if not current then return nil end
    end
    return current
end

local function destroyRemoteEvent()
    local remote = getBeeLauncherRemote()
    if remote and remote.Name == "RE/BeeLauncher/Shoot" then
        remoteEventParent = getRemoteEventParent()
        remote:Destroy()
        return true
    end
    return false
end

local function recreateRemoteEvent()
    if remoteEventParent and not getBeeLauncherRemote() then
        local newRemoteEvent = Instance.new("RemoteEvent")
        newRemoteEvent.Name = "RE/BeeLauncher/Shoot"
        newRemoteEvent.Parent = remoteEventParent
        return true
    end
    return false
end

local function playerHasBeeLauncherEquipped(player)
    if player == LocalPlayer then return false end
    
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Bee Launcher" then
                return true
            end
        end
    end
    return false
end

local function anyOtherPlayerHasBeeLauncher()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and playerHasBeeLauncherEquipped(player) then
            return true
        end
    end
    return false
end

local function updateRemoteEventStatus()
    if anyOtherPlayerHasBeeLauncher() then
        destroyRemoteEvent()
    else
        recreateRemoteEvent()
    end
end

local function monitorPlayerTools(player)
    if player == LocalPlayer then return end
    
    local function onCharacterAdded(character)
        local childAddedConnection = trackConnection(character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and child.Name == "Bee Launcher" then
                task.wait(0.1)
                updateRemoteEventStatus()
            end
        end))
        
        local childRemovedConnection = trackConnection(character.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") and child.Name == "Bee Launcher" then
                task.wait(0.5)
                updateRemoteEventStatus()
            end
        end))
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    local characterAddedConnection = trackConnection(player.CharacterAdded:Connect(onCharacterAdded))
end

-- Initialize bee launcher protection
remoteEventParent = getRemoteEventParent()
for _, player in pairs(Players:GetPlayers()) do
    monitorPlayerTools(player)
end
local playerAddedConnection = trackConnection(Players.PlayerAdded:Connect(monitorPlayerTools))
local playerRemovingConnection2 = trackConnection(Players.PlayerRemoving:Connect(function(player)
    task.wait(0.5)
    updateRemoteEventStatus()
end))

local beeProtectionConnection = trackConnection(task.spawn(function()
    while true do
        task.wait(10)
        updateRemoteEventStatus()
    end
end))
updateRemoteEventStatus()

-- Character respawn handling with cleanup
local characterAddedConnection = trackConnection(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    
    if speedCoilEnabled then
        task.wait(1)
        if hasSpeedCoil() then
            equipSpeedCoil()
        else
            if purchaseSpeedCoil() then
                task.wait(1)
                equipSpeedCoil()
            end
        end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            hookHumanoidSpeed(LocalPlayer.Character:WaitForChild("Humanoid"))
            LocalPlayer.Character.Humanoid.WalkSpeed = TARGET_SPEED
        end
    end
end))

-- Auto-load Auto Lock script on startup
task.spawn(function()
    task.wait(3)
    loadAutoLockScript()
end)

-- Save/Load Configuration
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ComboChronicleVault")
SaveManager:SetFolder("ComboChronicleVault/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()

-- Final cleanup function for script termination
_G.COMBO_CHRONICLE_CLEANUP = cleanupAll

-- Periodic garbage collection to prevent memory buildup
local gcConnection = trackConnection(task.spawn(function()
    while true do
        task.wait(30) -- Every 30 seconds
        collectgarbage("collect")
    end
end))

-- Initial notification
print("ComboChronicle Vault - Script loaded successfully! Auto Lock module will load automatically. Memory leak fixes applied.")