-- Spanish Translation
-- Script ID: b1b22908c6e1ac8a72b8543df0f6b910
-- Migrated: 2025-09-11T14:25:31.806Z
-- Auto-migrated from encrypted storage to GitHub

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'))()
local NotificationModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NamelessAdminNotifications.lua"))()

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

local Window = Rayfield:CreateWindow({
    Name = "Bóveda de ComboCrónica",
    LoadingTitle = "Cargando la bóveda de ComboChronicle",
    LoadingSubtitle = "By COMBO_WICK | Bang.E.Line",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Config",
        FileName = "SIM"
    },
    Discord = {
        Enabled = true,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Inicio", 6022668898)
local ServersTab = Window:CreateTab("Servidores", 6031229361)
local UtilsTab = Window:CreateTab("Utilidades", 6034590631)
local SettingsTab = Window:CreateTab("Configuración", 6035065170)

local serverData = {}
local filteredServers = {}
local currentFilter = "All"
local maxServersToShow = 50
local serverButtons = {}
local isLoading = false

local function ShowNotification(title, content, duration)
    NotificationModule.Notify({
        Title = title,
        Description = content,
        Duration = duration or 5,
    })
end

-- Utility functions
local function fetchServers()
    if isLoading then return false end
    isLoading = true
    
    local success, response = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    
    isLoading = false
    
    if success then
        local data = HttpService:JSONDecode(response)
        serverData = data.data or {}
        applyFilters()
        return true
    end
    return false
end

local function applyFilters()
    filteredServers = {}
    
    for _, server in ipairs(serverData) do
        local shouldInclude = false
        local playerRatio = server.playing / server.maxPlayers
        
        if currentFilter == "All" then
            shouldInclude = true
        elseif currentFilter == "Low" then
            shouldInclude = server.playing <= math.floor(server.maxPlayers * 0.3)
        elseif currentFilter == "High" then
            shouldInclude = server.playing >= math.floor(server.maxPlayers * 0.8)
        elseif currentFilter == "VIP" then
            shouldInclude = server.playing == 1
        end
        
        if shouldInclude then
            table.insert(filteredServers, server)
        end
    end
    
    table.sort(filteredServers, function(a, b) return a.playing < b.playing end)
end

local function getServerStats()
    if #serverData == 0 then return "No data available" end
    
    local totalPlayers = 0
    local totalServers = #serverData
    local fullServers = 0
    local emptyServers = 0
    local lowestPop = math.huge
    local highestPop = 0
    local avgPop = 0
    
    for _, server in ipairs(serverData) do
        totalPlayers = totalPlayers + server.playing
        if server.playing == 0 then
            emptyServers = emptyServers + 1
        elseif server.playing == server.maxPlayers then
            fullServers = fullServers + 1
        end
        if server.playing < lowestPop then
            lowestPop = server.playing
        end
        if server.playing > highestPop then
            highestPop = server.playing
        end
    end
    
    avgPop = math.floor(totalPlayers / totalServers)
    
    return string.format("Total: %d servers | Players: %d | Avg: %d | Empty: %d | Full: %d | Min: %d | Max: %d", 
        totalServers, totalPlayers, avgPop, emptyServers, fullServers, lowestPop == math.huge and 0 or lowestPop, highestPop)
end

local function destroyServerButtons()
    for i, button in ipairs(serverButtons) do
        if button and button.Destroy then
            pcall(function() button:Destroy() end)
        end
    end
    serverButtons = {}
end

local function createServerButtons()
    destroyServerButtons()
    
    if #filteredServers == 0 then
        ShowNotification("No Servers Found", "No servers match your current filters", 3)
        return
    end
    
    for i, server in ipairs(filteredServers) do
        local isCurrentServer = server.id == JobId
        local playerRatio = server.playing / server.maxPlayers
        local statusText = ""
        
        if isCurrentServer then
            statusText = "CURRENT"
        elseif server.playing == 0 then
            statusText = "EMPTY"
        elseif server.playing == server.maxPlayers then
            statusText = "FULL"
        elseif playerRatio < 0.3 then
            statusText = "LOW"
        else
            statusText = "HIGH"
        end
        
        local buttonText = string.format("[%s] %d/%d | ID: %s", 
            statusText, server.playing, server.maxPlayers, server.id:sub(1, 8) .. "...")
        
        local button = ServersTab:CreateButton({
            Name = buttonText,
            Callback = function()
                if isCurrentServer then
                    ShowNotification("Already Here", "You're already in this server!", 3)
                else
                    ShowNotification("Teleporting", "Joining server...", 2)
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                end
            end
        })
        
        table.insert(serverButtons, button)
    end
    
    ShowNotification("Servers Loaded", string.format("Showing %d servers", #filteredServers), 3)
end

-- Main Tab
local StatsLabel = MainTab:CreateLabel("Loading server data...")

local RefreshButton = MainTab:CreateButton({
    Name = "Actualizar lista de servidores",
    Callback = function()
        if isLoading then
            ShowNotification("Please Wait", "Already refreshing...", 2)
            return
        end
        
        StatsLabel:Set("Refreshing server data...")
        
        if fetchServers() then
            StatsLabel:Set(getServerStats())
            createServerButtons()
            ShowNotification("Success", "Server list refreshed successfully!", 3)
        else
            StatsLabel:Set("Failed to fetch server data")
            ShowNotification("Error", "Failed to refresh server list. Check your connection.", 5)
        end
    end
})

local CurrentServerSection = MainTab:CreateSection("Servidor actual")

local CurrentServerLabel = MainTab:CreateLabel("Job ID: " .. JobId:sub(1, 16) .. "...")

local CopyJobButton = MainTab:CreateButton({
    Name = "Copiar el ID de trabajo actual",
    Callback = function()
        if setclipboard then
            setclipboard(JobId)
            ShowNotification("Copied", "Job ID copied to clipboard", 3)
        else
            ShowNotification("Error", "Clipboard not supported on this executor", 3)
        end
    end
})

local RejoinButton = MainTab:CreateButton({
    Name = "Únete al servidor actual",
    Callback = function()
        ShowNotification("Rejoining", "Rejoining current server...", 2)
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
    end
})

-- Servers Tab
local FilterSection = ServersTab:CreateSection("Filtros")

local FilterDropdown = ServersTab:CreateDropdown({
    Name = "Servidores de filtros",
    Options = {"All", "Low", "High", "VIP"},
    CurrentOption = {"All"},
    MultipleOptions = false,
    Flag = "FilterDropdown",
    Callback = function(Option)
        currentFilter = Option[1] or "All"
        applyFilters()
        createServerButtons()
        ShowNotification("Filter Applied", "Filter set to: " .. currentFilter, 2)
    end
})

local ServerCountSlider = ServersTab:CreateSlider({
    Name = "Servidores Max a mostrar",
    Range = {5, 100},
    Increment = 5,
    Suffix = " servers",
    CurrentValue = 50,
    Flag = "ServerCountSlider",
    Callback = function(Value)
        maxServersToShow = Value
        createServerButtons()
        ShowNotification("Limit Updated", "Will show up to " .. Value .. " servers", 2)
    end
})

local ServerListSection = ServersTab:CreateSection("Lista de servidores")

local ManualRefreshButton = ServersTab:CreateButton({
    Name = "Actualizar lista de servidores",
    Callback = function()
        if isLoading then
            ShowNotification("Please Wait", "Already refreshing...", 2)
            return
        end
        
        if fetchServers() then
            createServerButtons()
            ShowNotification("Success", "Server list refreshed successfully!", 3)
        else
            ShowNotification("Error", "Failed to refresh server list. Check your connection.", 5)
        end
    end
})

local ShowServersButton = ServersTab:CreateButton({
    Name = "Cargar lista de servidores",
    Callback = function()
        if #serverData == 0 then
            ShowNotification("No Data", "Please refresh server list first", 3)
        else
            applyFilters()
            createServerButtons()
        end
    end
})

local ClearListButton = ServersTab:CreateButton({
    Name = "Limpiar lista de servidores",
    Callback = function()
        destroyServerButtons()
        ShowNotification("Cleared", "Server list cleared", 2)
    end
})

-- Utils Tab
local UtilsSection = UtilsTab:CreateSection("Servidor externo")

local PlaceInput = UtilsTab:CreateInput({
    Name = "ID del lugar",
    PlaceholderText = "Enter Place ID (numbers only)",
    RemoveTextAfterFocusLost = false,
    Flag = "PlaceInput",
    Callback = function(Text)
        _G.CustomPlaceId = Text
    end
})

local JobInput = UtilsTab:CreateInput({
    Name = "ID de trabajo",
    PlaceholderText = "Enter Job ID",
    RemoveTextAfterFocusLost = false,
    Flag = "JobInput",
    Callback = function(Text)
        _G.CustomJobId = Text
    end
})

local JoinExternalButton = UtilsTab:CreateButton({
    Name = "Unirse al servidor externo",
    Callback = function()
        if _G.CustomPlaceId and _G.CustomJobId and _G.CustomPlaceId ~= "" and _G.CustomJobId ~= "" then
            local placeId = tonumber(_G.CustomPlaceId)
            if placeId then
                ShowNotification("Teleporting", "Joining external server...", 3)
                TeleportService:TeleportToPlaceInstance(placeId, _G.CustomJobId, LocalPlayer)
            else
                ShowNotification("Invalid Input", "Place ID must be a valid number", 3)
            end
        else
            ShowNotification("Missing Input", "Please enter both Place ID and Job ID", 3)
        end
    end
})

local QuickJoinSection = UtilsTab:CreateSection("Únete rápido")

local JoinLowestButton = UtilsTab:CreateButton({
    Name = "Únete al servidor de población más baja",
    Callback = function()
        if #serverData == 0 then
            ShowNotification("No Data", "Please refresh server list first", 3)
            return
        end
        
        local lowestServer = nil
        local lowestPop = math.huge
        
        for _, server in ipairs(serverData) do
            if server.playing < lowestPop and server.playing < server.maxPlayers and server.id ~= JobId then
                lowestPop = server.playing
                lowestServer = server
            end
        end
        
        if lowestServer then
            ShowNotification("Joining Lowest", string.format("Joining server with %d players", lowestPop), 3)
            TeleportService:TeleportToPlaceInstance(PlaceId, lowestServer.id, LocalPlayer)
        else
            ShowNotification("No Servers", "No available servers found", 3)
        end
    end
})

local JoinRandomButton = UtilsTab:CreateButton({
    Name = "Unirse al servidor aleatorio",
    Callback = function()
        if #serverData == 0 then
            ShowNotification("No Data", "Please refresh server list first", 3)
            return
        end
        
        local availableServers = {}
        for _, server in ipairs(serverData) do
            if server.playing < server.maxPlayers and server.id ~= JobId then
                table.insert(availableServers, server)
            end
        end
        
        if #availableServers > 0 then
            local randomServer = availableServers[math.random(1, #availableServers)]
            ShowNotification("Random Join", string.format("Joining random server (%d/%d)", randomServer.playing, randomServer.maxPlayers), 3)
            TeleportService:TeleportToPlaceInstance(PlaceId, randomServer.id, LocalPlayer)
        else
            ShowNotification("No Servers", "No available servers found", 3)
        end
    end
})

local JoinBestButton = UtilsTab:CreateButton({
    Name = "Unirse al mejor servidor",
    Callback = function()
        if #serverData == 0 then
            ShowNotification("No Data", "Please refresh server list first", 3)
            return
        end
        
        local bestServer = nil
        local bestScore = -1
        
        for _, server in ipairs(serverData) do
            if server.playing < server.maxPlayers and server.id ~= JobId then
                local ratio = server.playing / server.maxPlayers
                local score = 0
                
                if ratio >= 0.3 and ratio <= 0.7 then
                    score = ratio * 100
                elseif ratio < 0.3 then
                    score = ratio * 50
                else
                    score = (1 - ratio) * 30
                end
                
                if score > bestScore then
                    bestScore = score
                    bestServer = server
                end
            end
        end
        
        if bestServer then
            ShowNotification("Joining Best", string.format("Joining optimal server (%d/%d)", bestServer.playing, bestServer.maxPlayers), 3)
            TeleportService:TeleportToPlaceInstance(PlaceId, bestServer.id, LocalPlayer)
        else
            ShowNotification("No Servers", "No available servers found", 3)
        end
    end
})

-- Settings Tab
local AutoRefreshSection = SettingsTab:CreateSection("Actualizar automáticamente")

local AutoRefreshToggle = SettingsTab:CreateToggle({
    Name = "Refrescar automáticamente (30s)",
    CurrentValue = true,
    Flag = "AutoRefresh",
    Callback = function(Value)
        _G.AutoRefresh = Value
        if Value then
            ShowNotification("Auto Refresh ON", "Server list will refresh every 30 seconds", 3)
            spawn(function()
                while _G.AutoRefresh do
                    wait(30)
                    if _G.AutoRefresh and not isLoading then
                        if fetchServers() then
                            StatsLabel:Set(getServerStats())
                            createServerButtons()
                        end
                    end
                end
            end)
        else
            ShowNotification("Auto Refresh OFF", "Auto refresh disabled", 2)
        end
    end
})

local NotificationSection = SettingsTab:CreateSection("Notificaciones")

local NotifyOnJoinToggle = SettingsTab:CreateToggle({
    Name = "Notificar en la unión del servidor",
    CurrentValue = true,
    Flag = "NotifyOnJoin",
    Callback = function(Value)
        _G.NotifyOnJoin = Value
    end
})

local AdvancedSection = SettingsTab:CreateSection("Avanzado")

local ServerCacheButton = SettingsTab:CreateButton({
    Name = "Limpiar caché de servidor",
    Callback = function()
        serverData = {}
        filteredServers = {}
        destroyServerButtons()
        StatsLabel:Set("Cache cleared - refresh to reload")
        ShowNotification("Cache Cleared", "All server data has been cleared", 3)
    end
})

local AboutSection = SettingsTab:CreateSection("Acerca de")
local AboutLabel = SettingsTab:CreateLabel("ComboChronicle Vault v2.0 - Enhanced Edition")

-- Initial load
spawn(function()
    wait(1)
    
    ShowNotification("ComboChronicle Vault", "Loading server data...", 3)
    
    if fetchServers() then
        StatsLabel:Set(getServerStats())
        createServerButtons()
        ShowNotification("Ready", "Server browser loaded successfully!", 3)
    else
        StatsLabel:Set("Failed to fetch server data - Check connection")
        ShowNotification("Warning", "Failed to load initial data - Try refreshing", 5)
    end
end)