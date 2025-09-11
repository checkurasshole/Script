-- Original English Script
-- Script ID: 1e0ccd7d411d8bf44a8ffaa8d4b2a1b2
-- Migrated: 2025-09-11T12:58:35.138Z
-- Auto-migrated from encrypted storage to GitHub

-- Load Fluent Library
local Fluent = loadstring(game:HttpGet("__URL_acea61736271ba5e__"))()
local SaveManager = loadstring(game:HttpGet("__URL_7a882722451e5f8e__"))()
local InterfaceManager = loadstring(game:HttpGet("__URL_a900b49de4b5c785__"))()

getgenv().VaultReady = false

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService('HttpService')

local function constructUrl(parts)
    return table.concat(parts, '')
end

local function getSecureEndpoint()
    local protocol = string.char(
        104,
        116,
        116,
        112,
        115,
        58,
        47,
        47
    )

    local webhookParts = {}

    webhookParts[1] = protocol

    local trash1 = 5 * math.random(1, 9)
    local dummy1 = tostring(trash1) .. '_lol'

    webhookParts[2] = 'v0-secure-'

    for i = 1, 3 do
        local temp = i * 3
    end
    local extra = 'ignore_me'

    webhookParts[3] = 'discord'

    local shadow = 'who_dis' .. tostring(math.random(100, 999))
    local bogus = math.pi * 2.718

    webhookParts[4] = '-proxy'

    local void = {}
    for i = 1, 2 do
        table.insert(void, i * 9)
    end
    local skipThis = table.concat(void, '-')

    webhookParts[5] = '.vercel'

    local notUsed = math.cos(os.clock()) * 99
    local filler = 'not_shown_' .. tostring(notUsed)

    webhookParts[6] = '.app'

    local joke = (1234 % 100) + 33
    local decoy = tostring(joke)

    webhookParts[7] = '/api/'

    local rando = tostring(math.random(1, 99999))
    local deepfake = 'key_' .. rando

    webhookParts[8] = 'webhook'

    return table.concat(webhookParts)
end

local function getVersionUrl()
    local urlParts = {}
    urlParts[1] = string.char(
        104,
        116,
        116,
        112,
        115,
        58,
        47,
        47
    )
    local noise = math.random(10, 99) * 3.14
    local dummy = 'ignore_' .. tostring(noise)
    urlParts[2] = 'pastebin'
    for i = 1, 4 do
        local temp = i * i * 2
    end
    local garbage = 'skip_this'
    urlParts[3] = '.com/raw/'
    local decoy = {}
    for i = 1, 3 do
        table.insert(decoy, i * 7)
    end
    local unused = table.concat(decoy, '+')
    urlParts[4] = 'ptHNczy5'
    local junkMath = math.sin(os.time() % 10) * 55
    local extra = 'not_important_' .. tostring(junkMath)

    return table.concat(urlParts)
end

local function getBlacklistUrl()
    local segments = {}
    segments[1] = string.char(
        104,
        116,
        116,
        112,
        115,
        58,
        47,
        47
    )
    local mockData = tostring(math.random(1000, 9999))
    local fakeRef = 'ref_' .. mockData
    segments[2] = 'pastebin'
    for m = 1, 5 do
        local throwaway = m * m + 7
    end
    local dummyToken = 'token_' .. tostring(os.time() % 100)
    segments[3] = '.com/raw/'
    local noise = {}
    for i = 1, 4 do
        table.insert(noise, i * 11)
    end
    local jumble = table.concat(noise, '-')
    segments[4] = '3h23tX2Y'
    local lastCalc = math.abs(math.sin(os.clock())) * 200
    local dummyEnd = 'verify_' .. tostring(lastCalc)

    return table.concat(segments)
end

local function getWhitelistUrl()
    local fragments = {}
    fragments[1] = string.char(
        104,
        116,
        116,
        112,
        115,
        58,
        47,
        47
    )
    local randomBits = math.random(1, 64) * 4
    local skipMe = 'skip_' .. tostring(randomBits)
    fragments[2] = 'pastebin'
    for n = 3, 6 do
        local useless = n * 3.33
    end
    local dummyVar = 'debug_' .. tostring(math.floor(math.random() * 1000))
    fragments[3] = '.com/raw/'
    local fakeData = {}
    for i = 1, 3 do
        table.insert(fakeData, i * 33)
    end
    local junkStr = table.concat(fakeData, '_')
    fragments[4] = 'Qmp4r6es'
    local endJunk = math.ceil(os.clock() * 50)
    local dummyEnd = 'end_' .. tostring(endJunk)

    return table.concat(fragments)
end

local function getLicenseUrl()
    local urlBits = {}
    urlBits[1] = string.char(104, 116, 116, 112, 115, 58, 47, 47)
    local mockTime = os.time() % 86400
    local fakeClock = 'time_' .. tostring(mockTime)
    urlBits[2] = 'raw.githubusercontent'
    for q = 2, 5 do
        local throwaway = q * 17 - 5
    end
    local unusedVar = 'unused_' .. tostring(math.random(100, 999))
    urlBits[3] = '.com/12345678kanhai/'
    local junkVal = {}
    for i = 1, 5 do
        table.insert(junkVal, i * 12)
    end
    local garbage = table.concat(junkVal, ':')
    urlBits[4] = 'Script/refs/heads/main/'
    local lastVal = math.floor(math.random() * 444)
    local dummyEnd = 'check_' .. tostring(lastVal)
    urlBits[5] = 'LICENSE'
    local finalJunk = math.ceil(os.clock() * 1000) % 555
    local lastDummy = 'end_' .. tostring(finalJunk)

    return table.concat(urlBits)
end

local function getKeyApiUrl()
    local apiParts = {}
    apiParts[1] = string.char(104, 116, 116, 112, 115, 58, 47, 47)
    local mockVar = math.random(500, 999) * 1.414
    local dummyRef = 'ref_' .. tostring(mockVar)
    apiParts[2] = 'v0-roblox-executor-'
    for k = 1, 4 do
        local throwaway = k * k * 3
    end
    local unusedData = 'data_' .. tostring(os.time() % 777)
    apiParts[3] = 'system'
    local noise = {}
    for i = 1, 3 do
        table.insert(noise, i * 13)
    end
    local junkString = table.concat(noise, '_')
    apiParts[4] = '.vercel'
    local fakeCalc = math.sin(os.clock() % 10) * 100
    local dummyVal = 'calc_' .. tostring(fakeCalc)
    apiParts[5] = '.app'
    local endNoise = math.ceil(math.random() * 666)
    local finalDummy = 'end_' .. tostring(endNoise)

    return table.concat(apiParts)
end

local function getScriptApiUrl()
    local scriptParts = {}
    scriptParts[1] = string.char(104, 116, 116, 112, 115, 58, 47, 47)
    local randJunk = math.random(100, 777) * 1.618
    local dummyScript = 'script_' .. tostring(randJunk)
    scriptParts[2] = 'combo0-chroncile'
    for j = 1, 4 do
        local throwaway = j * 19 + 3
    end
    local extraData = 'combo_' .. tostring(os.time() % 888)
    scriptParts[3] = '.vercel'
    local mockCalc = math.cos(os.clock()) * 150
    local dummyVercel = 'vercel_' .. tostring(mockCalc)
    scriptParts[4] = '.app/api/roblox'
    local finalNoise = math.floor(math.random() * 999)
    local lastDummy = 'api_' .. tostring(finalNoise)

    return table.concat(scriptParts)
end

local function getDefaultScriptUrl()
    local defaultParts = {}
    defaultParts[1] = string.char(104, 116, 116, 112, 115, 58, 47, 47)
    local noiseVar = math.random(50, 555) * 2.718
    local dummyDefault = 'default_' .. tostring(noiseVar)
    defaultParts[2] = 'raw.githubusercontent'
    for p = 1, 3 do
        local throwaway = p * p * 5
    end
    local extraJunk = 'github_' .. tostring(os.time() % 444)
    defaultParts[3] = '.com/checkurasshole/'
    local mockData = {}
    for i = 1, 4 do
        table.insert(mockData, i * 7)
    end
    local junkArray = table.concat(mockData, '-')
    defaultParts[4] = 'Script/refs/heads/main/'
    local calcJunk = math.abs(math.sin(os.clock())) * 300
    local dummyScript = 'main_' .. tostring(calcJunk)
    defaultParts[5] = 'Default'
    local endJunk = math.ceil(os.clock() * 123)
    local finalDummy = 'default_' .. tostring(endJunk)

    return table.concat(defaultParts)
end

local CONFIG = {
    VERSION_URL = getVersionUrl(),
    SECURE_ENDPOINT = getSecureEndpoint(),
    BLACKLIST_URLS = {
        getBlacklistUrl(),
    },
    WHITELIST_URL = getWhitelistUrl(),
    GITHUB_LICENSE_URL = getLicenseUrl(),
    HTTP_TIMEOUT = 15,
    FEEDBACK_COOLDOWN = 4500,
    VERSION = '1.3.3',
    MIN_VERSION = '1.3.3',
    VERSION_TOKEN_FALLBACK = 'VAULT_1_3_3_AUTH',
}

print('Vault script is loading... Please be patient, this may take a moment.')
local startTime = tick()

local VaultDataStore
local function initializeDataStore()
    local success, ds = pcall(function()
        return DataStoreService:GetDataStore('VaultData_v1_3_3')
    end)
    if success then
        VaultDataStore = ds
    end
end
initializeDataStore()

local function getDataStore(key, default)
    if not VaultDataStore then
        return default
    end
    local success, data = pcall(function()
        return VaultDataStore:GetAsync(
            tostring(LocalPlayer.UserId) .. '_' .. key
        )
    end)
    return success and data or default
end

local function setDataStore(key, value)
    if VaultDataStore then
        pcall(function()
            VaultDataStore:SetAsync(
                tostring(LocalPlayer.UserId) .. '_' .. key,
                value
            )
        end)
    end
end

local function getLocalStorage(key, default)
    local success, data = pcall(function()
        return LocalPlayer:GetAttribute(key)
    end)
    return (success and data) or default
end

local function setLocalStorage(key, value)
    pcall(function()
        LocalPlayer:SetAttribute(key, value)
    end)
end

local HTTP_RATE_LIMIT = 0.5
local lastHttpRequest = 0
local function safeHttpGet(url, retries)
    retries = retries or 3
    local data, success, errorMsg

    for i = 1, retries do
        while (tick() - lastHttpRequest) < HTTP_RATE_LIMIT do
            task.wait(0.1)
        end
        lastHttpRequest = tick()

        local requestComplete = false
        local requestThread = coroutine.create(function()
            success, data = pcall(function()
                return game:HttpGet(url)
            end)
            if not success then
                errorMsg = data
                data = nil
            end
            requestComplete = true
        end)

        coroutine.resume(requestThread)

        local startTime = tick()
        while
            not requestComplete
            and (tick() - startTime) < CONFIG.HTTP_TIMEOUT
        do
            task.wait(0.1)
        end

        if requestComplete and success then
            return true, data
        end

        if i < retries then
            task.wait(2)
        end
    end

    return false, errorMsg or 'Request timed out or blocked'
end

local function compareVersions(v1, v2)
    local v1Parts = { v1:match('(%d+)%.(%d+)%.(%d+)') }
    local v2Parts = { v2:match('(%d+)%.(%d+)%.(%d+)') }
    for i = 1, 3 do
        local n1, n2 = tonumber(v1Parts[i]) or 0, tonumber(v2Parts[i]) or 0
        if n1 < n2 then
            return -1
        end
        if n1 > n2 then
            return 1
        end
    end
    return 0
end

local function checkVersionAndToken()
    local success, response = safeHttpGet(CONFIG.VERSION_URL)
    if success then
        local version, token = response:match('([^|]+)|(.+)')
        if not version or not token then
            return false,
                'Invalid version format in Pastebin',
                CONFIG.VERSION_TOKEN_FALLBACK
        end
        if compareVersions(CONFIG.VERSION, version) < 0 then
            return false,
                'Script outdated. Please update to v' .. version,
                token
        elseif compareVersions(CONFIG.VERSION, CONFIG.MIN_VERSION) < 0 then
            return false,
                'Version below minimum required (' .. CONFIG.MIN_VERSION .. ')',
                token
        end
        return true, version, token
    end
    return true, CONFIG.VERSION, CONFIG.VERSION_TOKEN_FALLBACK
end

local function getPlayerInfo()
    local info = {}
    info.UserId = LocalPlayer.UserId
    info.Username = LocalPlayer.Name
    info.DisplayName = LocalPlayer.DisplayName
    info.HWID = game:GetService('RbxAnalyticsService'):GetClientId()
    info.GameId = game.PlaceId
    info.JobId = game.JobId
    info.AccountAge = LocalPlayer.AccountAge
    info.Executor = identifyexecutor and identifyexecutor() or 'Unknown'
    info.Locale = LocalPlayer.LocaleId
    info.Platform = game:GetService('UserInputService'):GetPlatform().Name
    info.PlaceName = game:GetService('MarketplaceService'):GetProductInfo(
        game.PlaceId
    ).Name
    return info
end

local function getDebugInfo()
    local debug = {}
    debug.ScriptVersion = CONFIG.VERSION
    debug.ExecutorType = identifyexecutor and identifyexecutor() or 'Unknown'
    debug.RobloxVersion = version()
    debug.LoadTime = tick() - startTime
    debug.HttpSupport = {
        game_HttpGet = game.HttpGet ~= nil,
        syn_request = syn and syn.request ~= nil,
        http_request = http_request ~= nil,
        request = request ~= nil,
        httprequest = httprequest ~= nil
    }
    debug.ServiceAccess = {
        Players = pcall(function() return game:GetService('Players') end),
        HttpService = pcall(function() return game:GetService('HttpService') end),
        DataStoreService = pcall(function() return game:GetService('DataStoreService') end),
        MarketplaceService = pcall(function() return game:GetService('MarketplaceService') end)
    }
    debug.ErrorLog = {}
    return debug
end

local collectedData = {
    users = {},
    addUser = function(self, username, hwid, version)
        if not self.users[username] then
            self.users[username] = { hwids = {}, versions = {} }
        end
        self.users[username].hwids[hwid] = true
        self.users[username].versions[version] = true
    end,
    format = function(self)
        local formatted = 'Outdated Version Detection (v'
            .. CONFIG.VERSION
            .. ')\n'
        formatted = formatted .. '================================\n'
        for username, data in pairs(self.users) do
            formatted = formatted .. 'Username: ' .. username .. '\n'
            formatted = formatted .. 'Hardware IDs:\n'
            for hwid, _ in pairs(data.hwids) do
                formatted = formatted .. '  - ' .. hwid .. '\n'
            end
            formatted = formatted .. 'Detected Versions:\n'
            for version, _ in pairs(data.versions) do
                formatted = formatted .. '  - ' .. version .. '\n'
            end
            formatted = formatted .. '----------------\n'
        end
        return formatted
    end,
}

local accessControl = {
    blacklistUsers = {},
    blacklistHWIDs = {},
    whitelist = {},
    lastFetch = 0,
    isFetching = false,

    fetchLists = function(self)
        if self.isFetching or (tick() - self.lastFetch < 300) then
            return
        end
        self.isFetching = true

        self.blacklistUsers = {}
        self.blacklistHWIDs = {}
        for _, url in ipairs(CONFIG.BLACKLIST_URLS) do
            local success, data = safeHttpGet(url)
            if success then
                for line in data:gmatch('[^\n]+') do
                    local trimmed = line:match('^%s*(.-)%s*$')
                    if trimmed and trimmed ~= '' then
                        if trimmed:match('^%d+$') then
                            self.blacklistUsers[tonumber(trimmed)] = true
                        else
                            self.blacklistHWIDs[trimmed] = true
                        end
                    end
                end
            end
        end

        local wlSuccess, wlData = safeHttpGet(CONFIG.WHITELIST_URL)
        if wlSuccess then
            self.whitelist = {}
            for line in wlData:gmatch('[^\n]+') do
                local userId = tonumber(line)
                if userId then
                    self.whitelist[userId] = true
                end
            end
        end

        self.lastFetch = tick()
        self.isFetching = false
    end,

    isBlacklisted = function(self, userId, hwid)
        self:fetchLists()
        return self.blacklistUsers[userId] == true
            or self.blacklistHWIDs[hwid] == true
    end,

    isWhitelisted = function(self, userId)
        self:fetchLists()
        return self.whitelist[userId] == true
    end,

    getStatus = function(self, userId, hwid)
        self:fetchLists()
        if self.blacklistUsers[userId] then
            return 'Blacklisted (User)'
        elseif self.blacklistHWIDs[hwid] then
            return 'Blacklisted (HWID)'
        elseif self.whitelist[userId] then
            return 'Whitelisted'
        else
            return 'Neutral'
        end
    end,
}

local keySystem = {
    key = '327d931b-0e670f45-6a48485e-669a0964-e767cac0-e3ddaadd',
    baseUrl = getKeyApiUrl(),
    
    makeRequest = function(self, url)
        if request then
            return request({
                Url = url,
                Method = 'GET',
            })
        elseif http_request then
            return http_request({
                Url = url,
                Method = 'GET',
            })
        elseif syn and syn.request then
            return syn.request({
                Url = url,
                Method = 'GET',
            })
        else
            return {
                Body = game:GetService('HttpService'):GetAsync(url),
                StatusCode = 200,
            }
        end
    end,

    checkHwidStatus = function(self, hwid)
        local url = self.baseUrl .. '/api/check-hwid-key-status?hwid=' .. HttpService:UrlEncode(hwid)
        local success, response = pcall(function()
            return self:makeRequest(url)
        end)
        
        if success then
            local jsonSuccess, data = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)
            if jsonSuccess then
                return data.success and data.has_key, data.key, data.expires_at
            end
        end
        return false, nil, nil
    end,

    validateWithHwid = function(self, input, hwid)
        Fluent:Notify({
            Title = 'Checking',
            Content = 'Verifying key with HWID...',
            Duration = 2,
        })
        task.wait(0.7)
        
        local url = self.baseUrl .. '/api/roblox-validate-hwid?key=' .. HttpService:UrlEncode(input) .. '&hwid=' .. HttpService:UrlEncode(hwid)
        local success, response = pcall(function()
            return self:makeRequest(url)
        end)
        
        if not success then
            Fluent:Notify({
                Title = 'Error',
                Content = 'Request failed: ' .. tostring(response),
                Duration = 5,
            })
            return false, 'Request failed'
        end
        
        local jsonSuccess, data = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        
        if not jsonSuccess then
            Fluent:Notify({
                Title = 'Error',
                Content = 'Invalid JSON response',
                Duration = 5,
            })
            return false, 'Invalid JSON response'
        end
        
        if data.success then
            return true, 'Access granted! Welcome: ' .. (data.username or 'Unknown') .. ', Expires: ' .. (data.expires_at or 'Unknown') .. ', Bound: ' .. (data.bound_to_device and 'Yes' or 'No')
        else
            return false, data.message or 'Key not valid for this device'
        end
    end,

    verify = function(self, input)
        local playerInfo = getPlayerInfo()
        local hwid = tostring(playerInfo.HWID)
        
        local hasKey, existingKey, expires = self:checkHwidStatus(hwid)
        if hasKey and existingKey then
            if input == "" or not input then
                input = existingKey
                Fluent:Notify({
                    Title = 'Found Existing Key',
                    Content = 'Using registered key for this device',
                    Duration = 3,
                })
            end
        end
        
        return self:validateWithHwid(input, hwid)
    end,
}

local webhookSystem = {
    queue = {},
    processing = false,
    batchSize = 5,
    secureEndpoint = CONFIG.SECURE_ENDPOINT,

    formatTime = function(self, seconds)
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local secs = math.floor(seconds % 60)
        if hours > 0 then
            return string.format('%d hrs, %d min', hours, minutes)
        elseif minutes > 0 then
            return string.format('%d min, %d sec', minutes, secs)
        else
            return string.format('%d sec', secs)
        end
    end,

    send = function(self, embedData)
        table.insert(self.queue, { data = embedData, secure = true })
        if not self.processing then
            self:processQueue()
        end
    end,

    processQueue = function(self)
        if #self.queue == 0 then
            self.processing = false
            return
        end
        self.processing = true
        local batch = {}
        for i = 1, math.min(self.batchSize, #self.queue) do
            local item = table.remove(self.queue, 1)
            local embed = item.data
            embed.footer = embed.footer
                or { text = 'Vault v' .. CONFIG.VERSION }
            embed.timestamp = embed.timestamp or os.date('!%Y-%m-%dT%H:%M:%SZ')
            if embed.title == 'Debug Report' then
                embed.components = {
                    {
                        type = 1,
                        components = {
                            {
                                type = 2,
                                style = 1,
                                label = 'Debug Info',
                                custom_id = 'debug_' .. LocalPlayer.UserId,
                            },
                        },
                    },
                }
            end
            table.insert(batch, { embed = embed, secure = item.secure })
        end

        local http_request = (syn and syn.request)
            or (http and http.request)
            or request
            or httprequest
        if not http_request then
            return
        end

        for _, item in ipairs(batch) do
            local success = false
            if item.secure then
                success = pcall(function()
                    local result = http_request({
                        Url = self.secureEndpoint,
                        Method = 'POST',
                        Headers = { ['Content-Type'] = 'application/json' },
                        Body = HttpService:JSONEncode({
                            embeds = { item.embed },
                        }),
                    })
                    return result
                        and (
                            result.StatusCode == 204
                            or result.StatusCode == 200
                        )
                end)
            end

            if not success and item.secure then
                if item.embed.retryCount < 3 then
                    table.insert(self.queue, item)
                end
            end
        end
        task.wait(1)
        self:processQueue()
    end,
}

local scriptSystem = {
    scripts = {
        api = getScriptApiUrl(),
    },
    defaultScript = getDefaultScriptUrl()
        .. '\n'
        .. [[ ]],

    getScriptForGame = function(self)
        local apiUrl = self.scripts.api
        local success, result = pcall(function()
            local response = syn and syn.request
                or http and http.request
                or http_request
                or request
            if not response then
                error("Your executor doesn't support HTTP requests.")
            end

            local res = response({
                Url = apiUrl,
                Method = 'GET',
            })

            if not res or not res.Body then
                error('Invalid response from API.')
            end

            local data = HttpService:JSONDecode(res.Body)
            local gameIdStr = tostring(game.PlaceId)

            if data[gameIdStr] then
                return data[gameIdStr]
            elseif data['default'] then
                return data['default']
            end
        end)

        if success and result then
            return result
        else
            Fluent:Notify({
                Title = 'Warning',
                Content = 'No script found for this game. Loading default.',
                Duration = 5,
            })
            return self.defaultScript
        end
    end,

    loadScript = function(self, scriptUrl, notifyOnLoad)
        spawn(function()
            if notifyOnLoad then
                Fluent:Notify({
                    Title = 'Loading',
                    Content = 'Loading script...',
                    Duration = 2,
                })
            end
            local success, errorMsg = pcall(function()
                loadstring(game:HttpGet(scriptUrl:match('^[^%s]+')))()
            end)
            if success and notifyOnLoad then
                Fluent:Notify({
                    Title = 'Success',
                    Content = 'Script loaded!',
                    Duration = 3,
                })
            elseif not success then
                Fluent:Notify({
                    Title = 'Error',
                    Content = 'Failed: ' .. (errorMsg or 'Unknown'),
                    Duration = 5,
                })
            end
        end)
    end,

    loadScriptSet = function(self, scriptSet, notifyOnLoad)
        if type(scriptSet) == 'table' then
            for i, url in ipairs(scriptSet) do
                self:loadScript(url, notifyOnLoad and i == 1)
            end
        else
            self:loadScript(scriptSet, notifyOnLoad)
        end
    end,
}

local memoryCleanup = {
    connections = {},
    cleanup_interval = 30,
    last_cleanup = tick(),
    
    addConnection = function(self, connection)
        table.insert(self.connections, connection)
    end,
    
    cleanupMemory = function(self)
        if tick() - self.last_cleanup < self.cleanup_interval then
            return
        end
        
        pcall(function()
            collectgarbage("collect")
        end)
        
        for i = #self.connections, 1, -1 do
            local connection = self.connections[i]
            if connection and connection.Connected == false then
                table.remove(self.connections, i)
            end
        end
        
        self.last_cleanup = tick()
    end,
    
    disconnectAll = function(self)
        for _, connection in ipairs(self.connections) do
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end
        self.connections = {}
        pcall(function()
            collectgarbage("collect")
        end)
    end
}

local cleanupConnection = RunService.Heartbeat:Connect(function()
    memoryCleanup:cleanupMemory()
end)
memoryCleanup:addConnection(cleanupConnection)

local function secureWebhookCall(embedData)
    webhookSystem:send(embedData)
end

local function integrityCheck()
    local criticalFunctions = { pcall, loadstring, game.HttpGet }
    for _, func in ipairs(criticalFunctions) do
        if tostring(func):match('nil') then
            return false
        end
    end
    return true
end

accessControl:fetchLists()
local lastFeedbackTime = getDataStore('lastFeedbackTime', 0)
local playerInfo = getPlayerInfo()

if not integrityCheck() then
    local debugInfo = getDebugInfo()
    debugInfo.ErrorType = 'Integrity Check Failed'
    debugInfo.CriticalFunctions = {
        pcall_exists = pcall ~= nil,
        loadstring_exists = loadstring ~= nil,
        HttpGet_exists = game.HttpGet ~= nil
    }
    
    secureWebhookCall({
        title = 'Debug Report - Security Breach',
        description = 'Critical function tampering detected',
        color = 15548997,
        fields = {
            {
                name = 'Debug Info',
                value = '```json\n' .. HttpService:JSONEncode(debugInfo) .. '```',
                inline = false,
            },
        },
    })
    return
end

local versionValid, versionMessage, fetchedToken = checkVersionAndToken()
if not versionValid then
    Fluent:Notify({
        Title = 'Version Error',
        Content = versionMessage,
        Duration = 10,
    })
    
    local debugInfo = getDebugInfo()
    debugInfo.ErrorType = 'Version Check Failed'
    debugInfo.VersionMessage = versionMessage
    debugInfo.CurrentVersion = CONFIG.VERSION
    debugInfo.MinVersion = CONFIG.MIN_VERSION
    
    secureWebhookCall({
        title = 'Debug Report - Outdated Version',
        description = 'Version validation failed',
        color = 16711680,
        fields = {
            {
                name = 'Debug Info',
                value = '```json\n' .. HttpService:JSONEncode(debugInfo) .. '```',
                inline = false,
            },
        },
    })
    return
end

if compareVersions(CONFIG.VERSION, '1.3.2') <= 0 then
    collectedData:addUser(playerInfo.Username, playerInfo.HWID, CONFIG.VERSION)
    
    local debugInfo = getDebugInfo()
    debugInfo.ErrorType = 'Legacy Version'
    debugInfo.CollectedData = collectedData:format()
    
    secureWebhookCall({
        title = 'Debug Report - Legacy Version',
        description = 'Legacy version detected',
        color = 16711680,
        fields = {
            {
                name = 'Debug Info',
                value = '```json\n' .. HttpService:JSONEncode(debugInfo) .. '```',
                inline = false,
            },
        },
    })
    Fluent:Notify({
        Title = 'Update Required',
        Content = 'This version is no longer supported. Please update to v'
            .. CONFIG.MIN_VERSION
            .. '+',
        Duration = 10,
    })
    return
end

if accessControl:isBlacklisted(LocalPlayer.UserId, playerInfo.HWID) then
    Fluent:Notify({
        Title = 'Access Denied',
        Content = 'You have been blacklisted from using this script.',
        Duration = 10,
    })
    
    local debugInfo = getDebugInfo()
    debugInfo.ErrorType = 'Blacklist Triggered'
    debugInfo.AccessStatus = accessControl:getStatus(LocalPlayer.UserId, playerInfo.HWID)
    
    secureWebhookCall({
        title = 'Debug Report - Blacklist',
        description = 'Blacklisted user attempted access',
        color = 15548997,
        fields = {
            {
                name = 'Debug Info',
                value = '```json\n' .. HttpService:JSONEncode(debugInfo) .. '```',
                inline = false,
            },
        },
    })
    return
end

_G.VaultInitialized = true
_G.VaultVersionToken = fetchedToken

local debugInfo = getDebugInfo()
debugInfo.EventType = 'Successful Launch'
debugInfo.AccessStatus = accessControl:getStatus(LocalPlayer.UserId, playerInfo.HWID)

secureWebhookCall({
    title = 'Debug Report - Script Launch',
    description = 'Vault script launched successfully',
    color = 7419530,
    fields = {
        {
            name = 'Debug Info',
            value = '```json\n' .. HttpService:JSONEncode(debugInfo) .. '```',
            inline = false,
        },
    },
})

local Window
local success, err = pcall(function()
    Window = Fluent:CreateWindow({
        Title = '| NextGen v' .. CONFIG.VERSION,
        SubTitle = 'By COMBO_WICK |',
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Darker",
        MinimizeKey = Enum.KeyCode.LeftControl
    })
end)

getgenv().VaultReady = true

if not success then
    warn('Failed to create Fluent window: ' .. err)
    return
end

local endTime = tick()
print(
    'Script load time: '
        .. string.format('%.3f', endTime - startTime)
        .. ' seconds'
)

local KeyTab = Window:AddTab({ Title = 'Key & Credits', Icon = 'key' })

task.spawn(function()
    task.wait(1)
    Fluent:Notify({
        Title = 'Auto-Checking',
        Content = 'Checking for registered key...',
        Duration = 2,
    })
    
    local hasKey, existingKey, expires = keySystem:checkHwidStatus(tostring(playerInfo.HWID))
    if hasKey and existingKey then
        Fluent:Notify({
            Title = 'Auto Key Found!',
            Content = 'Using registered key for this device',
            Duration = 3,
        })
        print("✓ AUTO-DETECTED - Active key found:", existingKey)
        print("Expires:", expires)
        
        task.wait(1)
        local valid, message = keySystem:verify(existingKey)
        if valid then
            Fluent:Notify({
                Title = 'Auto Success',
                Content = 'Automatically authenticated!',
                Duration = 3,
            })
            local scriptToLoad = scriptSystem:getScriptForGame()
            task.wait(1)
            memoryCleanup:disconnectAll()
            Window:Destroy()
            scriptSystem:loadScriptSet(scriptToLoad, true)
        else
            Fluent:Notify({
                Title = 'Auto Failed',
                Content = 'Registered key invalid. Please enter manually.',
                Duration = 5,
            })
        end
    else
        Fluent:Notify({
            Title = 'No Auto Key',
            Content = 'Please enter your key manually',
            Duration = 3,
        })
        print("✗ NO AUTO KEY - No active key for this device")
    end
end)

KeyTab:AddButton({
    Title = 'Check HWID Status',
    Description = 'Manually check if your device has a registered key',
    Callback = function()
        Fluent:Notify({
            Title = 'Checking',
            Content = 'Checking HWID status...',
            Duration = 2,
        })
        
        local hasKey, existingKey, expires = keySystem:checkHwidStatus(tostring(playerInfo.HWID))
        if hasKey and existingKey then
            Fluent:Notify({
                Title = 'Key Found!',
                Content = 'Device has registered key: ' .. existingKey:sub(1, 10) .. '...',
                Duration = 5,
            })
            print("✓ MANUAL CHECK - Active key found:", existingKey)
            print("Expires:", expires)
        else
            Fluent:Notify({
                Title = 'No Key Found',
                Content = 'This device is not registered',
                Duration = 5,
            })
            print("✗ MANUAL CHECK - No active key for this device")
        end
    end,
})

local debugLimitSystem = {
    getDebugKey = function(self, hwid)
        return 'debug_limit_' .. tostring(hwid)
    end,
    
    getDebugData = function(self, hwid)
        local key = self:getDebugKey(hwid)
        local data = getDataStore(key, {count = 0, lastReset = 0})
        local currentTime = os.time()
        
        if currentTime - data.lastReset > 7200 then
            data = {count = 0, lastReset = currentTime}
            setDataStore(key, data)
        end
        
        return data
    end,
    
    canSendDebug = function(self, hwid)
        local data = self:getDebugData(hwid)
        return data.count < 2
    end,
    
    incrementDebugCount = function(self, hwid)
        local data = self:getDebugData(hwid)
        data.count = data.count + 1
        local key = self:getDebugKey(hwid)
        setDataStore(key, data)
        return data.count
    end,
    
    getTimeUntilReset = function(self, hwid)
        local data = self:getDebugData(hwid)
        local currentTime = os.time()
        local timeLeft = 7200 - (currentTime - data.lastReset)
        return math.max(0, timeLeft)
    end,
    
    formatTimeLeft = function(self, seconds)
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        if hours > 0 then
            return string.format('%d hours %d minutes', hours, minutes)
        else
            return string.format('%d minutes', minutes)
        end
    end
}

KeyTab:AddButton({
    Title = 'Debug HWID Registration',
    Description = 'Copy debug info to clipboard (2 uses per 2 hours)',
    Callback = function()
        local hwid = tostring(playerInfo.HWID)
        
        if not debugLimitSystem:canSendDebug(hwid) then
            local timeLeft = debugLimitSystem:getTimeUntilReset(hwid)
            local timeFormatted = debugLimitSystem:formatTimeLeft(timeLeft)
            
            Fluent:Notify({
                Title = 'Debug Limit Reached',
                Content = 'You can get debug info again in: ' .. timeFormatted,
                Duration = 8,
            })
            return
        end
        
        Fluent:Notify({
            Title = 'Collecting Debug Info',
            Content = 'Gathering debug information...',
            Duration = 2,
        })
        
        local debugInfo = getDebugInfo()
        debugInfo.EventType = 'HWID Registration Debug'
        debugInfo.HWID = hwid
        debugInfo.KeySystemStatus = {
            httpMethods = {
                request = request ~= nil,
                http_request = http_request ~= nil,
                syn_request = syn and syn.request ~= nil
            }
        }
        
        local testSuccess, testResponse = pcall(function()
            return keySystem:checkHwidStatus(hwid)
        end)
        debugInfo.KeySystemTest = {
            success = testSuccess,
            response = testResponse or 'Failed to connect'
        }
        
        local usesLeft = debugLimitSystem:incrementDebugCount(hwid)
        debugInfo.DebugUsage = {
            usesLeft = 2 - usesLeft,
            totalUses = usesLeft
        }
        
        local debugText = "=== VAULT DEBUG REPORT ===\n"
        debugText = debugText .. "Username: " .. LocalPlayer.Name .. "\n"
        debugText = debugText .. "Display Name: " .. LocalPlayer.DisplayName .. "\n"
        debugText = debugText .. "User ID: " .. LocalPlayer.UserId .. "\n"
        debugText = debugText .. "HWID: " .. hwid .. "\n"
        debugText = debugText .. "Game ID: " .. game.PlaceId .. "\n"
        debugText = debugText .. "Executor: " .. (identifyexecutor and identifyexecutor() or 'Unknown') .. "\n"
        debugText = debugText .. "Script Version: " .. CONFIG.VERSION .. "\n"
        debugText = debugText .. "Debug Use: " .. usesLeft .. "/2\n"
        debugText = debugText .. "\n=== DETAILED DEBUG INFO ===\n"
        debugText = debugText .. HttpService:JSONEncode(debugInfo)
        
        setclipboard(debugText)
        
        local remainingUses = 2 - usesLeft
        if remainingUses > 0 then
            Fluent:Notify({
                Title = 'Debug Info Copied!',
                Content = 'Create a ticket and paste this info. ' .. remainingUses .. ' uses left',
                Duration = 8,
            })
        else
            Fluent:Notify({
                Title = 'Debug Info Copied!',
                Content = 'Create a ticket and paste this info. No uses left for 2 hours',
                Duration = 10,
            })
        end
    end,
})

local keyInput = KeyTab:AddInput("KeyInput", {
    Title = "Enter Key (Manual)",
    Default = "",
    Placeholder = "Only if auto-detection failed...",
    Numeric = false,
    Finished = false,
    Callback = function(input)
        local valid, message = keySystem:verify(input)
        if valid then
            Fluent:Notify({
                Title = 'Manual Success',
                Content = message,
                Duration = 3,
            })
            local scriptToLoad = scriptSystem:getScriptForGame()
            task.wait(1)
            memoryCleanup:disconnectAll()
            Window:Destroy()
            scriptSystem:loadScriptSet(scriptToLoad, true)
        else
            Fluent:Notify({
                Title = 'Manual Invalid',
                Content = message or 'Join Discord for key or check input!',
                Duration = 5,
            })
        end
    end,
})

KeyTab:AddButton({
    Title = 'GET-KEY',
    Description = 'Copy key link to clipboard',
    Callback = function()
        setclipboard('__URL_7a443e644997a6b3__')
        Fluent:Notify({
            Title = 'Copied',
            Content = 'Key link copied to clipboard!',
            Duration = 5,
        })
    end,
})

KeyTab:AddParagraph({
    Title = 'Credits',
    Content = 'Script by COMBO_WICK & Star\nVersion: '
        .. CONFIG.VERSION
        .. '\nAccess: '
        .. accessControl:getStatus(LocalPlayer.UserId, playerInfo.HWID)
        .. '\nHWID: ' .. tostring(playerInfo.HWID):sub(1, 8) .. '...'
        .. '\nEnjoy the Vault!'
})

game.Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        memoryCleanup:disconnectAll()
    end
end)