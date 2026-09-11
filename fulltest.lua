local KEY = "0f904aec-2aff6c65-931f5da6-f443bb31-fceafca9-b861a008"

local out = {}
local function log(s) table.insert(out, tostring(s)) end
local report = ""

local clipFns = {}
pcall(function() if setclipboard then table.insert(clipFns, setclipboard) end end)
pcall(function() if toclipboard then table.insert(clipFns, toclipboard) end end)
pcall(function() if writeclipboard then table.insert(clipFns, writeclipboard) end end)
pcall(function() if Clipboard and Clipboard.set then table.insert(clipFns, Clipboard.set) end end)

local gui, box, statusLbl
local function buildGui()
    pcall(function()
        local parent = (gethui and gethui()) or (game:GetService("CoreGui"))
        gui = Instance.new("ScreenGui")
        gui.Name = "CWDiag"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = parent
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 560, 0, 420)
        frame.Position = UDim2.new(0.5, -280, 0.5, -210)
        frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Draggable = true
        frame.Parent = gui
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 34)
        title.BackgroundColor3 = Color3.fromRGB(120, 40, 180)
        title.BorderSizePixel = 0
        title.Text = "COMBOWICK FULL DIAGNOSTIC  (drag me)"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 15
        title.Parent = frame
        statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -12, 0, 20)
        statusLbl.Position = UDim2.new(0, 6, 0, 36)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "running..."
        statusLbl.TextColor3 = Color3.fromRGB(255, 220, 100)
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.Font = Enum.Font.Gotham
        statusLbl.TextSize = 13
        statusLbl.Parent = frame
        box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -12, 1, -100)
        box.Position = UDim2.new(0, 6, 0, 58)
        box.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        box.BorderSizePixel = 0
        box.TextColor3 = Color3.fromRGB(210, 255, 210)
        box.Font = Enum.Font.Code
        box.TextSize = 12
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.MultiLine = true
        box.ClearTextOnFocus = false
        box.TextWrapped = true
        box.Text = "running..."
        box.Parent = frame
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0.5, -8, 0, 30)
        copyBtn.Position = UDim2.new(0, 6, 1, -36)
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
        copyBtn.BorderSizePixel = 0
        copyBtn.Text = "COPY REPORT"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 14
        copyBtn.Parent = frame
        copyBtn.MouseButton1Click:Connect(function()
            for _, fn in ipairs(clipFns) do pcall(fn, report) end
            copyBtn.Text = "COPIED! paste to support"
        end)
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0.5, -8, 0, 30)
        closeBtn.Position = UDim2.new(0.5, 2, 1, -36)
        closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "CLOSE"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.Parent = frame
        closeBtn.MouseButton1Click:Connect(function() pcall(function() gui:Destroy() end) end)
    end)
end

local function flush(status)
    report = table.concat(out, "\n")
    pcall(function() if box then box.Text = report end end)
    pcall(function() if statusLbl and status then statusLbl.Text = status end end)
    for _, fn in ipairs(clipFns) do pcall(fn, report) end
    pcall(function() if writefile then writefile("combowick_fulltest.txt", report) end end)
end

buildGui()

log("===== COMBOWICK FULL DIAGNOSTIC =====")
log("time: " .. tostring(os.time()))

local exec = "unknown"
pcall(function()
    if identifyexecutor then exec = (identifyexecutor()) or exec
    elseif getexecutorname then exec = (getexecutorname()) or exec end
end)
log("Executor       : " .. tostring(exec))

local reqFn = request or http_request or (http and http.request) or (syn and syn.request) or (fluxus and fluxus.request) or (getgenv and getgenv().request)
log("request() fn   : " .. tostring(reqFn ~= nil))
log("HttpGet        : " .. tostring(pcall(function() return game.HttpGet end)))
log("setclipboard   : " .. tostring(setclipboard ~= nil))
log("clip fns found : " .. tostring(#clipFns))
log("writefile      : " .. tostring(writefile ~= nil))

local hwid = "?"
pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
log("HWID           : " .. tostring(hwid))
log("PlaceId        : " .. tostring(game.PlaceId) .. "  GameId: " .. tostring(game.GameId))
flush("collecting env...")

local function GET(url)
    local t = tick()
    local ok, r = pcall(function()
        if reqFn then
            return reqFn({ Url = url, Method = "GET", Headers = { ["Content-Type"] = "application/json" } })
        else
            return { Body = game:HttpGet(url), StatusCode = 200 }
        end
    end)
    local ms = math.floor((tick() - t) * 1000)
    if not ok then return nil, tostring(r), ms end
    if type(r) ~= "table" then return nil, "non-table:" .. tostring(r), ms end
    local code = r.StatusCode or r.status_code or r.Status or 0
    local body = r.Body or r.body or ""
    return { code = code, body = body }, nil, ms
end

local function testHost(name, url)
    local res, err, ms = GET(url)
    if res then
        log(string.format("[OK]   %-20s code=%s %dms %db", name, tostring(res.code), ms, #res.body))
    else
        log(string.format("[FAIL] %-20s %dms -> %s", name, ms, err))
    end
    flush("testing " .. name .. "...")
    return res
end

log("")
log("--- HOST REACHABILITY ---")
testHost("GitHub IQ",     "https://raw.githubusercontent.com/checkurasshole/Script/refs/heads/main/IQ")
testHost("GitHub module", "https://raw.githubusercontent.com/checkurasshole/combowick-loader/main/combowick_module.lua")
testHost("secure-store",  "https://v0-supabase-secure-storage.vercel.app/api/script/1a6364bf01b563c0ce61fc32f7291e73")
testHost("Supabase sess", "https://fdxrmmcppkngeexkwdjd.supabase.co/rest/v1/")

log("")
log("--- KEY VALIDATION (the real check) ---")
log("Key: " .. KEY)
local vurl = "https://v0-remix-of-roblox-executor-system.vercel.app/api/roblox-validate-hwid?key="
    .. KEY .. "&hwid=" .. tostring(hwid) .. "&place_id=" .. tostring(game.PlaceId)
local vres, verr, vms = GET(vurl)
if not vres then
    log("VALIDATE REQUEST FAILED (" .. vms .. "ms): " .. tostring(verr))
    flush("validate failed")
else
    local body = vres.body
    log("HTTP status : " .. tostring(vres.code) .. "  (" .. vms .. "ms)")
    log("Body length : " .. #body)
    log("Has %7B/%7D : " .. tostring(body:find("%%7[BbDd]") ~= nil))
    log("Has %22/%5B : " .. tostring((body:find("%%22") or body:find("%%5[BbDd]")) ~= nil))
    log("FULL BODY   :")
    log(body)
    flush("decoding...")

    local hs = game:GetService("HttpService")
    local rok, rdata = pcall(function() return hs:JSONDecode(body) end)
    if rok and type(rdata) == "table" then
        log("")
        log("RAW decode   : OK  success=" .. tostring(rdata.success)
            .. " all_access=" .. tostring(rdata.all_access)
            .. " scripts=" .. tostring(rdata.scripts and #rdata.scripts or 0)
            .. " bind=" .. tostring(rdata.binding_status))
    else
        log("")
        log("RAW decode   : FAILED -> " .. tostring(rdata))
        local fixed = body:gsub("%%7[Bb]", "{"):gsub("%%7[Dd]", "}"):gsub("%%5[Bb]", "["):gsub("%%5[Dd]", "]"):gsub("%%22", '"'):gsub("%%3[Aa]", ":"):gsub("%%2[Cc]", ",")
        local fok, fdata = pcall(function() return hs:JSONDecode(fixed) end)
        if fok and type(fdata) == "table" then
            log("FIXED decode : OK  success=" .. tostring(fdata.success)
                .. " scripts=" .. tostring(fdata.scripts and #fdata.scripts or 0))
            log(">>> DIAGNOSIS: executor mangled the response, loader _fixBody handles it.")
        else
            log("FIXED decode : FAILED -> " .. tostring(fdata))
        end
    end
end

log("")
log("===== END — press COPY REPORT, paste to support =====")
flush("DONE — press COPY REPORT")
print(report)
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "COMBOWICK", Text = "Diagnostic done — press COPY REPORT in the box.", Duration = 10 })
end)
