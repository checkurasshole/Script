local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local scripts = {
    ["English"] = "https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/englishsss",
    ["German"] = "https://gist.githubusercontent.com/checkurasshole/a785d931be21a4d34a59e696867cd77e/raw/a10b9537d63aafa1c8003ac5448e789762c9c778/translated_script_de_2025-08-07.lua",
    ["Spanish"] = "https://gist.githubusercontent.com/checkurasshole/a785d931be21a4d34a59e696867cd77e/raw/dcf83482e34607bc66426f7901e587ec51ce59f1/translated_script_es_2025-08-07.lua",
    ["French"] = "https://gist.githubusercontent.com/checkurasshole/a785d931be21a4d34a59e696867cd77e/raw/034dbe53f1bd1a8ff876c57cc0f533e0463a18a8/translated_script_fr_2025-08-07.lua",
    ["Italian"] = "https://gist.githubusercontent.com/checkurasshole/a785d931be21a4d34a59e696867cd77e/raw/5005541ebf1785b52238aa87f49285b6a0d93f01/translated_script_it_2025-08-07.lua",
    ["Japanese"] = "",
    ["Brazilian"] = "https://gist.githubusercontent.com/checkurasshole/a785d931be21a4d34a59e696867cd77e/raw/4d7731350d33e1d37a3e5a1e0a60457beb3e0ef0/translated_script_pt_2025-08-07.lua",
    ["Russian"] = "https://gist.githubusercontent.com/checkurasshole/a785d931be21a4d34a59e696867cd77e/raw/60622e05f7367c3ad43ce53585e183322bfd805e/translated_script_ru_2025-08-07.lua"
}

local SAVE_KEY = "LanguageSelector_SavedSettings"
local autoSaveEnabled = true
local savedLanguage = nil

local function saveSettings()
    if autoSaveEnabled and savedLanguage then
        local data = {
            language = savedLanguage,
            autoSave = autoSaveEnabled
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
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 650)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -325)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 50, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 200))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.8
stroke.Thickness = 2
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 80)
title.Position = UDim2.new(0, 0, 0, 20)
title.BackgroundTransparency = 1
title.Text = "🌐 Select Language"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(1, 0, 0, 30)
subtitle.Position = UDim2.new(0, 0, 0, 100)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Choose your preferred language"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = mainFrame

local autoSaveFrame = Instance.new("Frame")
autoSaveFrame.Name = "AutoSaveFrame"
autoSaveFrame.Size = UDim2.new(1, -40, 0, 40)
autoSaveFrame.Position = UDim2.new(0, 20, 0, 135)
autoSaveFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
autoSaveFrame.BackgroundTransparency = 0.95
autoSaveFrame.BorderSizePixel = 0
autoSaveFrame.Parent = mainFrame

local autoSaveCorner = Instance.new("UICorner")
autoSaveCorner.CornerRadius = UDim.new(0, 8)
autoSaveCorner.Parent = autoSaveFrame

local autoSaveStroke = Instance.new("UIStroke")
autoSaveStroke.Color = Color3.fromRGB(255, 255, 255)
autoSaveStroke.Transparency = 0.8
autoSaveStroke.Thickness = 1
autoSaveStroke.Parent = autoSaveFrame

local autoSaveLabel = Instance.new("TextLabel")
autoSaveLabel.Name = "AutoSaveLabel"
autoSaveLabel.Size = UDim2.new(1, -60, 1, 0)
autoSaveLabel.Position = UDim2.new(0, 10, 0, 0)
autoSaveLabel.BackgroundTransparency = 1
autoSaveLabel.Text = "💾 Auto-Save Language Choice"
autoSaveLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
autoSaveLabel.TextScaled = true
autoSaveLabel.Font = Enum.Font.Gotham
autoSaveLabel.TextXAlignment = Enum.TextXAlignment.Left
autoSaveLabel.Parent = autoSaveFrame

local autoSaveToggle = Instance.new("TextButton")
autoSaveToggle.Name = "AutoSaveToggle"
autoSaveToggle.Size = UDim2.new(0, 40, 0, 20)
autoSaveToggle.Position = UDim2.new(1, -50, 0.5, -10)
autoSaveToggle.BackgroundColor3 = autoSaveEnabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(100, 100, 100)
autoSaveToggle.BorderSizePixel = 0
autoSaveToggle.Text = ""
autoSaveToggle.Parent = autoSaveFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = autoSaveToggle

local toggleIndicator = Instance.new("Frame")
toggleIndicator.Name = "Indicator"
toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
toggleIndicator.Position = autoSaveEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleIndicator.BorderSizePixel = 0
toggleIndicator.Parent = autoSaveToggle

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, 8)
indicatorCorner.Parent = toggleIndicator

autoSaveToggle.MouseButton1Click:Connect(function()
    autoSaveEnabled = not autoSaveEnabled
    
    local toggleColorTween = TweenService:Create(autoSaveToggle,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {BackgroundColor3 = autoSaveEnabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(100, 100, 100)}
    )
    toggleColorTween:Play()
    
    local indicatorTween = TweenService:Create(toggleIndicator,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = autoSaveEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
    )
    indicatorTween:Play()
    
    if autoSaveEnabled then
        saveSettings()
    else
        if isfile(SAVE_KEY .. ".json") then
            delfile(SAVE_KEY .. ".json")
        end
    end
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "LanguageScroll"
scrollFrame.Size = UDim2.new(1, -40, 1, -210)
scrollFrame.Position = UDim2.new(0, 20, 0, 185)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scrollFrame.ScrollBarImageTransparency = 0.5
scrollFrame.Parent = mainFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 180, 0, 50)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.SortOrder = Enum.SortOrder.Name
gridLayout.Parent = scrollFrame

local function createLanguageButton(languageName, scriptUrl)
    local button = Instance.new("TextButton")
    button.Name = languageName
    button.Size = UDim2.new(0, 180, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = (savedLanguage == languageName) and 0.7 or 0.9
    button.BorderSizePixel = 0
    button.Text = languageName
    button.TextColor3 = (savedLanguage == languageName) and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamSemibold
    button.Parent = scrollFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(255, 255, 255)
    buttonStroke.Transparency = (savedLanguage == languageName) and 0.3 or 0.7
    buttonStroke.Thickness = (savedLanguage == languageName) and 2 or 1
    buttonStroke.Parent = button
    
    local hoverTween = TweenService:Create(button, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.7, TextColor3 = Color3.fromRGB(100, 200, 255)}
    )
    
    local normalTween = TweenService:Create(button,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {BackgroundTransparency = (savedLanguage == languageName) and 0.7 or 0.9, 
         TextColor3 = (savedLanguage == languageName) and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(255, 255, 255)}
    )
    
    button.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        normalTween:Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        savedLanguage = languageName
        saveSettings()
        
        local loadingFrame = Instance.new("Frame")
        loadingFrame.Name = "LoadingFrame"
        loadingFrame.Size = UDim2.new(1, 0, 1, 0)
        loadingFrame.Position = UDim2.new(0, 0, 0, 0)
        loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        loadingFrame.BackgroundTransparency = 0.3
        loadingFrame.Parent = mainFrame
        
        local loadingText = Instance.new("TextLabel")
        loadingText.Size = UDim2.new(1, 0, 0, 50)
        loadingText.Position = UDim2.new(0, 0, 0.5, -25)
        loadingText.BackgroundTransparency = 1
        loadingText.Text = "Loading " .. languageName .. "..."
        loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadingText.TextScaled = true
        loadingText.Font = Enum.Font.GothamBold
        loadingText.Parent = loadingFrame
        
        local pulse = TweenService:Create(loadingText,
            TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {TextTransparency = 0.5}
        )
        pulse:Play()
        
        spawn(function()
            wait(1)
            
            local success, result = pcall(function()
                loadstring(game:HttpGet(scriptUrl))()
            end)
            
            if success then
                local fadeOut = TweenService:Create(screenGui,
                    TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {Enabled = false}
                )
                fadeOut:Play()
                
                fadeOut.Completed:Connect(function()
                    screenGui:Destroy()
                end)
            else
                loadingText.Text = "Error loading script"
                loadingText.TextColor3 = Color3.fromRGB(255, 100, 100)
                wait(2)
                loadingFrame:Destroy()
            end
        end)
    end)
    
    return button
end

for languageName, scriptUrl in pairs(scripts) do
    createLanguageButton(languageName, scriptUrl)
end

local function updateCanvasSize()
    local contentSize = gridLayout.AbsoluteContentSize
    scrollFrame.CanvasSize = UDim2.new(0, contentSize.X, 0, contentSize.Y + 20)
end

gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
updateCanvasSize()

mainFrame.Position = UDim2.new(0.5, -225, 1.5, 0)
local entranceTween = TweenService:Create(mainFrame,
    TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Position = UDim2.new(0.5, -225, 0.5, -325)}
)
entranceTween:Play()

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
closeButton.BackgroundTransparency = 0.3
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 15)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    local exitTween = TweenService:Create(mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Position = UDim2.new(0.5, -225, 1.5, 0)}
    )
    exitTween:Play()
    
    exitTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)
