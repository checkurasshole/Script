-- Hitbox Gunfight Arena.lua
-- Silent Aim functionality for ComboChronicle Vault | Gunfight Arena

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Silent Aim Variables
local silentaim = false
local silentkeybindtoggle = false
local silentkeybind = false

-- Function to get the closest player
local function get_closest_player()
    local closest = nil
    local closest_distance = math.huge

    for _, character in ipairs(Workspace:GetChildren()) do
        local player = Players:FindFirstChild(character.Name)
        local root_part = character:FindFirstChild("HumanoidRootPart")

        if not player or not root_part then
            continue
        end

        if character.Humanoid.Health <= 0 then
            continue
        end

        local team_attribute = player:GetAttribute("Team")
        if not team_attribute or Teams[team_attribute] == Players.LocalPlayer.Team then
            continue
        end

        local position, on_screen = Camera:WorldToViewportPoint(root_part.Position)
        if not on_screen then
            continue
        end

        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local distance = (Vector2.new(position.X, position.Y) - center).Magnitude

        if closest_distance > distance then
            closest = character
            closest_distance = distance
        end
    end

    return closest
end

-- Silent Aim Hook
local events = {
    ["ShootEvent"] = function(arg)
        return typeof(arg) == "Instance" and arg.Name and string.find(arg.Name, Players.LocalPlayer.Name)
    end
}

local old_namecall
old_namecall = hookmetamethod(game, "__namecall", function(self, caller, message, ...)
    local method = getnamecallmethod()

    if method == "Fire" and self.Name == "Sync" then
        for event, identify in pairs(events) do
            if event == "ShootEvent" and identify(message) then
                local closest_player = get_closest_player()
                local ammo, cframe, id, weapon, projectile = ...

                if closest_player and closest_player:FindFirstChild("Head") and silentaim then
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

-- Function to enable/disable silent aim
local function setSilentAim(state)
    silentaim = state
end

-- Expose the setSilentAim function globally
getgenv().SilentAimControl = {
    setSilentAim = setSilentAim
}
