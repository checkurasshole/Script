-- Language-gui Script (GUI)
-- Generated on: 8/22/2025, 11:28:45 AM

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function getGuiParent()
    local success, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if success then
        return coreGui
    else
        return playerGui
    end
end

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9c17deaa25943c8b9e36fcf471646ca8",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5ebd16f22a823adfcd9a2559d11d221c"
}

-- [Rest of GUI code stays the same]
local SAVE_KEY = "LanguageSelector_" .. game.GameId .. "_SavedSettings"
local autoSaveEnabled = true
local savedLanguage = nil
local currentScale = 1
local minScale = 0.5
local maxScale = 2

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local function saveSettings()
    if autoSaveEnabled and savedLanguage then
        local data = {
            language = savedLanguage,
            autoSave = autoSaveEnabled,
            scale = currentScale
        }
        writefile(SAVE_KEY .. ".json", HttpService:JSONEncode(data))
    end
end

local function loadSettings()
    if isfile(SAVE_KEY .. ".json") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_KEY .. ".json"))
        end)
        if success and data then
            savedLanguage = data.language
            autoSaveEnabled = data.autoSave or true
            currentScale = data.scale or 1
            return data
        end
    end
    return nil
end

local function autoLoadScript()
    if autoSaveEnabled and savedLanguage and scripts[savedLanguage] then
        spawn(function()
            wait(0.5)
            local success, result = pcall(function()
                loadstring(game:HttpGet(scripts[savedLanguage]))()
            end)
        end)
        return true
    end
    return false
end

loadSettings()

if autoLoadScript() then
    return
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LanguageSelectorGUI"
screenGui.Parent = getGuiParent()
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    screenGui.IgnoreGuiInset = true
end)

local baseFrameWidth = isMobile and 320 or 460
local baseFrameHeight = isMobile and 420 or 640
local frameWidth = baseFrameWidth * currentScale
local frameHeight = baseFrameHeight * currentScale

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
mainFrame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.02
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local function createLanguageButton(languageName, scriptUrl)
    local button = Instance.new("TextButton")
    button.Name = languageName
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    button.Text = languageName
    button.TextColor3 = Color3.fromRGB(220, 220, 255)
    button.Font = Enum.Font.SourceSansBold
    button.Parent = scrollFrame
    
    button.MouseButton1Click:Connect(function()
        savedLanguage = languageName
        saveSettings()
        
        spawn(function()
            wait(1.8)
            local success, result = pcall(function()
                loadstring(game:HttpGet(scriptUrl))()
            end)
            screenGui:Destroy()
        end)
    end)
    
    return button
end

for languageName, scriptUrl in pairs(scripts) do
    createLanguageButton(languageName, scriptUrl)
end