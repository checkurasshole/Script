-- Original English Script
-- Script ID: 7dcb43bd426819898279a579820cde32
-- Migrated: 2025-09-11T13:21:29.959Z
-- Auto-migrated from encrypted storage to GitHub

local Fluent = loadstring(game:HttpGet("__URL_e47c556fde49526d__"))()
local SaveManager = loadstring(game:HttpGet("__URL_fb684e2e9a755a0c__"))()
local InterfaceManager = loadstring(game:HttpGet("__URL_566bac056fd03ba3__"))()

local Window = Fluent:CreateWindow({
    Title = "COMBO_WICK",
    SubTitle = "",
    TabWidth = 120,
    Size = UDim2.fromOffset(400, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" })
}

local Options = Fluent.Options

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local moneySpamming = false
local moneyConnection
local currentAmount = -9000000

local rebirthSpamming = false
local rebirthConnection

local function startMoneySpam()
    if moneySpamming then return end
    moneySpamming = true
    
    moneyConnection = spawn(function()
        while moneySpamming do
            local args = {
                [1] = "PunchDamage",
                [2] = currentAmount
            }
            
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[1]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[2]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[3]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[4]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[5]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[6]:InvokeServer(unpack(args))
            end)
            
            wait(0.1)
        end
    end)
end

local function stopMoneySpam()
    moneySpamming = false
    if moneyConnection then
        moneyConnection = nil
    end
end

local function startRebirthSpam()
    if rebirthSpamming then return end
    rebirthSpamming = true
    
    rebirthConnection = spawn(function()
        while rebirthSpamming do
            pcall(function()
                local args = {
                    [1] = "PunchDamage",
                    [2] = 0
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[1]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                local args = {
                    [1] = "PunchDamage",
                    [2] = 0
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[2]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                local args = {
                    [1] = "PunchDamage",
                    [2] = 0
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[3]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                local args = {
                    [1] = "PunchDamage",
                    [2] = 0
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[4]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                local args = {
                    [1] = "PunchDamage",
                    [2] = 0
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[5]:InvokeServer(unpack(args))
            end)
            
            pcall(function()
                local args = {
                    [1] = "PunchDamage",
                    [2] = 0
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9):WaitForChild("Functions", 9e9):GetChildren()[6]:InvokeServer(unpack(args))
            end)
            
            wait(0.1)
        end
    end)
end

local function stopRebirthSpam()
    rebirthSpamming = false
    if rebirthConnection then
        rebirthConnection = nil
    end
end

local function teleportToUpgrades()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-208.16423, 107.800003, 292.948669, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    end
end

local function teleportToWeapons()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-163.876297, 107.547997, 295.893494, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    end
end

local MoneyInput = Tabs.Main:AddInput("MoneyInput", {
    Title = "Money Amount",
    Default = "9000000",
    Placeholder = "Enter amount",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local newAmount = tonumber(Value)
        if newAmount then
            currentAmount = -math.abs(newAmount)
        end
    end
})

local MoneyToggle = Tabs.Main:AddToggle("MoneySpam", {
    Title = "Money",
    Default = false,
    Callback = function(Value)
        if Value then
            startMoneySpam()
        else
            stopMoneySpam()
        end
    end
})

local RebirthToggle = Tabs.Main:AddToggle("RebirthSpam", {
    Title = "Rebirth",
    Default = false,
    Callback = function(Value)
        if Value then
            startRebirthSpam()
        else
            stopRebirthSpam()
        end
    end
})

local UpgradesButton = Tabs.Main:AddButton({
    Title = "Teleport to Upgrades",
    Callback = function()
        teleportToUpgrades()
    end
})

local WeaponsButton = Tabs.Main:AddButton({
    Title = "Teleport to Weapons",
    Callback = function()
        teleportToWeapons()
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("COMBO_WICK")
SaveManager:SetFolder("COMBO_WICK/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)

SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()