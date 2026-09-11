-- COMBOWICK — Connection Diagnostic. Tests reachability of every host the loader needs,
-- prints a report AND copies it to the clipboard (paste it back to support).
local out = {}
local function log(s) table.insert(out, tostring(s)) end

log("===== COMBOWICK CONNECTION DIAGNOSTIC =====")

-- executor + capabilities
local exec = "unknown"
pcall(function()
    if identifyexecutor then exec = (identifyexecutor()) or exec
    elseif getexecutorname then exec = (getexecutorname()) or exec end
end)
local reqFn = request or http_request or (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request)
log("Executor      : " .. tostring(exec))
log("request() fn  : " .. tostring(reqFn ~= nil))
log("setclipboard  : " .. tostring((setclipboard or toclipboard) ~= nil))
local hwid = "?"
pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
log("HWID          : " .. tostring(hwid))
log("PlaceId       : " .. tostring(game.PlaceId) .. "  GameId: " .. tostring(game.GameId))
log("")

-- test each host the loader depends on
local function testHost(name, url)
    local ok, info = pcall(function()
        local t = tick()
        local code, len = 0, 0
        if reqFn then
            local r = reqFn({ Url = url, Method = "GET" })
            code = r.StatusCode or r.status_code or r.Status or 0
            len = (r.Body and #r.Body) or 0
        else
            local body = game:HttpGet(url)
            code, len = 200, #body
        end
        return { ms = math.floor((tick() - t) * 1000), code = code, len = len }
    end)
    if ok and type(info) == "table" then
        log(string.format("[OK]   %-22s code=%s  %dms  %db", name, tostring(info.code), info.ms, info.len))
    else
        log(string.format("[FAIL] %-22s -> %s", name, tostring(info)))
    end
end

testHost("GitHub IQ loader",   "https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ")
testHost("GitHub module",      "https://raw.githubusercontent.com/checkurasshole/combowick-loader/main/combowick_module.lua")
testHost("Vercel key API",     "https://v0-remix-of-roblox-executor-system.vercel.app/api/roblox-validate-hwid?key=diag&hwid=diag&place_id=1")
testHost("Supabase session",   "https://fdxrmmcppkngeexkwdjd.supabase.co/rest/v1/")
testHost("secure-storage",     "https://v0-supabase-secure-storage.vercel.app/api/script/1a6364bf01b563c0ce61fc32f7291e73")

log("")
log("===== END (paste this whole thing to support) =====")

local report = table.concat(out, "\n")
print(report)
-- copy to clipboard (several executor variants)
pcall(function()
    local cb = setclipboard or toclipboard or writeclipboard or (Clipboard and Clipboard.set)
    if cb then cb(report) end
end)
-- backup to a file too
pcall(function() if writefile then writefile("combowick_diag.txt", report) end end)
-- on-screen notice
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "COMBOWICK Diag", Text = "Report copied to clipboard — paste it to support.", Duration = 8 })
end)
