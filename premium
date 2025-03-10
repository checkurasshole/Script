local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Window = Rayfield:CreateWindow({
    Name = "🔥 COMBO_WICK Apocalypse Unleashed 🔥",
    LoadingTitle = "⚡ Summoning the Apocalypse ⚡",
    LoadingSubtitle = "by Theodorzeidos & COMBO_WICK",
    ConfigurationSaving = {Enabled = true, FolderName = "TheodorBeyondV2", FileName = "DragonApocalypseV2"},
    Discord = {Enabled = true, Invite = "YOUR_DISCORD_INVITE", RememberJoins = true},
    KeySystem = false,
    KeySettings = {Title = "🔥 Enter the Void V2 🔥", Subtitle = "Unleash Total Domination", Note = "Key: BEYOND2025V2", FileName = "BeyondKeyV2", SaveKey = true, GrabKeyFromSite = false, Key = {"BEYOND2025V2"}}
})

Rayfield:Notify({
    Title = "🔥 Beyond V2 GUI Loaded 🔥",
    Content = "Level to 100K, No Mercy!",
    Duration = 5,
    Image = "flame"
})

Rayfield:Notify({
    Title = "⚠️ TOTAL WAR V2 ⚠️",
    Content = "DragonLore + Specific NPC Chaos!",
    Duration = 10,
    Image = "skull"
})

local Config = {
    SpamDragon = false,
    OPKillaura = false,
    AutoKillNPCs = false,
    TeleportSpecificNPCs = false,
    GodMode = false,
    SpeedHack = false,
    Invisibility = false,
    LagReducer = false,
    SpamCooldown = 0.01,
    KillRange = 500,
    FollowSpeed = 100,
    JumpHeight = 100,
    NPCDistance = 50
}

local State = {
    LastDragonSpamTime = 0,
    LastKillTime = 0,
    KillauraActive = false,
    OriginalFogEnd = Lighting.FogEnd,
    OriginalBrightness = Lighting.Brightness
}

local SpecificNPCs = {
    "RobotMega",
    "Samurai",
    "Froguilherm",
    "FrogSapone",
    "Ramatut"
}

local remoteEvents = {
    game:GetService("ReplicatedStorage").DragonLoreSkillEvent2,
    game:GetService("ReplicatedStorage").BlackHoleMagicEvent,
    game:GetService("ReplicatedStorage").SukunaMagicEvent2,
    game:GetService("ReplicatedStorage").ThunderSkillEvent2,
    game:GetService("ReplicatedStorage").RedSteelSwordEvent2,
    game:GetService("ReplicatedStorage").WhiteSteelSwordSkillEvent2
}

local function FireDragon()
    pcall(function()
        ReplicatedStorage:WaitForChild("DragonLoreSkillEvent2"):FireServer()
    end)
end

local function IsAlive(character)
    local humanoid = character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function StartKillaura()
    if not Config.OPKillaura then return end
    State.KillauraActive = true
    while Config.OPKillaura do
        for _, remoteEvent in pairs(remoteEvents) do
            pcall(function()
                remoteEvent:FireServer()
            end)
        end
        task.wait(Config.SpamCooldown)
    end
    State.KillauraActive = false
end

local function AutoKillNPCs()
    if not Config.AutoKillNPCs or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = LocalPlayer.Character.HumanoidRootPart
    local currentTime = tick()
    if currentTime - State.LastKillTime < Config.SpamCooldown then return end

    for _, obj in ipairs(workspace:GetChildren()) do
        local humanoid = obj:FindFirstChild("Humanoid")
        local root = obj:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root or not IsAlive(obj) or Players:GetPlayerFromCharacter(obj) then continue end

        local distance = (myRoot.Position - root.Position).Magnitude
        if distance <= Config.KillRange then
            FireDragon()
            for _, event in pairs(remoteEvents) do
                pcall(function() event:FireServer() end)
            end
        end
    end

    State.LastKillTime = currentTime
end

local function TeleportSpecificNPCs()
    if not Config.TeleportSpecificNPCs or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = LocalPlayer.Character.HumanoidRootPart

    for _, obj in ipairs(workspace:GetChildren()) do
        local humanoid = obj:FindFirstChild("Humanoid")
        local root = obj:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root or not IsAlive(obj) or Players:GetPlayerFromCharacter(obj) then continue end

        for _, npcName in ipairs(SpecificNPCs) do
            if obj.Name == npcName then
                root.CFrame = myRoot.CFrame * CFrame.new(0, 0, -Config.NPCDistance)
                break
            end
        end
    end
end

local function ToggleLagReducer(Value)
    if Value then
        -- Reduce render distance
        Lighting.FogEnd = 50
        Lighting.Brightness = 0
        -- Disable effects
        for _, effect in ipairs(workspace:GetDescendants()) do
            if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
                effect.Enabled = false
            end
        end
        -- Lower NPC update frequency
        Config.SpamCooldown = math.max(Config.SpamCooldown, 0.05) -- Minimum 0.05s to ease load
    else
        -- Restore defaults
        Lighting.FogEnd = State.OriginalFogEnd or 10000
        Lighting.Brightness = State.OriginalBrightness or 1
        for _, effect in ipairs(workspace:GetDescendants()) do
            if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
                effect.Enabled = true
            end
        end
        Config.SpamCooldown = 0.01 -- Reset to original
    end
end

local Tab = Window:CreateTab("🔥 Chaos Control V2", "flame")

Tab:CreateToggle({
    Name = "🐉 Spam Dragon",
    CurrentValue = false,
    Flag = "SpamDragon",
    Callback = function(Value)
        Config.SpamDragon = Value
        Rayfield:Notify({
            Title = "🐉 Dragon Spam",
            Content = Value and "Dragon Apocalypse ON!" or "Stopped",
            Duration = 3,
            Image = "flame"
        })
    end
})

Tab:CreateToggle({
    Name = "⚔️ OP Killaura",
    CurrentValue = false,
    Flag = "OPKillaura",
    Callback = function(Value)
        Config.OPKillaura = Value
        if Value then spawn(StartKillaura) end
        Rayfield:Notify({
            Title = "⚔️ Killaura",
            Content = Value and "Death Aura ON!" or "Off",
            Duration = 3,
            Image = "sword"
        })
    end
})

Tab:CreateToggle({
    Name = "💀 Auto Kill NPCs",
    CurrentValue = false,
    Flag = "AutoKillNPCs",
    Callback = function(Value)
        Config.AutoKillNPCs = Value
        Rayfield:Notify({
            Title = "💀 NPC Slaughter",
            Content = Value and "Monster Massacre ON!" or "Off",
            Duration = 3,
            Image = "skull"
        })
    end
})

Tab:CreateToggle({
    Name = "🌌 Teleport Specific NPCs",
    CurrentValue = false,
    Flag = "TeleportSpecificNPCs",
    Callback = function(Value)
        Config.TeleportSpecificNPCs = Value
        Rayfield:Notify({
            Title = "🌌 Specific NPC Teleport",
            Content = Value and "Targeted Chaos ON!" or "Off",
            Duration = 3,
            Image = "portal"
        })
    end
})

Tab:CreateSlider({
    Name = "Spam Cooldown (s)",
    Range = {0.01, 1},
    Increment = 0.01,
    CurrentValue = 0.01,
    Flag = "SpamCooldown",
    Callback = function(Value)
        Config.SpamCooldown = Value
    end
})

Tab:CreateSlider({
    Name = "Kill Range",
    Range = {10, 1000},
    Increment = 10,
    CurrentValue = 500,
    Flag = "KillRange",
    Callback = function(Value)
        Config.KillRange = Value
    end
})

Tab:CreateButton({
    Name = "🏃 Teleport LVL Fast",
    Callback = function()
        Rayfield:Notify({
            Title = "🏃 Teleport",
            Content = "Warp to Leveling Zone!",
            Duration = 5,
            Image = "running"
        })
        local targetPosition = Vector3.new(7964.574, 1787.371, 6922.9331)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        end
    end
})

local UtilityTab = Window:CreateTab("⚙️ Beyond OP Utilities V2", "wrench")

UtilityTab:CreateToggle({
    Name = "🛡️ God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        Config.GodMode = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value and 150 or 16
            if Value then
                spawn(function()
                    while Config.GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") do
                        LocalPlayer.Character.Humanoid.Health = 1000
                        LocalPlayer.Character.Humanoid.MaxHealth = 1000
                        task.wait(0.01)
                    end
                end)
            end
        end
    end
})

UtilityTab:CreateToggle({
    Name = "⚡ Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        Config.SpeedHack = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value and 500 or 16
        end
    end
})

UtilityTab:CreateToggle({
    Name = "👻 Invisibility",
    CurrentValue = false,
    Flag = "Invisibility",
    Callback = function(Value)
        Config.Invisibility = Value
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = Value and 1 or 0
                end
            end
        end
    end
})

UtilityTab:CreateToggle({
    Name = "🧹 Lag Reducer",
    CurrentValue = false,
    Flag = "LagReducer",
    Callback = function(Value)
        Config.LagReducer = Value
        ToggleLagReducer(Value)
        Rayfield:Notify({
            Title = "🧹 Lag Reducer",
            Content = Value and "Lag Reduction ON!" or "Normal Rendering Restored",
            Duration = 3,
            Image = "broom"
        })
    end
})

UtilityTab:CreateButton({
    Name = "🌌 Infinite Jump",
    Callback = function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = Config.JumpHeight
            humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
                humanoid.Jump = true
            end)
        end
    end
})

UtilityTab:CreateButton({
    Name = "💥 Crash Server",
    Callback = function()
        Rayfield:Notify({
            Title = "💥 Server Annihilation",
            Content = "Total Collapse Incoming!",
            Duration = 5,
            Image = "bomb"
        })
        spawn(function()
            while true do
                FireDragon()
                for _, event in pairs(remoteEvents) do
                    pcall(function() event:FireServer() end)
                end
                task.wait(0.005)
            end
        end)
    end
})

UtilityTab:CreateButton({
    Name = "🌀 Teleport to Random NPC",
    Callback = function()
        local targets = {}
        for _, obj in ipairs(workspace:GetChildren()) do
            local humanoid = obj:FindFirstChild("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")
            if humanoid and root and IsAlive(obj) and not Players:GetPlayerFromCharacter(obj) then
                table.insert(targets, root)
            end
        end
        if #targets > 0 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = targets[math.random(1, #targets)]
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(math.random(-5, 5), 5, math.random(-5, 5))
        end
    end
})

UtilityTab:CreateButton({
    Name = "🌋 Instant Kill All NPCs",
    Callback = function()
        Rayfield:Notify({
            Title = "🌋 NPC Genocide",
            Content = "Wiping Every Monster!",
            Duration = 5,
            Image = "volcano"
        })
        for _, obj in ipairs(workspace:GetChildren()) do
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and IsAlive(obj) and not Players:GetPlayerFromCharacter(obj) then
                for i = 1, 100 do
                    FireDragon()
                    for _, event in pairs(remoteEvents) do
                        pcall(function() event:FireServer() end)
                    end
                end
            end
        end
    end
})

UtilityTab:CreateButton({
    Name = "⚡ Supercharge Attacks",
    Callback = function()
        Rayfield:Notify({
            Title = "⚡ Attack Boost",
            Content = "Unleashing Infinite Power!",
            Duration = 5,
            Image = "lightning"
        })
        spawn(function()
            while true do
                FireDragon()
                for _, event in pairs(remoteEvents) do
                    pcall(function() event:FireServer() end)
                end
                task.wait(0.001)
            end
        end)
    end
})

RunService.RenderStepped:Connect(function()
    local currentTime = tick()

    if Config.SpamDragon then
        if currentTime - State.LastDragonSpamTime >= Config.SpamCooldown then
            FireDragon()
            State.LastDragonSpamTime = currentTime
        end
    end

    if Config.AutoKillNPCs then
        AutoKillNPCs()
    end

    if Config.TeleportSpecificNPCs then
        TeleportSpecificNPCs()
    end

    if Config.GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 1000
    end
end)

spawn(function()
    while true do
        local dummy = Instance.new("RemoteEvent", ReplicatedStorage)
        dummy.Name = "Fake_" .. HttpService:GenerateGUID(false)
        dummy:FireServer(math.random(1, 10000))
        task.wait(math.random(0.5, 2))
        dummy:Destroy()
    end
end)

Rayfield:LoadConfiguration()
message.txt
15 KB
