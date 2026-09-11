-- COMBOWICK — KEY VALIDATION test. Runs the EXACT key check the loader does, from your
-- executor, with your real key + HWID + game, and reports the full server answer. Copies to clipboard.
local out = {}
local function log(s) table.insert(out, tostring(s)) end

local KEY = "0f904aec-2aff6c65-931f5da6-f443bb31-fceafca9-b861a008" -- Vitaly's current key

log("===== COMBOWICK KEY-VALIDATION TEST =====")
local hwid = "?"
pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
log("HWID sent : " .. tostring(hwid))
log("PlaceId   : " .. tostring(game.PlaceId))
log("Key sent  : " .. KEY)
log("")

local reqFn = request or http_request or (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request)
local url = "https://v0-remix-of-roblox-executor-system.vercel.app/api/roblox-validate-hwid?key="
    .. KEY .. "&hwid=" .. tostring(hwid) .. "&place_id=" .. tostring(game.PlaceId)

local ok, res = pcall(function()
    if reqFn then return reqFn({ Url = url, Method = "GET", Headers = { ["Content-Type"] = "application/json" } })
    else return { Body = game:HttpGet(url), StatusCode = 200 } end
end)

if not ok then
    log("RESULT: request THREW -> " .. tostring(res))
elseif type(res) ~= "table" then
    log("RESULT: bad response type -> " .. tostring(res))
else
    log("HTTP status: " .. tostring(res.StatusCode or res.status_code or res.Status or "?"))
    local body = res.Body or res.body or ""
    log("Body:")
    log(tostring(body))
end

log("")
log("===== END (paste this whole thing to support) =====")
local report = table.concat(out, "\n")
print(report)
pcall(function() local cb = setclipboard or toclipboard or writeclipboard; if cb then cb(report) end end)
pcall(function() if writefile then writefile("combowick_keytest.txt", report) end end)
pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "COMBOWICK", Text = "Key test copied — paste it to support.", Duration = 8 }) end)
