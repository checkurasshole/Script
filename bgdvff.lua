local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create the GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LanguageSelector"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "Which language do you want?"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.Parent = Frame

-- Function to create buttons
local function createButton(text, position, url)
	local Button = Instance.new("TextButton")
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

-- Create buttons with new links
createButton("ENGLISH", UDim2.new(0.1, 0, 0, 50), "https://gist.githubusercontent.com/checkurasshole/b71e56088e1e1f7d3ae1b1d3bc06334a/raw/a5219e1d8eb52f7a1a9940e6691a1c54fdaea7a1/bgdvff.lua")
createButton("PORTUGUESE", UDim2.new(0.1, 0, 0, 100), "https://gist.githubusercontent.com/checkurasshole/c0ee97b420603ed7978e24ffb023952e/raw/535182447a3ce2dd90b49b571b357c61245ccb14/bgdvf.lua")
createButton("SPANISH", UDim2.new(0.1, 0, 0, 150), "https://gist.githubusercontent.com/checkurasshole/552b58f19b0b82b9a27f73d741527eb1/raw/a19f75832805e59b72b392d685266c33a8945d98/wsfdc.lua")
