-- Protected Script (Spanish)
-- Script ID: 07f6d589527351afca9521a42eab1806
-- Migrated: 2025-09-11T13:21:05.023Z
-- Auto-migrated from encrypted storage to GitHub

local Fluent = loadstring(game:HttpGet("__URL_73ded1c00b5b27af__"))()

local Window = Fluent:CreateWindow({
    Title = "COMBO_WICK",
    SubTitle = "",
    TabWidth = 80,
    Size = UDim2.fromOffset(300, 200),
    Acrylic = false,
    Theme = "Dark"
})

local Tab = Window:AddTab({ Title = "Principal", Icon = "" })
local ShopTab = Window:AddTab({ Title = "Tienda", Icon = "" })

local autoFarmEnabled = false
local autoSellEnabled = false
local sellCoroutine
local farmConnections = {}
local lastPosition = nil
local isCollecting = false
local isSelling = false

-- Fast collection function
local function teleportAndCollect(npc)
    if isSelling then
        print("Skipping collection - currently selling")
        return
    end
    
    isCollecting = true
    local prompt = npc:FindFirstChild("CollectPrompt")
    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
    if prompt and npcHRP then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        
        -- Store current position if not selling
        if not isSelling then
            lastPosition = hrp.CFrame
        end
        
        hrp.CFrame = npcHRP.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.05) -- Very fast
        fireproximityprompt(prompt)
        print("Collected from:", npc.Name)
    end
    task.wait(0.1)
    isCollecting = false
end

-- Enhanced FullMark detection with reconnection
local function setupFullMarkDetection(npc)
    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
    if not npcHRP then return end
    
    -- Check if FullMark already exists
    local fullMark = npcHRP:FindFirstChild("FullMark")
    if fullMark then
        task.spawn(function()
            teleportAndCollect(npc)
        end)
    end
    
    -- Monitor for FullMark creation with robust connection
    local connection
    connection = npcHRP.ChildAdded:Connect(function(child)
        if child.Name == "FullMark" and autoFarmEnabled then
            task.spawn(function()
                task.wait(0.01) -- Minimal delay
                teleportAndCollect(npc)
            end)
        end
    end)
    
    table.insert(farmConnections, connection)
    
    -- Also monitor FullMark removal to be ready for next cycle
    local removalConnection
    removalConnection = npcHRP.ChildRemoved:Connect(function(child)
        if child.Name == "FullMark" and autoFarmEnabled then
            -- Generator was just collected, ready for next cycle
            print("FullMark removed from:", npc.Name, "- ready for next cycle")
        end
    end)
    
    table.insert(farmConnections, removalConnection)
end

-- Continuous monitoring to catch missed generators
local function startContinuousMonitoring()
    task.spawn(function()
        while autoFarmEnabled do
            task.wait(2) -- Check every 2 seconds
            if not autoFarmEnabled then break end
            
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            
            -- Find player's plot
            local myPlot
            for _, plot in ipairs(workspace.Plots:GetChildren()) do
                local owner = plot:GetAttribute("Owner")
                if owner == player.Name or owner == player.DisplayName then
                    myPlot = plot
                    break
                end
            end
            
            if myPlot then
                local generators = myPlot:FindFirstChild("Generators")
                if generators then
                    for _, npc in ipairs(generators:GetChildren()) do
                        if npc:IsA("Model") then
                            local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                            if npcHRP then
                                local fullMark = npcHRP:FindFirstChild("FullMark")
                                if fullMark and not isCollecting and not isSelling then
                                    print("Found missed FullMark on:", npc.Name)
                                    task.spawn(function()
                                        teleportAndCollect(npc)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

Tab:AddToggle("AutoFarm", {Title = "Auto Granja", Default = false}):OnChanged(function(value)
    autoFarmEnabled = value
    
    -- Clean up old connections
    for _, connection in ipairs(farmConnections) do
        connection:Disconnect()
    end
    farmConnections = {}
    
    if value then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        
        -- Find player's plot
        local myPlot
        for _, plot in ipairs(workspace.Plots:GetChildren()) do
            local owner = plot:GetAttribute("Owner")
            if owner == player.Name or owner == player.DisplayName then
                myPlot = plot
                print("Found your plot:", plot.Name)
                break
            end
        end
        
        if not myPlot then
            warn("No plot found!")
            return
        end
        
        -- Setup detection for all generators
        local generators = myPlot:FindFirstChild("Generators")
        if generators then
            for _, npc in ipairs(generators:GetChildren()) do
                if npc:IsA("Model") then
                    setupFullMarkDetection(npc)
                end
            end
            
            -- Monitor for new generators being added
            local newGenConnection = generators.ChildAdded:Connect(function(npc)
                if npc:IsA("Model") and autoFarmEnabled then
                    task.wait(1) -- Wait for generator to fully load
                    setupFullMarkDetection(npc)
                end
            end)
            table.insert(farmConnections, newGenConnection)
        end
        
        -- Start continuous monitoring
        startContinuousMonitoring()
    end
end)

Tab:AddToggle("AutoSell", {Title = "Venta automática", Default = false}):OnChanged(function(value)
    autoSellEnabled = value
    if sellCoroutine then
        task.cancel(sellCoroutine)
        sellCoroutine = nil
    end
    if value then
        sellCoroutine = task.spawn(function()
            while autoSellEnabled do
                -- Wait 6 seconds between sells
                local startTime = tick()
                while tick() - startTime < 6 and autoSellEnabled do
                    task.wait(0.1)
                end
                
                if autoSellEnabled then
                    -- Wait for any active collection to finish
                    while isCollecting and autoSellEnabled do
                        task.wait(0.1)
                    end
                    
                    if not autoSellEnabled then break end
                    
                    isSelling = true
                    
                    local Players = game:GetService("Players")
                    local LocalPlayer = Players.LocalPlayer
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local RunService = game:GetService("RunService")
                    
                    -- Store current position before teleporting
                    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart")
                    local originalPos = hrp.CFrame
                    
                    -- Target position
                    local targetPos = Vector3.new(139.737488, 1.28039455, 8.53126335)
                    -- Drop height above target
                    local dropHeight = 10
                    -- Fire count and delay
                    local fireCount = 10
                    local fireDelay = 0.1
                    
                    local hum = char:WaitForChild("Humanoid")
                    
                    -- Move above target
                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, dropHeight, 0))
                    
                    -- Wait until character is fully on the ground
                    local function onGround()
                        return hum.FloorMaterial ~= Enum.Material.Air
                    end
                    repeat
                        task.wait(0.05)
                    until onGround()
                    
                    -- Wait a tiny extra moment to ensure the server registers landing
                    task.wait(0.1)
                    
                    -- Get remote
                    local sellRemote = ReplicatedStorage:WaitForChild("Events", 9e9)
                        :WaitForChild("Client", 9e9)
                        :WaitForChild("Sell", 9e9)
                        :WaitForChild("SellRequest", 9e9)
                    
                    local args = {[1] = true}
                    
                    -- Fire multiple times
                    for i = 1, fireCount do
                        local success, err = pcall(function()
                            sellRemote:InvokeServer(unpack(args))
                        end)
                        if not success then
                            warn("Failed to fire SellRequest:", err)
                        end
                        task.wait(fireDelay)
                    end
                    
                    -- Return to original position
                    task.wait(0.2)
                    hrp.CFrame = originalPos
                    print("Returned to original position after selling")
                    
                    isSelling = false
                end
            end
        end)
    end
end)

-- Auto-buy function
local function buyItem(itemName)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local args = {[1] = itemName}
    
    local success, err = pcall(function()
        ReplicatedStorage:WaitForChild("Events", 9e9)
            :WaitForChild("Client", 9e9)
            :WaitForChild("Stock", 9e9)
            :WaitForChild("BuyRequest", 9e9):InvokeServer(unpack(args))
    end)
    
    if success then
        print("Successfully bought:", itemName)
    else
        warn("Failed to buy", itemName, ":", err)
    end
end

-- Shop toggles with individual control
local shopToggles = {}

local shopItems = {
    "Catamaran Caster",
    "Viking Fisher", 
    "Net Caster Tom",
    "Kayak Guys",
    "Gnomes",
    "Tote Boat Theo",
    "The Cousin",
    "Net Caster Ava",
    "Sand Spike Sam",
    "Pier Jig Pair",
    "Bucket Buddy",
    "Rod Rookie"
}

for _, itemName in ipairs(shopItems) do
    local toggleId = "Buy" .. itemName:gsub(" ", ""):gsub("'", "")
    shopToggles[toggleId] = false
    
    ShopTab:AddToggle(toggleId, {
        Title = "Compra automática" .. itemName, 
        Default = false
    }):OnChanged(function(value)
        shopToggles[toggleId] = value
        
        if value then
            -- Buy the item immediately when toggled on
            buyItem(itemName)
            
            -- Start continuous buying
            task.spawn(function()
                while shopToggles[toggleId] do
                    task.wait(1) -- Wait 1 second between purchases
                    if shopToggles[toggleId] then
                        buyItem(itemName)
                    end
                end
            end)
        end
    end)
end

-- Custom Item Section
ShopTab:AddParagraph({
    Title = "Elementos personalizados",
    Content = "Añadir sus propios artículos a la compra automática"
})

local customItemName = ""
local customToggles = {}

ShopTab:AddInput("CustomItemInput", {
    Title = "Nombre del elemento",
    Default = "",
    Placeholder = "Enter item name here...",
    Numeric = false,
    Finished = true,
}):OnChanged(function(value)
    customItemName = value
    print("Custom item name set to:", customItemName)
end)

ShopTab:AddButton({
    Title = "Añadir elemento personalizado",
    Description = "Creates a toggle for the entered item",
    Callback = function()
        print("Button clicked! Current customItemName:", customItemName)
        if customItemName ~= "" and customItemName ~= nil and not customToggles[customItemName] then
            local toggleId = "Custom_" .. customItemName:gsub(" ", ""):gsub("'", ""):gsub("-", "")
            customToggles[customItemName] = false
            
            print("Creating toggle for:", customItemName)
            
            -- Create the toggle
            ShopTab:AddToggle(toggleId, {
                Title = "Compra automática" .. customItemName,
                Default = false
            }):OnChanged(function(value)
                customToggles[customItemName] = value
                print("Custom toggle changed:", customItemName, "=", value)
                
                if value then
                    print("Starting auto-buy for:", customItemName)
                    -- Buy immediately
                    buyItem(customItemName)
                    
                    -- Start continuous buying
                    task.spawn(function()
                        while customToggles[customItemName] do
                            task.wait(1)
                            if customToggles[customItemName] then
                                buyItem(customItemName)
                            end
                        end
                    end)
                end
            end)
            
            print("Successfully added custom item toggle for:", customItemName)
            
        elseif customItemName == "" or customItemName == nil then
            warn("Please enter an item name first! Current value:", customItemName)
        else
            warn("Item already exists:", customItemName)
        end
    end
})

-- Anti-AFK Status
Tab:AddParagraph({
    Title = "Situación anti-AFK",
    Content = "Activa"
})

-- Anti-AFK (unchanged, already efficient)
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local antiAfkEnabled = true

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    if antiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

task.spawn(function()
    while true do
        task.wait(math.random(120, 180))
        if antiAfkEnabled then
            local methods = {
                function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                end,
                function()
                    local camera = workspace.CurrentCamera
                    local currentCFrame = camera.CFrame
                    camera.CFrame = currentCFrame * CFrame.Angles(0, math.rad(0.1), 0)
                    task.wait(0.1)
                    camera.CFrame = currentCFrame
                end,
                function()
                    VirtualUser:MoveMouse(Vector2.new(1, 1))
                    task.wait(0.1)
                    VirtualUser:MoveMouse(Vector2.new(-1, -1))
                end,
                function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                end
            }
            local randomMethod = methods[math.random(1, #methods)]
            pcall(randomMethod)
        end
    end
end)