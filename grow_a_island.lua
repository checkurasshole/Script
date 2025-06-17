local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LanguageSelector"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Which language do you want?"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.Parent = Frame

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

-- New third set of links:
createButton("ENGLISH", UDim2.new(0.1, 0, 0, 50), "https://gist.githubusercontent.com/checkurasshole/02f025fd5ef64157fe3f69ac3f8b0f81/raw/88573a2239ca7524c818ff50e6a47af39f4dccd0/grow_a_island.lua")
createButton("PORTUGUESE", UDim2.new(0.1, 0, 0, 100), "https://gist.githubusercontent.com/checkurasshole/065d24127ba0ce82aa1aaf664582ae0c/raw/405c18632140495d739ef6ff609909aa333cc887/grow_a_islandprt.lua")
createButton("SPANISH", UDim2.new(0.1, 0, 0, 150), "https://gist.githubusercontent.com/checkurasshole/a5519077e0654e63abecb8eb0315338c/raw/4be76436b3ff287d06859b97153309a46d87634e/grow_a_islandspan.lua")
