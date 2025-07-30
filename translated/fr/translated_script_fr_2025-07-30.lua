-- Rayfield Car Control Script
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Combo Wick",
   LoadingTitle = "Loading Combo Wick...",
   LoadingSubtitle = "Par",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Contrôles des voitures", "car")

-- Variables
local carSignalService = game:GetService("ReplicatedStorage"):WaitForChild("Signal", 9e9):WaitForChild("Car", 9e9)
local placeSignalService = game:GetService("ReplicatedStorage"):WaitForChild("Signal", 9e9):WaitForChild("Place", 9e9)
local rebirthSignalService = game:GetService("ReplicatedStorage"):WaitForChild("Signal", 9e9):WaitForChild("Rebirth", 9e9)
local upgradeSignalService = game:GetService("ReplicatedStorage"):WaitForChild("Signal", 9e9):WaitForChild("Upgrade", 9e9)
local spamAmount = 10
local isLooping = false
local isUpgradeLooping = false
local isRebirthLooping = false
local isBrainrotLooping = false
local isMoneyLooping = false
local isXPLooping = false
local isFloorLooping = false

-- Function to fire ALL car signals at once (Updated)
local function fireAllCarSignalsAtOnce()
    carSignalService:FireServer("Drive")
    carSignalService:FireServer("FirstBoost", 0.10821316584677258)
    carSignalService:FireServer("Done", 1, 142530572450.96928)
    carSignalService:FireServer("VisibleCharacter")
    carSignalService:FireServer("BackToEquip")
    carSignalService:FireServer("DoneTeleport", 1)
end

-- Function for instant spam
local function instantSpamAll()
    for i = 1, spamAmount do
        carSignalService:FireServer("Drive")
        carSignalService:FireServer("FirstBoost", 0.10821316584677258)
        carSignalService:FireServer("Done", 1, 142530572450.96928)
        carSignalService:FireServer("VisibleCharacter")
        carSignalService:FireServer("BackToEquip")
        carSignalService:FireServer("DoneTeleport", 1)
    end
end

-- Loop Toggle
local LoopToggle = MainTab:CreateToggle({
   Name = "Argent infini",
   CurrentValue = false,
   Flag = "LoopToggle",
   Callback = function(Value)
        isLooping = Value
        
        if Value then
            spawn(function()
                while isLooping do
                    fireAllCarSignalsAtOnce()
                    wait(0.1)
                end
            end)
        end
   end,
})

-- Upgrade Car and Ramp Toggle
local UpgradeToggle = MainTab:CreateToggle({
   Name = "Voiture et Ramp de mise à n...",
   CurrentValue = false,
   Flag = "UpgradeToggle",
   Callback = function(Value)
        isUpgradeLooping = Value
        
        if Value then
            spawn(function()
                while isUpgradeLooping do
                    placeSignalService:FireServer("Upgrade", "Car")
                    placeSignalService:FireServer("Upgrade", "Ramp", 1)
                    wait(0.1)
                end
            end)
        end
   end,
})

-- Rebirth Toggle
local RebirthToggle = MainTab:CreateToggle({
   Name = "Renaissance",
   CurrentValue = false,
   Flag = "RebirthToggle",
   Callback = function(Value)
        isRebirthLooping = Value
        
        if Value then
            spawn(function()
                while isRebirthLooping do
                    rebirthSignalService:FireServer("rebirth")
                    wait(0.1)
                end
            end)
        end
   end,
})

-- Spam Amount Slider
local SpamSlider = MainTab:CreateSlider({
   Name = "Pourriel",
   Range = {1, 20},
   Increment = 1,
   Suffix = "times",
   CurrentValue = 10,
   Flag = "SpamAmount",
   Callback = function(Value)
        spamAmount = Value
   end,
})

-- Instant Spam Button
local InstantSpamButton = MainTab:CreateButton({
   Name = "Spam instantané",
   Callback = function()
        instantSpamAll()
   end,
})

-- Hide Cash Effects Button
local HideCashEffectsButton = MainTab:CreateButton({
   Name = "Cacher les effets de trésor...",
   Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        -- Keywords of effects to destroy
        local keywords = {"Money", "XP"}
        
        -- Helper: Checks if instance matches target visual effect
        local function isVisualEffect(inst)
            for _, word in ipairs(keywords) do
                if inst.Name:lower():find(word:lower()) then
                    -- Avoid touching ReplicatedStorage or Modules
                    if not inst:IsDescendantOf(game.ReplicatedStorage) then
                        return true
                    end
                end
            end
            return false
        end
        
        -- Destroy matching effects in workspace/character
        local function destroyEffects()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if isVisualEffect(obj) then
                    pcall(function()
                        obj:Destroy()
                    end)
                end
            end
            for _, obj in ipairs(character:GetDescendants()) do
                if isVisualEffect(obj) then
                    pcall(function()
                        obj:Destroy()
                    end)
                end
            end
        end
        
        -- Initial wipe
        destroyEffects()
        
        -- Listen for new stuff being added and destroy instantly
        workspace.DescendantAdded:Connect(function(obj)
            if isVisualEffect(obj) then
                task.wait()
                pcall(function() obj:Destroy() end)
            end
        end)
        
        character.DescendantAdded:Connect(function(obj)
            if isVisualEffect(obj) then
                task.wait()
                pcall(function() obj:Destroy() end)
            end
        end)
   end,
})

-- Upgrades Tab
local UpgradesTab = Window:CreateTab("Améliorations", "trending-up")

-- Brainrot Speed Toggle
local BrainrotToggle = UpgradesTab:CreateToggle({
   Name = "Vitesse du brainrot",
   CurrentValue = false,
   Flag = "BrainrotToggle",
   Callback = function(Value)
        isBrainrotLooping = Value
        
        if Value then
            spawn(function()
                while isBrainrotLooping do
                    upgradeSignalService:FireServer("Upgrade", "Brainrot Speed", 1)
                    wait(0.1)
                end
            end)
        end
   end,
})

-- Money Multiplier Toggle
local MoneyToggle = UpgradesTab:CreateToggle({
   Name = "Multiplieur d'argent",
   CurrentValue = false,
   Flag = "MoneyToggle",
   Callback = function(Value)
        isMoneyLooping = Value
        
        if Value then
            spawn(function()
                while isMoneyLooping do
                    upgradeSignalService:FireServer("Upgrade", "Money Multiplier", 1)
                    wait(0.1)
                end
            end)
        end
   end,
})

-- XP Multiplier Toggle
local XPToggle = UpgradesTab:CreateToggle({
   Name = "Multiplicateur XP",
   CurrentValue = false,
   Flag = "XPToggle",
   Callback = function(Value)
        isXPLooping = Value
        
        if Value then
            spawn(function()
                while isXPLooping do
                    upgradeSignalService:FireServer("Upgrade", "XP Multiplier", 1)
                    wait(0.1)
                end
            end)
        end
   end,
})

-- Floor Discount Toggle
local FloorToggle = UpgradesTab:CreateToggle({
   Name = "Rabais sur l'étage",
   CurrentValue = false,
   Flag = "FloorToggle",
   Callback = function(Value)
        isFloorLooping = Value
        
        if Value then
            spawn(function()
                while isFloorLooping do
                    upgradeSignalService:FireServer("Upgrade", "Floor Discount", 1)
                    wait(0.1)
                end
            end)
        end
   end,
})