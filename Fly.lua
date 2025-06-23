local Players = game:GetService('Players')
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild('PlayerGui')

local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = 'LanguageSelector'
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new('Frame')
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new('TextLabel')
Title.Text = 'Which language do you want?'
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.Parent = Frame

local function createButton(text, position, url)
    local Button = Instance.new('TextButton')
    Button.Size = UDim2.new(0.8, 0, 0, 40)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 20
    Button.Text = text
    Button.Parent = Frame

    Button.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        ScreenGui:Destroy()
    end)
end

-- Updated Gist links
createButton(
    'ENGLISH',
    UDim2.new(0.1, 0, 0, 50),
    'https://gist.githubusercontent.com/checkurasshole/1da7beb773ff4e66309c3251e0bc7c86/raw/009ba1c40af96700e2c5b506accf6df62ee7bcf0/English_Heaven.lua'
)
createButton(
    'FRENCH',
    UDim2.new(0.1, 0, 0, 100),
    'https://gist.githubusercontent.com/checkurasshole/1da7beb773ff4e66309c3251e0bc7c86/raw/009ba1c40af96700e2c5b506accf6df62ee7bcf0/french_heaven.lua'
)
createButton(
    'SPANISH',
    UDim2.new(0.1, 0, 0, 150),
    'https://gist.githubusercontent.com/checkurasshole/1da7beb773ff4e66309c3251e0bc7c86/raw/009ba1c40af96700e2c5b506accf6df62ee7bcf0/Spanish_heaven.lua'
)
