-- Script_1751579815899
-- Script ID: 98d6fc735f33a1e0ea7cd2bdef118b13
-- Migrated: 2025-09-11T12:58:08.266Z
-- Auto-migrated from encrypted storage to GitHub

-- Load the main module from GitHub
local mainModule = nil
local moduleLoaded = false

local function loadModule()
    local success, result = pcall(function()
        return loadstring(game:HttpGet('__URL_ad3ec455ebb75577__'))()
    end)
    
    if success then
        mainModule = result
        moduleLoaded = true
        print("✅ Module loaded successfully!")
        return true
    else
        print("❌ Failed to load module:", result)
        return false
    end
end

local Rayfield = loadstring(game:HttpGet('__URL_026f1db5621449f8__'))()
local Window = Rayfield:CreateWindow({
    Name = "ComboChronicle Vault | v3.9",
    LoadingTitle = "ComboChronicle Vault",
    LoadingSubtitle = "By COMBO_WICK | Bang.E.Line",
    Theme = "Ocean",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ComboVault",
        FileName = "Settings"
    }
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- Required Services for Server Browser
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

-- Settings
local cropName = "Carrot"
local CollectBatchPause = 1.5
local AutoSellInterval = 60
local AutoCollectEnabled = false
local AutoSellEnabled = false
local autoPlantEnabled = false
local sellTargetPosition = Vector3.new(91.6856689, 2.99960613, 0.405863285)
local CropTypes = {
    "Carrot", "Apple", "Potato", "Tomato", "Strawberry", "Blueberry", "Pumpkin", 
    "Corn", "Daffodil", "Watermelon", "Bamboo", "Coconut", "Cactus", "Dragon Fruit", 
    "Mango", "Grape", "Robux Egg 1", "Robux Egg 2", "Robux Egg 3", "Robux Egg 4", 
    "Cranberry", "Pear", "Lemon", "Peach", "Eggplant", "Pepper", "Durian", "Raffesia", "Green Apple", "Avocado", "Banana", "Pineapple", "Kiwi", "Bell Pepper", "Prickly Pear", "Loquat", "Feijoa", "Pitcher Plant", "Sugar Apple"
}
local feedDelay = 2
local autoBuyPlantingItems = {}
local autoBuyPlantingEnabled = false
local autoBuySummerItems = {}
local autoBuySummerEnabled = false
local autoCollectMoonlitEnabled = false
local eggEspEnabled = false

-- Planting Functions
local function plantCrop(position, crop)
    local args
    if crop:match("Robux Egg") then
        local eggNumber = tonumber(crop:match("%d+"))
        args = {
            [1] = "PurchaseSeed",
            [2] = eggNumber
        }
        ReplicatedStorage:WaitForChild("GameEvents", 9e9):WaitForChild("EasterShopService", 9e9):FireServer(unpack(args))
    else
        args = {
            [1] = position,
            [2] = crop
        }
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Plant_RE"):FireServer(unpack(args))
    end
end

-- Get held item
local function getHeldItem()
    local tool = Character:FindFirstChildOfClass("Tool")
    if tool then
        local name = tool.Name
        for _, crop in ipairs(CropTypes) do
            if string.find(string.lower(name), string.lower(crop)) then
                return crop
            end
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                for _, crop in ipairs(CropTypes) do
                    if string.find(string.lower(tool.Name), string.lower(crop)) then
                        return crop
                    end
                end
            end
        end
    end
    
    return cropName
end

-- Plant single crop in front of player
local function plantSingleCrop()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = Character:WaitForChild("HumanoidRootPart")
    
    local basePosition = HRP.Position + HRP.CFrame.LookVector * 4
    basePosition = Vector3.new(basePosition.X, 0.135, basePosition.Z)
    
    local heldCrop = getHeldItem()
    if heldCrop then
        cropName = heldCrop
    end
    
    plantCrop(basePosition, cropName)
end

-- Auto plant loop
local autoPlantLoop = nil
local function toggleAutoPlant(enabled)
    if enabled then
        if autoPlantLoop then
            autoPlantLoop:Disconnect()
        end
        autoPlantLoop = RunService.Heartbeat:Connect(function()
            task.wait(0.3)
            plantSingleCrop()
        end)
    else
        if autoPlantLoop then
            autoPlantLoop:Disconnect()
            autoPlantLoop = nil
        end
    end
end

-- Sell inventory
local function sellInventory()
    pcall(function()
        if HRP and HRP.Parent then
            local originalPosition = HRP.CFrame
            HRP.CFrame = CFrame.new(sellTargetPosition)
            task.wait(0.2)
            ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
            task.wait(0.2)
            HRP.CFrame = originalPosition
        end
    end)
end

-- Auto-sell loop
task.spawn(function()
    while true do
        if AutoSellEnabled then
            sellInventory()
            task.wait(AutoSellInterval)
        else
            task.wait(1)
        end
    end
end)

-- Update character reference when respawning
local function updateCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = Character:WaitForChild("HumanoidRootPart")
end

LocalPlayer.CharacterAdded:Connect(updateCharacter)

-- Auto-collect functionality
local Services = setmetatable({}, {
    __index = function(_, Index)
        return cloneref(game:GetService(Index))
    end,
})

local Players = Services.Players
local Workspace = Services.Workspace
local Player = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage

local Settings = {
    Script = {
        Running = false,
    },
    Values = {
        Plot = require(ReplicatedStorage.Modules.GetFarm),
        Remotes = require(ReplicatedStorage.Modules.Remotes),
        SeedData = require(ReplicatedStorage.Data.SeedData),
    },
}

-- Reliably finds the player's farm
local function findLocalPlayerFarm()
    local farms = Workspace:WaitForChild('Farm', 9e9)
    for _, farm in ipairs(farms:GetChildren()) do
        local important = farm:FindFirstChild('Important')
        if important then
            local data = important:FindFirstChild('Data')
            if
                data
                and data:FindFirstChild('Owner')
                and data.Owner.Value == Player.Name
            then
                print('[✅] Farm found:', farm.Name)
                return farm
            end
        end
    end
    print('[❌] No farm found for', Player.Name)
    return nil
end

-- Collects all collectable crops
function Settings.Script.AutoCollect()
    local plot = findLocalPlayerFarm()
    if not plot then
        return
    end

    local Temp = {}
    for _, plant in ipairs(plot.Important.Plants_Physical:GetChildren()) do
        local prompt = plant:FindFirstChildWhichIsA('ProximityPrompt', true)
        if prompt and prompt:HasTag('CollectPrompt') then
            table.insert(Temp, prompt.Parent.Parent)
        end
    end

    if #Temp > 0 then
        Settings.Values.Remotes.Crops.Collect.send(Temp)
    end
end

-- Continuous collect loop
local collectingLoop
local function SetAutoCollect(state)
    Settings.Script.Running = state

    if state then
        if collectingLoop then
            task.cancel(collectingLoop)
        end

        collectingLoop = task.spawn(function()
            while Settings.Script.Running do
                pcall(Settings.Script.AutoCollect)
                task.wait(CollectBatchPause)
            end
        end)
    else
        if collectingLoop then
            task.cancel(collectingLoop)
            collectingLoop = nil
        end
    end
end

-- Egg ESP Functions
local function toggleEggEsp(enabled)
    if enabled then
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local collectionService = game:GetService("CollectionService")
        local players = game:GetService("Players")

        local localPlayer = players.LocalPlayer

        local hatchFunction = getupvalue(getupvalue(getconnections(replicatedStorage.GameEvents.PetEggService.OnClientEvent)[1].Function, 1), 2)
        local eggModels = getupvalue(hatchFunction, 1)
        local eggPets = getupvalue(hatchFunction, 2)

        local espCache = {}
        local activeEggs = {}

        local function getObjectFromId(objectId)
            for eggModel in eggModels do
                if eggModel:GetAttribute("OBJECT_UUID") ~= objectId then continue end
                return eggModel
            end
        end

        local function CreateEspGui(object, text)
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "PetEggESP"
            billboard.Adornee = object:FindFirstChildWhichIsA("BasePart") or object.PrimaryPart or object
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true

            local label = Instance.new("TextLabel")
            label.Parent = billboard
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextStrokeTransparency = 0
            label.TextScaled = true
            label.Font = Enum.Font.SourceSansBold

            billboard.Parent = object
            return billboard
        end

        local function UpdateEsp(objectId, petName)
            local object = getObjectFromId(objectId)
            if not object or not espCache[objectId] then return end

            local eggName = object:GetAttribute("EggName")
            local labelGui = espCache[objectId]
            if labelGui and labelGui:FindFirstChildOfClass("TextLabel") then
                labelGui.TextLabel.Text = `{eggName} | {petName}`
            end
        end

        local function AddEsp(object)
            if object:GetAttribute("OWNER") ~= localPlayer.Name then return end

            local eggName = object:GetAttribute("EggName")
            local petName = eggPets[object:GetAttribute("OBJECT_UUID")]
            local objectId = object:GetAttribute("OBJECT_UUID")
            if not objectId then return end

            local esp = CreateEspGui(object, `{eggName} | {petName or "?"}`)
            espCache[objectId] = esp
            activeEggs[objectId] = object
        end

        local function RemoveEsp(object)
            if object:GetAttribute("OWNER") ~= localPlayer.Name then return end

            local objectId = object:GetAttribute("OBJECT_UUID")
            if espCache[objectId] then
                espCache[objectId]:Destroy()
                espCache[objectId] = nil
            end
            activeEggs[objectId] = nil
        end

        for _, object in collectionService:GetTagged("PetEggServer") do
            task.spawn(AddEsp, object)
        end

        collectionService:GetInstanceAddedSignal("PetEggServer"):Connect(AddEsp)
        collectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(RemoveEsp)

        local old
        old = hookfunction(getconnections(replicatedStorage.GameEvents.EggReadyToHatch_RE.OnClientEvent)[1].Function, newcclosure(function(objectId, petName)
            UpdateEsp(objectId, petName)
            return old(objectId, petName)
        end))
    else
        for _, esp in pairs(workspace:GetDescendants()) do
            if esp:IsA("BillboardGui") and esp.Name == "PetEggESP" then
                esp:Destroy()
            end
        end
    end
end

-- Auto Feed Pets (Limited to 3 items)
local function holdFoodItem()
    local equippedCount = 0
    for _, item in ipairs(Character:GetChildren()) do
        if item:IsA("Tool") and string.find(item.Name, "%d+%.?%d*kg") then
            item.Parent = Backpack
        end
    end
    local itemsEquipped = 0
    local maxItems = 3
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if itemsEquipped >= maxItems then break end
        if item:IsA("Tool") and string.find(item.Name, "%d+%.?%d*kg") then
            pcall(function()
                item.Parent = LocalPlayer.Character
                itemsEquipped = itemsEquipped + 1
            end)
            task.wait(0.05)
        end
    end
    return itemsEquipped > 0
end

local function findLocalPlayerFarm()
    for _, farm in ipairs(workspace:WaitForChild("Farm", 9e9):GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == LocalPlayer.Name then
            return farm
        end
    end
end

local function isPositionInPart(part, pos)
    local relative = part.CFrame:PointToObjectSpace(pos)
    local size = part.Size / 2
    return math.abs(relative.X) <= size.X and math.abs(relative.Y) <= size.Y and math.abs(relative.Z) <= size.Z
end

local function findUUID(pet)
    local attr = pet:GetAttribute("UUID") or pet:GetAttribute("PetUUID")
    if attr then return attr end
    for _, v in ipairs(pet:GetDescendants()) do
        if v.Name == "UUID" and v:IsA("StringValue") then return v.Value end
    end
    return nil
end

local function getNearbyPets(petArea)
    local pets = {}
    for _, mover in ipairs(workspace:WaitForChild("PetsPhysical", 9e9):GetChildren()) do
        local uuid = findUUID(mover)
        if uuid then
            for _, part in ipairs(mover:GetDescendants()) do
                if part:IsA("BasePart") and isPositionInPart(petArea, part.Position) then
                    table.insert(pets, {UUID = uuid})
                    break
                end
            end
        end
    end
    return pets
end

-- Remove Green Objects
local function getPlayerFarm()
    for _, farm in ipairs(workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == LocalPlayer.Name then
            return farm
        end
    end
end

local function isRoughlyGreen(color)
    return color.G > 0.4 and color.G > (color.R + 0.1) and color.G > (color.B + 0.1)
end

local function deleteGreenObjects()
    local farm = getPlayerFarm()
    if not farm then return end
    local greenBrickColors = {
        BrickColor.new("Lime green"),
        BrickColor.new("Parsley green")
    }
    for _, item in ipairs(farm:GetDescendants()) do
        if item:IsA("BasePart") then
            local brickColorMatch = table.find(greenBrickColors, item.BrickColor)
            if brickColorMatch or isRoughlyGreen(item.Color) then
                item:Destroy()
            end
        end
    end
end

-- Collect Moonlit, Bloodlit, and Golden Fruits with Proximity Prompting
local function findPlayerFarm()
    local farms = workspace:WaitForChild("Farm", 9e9)
    for _, farm in ipairs(farms:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")
        if owner and owner.Value == LocalPlayer.Name then
            return farm
        end
    end
end

local function isTargetColor(part)
    if not part:IsA("BasePart") then return false end
    local targetColors = {
        Color3.fromRGB(62, 56, 86),
        Color3.fromRGB(143, 1, 3),
        Color3.fromRGB(255, 170, 0)
    }
    for _, color in ipairs(targetColors) do
        if part.Color == color then
            return true
        end
    end
    return false
end

local function teleportTo(part)
    if HRP and part then
        HRP.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    end
end

local function fireProximityPrompts(part)
    local function searchDeep(obj)
        if obj:IsA("ProximityPrompt") then
            print("Found ProximityPrompt:", obj:GetFullName())
            fireproximityprompt(obj)
            return true
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            if searchDeep(child) then
                return true
            end
        end
        return false
    end
    
    local found = searchDeep(part)
    
    local plant = part.Parent and part.Parent.Parent
    if plant and not found then
        searchDeep(plant)
    end
    
    for _, descendant in ipairs(part:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            print("Found ProximityPrompt via GetDescendants:", descendant:GetFullName())
            fireproximityprompt(descendant)
        end
    end
end

local function findAndTeleport()
    local farm = findPlayerFarm()
    if not farm then return end
    
    local plantsFolder = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Plants_Physical")
    if not plantsFolder then return end
    
    for i, plant in ipairs(plantsFolder:GetChildren()) do
        local fruits = plant:FindFirstChild("Fruits")
        if fruits then
            for j, fruitGroup in ipairs(fruits:GetChildren()) do
                if isTargetColor(fruitGroup) then
                    teleportTo(fruitGroup)
                    task.wait(0.2)
                    fireProximityPrompts(fruitGroup)
                    fireProximityPrompts(plant)
                    return
                end
                
                for k = 1, 5 do
                    local numberedChild = fruitGroup:FindFirstChild(tostring(k))
                    if numberedChild and isTargetColor(numberedChild) then
                        teleportTo(numberedChild)
                        task.wait(0.2)
                        fireProximityPrompts(numberedChild)
                        fireProximityPrompts(plant)
                        return
                    end
                end
                
                for _, deepFruit in ipairs(fruitGroup:GetChildren()) do
                    if isTargetColor(deepFruit) then
                        teleportTo(deepFruit)
                        task.wait(0.2)
                        fireProximityPrompts(deepFruit)
                        fireProximityPrompts(plant)
                        return
                    end
                end
            end
        end
    end
end

-- Auto Buy Loops
task.spawn(function()
    while true do
        if autoBuyPlantingEnabled then
            for _, item in ipairs(autoBuyPlantingItems) do
                local args = { [1] = item }
                if item:match("Sprinkler") or item == "Lightning Rod" then
                    pcall(function()
                        ReplicatedStorage:WaitForChild("GameEvents", 9e9):WaitForChild("BuyGearStock", 9e9):FireServer(unpack(args))
                    end)
                else
                    pcall(function()
                        ReplicatedStorage:WaitForChild("GameEvents", 9e9):WaitForChild("BuySeedStock", 9e9):FireServer(unpack(args))
                    end)
                end
                task.wait(0)
            end
        end
        task.wait(0)
    end
end)

task.spawn(function()
    while true do
        if autoBuySummerEnabled then
            for _, item in ipairs(autoBuySummerItems) do
                local args = { [1] = item }
                pcall(function()
                    ReplicatedStorage:WaitForChild("GameEvents", 9e9):WaitForChild("BuyEventShopStock", 9e9):FireServer(unpack(args))
                end)
                task.wait(0.25)
            end
        end
        task.wait(1)
    end
end)

-- Auto Collect Moonlit Loop
task.spawn(function()
    while true do
        if autoCollectMoonlitEnabled then
            findAndTeleport()
            task.wait(1)
        else
            task.wait(1)
        end
    end
end)

-- Planting Tab
local PlantingTab = Window:CreateTab("Planting/Shop", nil)
PlantingTab:CreateSection("Crop Planting")
local cropDropdown = PlantingTab:CreateDropdown({
    Name = "Select Crop",
    Options = CropTypes,
    CurrentOption = cropName,
    Flag = "CropTypeDropdown",
    Callback = function(value)
        cropName = value
    end
})
PlantingTab:CreateButton({
    Name = "Plant Single Crop",
    Callback = function()
        plantSingleCrop()
    end
})
PlantingTab:CreateToggle({
    Name = "Auto Plant",
    CurrentValue = autoPlantEnabled,
    Flag = "AutoPlantToggle",
    Callback = function(value)
        autoPlantEnabled = value
        toggleAutoPlant(value)
    end
})
PlantingTab:CreateSection("Shop & Auto Buy")
PlantingTab:CreateToggle({
    Name = "Summer Event Shop GUI",
    CurrentValue = false,
    Flag = "SummerEventShopToggle",
    Callback = function(v)
        game.Players.LocalPlayer.PlayerGui.EventShop_UI.Enabled = v
    end
})
PlantingTab:CreateToggle({
    Name = "Cosmetic Shop",
    CurrentValue = false,
    Flag = "CosmeticShop_UI_Toggle",
    Callback = function(value)
        local gui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("CosmeticShop_UI")
        gui.Enabled = value
    end
})
PlantingTab:CreateToggle({
    Name = "Gear GUI",
    CurrentValue = false,
    Flag = "GearShopToggle",
    Callback = function(value)
        game:GetService("Players").LocalPlayer.PlayerGui.Gear_Shop.Enabled = value
    end
})
PlantingTab:CreateToggle({
    Name = "Seed Shop GUI",
    CurrentValue = false,
    Flag = "SeedShopToggle",
    Callback = function(value)
        game:GetService("Players").LocalPlayer.PlayerGui.Seed_Shop.Enabled = value
    end
})
PlantingTab:CreateDropdown({
    Name = "Auto Buy Items",
    Options = {
        "Carrot", "Strawberry", "Grape", "Mushroom", "Pepper", "Cacao",
        "Coconut (Mythical)", "Cactus (Mythical)", "Dragon Fruit (Mythical)", "Mango (Mythical)",
        "Watermelon (Legendary)", "Pumpkin (Legendary)", "Apple (Legendary)", "Bamboo (Legendary)", "Daffodil (Legendary)",
        "Beanstalk", "Master Sprinkler", "Godly Sprinkler", "Lightning Rod", "Advanced Sprinkler", "Favorite Tool", "Harvest Tool"
    },
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "AutoBuyPlantingItems",
    Callback = function(value)
        autoBuyPlantingItems = value
    end
})
PlantingTab:CreateToggle({
    Name = "Enable Auto Buy",
    CurrentValue = false,
    Flag = "AutoBuyPlantingToggle",
    Callback = function(value)
        autoBuyPlantingEnabled = value
    end
})

local AutoCollectTab = Window:CreateTab("Auto Harvest", nil)
AutoCollectTab:CreateSection("Auto Harvest")
AutoCollectTab:CreateToggle({
    Name = "Auto Harvest",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(value)
        AutoCollectEnabled = value
        SetAutoCollect(value)
    end
})
AutoCollectTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = function(value)
        AutoSellEnabled = value
    end
})
AutoCollectTab:CreateButton({
    Name = "Sell Inventory Now",
    Callback = function()
        sellInventory()
    end
})
AutoCollectTab:CreateSection("Auto Harvest Settings")
AutoCollectTab:CreateSlider({
    Name = "Harvest Pause",
    Range = {0.5, 5},
    Increment = 0.5,
    Suffix = "sec",
    CurrentValue = CollectBatchPause,
    Flag = "BatchPauseSlider",
    Callback = function(value)
        CollectBatchPause = value
    end
})
AutoCollectTab:CreateSlider({
    Name = "Sell Every",
    Range = {10, 300},
    Increment = 10,
    Suffix = "sec",
    CurrentValue = AutoSellInterval,
    Flag = "AutoSellIntervalSlider",
    Callback = function(value)
        AutoSellInterval = value
    end
})

local InventoryTab = Window:CreateTab("Inventory Tracker", nil)

-- Status Labels
local StatusLabel = InventoryTab:CreateLabel("Status: Loading module...")
local InventoryLabel = InventoryTab:CreateLabel("Inventory Value: $0 (0 items)")
local FarmLabel = InventoryTab:CreateLabel("Farm Value: $0 (0 items)")
local FruitLabel = InventoryTab:CreateLabel("Most Expensive Fruit: None found")


-- Manual Check Button
local ManualCheckButton = InventoryTab:CreateButton({
    Name = "Check Values Now",
    Callback = function()
        if not moduleLoaded or not mainModule then
            StatusLabel:Set("Status: Module not loaded! Click Load Module first.")
            return
        end

        mainModule.ManualCheck()
        StatusLabel:Set("Status: Values updated!")
    end,
})

-- Auto Update Toggle
local AutoUpdateToggle = InventoryTab:CreateToggle({
    Name = "Auto Update",
    CurrentValue = true,
    Callback = function(Value)
        if not moduleLoaded or not mainModule then
            StatusLabel:Set("Status: Module not loaded!")
            return
        end

        mainModule.SetAutoUpdate(Value)
        StatusLabel:Set("Status: Auto update " .. (Value and "enabled" or "disabled"))
    end,
})

-- Tracer Toggle
local TracerToggle = InventoryTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = true,
    Callback = function(Value)
        if not moduleLoaded or not mainModule then
            StatusLabel:Set("Status: Module not loaded!")
            return
        end

        mainModule.SetTracer(Value)
        StatusLabel:Set("Status: Tracer " .. (Value and "enabled" or "disabled"))
    end,
})

-- Steal Button
local StealButton = InventoryTab:CreateButton({
    Name = "Steal Best Fruit",
    Callback = function()
        if not moduleLoaded or not mainModule then
            StatusLabel:Set("Status: Module not loaded!")
            return
        end

        local fruitInfo = mainModule.GetBestFruitInfo()
        if fruitInfo then
            StatusLabel:Set("Status: Attempting to steal " .. fruitInfo.Name .. "...")
            print("Attempting to steal:", fruitInfo.Name, "($" .. fruitInfo.FormattedValue .. ") from", fruitInfo.Owner)

            local success = mainModule.StealBestFruit()
            if success then
                StatusLabel:Set("Status: Successfully stolen " .. fruitInfo.Name .. "!")
                print("Successfully stolen!")
            else
                StatusLabel:Set("Status: Failed to steal fruit")
                print("Failed to steal fruit")
            end
        else
            StatusLabel:Set("Status: No valuable fruit found to steal")
            print("No valuable fruit found to steal")
        end
    end,
})

-- Function to format numbers with commas
local function formatNumber(num)
    if num == 0 then
        return "0"
    end
    local formatted = string.format("%.0f", num)
    return formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Update display function
local function updateDisplay()
    if not moduleLoaded or not mainModule then
        return
    end

    local data = mainModule.GetData()
    if not data then
        return
    end

    -- Update inventory display
    InventoryLabel:Set(string.format("Inventory Value: $%s (%d items)", formatNumber(data.Inventory.TotalValue), data.Inventory.Count))

    -- Update farm display
    FarmLabel:Set(string.format("Farm Value: $%s (%d items)", formatNumber(data.Farm.TotalValue), data.Farm.Count))

    -- Update fruit display
    if data.MostExpensiveFruit.Fruit and data.MostExpensiveFruit.Value > 0 then
        FruitLabel:Set(string.format("Most Expensive Fruit: %s ($%s) - Owner: %s", data.MostExpensiveFruit.Fruit.Name, formatNumber(data.MostExpensiveFruit.Value), data.MostExpensiveFruit.Owner or "Unknown"))
    else
        FruitLabel:Set("Most Expensive Fruit: None found")
    end
end

-- Auto-load module on startup
task.spawn(function()
    wait(1) -- Give time for everything to load
    loadModule()
end)

-- Update loop
task.spawn(function()
    while true do
        updateDisplay()
        wait(1) -- Update display every second
    end
end)

-- Notification
Rayfield:Notify({
    Title = "Fruit Tracker Loaded",
    Content = "Script is ready! Click Load Module to start.",
    Duration = 5,
    Image = 4483362458,
})

local PetsTab = Window:CreateTab("Pets", nil)
PetsTab:CreateSection("Pets")

local FeedLabel = PetsTab:CreateLabel("Pets Fed: 0")

local AutoFeedToggle = PetsTab:CreateToggle({
    Name = "Auto Feed Pets",
    CurrentValue = true,
    Flag = "AutoFeedPetsToggle",
    Callback = function(value)
        if mainModule and mainModule.SetAutoFeed then
            mainModule.SetAutoFeed(value)
        end
    end,
})

local ManualFeedButton = PetsTab:CreateButton({
    Name = "Feed Pets Now",
    Callback = function()
        if mainModule and mainModule.ManualFeed then
            local count = mainModule.ManualFeed()
            Rayfield:Notify({
                Title = "Manual Feed",
                Content = "Fed " .. count .. " pets",
                Duration = 2,
            })
        end
    end,
})

local FeedDelaySlider = PetsTab:CreateSlider({
    Name = "Feed Delay",
    Range = { 0.1, 5 },
    Increment = 0.1,
    Suffix = "sec",
    CurrentValue = 2,
    Flag = "FeedDelaySlider",
    Callback = function(value)
        if mainModule and mainModule.SetFeedDelay then
            mainModule.SetFeedDelay(value)
        end
    end,
})

PetsTab:CreateToggle({
    Name = "Egg ESP",
    CurrentValue = false,
    Flag = "EggEspToggle",
    Callback = function(value)
        eggEspEnabled = value
        toggleEggEsp(value)
    end
})

-- Optimized update loop
local lastUpdateTime = 0
local updateConnection = game
    :GetService("RunService").Heartbeat
    :Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdateTime >= 1 then
            lastUpdateTime = currentTime

            if mainModule and mainModule.GetData then
                pcall(function()
                    local data = mainModule.GetData()
                    if data then
                        FeedLabel:Set(
                            string.format("Pets Fed: %d", data.FedCount or 0)
                        )
                    end
                end)
            end
        end
    end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == game:GetService("Players").LocalPlayer then
        if updateConnection then
            updateConnection:Disconnect()
        end
        Rayfield:Destroy()
    end
end)

local SummerTab = Window:CreateTab("Summer Event", nil)
SummerTab:CreateSection("Summer Event")

local submitAllLoop = nil
SummerTab:CreateToggle({
    Name = "Submit Selected",
    CurrentValue = false,
    Flag = "SubmitAllToggle",
    Callback = function(value)
        if value then
            if submitAllLoop then
                submitAllLoop:Disconnect()
            end
            submitAllLoop = RunService.Heartbeat:Connect(function()
                local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:find("Pollinated") then
                            game:GetService("Players").LocalPlayer.Character.Humanoid:EquipTool(tool)
                            break
                        end
                    end
                end

                local args = {
                    [1] = "SubmitHeldPlant"
                }
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents", 9e9):WaitForChild("SummerHarvestRemoteEvent", 9e9):FireServer(unpack(args))
                end)
                task.wait(1)
            end)
        else
            if submitAllLoop then
                submitAllLoop:Disconnect()
                submitAllLoop = nil
            end
        end
    end
})

SummerTab:CreateToggle({
    Name = "Auto Collect Moonlit/Bloodlit/Honey",
    CurrentValue = false,
    Flag = "AutoCollectMoonlitToggle",
    Callback = function(value)
        autoCollectMoonlitEnabled = value
    end
})

SummerTab:CreateSection("Auto Buy Summer Items")

local autoBuySummerItems = {}
local autoBuySummerEnabled = false

SummerTab:CreateDropdown({
    Name = "Summer Auto Buy Items",
    Options = {
        "Summer Seed Pack", "Summer Sprinkler", "Summer Crate", "Summer Torch",
        "Summer Walkway", "Summer Chair", "Summer Fruit", "Summer Egg"
    },
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "AutoBuySummerItems",
    Callback = function(value)
        autoBuySummerItems = value
    end
})

SummerTab:CreateToggle({
    Name = "Enable Summer Auto Buy",
    CurrentValue = false,
    Flag = "AutoBuySummerToggle",
    Callback = function(value)
        autoBuySummerEnabled = value
        if value then
            if autoBuySummerLoop then
                autoBuySummerLoop:Disconnect()
            end
            autoBuySummerLoop = RunService.Heartbeat:Connect(function()
                if autoBuySummerEnabled and autoBuySummerItems then
                    for _, itemName in pairs(autoBuySummerItems) do
                        local args = { [1] = itemName }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents", 9e9):WaitForChild("BuyEventShopStock", 9e9):FireServer(unpack(args))
                        end)
                        task.wait(0.2)
                    end
                end
            end)
        else
            if autoBuySummerLoop then
                autoBuySummerLoop:Disconnect()
                autoBuySummerLoop = nil
            end
        end
    end
})

-- Server Browser Tab
local ServerBrowserTab = Window:CreateTab("Server Browser", nil)

local function serverHop()
    Rayfield:Notify({
        Title = "Server Hop",
        Content = "Finding a new server...",
        Duration = 3,
        Image = 4483362458
    })
    
    -- Simple server hop - Roblox will find a random server for you
    TeleportService:Teleport(PlaceId, LocalPlayer)
end

local function rejoinServer()
    Rayfield:Notify({
        Title = "Rejoining",
        Content = "Rejoining current server...",
        Duration = 3,
        Image = 4483362458
    })
    
    -- Rejoin the same server
    TeleportService:TeleportToPlaceInstance(PlaceId, game.JobId, LocalPlayer)
end

ServerBrowserTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        serverHop()
    end
})

ServerBrowserTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        rejoinServer()
    end
})

ServerBrowserTab:CreateButton({
    Name = "Show Server Info",
    Callback = function()
        local playerCount = #Players:GetPlayers()
        Rayfield:Notify({
            Title = "Server Info",
            Content = string.format("Players: %d | Version: %s", playerCount, game.PlaceVersion),
            Duration = 5,
            Image = 4483362458
        })
        print("Current server - Players:", playerCount, "Version:", game.PlaceVersion)
    end
})