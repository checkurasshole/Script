-- Protected Script (Portuguese)
-- Script ID: d918eb060771b522cc93f97e57d6853d
-- Migrated: 2025-09-11T14:25:45.784Z
-- Auto-migrated from encrypted storage to GitHub

local Fluent = loadstring(game:HttpGet("__URL_15196e5d4e9dbb01__"))()
local SaveManager = loadstring(game:HttpGet("__URL_8babace55ae572e4__"))()
local InterfaceManager = loadstring(game:HttpGet("__URL_751d49f30abc55e4__"))()

local Window = Fluent:CreateWindow({
    Title = "COMBO_WICK",
    SubTitle = "",
    TabWidth = 120,
    Size = UDim2.fromOffset(400, 350),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Create Toggle Button
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait a bit to ensure everything loads
wait(0.5)

-- Create ScreenGui for the toggle button
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "FluentToggleGui"
toggleGui.ResetOnSpawn = false
toggleGui.DisplayOrder = 999999
toggleGui.Parent = playerGui

-- Create the main toggle button (using TextButton directly)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 80, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "COMBO_WICK"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.Gotham
toggleButton.Parent = toggleGui

-- Add corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = toggleButton

-- Add stroke for better visibility
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 100)
stroke.Thickness = 1
stroke.Parent = toggleButton

-- GUI visibility state (removed since we're using Fluent's minimize)


-- Variables for dragging
local dragging = false
local dragStart = nil
local startPos = nil

-- Simple click functionality - works like Fluent minimize
toggleButton.MouseButton1Click:Connect(function()
    if not dragging then
        -- Use Fluent's built-in minimize function
        Window:Minimize()
        
        print("GUI minimized/restored") -- Debug print
    end
end)

-- Make button draggable
toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        dragStart = input.Position
        startPos = toggleButton.Position
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            dragging = true
            toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

toggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = nil
        -- Reset dragging after a short delay
        wait(0.1)
        dragging = false
    end
end)

-- Hover effects (simplified since we're just using minimize)
toggleButton.MouseEnter:Connect(function()
    toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end)

toggleButton.MouseLeave:Connect(function()
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

-- Debug: Print to confirm the button was created
print("Toggle button created successfully!")

-- Original Fluent GUI code
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tabs = {
    Spawn = Window:AddTab({ Title = "Itens de Surgimento", Icon = "package" })
}

local Platforms = {
    "Yellow Wool Platform", "Acacia Platform", "Birch Platform", "Blackstone Platform",
    "Bloodwood Platform", "Blue Wool Platform", "Cherry Platform", "Diorite Platform",
    "Granite Platform", "Grass Platform", "Green Wool Platform", "Oak Platform",
    "Orange Wool Platform", "Purple Wool Platform", "Red Wool Platform", "Stone Platform"
}

local Tools = {
    "Pickup Tool", "Diamond Axe", "Diamond Hammer", "Diamond Pickaxe", "Diamond Shovel",
    "Diamond Spear", "Diamond Sword", "Diamond Trident", "Gold Axe", "Gold Hammer",
    "Gold Pickaxe", "Gold Shovel", "Gold Spear", "Gold Sword", "Gold Trident",
    "Iron Axe", "Iron Hammer", "Iron Pickaxe", "Iron Shovel", "Iron Spear",
    "Iron Sword", "Iron Trident", "Stone Axe", "Stone Hammer", "Stone Pickaxe",
    "Stone Shovel", "Stone Spear", "Stone Sword", "Stone Trident", "Bandage", "Medkit"
}

local BuildTools = {
    "Blue Bed", "Blue Chair", "Blue Seat", "Blue Shelf", "Botanist Workbench",
    "Carpenter Workbench", "Cooking Pot", "Double Lantern Pole", "Drill",
    "Farm Plot", "Farm Stand", "Forge Workbench", "General Workbench",
    "Glass Blower Workbench", "Lantern", "Lantern Pole", "Lantern Stand",
    "Lightkeeper Workbench", "Loom Workbench", "Platform Workbench", "Red Bed",
    "Red Chair", "Red Seat", "Red Shelf", "Stone Smelter", "White Bed",
    "White Chair", "White Seat", "White Shelf", "Wood Cutter"
}

local selectedPlatform = Platforms[1]
local selectedTool = Tools[1]
local selectedBuildTool = BuildTools[1]

Tabs.Spawn:AddSection("Platforms")

local PlatformDropdown = Tabs.Spawn:AddDropdown("PlatformDropdown", {
    Title = "Selecione plataforma",
    Values = Platforms,
    Multi = false,
    Default = 1,
})

PlatformDropdown:OnChanged(function(Value)
    selectedPlatform = Value
end)

local PlatformButton = Tabs.Spawn:AddButton({
    Title = "Descarregue",
    Callback = function()
        ReplicatedStorage.PurchaseTool:FireServer(selectedPlatform, 0)
    end
})

Tabs.Spawn:AddSection("Tools")

local ToolsDropdown = Tabs.Spawn:AddDropdown("ToolsDropdown", {
    Title = "Seleccionar ferramenta",
    Values = Tools,
    Multi = false,
    Default = 1,
})

ToolsDropdown:OnChanged(function(Value)
    ReplicatedStorage.PurchaseGeneral:FireServer(Value, 0)
end)

local BuildToolsDropdown = Tabs.Spawn:AddDropdown("BuildToolsDropdown", {
    Title = "Seleccione Ferramenta de Construção",
    Values = BuildTools,
    Multi = false,
    Default = 1,
})

BuildToolsDropdown:OnChanged(function(Value)
    selectedBuildTool = Value
end)

local BuildToolButton = Tabs.Spawn:AddButton({
    Title = "Descarregue",
    Callback = function()
        ReplicatedStorage.PurchaseGeneral:FireServer(selectedBuildTool, 0)
    end
})