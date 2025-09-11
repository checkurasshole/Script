-- Original English Script
-- Script ID: a3521b974c0dba3255e99b581886c973
-- Migrated: 2025-09-11T14:25:53.542Z
-- Auto-migrated from encrypted storage to GitHub

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
    ["English"] = "http....",
    ["Spanish"] = "__URL_faf991a3cf6e6e2a__"
}

local SAVE_KEY = "LanguageSelector_" .. game.GameId .. "_SavedSettings"
local autoSaveEnabled = true
local savedLanguage = nil
local currentScale = 1
local minScale = 0.5
local maxScale = 2

local function createParticleSystem(parent)
    local particleFrame = Instance.new("Frame")
    particleFrame.Name = "ParticleSystem"
    particleFrame.Size = UDim2.new(1, 0, 1, 0)
    particleFrame.Position = UDim2.new(0, 0, 0, 0)
    particleFrame.BackgroundTransparency = 1
    particleFrame.ClipsDescendants = true
    particleFrame.Parent = parent
    
    for i = 1, 25 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 8), 0, math.random(2, 8))
        particle.Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
        particle.BackgroundColor3 = Color3.fromHSV(math.random(0, 360) / 360, 0.7, 1)
        particle.BackgroundTransparency = math.random(30, 80) / 100
        particle.BorderSizePixel = 0
        particle.Parent = particleFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, particle.Size.X.Offset / 2)
        corner.Parent = particle
        
        spawn(function()
            while particle.Parent do
                local moveTween = TweenService:Create(particle,
                    TweenInfo.new(math.random(8, 15), Enum.EasingStyle.Linear),
                    {Position = UDim2.new(math.random(-20, 120) / 100, 0, math.random(-20, 120) / 100, 0)}
                )
                moveTween:Play()
                moveTween.Completed:Wait()
                
                local fadeTween = TweenService:Create(particle,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                    {BackgroundTransparency = 1}
                )
                fadeTween:Play()
                fadeTween.Completed:Wait()
                
                particle.Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
                particle.BackgroundColor3 = Color3.fromHSV(math.random(0, 360) / 360, 0.7, 1)
                
                local showTween = TweenService:Create(particle,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad),
                    {BackgroundTransparency = math.random(30, 80) / 100}
                )
                showTween:Play()
                showTween.Completed:Wait()
            end
        end)
    end
    
    return particleFrame
end

local function showResetNotification()
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "ResetNotificationGUI"
    notificationGui.Parent = getGuiParent()
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        notificationGui.IgnoreGuiInset = true
    end)
    
    local notificationWidth = 280
    local notificationHeight = 80
    
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0, notificationWidth, 0, notificationHeight)
    notificationFrame.Position = UDim2.new(1, 20, 0, 20)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    notificationFrame.BackgroundTransparency = 0.05
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = notificationGui
    
    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 12)
    notificationCorner.Parent = notificationFrame
    
    local notificationShadow = Instance.new("Frame")
    notificationShadow.Name = "NotificationShadow"
    notificationShadow.Size = UDim2.new(1, 20, 1, 20)
    notificationShadow.Position = UDim2.new(0, -10, 0, -8)
    notificationShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notificationShadow.BackgroundTransparency = 0.7
    notificationShadow.ZIndex = notificationFrame.ZIndex - 1
    notificationShadow.BorderSizePixel = 0
    notificationShadow.Parent = notificationFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 16)
    shadowCorner.Parent = notificationShadow
    
    local notificationGradient = Instance.new("UIGradient")
    notificationGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 50, 70)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 40, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 60, 90))
    }
    notificationGradient.Rotation = 45
    notificationGradient.Parent = notificationFrame
    
    local notificationStroke = Instance.new("UIStroke")
    notificationStroke.Color = Color3.fromRGB(120, 140, 255)
    notificationStroke.Transparency = 0.3
    notificationStroke.Thickness = 1.5
    notificationStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    notificationStroke.Parent = notificationFrame
    
    local questionText = Instance.new("TextLabel")
    questionText.Name = "QuestionText"
    questionText.Size = UDim2.new(1, -20, 0, 30)
    questionText.Position = UDim2.new(0, 10, 0, 8)
    questionText.BackgroundTransparency = 1
    questionText.Text = "🔄 Reset language option chosen?"
    questionText.TextColor3 = Color3.fromRGB(255, 255, 255)
    questionText.TextSize = 12
    questionText.Font = Enum.Font.SourceSansBold
    questionText.TextScaled = true
    questionText.Parent = notificationFrame
    
    local questionStroke = Instance.new("UIStroke")
    questionStroke.Color = Color3.fromRGB(180, 200, 255)
    questionStroke.Thickness = 0.8
    questionStroke.Transparency = 0.4
    questionStroke.Parent = questionText
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, -20, 0, 32)
    buttonFrame.Position = UDim2.new(0, 10, 1, -40)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = notificationFrame
    
    local yesButton = Instance.new("TextButton")
    yesButton.Name = "YesButton"
    yesButton.Size = UDim2.new(0, 60, 1, 0)
    yesButton.Position = UDim2.new(0, 0, 0, 0)
    yesButton.BackgroundColor3 = Color3.fromRGB(100, 220, 120)
    yesButton.BackgroundTransparency = 0.1
    yesButton.BorderSizePixel = 0
    yesButton.Text = "Yes"
    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.TextSize = 11
    yesButton.Font = Enum.Font.SourceSansBold
    yesButton.Parent = buttonFrame
    
    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 8)
    yesCorner.Parent = yesButton
    
    local yesStroke = Instance.new("UIStroke")
    yesStroke.Color = Color3.fromRGB(140, 240, 160)
    yesStroke.Thickness = 1
    yesStroke.Transparency = 0.3
    yesStroke.Parent = yesButton
    
    local noButton = Instance.new("TextButton")
    noButton.Name = "NoButton"
    noButton.Size = UDim2.new(0, 60, 1, 0)
    noButton.Position = UDim2.new(0, 70, 0, 0)
    noButton.BackgroundColor3 = Color3.fromRGB(255, 100, 120)
    noButton.BackgroundTransparency = 0.1
    noButton.BorderSizePixel = 0
    noButton.Text = "No"
    noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noButton.TextSize = 11
    noButton.Font = Enum.Font.SourceSansBold
    noButton.Parent = buttonFrame
    
    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 8)
    noCorner.Parent = noButton
    
    local noStroke = Instance.new("UIStroke")
    noStroke.Color = Color3.fromRGB(255, 140, 160)
    noStroke.Thickness = 1
    noStroke.Transparency = 0.3
    noStroke.Parent = noButton
    
    local timeLeft = 5
    local timerBar = Instance.new("Frame")
    timerBar.Name = "TimerBar"
    timerBar.Size = UDim2.new(1, 0, 0, 2)
    timerBar.Position = UDim2.new(0, 0, 1, -2)
    timerBar.BackgroundColor3 = Color3.fromRGB(120, 200, 255)
    timerBar.BorderSizePixel = 0
    timerBar.Parent = notificationFrame
    
    local timerCorner = Instance.new("UICorner")
    timerCorner.CornerRadius = UDim.new(0, 1)
    timerCorner.Parent = timerBar
    
    local slideInTween = TweenService:Create(notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -notificationWidth - 20, 0, 20)}
    )
    slideInTween:Play()
    
    local timerTween = TweenService:Create(timerBar,
        TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 0, 0, 2)}
    )
    timerTween:Play()
    
    local function closeNotification()
        local slideOutTween = TweenService:Create(notificationFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 20, 0, 20)}
        )
        slideOutTween:Play()
        
        slideOutTween.Completed:Connect(function()
            notificationGui:Destroy()
        end)
    end
    
    yesButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(yesButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.05, TextColor3 = Color3.fromRGB(255, 255, 255)}
        )
        hoverTween:Play()
    end)
    
    yesButton.MouseLeave:Connect(function()
        local normalTween = TweenService:Create(yesButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.1, TextColor3 = Color3.fromRGB(255, 255, 255)}
        )
        normalTween:Play()
    end)
    
    noButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(noButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.05, TextColor3 = Color3.fromRGB(255, 255, 255)}
        )
        hoverTween:Play()
    end)
    
    noButton.MouseLeave:Connect(function()
        local normalTween = TweenService:Create(noButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.1, TextColor3 = Color3.fromRGB(255, 255, 255)}
        )
        normalTween:Play()
    end)
    
    yesButton.MouseButton1Click:Connect(function()
        savedLanguage = nil
        if isfile(SAVE_KEY .. ".json") then
            delfile(SAVE_KEY .. ".json")
        end
        closeNotification()
    end)
    
    noButton.MouseButton1Click:Connect(function()
        closeNotification()
    end)
    
    timerTween.Completed:Connect(function()
        closeNotification()
    end)
end

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
            wait(1)
            showResetNotification()
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

local frameWidth = 280
local frameHeight = 380

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
mainFrame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.02
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

local shadowFrame = Instance.new("Frame")
shadowFrame.Name = "ShadowFrame"
shadowFrame.Size = UDim2.new(1, 40, 1, 40)
shadowFrame.Position = UDim2.new(0, -20, 0, -15)
shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadowFrame.BackgroundTransparency = 0.7
shadowFrame.ZIndex = mainFrame.ZIndex - 1
shadowFrame.BorderSizePixel = 0
shadowFrame.Parent = mainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 23)
shadowCorner.Parent = shadowFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 30, 90)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(30, 45, 80)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(45, 30, 85)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 60, 95))
}
gradient.Rotation = 135
gradient.Parent = mainFrame

local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Color3.fromRGB(120, 140, 255)
innerStroke.Transparency = 0.2
innerStroke.Thickness = 2
innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
innerStroke.Parent = mainFrame

local strokeGradient = Instance.new("UIGradient")
strokeGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 200)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(100, 200, 255)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(200, 255, 100)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 200, 100)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(150, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 200))
}
strokeGradient.Parent = innerStroke

local time = 0
local strokeConnection = RunService.Heartbeat:Connect(function(dt)
    time = time + dt
    strokeGradient.Rotation = (time * 60) % 360
    innerStroke.Transparency = 0.2 + math.sin(time * 3) * 0.1
end)

local dragToggle = nil
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        if dragToggle then
            updateInput(input)
        end
    end
end)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -60, 0, 35)
title.Position = UDim2.new(0, 15, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🌍 SELECT LANGUAGE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = mainFrame

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(120, 200, 255)
titleStroke.Thickness = 1
titleStroke.Transparency = 0.5
titleStroke.Parent = title

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(1, -30, 0, 20)
subtitle.Position = UDim2.new(0, 15, 0, 45)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Choose preferred language • Drag to move"
subtitle.TextColor3 = Color3.fromRGB(180, 200, 255)
subtitle.TextSize = 10
subtitle.Font = Enum.Font.SourceSansItalic
subtitle.TextScaled = true
subtitle.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -32, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 80)
closeButton.BackgroundTransparency = 0.1
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 12
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 12)
closeCorner.Parent = closeButton

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = Color3.fromRGB(255, 100, 120)
closeStroke.Thickness = 1
closeStroke.Transparency = 0.3
closeStroke.Parent = closeButton

local autoSaveFrame = Instance.new("Frame")
autoSaveFrame.Name = "AutoSaveFrame"
autoSaveFrame.Size = UDim2.new(1, -30, 0, 32)
autoSaveFrame.Position = UDim2.new(0, 15, 0, 70)
autoSaveFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
autoSaveFrame.BackgroundTransparency = 0.92
autoSaveFrame.BorderSizePixel = 0
autoSaveFrame.Parent = mainFrame

local autoSaveCorner = Instance.new("UICorner")
autoSaveCorner.CornerRadius = UDim.new(0, 8)
autoSaveCorner.Parent = autoSaveFrame

local autoSaveStroke = Instance.new("UIStroke")
autoSaveStroke.Color = Color3.fromRGB(200, 220, 255)
autoSaveStroke.Transparency = 0.6
autoSaveStroke.Thickness = 1
autoSaveStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
autoSaveStroke.Parent = autoSaveFrame

local autoSaveLabel = Instance.new("TextLabel")
autoSaveLabel.Name = "AutoSaveLabel"
autoSaveLabel.Size = UDim2.new(1, -45, 1, 0)
autoSaveLabel.Position = UDim2.new(0, 10, 0, 0)
autoSaveLabel.BackgroundTransparency = 1
autoSaveLabel.Text = "💾 Auto-Save Settings"
autoSaveLabel.TextColor3 = Color3.fromRGB(220, 230, 255)
autoSaveLabel.TextSize = 10
autoSaveLabel.Font = Enum.Font.SourceSans
autoSaveLabel.TextXAlignment = Enum.TextXAlignment.Left
autoSaveLabel.TextScaled = true
autoSaveLabel.Parent = autoSaveFrame

local autoSaveToggle = Instance.new("TextButton")
autoSaveToggle.Name = "AutoSaveToggle"
autoSaveToggle.Size = UDim2.new(0, 35, 0, 16)
autoSaveToggle.Position = UDim2.new(1, -40, 0.5, -8)
autoSaveToggle.BackgroundColor3 = autoSaveEnabled and Color3.fromRGB(100, 220, 120) or Color3.fromRGB(120, 120, 140)
autoSaveToggle.BorderSizePixel = 0
autoSaveToggle.Text = ""
autoSaveToggle.Parent = autoSaveFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = autoSaveToggle

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = autoSaveEnabled and Color3.fromRGB(140, 240, 160) or Color3.fromRGB(160, 160, 180)
toggleStroke.Thickness = 1
toggleStroke.Transparency = 0.4
toggleStroke.Parent = autoSaveToggle

local toggleIndicator = Instance.new("Frame")
toggleIndicator.Name = "Indicator"
toggleIndicator.Size = UDim2.new(0, 12, 0, 12)
toggleIndicator.Position = autoSaveEnabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleIndicator.BorderSizePixel = 0
toggleIndicator.Parent = autoSaveToggle

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, 6)
indicatorCorner.Parent = toggleIndicator

local indicatorStroke = Instance.new("UIStroke")
indicatorStroke.Color = Color3.fromRGB(200, 200, 220)
indicatorStroke.Thickness = 1
indicatorStroke.Transparency = 0.3
indicatorStroke.Parent = toggleIndicator

autoSaveToggle.MouseButton1Click:Connect(function()
    autoSaveEnabled = not autoSaveEnabled
    
    local toggleColorTween = TweenService:Create(autoSaveToggle,
        TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {BackgroundColor3 = autoSaveEnabled and Color3.fromRGB(100, 220, 120) or Color3.fromRGB(120, 120, 140)}
    )
    toggleColorTween:Play()
    
    local toggleStrokeTween = TweenService:Create(toggleStroke,
        TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Color = autoSaveEnabled and Color3.fromRGB(140, 240, 160) or Color3.fromRGB(160, 160, 180)}
    )
    toggleStrokeTween:Play()
    
    local indicatorTween = TweenService:Create(toggleIndicator,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = autoSaveEnabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}
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
scrollFrame.Size = UDim2.new(1, -30, 1, -120)
scrollFrame.Position = UDim2.new(0, 15, 0, 110)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 170, 255)
scrollFrame.ScrollBarImageTransparency = 0.2
scrollFrame.Parent = mainFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 240, 0, 55)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 12)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.SortOrder = Enum.SortOrder.Name
gridLayout.Parent = scrollFrame

local function createLanguageButton(languageName, scriptUrl)
    local button = Instance.new("TextButton")
    button.Name = languageName
    button.Size = gridLayout.CellSize
    button.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    button.BackgroundTransparency = (savedLanguage == languageName) and 0.1 or 0.4
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = scrollFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 16)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = (savedLanguage == languageName) and Color3.fromRGB(150, 220, 255) or Color3.fromRGB(80, 120, 200)
    buttonStroke.Transparency = (savedLanguage == languageName) and 0.1 or 0.3
    buttonStroke.Thickness = (savedLanguage == languageName) and 3 or 2
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Parent = button
    
    local strokeGradientBtn = Instance.new("UIGradient")
    strokeGradientBtn.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 200)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 255, 200)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(200, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 100))
    }
    strokeGradientBtn.Parent = buttonStroke
    
    if savedLanguage == languageName then
        spawn(function()
            local time = 0
            while button.Parent do
                time = time + RunService.Heartbeat:Wait()
                strokeGradientBtn.Rotation = (time * 60) % 360
            end
        end)
    end
    
    local labelFrame = Instance.new("Frame")
    labelFrame.Size = UDim2.new(1, -20, 0, 30)
    labelFrame.Position = UDim2.new(0, 10, 0, 5)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Parent = button
    
    local languageIcon = Instance.new("TextLabel")
    languageIcon.Size = UDim2.new(0, 25, 1, 0)
    languageIcon.Position = UDim2.new(0, 0, 0, 0)
    languageIcon.BackgroundTransparency = 1
    languageIcon.Text = "◉"
    languageIcon.TextColor3 = (savedLanguage == languageName) and Color3.fromRGB(150, 255, 200) or Color3.fromRGB(120, 180, 255)
    languageIcon.TextSize = 18
    languageIcon.Font = Enum.Font.SourceSansBold
    languageIcon.Parent = labelFrame
    
    local languageLabel = Instance.new("TextLabel")
    languageLabel.Size = UDim2.new(1, -35, 1, 0)
    languageLabel.Position = UDim2.new(0, 30, 0, 0)
    languageLabel.BackgroundTransparency = 1
    languageLabel.Text = "▶ " .. languageName
    languageLabel.TextColor3 = (savedLanguage == languageName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 220, 255)
    languageLabel.TextSize = 14
    languageLabel.Font = Enum.Font.SourceSansBold
    languageLabel.TextXAlignment = Enum.TextXAlignment.Left
    languageLabel.TextScaled = true
    languageLabel.Parent = labelFrame
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, -20, 0, 15)
    statusFrame.Position = UDim2.new(0, 10, 1, -20)
    statusFrame.BackgroundTransparency = 1
    statusFrame.Parent = button
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.Position = UDim2.new(0, 0, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = (savedLanguage == languageName) and "● ACTIVE CONFIGURATION" or "○ Ready for Initialization"
    statusLabel.TextColor3 = (savedLanguage == languageName) and Color3.fromRGB(120, 255, 150) or Color3.fromRGB(150, 170, 200)
    statusLabel.TextSize = 9
    statusLabel.Font = Enum.Font.SourceSansItalic
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextScaled = true
    statusLabel.Parent = statusFrame
    
    local originalSize = button.Size
    local hoverSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 15, originalSize.Y.Scale, originalSize.Y.Offset + 8)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            BackgroundTransparency = 0.05,
            Size = hoverSize
        }):Play()
        
        TweenService:Create(buttonStroke, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Transparency = 0.05,
            Thickness = 4
        }):Play()
        
        TweenService:Create(languageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        
        TweenService:Create(languageIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextColor3 = Color3.fromRGB(200, 255, 150)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            BackgroundTransparency = (savedLanguage == languageName) and 0.1 or 0.4,
            Size = originalSize
        }):Play()
        
        TweenService:Create(buttonStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Transparency = (savedLanguage == languageName) and 0.1 or 0.3,
            Thickness = (savedLanguage == languageName) and 3 or 2
        }):Play()
        
        TweenService:Create(languageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextColor3 = (savedLanguage == languageName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 220, 255)
        }):Play()
        
        TweenService:Create(languageIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextColor3 = (savedLanguage == languageName) and Color3.fromRGB(150, 255, 200) or Color3.fromRGB(120, 180, 255)
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        savedLanguage = languageName
        saveSettings()
        
        local loadingFrame = Instance.new("Frame")
        loadingFrame.Name = "LoadingFrame"
        loadingFrame.Size = UDim2.new(1, 0, 1, 0)
        loadingFrame.Position = UDim2.new(0, 0, 0, 0)
        loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        loadingFrame.BackgroundTransparency = 0.1
        loadingFrame.Parent = mainFrame
        
        local loadingCorner = Instance.new("UICorner")
        loadingCorner.CornerRadius = mainCorner.CornerRadius
        loadingCorner.Parent = loadingFrame
        
        local loadingGradient = Instance.new("UIGradient")
        loadingGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 40)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 20, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 40, 80))
        }
        loadingGradient.Rotation = 45
        loadingGradient.Parent = loadingFrame
        
        local loadingText = Instance.new("TextLabel")
        loadingText.Size = UDim2.new(1, -30, 0, 35)
        loadingText.Position = UDim2.new(0, 15, 0.5, -17)
        loadingText.BackgroundTransparency = 1
        loadingText.Text = "▄︻デ══━一💥Loading " .. languageName .. "..."
        loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadingText.TextSize = 16
        loadingText.Font = Enum.Font.SourceSansBold
        loadingText.TextScaled = true
        loadingText.Parent = loadingFrame
        
        local loadingStroke = Instance.new("UIStroke")
        loadingStroke.Color = Color3.fromRGB(120, 200, 255)
        loadingStroke.Thickness = 1
        loadingStroke.Transparency = 0.3
        loadingStroke.Parent = loadingText
        
        local loadingBar = Instance.new("Frame")
        loadingBar.Name = "LoadingBar"
        loadingBar.Size = UDim2.new(0.7, 0, 0, 4)
        loadingBar.Position = UDim2.new(0.15, 0, 0.65, 0)
        loadingBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        loadingBar.BorderSizePixel = 0
        loadingBar.Parent = loadingFrame
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 2)
        barCorner.Parent = loadingBar
        
        local loadingProgress = Instance.new("Frame")
        loadingProgress.Name = "LoadingProgress"
        loadingProgress.Size = UDim2.new(0, 0, 1, 0)
        loadingProgress.Position = UDim2.new(0, 0, 0, 0)
        loadingProgress.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        loadingProgress.BorderSizePixel = 0
        loadingProgress.Parent = loadingBar
        
        local progressCorner = Instance.new("UICorner")
        progressCorner.CornerRadius = UDim.new(0, 2)
        progressCorner.Parent = loadingProgress
        
        local progressGradient = Instance.new("UIGradient")
        progressGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 220, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 240, 255))
        }
        progressGradient.Parent = loadingProgress
        
        local pulse = TweenService:Create(loadingText,
            TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {TextTransparency = 0.3}
        )
        pulse:Play()
        
        local progressTween = TweenService:Create(loadingProgress,
            TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 1, 0)}
        )
        progressTween:Play()
        
        spawn(function()
            wait(1.8)
            
            local success, result = pcall(function()
                loadstring(game:HttpGet(scriptUrl))()
            end)
            
            if strokeConnection then
                strokeConnection:Disconnect()
            end
            screenGui:Destroy()
            
            wait(1)
            showResetNotification()
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

mainFrame.Position = UDim2.new(0.5, -frameWidth/2, 1.2, 0)
local entranceTween = TweenService:Create(mainFrame,
    TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)}
)
entranceTween:Play()

closeButton.MouseButton1Click:Connect(function()
    local exitTween = TweenService:Create(mainFrame,
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Position = UDim2.new(0.5, -frameWidth/2, 1.2, 0)}
    )
    exitTween:Play()
    
    exitTween.Completed:Connect(function()
        if strokeConnection then
            strokeConnection:Disconnect()
        end
        screenGui:Destroy()
    end)
end)