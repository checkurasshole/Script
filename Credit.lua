local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local localPlayer = Players.LocalPlayer

 
local screenGui = Instance.new('ScreenGui')
screenGui.Name = 'NotificationGUI'
screenGui.Parent = localPlayer:WaitForChild('PlayerGui')
screenGui.ResetOnSpawn = false

 
local frame = Instance.new('Frame')
frame.Size = UDim2.new(0, 300, 0, 80)
frame.Position = UDim2.new(1, 0, 0.5, -40) -- Start off-screen to the right
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

 
local uiCorner = Instance.new('UICorner')
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = frame

 
local textLabel = Instance.new('TextLabel')
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = 'Credits: COMBO_WICK & 2AreYouMental110'
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.Font = Enum.Font.SourceSansBold
textLabel.TextSize = 20
textLabel.TextWrapped = true
textLabel.Parent = frame

 
local function animateNotification()
    -- Slide in from right
    local tweenIn = TweenService:Create(
        frame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, -150, 0.5, -40) } -- Center of screen
    )
    tweenIn:Play()
    tweenIn.Completed:Wait()

    
    task.wait(7)

    
    local tweenOut = TweenService:Create(
        frame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(-1, -300, 0.5, -40) } -- Off-screen to the left
    )
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        screenGui:Destroy() -- Clean up after animation
    end)
end

-- Run animation
animateNotification()
