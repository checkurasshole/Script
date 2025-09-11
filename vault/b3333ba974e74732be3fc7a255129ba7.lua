-- Protected Script (Korean)
-- Script ID: b3333ba974e74732be3fc7a255129ba7
-- Migrated: 2025-09-11T13:20:59.179Z
-- Auto-migrated from encrypted storage to GitHub

local Fluent = loadstring(game:HttpGet("__URL_f49f44bfd926ec17__"))()

local Window = Fluent:CreateWindow({
    Title = "자동차 농장 및 판매",
    SubTitle = "",
    TabWidth = 80,
    Size = UDim2.fromOffset(300, 200),
    Acrylic = false,
    Theme = "Dark"
})

local Tab = Window:AddTab({ Title = "메인", Icon = "" })
local ShopTab = Window:AddTab({ Title = "상점", Icon = "" })

local autoFarmEnabled = false
local autoSellEnabled = false
local sellCoroutine
local farmConnections = {}

-- Fast collection function
local function teleportAndCollect(npc)
    local prompt = npc:FindFirstChild("CollectPrompt")
    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
    if prompt and npcHRP then
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        
        hrp.CFrame = npcHRP.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.1) -- Reduced wait time
        fireproximityprompt(prompt)
        print("Collected from:", npc.Name)
    end
end

-- Fast FullMark detection
local function setupFullMarkDetection(npc)
    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
    if not npcHRP then return end
    
    -- Check if FullMark already exists
    local fullMark = npcHRP:FindFirstChild("FullMark")
    if fullMark then
        teleportAndCollect(npc)
    end
    
    -- Monitor for FullMark creation
    local connection = npcHRP.ChildAdded:Connect(function(child)
        if child.Name == "FullMark" and autoFarmEnabled then
            task.wait(0.05) -- Small delay to ensure it's fully loaded
            teleportAndCollect(npc)
        end
    end)
    
    table.insert(farmConnections, connection)
end

Tab:AddToggle("AutoFarm", {Title = "오토팜", Default = false}):OnChanged(function(value)
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
            
            -- Also monitor for new generators being added
            local newGenConnection = generators.ChildAdded:Connect(function(npc)
                if npc:IsA("Model") and autoFarmEnabled then
                    task.wait(1) -- Wait for generator to fully load
                    setupFullMarkDetection(npc)
                end
            end)
            table.insert(farmConnections, newGenConnection)
        end
    end
end)

Tab:AddToggle("AutoSell", {Title = "자동 판매", Default = false}):OnChanged(function(value)
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
                    local Players = game:GetService("Players")
                    local LocalPlayer = Players.LocalPlayer
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local RunService = game:GetService("RunService")
                    
                    -- Target position
                    local targetPos = Vector3.new(139.737488, 1.28039455, 8.53126335)
                    -- Drop height above target
                    local dropHeight = 10
                    -- Fire count and delay
                    local fireCount = 10
                    local fireDelay = 0.1
                    
                    -- Ensure character exists
                    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart")
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
        Title = "자동 구매" .. itemName, 
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
    Title = "사용자 정의 항목",
    Content = "나만의 아이템을 추가하여 자동 구매"
})

local customItemName = ""
local customToggles = {}

ShopTab:AddInput("CustomItemInput", {
    Title = "제목",
    Default = "",
    Placeholder = "Enter item name here...",
    Numeric = false,
    Finished = true,
}):OnChanged(function(value)
    customItemName = value
    print("Custom item name set to:", customItemName)
end)

ShopTab:AddButton({
    Title = "상점 항목 이름 추가",
    Description = "Creates a toggle for the item you want to buy",
    Callback = function()
        print("Button clicked! Current customItemName:", customItemName)
        if customItemName ~= "" and customItemName ~= nil and not customToggles[customItemName] then
            local toggleId = "Custom_" .. customItemName:gsub(" ", ""):gsub("'", ""):gsub("-", "")
            customToggles[customItemName] = false
            
            print("Creating toggle for:", customItemName)
            
            -- Create the toggle
            ShopTab:AddToggle(toggleId, {
                Title = "자동 구매" .. customItemName,
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
    Title = "반공격 상태",
    Content = "구독 중"
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