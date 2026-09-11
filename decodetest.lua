-- COMBOWICK — decode test. Validates the key, then tries to JSONDecode the raw body AND a
-- repaired body, so we see if the response is actually mangled (%7D) or clean. Copies to clipboard.
local out = {}
local function log(s) table.insert(out, tostring(s)) end
local KEY = "0f904aec-2aff6c65-931f5da6-f443bb31-fceafca9-b861a008"
local hs = game:GetService("HttpService")

log("===== COMBOWICK DECODE TEST =====")
local hwid = "?"; pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
log("HWID   : " .. tostring(hwid))
log("Place  : " .. tostring(game.PlaceId))

local reqFn = request or http_request or (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request)
local url = "https://v0-remix-of-roblox-executor-system.vercel.app/api/roblox-validate-hwid?key=" .. KEY .. "&hwid=" .. tostring(hwid) .. "&place_id=" .. tostring(game.PlaceId)
local ok, res = pcall(function()
    if reqFn then return reqFn({ Url = url, Method = "GET" }) else return { Body = game:HttpGet(url) } end
end)

if not ok or type(res) ~= "table" then
    log("REQUEST FAILED: " .. tostring(res))
else
    local body = res.Body or res.body or ""
    log("HTTP method : " .. (reqFn and "request()" or "HttpGet"))
    log("Body length : " .. #body)
    log("Last 24 chars: [" .. body:sub(-24) .. "]")
    log("Has literal %7D: " .. tostring(body:find("%%7[BbDd]") ~= nil))
    local rok, rdata = pcall(function() return hs:JSONDecode(body) end)
    if rok and type(rdata) == "table" then
        log("RAW decode  : OK  success=" .. tostring(rdata.success) .. " scripts=" .. tostring(rdata.scripts and #rdata.scripts or 0))
    else
        log("RAW decode  : FAILED -> " .. tostring(rdata))
    end
    local fixed = body:gsub("%%7[Bb]", "{"):gsub("%%7[Dd]", "}"):gsub("%%5[Bb]", "["):gsub("%%5[Dd]", "]"):gsub("%%22", '"'):gsub("%%3[Aa]", ":"):gsub("%%2[Cc]", ",")
    local fok, fdata = pcall(function() return hs:JSONDecode(fixed) end)
    if fok and type(fdata) == "table" then
        log("FIXED decode: OK  success=" .. tostring(fdata.success) .. " scripts=" .. tostring(fdata.scripts and #fdata.scripts or 0))
    else
        log("FIXED decode: FAILED -> " .. tostring(fdata))
    end
end

log("===== END (paste this to support) =====")
local report = table.concat(out, "\n")
print(report)
pcall(function() local cb = setclipboard or toclipboard or writeclipboard; if cb then cb(report) end end)
pcall(function() if writefile then writefile("combowick_decodetest.txt", report) end end)
