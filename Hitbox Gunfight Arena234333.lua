-- optimization and variables
local game = game
local players = game:GetService("Players")
local player = players.LocalPlayer
local teams = game:GetService("Teams");
local rs = game:GetService("RunService")
local camera = workspace.CurrentCamera
local vector2 = Vector2.new
local enum = Enum.KeyCode
local silentaim = false
local silentkeybindtoggle = false
local silentkeybind = false

-- functions
local get_closest_player = function()
    local closest = nil
    local closest_distance = math.huge

    for _, character in workspace.GetChildren(workspace) do
        local player = players.FindFirstChild(players, character.Name)
        local root_part = character.FindFirstChild(character, "HumanoidRootPart")

        if (not player) or (not root_part) then
            continue
        end

        if (character.Humanoid.Health <= 0) then
            continue
        end

        local team_attribute = player.GetAttribute(player, "Team")

        if (not team_attribute) then
            continue
        end

        if (teams[team_attribute] == players.LocalPlayer.Team) then
            continue
        end

        local position, on_screen = camera.WorldToViewportPoint(camera, root_part.Position)

        if (not on_screen) then
            continue
        end

        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local distance = (Vector2.new(position.X, position.Y) - center).Magnitude

        if (closest_distance > distance) then
            closest = character
            closest_distance = distance
        end
    end

    return closest
end

local events = {
    ["ShootEvent"] = function(arg)
        return (typeof(arg) == "Instance" and arg.Name and (string.find(arg.Name, players.LocalPlayer.Name)))
    end,
}

local old_namecall
old_namecall = hookmetamethod(game, "__namecall", function(self, caller, message, ...)
    local method = getnamecallmethod()

    if (method == "Fire" and self.Name == "Sync") then
        for event, identify in events do
            if (event == "ShootEvent" and identify(message)) then
                local closest_player = get_closest_player()
                local ammo, cframe, id, weapon, projectile = ...

                if (closest_player and closest_player.FindFirstChild(closest_player, "Head")) and silentaim then
                    if silentkeybindtoggle then
                        if silentkeybind then
                            cframe = closest_player.Head.CFrame
                        end
                    else
                        cframe = closest_player.Head.CFrame
                    end
                end

                return old_namecall(self, caller, message, ammo, cframe, id, weapon, projectile, ...)
            end
        end
    end

    return old_namecall(self, caller, message, ...)
end)

-- OrionLib UI for Silent Aim
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Gunfight Arena - Silent Aim", HidePremium = false, SaveConfig = false, ConfigFolder = "gunfightarena"})

local aimtab = Window:MakeTab({
	Name = "Aim",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local aimsection = aimtab:AddSection({
	Name = "SilentAim"
})

aimsection:AddToggle({
	Name = "Silent Aim (credit to dementia)",
	Default = false,
	Callback = function(Value)
		silentaim = Value
	end    
})

aimsection:AddToggle({
	Name = "SilentAim keybind toggle",
	Default = false,
	Callback = function(Value)
		silentkeybindtoggle = Value
	end    
})

aimsection:AddBind({
	Name = "silent aim keybind",
	Default = enum.E,
	Hold = false,
	Callback = function()
        if silentkeybindtoggle then
            silentkeybind = not silentkeybind
        end
	end    
})

OrionLib:Init()
