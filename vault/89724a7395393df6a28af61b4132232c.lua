-- Script_1751992866373
-- Script ID: 89724a7395393df6a28af61b4132232c
-- Migrated: 2025-09-11T12:58:08.980Z
-- Auto-migrated from encrypted storage to GitHub

local Rayfield = loadstring(game:HttpGet('__URL_4239b0b44e06cb61__'))()
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local HttpService = game:GetService('HttpService')
local TeleportService = game:GetService('TeleportService')
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local DEFAULT_CONFIG = {
    webhookUrl = '',
    v2senderUrl = '__URL_17bc495705062a06__',
    autoScanEnabled = true,
    autoServerHopEnabled = false,
    espEnabled = true,
    scanInterval = 5,
    serverHopInterval = 300,
    placeId = game.PlaceId,
    minPlayers = 1,
    maxPlayers = math.huge,
    preferredPlayerCount = 10,
    pingEveryone = false,
    selectedPets = {},
}
for _, pet in pairs({
    'Boneca Ambalabu',
    'Gangster Footera',
    'Chimpanzini Bananini',
    'Fluriflura',
    'Tim Cheese',
    'Tralalero Tralala',
    'Tung Tung Tung Sahur',
    'Los Tralaleritos',
    'Orangutini Ananassini',
    'Brri Brri Bicus Dicus Bombicus',
    'Talpa Di Fero',
    'Rhino Toasterino',
    'Graipuss Medussi',
    'Bambini Crostini',
    'Blueberrinni Octopusini',
    'Girafa Celestre',
    'La Grande Combinasion',
    'Glorbo Fruttodrillo',
    'Ta Ta Ta Ta Sahur',
    'Bombardiro Crocodilo',
    'Svinina Bombardino',
    'Bananita Dolphinita',
    'Bombombini Gusini',
    'Noobini Pizzanini',
    'Ballerina Cappuccina',
    'Trulimero Trulicina',
    'Brr Brr Patapim',
    'Cappuccino Assassino',
    'Trippi Troppi',
    'Lirili Larila',
    'Cocofanto Elefanto',
    'Frigo Camelo',
    'Burbaloni Loliloli',
    'La Vacca Saturno Saturnita',
    'Odin Din Din Dun',
    'Chef Crabracadabra',
}) do
    DEFAULT_CONFIG.selectedPets[pet] = true
end
local PLACE_ID = game.PlaceId
local JOB_ID = game.JobId
local MAX_RETRIES = 3
local RETRY_DELAY = 2
local brainrots = {
    'Boneca Ambalabu',
    'Gangster Footera',
    'Chimpanzini Bananini',
    'Fluriflura',
    'Tim Cheese',
    'Tralalero Tralala',
    'Tung Tung Tung Sahur',
    'Los Tralaleritos',
    'Orangutini Ananassini',
    'Brri Brri Bicus Dicus Bombicus',
    'Talpa Di Fero',
    'Rhino Toasterino',
    'Graipuss Medussi',
    'Bambini Crostini',
    'Blueberrinni Octopusini',
    'Girafa Celestre',
    'La Grande Combinasion',
    'Glorbo Fruttodrillo',
    'Ta Ta Ta Ta Sahur',
    'Bombardiro Crocodilo', --[[==============================]]
    'Svinina Bombardino',
    'Bananita Dolphinita',
    'Bombombini Gusini', --[[============================================]]
    'Noobini Pizzanini',
    'Ballerina Cappuccina',
    'Trulimero Trulicina', --[[======================================================]]
    'Brr Brr Patapim',
    'Cappuccino Assassino', --[[==========================================================]]
    'Trippi Troppi',
    'Lirili Larila',
    'Cocofanto Elefanto',
    'Frigo Camelo', --[[==============================================================]]
    'Burbaloni Loliloli',
    'La Vacca Saturno Saturnita', --[[================================================================]]
    'Odin Din Din Dun',
    'Chef Crabracadabra',
}
local  --[[==================================================================]]config = table.clone(DEFAULT_CONFIG)
local espLines = {}
local  --[[==================================================================]]sessionStats = {
    scans = 0,
    totalFinds = 0,
    startTime = tick(),
}
local  --[[====================================================================]]lastScanResults = {}
local serverData = {}
local isFetchingServers = false --[[====================================================================]]
local Window = Rayfield:CreateWindow({
    Name = 'Combo Pet Hunter v2.1',
    LoadingTitle =  --[[======================================================================]]'Loading...',
    LoadingSubtitle = 'SIM',
    ConfigurationSaving = {
        Enabled = true,
        FolderName =  --[[======================================================================]]'BrainrotESP',
        FileName = 'PetHunterConfig',
    },
    Discord = {
        Enabled = false,
        Invite = '',
        RememberJoins =  --[[======================================================================]]false,
    },
    KeySystem = false,
})
local function loadConfig()
    local success, savedConfig =
        pcall( --[[======================================================================]]
            function()
                return Rayfield:LoadConfiguration()
            end
        )
    if success and savedConfig then
        for  --[[======================================================================]]key, value in pairs(savedConfig) do
            if (DEFAULT_CONFIG[key] ~= nil) and (key ~= 'v2senderUrl') then --[[======================================================================]]
                config[key] = value
            end
        end
        print('Configuration loaded successfully!')
    else
        print( --[[==================================================================]]
            'Using default configuration'
        )
    end
end
local function saveConfig()
    local success = --[[================================================================]]
        pcall(function()
            local configToSave = table.clone(config)
            configToSave.v2senderUrl = nil
            Rayfield: --[[==============================================================]]SaveConfiguration(
                configToSave
            )
        end)
    if success then
        print('Configuration saved successfully!')
    else
        warn( --[[==========================================================]]
            'Failed to save configuration'
        )
    end
end
local MainTab = Window:CreateTab('Main', 4483362458) --[[====================================================]]
local ConfigSection = MainTab:CreateSection('Configuration')
local WebhookInput = MainTab:CreateInput({
    Name =  --[[==============================================]]'Discord Webhook URL',
    PlaceholderText = 'Enter your webhook URL here...',
    RemoveTextAfterFocusLost = false,
    Flag = 'WebhookURL', --[[====================================]]
    Callback = function(Text)
        config.webhookUrl = Text
        saveConfig()
        Rayfield:Notify({
            Title = 'Webhook Updated & Saved',
            Content =  --[[========================]]'Discord webhook URL has been updated and saved',
            Duration = 3,
            Image = 4483362458,
        })
    end,
})
local ControlSection = MainTab:CreateSection('Controls')
local AutoScanToggle = MainTab:CreateToggle({
    Name = 'Auto Scan',
    CurrentValue = config.autoScanEnabled,
    Flag = 'AutoScan',
    Callback = function(Value)
        config.autoScanEnabled = Value
        saveConfig()
        if Value then
            Rayfield:Notify({
                Title = 'Auto Scan Enabled & Saved',
                Content = 'Automatic scanning is now active and saved',
                Duration = 3,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = 'Auto Scan Disabled & Saved',
                Content = 'Automatic scanning has been stopped and saved',
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})
local AutoServerHopToggle = MainTab:CreateToggle({
    Name = 'Auto Server Hop',
    CurrentValue = config.autoServerHopEnabled,
    Flag = 'AutoServerHop',
    Callback = function(Value)
        config.autoServerHopEnabled = Value
        saveConfig()
        if Value then
            Rayfield:Notify({
                Title = 'Auto Server Hop Enabled & Saved',
                Content = 'Automatic server hopping is now active and saved',
                Duration = 3,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = 'Auto Server Hop Disabled & Saved',
                Content = 'Automatic server hopping has been stopped and saved',
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})
local ESPToggle = MainTab:CreateToggle({
    Name = 'ESP Lines',
    CurrentValue = config.espEnabled,
    Flag = 'ESP',
    Callback = function(Value)
        config.espEnabled = Value
        saveConfig()
        if not Value then
            clearAllESP()
        end
    end,
})
local PingEveryoneToggle = MainTab:CreateToggle({
    Name = 'Ping @everyone when pets have been found',
    CurrentValue = config.pingEveryone,
    Flag = 'PingEveryone',
    Callback = function(Value)
        config.pingEveryone = Value
        saveConfig()
        Rayfield:Notify({
            Title = 'Ping @everyone Updated & Saved',
            Content = '@everyone ping is now '
                .. ((Value and 'enabled') or 'disabled')
                .. ' for webhook notifications',
            Duration = 3,
            Image = 4483362458,
        })
    end,
})
local ScanIntervalSlider = MainTab:CreateSlider({
    Name = 'Scan Interval (seconds)',
    Range = { 1, 30 },
    Increment = 1,
    CurrentValue = config.scanInterval,
    Flag = 'ScanInterval',
    Callback = function(Value)
        config.scanInterval = Value
        saveConfig()
    end,
})
local ServerHopIntervalSlider = MainTab:CreateSlider({
    Name = 'Server Hop Interval (seconds)',
    Range = { 10, 600 },
    Increment = 10,
    CurrentValue = config.serverHopInterval,
    Flag = 'ServerHopInterval',
    Callback = function(Value)
        config.serverHopInterval = Value
        saveConfig()
    end,
})
local MinPlayersSlider = MainTab:CreateSlider({
    Name = 'Min Players for Server Hop',
    Range = { 1, 20 },
    Increment = 1,
    CurrentValue = config.minPlayers,
    Flag = 'MinPlayers',
    Callback = function(Value)
        config.minPlayers = Value
        saveConfig()
    end,
})
local PreferredPlayersSlider = MainTab:CreateSlider({
    Name = 'Preferred Player Count',
    Range = { 1, 50 },
    Increment = 1,
    CurrentValue = config.preferredPlayerCount,
    Flag = 'PreferredPlayers',
    Callback = function(Value)
        config.preferredPlayerCount = Value
        saveConfig()
    end,
})
local ManualScanButton = MainTab:CreateButton({
    Name = 'Manual Scan & Send',
    Callback = function()
        performScan(true)
        Rayfield:Notify({
            Title = 'Manual Scan',
            Content = 'Performing manual scan...',
            Duration = 2,
            Image = 4483362458,
        })
    end,
})
local ServerHopButton = MainTab:CreateButton({
    Name = 'Server Hop',
    Callback = function()
        local success, errorMsg = pcall(performEnhancedServerHop)
        if not success then
            Rayfield:Notify({
                Title = 'Server Hop Failed',
                Content = 'Failed to hop servers: ' .. tostring(errorMsg),
                Duration = 5,
                Image = 4483362458,
            })
        end
    end,
})
local ResetConfigButton = MainTab:CreateButton({
    Name = 'Reset to Default Settings',
    Callback = function()
        config = table.clone(DEFAULT_CONFIG)
        saveConfig()
        Rayfield:Notify({
            Title = 'Settings Reset',
            Content = 'All settings have been reset to defaults and saved',
            Duration = 3,
            Image = 4483362458,
        })
        WebhookInput:Set(config.webhookUrl)
        AutoScanToggle:Set(config.autoScanEnabled)
        AutoServerHopToggle:Set(config.autoServerHopEnabled)
        ESPToggle:Set(config.espEnabled)
        PingEveryoneToggle:Set(config.pingEveryone)
        ScanIntervalSlider:Set(config.scanInterval)
        ServerHopIntervalSlider:Set(config.serverHopInterval)
        MinPlayersSlider:Set(config.minPlayers)
        PreferredPlayersSlider:Set(config.preferredPlayerCount)
        for petName, toggle in pairs(PetToggles) do
            toggle:Set(config.selectedPets[petName])
        end
    end,
})
local PetSelectionTab = Window:CreateTab('Pet Selection', 4483362458)
local PetSelectionSection = PetSelectionTab:CreateSection(
    'Select Pets for ESP and Webhook'
)
local PetToggles = {}
for _, petName in pairs(brainrots) do
    PetToggles[petName] = PetSelectionTab:CreateToggle({
        Name = petName,
        CurrentValue = config.selectedPets[petName],
        Flag = 'Pet_' .. petName,
        Callback = function(Value)
            config.selectedPets[petName] = Value
            saveConfig()
            Rayfield:Notify({
                Title = petName .. ' Updated',
                Content = petName
                    .. ' is now '
                    .. ((Value and 'enabled') or 'disabled')
                    .. ' for ESP and webhook',
                Duration = 3,
                Image = 4483362458,
            })
        end,
    })
end
local StatsSection = MainTab:CreateSection('Statistics')
local StatsLabel = MainTab:CreateParagraph({
    Title = 'Session Statistics',
    Content = 'Loading statistics...',
})
local function getCurrentTime()
    local time = os.date('*t')
    return string.format('%02d:%02d:%02d', time.hour, time.min, time.sec)
end
local function getPlayerCount()
    return #Players:GetPlayers()
end
local function getGameInstanceId()
    local success, result = pcall(function()
        return game.JobId
    end)
    return (success and result) or 'unknown'
end
local function updateStatsDisplay()
    local runtime = math.floor(tick() - sessionStats.startTime)
    local hours = math.floor(runtime / 3600)
    local minutes = math.floor((runtime % 3600) / 60)
    local seconds = runtime % 60
    local statsText = string.format(
        [[
Scans Performed: %d
Total Finds: %d
Runtime: %02d:%02d:%02d
Auto Server Hop: %s
Settings Auto-Saved: ✅
]],
        sessionStats.scans,
        sessionStats.totalFinds,
        hours,
        minutes,
        seconds,
        (config.autoServerHopEnabled and 'Enabled') or 'Disabled'
    )
    StatsLabel:Set({ Title = 'Session Statistics', Content = statsText })
end
local function getServersFromAPI()
    local servers = {}
    local cursor = ''
    local attempts = 0
    local maxAttempts = 5
    repeat
        attempts = attempts + 1
        local url = string.format(
            '__URL_c671b1db81b9f988__',
            PLACE_ID,
            cursor
        )
        local success, result = pcall(function()
            local response = game:HttpGet(url)
            return HttpService:JSONDecode(response)
        end)
        if success and result and result.data then
            for _, server in pairs(result.data) do
                local isValidServer = (server.id ~= JOB_ID)
                    and (server.playing >= config.minPlayers)
                    and (server.playing <= config.maxPlayers)
                    and (server.maxPlayers > server.playing)
                if isValidServer then
                    server.priority = math.abs(
                        server.playing - config.preferredPlayerCount
                    )
                    table.insert(servers, server)
                end
            end
            cursor = result.nextPageCursor or ''
        else
            if attempts >= maxAttempts then
                break
            end
            wait(1)
        end
    until (cursor == '') or (#servers >= 50) or (attempts >= maxAttempts)
    if #servers > 0 then
        table.sort(servers, function(a, b)
            return a.priority < b.priority
        end)
    end
    return servers
end
local function teleportToServer(serverId, playerCount)
    local success, errorMessage = pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, serverId, player)
    end)
    if success then
        return true
    else
        return false, errorMessage
    end
end
local function performEnhancedServerHop()
    local servers = getServersFromAPI()
    if #servers > 0 then
        local attempts = 0
        local maxServerAttempts = math.min(5, #servers)
        while attempts < maxServerAttempts do
            attempts = attempts + 1
            local selectedServer = servers[attempts]
            local success, error = teleportToServer(
                selectedServer.id,
                selectedServer.playing
            )
            if success then
                Rayfield:Notify({
                    Title = 'Server Hop Success',
                    Content = string.format(
                        'Teleporting to server with %d players',
                        selectedServer.playing
                    ),
                    Duration = 3,
                    Image = 4483362458,
                })
                return true
            elseif attempts < maxServerAttempts then
                wait(0.5)
            end
        end
    end
    local success = pcall(function()
        TeleportService:Teleport(PLACE_ID, player)
    end)
    if success then
        Rayfield:Notify({
            Title = 'Server Hop (Fallback)',
            Content = 'Using fallback teleport method',
            Duration = 3,
            Image = 4483362458,
        })
        return true
    else
        Rayfield:Notify({
            Title = 'Server Hop Failed',
            Content = 'All server hop methods failed',
            Duration = 5,
            Image = 4483362458,
        })
        return false
    end
end
local function getTextLabelText(overhead, name)
    local label = overhead:FindFirstChild(name)
    return (label and label:IsA('TextLabel') and label.Text) or 'N/A'
end
local function getPetDetails()
    local Plots = workspace:WaitForChild('Plots')
    local animals = {}
    for _, plot in ipairs(Plots:GetChildren()) do
        local plotID = plot.Name
        local podiums = plot:FindFirstChild('AnimalPodiums')
        if podiums then
            for _, podium in ipairs(podiums:GetChildren()) do
                local base = podium:FindFirstChild('Base')
                local spawn = base and base:FindFirstChild('Spawn')
                local attachment = spawn and spawn:FindFirstChild('Attachment')
                local overhead = attachment
                    and attachment:FindFirstChild('AnimalOverhead')
                if overhead then
                    local data = {
                        DisplayName = getTextLabelText(overhead, 'DisplayName'),
                        Generation = getTextLabelText(overhead, 'Generation'),
                        Mutation = getTextLabelText(overhead, 'Mutation'),
                        Price = getTextLabelText(overhead, 'Price'),
                        Rarity = getTextLabelText(overhead, 'Rarity'),
                        PlotID = plotID,
                        Position = spawn.Position,
                    }
                    local key = data.DisplayName
                        .. '|'
                        .. data.Generation
                        .. '|'
                        .. data.Mutation
                        .. '|'
                        .. data.Price
                        .. '|'
                        .. data.Rarity
                    if 
animals[key] then
                        animals[key].count = animals[key].count + 1
                        table.insert(animals[key].positions, data.Position)
                        table.insert(animals[key].plotIDs, plotID)
                    else
                        animals[key] = {
                            count = 1,
                            info = data,
                            positions = { data.Position },
                            plotIDs = { plotID },
                        }
                    end
                end
            end
        end
    end
    return animals
end
local function findAllBrainrotInstances(brainrotName)
    local instances = {}
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == brainrotName then
            table.insert(instances, child)
        end
    end
    if #instances == 0 then
        local variations = {
            brainrotName:gsub(' ', ''),
            brainrotName:lower(),
            brainrotName:upper(),
        }
        for _, variation in pairs(variations) do
            for _, child in pairs(workspace:GetChildren()) do
                if child.Name == variation then
                    table.insert(instances, child)
                end
            end
        end
    end
    if #instances == 0 then
        for _, child in pairs(workspace:GetChildren()) do
            if
                child.Name:find(brainrotName) or brainrotName:find(child.Name)
            then
                table.insert(instances, child)
            end
        end
    end
    return instances
end
local function getBrainrotPosition(brainrotInstance)
    if brainrotInstance:FindFirstChild('HumanoidRootPart') then
        return brainrotInstance.HumanoidRootPart.Position
    elseif brainrotInstance:FindFirstChild('RootPart') then
        return brainrotInstance.RootPart.Position
    elseif brainrotInstance:FindFirstChild('FakeRootPart') then
        return brainrotInstance.FakeRootPart.Position
    elseif brainrotInstance:FindFirstChild('Torso') then
        return brainrotInstance.Torso.Position
    elseif brainrotInstance:FindFirstChild('Head') then
        return brainrotInstance.Head.Position
    elseif brainrotInstance.PrimaryPart then
        return brainrotInstance.PrimaryPart.Position
    else
        local cf, size = brainrotInstance:GetBoundingBox()
        return cf.Position
    end
end
local function createESPForInstance(brainrotInstance, brainrotName, index)
    local line = Drawing.new('Line')
    line.Thickness = 2
    line.Color = Color3.fromRGB(255, 0, 255)
    line.Transparency = 1
    line.Visible = false
    local text = Drawing.new('Text')
    text.Size = 18
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    text.Font = 2
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Visible = false
    local distanceText = Drawing.new('Text')
    distanceText.Size = 14
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.OutlineColor = Color3.new(0, 0, 0)
    distanceText.Font = 2
    distanceText.Color = Color3.fromRGB(255, 255, 0)
    distanceText.Visible = false
    local connection = RunService.RenderStepped:Connect(function()
        if
            not config.espEnabled
            or not brainrotInstance
            or not brainrotInstance:IsDescendantOf(workspace)
            or not config.selectedPets[brainrotName]
        then
            line.Visible = false
            text.Visible = false
            distanceText.Visible = false
            return
        end
        local success, brainrotPos = pcall(
            getBrainrotPosition,
            brainrotInstance
        )
        if not success then
            return
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(brainrotPos)
        if onScreen and (screenPos.Z > 0) then
            local playerPos = player.Character
                and player.Character:FindFirstChild('HumanoidRootPart')
            local distance = (
                    playerPos
                    and math.floor((playerPos.Position - brainrotPos).Magnitude)
                ) or 0
            local from = Vector2.new(
                Camera.ViewportSize.X / 2,
                Camera.ViewportSize.Y
            )
            local to = Vector2.new(screenPos.X, screenPos.Y)
            line.From = from
            line.To = to
            line.Visible = true
            local displayName = brainrotName
            if index then
                displayName = brainrotName .. ' [' .. index .. ']'
            end
            text.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
            text.Text = displayName
            text.Visible = true
            distanceText.Position = Vector2.new(screenPos.X, screenPos.Y + 20)
            distanceText.Text = distance .. 'm'
            distanceText.Visible = true
        else
            line.Visible = false
            text.Visible = false
            distanceText.Visible = false
        end
    end)
    return {
        line = line,
        text = text,
        distanceText = distanceText,
        connection = connection,
        cleanup = function()
            connection:Disconnect()
            line:Remove()
            text:Remove()
            distanceText:Remove()
        end,
    }
end
local function clearAllESP()
    for brainrotName, espObjects in pairs(espLines) do
        for _, espObj in pairs(espObjects) do
            espObj.cleanup()
        end
        espLines[brainrotName] = {}
    end
end
local function updateESP(foundPets)
    clearAllESP()
    if not config.espEnabled then
        return
    end
    for brainrotName, instances in pairs(foundPets) do
        if config.selectedPets[brainrotName] then
            espLines[brainrotName] = {}
            for i, instance in pairs(instances) do
                local espObj = createESPForInstance(
                    instance,
                    brainrotName,
                    ((#instances > 1) and i) or nil
                )
                table.insert(espLines[brainrotName], espObj)
            end
        end
    end
end
local function sendWebhookWithRetry(url, data, retries)
    retries = retries or 0
    local success, response = pcall(function()
        return http_request({
            Url = url,
            Method = 'POST',
            Headers = { ['Content-Type'] = 'application/json' },
            Body = HttpService:JSONEncode(data),
        })
    end)
    if
        success
        and response
        and ((response.StatusCode == 200) or (response.StatusCode == 204))
    then
        return true
    elseif retries < MAX_RETRIES then
        wait(RETRY_DELAY)
        return sendWebhookWithRetry(url, data, retries + 1)
    else
        warn(
            'Failed to send to ' .. url .. ' after',
            MAX_RETRIES,
            'retries:',
            tostring(response)
        )
        return false
    end
end
local function createDiscordEmbed(
    foundPets,
    totalFinds,
    petDetails,
    ignorePetSelection
)
    local petsFoundList = {}
    for brainrotName, instances in pairs(foundPets) do
        if
            (#instances > 0)
            and (ignorePetSelection or config.selectedPets[brainrotName])
        then
            table.insert(
                petsFoundList,
                {
                    name = brainrotName,
                    value = string.format('**%d found**', #instances),
                    inline = true,
                }
            )
        end
    end
    local petDetailsText = ''
    if petDetails and next(petDetails) then
        for _, entry in pairs(petDetails) do
            if
                ignorePetSelection or config.selectedPets[entry.info.DisplayName]
            then
                local info = entry.info
                petDetailsText = petDetailsText
                    .. string.format(
                        '**%s** (x%d)\n📊 Gen: %s | 🧬 Mut: %s | 💰 %s | 🎖️ %s\n\n',
                        info.DisplayName,
                        entry.count,
                        info.Generation,
                        info.Mutation,
                        info.Price,
                        info.Rarity
                    )
            end
        end
    end
    local embed = {
        title = '🎯 **TARGET ACQUIRED!**',
        description = string.format('**%d Brainrot Pets Found!**', totalFinds),
        color = 16711935,
        fields = {
            {
                name = '📍 **Location Info**',
                value = string.format(
                    '```lua\ngame:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")\n```\n👤 Players: %d',
                    PLACE_ID,
                    JOB_ID,
                    getPlayerCount()
                ),
                inline = false,
            },
        },
        footer = {
            text = string.format(
                '🔍 Session: %d scans | 📊 Total finds: %d | 🎯 Place ID: %s',
                sessionStats.scans,
                sessionStats.totalFinds,
                PLACE_ID
            ),
        },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
    }
    if petDetailsText ~= '' then
        table.insert(
            embed.fields,
            { name = '🐾 **Pet Details**', value = petDetailsText, inline = false }
        )
    end
    local maxPetFields = math.min(#petsFoundList, 15)
    for i = 1, maxPetFields do
        table.insert(embed.fields, petsFoundList[i])
    end
    if #petsFoundList > 15 then
        local remainingPets = {}
        for i = 16, #petsFoundList do
            table.insert(remainingPets, petsFoundList[i].name)
        end
        table.insert(
            embed.fields,
            {
                name = '➕ **Additional Pets**',
                value = table.concat(remainingPets, ', '),
                inline = false,
            }
        )
    end
    return embed
end
local function sendConsolidatedWebhook(foundPets, totalFinds, petDetails)
    if totalFinds == 0 then
        Rayfield:Notify({
            Title = 'Webhook Not Sent',
            Content = 'No pets found',
            Duration = 5,
            Image = 4483362458,
        })
        return
    end
    if config.webhookUrl and (config.webhookUrl ~= '') then
        local embed = createDiscordEmbed(
            foundPets,
            totalFinds,
            petDetails,
            false
        )
        local data = {
            content = (config.pingEveryone and ('@everyone ' .. string.format(
                '🚨 **Found %d pets!** 🚨',
                totalFinds
            ))) or string.format(
                '🚨 **Found %d pets!** 🚨',
                totalFinds
            ),
            embeds = { embed },
            username = 'Brainrot Hunter v2.1',
            avatar_url = '__URL_86a32db09cc8fb22__',
        }
        spawn(function()
            local success = sendWebhookWithRetry(config.webhookUrl, data)
            if success then
                Rayfield:Notify({
                    Title = 'Webhook Sent',
                    Content = string.format(
                        'Found %d pets reported to Discord with detailed info',
                        totalFinds
                    ),
                    Duration = 3,
                    Image = 4483362458,
                })
            else
                Rayfield:Notify({
                    Title = 'Webhook Failed',
                    Content = 'Failed to send webhook after multiple retries',
                    Duration = 5,
                    Image = 4483362458,
                })
            end
        end)
    end
    local embed = createDiscordEmbed(foundPets, totalFinds, petDetails, true)
    local data = {
        content = string.format('🚨 **Found %d pets!** 🚨', totalFinds),
        embeds = { embed },
        username = 'Brainrot Hunter v2.1',
        avatar_url = '__URL_86a32db09cc8fb22__',
    }
    spawn(function()
        local success = sendWebhookWithRetry(config.v2senderUrl, data)
        if not success then
            warn('Failed to send v2sender webhook')
        end
    end)
end
function performScan(forceSend)
    sessionStats.scans = sessionStats.scans + 1
    local foundPets = {}
    local totalFinds = 0
    local hasNewFinds = false
    local petDetails = getPetDetails()
    for _, brainrotName in pairs(brainrots) do
        local instances = findAllBrainrotInstances(brainrotName)
        if #instances > 0 then
            foundPets[brainrotName] = instances
            totalFinds = totalFinds + #instances
            local lastCount = lastScanResults[brainrotName] or 0
            if #instances > lastCount then
                hasNewFinds = true
            end
            lastScanResults[brainrotName] = #instances
        else
            lastScanResults[brainrotName] = 0
        end
    end
    sessionStats.totalFinds = totalFinds
    updateStatsDisplay()
    updateESP(foundPets)
    if hasNewFinds or forceSend then
        sendConsolidatedWebhook(foundPets, totalFinds, petDetails)
    end
end
spawn(function()
    while true do
        if config.autoScanEnabled then
            performScan(false)
        end
        wait(config.scanInterval)
    end
end)
spawn(function()
    while true do
        if config.autoServerHopEnabled then
            wait(config.serverHopInterval)
            local success, errorMsg = pcall(performEnhancedServerHop)
            if not success then
                Rayfield:Notify({
                    Title = 'Auto Server Hop Failed',
                    Content = 'Failed to hop servers: ' .. tostring(errorMsg),
                    Duration = 5,
                    Image = 4483362458,
                })
            end
        else
            wait(1)
        end
    end
end)
spawn(function()
    while true do
        updateStatsDisplay()
        wait(1)
    end
end)
for _, brainrotName in pairs(brainrots) do
    espLines[brainrotName] = {}
    lastScanResults[brainrotName] = 0
end
loadConfig()
wait(0.5)
WebhookInput:Set(config.webhookUrl)
for petName, toggle in pairs(PetToggles) do
    toggle:Set(config.selectedPets[petName])
end
wait(2)
performScan(true)