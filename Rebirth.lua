-- ============================================================================
--  Rebirth v2  ·  premium unified Remote / Event / HTTP spy
--  Columnar log table (Time · Type · Remote Path) with color-coded types,
--  per-type stats footer, status bar (FPS/ping), nav profile card.
--  Built on v1's bulletproof rowItem selection + the proven IxSpy engine.
-- ============================================================================

if not game:GetService("RunService"):IsClient() then return end
if shared and typeof(shared.__IxSpyRebirth) == "function" then pcall(shared.__IxSpyRebirth); return end

--======================  Environment & capabilities  ========================--

local env = getfenv()
local function fn(name)
    local f = env[name]
    return (typeof(f) == "function") and f or nil
end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

local hookfunction      = fn("hookfunction")
local hookmetamethod    = fn("hookmetamethod")
local getnamecallmethod = fn("getnamecallmethod")
local newcclosure       = fn("newcclosure")
local checkcaller       = fn("checkcaller")
local getcallingscript  = fn("getcallingscript")
local getcallbackvalue  = fn("getcallbackvalue")
local getnilinstancesFn = fn("getnilinstances") or fn("getnils")
local firesignal        = fn("firesignal")
local setclipboard      = fn("setclipboard") or fn("toclipboard")
local decompile         = fn("decompile")
local getscriptbytecode = fn("getscriptbytecode") or fn("dumpstring")
local loadstringFn      = fn("loadstring")
local writefileFn       = fn("writefile")
local readfileFn        = fn("readfile")
local isfileFn          = fn("isfile")
local makefolderFn      = fn("makefolder")
local cloneref          = fn("cloneref") or function(x) return x end
local getconnections    = fn("getconnections") or fn("get_signal_cons")
local httpRequestFn     = fn("request") or fn("http_request") or fn("syn_request") or (typeof(getfenv().syn) == "table" and typeof(getfenv().syn.request) == "function" and getfenv().syn.request or nil)

local getrawmetatable   = fn("getrawmetatable") or getrawmetatable

-- ─── Functional capability self-test ────────────────────────────────────────
-- Don't trust that a primitive merely EXISTS — some executors export stubs that
-- lie. Each test EXERCISES the function on a throwaway object and asserts the real
-- result, so the spy KNOWS which data sources are trustworthy rather than assuming.
-- Surfaced to the user in Settings → Compatibility (green = verified working).
local Caps, CapsOrder = {}, {}
local function captest(name, essential, checker)
    CapsOrder[#CapsOrder + 1] = name
    local ok, res = pcall(checker)
    local pass = ok and res ~= false
    local note
    if not pass then note = ok and "present but had no effect" or tostring(res):gsub("^.-:%d+:%s*", "") end
    Caps[name] = { ok = pass, essential = essential or false, note = note }
    return pass
end

captest("hookfunction", true, function()
    assert(typeof(hookfunction) == "function", "missing")
    local f = function() return "a" end
    local old = hookfunction(f, function() return "b" end)
    local works = f() == "b"
    if old then pcall(hookfunction, f, old) end           -- restore the dummy
    return works
end)
captest("hookmetamethod", true, function() return typeof(hookmetamethod) == "function" end)
captest("getnamecallmethod", true, function() return typeof(getnamecallmethod) == "function" end)
captest("getrawmetatable", false, function()
    assert(typeof(getrawmetatable) == "function", "missing")
    return typeof(getrawmetatable(game)) == "table"
end)
captest("getconnections", false, function()
    assert(typeof(getconnections) == "function", "missing")
    return typeof(getconnections(RunService.Heartbeat)) == "table"
end)
captest("getcallbackvalue", false, function()                 -- needed to read RemoteFunction callbacks (incoming)
    assert(typeof(getcallbackvalue) == "function", "missing")
    local bf = Instance.new("BindableFunction"); local cb = function() end
    bf.OnInvoke = cb
    local got = getcallbackvalue(bf, "OnInvoke"); bf:Destroy()
    return got == cb
end)
captest("getnilinstances", false, function()
    assert(typeof(getnilinstancesFn) == "function", "missing")
    return typeof(getnilinstancesFn()) == "table"
end)
captest("getcallingscript", false, function()
    assert(typeof(getcallingscript) == "function", "missing")
    getcallingscript(); return true                          -- must not error
end)
captest("checkcaller", false, function()
    assert(typeof(checkcaller) == "function", "missing")
    return typeof(checkcaller()) == "boolean"
end)
captest("newcclosure", false, function()
    assert(typeof(newcclosure) == "function", "missing")
    return newcclosure(function() return 7 end)() == 7
end)
captest("firesignal", false, function() return typeof(firesignal) == "function" end)
captest("decompile", false, function() return typeof(decompile) == "function" end)

local HOOKS_AVAILABLE    = Caps.hookfunction.ok
local NAMECALL_AVAILABLE = Caps.hookmetamethod.ok and Caps.getnamecallmethod.ok
local NIL_FN_NAME        = fn("getnilinstances") and "getnilinstances" or (fn("getnils") and "getnils")

--==============================  GC keeper  =================================--

local KEEP = {}
local function keep(v)
    if typeof(v) == "table" or typeof(v) == "function" then KEEP[#KEEP + 1] = v end
    return v
end

--==============================  Settings  =================================--

local Settings = keep({
    Capture_mode       = 1,      -- 1 Max(namecall+func) · 2 Stealth(func) · 3 Passive(incoming)
    Actor_support      = true,
    Group_calls        = true,
    Ignore_spammy_logs = false,
    Maximum_log_amount = 3000,
    Calls_per_remote   = 200,    -- per-grouped-remote call history kept (expandable sub-rows / call picker)
    Log_which_calls    = 1,      -- 1 game · 2 all · 3 executor
    Highlight_syntax   = true,
    Codegen_mode       = "Readable",
    Toggle_key         = "RightControl",
    Show_http          = false,   -- HTTP Spy tab hidden until enabled in Settings
})
local CFG_DIR = "IxSpy"
local SETTINGS_PATH = CFG_DIR .. "/Settings.json"

local function ensureDir() if makefolderFn then pcall(makefolderFn, CFG_DIR) end end
local function writeJSON(path, tbl)
    if not writefileFn then return false end
    return pcall(function() ensureDir(); writefileFn(path, HttpService:JSONEncode(tbl)) end)
end
local function readJSON(path)
    if not (readfileFn and isfileFn) then return nil end
    local ok, exists = pcall(isfileFn, path)
    if not ok or not exists then return nil end
    local ok2, decoded = pcall(function() return HttpService:JSONDecode(readfileFn(path)) end)
    if ok2 and typeof(decoded) == "table" then return decoded end
    return nil
end
local function saveSettings() writeJSON(SETTINGS_PATH, Settings) end
do
    local saved = readJSON(SETTINGS_PATH)
    -- only adopt keys that exist in defaults AND match the default's type, so a corrupt or
    -- hand-edited config (e.g. a number field saved as a string) can't crash startup downstream.
    if saved then for k, v in saved do if Settings[k] ~= nil and type(v) == type(Settings[k]) then Settings[k] = v end end end
end
-- persist block / ignore / pin lists BY NAME (per view kind) across reloads. Instance keys and
-- auto-ignored spam are excluded — only your manual, name-keyed choices survive a reload.
local Filters = { path = CFG_DIR .. "/Filters.json" }   -- one table instead of 4 top-level locals (register headroom)
Filters.data = readJSON(Filters.path) or {}
function Filters.save(kind, view)
    local function names(t, skip) local o = {}; for k, v in t do if type(k) == "string" and v and not (skip and skip[k]) then o[k] = true end end return o end
    Filters.data[kind] = { block = names(view.block), ignore = names(view.ignore, view.autoIgnored), pins = names(view.pins) }
    writeJSON(Filters.path, Filters.data)
end
function Filters.load(kind, view)
    local f = Filters.data[kind]; if type(f) ~= "table" then return end
    for _, key in { "block", "ignore", "pins" } do
        if type(f[key]) == "table" then for nm, v in f[key] do if type(nm) == "string" and v == true then view[key][nm] = true end end end
    end
end
if Settings.Capture_mode < 1 or Settings.Capture_mode > 3 then Settings.Capture_mode = 1 end
-- Auto-demote to the safest capture mode this executor can ACTUALLY do (validated above),
-- so a missing/stubbed primitive degrades gracefully instead of silently capturing nothing.
if Settings.Capture_mode <= 2 and not HOOKS_AVAILABLE then Settings.Capture_mode = 3 end   -- Max AND Stealth need hookfunction (namecall routes delegate to the function hooks); without it only Passive (incoming) works
if Settings.Capture_mode == 1 and not NAMECALL_AVAILABLE then Settings.Capture_mode = HOOKS_AVAILABLE and 2 or 3 end   -- Max also needs namecall; fall to Stealth (functions) or Passive
local USE_FUNCTION_HOOKS = HOOKS_AVAILABLE and Settings.Capture_mode <= 2
local USE_NAMECALL       = NAMECALL_AVAILABLE and Settings.Capture_mode == 1

--===========================  Hook engine  ================================--

local Hooks = {}
do
    local restore = keep({})
    local iscclosure = fn("iscclosure")
    local clonefunction = fn("clonefunction")
    local mmLogged = false
    local registry = keep({})   -- displayed in the Hooks manager
    local function isC(f) if iscclosure then return iscclosure(f) end return debug.info(f, "s") == "[C]" end
    local function newC(c)
        if newcclosure then return newcclosure(c) end
        if clonefunction then return clonefunction(function(...) return c(...) end) end
        return function(...) return c(...) end
    end
    local function newL(c)
        local cloned = clonefunction and clonefunction(function(...) return c(...) end) or function(...) return c(...) end
        return function(...) return cloned(...) end
    end
    -- match the hook's closure TYPE to the original (C vs Lua) so iscclosure(hook) == iscclosure(original) — evades closure-type detection
    local function safe(original, hooked) if isC(original) then return newC(newL(hooked)) else return newL(newC(hooked)) end end

    function Hooks.HookFunction(target, replacement, label)
        local old
        old = hookfunction(target, safe(target, function(...) return replacement(old, ...) end))
        restore[#restore + 1] = keep({ "F", target, old })
        if label then registry[#registry + 1] = { kind = "function", label = label, active = true } end
        return target
    end
    function Hooks.HookMetaMethod(method, replacement, label)
        local old
        old = hookmetamethod(game, method, safe(pcall, function(...) return replacement(old, ...) end))
        if not mmLogged then mmLogged = true; restore[#restore + 1] = keep({ "MM", method, old }) end
        if label then registry[#registry + 1] = { kind = "metamethod", label = label, active = true } end
    end
    function Hooks.RestoreAll()
        for _, h in restore do pcall(function()
            if h[1] == "F" then hookfunction(h[2], h[3]) else hookmetamethod(game, h[2], h[3]) end
        end) end
    end
    function Hooks.Registry() return registry end
end

-- one shared __namecall hook; pages register routes
local NamecallRoutes = {}
local function addNamecallRoute(f) NamecallRoutes[#NamecallRoutes + 1] = f end
local function installNamecall()
    if not USE_NAMECALL then return end
    -- dispatch defined ONCE (no per-namecall closure alloc on this very hot path)
    local function dispatch(self, ...)
        if typeof(self) ~= "Instance" then return false end
        local m = getnamecallmethod(); if not m then return false end
        local M = m:sub(1, 1):upper() .. m:sub(2)
        for _, route in NamecallRoutes do
            local matched, res = route(self, M, ...)
            if matched then return true, res end
        end
        return false
    end
    Hooks.HookMetaMethod("__namecall", function(old, self, ...)
        -- NEVER let a spy bug break a game namecall: on ANY error, fall through to the real call.
        -- Safe from double-firing: routes only perform the real call as their LAST step, so a throw
        -- always happens before the remote actually fires.
        local ok, matched, res = pcall(dispatch, self, ...)
        if ok and matched and res then return table.unpack(res, 1, res.n) end
        return old(self, ...)
    end, "__namecall dispatcher")
end

local function resolveCaller()
    if getcallingscript then
        local ok, scr = pcall(getcallingscript)
        if ok and typeof(scr) == "Instance" then return cloneref(scr) end
    end
    for level = 2, 14 do
        local ok, src = pcall(debug.info, level, "s")
        if not ok or not src then break end
        if src ~= "[C]" then return src end
    end
    return nil
end

--========================  Serializer (ToString)  ==========================--

local ToString = {}
do
    -- Full byte-correct escaping. Unescaped control chars/quotes/backslashes produce
    -- INVALID Lua (a real bug class in TurtleSpy/DexSpy/etc.). Named escapes for the
    -- common ones; everything else gets a 3-digit \ddd so a following digit can't merge.
    -- High bytes (128-255) pass through raw so UTF-8 text stays readable and valid.
    local ESCAPES = { ["\\"] = "\\\\", ["\""] = "\\\"", ["\n"] = "\\n", ["\t"] = "\\t", ["\r"] = "\\r", ["\a"] = "\\a", ["\b"] = "\\b", ["\f"] = "\\f", ["\v"] = "\\v" }  -- \0 omitted on purpose: falls through to 3-digit \000 (a 1-digit \0 could merge with a following ASCII digit)
    local function normalize(s)
        return (s:gsub("[%z\1-\31\127\\\"]", function(c) return ESCAPES[c] or string.format("\\%03d", string.byte(c)) end))
    end
    -- binary-safe: also escapes high bytes (128-255) so buffer payloads copy/paste losslessly
    local function normalizeBin(s)
        return (s:gsub("[%z\1-\31\127-\255\\\"]", function(c) return ESCAPES[c] or string.format("\\%03d", string.byte(c)) end))
    end
    -- Stringify userdata safely: a malicious __tostring on a passed object can crash/detect.
    local function safeTostring(v)
        local ok, mt = pcall(getrawmetatable, v)
        if ok and type(mt) == "table" and rawget(mt, "__tostring") then
            local saved = rawget(mt, "__tostring")
            local restored = pcall(function()
                if fn("setreadonly") then env.setreadonly(mt, false) elseif fn("make_writable") then env.make_writable(mt) end
                rawset(mt, "__tostring", nil)
            end)
            local s = (pcall(tostring, v)) and tostring(v) or ("<" .. typeof(v) .. ">")
            if restored then pcall(function() rawset(mt, "__tostring", saved); if fn("setreadonly") then env.setreadonly(mt, true) end end) end
            return s
        end
        local sok, s = pcall(tostring, v)
        return sok and s or ("<" .. typeof(v) .. ">")
    end
    local function escapePattern(s) return (s:gsub("[%%%.%?%!%,%[%]%(%)%{%}]", "%%%0")) end
    local alphabet = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm_1234567890"
    local RESERVED = {["and"]=1,["break"]=1,["do"]=1,["else"]=1,["elseif"]=1,["end"]=1,["false"]=1,["for"]=1,["function"]=1,["if"]=1,["in"]=1,["local"]=1,["nil"]=1,["not"]=1,["or"]=1,["repeat"]=1,["return"]=1,["then"]=1,["true"]=1,["until"]=1,["while"]=1}
    local function validName(v)
        v = tostring(v)
        if not v or v == "" or tonumber(v:sub(1, 1)) or RESERVED[v] then return false end
        for ch in v:gmatch(".") do if not alphabet:find(escapePattern(ch)) then return false end end
        return true
    end
    local compressMap
    local function getPath(obj, normalNil, dontGetService)
        if not obj then return "nil"
        elseif obj == workspace.Parent or obj == game then return "game"
        elseif not obj.Parent then
            if not normalNil and NIL_FN_NAME then return ("getNil(\"%s\", \"%s\")"):format(normalize(obj.Name), obj.ClassName) end
            return "(nil)[\"" .. normalize(obj.Name) .. "\"]"
        end
        local path = ""
        while obj.Parent do
            -- Portable anchors first: the local player & character resolve by REFERENCE,
            -- not by username, so a generated script runs for anyone (SimpleSpy-style).
            if obj == LocalPlayer then
                path = "game:GetService(\"Players\").LocalPlayer" .. path; break
            elseif LocalPlayer and obj == LocalPlayer.Character then
                path = "game:GetService(\"Players\").LocalPlayer.Character" .. path; break
            elseif (obj.Parent == game or obj.Parent == workspace.Parent) and not dontGetService and pcall(game.GetService, game, obj.ClassName) and game:GetService(obj.ClassName) then
                path = "game:GetService(\"" .. obj.ClassName:gsub(" ", "") .. "\")" .. path; break
            elseif (obj.Parent == game or obj.Parent == workspace.Parent) and obj == workspace or obj == game:GetService("Workspace") then
                path = "workspace" .. path; break
            end
            local siblings, same, index = obj.Parent:GetChildren(), 0, nil
            for i, v in siblings do if v.Name == obj.Name then same += 1; if v == obj then index = i end end end
            if same > 1 and index and index ~= 1 and not dontGetService then
                path = ":GetChildren()[" .. index .. "]" .. path
            else
                local notInstance = typeof(obj.Parent[obj.Name]) ~= "Instance"
                if not validName(obj.Name) or notInstance then
                    path = (notInstance and (":FindFirstChild(\"" .. normalize(obj.Name) .. "\")") or ("[\"" .. normalize(obj.Name) .. "\"]")) .. path
                else path = "." .. obj.Name .. path end
            end
            obj = obj.Parent
        end
        if not obj.Parent and obj ~= game and obj ~= workspace.Parent then
            -- Walked up to a DETACHED (nil-parented) ancestor that isn't the DataModel:
            -- resolve that ancestor via getnilinstances rather than a wrong "game" prefix.
            if not normalNil and NIL_FN_NAME then path = ("getNil(\"%s\", \"%s\")"):format(normalize(obj.Name), obj.ClassName) .. path
            else path = "(nil)[\"" .. normalize(obj.Name) .. "\"]" .. path end
        elseif not obj.Parent then path = "game" .. path end
        return (path:gsub("game:GetService%(\"Workspace\"%)", "workspace"))
    end
    local tostr
    local function convertArg(arg, indent)
        local t = typeof(arg)
        if compressMap and t == "Instance" and compressMap[arg] then return compressMap[arg] end   -- compress map only ever holds instance keys (hoisted vars)
        if t == "string" then
            local ok, decoded = pcall(HttpService.JSONDecode, HttpService, arg)
            if ok and not tonumber(arg) and typeof(decoded) == "table" then
                return "game:GetService(\"HttpService\"):JSONEncode(" .. tostr(decoded, indent) .. ")"
            end
            if #arg == 38 and arg:sub(1,1)=="{" and arg:sub(-1)=="}" and arg:sub(10,10)=="-" and arg:sub(15,15)=="-" and arg:sub(20,20)=="-" and arg:sub(25,25)=="-" then
                return "game:GetService(\"HttpService\"):GenerateGUID(true)"
            elseif #arg == 36 and arg:sub(9,9)=="-" and arg:sub(14,14)=="-" and arg:sub(19,19)=="-" and arg:sub(24,24)=="-" then
                return "game:GetService(\"HttpService\"):GenerateGUID(false)"
            end
            return "\"" .. normalize(arg) .. "\""
        elseif t == "number" then
            if arg == math.huge then return "math.huge"
            elseif arg == -math.huge then return "-math.huge"
            elseif arg ~= arg then return "(0/0)"
            elseif arg == math.pi then return "math.pi"
            elseif math.floor(arg) == arg and math.abs(arg) < 9e15 then   -- < 2^53: still exactly representable, so %d is exact (readable big IDs instead of 1e+16)
                -- exact integer fast-path, but still apply time heuristics
                if math.abs(os.time() - arg) <= 2.5 then return "os.time()"
                elseif math.abs(workspace:GetServerTimeNow() - arg) <= 2.5 then return "math.floor(workspace:GetServerTimeNow())" end
                return string.format("%d", arg)
            elseif math.abs(tick() - arg) <= 2.5 then return "tick()"
            elseif math.abs(workspace:GetServerTimeNow() - arg) <= 2.5 then return "workspace:GetServerTimeNow()"
            elseif math.abs(os.clock() - arg) <= 2.5 then return "os.clock()" end
            -- round-trip-exact float: shortest representation that reads back identically
            local s = string.format("%.14g", arg)
            if tonumber(s) ~= arg then s = string.format("%.17g", arg) end
            return s
        elseif t == "boolean" or t == "nil" then return tostring(arg)
        elseif t == "Color3" then
            local r, g, b = arg.R * 255, arg.G * 255, arg.B * 255
            if math.abs(r-math.floor(r+0.5))<1e-4 and math.abs(g-math.floor(g+0.5))<1e-4 and math.abs(b-math.floor(b+0.5))<1e-4 then
                return string.format("Color3.fromRGB(%d, %d, %d)", math.round(r), math.round(g), math.round(b))
            end
            return string.format("Color3.new(%g, %g, %g)", arg.R, arg.G, arg.B)
        elseif t == "BrickColor" then return "BrickColor.new(\"" .. arg.Name .. "\")"
        elseif t == "UDim"  then return string.format("UDim.new(%g, %d)", arg.Scale, arg.Offset)
        elseif t == "UDim2" then return string.format("UDim2.new(%g, %d, %g, %d)", arg.X.Scale, arg.X.Offset, arg.Y.Scale, arg.Y.Offset)
        elseif t == "Vector3" then return string.format("Vector3.new(%g, %g, %g)", arg.X, arg.Y, arg.Z)
        elseif t == "Vector2" then return string.format("Vector2.new(%g, %g)", arg.X, arg.Y)
        elseif t == "Vector3int16" then return string.format("Vector3int16.new(%d, %d, %d)", arg.X, arg.Y, arg.Z)
        elseif t == "CFrame" then return "CFrame.new(" .. table.concat({ arg:GetComponents() }, ", ") .. ")"
        elseif t == "Ray" then return "Ray.new(" .. convertArg(arg.Origin, indent) .. ", " .. convertArg(arg.Direction, indent) .. ")"
        elseif t == "EnumItem" then return tostring(arg)   -- tostring already yields "Enum.KeyCode.Space"
        elseif t == "Enum" then return tostring(arg)        -- tostring already yields "Enum.KeyCode"
        elseif t == "Vector2int16" then return string.format("Vector2int16.new(%d, %d)", arg.X, arg.Y)
        elseif t == "NumberRange" then return string.format("NumberRange.new(%g, %g)", arg.Min, arg.Max)
        elseif t == "TweenInfo" then return string.format("TweenInfo.new(%g, Enum.EasingStyle.%s, Enum.EasingDirection.%s, %d, %s, %g)", arg.Time, arg.EasingStyle.Name, arg.EasingDirection.Name, arg.RepeatCount, tostring(arg.Reverses), arg.DelayTime)
        elseif t == "Rect" then return string.format("Rect.new(%g, %g, %g, %g)", arg.Min.X, arg.Min.Y, arg.Max.X, arg.Max.Y)
        elseif t == "NumberSequence" then
            local kp = {}
            for _, k in arg.Keypoints do kp[#kp + 1] = string.format("NumberSequenceKeypoint.new(%g, %g, %g)", k.Time, k.Value, k.Envelope) end
            return "NumberSequence.new({ " .. table.concat(kp, ", ") .. " })"
        elseif t == "ColorSequence" then
            local kp = {}
            for _, k in arg.Keypoints do kp[#kp + 1] = string.format("ColorSequenceKeypoint.new(%g, Color3.new(%g, %g, %g))", k.Time, k.Value.R, k.Value.G, k.Value.B) end
            return "ColorSequence.new({ " .. table.concat(kp, ", ") .. " })"
        elseif t == "NumberSequenceKeypoint" then return string.format("NumberSequenceKeypoint.new(%g, %g, %g)", arg.Time, arg.Value, arg.Envelope)
        elseif t == "ColorSequenceKeypoint" then return string.format("ColorSequenceKeypoint.new(%g, Color3.new(%g, %g, %g))", arg.Time, arg.Value.R, arg.Value.G, arg.Value.B)
        elseif t == "PhysicalProperties" then return string.format("PhysicalProperties.new(%g, %g, %g, %g, %g)", arg.Density, arg.Friction, arg.Elasticity, arg.FrictionWeight, arg.ElasticityWeight)
        elseif t == "Region3" then
            local c, s = arg.CFrame.Position, arg.Size
            return string.format("Region3.new(Vector3.new(%g, %g, %g), Vector3.new(%g, %g, %g))", c.X - s.X / 2, c.Y - s.Y / 2, c.Z - s.Z / 2, c.X + s.X / 2, c.Y + s.Y / 2, c.Z + s.Z / 2)
        elseif t == "Region3int16" then return string.format("Region3int16.new(Vector3int16.new(%d, %d, %d), Vector3int16.new(%d, %d, %d))", arg.Min.X, arg.Min.Y, arg.Min.Z, arg.Max.X, arg.Max.Y, arg.Max.Z)
        elseif t == "Axes" then
            local ax = {}
            for _, e in { Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z } do if arg[e.Name] then ax[#ax + 1] = "Enum.Axis." .. e.Name end end
            return "Axes.new(" .. table.concat(ax, ", ") .. ")"
        elseif t == "Faces" then
            local fc = {}
            for _, e in { "Top", "Bottom", "Left", "Right", "Back", "Front" } do if arg[e] then fc[#fc + 1] = "Enum.NormalId." .. e end end
            return "Faces.new(" .. table.concat(fc, ", ") .. ")"
        elseif t == "Font" then return string.format("Font.new(%q, Enum.FontWeight.%s, Enum.FontStyle.%s)", arg.Family, arg.Weight.Name, arg.Style.Name)
        elseif t == "DateTime" then return "DateTime.fromUnixTimestampMillis(" .. arg.UnixTimestampMillis .. ")"
        elseif t == "function" then
            local n = debug.info(arg, "n")
            if n and n ~= "" and env[n] then return n end          -- a known global by name
            local src = debug.info(arg, "s")
            local line = debug.info(arg, "l")
            local info = (n and n ~= "" and ("name=" .. n .. " ") or "") .. "src=" .. tostring(src) .. (line and line ~= -1 and (":" .. line) or "")
            return "function() end --[[ " .. info:gsub("%]%]", "] ]") .. " ]]"
        elseif t == "thread" then return "coroutine.create(function() end)"
        elseif t == "userdata" then return "newproxy()"
        elseif t == "buffer" then
            local s1 = buffer.tostring(arg)
            local zero = true
            for i = 1, #s1 do if string.byte(s1, i) ~= 0 then zero = false; break end end
            -- reuse the corrected normalize() so byte escaping is consistent (3-digit, backslash-safe)
            return (zero and ("buffer.create(" .. #s1 .. ")") or ("buffer.fromstring(\"" .. normalizeBin(s1) .. "\")")) .. " --[[ len " .. #s1 .. " ]]"
        elseif t == "Instance" then return getPath(arg)
        elseif t == "table" then return tostr(arg, indent)
        else
            local obj = env[t]
            if typeof(obj) == "table" and obj.new and pcall(obj.new) and safeTostring(obj.new()) == safeTostring(arg) then return t .. ".new()" end
            return "nil --[[ " .. t .. ": " .. safeTostring(arg):gsub("%]%]", "] ]") .. " ]]"
        end
    end
    local function isArray(tbl)
        if typeof(tbl) ~= "table" then return false end
        local arr, allValid, count = true, true, 0
        for k in tbl do
            if typeof(k) ~= "number" or math.floor(k) ~= k then arr = false; break end
            count = math.max(count, k)
        end
        if arr then
            arr = count >= 1 and #tbl == count; allValid = false   -- require positive dense keys; {[0]=x}/negatives serialize as a dict (else the entry is dropped)
            if arr then for i = 1, count do if tbl[i] == nil then arr = false; break end end end
        else for k in tbl do if typeof(k) ~= "string" or not validName(k) then allValid = false; break end end end
        return arr, allValid, count   -- arr = dense 1..n array; allValid = every key is a bare identifier (key= vs ["key"]); count = max int key
    end
    local parsed = keep({})
    function tostr(tbl, indent)
        indent = tonumber(indent) or 0
        local pad, padNext = string.rep("    ", math.max(indent, 0)), string.rep("    ", math.max(indent, 0) + 1)
        if typeof(tbl) ~= "table" then return convertArg(tbl, math.max(indent, 0)) end
        if indent > 40 then return "{ --[[ …depth capped ]] }" end   -- guard pathological deep nesting from overflowing the stack
        if table.find(parsed, tbl) then return "{} --[[ cyclic ]]" end
        table.insert(parsed, tbl)
        local arr, allValid, count = isArray(tbl)
        local result
        if arr then
            if count == 0 then result = "{}"
            else
                result = "{\n"
                for i = 1, count do result ..= padNext .. tostr(tbl[i], math.max(indent, 0) + 1) .. ",\n" end
                result ..= pad .. "}"
            end
        else
            local empty = true
            for _ in tbl do empty = false; break end
            if empty then result = "{}"
            else
                result = "{\n"
                for k, v in tbl do
                    result ..= padNext .. (allValid and k or "[" .. tostr(k, math.max(indent, 0) + 1) .. "]") .. " = " .. tostr(v, math.max(indent, 0) + 1) .. ",\n"
                end
                result ..= pad .. "}"
            end
        end
        local idx = table.find(parsed, tbl)
        if idx then table.remove(parsed, idx) end
        return result
    end
    function ToString.ToString(...) return tostr(...) end
    function ToString.GetPath(o, a, b) return getPath(o, a, b) end
    ToString.EscapePattern = escapePattern
    ToString.Normalize = normalize
    ToString.NeedsGetNil = function(packed)
        if not NIL_FN_NAME then return false end
        local seen = {}
        local function scan(v, depth)   -- recurse tables too: a nil-parented instance nested in a payload still needs the getNil helper
            local t = typeof(v)
            if t == "Instance" then return not v.Parent
            elseif t == "table" and not seen[v] and depth < 6 then
                seen[v] = true
                for k, val in v do if scan(k, depth + 1) or scan(val, depth + 1) then return true end end
            end
            return false
        end
        for i = 1, (packed.n or #packed) do if scan(packed[i], 0) then return true end end
        return false
    end
    -- Cheap shallow preview (NO deep serialization — this runs on every visible-row render).
    local function quick(v)
        local t = typeof(v)
        if t == "string" then return "\"" .. (#v > 14 and (v:sub(1, 13):gsub("[%c]", " ") .. "…") or v:gsub("[%c]", " ")) .. "\""
        elseif t == "number" or t == "boolean" then return tostring(v)
        elseif t == "nil" then return "nil"
        elseif t == "Instance" then return v.ClassName
        elseif t == "table" then return "{…}"
        elseif t == "buffer" then return "buffer[" .. buffer.len(v) .. "]"
        elseif t == "Vector3" then return "Vector3"
        elseif t == "CFrame" then return "CFrame"
        elseif t == "EnumItem" then return tostring(v)
        else return t end
    end
    ToString.ArgPreview = function(packed)
        local n = packed.n or #packed
        if n == 0 then return "()" end
        local parts = {}
        for i = 1, math.min(n, 4) do parts[i] = quick(packed[i]) end
        return "(" .. table.concat(parts, ", ") .. (n > 4 and ", …" or "") .. ")"
    end
    ToString.SetCompress = function(m) compressMap = m end
    ToString.ValidName = validName
end

local GETNIL = "local function getNil(name, class)\n    for _, v in " .. (NIL_FN_NAME or "getnilinstances") .. "() do\n        if v.ClassName == class and v.Name == name then return v end\n    end\nend\n"   -- use the executor's actual nil-list fn (getnilinstances OR getnils)

--======================  Networking framework detection  ====================--

local function detectFramework(remote, packed)
    local name = remote.Name or ""
    local lname = name:lower()
    local path = ""
    pcall(function() path = remote:GetFullName():lower() end)
    local function has(s) return lname:find(s, 1, true) ~= nil or path:find(s, 1, true) ~= nil end
    if has("bytenet") then return "ByteNet"
    elseif has("bridgenet2") or has("databridge") then return "BridgeNet2"
    elseif has("bridgenet") or lname == "bridge" then return "BridgeNet"
    elseif has("blink") then return "Blink"
    elseif lname:find("^zap") or has("zap_") or has("/zap") then return "Zap"
    elseif has("warp") then return "Warp"
    elseif has("redevent") or has("/red/") or has("red_remote") then return "Red"
    elseif has("knit") or has("/re/") or has("/rf/") or has("knitremotes") then return "Knit"
    elseif has("aeroremote") or has("aero/") then return "Aero"
    elseif has("cmdr") then return "Cmdr" end
    for i = 1, (packed.n or #packed) do if typeof(packed[i]) == "buffer" then return "Buffer" end end
    return "Roblox"
end

local function estimateSize(packed)
    local seen = {}
    local nodes = 0
    local function sz(v)
        nodes += 1
        if nodes > 20000 then return 0 end  -- cap: never let a huge/deep arg hang the drain
        local t = typeof(v)
        if t == "string" then return #v
        elseif t == "buffer" then return buffer.len(v)
        elseif t == "number" then return 8
        elseif t == "boolean" or t == "nil" then return 1
        elseif t == "Vector3" or t == "Color3" then return 12
        elseif t == "Vector2" or t == "UDim2" then return 8
        elseif t == "CFrame" then return 48
        elseif t == "Instance" then return 4
        elseif t == "table" then
            if seen[v] then return 0 end
            seen[v] = true
            local s = 0
            for k, val in v do s += sz(k) + sz(val); if nodes > 20000 then break end end
            return s
        end
        return 4
    end
    local total = 0
    for i = 1, (packed.n or #packed) do total += sz(packed[i]) end
    return total
end

--==============================  Code generation  ==========================--

local Codegen = {}
do
    local function hoistedBody(event, incoming, packed)
        local isFunc = event:IsA("RemoteFunction") or event:IsA("BindableFunction")
        local n = packed.n or #packed
        local instOrder, instSeen, seenTbl = {}, {}, {}
        local function collect(v, depth)
            local t = typeof(v)
            if t == "Instance" then
                if not instSeen[v] and v.Parent and v ~= workspace and v ~= game then instSeen[v] = true; instOrder[#instOrder + 1] = v end
            elseif t == "table" and not seenTbl[v] and depth < 40 then seenTbl[v] = true; for k, val in v do collect(k, depth + 1); collect(val, depth + 1) end end   -- depth cap parity with tostr
        end
        for i = 1, n do collect(packed[i], 0) end
        local servicesSeen, servicesOrder, usesGetNil = {}, {}, false
        local function shortPath(inst)
            ToString.SetCompress(nil)
            local p = ToString.GetPath(inst)
            if p:find("getNil(", 1, true) then usesGetNil = true end
            p = p:gsub("game:GetService%(\"([%w_]+)\"%)", function(svc)
                if not servicesSeen[svc] then servicesSeen[svc] = true; servicesOrder[#servicesOrder + 1] = svc end
                return svc
            end)
            return p
        end
        local remotePath = shortPath(event)
        local instPaths = {}
        for _, inst in instOrder do instPaths[inst] = shortPath(inst) end
        local used = {}
        for _, svc in servicesOrder do used[svc] = true end
        local function uniqueName(base)
            base = tostring(base):gsub("[^%w_]", "")
            if base == "" or tonumber(base:sub(1, 1)) then base = "Variable" end
            if not ToString.ValidName(base) then base = "Variable" end
            local nm, k = base, 1
            while used[nm] do k += 1; nm = base .. k end
            used[nm] = true
            return nm
        end
        local remoteVar = uniqueName(event.Name ~= "" and event.Name or event.ClassName)
        local instVar = {}
        for _, inst in instOrder do instVar[inst] = uniqueName(inst.Name ~= "" and inst.Name or inst.ClassName) end
        local map = {}
        for inst, nm in instVar do map[inst] = nm end
        ToString.SetCompress(map)
        local argParts = {}
        for i = 1, n do argParts[i] = ToString.ToString(packed[i], 1) end
        ToString.SetCompress(nil)
        return {
            isFunc = isFunc, n = n, remoteVar = remoteVar, remotePath = remotePath,
            servicesOrder = servicesOrder, instOrder = instOrder, instVar = instVar,
            instPaths = instPaths, argParts = argParts, usesGetNil = usesGetNil, className = event.ClassName,
        }
    end

    local function callExpr(h, incoming, varName)
        varName = varName or h.remoteVar
        local argText = h.n == 0 and "" or ("\n    " .. table.concat(h.argParts, ",\n    ") .. "\n")
        local cls = h.className
        if cls == "BindableEvent" then return varName .. ":Fire(" .. argText .. ")" end
        if cls == "BindableFunction" then return "local result = " .. varName .. ":Invoke(" .. argText .. ")" end
        if not incoming then
            return h.isFunc and ("local result = " .. varName .. ":InvokeServer(" .. argText .. ")") or (varName .. ":FireServer(" .. argText .. ")")
        elseif h.isFunc then return "getcallbackvalue(" .. varName .. ", \"OnClientInvoke\")(" .. argText .. ")"
        else return "firesignal(" .. varName .. ".OnClientEvent" .. (h.n > 0 and "," or "") .. argText .. ")" end
    end

    local function header(meta)
        local s = "-- IxSpy"
        if meta and (meta.framework or meta.size or meta.time) then
            s ..= "  |  " .. (meta.framework or "Roblox")
                .. (meta.size and ("  |  ~" .. meta.size .. "b") or "")
                .. (meta.time and ("  |  " .. meta.time) or "")
        end
        return s
    end

    -- Readable: hoisted sections (Sigma style)
    function Codegen.Readable(event, incoming, packed, meta)
        local h = hoistedBody(event, incoming, packed)
        local out = {}
        if h.usesGetNil then out[#out + 1] = GETNIL end
        out[#out + 1] = header(meta)
        if #h.servicesOrder > 0 then
            out[#out + 1] = "\n-- Services"
            for _, svc in h.servicesOrder do out[#out + 1] = ("local %s = game:GetService(\"%s\")"):format(svc, svc) end
        end
        out[#out + 1] = "\n-- Remote"
        out[#out + 1] = ("local %s = %s -- %s"):format(h.remoteVar, h.remotePath, h.className)
        if #h.instOrder > 0 then
            out[#out + 1] = "\n-- Variables"
            for _, inst in h.instOrder do out[#out + 1] = ("local %s = %s"):format(h.instVar[inst], h.instPaths[inst]) end
        end
        out[#out + 1] = incoming and "\n-- Received from the server" or "\n-- Sent to the server"
        out[#out + 1] = callExpr(h, incoming)
        return table.concat(out, "\n")
    end

    -- Compact: single inline call
    function Codegen.Compact(event, incoming, packed, meta)
        ToString.SetCompress(nil)
        local isFunc = event:IsA("RemoteFunction") or event:IsA("BindableFunction")
        local n = packed.n or #packed
        local path = ToString.GetPath(event)
        local list = {}
        for i = 1, n do list[i] = ToString.ToString(packed[i], 0):gsub("%s*\n%s*", " ") end
        local args = table.concat(list, ", ")
        local code
        local cls = event.ClassName
        if cls == "BindableEvent" then code = path .. ":Fire(" .. args .. ")"
        elseif cls == "BindableFunction" then code = "local result = " .. path .. ":Invoke(" .. args .. ")"
        elseif not incoming then code = isFunc and ("local result = " .. path .. ":InvokeServer(" .. args .. ")") or (path .. ":FireServer(" .. args .. ")")
        elseif isFunc then code = "getcallbackvalue(" .. path .. ", \"OnClientInvoke\")(" .. args .. ")"
        else code = "firesignal(" .. path .. ".OnClientEvent" .. (n > 0 and ", " .. args or "") .. ")" end
        local pre = ToString.NeedsGetNil(packed) and (GETNIL .. "\n") or ""
        return pre .. header(meta) .. "\n" .. code
    end

    -- Replay: standalone, runnable
    function Codegen.Replay(event, incoming, packed, meta)
        return Codegen.Readable(event, incoming, packed, meta)
    end

    -- Loop: repeat the call forever
    function Codegen.Loop(event, incoming, packed, meta)
        local h = hoistedBody(event, incoming, packed)
        local out = {}
        if h.usesGetNil then out[#out + 1] = GETNIL end
        out[#out + 1] = header(meta) .. "  |  LOOP"
        for _, svc in h.servicesOrder do out[#out + 1] = ("local %s = game:GetService(\"%s\")"):format(svc, svc) end
        out[#out + 1] = ("local %s = %s"):format(h.remoteVar, h.remotePath)
        for _, inst in h.instOrder do out[#out + 1] = ("local %s = %s"):format(h.instVar[inst], h.instPaths[inst]) end
        out[#out + 1] = "while task.wait(0.5) do"
        out[#out + 1] = "    " .. callExpr(h, incoming):gsub("\n", "\n    ")
        out[#out + 1] = "end"
        return table.concat(out, "\n")
    end

    -- Hook template
    function Codegen.Hook(event, incoming, packed, meta)
        local path = (function() ToString.SetCompress(nil); return ToString.GetPath(event) end)()
        local cls = event.ClassName
        local method = (cls == "RemoteFunction" and "InvokeServer") or (cls == "BindableFunction" and "Invoke") or (cls == "BindableEvent" and "Fire") or "FireServer"
        local nm = (event.Name or ""):gsub('[%c"\\]', "")   -- sanitized so a quote/control char in the name can't break the print label
        return header(meta) .. "  |  HOOK TEMPLATE\n"
            .. "local remote = " .. path .. "\n"
            .. "local old\nold = hookfunction(remote." .. method .. ", newcclosure(function(self, ...)\n"
            .. "    if self == remote then\n"
            .. "        print(\"[" .. nm .. "]\", ...)\n"
            .. "        -- return  -- uncomment to block\n"
            .. "    end\n"
            .. "    return old(self, ...)\n"
            .. "end))"
    end

    -- Spoof template
    function Codegen.Spoof(event, incoming, packed, meta)
        local path = (function() ToString.SetCompress(nil); return ToString.GetPath(event) end)()
        return header(meta) .. "  |  SPOOF TEMPLATE\n"
            .. "-- Edit the returned values, then press 'Apply spoof'.\n"
            .. "-- For " .. ((event.Name or ""):gsub("%c", " ")) .. " (" .. event.ClassName .. ")\n"
            .. "return \"spoofed value\""
    end

    Codegen.Modes = { "Readable", "Compact", "Replay", "Loop", "Hook", "Spoof" }
    function Codegen.Generate(mode, event, incoming, packed, meta)
        local f = Codegen[mode] or Codegen.Readable
        local ok, res = pcall(f, event, incoming, packed, meta)
        ToString.SetCompress(nil)
        return ok and res or ("-- codegen error: " .. tostring(res))
    end
end

-- base64 for bytecode — executor-native if present, else pure-Lua (from the Dex decompiler router)
local _b64enc = fn("base64_encode") or fn("base64encode") or (typeof(getfenv().crypt) == "table" and rawget(getfenv().crypt, "base64encode"))
local function b64(data)
    if _b64enc then local ok, r = pcall(_b64enc, data); if ok and type(r) == "string" and #r > 0 then return r end end
    -- pure-Lua base64 fallback: bytes -> bitstring, read 6-bit groups; trailing "0000" zero-pads the last group (extra <6-bit chunk discarded), then "="/"==" by length mod 3
    local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    return ((data:gsub(".", function(x)
        local r, byte = "", x:byte()
        for i = 8, 1, -1 do r = r .. (byte % 2 ^ i - byte % 2 ^ (i - 1) > 0 and "1" or "0") end
        return r
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if #x < 6 then return "" end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0) end
        return b:sub(c + 1, c + 1)
    end) .. ({ "", "==", "=" })[#data % 3 + 1])
end
-- Decompile router: native `decompile` → bytecode→lua.expert → Konstant (matches DEX's router).
local function decompileScript(scr)
    if decompile then local ok, s = pcall(decompile, scr); if ok and type(s) == "string" and #s > 0 then return s end end
    if getscriptbytecode and httpRequestFn then
        local okb, bc = pcall(getscriptbytecode, scr)
        if okb and type(bc) == "string" and #bc > 0 then
            -- lua.expert (base64-encoded bytecode, JSON)
            local okr, resp = pcall(httpRequestFn, { Url = "https://api.lua.expert/decompile", Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode({ script = b64(bc) }) })
            if okr and type(resp) == "table" then
                local status = resp.StatusCode or resp.Status or resp.status_code
                local body = resp.Body or resp.body
                if status and tonumber(status) == 200 and type(body) == "string" and #body > 0 then return body end
            end
            -- Konstant (raw bytecode, text)
            local okr2, resp2 = pcall(httpRequestFn, { Url = "https://api.plusgiant5.com/konstant/decompile", Method = "POST", Body = bc, Headers = { ["Content-Type"] = "text/plain" } })
            if okr2 and type(resp2) == "table" and resp2.Body and #resp2.Body > 0 then
                local st2 = resp2.StatusCode or resp2.Status or resp2.status_code   -- reject error pages (only accept 200, or when no status is reported)
                if not st2 or tonumber(st2) == 200 then return resp2.Body end
            end
        end
    end
    return nil
end
local DECOMPILE_OK = (decompile ~= nil) or (getscriptbytecode ~= nil and httpRequestFn ~= nil)

-- ============================================================================
--  REBIRTH v2 — GUI
-- ============================================================================

local VERSION = "2.1"

--==============================  Theme  ===================================--

local Theme = {
    Bg       = Color3.fromRGB(23, 18, 13),
    Bg2      = Color3.fromRGB(29, 23, 17),
    Panel    = Color3.fromRGB(34, 27, 20),
    Panel2   = Color3.fromRGB(45, 36, 27),
    Panel3   = Color3.fromRGB(59, 48, 36),
    Hover    = Color3.fromRGB(75, 61, 45),
    Accent   = Color3.fromRGB(201, 156, 88),
    Accent2  = Color3.fromRGB(238, 201, 134),
    Text     = Color3.fromRGB(244, 238, 229),
    Sub      = Color3.fromRGB(170, 157, 138),
    Faint    = Color3.fromRGB(122, 108, 89),
    Stroke   = Color3.fromRGB(53, 44, 33),
    StrokeS  = Color3.fromRGB(76, 62, 46),
    Good     = Color3.fromRGB(74, 214, 140),
    Warn     = Color3.fromRGB(255, 196, 84),
    Bad      = Color3.fromRGB(240, 96, 104),
    RemoteEvent = Color3.fromRGB(255, 170, 92),
    Unreliable  = Color3.fromRGB(255, 214, 92),
    RemoteFunc  = Color3.fromRGB(180, 124, 255),
    Bindable    = Color3.fromRGB(96, 200, 255),
    Http        = Color3.fromRGB(96, 232, 168),
    Framework   = Color3.fromRGB(116, 178, 255),
    Hidden      = Color3.fromRGB(255, 104, 148),
}

local FONT      = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local FONT_REG  = Enum.Font.Gotham
local FONT_MONO = Enum.Font.Code
local EASE   = TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local EASE_F = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--==============================  make()  ==================================--

local function make(class, props, children)
    local o = Instance.new(class)
    if props then
        for k, v in props do
            if k ~= "Parent" then
                if k ~= "Text" and type(v) == "string" and v:sub(1, 1) == "@" then o[k] = Theme[v:sub(2)] or Color3.new(1, 0, 1)
                else o[k] = v end
            end
        end
    end
    if children then for _, c in children do c.Parent = o end end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end
local function corner(r) return make("UICorner", { CornerRadius = UDim.new(0, r or 8) }) end
local function stroke(key, th, tr) return make("UIStroke", { Color = "@" .. (key or "Stroke"), Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end
local function pad(t, b, l, r) return make("UIPadding", { PaddingTop = UDim.new(0, t), PaddingBottom = UDim.new(0, b or t), PaddingLeft = UDim.new(0, l or t), PaddingRight = UDim.new(0, r or l or t) }) end
local function vlayout(gap, align) return make("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, gap or 6), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = align or Enum.HorizontalAlignment.Left }) end
local function hlayout(gap, valign) return make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, gap or 6), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = valign or Enum.VerticalAlignment.Center }) end
local function grad(rot, a, b) return make("UIGradient", { Rotation = rot or 90, Color = ColorSequence.new(a, b) }) end
local function shadow(parent, spread, transp)
    return make("ImageLabel", { Parent = parent, BackgroundTransparency = 1, ZIndex = 0, Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = transp or 0.4, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), Size = UDim2.new(1, (spread or 60) * 2, 1, (spread or 60) * 2), Position = UDim2.new(0, -(spread or 60), 0, -(spread or 60) + 6) })
end

local Conns = keep({})
local function track(c) Conns[#Conns + 1] = c; return c end

--==============================  Root / window  ===========================--

local ScreenGui = make("ScreenGui", { Name = "Rebirth", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 1e9 })
do
    local ok = false
    local protectgui = fn("protect_gui") or fn("protectgui")
    local gethui = fn("gethui")
    if gethui then ok = pcall(function() ScreenGui.Parent = gethui() end) and ScreenGui.Parent ~= nil end
    if not ok and protectgui then pcall(protectgui, ScreenGui) end
    if not ok then ok = pcall(function() ScreenGui.Parent = CoreGui end) and ScreenGui.Parent ~= nil end
    if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end
local function viewport() local c = workspace.CurrentCamera; return (c and c.ViewportSize) or Vector2.new(1280, 720) end

local Window = make("Frame", { Name = "Window", Parent = ScreenGui, BackgroundColor3 = "@Bg", BorderSizePixel = 0, Size = UDim2.fromOffset(800, 540), Position = UDim2.new(0.5, -400, 0.5, -270) }, { corner(12) })
-- animated shiny-gold border: a bright streak slowly travels around the window edge
-- WHITE stroke base so the gradient shows at FULL intensity (a colored base multiplies/darkens it)
local winStroke = make("UIStroke", { Parent = Window, Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 0.06, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
local winShine = make("UIGradient", { Parent = winStroke, Rotation = 0, Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    Color3.fromRGB(178, 135, 70)),
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(214, 168, 96)),
    ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(255, 248, 222)),
    ColorSequenceKeypoint.new(0.58, Color3.fromRGB(214, 168, 96)),
    ColorSequenceKeypoint.new(1,    Color3.fromRGB(178, 135, 70)),
}) })
do  -- smooth per-frame shine traveling around the edge + gentle breathe
    local t = 0
    track(RunService.Heartbeat:Connect(function(dt)
        if not winShine.Parent then return end
        if not Window.Visible then return end   -- don't run the per-frame shine while the GUI is hidden
        t += dt
        winShine.Rotation = (t * 70) % 360
        winStroke.Transparency = 0.06 + math.sin(t * 2.5) * 0.05   -- floor ~0.01, so the whole edge stays gold
    end))
end
make("Frame", { Parent = Window, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 120), ZIndex = 0 }, { corner(12), grad(90, Color3.fromRGB(48, 36, 23), Theme.Bg) })

local UIScaleObj = make("UIScale", { Parent = Window, Scale = 1 })
-- DENSITY: render the whole window smaller (text + spacing + elements shrink together,
-- like Sigma Spy). Lower DENSITY = smaller/denser. Tweak this single number to taste.
local DENSITY = 0.78
local function applyScale() local v = viewport(); UIScaleObj.Scale = math.clamp(math.min(v.X / 1360, v.Y / 780), 0.45, 1.0) * DENSITY end
applyScale()
local function clampWindow()
    local v, s = viewport(), Window.AbsoluteSize
    Window.Position = UDim2.fromOffset(math.clamp(Window.Position.X.Offset, 0, math.max(0, v.X - s.X)), math.clamp(Window.Position.Y.Offset, 0, math.max(0, v.Y - s.Y)))
end
do local c = workspace.CurrentCamera; if c then track(c:GetPropertyChangedSignal("ViewportSize"):Connect(function() applyScale(); clampWindow() end)) end end

--==============================  Notifications  ============================--

local Notify
do
    local holder = make("Frame", { Name = "Toasts", Parent = ScreenGui, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(320, 500), BackgroundTransparency = 1, ZIndex = 60 }, {
        make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 9) }),
        make("UIScale", { Scale = UIScaleObj.Scale }),
    })
    function Notify(title, text, colorKey, dur)
        colorKey, dur = colorKey or "Accent", dur or 4
        -- cap simultaneous toasts so a burst can't fill the screen (destroy is safe mid-fade:
        -- the delayed fade guards on card.Parent). Cards are holder's only Frame children, oldest first.
        do local cards = {}; for _, c in holder:GetChildren() do if c:IsA("Frame") then cards[#cards + 1] = c end end
            for i = 1, #cards - 5 do cards[i]:Destroy() end end
        local card = make("Frame", { Parent = holder, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 61 }, {
            corner(10), stroke("StrokeS", 1, 0.4),
            make("Frame", { BackgroundColor3 = "@" .. colorKey, BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, -18), Position = UDim2.fromOffset(9, 9), ZIndex = 62 }, { corner(2) }),
            make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(20, 0), ZIndex = 62 }, {
                pad(12), vlayout(3),
                make("TextLabel", { LayoutOrder = 1, BackgroundTransparency = 1, Font = FONT_BOLD, Text = title, TextColor3 = "@Text", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 62 }),
                (text and text ~= "") and make("TextLabel", { LayoutOrder = 2, BackgroundTransparency = 1, Font = FONT_REG, Text = text, TextColor3 = "@Sub", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 62 }) or nil,
            }),
        })
        card.Position = UDim2.fromOffset(20, 0)
        TweenService:Create(card, EASE, { BackgroundTransparency = 0 }):Play()
        task.delay(dur, function()
            if card and card.Parent then
                local t = TweenService:Create(card, EASE_F, { BackgroundTransparency = 1 })
                t:Play(); t.Completed:Wait(); card:Destroy()
            end
        end)
    end
end

--==============================  Tooltips  ================================--

local addTip
do
    local tip = make("Frame", { Name = "Tooltip", Parent = ScreenGui, BackgroundColor3 = "@Panel3", BorderSizePixel = 0, Visible = false, ZIndex = 200, AutomaticSize = Enum.AutomaticSize.XY }, { corner(6), stroke("StrokeS", 1), pad(5, 5, 8, 8), make("UIScale", { Scale = UIScaleObj.Scale }) })
    local tipLbl = make("TextLabel", { Parent = tip, BackgroundTransparency = 1, Font = FONT, Text = "", TextColor3 = "@Text", TextSize = 12, ZIndex = 201, AutomaticSize = Enum.AutomaticSize.XY })
    local hovered
    function addTip(gui, text)
        track(gui.MouseEnter:Connect(function()
            hovered = gui; tipLbl.Text = text
            local a, s = gui.AbsolutePosition, gui.AbsoluteSize
            if a.Y < 80 then tip.AnchorPoint = Vector2.new(0.5, 0); tip.Position = UDim2.fromOffset(a.X + s.X / 2, a.Y + s.Y + 6)
            else tip.AnchorPoint = Vector2.new(0.5, 1); tip.Position = UDim2.fromOffset(a.X + s.X / 2, a.Y - 6) end
            tip.Visible = true
        end))
        track(gui.MouseLeave:Connect(function() if hovered == gui then hovered = nil; tip.Visible = false end end))
    end
end

--==============================  Components  ===============================--

local UI = {}

function UI.button(parent, o)
    local b = make("TextButton", { Parent = parent, AutoButtonColor = false, BorderSizePixel = 0, Text = "", BackgroundColor3 = o.primary and "@Accent" or "@Panel3", Size = o.size or UDim2.new(0, 0, 0, 30), AutomaticSize = o.autoX ~= false and Enum.AutomaticSize.X or Enum.AutomaticSize.None, LayoutOrder = o.order or 0 }, { corner(o.radius or 8) })
    if o.primary then grad(96, Theme.Accent, Theme.Accent2).Parent = b else stroke("Stroke", 1, 0.35).Parent = b end
    local txtCol = o.primary and Color3.new(1, 1, 1) or ("@" .. (o.color or "Text"))
    local clean = ((o.text or ""):gsub("^[^%w%s]+%s*", ""))
    local lbl
    if o.icon then
        local row = make("Frame", { Parent = b, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0) }, { make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }), make("UIPadding", { PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11) }) })
        make("ImageLabel", { Name = "Ico", Parent = row, BackgroundTransparency = 1, Image = o.icon, ImageColor3 = o.primary and Color3.new(1, 1, 1) or (Theme[o.color or "Text"] or Theme.Text), Size = UDim2.fromOffset(14, 14), LayoutOrder = 1 })
        lbl = make("TextLabel", { Name = "Lbl", Parent = row, BackgroundTransparency = 1, Font = FONT, TextSize = o.textSize or 13, Text = clean, TextColor3 = txtCol, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 2 })
    else
        lbl = make("TextLabel", { Name = "Lbl", Parent = b, BackgroundTransparency = 1, Font = FONT, TextSize = o.textSize or 13, Text = clean, TextColor3 = txtCol, Size = UDim2.new(1, 0, 1, 0) }, { make("UIPadding", { PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11) }) })
    end
    track(b.MouseEnter:Connect(function() TweenService:Create(b, EASE_F, { BackgroundColor3 = o.primary and Theme.Accent or Theme.Hover }):Play() end))
    track(b.MouseLeave:Connect(function() TweenService:Create(b, EASE_F, { BackgroundColor3 = o.primary and Theme.Accent or Theme.Panel3 }):Play() end))
    if o.onClick then track(b.MouseButton1Click:Connect(o.onClick)) end
    return b, lbl
end

function UI.iconBtn(parent, glyph, o)
    o = o or {}
    local b = make("TextButton", { Parent = parent, AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel3", BackgroundTransparency = o.flat and 1 or 0, Size = UDim2.fromOffset(o.sz or 30, o.sz or 30), Text = glyph, Font = FONT_BOLD, TextSize = o.textSize or 15, TextColor3 = o.color and ("@" .. o.color) or "@Text", LayoutOrder = o.order or 0 }, { corner(8) })
    track(b.MouseEnter:Connect(function() TweenService:Create(b, EASE_F, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Hover }):Play() end))
    track(b.MouseLeave:Connect(function() TweenService:Create(b, EASE_F, { BackgroundTransparency = o.flat and 1 or 0, BackgroundColor3 = Theme.Panel3 }):Play() end))
    if o.onClick then track(b.MouseButton1Click:Connect(o.onClick)) end
    return b
end

function UI.toggle(parent, state, onChange)
    local sw = make("TextButton", { Parent = parent, AutoButtonColor = false, Text = "", BorderSizePixel = 0, BackgroundColor3 = state and "@Accent" or "@Panel3", Size = UDim2.fromOffset(44, 24) }, {
        corner(12), make("Frame", { Name = "Knob", BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(245, 245, 252), Size = UDim2.fromOffset(18, 18), Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }, { corner(9) }),
    })
    local cur = state
    local function set(v, a) cur = v; TweenService:Create(sw, a and EASE_F or EASE, { BackgroundColor3 = v and Theme.Accent or Theme.Panel3 }):Play(); TweenService:Create(sw.Knob, a and EASE_F or EASE, { Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }):Play() end
    track(sw.MouseButton1Click:Connect(function() set(not cur, true); if onChange then onChange(cur) end end))
    return sw, function(v) set(v, false) end
end

-- segmented control with a sliding highlight (used for direction)
function UI.segmented(parent, opts, current, onPick)
    local seg = make("Frame", { Parent = parent, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Size = UDim2.fromOffset(#opts * 64, 30), LayoutOrder = 0 }, { corner(8), stroke("Stroke", 1, 0.4) })
    local w = 1 / #opts
    local hl = make("Frame", { Parent = seg, BackgroundColor3 = "@Accent", BorderSizePixel = 0, Size = UDim2.new(w, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2) }, { corner(6), grad(96, Theme.Accent, Theme.Accent2) })
    local idx = 1
    for i, opt in opts do if opt == current then idx = i end end
    hl.Position = UDim2.new((idx - 1) * w, 2, 0, 2)
    for i, opt in opts do
        local lbl
        local b = make("TextButton", { Parent = seg, AutoButtonColor = false, BackgroundTransparency = 1, Text = "", Size = UDim2.new(w, 0, 1, 0), Position = UDim2.new((i - 1) * w, 0, 0, 0) }, {})
        lbl = make("TextLabel", { Parent = b, BackgroundTransparency = 1, Font = FONT, TextSize = 12, Text = opt, TextColor3 = i == idx and Theme.Text or Theme.Sub, Size = UDim2.new(1, 0, 1, 0) })
        track(b.MouseButton1Click:Connect(function()
            idx = i
            TweenService:Create(hl, EASE, { Position = UDim2.new((i - 1) * w, 2, 0, 2) }):Play()
            for _, c in seg:GetChildren() do if c:IsA("TextButton") then c:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.Sub end end
            lbl.TextColor3 = Theme.Text
            if onPick then onPick(opt) end
        end))
    end
    return seg
end

function UI.dropdown(parent, opts, current, onPick, width)
    local btn = make("TextButton", { Parent = parent, AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel2", Size = UDim2.fromOffset(width or 130, 30), Text = "", LayoutOrder = 0 }, { corner(8), stroke("Stroke", 1, 0.4) })
    local lbl = make("TextLabel", { Parent = btn, BackgroundTransparency = 1, Font = FONT, TextSize = 12, Text = tostring(current), TextColor3 = "@Text", TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -30, 1, 0) })
    make("TextLabel", { Parent = btn, BackgroundTransparency = 1, Font = FONT_BOLD, TextSize = 11, Text = "v", TextColor3 = "@Sub", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(12, 12) })
    local pop, backdrop
    local function close() if backdrop then backdrop:Destroy(); backdrop = nil end if pop then pop:Destroy(); pop = nil end end
    track(btn.MouseButton1Click:Connect(function()
        if pop then close(); return end
        local abs, sz = btn.AbsolutePosition, btn.AbsoluteSize
        backdrop = make("TextButton", { Parent = ScreenGui, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 79 })   -- click-outside closes
        backdrop.MouseButton1Click:Connect(close)
        local ph = (math.min(#opts, 9) * 28 + 8) * UIScaleObj.Scale
        local vpY = viewport().Y
        local py = abs.Y + sz.Y + 5; if py + ph > vpY then py = math.max(0, abs.Y - ph - 5) end   -- flip above if it would spill off the bottom
        pop = make("Frame", { Parent = ScreenGui, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Position = UDim2.fromOffset(abs.X, py), Size = UDim2.fromOffset(width or 130, math.min(#opts, 9) * 28 + 8), ZIndex = 80, ClipsDescendants = true }, { corner(8), stroke("StrokeS", 1), pad(4), make("UIScale", { Scale = UIScaleObj.Scale }) })
        local sc = make("ScrollingFrame", { Parent = pop, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 3, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 80 }, { vlayout(2) })
        for _, opt in opts do
            local o = make("TextButton", { Parent = sc, AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel2", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Text = tostring(opt), Font = FONT, TextSize = 12, TextColor3 = "@Text", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 81 }, { corner(6), pad(0, 0, 9, 9) })
            track(o.MouseEnter:Connect(function() o.BackgroundTransparency = 0; o.BackgroundColor3 = Theme.Hover end))
            track(o.MouseLeave:Connect(function() o.BackgroundTransparency = 1 end))
            track(o.MouseButton1Click:Connect(function() lbl.Text = tostring(opt); close(); if onPick then onPick(opt) end end))
        end
    end))
    return btn, function(v) lbl.Text = tostring(v) end
end

-- Menu button (Cobalt-style): an icon+label+caret button that opens an anchored
-- dropdown of option rows on click. Collapses a long action row into a few tidy
-- groups. Options: { text, icon?, onClick, tint?("Bad"/"Good"/"Warn"/Color3),
-- condition?()->bool, closeOnClick? }. `o.items` may be a table or a function
-- (rebuilt each open, so condition/labels stay live).
function UI.menuButton(parent, o)
    o = o or {}
    local b = make("TextButton", { Parent = parent, AutoButtonColor = false, BorderSizePixel = 0, Text = "", BackgroundColor3 = "@Panel3", Size = o.size or UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = o.order or 0 }, { corner(o.radius or 8), stroke("Stroke", 1, 0.35) })
    local rowf = make("Frame", { Parent = b, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0) }, { make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }), make("UIPadding", { PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 9) }) })
    if o.icon then make("ImageLabel", { Parent = rowf, BackgroundTransparency = 1, Image = o.icon, ImageColor3 = Theme[o.color or "Text"] or Theme.Text, Size = UDim2.fromOffset(14, 14), LayoutOrder = 1 }) end
    make("TextLabel", { Parent = rowf, BackgroundTransparency = 1, Font = FONT, TextSize = o.textSize or 12, Text = o.text or "", TextColor3 = "@" .. (o.color or "Text"), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 2 })
    make("ImageLabel", { Name = "Caret", Parent = rowf, BackgroundTransparency = 1, Image = "rbxassetid://10709790948", ImageColor3 = Theme.Sub, Size = UDim2.fromOffset(11, 11), LayoutOrder = 3 })
    track(b.MouseEnter:Connect(function() TweenService:Create(b, EASE_F, { BackgroundColor3 = Theme.Hover }):Play() end))
    track(b.MouseLeave:Connect(function() TweenService:Create(b, EASE_F, { BackgroundColor3 = Theme.Panel3 }):Play() end))

    local function tintOf(t)
        if typeof(t) == "Color3" then return t end
        if type(t) == "string" then return Theme[t] or Theme.Text end
        return Theme.Text
    end
    local pop, backdrop
    local function close() if backdrop then backdrop:Destroy(); backdrop = nil end if pop then pop:Destroy(); pop = nil end end
    track(b.MouseButton1Click:Connect(function()
        if pop then close(); return end
        local items = typeof(o.items) == "function" and o.items() or o.items or {}
        local shown = {}
        for _, it in ipairs(items) do if not (it.condition and not it.condition()) then shown[#shown + 1] = it end end
        if #shown == 0 then return end
        local abs, sz = b.AbsolutePosition, b.AbsoluteSize
        local w = o.menuWidth or 188
        backdrop = make("TextButton", { Parent = ScreenGui, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 89 })
        track(backdrop.MouseButton1Click:Connect(close))
        pop = make("Frame", { Parent = ScreenGui, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Position = UDim2.fromOffset(abs.X, abs.Y + sz.Y + 5), Size = UDim2.fromOffset(w, #shown * 30 + 6), ZIndex = 90 }, { corner(8), stroke("StrokeS", 1), pad(3, 3, 3, 3), make("UIScale", { Scale = UIScaleObj.Scale }), vlayout(2) })
        for _, it in ipairs(shown) do
            local txt = typeof(it.text) == "function" and it.text() or it.text
            local ico = it.icon and (typeof(it.icon) == "function" and it.icon() or it.icon)
            local col = tintOf(it.tint)
            local oi = make("TextButton", { Parent = pop, AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Hover", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), Text = "", ZIndex = 91 }, { corner(6) })
            if ico then make("ImageLabel", { Parent = oi, BackgroundTransparency = 1, Image = ico, ImageColor3 = col, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0), Size = UDim2.fromOffset(14, 14), ZIndex = 91 }) end
            make("TextLabel", { Parent = oi, BackgroundTransparency = 1, Font = FONT, TextSize = 13, Text = txt, TextColor3 = col, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(ico and 31 or 11, 0), Size = UDim2.new(1, -(ico and 39 or 18), 1, 0), ZIndex = 91 })
            track(oi.MouseEnter:Connect(function() oi.BackgroundTransparency = 0 end))
            track(oi.MouseLeave:Connect(function() oi.BackgroundTransparency = 1 end))
            track(oi.MouseButton1Click:Connect(function()
                local fn2 = it.onClick
                if it.closeOnClick ~= false then close() end
                if fn2 then fn2() end
            end))
        end
    end))
    return b, { close = close }
end

function UI.input(parent, placeholder, onChange, o)
    o = o or {}
    local wrap = make("Frame", { Parent = parent, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Size = o.size or UDim2.new(1, 0, 0, 30), LayoutOrder = o.order or 0 }, { corner(8), stroke("Stroke", 1, 0.4) })
    make("ImageLabel", { Parent = wrap, BackgroundTransparency = 1, Image = "rbxassetid://10734943674", ImageColor3 = Theme.Faint, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0), Size = UDim2.fromOffset(14, 14) })
    local box = make("TextBox", { Parent = wrap, BackgroundTransparency = 1, Font = FONT, TextSize = 13, PlaceholderText = placeholder or "", Text = "", TextColor3 = "@Text", PlaceholderColor3 = "@Faint", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -36, 1, 0) })
    local s = wrap:FindFirstChildOfClass("UIStroke")
    track(box.Focused:Connect(function() if s then TweenService:Create(s, EASE_F, { Color = Theme.Accent, Transparency = 0 }):Play() end end))
    track(box.FocusLost:Connect(function() if s then TweenService:Create(s, EASE_F, { Color = Theme.Stroke, Transparency = 0.4 }):Play() end end))
    if onChange then track(box:GetPropertyChangedSignal("Text"):Connect(function() onChange(box.Text) end)) end
    return box
end

function UI.chip(parent, text, colorKey, o)
    o = o or {}
    local c = make("Frame", { Parent = parent, BackgroundColor3 = "@" .. (colorKey or "Panel3"), BackgroundTransparency = 0.82, BorderSizePixel = 0, Size = UDim2.fromOffset(0, o.h or 18), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = o.order or 0 }, { corner(6) })
    make("TextLabel", { Parent = c, BackgroundTransparency = 1, Font = FONT, TextSize = o.textSize or 11, Text = text, TextColor3 = "@" .. (colorKey or "Sub"), Size = UDim2.new(1, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X }, { make("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }) })
    return c
end

--==============================  Stats  ===================================--

local Stats = { total = 0, sec = 0, perSec = 0, history = {}, freq = {}, fw = {} }
for i = 1, 60 do Stats.history[i] = 0 end
local function statBump(e)
    Stats.total += 1; Stats.sec += 1
    Stats.freq[e.name] = (Stats.freq[e.name] or 0) + 1
    Stats.fw[e.framework] = (Stats.fw[e.framework] or 0) + 1
end
local function callPasses(isExec)
    local m = Settings.Log_which_calls
    if m == 2 then return true elseif m == 1 then return not isExec elseif m == 3 then return isExec end
    return true
end

--==============================  Virtual list  ============================--
-- Each pooled row holds the live entry object it is currently bound to (rowItem),
-- so a click always resolves to exactly what is on screen — no id indirection,
-- no stale lookups. Windowed render; coalesced to one pass per frame.

local function VirtualList(parent, rowH, buildRow, bindRow, onClick)
    local self = { items = {} }
    local scroll = make("ScrollingFrame", { Parent = parent, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 5, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, ClipsDescendants = true }, { pad(6, 6, 6, 6) })
    local content = make("Frame", { Parent = scroll, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 0) })
    local pool, active, rowItem = {}, {}, {}
    local dirty = true
    local function render()
        local n = #self.items
        content.Size = UDim2.new(1, -12, 0, math.max(n * rowH, 1))
        scroll.CanvasSize = UDim2.new(0, 0, 0, n * rowH + 12)
        local top, vh = scroll.CanvasPosition.Y, scroll.AbsoluteSize.Y
        local first = math.max(1, math.floor(top / rowH))
        local last = math.min(n, first + math.ceil(vh / rowH) + 2)
        for i, row in active do if i < first or i > last then row.Visible = false; rowItem[row] = nil; pool[#pool + 1] = row; active[i] = nil end end
        for i = first, last do
            local row = active[i]
            if not row then
                row = table.remove(pool)
                if not row then
                    row = buildRow()
                    track(row.MouseButton1Click:Connect(function() local it = rowItem[row]; if it and onClick then onClick(it) end end))
                end
                row.Parent = content
                active[i] = row
            end
            row.Position = UDim2.fromOffset(0, (i - 1) * rowH)
            row.Visible = true
            rowItem[row] = self.items[i]
            bindRow(row, self.items[i], i)
        end
    end
    track(scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function() dirty = true end))
    track(scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() dirty = true end))
    function self.setItems(t) self.items = t; dirty = true end
    function self.invalidate() dirty = true end
    function self.tick() if dirty then dirty = false; render() end end
    function self.atTop() return scroll.CanvasPosition.Y < rowH end
    function self.toTop() scroll.CanvasPosition = Vector2.new(0, 0) end
    self.scroll = scroll
    return self
end

--==============================  Topbar  ==================================--

-- ONE clean header bar — R logo + brand on the left; live metadata · Capturing · window
-- controls on the right, auto-laid-out with even gaps so nothing feels crammed.
local Topbar = make("Frame", { Name = "Topbar", Parent = Window, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 50) }, {
    make("Frame", { BackgroundColor3 = "@Stroke", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1) }),
})
make("Frame", { Parent = Topbar, BackgroundColor3 = "@Accent", BorderSizePixel = 0, ClipsDescendants = true, AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(28, 28), Position = UDim2.new(0, 18, 0.5, 0) }, {
    corner(14), grad(55, Theme.Accent, Theme.Accent2),
    make("Frame", { Name = "Gloss", BackgroundColor3 = Color3.fromRGB(255, 250, 235), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0.55, 0) }, { make("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) }) }) }),
    make("TextLabel", { BackgroundTransparency = 1, Font = FONT_BOLD, Text = "R", TextColor3 = Color3.fromRGB(34, 26, 15), TextSize = 17, Size = UDim2.new(1, 0, 1, 0) }),
})
make("TextLabel", { Parent = Topbar, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Rebirth", TextColor3 = "@Text", TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 56, 0.5, 0), Size = UDim2.fromOffset(82, 24) })
make("TextLabel", { Parent = Topbar, BackgroundTransparency = 1, Font = FONT, Text = "v" .. VERSION, TextColor3 = "@Faint", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 132, 0.5, 0), Size = UDim2.fromOffset(50, 20) })

local rightCluster = make("Frame", { Parent = Topbar, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 30) }, {
    make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 16), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }),
})
local tsMeta = make("TextLabel", { Parent = rightCluster, BackgroundTransparency = 1, Font = FONT_MONO, Text = "—", TextColor3 = "@Faint", TextSize = 11, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 1 })

-- live "Capturing" badge with an animated equalizer
local statusPill = make("Frame", { Parent = rightCluster, BackgroundColor3 = "@Good", BackgroundTransparency = 0.82, BorderSizePixel = 0, Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2 }, { corner(13), stroke("Good", 1, 0.5), make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12) }), hlayout(7) })
local statusWave = make("Frame", { Parent = statusPill, BackgroundTransparency = 1, Size = UDim2.fromOffset(15, 14), LayoutOrder = 1 }, { make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }) })
local waveBars = {}
for i = 1, 4 do waveBars[i] = make("Frame", { Parent = statusWave, BackgroundColor3 = "@Good", BorderSizePixel = 0, Size = UDim2.fromOffset(2, ({ 6, 11, 7, 13 })[i]), LayoutOrder = i }, { corner(1) }) end
local statusLbl = make("TextLabel", { Parent = statusPill, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Capturing", TextColor3 = "@Good", TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 2 })
local function setStatusColor(c)
    statusPill.BackgroundColor3 = c
    statusLbl.TextColor3 = c
    for _, b in waveBars do b.BackgroundColor3 = c end
    local s = statusPill:FindFirstChildOfClass("UIStroke"); if s then s.Color = c end
end
do  -- equalizer animation (reads as a live capture feed)
    task.spawn(function()
        local frames = { { 6, 11, 7, 13 }, { 12, 5, 13, 7 }, { 7, 13, 6, 11 }, { 13, 7, 11, 5 } }
        local k = 0
        while statusWave and statusWave.Parent do
            if Window.Visible then   -- don't spawn tweens while the GUI is hidden (keybind toggled off)
                k = (k % #frames) + 1
                for i, b in waveBars do TweenService:Create(b, TweenInfo.new(0.30, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(2, frames[k][i]) }):Play() end
            end
            task.wait(0.32)
        end
    end)
end

-- window controls (minimize / close) — in the cluster, evenly spaced
local function topCtl(glyph, colorKey, order)
    local b = make("TextButton", { Parent = rightCluster, AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel3", BackgroundTransparency = 1, Size = UDim2.fromOffset(28, 28), Text = glyph, Font = FONT_BOLD, TextSize = 15, TextColor3 = "@" .. colorKey, LayoutOrder = order }, { corner(8) })
    track(b.MouseEnter:Connect(function() TweenService:Create(b, EASE_F, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Hover }):Play() end))
    track(b.MouseLeave:Connect(function() TweenService:Create(b, EASE_F, { BackgroundTransparency = 1 }):Play() end))
    return b
end
local minBtn = topCtl("-", "Sub", 3)
local closeBtn = topCtl("X", "Bad", 4)
addTip(minBtn, "Minimize"); addTip(closeBtn, "Close · unload spy")

-- drag — snapshot the window's ACTUAL pixel position (AbsolutePosition) at grab time.
-- The window starts centered with scale components (0.5,…); reading .Offset alone
-- dropped the scale and clamped the first drag to the top-left corner. Absolute pos
-- has no scale component, so the first move can't jump.
do
    local dragging, ds, sp, di
    track(Topbar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging, ds, sp = true, i.Position, Window.AbsolutePosition; track(i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)) end
    end))
    track(Topbar.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end end))
    track(UserInputService.InputChanged:Connect(function(i)
        if i == di and dragging then
            local d = i.Position - ds; local v, s = viewport(), Window.AbsoluteSize
            Window.Position = UDim2.fromOffset(math.clamp(sp.X + d.X, 0, math.max(0, v.X - s.X)), math.clamp(sp.Y + d.Y, 0, math.max(0, v.Y - s.Y)))
        end
    end))
end

local contentArea = make("Frame", { Name = "Content", Parent = Window, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 50), Size = UDim2.new(1, 0, 1, -74) })

-- status bar (bottom)
local statusBar = make("Frame", { Name = "StatusBar", Parent = Window, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 24) }, { make("Frame", { BackgroundColor3 = "@Stroke", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1) }) })
make("Frame", { Parent = statusBar, BackgroundColor3 = "@Good", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(14, 12), Size = UDim2.fromOffset(7, 7) }, { corner(4) })
make("TextLabel", { Parent = statusBar, BackgroundTransparency = 1, Font = FONT, Text = "Connected to Roblox", TextColor3 = "@Sub", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(0, 220, 1, 0) })
-- (FPS / Ping moved to the title strip at the top)

local minimized = false
local restoreSize = UDim2.fromOffset(800, 540)
local function doMinimize()
    minimized = not minimized
    if minimized then restoreSize = Window.Size end            -- remember the (possibly resized) size
    contentArea.Visible = not minimized
    statusBar.Visible = not minimized
    minBtn.Text = minimized and "+" or "-"                     -- glyph reflects state (restore vs minimize)
    TweenService:Create(Window, EASE, { Size = minimized and UDim2.fromOffset(restoreSize.X.Offset, 50) or restoreSize }):Play()
end
track(minBtn.MouseButton1Click:Connect(doMinimize))

-- resize grip
do
    local grip = make("TextButton", { Parent = Window, AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -5, 1, -5), Size = UDim2.fromOffset(18, 18), Text = "◢", Font = FONT_BOLD, TextSize = 11, TextColor3 = "@Faint", ZIndex = 6 })
    addTip(grip, "Drag to resize")
    local rz, sp2, ss
    track(grip.InputBegan:Connect(function(i) if minimized then return end if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then rz, sp2, ss = true, i.Position, Vector2.new(Window.Size.X.Offset, Window.Size.Y.Offset); track(i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then rz = false end end)) end end))
    track(UserInputService.InputChanged:Connect(function(i)
        if rz and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local sc = UIScaleObj.Scale; local d = (i.Position - sp2) / sc; local v = viewport()
            Window.Size = UDim2.fromOffset(math.clamp(ss.X + d.X, 640, math.max(640, v.X / sc)), math.clamp(ss.Y + d.Y, 400, math.max(400, v.Y / sc)))
        end
    end))
end

--==============================  Nav rail  ================================--

-- top horizontal nav strip (replaces the left rail) — frees the full width for the spy
local navStrip = make("Frame", { Name = "NavStrip", Parent = contentArea, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Position = UDim2.fromOffset(12, 4), Size = UDim2.new(1, -24, 0, 34), ClipsDescendants = true }, { corner(10), stroke("Stroke", 1, 0.5) })
local navRow = make("Frame", { Parent = navStrip, BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -190, 1, 0) }, { make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }) })
local railIndicator = make("Frame", { Parent = navStrip, BackgroundColor3 = "@Accent", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Size = UDim2.fromOffset(40, 3), Position = UDim2.new(0, 12, 1, -1), ZIndex = 3 }, { corner(2), grad(0, Theme.Accent, Theme.Accent2) })
local PageHolder = make("Frame", { Name = "Pages", Parent = contentArea, BackgroundColor3 = "@Panel", BorderSizePixel = 0, Position = UDim2.fromOffset(12, 44), Size = UDim2.new(1, -24, 1, -52) }, { corner(12), stroke("Stroke", 1, 0.5) })

local Pages, navBtns, activePage = {}, {}, nil
local function selectPage(name)
    activePage = name
    for n, p in Pages do p.Visible = (n == name) end
    for n, b in navBtns do
        local on = n == name
        TweenService:Create(b, EASE_F, { BackgroundTransparency = on and 0 or 1 }):Play()
        b.Lbl.TextColor3 = on and Theme.Text or Theme.Sub
        local ico = b:FindFirstChild("Icon"); if ico then ico.ImageColor3 = on and Theme.Accent or Theme.Sub end   -- active tab's icon pops, inactive dims with its label
        if on then
            task.defer(function()
                local sc = math.max(UIScaleObj.Scale, 0.01)
                local x = (b.AbsolutePosition.X - navStrip.AbsolutePosition.X) / sc
                local w = b.AbsoluteSize.X / sc
                TweenService:Create(railIndicator, EASE, { Position = UDim2.new(0, x, 1, -1), Size = UDim2.fromOffset(w, 3) }):Play()
            end)
        end
    end
end
local navOrder = 0
-- real Lucide icons (verified asset IDs from the Fluent/Lucide library), tinted to theme
local NAV_ICON = {
    dashboard = "rbxassetid://10723424646",  -- layout-dashboard
    remote    = "rbxassetid://10734931596",  -- radio
    event     = "rbxassetid://10709752035",  -- activity
    http      = "rbxassetid://10723404337",  -- globe
    settings  = "rbxassetid://10734950309",  -- settings
    scripts   = "rbxassetid://10723356507",  -- file-code
    explorer  = "rbxassetid://10723387085",  -- folder-tree
}
local function addNav(name, kind, label)
    navOrder += 1
    local b = make("TextButton", { Name = name, Parent = navRow, AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel3", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, -8), Text = "", LayoutOrder = navOrder }, {
        corner(8),
        make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 7), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }),
        make("UIPadding", { PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 12) }),
        make("ImageLabel", { Name = "Icon", BackgroundTransparency = 1, Image = NAV_ICON[kind] or "", ImageColor3 = Theme.Accent, Size = UDim2.fromOffset(15, 15), LayoutOrder = 1 }),
        make("TextLabel", { Name = "Lbl", BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = "@Sub", TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), LayoutOrder = 2 }),
    })
    track(b.MouseEnter:Connect(function() if activePage ~= name then TweenService:Create(b, EASE_F, { BackgroundTransparency = 0.9 }):Play() end end))
    track(b.MouseLeave:Connect(function() if activePage ~= name then TweenService:Create(b, EASE_F, { BackgroundTransparency = 1 }):Play() end end))
    track(b.MouseButton1Click:Connect(function() selectPage(name) end))
    navBtns[name] = b
    return b
end
local function newPage(name)
    local p = make("Frame", { Name = name, Parent = PageHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false }, { pad(14) })
    Pages[name] = p
    return p
end
-- profile (right side of the nav strip): avatar + blurred name
do
    local profile = make("Frame", { Parent = navStrip, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(150, 30) })
    make("ImageLabel", { Parent = profile, BackgroundColor3 = "@Panel3", BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(26, 26), Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=48&h=48", ScaleType = Enum.ScaleType.Crop }, { corner(8) })
    make("TextLabel", { Parent = profile, BackgroundTransparency = 1, Font = FONT_BOLD, Text = LocalPlayer.DisplayName, TextColor3 = "@Sub", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -34, 0.5, 0), Size = UDim2.fromOffset(110, 16) })
    -- privacy: frosted overlay blurs the name (avatar/face stays visible)
    make("Frame", { Parent = profile, BackgroundColor3 = "@Bg2", BackgroundTransparency = 0.12, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -34, 0.5, 0), Size = UDim2.fromOffset(112, 18), ZIndex = 5 }, { corner(5) })
end

local function teardown()
    Hooks.RestoreAll()
    for _, c in Conns do pcall(function() c:Disconnect() end) end
    ScreenGui:Destroy()
    if shared then shared.__IxSpyRebirth = nil end
end
track(closeBtn.MouseButton1Click:Connect(teardown))

--==============================  Highlighter  =============================--

local highlight
do
    local KW, GL = {}, {}
    for _, w in { "and","break","do","else","elseif","end","false","for","function","if","in","local","nil","not","or","repeat","return","then","true","until","while","continue","self" } do KW[w] = true end
    for _, w in { "game","workspace","script","Enum","Color3","Vector3","Vector2","CFrame","UDim","UDim2","Instance","BrickColor","Ray","Rect","TweenInfo","NumberRange","NumberSequence","ColorSequence","math","table","string","task","os","coroutine","buffer","unpack","getNil","getnilinstances","getcallbackvalue","firesignal","request","pcall","select","hookfunction","newcclosure","print","Font","DateTime" } do GL[w] = true end
    local C = { c = "#5a6378", s = "#9ed27a", n = "#e0b262", k = "#c98cff", g = "#62a8e8", p = "#9aa0b4" }
    local function esc(s) return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;")) end
    local function span(c, t) return "<font color=\"" .. c .. "\">" .. esc(t) .. "</font>" end
    function highlight(code)
        -- skip the per-char highlighter on very large sources (huge decompiled scripts) to avoid a freeze
        if not Settings.Highlight_syntax or #code > 60000 then return esc(code) end
        local out, i, n = {}, 1, #code
        while i <= n do
            local c = code:sub(i, i)
            if c == "-" and code:sub(i + 1, i + 1) == "-" then
                local eq = code:match("^%-%-%[(=*)%[", i); local stop
                if eq then local cl = "]" .. eq .. "]"; local e = code:find(cl, i + 4, true); stop = e and (e + #cl - 1) or n
                else local e = code:find("\n", i); stop = e and e - 1 or n end
                out[#out + 1] = span(C.c, code:sub(i, stop)); i = stop + 1
            elseif c == "\"" or c == "'" then
                local j = i + 1
                while j <= n do local cj = code:sub(j, j); if cj == "\\" then j += 2 elseif cj == c or cj == "\n" then j += 1; break else j += 1 end end
                out[#out + 1] = span(C.s, code:sub(i, j - 1)); i = j
            elseif c:match("%d") or (c == "." and code:sub(i + 1, i + 1):match("%d")) then
                local j = i; while j <= n and code:sub(j, j):match("[%w%.xXeE]") do j += 1 end
                out[#out + 1] = span(C.n, code:sub(i, j - 1)); i = j
            elseif c:match("[%a_]") then
                local j = i; while j <= n and code:sub(j, j):match("[%w_]") do j += 1 end
                local w = code:sub(i, j - 1)
                out[#out + 1] = KW[w] and span(C.k, w) or GL[w] and span(C.g, w) or esc(w); i = j
            elseif c:match("[%p]") then out[#out + 1] = span(C.p, c); i += 1
            else out[#out + 1] = esc(c); i += 1 end
        end
        return table.concat(out)
    end
end

-- read-only, line-numbered, horizontally+vertically scrolling code display
local function codeView(parent)
    local frame = make("Frame", { Parent = parent, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true }, { corner(10), stroke("Stroke", 1) })
    local gutBg = make("Frame", { Parent = frame, BackgroundColor3 = "@Panel", BorderSizePixel = 0, Size = UDim2.new(0, 44, 1, 0), ClipsDescendants = true })
    local gutter = make("TextLabel", { Parent = gutBg, BackgroundTransparency = 1, Font = FONT_MONO, TextSize = 16, TextColor3 = "@Faint", TextXAlignment = Enum.TextXAlignment.Right, TextYAlignment = Enum.TextYAlignment.Top, Text = "1", Position = UDim2.fromOffset(0, 12), Size = UDim2.new(1, -9, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
    local scroll = make("ScrollingFrame", { Parent = frame, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(50, 0), Size = UDim2.new(1, -50, 1, 0), ScrollBarThickness = 5, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.XY, ScrollingDirection = Enum.ScrollingDirection.XY, ClipsDescendants = true })
    local box = make("TextLabel", { Parent = scroll, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0), Font = FONT_MONO, TextSize = 16, RichText = true, TextColor3 = "@Text", TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = false, Text = "" }, { pad(12, 12, 8, 12) })
    track(scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function() gutter.Position = UDim2.fromOffset(0, 12 - scroll.CanvasPosition.Y) end))
    local api = { Raw = "" }
    function api.set(raw, keepScroll)
        if keepScroll and raw == api.Raw then return end   -- live refresh, content unchanged: don't touch scroll
        api.Raw = raw or ""
        box.Text = highlight(api.Raw)
        local lines = select(2, api.Raw:gsub("\n", "\n")) + 1
        local t = table.create(lines); for i = 1, lines do t[i] = i end
        gutter.Text = table.concat(t, "\n")
        if not keepScroll then scroll.CanvasPosition = Vector2.new(0, 0) end   -- only jump to top on explicit (re)select
    end
    return api
end

--==============================  Runner overlay  ==========================--
-- All editing/running happens HERE, fully decoupled from the log list & detail.

local Runner
do
    local dim = make("Frame", { Name = "RunnerDim", Parent = ScreenGui, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 90 })
    local panel = make("Frame", { Parent = dim, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = "@Panel", BorderSizePixel = 0, Size = UDim2.fromOffset(560, 380), ZIndex = 91 }, { corner(12), stroke("StrokeS", 1), make("UIScale", { Scale = UIScaleObj.Scale }) })
    shadow(panel, 50, 0.4)
    local title = make("TextLabel", { Parent = panel, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Runner", TextColor3 = "@Text", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -120, 0, 22), ZIndex = 92 })
    local sub = make("TextLabel", { Parent = panel, BackgroundTransparency = 1, Font = FONT_REG, Text = "", TextColor3 = "@Sub", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(16, 32), Size = UDim2.new(1, -120, 0, 16), ZIndex = 92 })
    local edScroll = make("ScrollingFrame", { Parent = panel, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Position = UDim2.fromOffset(16, 56), Size = UDim2.new(1, -32, 1, -108), ScrollBarThickness = 5, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 92 }, { corner(10), stroke("Stroke", 1) })
    local edit = make("TextBox", { Parent = edScroll, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Font = FONT_MONO, TextSize = 13, TextColor3 = "@Text", TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ClearTextOnFocus = false, MultiLine = true, TextWrapped = true, Text = "", ZIndex = 92 }, { pad(10) })
    local btnRow = make("Frame", { Parent = panel, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -14), Size = UDim2.fromOffset(360, 32), ZIndex = 92 }, { make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }) })
    local closeX = make("TextButton", { Parent = panel, AutoButtonColor = false, BorderSizePixel = 0, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 10), Size = UDim2.fromOffset(26, 26), Text = "✕", Font = FONT_BOLD, TextSize = 14, TextColor3 = "@Sub", ZIndex = 93 }, {})
    local ctx = {}
    local function close() dim.Visible = false end
    track(closeX.MouseButton1Click:Connect(close))
    track(dim.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local m = UserInputService:GetMouseLocation(); local p, s = panel.AbsolutePosition, panel.AbsoluteSize; if m.X < p.X or m.X > p.X + s.X or m.Y < p.Y or m.Y > p.Y + s.Y then close() end end end))

    UI.button(btnRow, { text = "Run", primary = true, order = 3, onClick = function()
        local src = edit.Text
        if not loadstringFn then Notify("Run", "loadstring unavailable.", "Bad"); return end
        local f, err = loadstringFn(src)
        if not f then Notify("Compile error", tostring(err), "Bad"); return end
        task.spawn(function() local ok, e = pcall(f); Notify(ok and "Ran code" or "Runtime error", ok and "Executed" or tostring(e), ok and "Good" or "Bad") end)
    end })
    local spoofBtn = UI.button(btnRow, { text = "Set as spoof", order = 2, onClick = function()
        if ctx.onSpoof then ctx.onSpoof(edit.Text) end
    end })
    UI.button(btnRow, { text = "Close", order = 1, onClick = close })

    Runner = {}
    function Runner.open(titleText, subText, code, onSpoof)
        title.Text = titleText or "Runner"
        sub.Text = subText or ""
        edit.Text = code or ""
        ctx.onSpoof = onSpoof
        spoofBtn.Visible = onSpoof ~= nil   -- only show the spoof action when the caller supplied one
        dim.Visible = true
        TweenService:Create(dim, EASE_F, { BackgroundTransparency = 0.45 }):Play()
    end
end

local function clip(s)
    if not setclipboard then Notify("Copy", "Clipboard unavailable on this executor.", "Bad", 2); return end
    local ok = pcall(setclipboard, s)
    Notify(ok and "Copied" or "Copy failed", ok and "Sent to clipboard" or "clipboard error", ok and "Good" or "Bad", 2)
end
local function callerName(c) if typeof(c) == "Instance" then local ok, n = pcall(function() return c:GetFullName() end); return ok and n or c.Name elseif typeof(c) == "string" then return c end return nil end
-- method-based type label (matches the reference: FireServer / InvokeServer / InvokeClient / …)
local function typeLabel(class, incoming)
    if class == "RemoteEvent" then return incoming and "RemoteEvent" or "FireServer"
    elseif class == "UnreliableRemoteEvent" then return incoming and "Unreliable" or "FireServer"
    elseif class == "RemoteFunction" then return incoming and "InvokeClient" or "InvokeServer"
    elseif class == "BindableEvent" then return "Fire"
    elseif class == "BindableFunction" then return "Invoke" end
    return class
end
local TYPE_COLOR = {
    RemoteEvent  = Color3.fromRGB(214, 134, 82),   -- copper
    FireServer   = Color3.fromRGB(233, 178, 96),   -- amber
    InvokeServer = Color3.fromRGB(206, 112, 86),   -- terracotta
    InvokeClient = Color3.fromRGB(228, 148, 78),   -- warm orange
    Unreliable   = Color3.fromRGB(238, 210, 146),  -- champagne
    Fire         = Color3.fromRGB(190, 150, 102),  -- bronze
    Invoke       = Color3.fromRGB(216, 160, 134),  -- rose-gold
}
local function typeColor(label) return TYPE_COLOR[label] or Theme.Sub end
-- short labels for the row "Type" column (RemoteEvent -> RE, etc.)
local SHORT_TYPE = { RemoteEvent = "RE", FireServer = "FS", InvokeServer = "IS", InvokeClient = "IC", Unreliable = "UR", Fire = "Fire", Invoke = "Inv" }
local function shortType(label) return SHORT_TYPE[label] or label end
-- per-framework colors for the inline [framework] tag in each row (matches the reference)
local FW_HEX = { ByteNet = "#7ab4ff", BridgeNet = "#9a7cff", BridgeNet2 = "#9a7cff", Blink = "#5fd0c0", Warp = "#ff9a6e", Red = "#ff6e6e", Zap = "#ffd166", Knit = "#c98cff", Aero = "#74b2ff", Cmdr = "#8ed081", Buffer = "#9aa0b4" }
local function fwHex(fw) return FW_HEX[fw] or "#d4a96e" end
local function richEsc(s) return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
local function commaize(n)
    local s = tostring(math.floor(n))
    local k = 1
    while k > 0 do s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2") end
    return s
end

--==============================  View factory  ============================--

local AllViews = {}
local ExplorerReveal   -- set by the Explorer page; lets a spy row jump to its instance in the tree
local explorerTick     -- set by the Explorer page; renders its virtualized tree each frame (so scrolling repaints)

local function createView(page, cfg)
    local view = {
        kind = cfg.kind, cfg = cfg,
        entries = {}, visible = {}, byId = {}, groupMap = {},
        queue = {}, qHead = 1, dirtyFilter = false,
        selectedEntry = nil, paused = false, _lastSelCount = 0,
        block = keep({}), ignore = keep({}), spoofs = keep({}), pins = keep({}), watch = keep({}), watchLast = {},
        rate = {}, autoIgnored = {},
        filterText = "", filterDir = "All", filterType = "All", filterFw = "All",
        codeMode = Settings.Codegen_mode,
    }
    AllViews[#AllViews + 1] = view
    Filters.load(cfg.kind, view)   -- restore this view's saved block/ignore/pin names

    --── toolbar (row 1: actions + filter + count) ──
    local header = make("Frame", { Parent = page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 66) })
    local row1 = make("Frame", { Parent = header, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30) })
    local actC = make("Frame", { Parent = row1, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 30) }, { hlayout(8) })
    local pauseBtn = UI.button(actC, { text = "Pause", icon = "rbxassetid://10734919336", order = 1, onClick = function() end })
    local clearBtn = UI.button(actC, { text = "Clear", icon = "rbxassetid://10747362241", color = "Bad", order = 2, onClick = function() end })
    local rightC = make("Frame", { Parent = row1, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 30) }, { make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }) })
    local search = UI.input(rightC, "Filter", function(t) view.filterText = t:lower(); view.dirtyFilter = true end, { size = UDim2.fromOffset(200, 30), order = 1 })
    addTip(search, "space = AND  ·  -term = exclude  ·  matches name / path / args / caller")
    local countPill = make("TextLabel", { Parent = rightC, BackgroundColor3 = "@Panel2", Font = FONT_MONO, Text = "0 logs", TextColor3 = "@Sub", TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 30), LayoutOrder = 2 }, { corner(8), stroke("Stroke", 1, 0.5), make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }) })
    -- toolbar (row 2: filters)
    local row2 = make("Frame", { Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 36), Size = UDim2.new(1, 0, 0, 28) })
    local filtC = make("Frame", { Parent = row2, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 28) }, { hlayout(8) })
    if cfg.directions then local s = UI.segmented(filtC, { "All", "Out", "In" }, "All", function(v) view.filterDir = v; view.dirtyFilter = true end); s.LayoutOrder = 1; addTip(s, "Direction: Out = client\226\134\146server, In = server\226\134\146client") end
    if cfg.types then local d = UI.dropdown(filtC, cfg.types, "All", function(v) view.filterType = v; view.dirtyFilter = true end, 150); d.LayoutOrder = 2; d.Size = UDim2.fromOffset(150, 28); addTip(d, "Filter by remote/bindable type") end
    do local d = UI.dropdown(filtC, { "All", "Roblox", "ByteNet", "BridgeNet", "BridgeNet2", "Blink", "Warp", "Red", "Zap", "Knit", "Aero", "Cmdr", "Buffer" }, "All", function(v) view.filterFw = v; view.dirtyFilter = true end, 124); d.LayoutOrder = 3; d.Size = UDim2.fromOffset(124, 28); addTip(d, "Filter by networking framework") end

    --── body: list | divider | detail ──
    local split = 0.44
    local body = make("Frame", { Parent = page, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 72), Size = UDim2.new(1, 0, 1, -72) })
    local listPanel = make("Frame", { Parent = body, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Size = UDim2.new(split, -6, 1, 0) }, { corner(11), stroke("Stroke", 1) })
    local divider = make("TextButton", { Parent = body, AutoButtonColor = false, BackgroundColor3 = "@StrokeS", BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", Position = UDim2.new(split, -5, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 10, 0.4, 0) }, { corner(3) })
    local detail = make("Frame", { Parent = body, BackgroundTransparency = 1, Position = UDim2.new(split, 6, 0, 0), Size = UDim2.new(1 - split, -6, 1, 0) })
    local function relayout() listPanel.Size = UDim2.new(split, -6, 1, 0); divider.Position = UDim2.new(split, -5, 0.5, 0); detail.Position = UDim2.new(split, 6, 0, 0); detail.Size = UDim2.new(1 - split, -6, 1, 0) end
    do
        local drag
        track(divider.MouseEnter:Connect(function() divider.BackgroundTransparency = 0.2 end))
        track(divider.MouseLeave:Connect(function() if not drag then divider.BackgroundTransparency = 1 end end))
        addTip(divider, "Drag to resize panels")
        track(divider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end))
        track(UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false; divider.BackgroundTransparency = 1 end end))
        track(UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then split = math.clamp((i.Position.X - body.AbsolutePosition.X) / math.max(body.AbsoluteSize.X, 1), 0.24, 0.6); relayout() end end))
    end

    --── log table: column header · body · per-type footer ──
    local COLS = { typ = 62, path = 96 }
    local listHeader = make("Frame", { Parent = listPanel, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26) })
    make("TextLabel", { Parent = listHeader, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "#", TextColor3 = "@Faint", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.fromOffset(20, 0), Size = UDim2.fromOffset(20, 26) })
    make("TextLabel", { Parent = listHeader, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Type", TextColor3 = "@Faint", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(COLS.typ, 0), Size = UDim2.fromOffset(84, 26) })
    make("TextLabel", { Parent = listHeader, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Remote", TextColor3 = "@Faint", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(COLS.path, 0), Size = UDim2.new(1, -COLS.path - 52, 0, 26) })
    make("TextLabel", { Parent = listHeader, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Count", TextColor3 = "@Faint", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 0), Size = UDim2.fromOffset(46, 26) })
    make("Frame", { Parent = listHeader, BackgroundColor3 = "@Stroke", BorderSizePixel = 0, Position = UDim2.new(0, 8, 1, -1), Size = UDim2.new(1, -16, 0, 1) })
    local listBody = make("Frame", { Parent = listPanel, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 1, -28) })

    --── empty state ──
    local empty = make("Frame", { Parent = listBody, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, { make("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center }) })
    make("Frame", { Parent = empty, BackgroundTransparency = 1, Size = UDim2.fromOffset(34, 34) }, { corner(17), stroke("Faint", 2, 0.2) })
    local emptyLbl = make("TextLabel", { Parent = empty, BackgroundTransparency = 1, Font = FONT, Text = "Waiting for traffic...", TextColor3 = "@Faint", TextSize = 13, Size = UDim2.fromOffset(220, 18) })

    --── virtualized columnar rows (Time · Type · Remote Path) ──
    view.expanded = view.expanded or {}   -- entries whose call-history arrow is open
    local rowMap = {}                      -- pooled row -> its current display item (for the arrow)
    local function buildRow()
        local row = make("TextButton", { AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel2", BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 34) }, {
            corner(7),
            -- pinned indicator: a gold accent bar down the left edge (hidden unless pinned)
            make("Frame", { Name = "PinBar", BackgroundColor3 = "@Accent2", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 1, 0.5, 0), Size = UDim2.fromOffset(3, 22), Visible = false, ZIndex = 4 }, { corner(2), grad(0, Theme.Accent, Theme.Accent2) }),
            -- expand arrow (only shown on grouped rows fired more than once)
            make("ImageButton", { Name = "Arrow", AutoButtonColor = false, BackgroundTransparency = 1, Image = "rbxassetid://10709791437", ImageColor3 = "@Sub", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(11, 17), Size = UDim2.fromOffset(12, 12), Rotation = 0, Visible = false }),
            make("TextLabel", { Name = "Num", BackgroundTransparency = 1, Font = FONT_MONO, TextSize = 11, TextColor3 = "@Accent", TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.fromOffset(20, 0), Size = UDim2.fromOffset(20, 34) }),
            make("Frame", { Name = "TypePill", BorderSizePixel = 0, BackgroundColor3 = "@Accent", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(46, 17), Size = UDim2.fromOffset(10, 16) }, { corner(5) }),
            make("TextLabel", { Name = "Typ", BackgroundTransparency = 1, Font = FONT_BOLD, TextSize = 12, TextColor3 = "@Text", TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(62, 0), Size = UDim2.fromOffset(30, 34) }),
            make("TextLabel", { Name = "Path", BackgroundTransparency = 1, Font = FONT, TextSize = 12, RichText = true, TextColor3 = "@Sub", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(96, 0), Size = UDim2.new(1, -144, 1, 0) }),
            make("Frame", { Name = "CountPill", BorderSizePixel = 0, BackgroundColor3 = "@Accent", BackgroundTransparency = 0.8, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X }, {
                corner(9), make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
                make("TextLabel", { Name = "Lbl", BackgroundTransparency = 1, Font = FONT_BOLD, TextSize = 11, TextColor3 = "@Accent2", Text = "", AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0) }),
            }),
        })
        track(row.MouseEnter:Connect(function() if not row:GetAttribute("sel") then TweenService:Create(row, EASE_F, { BackgroundTransparency = 0.6 }):Play() end end))
        track(row.MouseLeave:Connect(function() if not row:GetAttribute("sel") then TweenService:Create(row, EASE_F, { BackgroundTransparency = 1 }):Play() end end))
        track(row.Arrow.MouseButton1Click:Connect(function()
            local item = rowMap[row]; if not item or item.__call then return end
            local e = item.entry; if not (e.history and #e.history > 1) then return end
            view.expanded[e] = (not view.expanded[e]) or nil
            view.refreshDisplay()
        end))
        return row
    end
    local function bindRow(row, item)
        rowMap[row] = item
        local e = item.entry
        if item.__call then
            -- sub-row: one individual fire of the grouped remote
            row.Arrow.Visible = false; row.Num.Text = ""; row.TypePill.Visible = false; row.Typ.Text = ""; row.CountPill.Visible = false; row.PinBar.Visible = false
            local c, idx = item.call, item.idx
            local subSel = (view.selectedEntry == e and view.callIdx == idx)
            local nargs = (c.packed and (c.packed.n or #c.packed)) or 0
            row.Path.Text = "    ·   #" .. (c.n or idx) .. "   ·   " .. (c.time or "") .. "   ·   " .. nargs .. " arg" .. (nargs == 1 and "" or "s")
            row.Path.TextColor3 = subSel and Theme.Accent2 or Theme.Faint
            row:SetAttribute("sel", subSel)                       -- so hover/leave doesn't wipe the selection
            row.BackgroundColor3 = subSel and Theme.Accent or Theme.Panel2
            row.BackgroundTransparency = subSel and 0.8 or 1      -- selected call gets a warm gold wash
            return
        end
        -- normal grouped/entry row
        row.BackgroundColor3 = Theme.Panel2                       -- reset (pooled row may have been a gold sub-row)
        local sel = (e == view.selectedEntry)
        row:SetAttribute("sel", sel)
        local tc = typeColor(e.typeLabel)
        local pinned = view.pins[e.name] and true or false
        row.PinBar.Visible = pinned                               -- gold bar marks pinned rows
        local expandable = e.history and #e.history > 1
        row.Arrow.Visible = expandable; row.Arrow.Rotation = view.expanded[e] and 90 or 0
        row.Num.Text = tostring(item.num or "")
        row.Num.TextColor3 = pinned and Theme.Accent2 or Theme.Accent
        row.TypePill.Visible = true; row.TypePill.BackgroundColor3 = tc
        row.Typ.Text = shortType(e.typeLabel or e.class); row.Typ.TextColor3 = tc
        local p = (e.name ~= "" and e.name) or e.class or "?"
        row.Path.TextColor3 = Theme.Sub
        -- direction glyph: up = we sent it to the server, down = server pushed it to us
        local prefix = e.incoming and '<font color="#6fb2ff">\226\134\147</font> ' or '<font color="#7ee081">\226\134\145</font> '
        if e.framework ~= "Roblox" then prefix = prefix .. ('<font color="%s">[%s]</font> '):format(fwHex(e.framework), e.framework) end
        if e.hidden then prefix = prefix .. '<font color="#ff6894">[hidden]</font> ' end   -- not a descendant of game (nil-parented / non-replicated)
        if view.watch[e.name] then prefix = '<font color="#eec986">\226\151\137</font> ' .. prefix end   -- ◉ marks a watched remote
        row.Path.Text = prefix .. richEsc(p)
        local cp, lbl = row.CountPill, row.CountPill.Lbl
        cp.Visible = true
        local txt, col = (e.count or 1) .. "x", Theme.Accent
        if view.spoofs[e.name] then txt, col = "SPOOF", Theme.Good elseif view.block[e.name] then txt, col = "BLOCK", Theme.Bad end
        lbl.Text = txt; lbl.TextColor3 = col; cp.BackgroundColor3 = col
        if not sel and view.watch[e.name] then row.BackgroundColor3 = Theme.Accent; row.BackgroundTransparency = 0.92   -- faint tint on watched rows
        else row.BackgroundColor3 = Theme.Panel2; row.BackgroundTransparency = sel and 0.5 or 1 end
    end
    local vlist = VirtualList(listBody, 38, buildRow, bindRow, function(item)
        view.select(item.entry)                         -- selects entry (resets callIdx to latest)
        if item.__call then                             -- a sub-row: jump straight to that specific fire
            view.callIdx = item.idx
            view.renderDetail(item.entry)
            if view.vlist then view.vlist.invalidate() end
        end
    end)
    view.vlist = vlist
    -- flatten visible entries; expand any open arrow into newest-first per-call sub-rows
    function view.display()
        local out, n = {}, 0
        for _, e in ipairs(view.visible or {}) do
            n += 1
            out[#out + 1] = { entry = e, num = n }
            if view.expanded[e] and e.history and #e.history > 1 then
                for j = #e.history, 1, -1 do out[#out + 1] = { __call = true, entry = e, idx = j, call = e.history[j] } end
            end
        end
        return out
    end
    function view.refreshDisplay() vlist.setItems(view.display()) end

    --── detail panel ──
    -- (detail header removed — tabs + code only)
    local tabRow = make("Frame", { Parent = detail, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 26) }, { hlayout(6) })
    local bodyArea = make("Frame", { Parent = detail, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 1, -(34 + 38)) })
    local scriptArea = make("Frame", { Parent = bodyArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) })
    local argsArea = make("ScrollingFrame", { Parent = bodyArea, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Visible = false, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 4, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, { corner(11), stroke("Stroke", 1), pad(10), vlayout(6) })
    local connArea = make("Frame", { Parent = bodyArea, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Visible = false, Size = UDim2.new(1, 0, 1, 0) }, { corner(11), stroke("Stroke", 1) })

    -- script tab content
    local modeDD = UI.dropdown(scriptArea, Codegen.Modes, view.codeMode, function(v) view.codeMode = v; if view.selectedEntry then view.renderDetail(view.selectedEntry) end end, 120)
    modeDD.Position = UDim2.fromOffset(0, 0)

    -- call-history picker: when a remote was fired multiple times, pick which call to view
    local callBtn = make("TextButton", { Parent = scriptArea, AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel2", Position = UDim2.fromOffset(128, 0), Size = UDim2.fromOffset(146, 30), Text = "", Visible = false }, { corner(8), stroke("Stroke", 1, 0.4) })
    local callLbl = make("TextLabel", { Parent = callBtn, BackgroundTransparency = 1, Font = FONT, TextSize = 12, Text = "", TextColor3 = "@Text", TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -28, 1, 0) })
    make("TextLabel", { Parent = callBtn, BackgroundTransparency = 1, Font = FONT_BOLD, TextSize = 11, Text = "v", TextColor3 = "@Sub", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(12, 12) })
    local callPop, callBackdrop
    local function closeCallPop() if callBackdrop then callBackdrop:Destroy(); callBackdrop = nil end if callPop then callPop:Destroy(); callPop = nil end end
    track(callBtn.MouseButton1Click:Connect(function()
        if callPop then closeCallPop(); return end
        local e = view.selectedEntry; if not (e and e.history and #e.history > 1) then return end
        local abs, sz = callBtn.AbsolutePosition, callBtn.AbsoluteSize
        callBackdrop = make("TextButton", { Parent = ScreenGui, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 79 })   -- click-outside closes the picker
        callBackdrop.MouseButton1Click:Connect(closeCallPop)
        callPop = make("Frame", { Parent = ScreenGui, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Position = UDim2.fromOffset(abs.X, abs.Y + sz.Y + 5), Size = UDim2.fromOffset(146, math.min(#e.history, 8) * 28 + 8), ZIndex = 80, ClipsDescendants = true }, { corner(8), stroke("StrokeS", 1), pad(4), make("UIScale", { Scale = UIScaleObj.Scale }) })
        local sc = make("ScrollingFrame", { Parent = callPop, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 3, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 80 }, { vlayout(2) })
        for i = #e.history, 1, -1 do
            local h = e.history[i]
            local nargs = (h.packed and (h.packed.n or #h.packed)) or 0
            local o = make("TextButton", { Parent = sc, AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel2", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Text = "#" .. (h.n or i) .. "   " .. (h.time or "") .. "   (" .. nargs .. " args)", Font = FONT, TextSize = 12, TextColor3 = "@Text", TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 81 }, { corner(6), pad(0, 0, 9, 9) })
            o.MouseEnter:Connect(function() o.BackgroundTransparency = 0; o.BackgroundColor3 = Theme.Hover end)
            o.MouseLeave:Connect(function() o.BackgroundTransparency = 1 end)
            o.MouseButton1Click:Connect(function() view.callIdx = i; closeCallPop(); view.renderDetail(e) end)
        end
    end))

    local code = codeView(make("Frame", { Parent = scriptArea, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 36), Size = UDim2.new(1, 0, 1, -36) }))
    view.code = code

    -- conns tab content
    local connHead = make("TextLabel", { Parent = connArea, BackgroundTransparency = 1, Font = FONT, Text = "", TextColor3 = "@Sub", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(12, 9), Size = UDim2.new(1, -120, 0, 18) })
    local connList = make("ScrollingFrame", { Parent = connArea, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(8, 34), Size = UDim2.new(1, -16, 1, -42), ScrollBarThickness = 4, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, { vlayout(5) })
    local connDisableAll = make("TextButton", { Parent = connArea, AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel3", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 6), Size = UDim2.fromOffset(96, 22), Text = "Disable all", Font = FONT, TextSize = 11, TextColor3 = "@Bad" }, { corner(6) })

    local tabBtns = {}
    local function showTab(which)
        scriptArea.Visible = which == "script"; argsArea.Visible = which == "args"; connArea.Visible = which == "conns"
        for n, b in tabBtns do b.BackgroundTransparency = (n == which) and 0 or 1; b.Lbl.TextColor3 = (n == which) and Theme.Text or Theme.Sub end
        if which == "conns" and view.selectedEntry then view.renderConns(view.selectedEntry) end
    end
    local function addTab(id, label)
        local b = UI.button(tabRow, { text = label, order = #tabRow:GetChildren(), onClick = function() showTab(id) end })
        b.BackgroundTransparency = 1; b.Lbl.TextColor3 = Theme.Sub
        tabBtns[id] = b
    end
    addTab("script", "Script"); addTab("args", "Args"); addTab("conns", "Conns")

    -- action bar (per-capture) — single horizontal row, scrolls sideways if it overflows
    local actionBar = make("ScrollingFrame", { Parent = detail, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X }, {
        make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }),
    })
    local ACT_ICON = {
        Copy = "rbxassetid://10709812159", Run = "rbxassetid://10734923549", Repeat = "rbxassetid://10734933966",
        Spoof = "rbxassetid://10734966248", Return = "rbxassetid://10709813185", Clear = "rbxassetid://10747362241",
        Block = "rbxassetid://10734951684", Unblock = "rbxassetid://10734951847", Pin = "rbxassetid://10734922324",
        Decompile = "rbxassetid://10723356507", Ignore = "rbxassetid://10734965702",
    }
    local function act(text, o)
        o = o or {}; o.text = text; o.order = #actionBar:GetChildren(); o.textSize = o.textSize or 12
        o.icon = o.icon or ACT_ICON[(text:gsub("^[^%w%s]+%s*", ""))]
        local b, lbl = UI.button(actionBar, o)
        b.Size = UDim2.new(0, 0, 1, 0)
        -- only the destructive Block keeps a colored tint (text + icon); everything else stays neutral
        if o.tint and not o.primary then
            local col = (type(o.tint) == "string") and Theme[o.tint] or o.tint
            if col == Theme.Bad then
                lbl.TextColor3 = col
                local s = b:FindFirstChildOfClass("UIStroke"); if s then s.Color = col; s.Transparency = 0.25 end
                local img = b:FindFirstChild("Ico", true); if img then img.ImageColor3 = col end
            end
        end
        return b
    end

    --── detail rendering ──
    -- which call in a grouped entry's history we're viewing (nil = newest)
    local function pickedPacked(e)
        local n = e.history and #e.history or 0
        if n == 0 then return e.packed end
        local idx = math.clamp(view.callIdx or n, 1, n)
        return (e.history[idx] and e.history[idx].packed) or e.packed
    end
    function view.refreshCallPicker(e)
        local n = math.max(1, (e and e.history and #e.history) or 1)
        callBtn.Visible = n > 1
        local sel = math.clamp(view.callIdx or n, 1, n)
        local trueN = (e and e.history and e.history[sel] and e.history[sel].n) or sel
        callLbl.Text = "Call #" .. trueN .. " / " .. ((e and e.count) or n)
    end
    view._refreshMeta = function(e) view.refreshCallPicker(e) end
    function view.renderDetail(e, keepScroll)
        view.refreshCallPicker(e)
        local packed = pickedPacked(e)
        local meta = { framework = e.framework, size = e.size, time = e.time }
        local savedP = e.packed; e.packed = packed
        code.set(cfg.codegen(view.codeMode, e, meta), keepScroll)
        e.packed = savedP
        -- args tab
        for _, c in argsArea:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
        -- per-remote stats line: fire count, first/last seen, and the calling script
        local avgB = math.floor((e.sizeSum or e.size or 0) / math.max(1, e.count or 1))
        make("TextLabel", { Parent = argsArea, BackgroundTransparency = 1, Font = FONT_MONO, RichText = true, Text = ("<font color=\"#c99c58\">×%d</font>  ·  first %s  ·  last %s  ·  avg %sb%s"):format(e.count or 1, e.firstTime or e.time or "?", e.time or "?", commaize(avgB), e.callerName and ("  ·  by " .. richEsc(tostring(e.callerName))) or ""), TextColor3 = "@Sub", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 0 })
        local n = packed.n or #packed
        if n == 0 then make("TextLabel", { Parent = argsArea, BackgroundTransparency = 1, Font = FONT, Text = "(no arguments)", TextColor3 = "@Faint", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 18) })
        else
            for i = 1, n do
                local val = packed[i]
                local ok, s = pcall(function() ToString.SetCompress(nil); return ToString.ToString(val, 1) end)
                ToString.SetCompress(nil)
                s = ok and s or ("<" .. typeof(val) .. ">")
                local rowf = make("Frame", { Parent = argsArea, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = i }, { corner(8), pad(8) })
                make("TextLabel", { Parent = rowf, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "[" .. i .. "]  " .. typeof(val), TextColor3 = "@Accent2", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -50, 0, 14) })
                local cp = make("TextButton", { Parent = rowf, AutoButtonColor = false, BorderSizePixel = 0, BackgroundTransparency = 1, Text = "copy", Font = FONT, TextSize = 10, TextColor3 = "@Sub", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(40, 14) })
                cp.MouseButton1Click:Connect(function() clip(s) end)   -- transient (re-rendered): auto-disconnects on Destroy
                make("TextLabel", { Parent = rowf, BackgroundTransparency = 1, Font = FONT_MONO, RichText = true, Text = highlight(#s > 1200 and (s:sub(1, 1200) .. "  …") or s), TextColor3 = "@Text", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
            end
        end
        -- captured RemoteFunction return value(s), shown WITHOUT re-invoking (no side effects).
        -- got shape: invoke -> { [1] = table.pack(returns) };  spoof -> the packed values directly.
        local g = e.got
        local rets = (type(g) == "table") and ((type(g[1]) == "table" and g[1].n ~= nil and g[1]) or (g.n ~= nil and g) or nil) or nil
        if rets and (rets.n or #rets) > 0 then
            make("TextLabel", { Parent = argsArea, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "RETURN  ·  server reply (latest call)", TextColor3 = "@Good", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 500 })
            for i = 1, (rets.n or #rets) do
                local val = rets[i]
                local ok, s = pcall(function() ToString.SetCompress(nil); return ToString.ToString(val, 1) end)
                ToString.SetCompress(nil)
                s = ok and s or ("<" .. typeof(val) .. ">")
                local rowf = make("Frame", { Parent = argsArea, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 500 + i }, { corner(8), pad(8), stroke("StrokeS", 1, 0.6) })
                make("TextLabel", { Parent = rowf, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "→ [" .. i .. "]  " .. typeof(val), TextColor3 = "@Good", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -50, 0, 14) })
                local cp = make("TextButton", { Parent = rowf, AutoButtonColor = false, BorderSizePixel = 0, BackgroundTransparency = 1, Text = "copy", Font = FONT, TextSize = 10, TextColor3 = "@Sub", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(40, 14) })
                cp.MouseButton1Click:Connect(function() clip(s) end)
                make("TextLabel", { Parent = rowf, BackgroundTransparency = 1, Font = FONT_MONO, RichText = true, Text = highlight(#s > 1200 and (s:sub(1, 1200) .. "  …") or s), TextColor3 = "@Text", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
            end
        end
    end

    -- connections viewer
    local function signalOf(e)
        local ok, sig = pcall(function()
            if e.class == "RemoteEvent" or e.class == "UnreliableRemoteEvent" then return e.remote.OnClientEvent
            elseif e.class == "BindableEvent" then return e.remote.Event end
            return nil
        end)
        return ok and sig or nil
    end
    function view.renderConns(e)
        for _, c in connList:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
        if not getconnections then connHead.Text = "getconnections unavailable on this executor."; return end
        local sig = signalOf(e)
        if not sig then connHead.Text = e.class .. " has no inspectable signal (RemoteFunction uses a single callback)."; return end
        local ok, conns = pcall(getconnections, sig)
        if not ok or type(conns) ~= "table" then connHead.Text = "Could not read connections."; return end
        connHead.Text = #conns .. " listener" .. (#conns == 1 and "" or "s")
        for i, con in conns do
            local f = (pcall(function() return con.Function end)) and con.Function or nil
            local src, line = "?", nil
            if f then pcall(function() src = debug.info(f, "s"); line = debug.info(f, "l") end) end
            local enabled = true
            pcall(function() local s = con.Enabled; if s == nil then s = con.State end; enabled = s ~= false end)
            local rowf = make("Frame", { Parent = connList, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = i }, { corner(8), pad(6, 6, 8, 8) })
            make("TextLabel", { Parent = rowf, BackgroundTransparency = 1, Font = FONT_MONO, Text = "#" .. i .. "  " .. tostring(src) .. (line and line ~= -1 and (":" .. line) or ""), TextColor3 = "@Text", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -150, 0, 14) })
            local st = make("TextLabel", { Parent = rowf, BackgroundTransparency = 1, Font = FONT, Text = enabled and "enabled" or "disabled", TextColor3 = enabled and "@Good" or "@Bad", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(0, 80, 0, 14) })
            local brow = make("Frame", { Parent = rowf, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 0, 1, 0), Size = UDim2.new(0, 140, 0, 18) }, { make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Right }) })
            local function mb(txt, ck, cb) local b = make("TextButton", { Parent = brow, AutoButtonColor = true, BorderSizePixel = 0, BackgroundColor3 = "@Panel3", Size = UDim2.fromOffset(58, 18), Text = txt, Font = FONT, TextSize = 10, TextColor3 = "@" .. ck }, { corner(5) }); b.MouseButton1Click:Connect(cb) end
            mb("Toggle", "Text", function() local okk = pcall(function() if enabled then (con.Disable or con.disable)(con) else (con.Enable or con.enable)(con) end end); if okk then enabled = not enabled; st.Text = enabled and "enabled" or "disabled"; st.TextColor3 = enabled and Theme.Good or Theme.Bad else Notify("Connections", "Toggle unsupported", "Bad") end end)
            mb("Fire", "Accent", function() local a = e.packed or table.pack(); local okk = pcall(function() (con.Fire or con.fire)(con, table.unpack(a, 1, a.n or #a)) end); Notify(okk and "Fired" or "Fire failed", e.name, okk and "Good" or "Bad", 2) end)
        end
    end
    track(connDisableAll.MouseButton1Click:Connect(function()
        local e = view.selectedEntry; if not e or not getconnections then return end
        local sig = signalOf(e); if not sig then return end
        local ok, conns = pcall(getconnections, sig)
        if ok and type(conns) == "table" then local nn = 0; for _, con in conns do if pcall(function() (con.Disable or con.disable)(con) end) then nn += 1 end end Notify("Disabled connections", nn .. " listener" .. (nn == 1 and "" or "s") .. " on " .. e.name, "Bad"); view.renderConns(e) end
    end))

    function view.select(e)
        view.selectedEntry = e; view._lastSelCount = e.count; view.callIdx = nil
        view.renderDetail(e)
        if connArea.Visible then view.renderConns(e) end
        vlist.invalidate()
    end

    --── data layer (capture queue → entries → filtered view) ──
    local DROP_AT = 2500
    function view.accepting() if view.paused then return false end return (#view.queue - view.qHead + 1) < DROP_AT end
    function view.addRaw(remote, incoming, packed, caller, got)
        if view.paused then return end
        local nm = remote.Name ~= "" and remote.Name or remote.ClassName
        if view.ignore[nm] then return end
        local q = view.queue
        if (#q - view.qHead + 1) >= DROP_AT then return end
        q[#q + 1] = { remote, incoming, packed, caller, got, os.clock(), coroutine.running() }
    end
    local nextId = 0
    local function process(raw)
        local remote, incoming, packed, caller, got, clk, thr = raw[1], raw[2], raw[3], raw[4], raw[5], raw[6], raw[7]
        local nm = remote.Name ~= "" and remote.Name or remote.ClassName
        if view.watch[nm] then local wl = view.watchLast[nm]; if not wl or (clk - wl) > 1 then view.watchLast[nm] = clk; Notify("Watched remote fired", nm, "Accent", 2.5) end end   -- one notify/sec per watched name
        if Settings.Ignore_spammy_logs then
            local r = view.rate[nm]
            if not r or (clk - r.t) > 1 then r = { t = clk, c = 0 }; view.rate[nm] = r end
            r.c += 1
            if r.c > 80 then view.ignore[nm] = true; view.dirtyFilter = true; if not view.autoIgnored[nm] then view.autoIgnored[nm] = true; Notify("Auto-ignored spam", nm .. " (>80/s)", "Warn", 3) end return end
        end
        local lbl = typeLabel(remote.ClassName, incoming)
        local gkey = nm .. "\0" .. remote.ClassName .. "\0" .. (incoming and "I" or "O")
        local existing = Settings.Group_calls and view.groupMap[gkey]
        if existing then
            if cfg.onStat then cfg.onStat(existing) end   -- count EVERY call (not just new remotes) so Dashboard Total/Calls-per-sec are real
            existing.count += 1; existing.packed = packed; existing.got = got; existing.remote = remote; existing.clk = clk; existing.time = os.date("%H:%M:%S")
            existing.sizeSum = (existing.sizeSum or existing.size or 0) + estimateSize(packed)   -- running total for avg payload size
            existing.history = existing.history or {}
            existing.history[#existing.history + 1] = { packed = packed, time = existing.time, n = existing.count }  -- n = TRUE call number
            if #existing.history > math.max(Settings.Calls_per_remote, 5) then
                table.remove(existing.history, 1)
                -- the array just shifted down by one — keep a selected sub-row pointing at the SAME call
                if view.selectedEntry == existing and view.callIdx then view.callIdx = math.max(1, view.callIdx - 1) end
            end
            if view.selectedEntry == existing then view._lastSelCount = -1 end  -- refresh call picker next tick
        else
            nextId += 1
            local fwk = detectFramework(remote, packed)
            local okk, isDesc = pcall(function() return remote:IsDescendantOf(game) end)
            local full = nm; pcall(function() full = remote:GetFullName() end)
            local segs = full:split("."); local short = full
            if #segs > 3 then short = "…" .. segs[#segs - 2] .. "." .. segs[#segs - 1] .. "." .. segs[#segs] end
            local e = {
                id = nextId, name = nm, remote = remote, incoming = incoming, packed = packed, got = got,
                caller = caller, callerName = callerName(caller), thread = tostring(thr), time = os.date("%H:%M:%S"), clk = clk,
                framework = fwk, size = estimateSize(packed), count = 1, class = remote.ClassName, hidden = okk and not isDesc, gkey = gkey,
                typeLabel = lbl, fullName = full, shortPath = short, firstTime = os.date("%H:%M:%S"),
            }
            -- index a bounded preview of the argument CONTENT so the filter can find remotes by payload
            -- (scalars + one level into tables; capped, no deep recursion or full serialization).
            local argPrev = ""
            do
                local parts, budget = {}, 240
                local function addScalar(v)
                    if budget <= 0 then return end
                    local tv = typeof(v); local s
                    if tv == "string" then s = v elseif tv == "number" or tv == "boolean" or tv == "EnumItem" then s = tostring(v)
                    elseif tv == "Instance" then s = (pcall(function() return v.Name end)) and v.Name or nil end
                    if s then s = #s > 50 and s:sub(1, 50) or s; parts[#parts + 1] = s; budget -= #s + 1 end
                end
                local an = packed.n or #packed
                for i = 1, math.min(an, 12) do
                    if budget <= 0 then break end
                    local v = packed[i]
                    if typeof(v) == "table" then local c = 0; for k, val in v do addScalar(k); addScalar(val); c += 1; if c >= 20 or budget <= 0 then break end end
                    else addScalar(v) end
                end
                argPrev = table.concat(parts, " ")
            end
            e.search = (nm .. " " .. fwk .. " " .. full .. " " .. argPrev .. " " .. (e.callerName or "")):lower()   -- also searchable by calling script
            e.history = { { packed = packed, time = e.time, n = 1 } }
            view.entries[#view.entries + 1] = e
            view.byId[e.id] = e
            if Settings.Group_calls then view.groupMap[gkey] = e end
            view.dirtyFilter = true
            if cfg.onStat then cfg.onStat(e) end
        end
    end
    function view.drain()
        local q = view.queue
        local head, n = view.qHead, #q
        if head > n then return false end
        -- adaptive budget: clear burst backlogs faster (they're mostly cheap grouped repeats)
        -- while staying light in the steady state. Still bounded, so no frame hang.
        local pending = n - head + 1
        local budget = pending > 1200 and 400 or (pending > 500 and 240 or 120)
        while head <= n and budget > 0 do local raw = q[head]; q[head] = nil; head += 1; budget -= 1; process(raw) end
        view.qHead = head
        if head > n then view.queue = {}; view.qHead = 1 end
        local E = view.entries
        local maxN = math.max(Settings.Maximum_log_amount, 50)
        if #E > maxN * 1.3 then
            local from = #E - maxN + 1
            local newE = table.create(maxN)
            view.groupMap = {}; view.byId = {}
            for i = from, #E do local e = E[i]; newE[#newE + 1] = e; view.byId[e.id] = e; if Settings.Group_calls then view.groupMap[e.gkey] = e end end
            view.entries = newE; view.dirtyFilter = true
            -- drop expanded refs for trimmed entries (else next(view.expanded) stays truthy → re-render every frame)
            if view.expanded and next(view.expanded) then
                local surv = {}; for _, e in newE do surv[e] = true end
                for e in pairs(view.expanded) do if not surv[e] then view.expanded[e] = nil end end
            end
        end
        return true
    end
    function view.passes(e)
        if view.ignore[e.name] then return false end   -- ignored remotes vanish from the list immediately
        if view.filterDir == "Out" and e.incoming then return false end
        if view.filterDir == "In" and not e.incoming then return false end
        if view.filterType ~= "All" and e.class ~= view.filterType then return false end
        if view.filterFw ~= "All" and e.framework ~= view.filterFw then return false end
        if view.filterText ~= "" then for term in view.filterText:gmatch("%S+") do
            if term:sub(1, 1) == "-" and #term > 1 then if e.search:find(term:sub(2), 1, true) then return false end   -- -term excludes
            elseif not e.search:find(term, 1, true) then return false end
        end end
        return true
    end
    function view.rebuild()
        local out, pinned = {}, {}
        local E = view.entries
        for i = #E, 1, -1 do local e = E[i]; if view.passes(e) then if view.pins[e.name] then pinned[#pinned + 1] = e else out[#out + 1] = e end end end
        if #pinned > 0 then local m = {}; for _, e in pinned do m[#m + 1] = e end; for _, e in out do m[#m + 1] = e end; out = m end
        view.visible = out
        view.refreshDisplay()
        countPill.Text = (#out == #E) and (commaize(#E) .. " logs") or (commaize(#out) .. " of " .. commaize(#E))
        -- show the empty state whenever nothing is visible, with the RIGHT reason
        empty.Visible = (#out == 0)
        if #out == 0 then emptyLbl.Text = (#E == 0) and "Waiting for traffic..." or "No matches for this filter" end
    end
    function view.tick()
        local added = view.drain()
        if view.dirtyFilter then
            local atTop = vlist.atTop()
            view.dirtyFilter = false; view.rebuild()
            if atTop then vlist.toTop() end
        elseif added then if next(view.expanded) then view.refreshDisplay() else vlist.invalidate() end end
        vlist.tick()
        if view.selectedEntry and view.selectedEntry.count ~= view._lastSelCount then
            view._lastSelCount = view.selectedEntry.count
            pcall(view._refreshMeta, view.selectedEntry)
            -- viewing the LATEST call? keep the code/args panel live (throttled to 4/s) so it
            -- never shows a stale older fire while the remote keeps firing
            if view.callIdx == nil then
                local now = os.clock()
                if now - (view._detailClock or 0) > 0.25 then view._detailClock = now; pcall(view.renderDetail, view.selectedEntry, true) end
            end
            vlist.invalidate()
        end
    end

    --── header controls ──
    track(pauseBtn.MouseButton1Click:Connect(function()
        view.paused = not view.paused
        pauseBtn.Lbl.Text = view.paused and "Resume" or "Pause"
        pauseBtn.Lbl.TextColor3 = view.paused and Theme.Good or Theme.Text
        setStatusColor(view.paused and Theme.Warn or Theme.Good)
        statusLbl.Text = view.paused and "Paused" or "Capturing"
    end))
    track(clearBtn.MouseButton1Click:Connect(function()
        view.entries = {}; view.visible = {}; view.groupMap = {}; view.byId = {}; view.selectedEntry = nil; view.expanded = {}; view.callIdx = nil
        view.refreshDisplay(); countPill.Text = "0 logs"; empty.Visible = true
        code.set(""); callBtn.Visible = false
        for _, c in argsArea:GetChildren() do if c:IsA("Frame") then c:Destroy() end end   -- wipe the detail too
        for _, c in connList:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
        connHead.Text = ""; showTab("script")
    end))

    --── toolbar actions ──
    -- handlers (logic unchanged) — wired below into a few grouped controls so the bar stays tidy
    local function doRepeat()
        local e = view.selectedEntry; if not e or typeof(e.remote) ~= "Instance" then return end
        task.spawn(function()
            local a = pickedPacked(e)   -- repeat the call you're VIEWING (respects the call picker), not just the latest
            local ok, err = pcall(function()
                if not e.incoming then
                    if e.class == "RemoteFunction" then e.remote:InvokeServer(table.unpack(a, 1, a.n))
                    elseif e.class == "BindableFunction" then e.remote:Invoke(table.unpack(a, 1, a.n))
                    elseif e.class == "BindableEvent" then e.remote:Fire(table.unpack(a, 1, a.n))
                    else e.remote:FireServer(table.unpack(a, 1, a.n)) end
                elseif e.class == "RemoteFunction" and getcallbackvalue then getcallbackvalue(e.remote, "OnClientInvoke")(table.unpack(a, 1, a.n))
                elseif firesignal then firesignal(e.remote.OnClientEvent, table.unpack(a, 1, a.n)) end
            end)
            Notify(ok and "Repeated" or "Repeat failed", ok and e.name or tostring(err), ok and "Good" or "Bad")
        end)
    end
    local function doSpoof()
        local e = view.selectedEntry; if not e then return end
        if e.class ~= "RemoteFunction" and e.class ~= "BindableFunction" then Notify("Spoof", "Only RemoteFunction/BindableFunction can be spoofed (selected: " .. e.class .. ").", "Bad"); return end
        Runner.open("Spoof return · " .. e.name, "Edit to `return <values>` then 'Set as spoof'. The remote will reply your value to the client.", "return \"spoofed value\"", function(src)
            if not loadstringFn then Notify("Spoof", "loadstring unavailable.", "Bad"); return end
            if src:find(":FireServer", 1, true) or src:find(":InvokeServer", 1, true) or src:find(":Fire(", 1, true) or src:find(":Invoke(", 1, true) or src:find("firesignal", 1, true) then Notify("Spoof", "Body must be a pure `return …` (no remote/bindable calls).", "Bad"); return end
            local f, err = loadstringFn(src); if not f then Notify("Spoof", "Code error: " .. tostring(err), "Bad"); return end
            local res = table.pack(pcall(f)); if not res[1] then Notify("Spoof", "Run error: " .. tostring(res[2]), "Bad"); return end
            local vals = { n = res.n - 1 }; for i = 2, res.n do vals[i - 1] = res[i] end
            vals = keep(vals); view.spoofs[e.remote] = vals; view.spoofs[e.name] = vals; vlist.invalidate()
            Notify("Return spoofed", e.name .. " now returns " .. (vals.n) .. " value(s).", "Good")
        end)
    end
    local function doReturn()
        local e = view.selectedEntry; if not e then return end
        local isRF, isBF = e.class == "RemoteFunction", e.class == "BindableFunction"
        if not isRF and not isBF then Notify("Get Return", "Select a RemoteFunction/BindableFunction.", "Bad"); return end
        showTab("script")
        task.spawn(function()
            local a = pickedPacked(e)   -- return for the call you're VIEWING (respects the call picker)
            local res = table.pack(pcall(function() if isRF then return e.remote:InvokeServer(table.unpack(a, 1, a.n)) else return e.remote:Invoke(table.unpack(a, 1, a.n)) end end))
            if not res[1] then Notify("Get Return failed", tostring(res[2]), "Bad"); return end
            local vals = { n = res.n - 1 }; for i = 2, res.n do vals[i - 1] = res[i] end
            if view.selectedEntry == e then ToString.SetCompress(nil); code.set(code.Raw .. "\n\n-- Returned:\n--[[ " .. ToString.ToString(vals) .. " ]]") end
            Notify("Got return", e.name .. " → " .. (res.n - 1) .. " value(s)", "Good")
        end)
    end
    local function doDecompile()
        local e = view.selectedEntry; if not e then return end
        local c = e.caller
        if typeof(c) ~= "Instance" then Notify("Decompile", typeof(c) == "string" and ("Caller '" .. tostring(c):sub(1, 80) .. "' resolved by name only — no script instance to decompile.") or "No caller script to decompile.", "Bad"); return end
        showTab("script"); code.set("-- Decompiling " .. callerName(c) .. " …")
        task.spawn(function()
            local src = decompileScript(c)
            if view.selectedEntry == e then code.set(src or "-- No decompiler available (native / lua.expert / Konstant all failed).") end   -- don't clobber a newer selection
        end)
    end
    local function doExport()
        if not writefileFn then Notify("Export", "writefile unavailable.", "Bad"); return end
        local parts = {}
        for _, e in view.visible do parts[#parts + 1] = cfg.codegen("Readable", e, { framework = e.framework, size = e.size, time = e.time }) end
        if #parts == 0 then Notify("Export", "Nothing to export (list is empty or filtered out).", "Warn"); return end
        local fname = CFG_DIR .. "/Rebirth_" .. (cfg.kind or "log") .. "_" .. os.date("%H%M%S") .. ".txt"
        local ok = pcall(function() ensureDir(); writefileFn(fname, table.concat(parts, "\n\n-- ──────────\n\n")) end)
        Notify(ok and "Exported" or "Export failed", ok and (fname .. "  (" .. #parts .. ")") or "write error (disk/permission?)", ok and "Good" or "Bad")
    end
    local notHttp = function() return cfg.kind ~= "http" end

    act("⧉  Copy", { primary = true, onClick = function() if code.Raw and code.Raw ~= "" then clip(code.Raw) end end })
    act("▶  Run", { tint = "Good", onClick = function()
        local e = view.selectedEntry; if not e then return end
        Runner.open("Run · " .. e.name, "Edit and Run this code (isolated from the log list).", code.Raw)
    end })
    -- Manipulate ▾ : actions that act ON the selected call
    UI.menuButton(actionBar, { text = "Manipulate", icon = "rbxassetid://10734963191", order = #actionBar:GetChildren(), items = {
        { text = "Repeat call",      icon = ACT_ICON.Repeat, onClick = doRepeat },
        { text = "Spoof return…",    icon = ACT_ICON.Spoof,  onClick = doSpoof,  condition = notHttp },
        { text = "Get return value", icon = ACT_ICON.Return, onClick = doReturn, condition = notHttp },
        { text = "Clear spoofs",     icon = ACT_ICON.Clear,  onClick = function() table.clear(view.spoofs); vlist.invalidate(); Notify("Cleared spoofs", "", "Good") end, condition = notHttp },
    } })
    -- List ▾ : actions that change what the log shows
    UI.menuButton(actionBar, { text = "List", icon = "rbxassetid://10723375128", order = #actionBar:GetChildren(), items = {
        { text = "Block remote", icon = ACT_ICON.Block, tint = "Bad", onClick = function() local e = view.selectedEntry; if e then view.block[e.remote] = true; view.block[e.name] = true; Filters.save(cfg.kind, view); vlist.invalidate(); Notify("Blocked", e.name, "Bad") end end },
        { text = "Unblock all",  icon = ACT_ICON.Unblock, onClick = function() table.clear(view.block); Filters.save(cfg.kind, view); vlist.invalidate(); Notify("Unblocked all", "", "Good") end },
        { text = "Ignore remote", icon = ACT_ICON.Ignore, onClick = function() local e = view.selectedEntry; if e then view.ignore[e.name] = true; Filters.save(cfg.kind, view); if view.selectedEntry == e then view.selectedEntry = nil; code.set(""); callBtn.Visible = false end view.dirtyFilter = true; Notify("Ignored", e.name, "Sub") end end },
        { text = "Unignore all",  onClick = function() table.clear(view.ignore); if view.autoIgnored then table.clear(view.autoIgnored) end Filters.save(cfg.kind, view); view.dirtyFilter = true; Notify("Unignored all", "", "Good") end },
        { text = "Pin / Unpin",   icon = ACT_ICON.Pin, onClick = function() local e = view.selectedEntry; if e then view.pins[e.name] = not view.pins[e.name]; Filters.save(cfg.kind, view); view.dirtyFilter = true; Notify(view.pins[e.name] and "Pinned" or "Unpinned", e.name, "Warn") end end },
        { text = "Watch fires",   icon = ACT_ICON.Pin, onClick = function() local e = view.selectedEntry; if e then view.watch[e.name] = (not view.watch[e.name]) or nil; Notify(view.watch[e.name] and "Watching" or "Unwatched", e.name .. (view.watch[e.name] and " — you'll get a toast each time it fires" or ""), "Accent") end end },
        { text = "Reveal in Explorer", icon = "rbxassetid://10723387085", onClick = function() local e = view.selectedEntry; if e and typeof(e.remote) == "Instance" and ExplorerReveal then ExplorerReveal(e.remote) else Notify("Explorer", "No instance to reveal.", "Bad") end end },
    } })
    act("⤓  Decompile", { onClick = doDecompile })
    act("⇪  Export", { onClick = doExport })

    showTab("script")
    return view
end

--==============================  Nav + pages  =============================--

addNav("Dashboard", "dashboard", "Dashboard")
addNav("Remotes", "remote", "Remote Spy")
addNav("Events", "event", "Event Spy")
addNav("Explorer", "explorer", "Explorer")
addNav("Http", "http", "HTTP Spy"); navBtns.Http.Visible = Settings.Show_http
addNav("Settings", "settings", "Settings")

--==============================  Dashboard  ===============================--

local dashRefresh
do
    local page = newPage("Dashboard")
    make("TextLabel", { Parent = page, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Dashboard", TextColor3 = "@Text", TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 28) })
    local cards = make("Frame", { Parent = page, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 76) }, { hlayout(10) })
    local function statCard(label, ck)
        local c = make("Frame", { Parent = cards, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Size = UDim2.new(0.25, -8, 1, 0) }, { corner(11), stroke("Stroke", 1), pad(14) })
        make("TextLabel", { Parent = c, BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = "@Sub", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 16) })
        return make("TextLabel", { Parent = c, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "0", TextColor3 = "@" .. ck, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 30) })
    end
    local cTotal, cRate, cUniq, cFw = statCard("Total", "Accent"), statCard("Calls / sec", "Good"), statCard("Unique", "Accent2"), statCard("Frameworks", "Framework")
    local tl = make("Frame", { Parent = page, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Position = UDim2.fromOffset(0, 124), Size = UDim2.new(1, 0, 0, 128) }, { corner(11), stroke("Stroke", 1), pad(14) })
    make("TextLabel", { Parent = tl, BackgroundTransparency = 1, Font = FONT, Text = "Call-rate (last 60s)", TextColor3 = "@Sub", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 16) })
    local barH = make("Frame", { Parent = tl, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 1, -24), ClipsDescendants = true })
    local bars = {}
    for i = 1, 60 do bars[i] = make("Frame", { Parent = barH, BackgroundColor3 = "@Accent", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new((i - 1) / 60, 1, 1, 0), Size = UDim2.new(1 / 60, -2, 0, 2) }, { corner(2) }) end
    local topCard = make("Frame", { Parent = page, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Position = UDim2.fromOffset(0, 262), Size = UDim2.new(1, 0, 1, -300) }, { corner(11), stroke("Stroke", 1), pad(14) })
    make("TextLabel", { Parent = topCard, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Top remotes", TextColor3 = "@Text", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 18) })
    local topBody = make("ScrollingFrame", { Parent = topCard, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 1, -26), ScrollBarThickness = 3, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, { vlayout(4) })
    local statusBar = make("TextLabel", { Parent = page, BackgroundTransparency = 1, Font = FONT_MONO, Text = "", TextColor3 = "@Faint", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 18) })
    function dashRefresh()
        cTotal.Text = tostring(Stats.total); cRate.Text = tostring(Stats.perSec)
        local u = 0; for _ in Stats.freq do u += 1 end; cUniq.Text = tostring(u)
        local fc = 0; for k in Stats.fw do if k ~= "Roblox" then fc += 1 end end; cFw.Text = tostring(fc)
        local mx = 1; for i = 1, 60 do mx = math.max(mx, Stats.history[i]) end
        for i = 1, 60 do local h = Stats.history[i] / mx; bars[i].Size = UDim2.new(1 / 60, -2, h, 0); bars[i].BackgroundColor3 = h > 0.66 and Theme.Bad or h > 0.33 and Theme.Warn or Theme.Accent end
        for _, c in topBody:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
        local arr = {}; for k, v in Stats.freq do arr[#arr + 1] = { k, v } end
        table.sort(arr, function(a, b) return a[2] > b[2] end)
        for i = 1, math.min(#arr, 14) do
            local r = make("Frame", { Parent = topBody, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 24) }, { corner(6), pad(0, 0, 9, 9) })
            make("TextLabel", { Parent = r, BackgroundTransparency = 1, Font = FONT, Text = arr[i][1], TextColor3 = "@Text", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -50, 1, 0) })
            make("TextLabel", { Parent = r, BackgroundTransparency = 1, Font = FONT_MONO, Text = tostring(arr[i][2]), TextColor3 = "@Accent", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(44, 24) })
        end
        local mode = ({ "Max (namecall + functions)", "Stealth (functions only)", "Passive (incoming only)" })[Settings.Capture_mode]
        statusBar.Text = string.format("capture: %s  ·  decompiler: %s  ·  actors: %s  ·  getconnections: %s",
            mode, decompile and "yes" or "no", (fn("getactors") and fn("run_on_actor")) and "yes" or "no", getconnections and "yes" or "no")
    end
end

--==============================  Remote / Event capture  ==================--

local function installRemoteHooks(view)
    local getactors = fn("getactors")
    local run_on_actor = fn("run_on_actor")
    local getgc = fn("getgc")
    local getinstancesFn = fn("getinstances")
    task.spawn(function()
        local seen = keep({})
        local function setup(inst)
            if typeof(inst) ~= "Instance" or seen[inst] then return end
            seen[inst] = true
            if inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent") then
                track(inst.OnClientEvent:Connect(function(...) if Settings.Log_which_calls <= 2 and view.accepting() then view.addRaw(cloneref(inst), true, table.pack(...), nil, nil) end end))
            elseif inst:IsA("RemoteFunction") and getcallbackvalue and USE_FUNCTION_HOOKS then
                -- known limitation: hooks OnClientInvoke only if the client callback is ALREADY set at scan time;
                -- a callback assigned later isn't re-hooked. Incoming RF invokes are rare, so this is acceptable.
                local ok, cb = pcall(getcallbackvalue, inst, "OnClientInvoke")
                if ok and typeof(cb) == "function" then pcall(function() Hooks.HookFunction(cb, function(old, ...)
                    if Settings.Log_which_calls <= 2 then local got = {}; view.addRaw(cloneref(inst), true, table.pack(...), nil, got); got[1] = table.pack(old(...)); return table.unpack(got[1], 1, got[1].n) end
                    return old(...)
                end) end) end
            end
        end
        local function scan(getter, chunk) local ok, items = pcall(getter); if not ok or typeof(items) ~= "table" then return end local i = 0; for _, v in items do pcall(setup, v); i += 1; if i % chunk == 0 then task.wait() end end end
        scan(function() return game:GetDescendants() end, 400)
        if getinstancesFn then scan(getinstancesFn, 400) end
        if getnilinstancesFn then scan(getnilinstancesFn, 200) end
        track(game.DescendantAdded:Connect(setup))
        -- DescendantAdded only sees game descendants; nil-parented remotes built on init
        -- (some frameworks/anti-cheats) are invisible to it. Re-scan nils over the startup
        -- window to connect their incoming events too. seen[] blocks any double-connect.
        if getnilinstancesFn then task.spawn(function() for _, d in { 2, 3, 5 } do task.wait(d); scan(getnilinstancesFn, 200) end end) end
        if getgc then task.spawn(function() pcall(function()
            local n = 0
            for _, v in getgc(true) do
                if typeof(v) == "Instance" then local okk, isR = pcall(function() return v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("UnreliableRemoteEvent") end); if okk and isR then pcall(setup, v) end end
                n += 1; if n % 1500 == 0 then task.wait() end; if n > 4000000 then break end
            end
        end) end) end
    end)
    if USE_FUNCTION_HOOKS then
        local function doCap(self, args, got) if view.accepting() and callPasses(checkcaller and checkcaller()) then view.addRaw(cloneref(self), false, args, resolveCaller(), got) end end
        local function out(self, args) pcall(doCap, self, args) end   -- capture never throws, so a hook can't break the game (Stealth mode)
        local fireE = Hooks.HookFunction(Instance.new("RemoteEvent").FireServer, function(old, self, ...)
            if typeof(self) ~= "Instance" or self.ClassName ~= "RemoteEvent" then return old(self, ...) end
            local args = table.pack(...); out(self, args); if view.block[self] or view.block[self.Name] then return end
            return old(self, table.unpack(args, 1, args.n))
        end, "RemoteEvent.FireServer")
        local fireU = Hooks.HookFunction(Instance.new("UnreliableRemoteEvent").FireServer, function(old, self, ...)
            if typeof(self) ~= "Instance" or self.ClassName ~= "UnreliableRemoteEvent" then return old(self, ...) end
            local args = table.pack(...); out(self, args); if view.block[self] or view.block[self.Name] then return end
            return old(self, table.unpack(args, 1, args.n))
        end, "UnreliableRemoteEvent.FireServer")
        local invoke = Hooks.HookFunction(Instance.new("RemoteFunction").InvokeServer, function(old, self, ...)
            if typeof(self) ~= "Instance" or self.ClassName ~= "RemoteFunction" then return old(self, ...) end
            local args = table.pack(...)
            local spoof = view.spoofs[self] or view.spoofs[self.Name]
            if spoof then pcall(doCap, self, args, spoof); return table.unpack(spoof, 1, spoof.n or #spoof) end
            if not view.block[self] and not view.block[self.Name] then
                local got = {}
                pcall(doCap, self, args, got)
                got[1] = table.pack(old(self, table.unpack(args, 1, args.n))); return table.unpack(got[1], 1, got[1].n)
            else pcall(doCap, self, args, nil) end
        end, "RemoteFunction.InvokeServer")
        addNamecallRoute(function(self, M, ...)
            local cn = self.ClassName
            if M == "FireServer" and cn == "RemoteEvent" then return true, table.pack(fireE(self, ...))
            elseif M == "FireServer" and cn == "UnreliableRemoteEvent" then return true, table.pack(fireU(self, ...))
            elseif M == "InvokeServer" and cn == "RemoteFunction" then return true, table.pack(invoke(self, ...)) end
            return false
        end)
        if Settings.Actor_support and getactors and run_on_actor then pcall(function()
            local genv = (fn("getgenv") and env.getgenv()) or _G
            genv.__RebirthQ = genv.__RebirthQ or {}
            local q = genv.__RebirthQ
            -- only remotes are hooked in actor VMs (not bindables): bindables are VM-local, so an actor's
            -- BindableEvent/Function never reaches the main VM anyway. pcall-wrapped; returns original result.
            local code = [[ pcall(function() local genv=(getgenv and getgenv())or _G; local q=genv.__RebirthQ; if not q or not hookfunction then return end local function w(cls,m) local old; old=hookfunction(Instance.new(cls)[m],function(self,...) if typeof(self)=="Instance" and self.ClassName==cls then q[#q+1]={self,m,table.pack(...)} end return old(self,...) end) end w("RemoteEvent","FireServer");w("UnreliableRemoteEvent","FireServer");w("RemoteFunction","InvokeServer") end) ]]
            for _, a in getactors() do pcall(run_on_actor, a, code) end
            local qh = 1
            track(RunService.Heartbeat:Connect(function()
                local n = #q; if qh > n then return end
                local b = 120
                while qh <= n and b > 0 do local e = q[qh]; q[qh] = nil; qh += 1; b -= 1; if e and typeof(e[1]) == "Instance" and view.accepting() then pcall(view.addRaw, cloneref(e[1]), false, e[3], "Actor VM", nil) end end
                if qh > #q then for k in q do q[k] = nil end; qh = 1 end
                if #q - qh + 1 > 6000 then qh = #q + 1 end
            end))
        end) end
    end
end

local function installEventHooks(view)
    if not USE_FUNCTION_HOOKS then return end
    local function doCap(self, args, got) if view.accepting() and callPasses(checkcaller and checkcaller()) then view.addRaw(cloneref(self), false, args, resolveCaller(), got) end end
    local fire = Hooks.HookFunction(Instance.new("BindableEvent").Fire, function(old, self, ...)
        if typeof(self) ~= "Instance" or self.ClassName ~= "BindableEvent" then return old(self, ...) end
        local args = table.pack(...)
        pcall(doCap, self, args, nil)
        if view.block[self] or view.block[self.Name] then return end
        return old(self, table.unpack(args, 1, args.n))
    end, "BindableEvent.Fire")
    local invoke = Hooks.HookFunction(Instance.new("BindableFunction").Invoke, function(old, self, ...)
        if typeof(self) ~= "Instance" or self.ClassName ~= "BindableFunction" then return old(self, ...) end
        local args = table.pack(...)
        local spoof = view.spoofs[self] or view.spoofs[self.Name]
        if spoof then pcall(doCap, self, args, spoof); return table.unpack(spoof, 1, spoof.n or #spoof) end
        if not view.block[self] and not view.block[self.Name] then
            local got = {}
            pcall(doCap, self, args, got)
            got[1] = table.pack(old(self, table.unpack(args, 1, args.n))); return table.unpack(got[1], 1, got[1].n)
        else pcall(doCap, self, args, nil) end
    end, "BindableFunction.Invoke")
    addNamecallRoute(function(self, M, ...)
        local cn = self.ClassName
        if M == "Fire" and cn == "BindableEvent" then return true, table.pack(fire(self, ...))
        elseif M == "Invoke" and cn == "BindableFunction" then return true, table.pack(invoke(self, ...)) end
        return false
    end)
end

local remotesView
do
    local page = newPage("Remotes")
    remotesView = createView(page, { kind = "remote", directions = true, types = { "All", "RemoteEvent", "UnreliableRemoteEvent", "RemoteFunction" }, onStat = statBump, codegen = function(mode, e, meta) return Codegen.Generate(mode, e.remote, e.incoming, e.packed, meta) end })
    installRemoteHooks(remotesView)
end
do
    local page = newPage("Events")
    local view = createView(page, { kind = "event", directions = false, types = { "All", "BindableEvent", "BindableFunction" }, onStat = statBump, codegen = function(mode, e, meta) return Codegen.Generate(mode, e.remote, false, e.packed, meta) end })
    installEventHooks(view)
end

--==============================  Explorer  ===============================--
-- A focused, spy-integrated instance explorer: lazy virtualized tree + live
-- properties/attributes. The differentiator is cross-navigation — "Reveal in
-- Explorer" from a spy row, and "Fire" a remote straight from the tree.
local function _buildExplorer()
    local page = newPage("Explorer")
    local PROPS = {
        "Name", "Value", "Enabled", "Disabled", "Visible", "Active", "RunContext",
        "Text", "RichText", "PlaceholderText", "TextScaled", "TextWrapped", "TextSize", "TextColor3", "TextTransparency", "Font",
        "Image", "ImageColor3", "ImageTransparency", "ScaleType", "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "ZIndex", "ClipsDescendants", "AutomaticSize",
        "Position", "Size", "Rotation", "AnchorPoint",
        "CFrame", "Orientation", "Anchored", "CanCollide", "CanTouch", "CanQuery", "Massless", "Transparency", "Reflectance", "Material", "Color", "BrickColor", "CastShadow", "CollisionGroup",
        "AssemblyLinearVelocity", "Mass",
        "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight", "HipHeight", "DisplayName", "AutoRotate",
        "PrimaryPart", "WorldPivot", "Adornee",
        "Brightness", "Range", "Shadows", "Texture", "SoundId", "Volume", "Playing", "Looped", "TimePosition", "PlaybackSpeed", "TimeLength",
        "MaxActivationDistance", "ActionText", "ObjectText", "HoldDuration", "RequiresLineOfSight",
        "Locked", "Archivable", "CanBeDropped",
    }
    local CAT_ORDER = { "Data", "Appearance", "Text", "Transform", "Behavior", "Other" }
    local PROP_CAT = {
        Name = "Data", Value = "Data", Archivable = "Data", RunContext = "Data", Enabled = "Data", Disabled = "Data",
        Color = "Appearance", BrickColor = "Appearance", Material = "Appearance", Transparency = "Appearance", Reflectance = "Appearance", CastShadow = "Appearance",
        BackgroundColor3 = "Appearance", BackgroundTransparency = "Appearance", BorderColor3 = "Appearance", BorderSizePixel = "Appearance",
        Image = "Appearance", ImageColor3 = "Appearance", ImageTransparency = "Appearance", ScaleType = "Appearance", TextColor3 = "Appearance", TextTransparency = "Appearance", Texture = "Appearance", Visible = "Appearance",
        Text = "Text", Font = "Text", TextSize = "Text", TextScaled = "Text", TextWrapped = "Text", RichText = "Text", PlaceholderText = "Text",
        Position = "Transform", Size = "Transform", CFrame = "Transform", Orientation = "Transform", Rotation = "Transform", AnchorPoint = "Transform", WorldPivot = "Transform",
        Anchored = "Behavior", CanCollide = "Behavior", CanTouch = "Behavior", CanQuery = "Behavior", Massless = "Behavior", Locked = "Behavior", CollisionGroup = "Behavior", Active = "Behavior", CanBeDropped = "Behavior", AutomaticSize = "Behavior", ClipsDescendants = "Behavior",
    }

    local search = UI.input(page, "Search tree (name/class) — or type, then Find code", nil, { size = UDim2.new(1, -190, 0, 30) })
    search.Parent.Position = UDim2.fromOffset(0, 0)
    local codeBtn, codeLbl = UI.button(page, { text = "Find code", autoX = false })
    codeBtn.AnchorPoint = Vector2.new(1, 0); codeBtn.Position = UDim2.new(1, -96, 0, 0); codeBtn.Size = UDim2.fromOffset(90, 30); codeBtn.Visible = DECOMPILE_OK
    local refreshBtn = UI.button(page, { text = "Refresh", autoX = false })
    refreshBtn.AnchorPoint = Vector2.new(1, 0); refreshBtn.Position = UDim2.new(1, 0, 0, 0); refreshBtn.Size = UDim2.fromOffset(90, 30)

    local body = make("Frame", { Parent = page, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 1, -40) })
    local treePanel = make("Frame", { Parent = body, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Size = UDim2.new(0.46, -6, 1, 0) }, { corner(11), stroke("Stroke", 1) })
    local treeBody  = make("Frame", { Parent = treePanel, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 1, -42) })
    -- selection bar: live count + batch-decompile + scripts-only filter toggle (DECOMPILER-style)
    local treeBar = make("Frame", { Parent = treePanel, BackgroundColor3 = "@Panel", BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 34) }, { corner(11) })
    local cntLbl = make("TextButton", { Parent = treeBar, AutoButtonColor = false, BackgroundTransparency = 1, Font = FONT, Text = "0 selected", TextColor3 = "@Sub", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(0.34, 0, 1, 0) })
    local function refreshCount() cntLbl.Text = nChecked .. " selected" .. (nChecked > 0 and "  ·  clear" or "") end
    local dcBtn = UI.button(treeBar, { text = "Decompile ✓", primary = true, autoX = false, textSize = 12 })
    dcBtn.AnchorPoint = Vector2.new(1, 0.5); dcBtn.Position = UDim2.new(1, -8, 0.5, 0); dcBtn.Size = UDim2.fromOffset(104, 24)
    local soBtn = UI.button(treeBar, { text = "Scripts only", autoX = false, textSize = 12 })
    soBtn.AnchorPoint = Vector2.new(1, 0.5); soBtn.Position = UDim2.new(1, -118, 0.5, 0); soBtn.Size = UDim2.fromOffset(94, 24)
    local propPanel = make("Frame", { Parent = body, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Position = UDim2.new(0.46, 6, 0, 0), Size = UDim2.new(0.54, -6, 1, 0) }, { corner(11), stroke("Stroke", 1) })

    -- property panel header (fixed) + scrolling body
    local propHead = make("Frame", { Parent = propPanel, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 64) }, { pad(10, 4, 10, 10) })
    local pName = make("TextLabel", { Parent = propHead, BackgroundTransparency = 1, RichText = true, Font = FONT_BOLD, Text = "Select an instance", TextColor3 = "@Text", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, 0, 0, 18) })
    local pPath = make("TextButton", { Parent = propHead, AutoButtonColor = false, BackgroundTransparency = 1, Font = FONT_MONO, Text = "", TextColor3 = "@Faint", TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 14) })
    local pBtns = make("Frame", { Parent = propHead, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 22) }, { hlayout(6) })
    local propScroll = make("ScrollingFrame", { Parent = propPanel, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 66), Size = UDim2.new(1, 0, 1, -66), ScrollBarThickness = 4, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, { vlayout(4), pad(10, 10, 10, 10) })
    -- decompiled-source view (shown instead of properties when a script is selected — the merged Scripts tab)
    local scrFrame = make("Frame", { Parent = propPanel, BackgroundTransparency = 1, Visible = false, Position = UDim2.fromOffset(8, 68), Size = UDim2.new(1, -16, 1, -76) })
    local scrView = codeView(scrFrame)

    local expanded = {}                  -- inst -> true
    local selectedInst = nil
    local searchMatches = nil            -- flat list while searching
    local rowMap = {}

    -- ── DECOMPILER-style tree: filter to scripts/remotes, checkbox multi-select, batch decompile ──
    local TARGET = { Script = true, LocalScript = true, ModuleScript = true, RemoteEvent = true, RemoteFunction = true, UnreliableRemoteEvent = true, BindableEvent = true, BindableFunction = true }
    local SCRIPTCLS = { Script = true, LocalScript = true, ModuleScript = true }
    local function clsOf(inst) local ok, c = pcall(function() return inst.ClassName end); return ok and c or "" end
    local function nmOf(inst) local ok, n = pcall(function() return inst.Name end); return ok and tostring(n) or "?" end
    local scriptsOnly = true          -- filtered tree (DECOMPILER default); toggle off for the full instance tree
    local checked, nChecked = {}, 0   -- script inst -> true (batch-decompile selection)
    local showSet = nil               -- inst -> true (instances to show while filtered); nil = needs rebuild
    local scriptDescCache = {}        -- folder -> { script descendants } for tri-state; cleared on rebuild

    local function childrenOf(inst) local ok, c = pcall(function() return inst:GetChildren() end); return ok and c or {} end
    local function compactVal(v)
        local ok, s = pcall(function() ToString.SetCompress(nil); return ToString.ToString(v, 0) end)
        ToString.SetCompress(nil)
        s = ok and s or ("<" .. typeof(v) .. ">")
        s = s:gsub("%s*\n%s*", " ")
        if #s > 140 then s = s:sub(1, 138) .. "…" end
        return s
    end

    -- ── full property enumeration via the Roblox API dump (the same source Dex uses) ──
    local gethiddenproperty = fn("gethiddenproperty")
    local sethiddenproperty = fn("sethiddenproperty")
    local setscriptable     = fn("setscriptable")
    local ApiProps, apiState = nil, "idle"   -- idle | loading | ready | fail
    local function httpGetText(u)
        local ok, r = pcall(function() return game:HttpGet(u) end)
        if ok and type(r) == "string" and #r > 0 then return r end
        if httpRequestFn then local ok2, resp = pcall(httpRequestFn, { Url = u, Method = "GET" }); if ok2 and type(resp) == "table" and resp.Body and #resp.Body > 0 then return resp.Body end end
        return nil
    end
    local function readProp(inst, name)
        local ok, v = pcall(function() return inst[name] end)
        if ok then return true, v end
        if gethiddenproperty then local ok2, v2 = pcall(gethiddenproperty, inst, name); if ok2 then return true, v2 end end
        return false
    end
    local function writeProp(inst, name, nv)
        if pcall(function() inst[name] = nv end) then return true end
        if setscriptable then pcall(setscriptable, inst, name, true); if pcall(function() inst[name] = nv end) then return true end end
        if sethiddenproperty then return (pcall(sethiddenproperty, inst, name, nv)) end
        return false
    end
    local function loadApiDump(after)
        if apiState == "ready" then if after then pcall(after) end return end
        if apiState == "loading" then return end
        apiState = "loading"
        task.spawn(function()
            local ver = httpGetText("https://setup.roblox.com/versionQTStudio")
            local raw
            if ver then ver = ver:gsub("%s+", ""); raw = httpGetText("https://setup.roblox.com/" .. ver .. "-API-Dump.json") end
            raw = raw or httpGetText("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json")
            local ok, api = pcall(function() return HttpService:JSONDecode(raw or "") end)
            if not ok or type(api) ~= "table" or not api.Classes then apiState = "fail"; if after then pcall(after) end return end
            local own, super = {}, {}
            for _, class in api.Classes do
                if type(class) == "table" and class.Name then
                    super[class.Name] = class.Superclass
                    local list = {}
                    for _, m in (class.Members or {}) do
                        if type(m) == "table" and m.MemberType == "Property" and m.Name then
                            local skip = false
                            for _, tg in (m.Tags or {}) do if tg == "Deprecated" or tg == "Hidden" then skip = true break end end
                            local sec = m.Security; local rs = (type(sec) == "table" and sec.Read) or sec
                            if rs and rs ~= "None" and rs ~= "PluginSecurity" and rs ~= "LocalUserSecurity" then skip = true end
                            if not skip then list[#list + 1] = m.Name end
                        end
                    end
                    own[class.Name] = list
                end
            end
            ApiProps = setmetatable({}, { __index = function(t, cls)   -- flatten with inheritance, cached per class
                local out, seen = {}, {}
                local c = cls
                while c do for _, nm in (own[c] or {}) do if not seen[nm] then seen[nm] = true; out[#out + 1] = nm end end c = super[c] end
                rawset(t, cls, out); return out
            end })
            apiState = "ready"; if after then pcall(after) end
        end)
    end

    -- ── authentic Studio class icons (same as Dex: local ClassImages texture,
    --    linear 16px strip indexed by ReflectionMetadata.ExplorerImageIndex) ──
    local CLASS_IMG = "rbxasset://textures/ClassImages.PNG"
    local ICON_FALLBACK = {
        Part = 1, MeshPart = 1, TrussPart = 1, WedgePart = 1, UnionOperation = 77, Terrain = 65, Model = 2, Folder = 70,
        Script = 6, LocalScript = 18, ModuleScript = 71, Humanoid = 9, Players = 21, Player = 12, Workspace = 19, Tool = 17,
        RemoteEvent = 80, RemoteFunction = 79, BindableEvent = 67, BindableFunction = 66, Sound = 11, Decal = 7, Texture = 10,
        Frame = 48, ScrollingFrame = 48, TextLabel = 50, TextButton = 51, TextBox = 51, ImageLabel = 49, ImageButton = 52,
        ScreenGui = 47, BillboardGui = 64, SurfaceGui = 64, Lighting = 13, ReplicatedStorage = 72, ReplicatedFirst = 72,
        StarterGui = 46, StarterPack = 20, SoundService = 31, IntValue = 4, NumberValue = 4, StringValue = 4, BoolValue = 4,
        ObjectValue = 4, Vector3Value = 4, CFrameValue = 4, Color3Value = 4, Motor6D = 34, Weld = 34, Seat = 35, VehicleSeat = 35,
        SpawnLocation = 25, ParticleEmitter = 69, PointLight = 13, SpotLight = 13, Team = 24, Teams = 23, Configuration = 70,
    }
    local iconIndex = setmetatable({}, { __index = function(_, k) return ICON_FALLBACK[k] end })
    local function setRowIcon(img, className) img.ImageRectOffset = Vector2.new(16 * (iconIndex[className] or 0), 0) end
    local rmdState = "idle"
    local function loadRMD()
        if rmdState ~= "idle" then return end
        rmdState = "loading"
        task.spawn(function()
            local xml = httpGetText("https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml")
            if not xml then rmdState = "fail"; return end
            local map = {}
            for props in xml:gmatch('<Item class="ReflectionMetadataClass">%s*<Properties>(.-)</Properties>') do
                local name = props:match('<string name="Name">(.-)</string>')
                local idx = props:match('<int name="ExplorerImageIndex">(.-)</int>')
                if name and idx then map[name] = tonumber(idx) end
            end
            iconIndex = setmetatable(map, { __index = function(_, k) return ICON_FALLBACK[k] end })   -- RMD over fallback
            rmdState = "ready"
            if treeList then treeList.invalidate() end
        end)
    end

    -- ── tree ──
    local treeList, renderProps, contextFor, toggleCheck
    -- build the "show" set: every script/remote plus its ancestor folders (so branches with no scripts are hidden)
    local function rebuildFilter()
        showSet = {}; scriptDescCache = {}
        local targets = {}
        local function collect(v) if typeof(v) == "Instance" and TARGET[clsOf(v)] then targets[#targets + 1] = v end end
        pcall(function() for _, v in game:GetDescendants() do collect(v) end end)
        if getnilinstancesFn then pcall(function() for _, v in getnilinstancesFn() do collect(v) end end) end
        for _, t in targets do
            showSet[t] = true
            local isS = SCRIPTCLS[clsOf(t)]
            local ok, p = pcall(function() return t.Parent end); p = ok and p or nil
            while p and p ~= game do
                showSet[p] = true
                if isS then local d = scriptDescCache[p]; if not d then d = {}; scriptDescCache[p] = d end; d[#d + 1] = t end   -- pre-fill tri-state lists in one pass
                local ok2, pp = pcall(function() return p.Parent end); p = ok2 and pp or nil
            end
        end
    end
    -- folder -> its script descendants, pre-filled by rebuildFilter in one pass (no per-bind tree walk)
    local EMPTY_DESC = {}
    local function scriptDescOf(inst) return scriptDescCache[inst] or EMPTY_DESC end
    local function shownKids(inst)
        local kids = childrenOf(inst)
        if scriptsOnly and showSet then
            local out = {}; for _, c in kids do if showSet[c] then out[#out + 1] = c end end; kids = out
        end
        table.sort(kids, function(a, b)
            local ta, tb = TARGET[clsOf(a)] or false, TARGET[clsOf(b)] or false
            if ta ~= tb then return not ta end   -- containers first, then scripts/remotes
            return nmOf(a):lower() < nmOf(b):lower()
        end)
        return kids
    end
    local function flatten()
        if searchMatches then return searchMatches end
        if scriptsOnly and not showSet then rebuildFilter() end
        local out = {}
        local function walk(inst, depth)
            local kids = shownKids(inst)
            out[#out + 1] = { inst = inst, depth = depth, hasKids = #kids > 0 }
            if expanded[inst] and #kids > 0 then for _, c in kids do walk(c, depth + 1) end end
        end
        walk(game, 0)
        return out
    end
    local function refreshTree() treeList.setItems(flatten()); treeList.tick() end   -- flatten rebuilds the filter only when showSet was invalidated (nil)
    local function selectInst(inst) selectedInst = inst; pcall(renderProps, inst); if treeList then treeList.invalidate() end end
    -- batch-selection helpers
    local function setChecked(s, on)
        if on and not checked[s] then checked[s] = true; nChecked += 1
        elseif not on and checked[s] then checked[s] = nil; nChecked -= 1 end
    end
    toggleCheck = function(inst)
        if SCRIPTCLS[clsOf(inst)] then setChecked(inst, not checked[inst])
        else
            local desc = scriptDescOf(inst); if #desc == 0 then return end
            local allOn = true; for _, s in desc do if not checked[s] then allOn = false; break end end
            for _, s in desc do setChecked(s, not allOn) end
        end
        refreshCount(); treeList.invalidate()
    end

    local function buildTreeRow()
        local row = make("TextButton", { AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel2", BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 24) }, {
            corner(6),
            make("ImageButton", { Name = "Arrow", AutoButtonColor = false, BackgroundTransparency = 1, Image = "rbxassetid://10709791437", ImageColor3 = "@Sub", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(11, 11), Rotation = 0, Visible = false }),
            make("TextButton", { Name = "Chk", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel3", Text = "", Font = FONT_BOLD, TextSize = 11, TextColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(14, 14), Visible = false, ZIndex = 3 }, { corner(4) }),
            make("ImageLabel", { Name = "Ico", BackgroundTransparency = 1, Image = CLASS_IMG, ImageRectSize = Vector2.new(16, 16), ScaleType = Enum.ScaleType.Crop, AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(16, 16) }),
            make("TextLabel", { Name = "Nm", BackgroundTransparency = 1, Font = FONT, TextSize = 12, TextColor3 = "@Text", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -40, 1, 0) }),
            make("TextLabel", { Name = "Cls", BackgroundTransparency = 1, Font = FONT_REG, TextSize = 10, TextColor3 = "@Faint", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X }),
        })
        track(row.MouseEnter:Connect(function() if not row:GetAttribute("sel") then row.BackgroundTransparency = 0.7 end end))
        track(row.MouseLeave:Connect(function() if not row:GetAttribute("sel") then row.BackgroundTransparency = 1 end end))
        track(row.Arrow.MouseButton1Click:Connect(function()
            local node = rowMap[row]; if not node or not node.hasKids then return end
            expanded[node.inst] = (not expanded[node.inst]) or nil
            refreshTree()
        end))
        track(row.Chk.MouseButton1Click:Connect(function()
            local node = rowMap[row]; if node then toggleCheck(node.inst) end
        end))
        track(row.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                local node = rowMap[row]; if node and contextFor then pcall(contextFor, node.inst, input.Position) end
            end
        end))
        return row
    end
    local function bindTreeRow(row, node)
        rowMap[row] = node
        local inst = node.inst
        local x = node.search and 2 or (node.depth * 14 + 4)
        row.Arrow.Position = UDim2.fromOffset(x + 5, 12)
        row.Arrow.Visible = node.hasKids and not node.search
        row.Arrow.Rotation = expanded[inst] and 90 or 0
        local cls = clsOf(inst)
        -- checkbox: scripts get an individual box; folders a tri-state over their script descendants
        local isScr = SCRIPTCLS[cls] and true or false
        local desc = (not isScr and not node.search and scriptsOnly) and scriptDescOf(inst) or nil
        local showChk = (isScr or (desc and #desc > 0)) and not node.search and true or false
        row.Chk.Visible = showChk
        if showChk then
            row.Chk.Position = UDim2.fromOffset(x + 18, 12)
            local st   -- 0 none, 1 all, 2 some
            if isScr then st = checked[inst] and 1 or 0
            else local c = 0; for _, s in desc do if checked[s] then c += 1 end end; st = (c == 0 and 0) or (c == #desc and 1) or 2 end
            row.Chk.Text = (st == 1 and "✓") or (st == 2 and "–") or ""
            row.Chk.BackgroundColor3 = (st == 1 and Theme.Good) or (st == 2 and Theme.Warn) or Theme.Panel3
        end
        local ix = node.search and 4 or (x + 35)
        row.Ico.Position = UDim2.fromOffset(ix, 12); setRowIcon(row.Ico, cls)
        local nx = ix + 20
        local okn, nm = pcall(function() return node.search and inst:GetFullName() or inst.Name end)
        row.Nm.Position = UDim2.fromOffset(nx, 0); row.Nm.Size = UDim2.new(1, -nx - 66, 1, 0)
        row.Nm.Text = okn and nm or "?"
        row.Cls.Text = cls ~= "" and cls or "?"
        local seld = (inst == selectedInst)
        row:SetAttribute("sel", seld)
        row.BackgroundColor3 = seld and Theme.Accent or Theme.Panel2
        row.BackgroundTransparency = seld and 0.78 or 1
        row.Nm.TextColor3 = seld and Theme.Accent2 or Theme.Text
    end
    treeList = VirtualList(treeBody, 26, buildTreeRow, bindTreeRow, function(node) selectInst(node.inst) end)

    -- ── properties / attributes ──
    local function valueRow(name, value, setter, order)
        local t = typeof(value)
        local rowf = make("Frame", { Parent = propScroll, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = order }, { corner(7), pad(0, 0, 9, 9) })
        make("TextLabel", { Parent = rowf, BackgroundTransparency = 1, Font = FONT, Text = name, TextColor3 = "@Sub", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.42, 0, 1, 0) })
        if setter and t == "boolean" then
            local b = make("TextButton", { Parent = rowf, AutoButtonColor = false, BackgroundTransparency = 1, Font = FONT_BOLD, Text = tostring(value), TextColor3 = value and "@Good" or "@Bad", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.58, 0, 1, 0) })
            local cur = value
            b.MouseButton1Click:Connect(function() local nv = not cur; if setter(nv) then cur = nv; b.Text = tostring(nv); b.TextColor3 = nv and Theme.Good or Theme.Bad else Notify("Property", "Couldn't set " .. name, "Bad") end end)
        elseif setter and (t == "number" or t == "string") then
            local box = make("TextBox", { Parent = rowf, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Font = FONT_MONO, Text = tostring(value), TextColor3 = "@Text", TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.58, 0, 0, 20) }, { corner(5), pad(0, 0, 7, 7) })
            box.FocusLost:Connect(function()
                local nv = (t == "number") and tonumber(box.Text) or box.Text
                if nv == nil then box.Text = tostring(value); return end
                if not setter(nv) then box.Text = tostring(value); Notify("Property", "Couldn't set " .. name, "Bad") end
            end)
        else
            local lbl = make("TextButton", { Parent = rowf, AutoButtonColor = false, BackgroundTransparency = 1, Font = FONT_MONO, Text = compactVal(value), TextColor3 = "@Text", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.58, 0, 1, 0) })
            lbl.MouseButton1Click:Connect(function() clip(compactVal(value)) end)
        end
    end
    local function sectionHeader(text, order)
        make("TextLabel", { Parent = propScroll, BackgroundTransparency = 1, Font = FONT_BOLD, Text = text, TextColor3 = "@Accent2", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = order })
    end
    local function isRemote(inst) local ok, r = pcall(function() return inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent") or inst:IsA("RemoteFunction") or inst:IsA("BindableEvent") or inst:IsA("BindableFunction") end); return ok and r end
    local function isScript(inst) local ok, r = pcall(function() return inst:IsA("LuaSourceContainer") end); return ok and r end
    local decompiled = {}   -- script -> decompiled source (cache, shared by select + code-search)
    local function remoteTemplate(inst)
        ToString.SetCompress(nil); local path = ToString.GetPath(inst); local cls = inst.ClassName
        if cls == "RemoteEvent" or cls == "UnreliableRemoteEvent" then return path .. ":FireServer()"
        elseif cls == "RemoteFunction" then return "local result = " .. path .. ":InvokeServer()\nprint(result)"
        elseif cls == "BindableEvent" then return path .. ":Fire()"
        elseif cls == "BindableFunction" then return "local result = " .. path .. ":Invoke()\nprint(result)" end
        return path
    end

    -- ── right-click context menu (Dex-style) ──
    local ctxMenu, ctxBackdrop
    local function closeCtx() if ctxBackdrop then ctxBackdrop:Destroy(); ctxBackdrop = nil end if ctxMenu then ctxMenu:Destroy(); ctxMenu = nil end end
    local function expandAll(inst, depth)
        expanded[inst] = true
        if (depth or 0) >= 6 then return end
        for _, c in childrenOf(inst) do if #childrenOf(c) > 0 then expandAll(c, (depth or 0) + 1) end end
    end
    contextFor = function(inst, pos)
        closeCtx()
        ToString.SetCompress(nil)
        local path = (pcall(function() return ToString.GetPath(inst) end)) and ToString.GetPath(inst) or inst.Name
        local items = {
            { text = "Select & inspect", onClick = function() selectInst(inst) end },
            { text = "Copy Path", onClick = function() clip(path) end },
            { text = "Copy Reference", onClick = function() clip("local inst = " .. path) end },
            { text = "Fire / Invoke", remote = true, onClick = function() Runner.open("Fire · " .. inst.Name, "Edit the call and press Run.", remoteTemplate(inst)) end },
            { text = "Expand descendants", onClick = function() expandAll(inst, 0); refreshTree() end },
            { text = "Collapse", onClick = function() expanded[inst] = nil; refreshTree() end },
            { text = "Destroy", tint = "Bad", onClick = function() local ok = pcall(function() inst:Destroy() end); if selectedInst == inst then selectInst(nil) end refreshTree(); Notify("Explorer", ok and ("Destroyed " .. (path:match("[%w_]+$") or "")) or "Couldn't destroy", ok and "Good" or "Bad") end },
        }
        local shown = {}
        for _, it in items do if not (it.remote and not isRemote(inst)) then shown[#shown + 1] = it end end
        ctxBackdrop = make("TextButton", { Parent = ScreenGui, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 95 })
        ctxBackdrop.MouseButton1Click:Connect(closeCtx); ctxBackdrop.MouseButton2Click:Connect(closeCtx)
        -- clamp to the viewport so a right-click near the bottom/right edge doesn't spill the menu off-screen
        local mw, mh = 186 * UIScaleObj.Scale, (#shown * 28 + 6) * UIScaleObj.Scale
        local vp = viewport()
        local px = math.clamp(pos.X, 0, math.max(0, vp.X - mw)); local py = math.clamp(pos.Y, 0, math.max(0, vp.Y - mh))
        ctxMenu = make("Frame", { Parent = ScreenGui, BackgroundColor3 = "@Panel2", BorderSizePixel = 0, Position = UDim2.fromOffset(px, py), Size = UDim2.fromOffset(186, #shown * 28 + 6), ZIndex = 96 }, { corner(8), stroke("StrokeS", 1), pad(3, 3, 3, 3), make("UIScale", { Scale = UIScaleObj.Scale }), vlayout(2) })
        for _, it in shown do
            local b = make("TextButton", { Parent = ctxMenu, AutoButtonColor = false, BackgroundColor3 = "@Hover", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Text = "", ZIndex = 97 }, { corner(6) })
            make("TextLabel", { Parent = b, BackgroundTransparency = 1, Font = FONT, TextSize = 13, Text = it.text, TextColor3 = it.tint == "Bad" and "@Bad" or "@Text", TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -18, 1, 0), ZIndex = 97 })
            b.MouseEnter:Connect(function() b.BackgroundTransparency = 0 end); b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
            b.MouseButton1Click:Connect(function() closeCtx(); if it.onClick then it.onClick() end end)
        end
    end
    function renderProps(inst)
        for _, c in propScroll:GetChildren() do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
        for _, c in pBtns:GetChildren() do if c:IsA("TextButton") then c:Destroy() end end
        if not inst then pName.Text = "Select an instance"; pPath.Text = ""; scrFrame.Visible = false; propScroll.Visible = true; return end
        local okn = pcall(function() pName.Text = richEsc(inst.Name) .. '   <font color="#7a6c59">' .. inst.ClassName .. '</font>' end)
        if not okn then pName.Text = "?" end
        ToString.SetCompress(nil)
        local path = (pcall(function() return ToString.GetPath(inst) end)) and ToString.GetPath(inst) or inst.Name
        pPath.Text = path
        -- header buttons
        UI.button(pBtns, { text = "Copy path", textSize = 11, order = 1, onClick = function() clip(path) end }).Size = UDim2.fromOffset(0, 22)
        -- a SCRIPT shows its decompiled source instead of properties (the merged Scripts tab)
        if isScript(inst) then
            propScroll.Visible = false; scrFrame.Visible = true
            UI.button(pBtns, { text = "Copy source", primary = true, textSize = 11, order = 2, onClick = function() if scrView.Raw and scrView.Raw ~= "" then clip(scrView.Raw) end end }).Size = UDim2.fromOffset(0, 22)
            if decompiled[inst] and decompiled[inst] ~= "" then scrView.set(decompiled[inst])   -- "" = a scan couldn't decompile it; fall through to retry rather than show a blank panel
            else
                scrView.set("-- decompiling " .. tostring(inst.Name) .. " …")
                task.spawn(function()
                    local src = decompileScript(inst) or "-- (no source — empty, native-only, or protected)"
                    decompiled[inst] = src
                    if selectedInst == inst then scrView.set(src) end
                end)
            end
            return
        end
        scrFrame.Visible = false; propScroll.Visible = true
        if isRemote(inst) then
            UI.button(pBtns, { text = "Fire", primary = true, textSize = 11, order = 2, onClick = function() Runner.open("Fire · " .. inst.Name, "Edit the call and press Run.", remoteTemplate(inst)) end }).Size = UDim2.fromOffset(0, 22)
        end
        local ord = 0
        -- attributes
        local attrs = (pcall(function() return inst:GetAttributes() end)) and inst:GetAttributes() or {}
        local anyAttr = false; for _ in attrs do anyAttr = true; break end
        if anyAttr then
            ord += 1; sectionHeader("ATTRIBUTES", ord)
            for k, v in attrs do ord += 1; valueRow(k, v, function(nv) return (pcall(function() inst:SetAttribute(k, nv) end)) end, ord) end
        end
        -- properties — full API-dump set when loaded (curated fallback while loading),
        -- bucketed into Dex-style categories (Data / Appearance / Transform / …)
        local full = (apiState == "ready" and inst.ClassName and ApiProps[inst.ClassName]) or nil
        if not full then ord += 1; sectionHeader("PROPERTIES  ·  " .. (apiState == "loading" and "loading full set…" or apiState == "fail" and "basic (dump unavailable)" or "basic"), ord) end
        local names, buckets, seen, shown = full or PROPS, {}, {}, 0
        for _, p in names do
            if not seen[p] and p ~= "Parent" and p ~= "ClassName" then
                seen[p] = true
                local ok, val = readProp(inst, p)
                if ok and val ~= nil and typeof(val) ~= "function" then
                    local cat = PROP_CAT[p] or "Other"
                    local b = buckets[cat]; if not b then b = {}; buckets[cat] = b end
                    b[#b + 1] = { name = p, val = val }
                end
            end
        end
        for _, cat in CAT_ORDER do
            local b = buckets[cat]
            if b and #b > 0 then
                table.sort(b, function(a, c) return a.name < c.name end)
                ord += 1; sectionHeader(cat, ord)
                for _, it in b do
                    shown += 1; ord += 1
                    local vt = typeof(it.val)
                    local setter = (vt == "boolean" or vt == "number" or vt == "string") and function(nv) return writeProp(inst, it.name, nv) end or nil
                    valueRow(it.name, it.val, setter, ord)
                end
            end
        end
        if shown == 0 then ord += 1; make("TextLabel", { Parent = propScroll, BackgroundTransparency = 1, Font = FONT_REG, Text = "(no readable properties)", TextColor3 = "@Faint", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = ord }) end
        -- lazily pull the full dump, then re-render this same instance when it's ready
        if apiState ~= "ready" then loadApiDump(function() if selectedInst == inst then renderProps(inst) end end) end
    end

    -- ── reveal (spy → explorer) ──
    function ExplorerReveal(inst)
        if typeof(inst) ~= "Instance" then return end
        selectPage("Explorer")
        searchMatches = nil
        local okd = pcall(function() return inst:IsDescendantOf(game) end)
        if not (okd and inst:IsDescendantOf(game)) then refreshTree(); selectInst(inst); Notify("Explorer", inst.Name .. " is nil-parented — properties only.", "Warn"); return end
        local p = inst.Parent
        while p do expanded[p] = true; if p == game then break end p = p.Parent end
        if scriptsOnly then showSet = nil end   -- rebuild the filter so a freshly-seen remote is included
        local flat = flatten(); treeList.setItems(flat); treeList.tick()
        selectInst(inst)
        for i, node in flat do if node.inst == inst then treeList.scroll.CanvasPosition = Vector2.new(0, math.max(0, (i - 1) * 26 - 80)); treeList.invalidate(); break end end
    end

    -- ── init + search ──
    -- force-load every standard service so the tree shows the FULL game tree.
    -- game:GetChildren() only returns services already instantiated, which left big gaps.
    for _, svc in { "Workspace","Players","Lighting","ReplicatedStorage","ReplicatedFirst","ServerStorage","ServerScriptService","StarterGui","StarterPack","StarterPlayer","SoundService","Chat","Teams","LocalizationService","TestService","RunService","UserInputService","ContextActionService","TweenService","Debris","CollectionService","PhysicsService","MarketplaceService","HttpService","TextService","GuiService","PathfindingService","ProximityPromptService","TeleportService","PolicyService","MaterialService","InsertService","BadgeService","GroupService","AssetService","AvatarEditorService","TextChatService","VoiceChatService" } do
        pcall(function() game:GetService(svc) end)
    end
    -- ── batch decompile: dump every checked script into the source view + clipboard (+ file) ──
    local function decompileSelected()
        local sel = {}; for s in checked do sel[#sel + 1] = s end
        if #sel == 0 then Notify("Batch decompile", "No scripts checked — tick some in the tree first.", "Warn"); return end
        Notify("Batch decompile", "Decompiling " .. #sel .. " script(s)…", "Accent", 2)
        selectedInst = nil; propScroll.Visible = false; scrFrame.Visible = true; scrView.set("-- decompiling " .. #sel .. " script(s)…")   -- immediate feedback
        task.spawn(function()
            local parts = {}
            for i, s in sel do
                local okp, path = pcall(function() return s:GetFullName() end)
                local src = decompiled[s]
                if src == nil or src == "" then src = decompileScript(s) or "-- (no source)"; decompiled[s] = src end
                parts[#parts + 1] = ("-- [%d/%d] %s  (%s)\n%s"):format(i, #sel, okp and path or nmOf(s), clsOf(s), src)
                if i % 3 == 0 then task.wait() end
            end
            local combined = table.concat(parts, "\n\n-- " .. string.rep("—", 24) .. "\n\n")
            if selectedInst == nil then scrView.set(combined) end   -- don't clobber a script the user selected during the batch
            if setclipboard then pcall(setclipboard, combined) end
            local saved = ""
            if writefileFn then local fn2 = CFG_DIR .. "/Rebirth_dump_" .. os.date("%H%M%S") .. ".lua"; if pcall(function() ensureDir(); writefileFn(fn2, combined) end) then saved = " · saved to file" end end
            Notify("Batch decompile", #sel .. " script(s) done — copied" .. saved, "Good")
        end)
    end
    track(dcBtn.MouseButton1Click:Connect(decompileSelected))
    track(soBtn.MouseButton1Click:Connect(function()
        scriptsOnly = not scriptsOnly
        soBtn.Lbl.Text = scriptsOnly and "Scripts only" or "Full tree"
        showSet = nil; searchMatches = nil
        refreshTree()
    end))
    track(cntLbl.MouseButton1Click:Connect(function()   -- click the count to clear the batch selection
        if nChecked == 0 then return end
        checked = {}; nChecked = 0; refreshCount(); treeList.invalidate()
    end))

    expanded[game] = true
    refreshTree(); renderProps(nil); loadRMD()   -- fetch real Studio icon indices in the background
    explorerTick = function() pcall(function() treeList.tick() end) end   -- driven by the runtime loop so scrolling repaints the window
    track(refreshBtn.MouseButton1Click:Connect(function() showSet = nil; refreshTree(); if selectedInst then pcall(renderProps, selectedInst) end end))
    -- "Find code": decompile every client script and grep its source for the search text
    -- (the merged Script Scanner). Matches show in the tree; click one to read its source.
    local scanning = false
    local searchToken = 0   -- shared by Find-code + tree text-search so they don't clobber each other
    track(codeBtn.MouseButton1Click:Connect(function()
        if scanning then scanning = false; codeLbl.Text = "Find code"; return end   -- click again = stop
        local q = (search.Text or ""):lower()
        scanning = true; codeLbl.Text = "Scanning…"; searchToken += 1; local myTok = searchToken
        task.spawn(function()
            local list, seen = {}, {}
            local function add(v)
                if typeof(v) ~= "Instance" or seen[v] or not isScript(v) then return end
                if v:IsDescendantOf(ScreenGui) then return end
                local okc = pcall(function() return v:IsDescendantOf(CoreGui) end); if okc and v:IsDescendantOf(CoreGui) then return end
                seen[v] = true; list[#list + 1] = v
            end
            pcall(function() for _, v in game:GetDescendants() do add(v) end end)
            if getnilinstancesFn then pcall(function() for _, v in getnilinstancesFn() do add(v) end end) end
            local matches, done = {}, 0
            for _, scr in list do
                if not scanning or done >= 600 or myTok ~= searchToken then break end
                if decompiled[scr] == nil then decompiled[scr] = decompileScript(scr) or "" end
                done += 1
                if q == "" or decompiled[scr]:lower():find(q, 1, true) then matches[#matches + 1] = { inst = scr, depth = 0, hasKids = false, search = true } end
                codeLbl.Text = done .. "/" .. #list
                if #matches >= 400 then break end
                task.wait()
            end
            if myTok == searchToken then searchMatches = (#matches > 0) and matches or nil; refreshTree() end   -- skip if a newer search superseded this scan
            local was = scanning; scanning = false; codeLbl.Text = "Find code"
            Notify("Code search", #matches .. " script" .. (#matches == 1 and "" or "s") .. (q ~= "" and (" matched '" .. q .. "'") or " found") .. (was and "" or " (stopped)"), "Good")
        end)
    end))
    track(search:GetPropertyChangedSignal("Text"):Connect(function()
        local q = search.Text
        searchToken += 1; local my = searchToken
        task.delay(0.28, function()
            if my ~= searchToken then return end
            if q == "" then searchMatches = nil; refreshTree(); return end
            local ql = q:lower()
            local matches, scanned = {}, 0
            local function scan(inst)
                if #matches >= 600 or my ~= searchToken then return end
                for _, c in childrenOf(inst) do
                    scanned += 1; if scanned % 2500 == 0 then task.wait() end
                    if #matches >= 600 or my ~= searchToken then return end
                    local okn2, nm = pcall(function() return c.Name end)
                    local cls = (pcall(function() return c.ClassName end)) and c.ClassName or ""
                    if okn2 and (nm:lower():find(ql, 1, true) or cls:lower():find(ql, 1, true)) then matches[#matches + 1] = { inst = c, depth = 0, hasKids = false, search = true } end
                    scan(c)
                end
            end
            scan(game)
            if my ~= searchToken then return end
            searchMatches = matches; refreshTree()
        end)
    end))
end
_buildExplorer()

--==============================  HTTP Spy (lite)  =========================--

local httpTick
do
    local page = newPage("Http")
    local entries, visible, byId, nextId, paused, filterText = {}, {}, {}, 0, false, ""
    make("TextLabel", { Parent = page, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "HTTP", TextColor3 = "@Text", TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(2, 0), Size = UDim2.fromOffset(80, 30) })
    local search = UI.input(page, "Filter URL / method…", function(t) filterText = t:lower(); page:SetAttribute("dirty", true) end, { size = UDim2.fromOffset(260, 30) })
    search.AnchorPoint = Vector2.new(1, 0); search.Position = UDim2.new(1, 0, 0, 0)
    local body = make("Frame", { Parent = page, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 1, -82) })
    local listPanel = make("Frame", { Parent = body, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Size = UDim2.new(0.42, -6, 1, 0) }, { corner(11), stroke("Stroke", 1) })
    local detail = make("Frame", { Parent = body, BackgroundTransparency = 1, Position = UDim2.new(0.42, 6, 0, 0), Size = UDim2.new(0.58, -6, 1, 0) })
    local code = codeView(detail)
    local selected, dirtyH = nil, false
    local function buildCode(e)
        local p = { "-- Rebirth HTTP  ·  " .. (e.time or ""), "local res = request({", "    Url = " .. ToString.ToString(e.url) .. "," }   -- escaped, not raw-concatenated (URLs can contain quotes/backslashes)
        if e.method then p[#p + 1] = "    Method = \"" .. e.method .. "\"," end
        if typeof(e.headers) == "table" and next(e.headers) then p[#p + 1] = "    Headers = " .. ToString.ToString(e.headers, 1) .. "," end
        if e.body ~= nil and e.body ~= "" then p[#p + 1] = "    Body = " .. ToString.ToString(e.body) .. "," end
        p[#p + 1] = "})"
        if e.status or (e.resp and e.resp ~= "") then
            p[#p + 1] = ""
            p[#p + 1] = "-- Response" .. (e.status and ("  ·  status " .. tostring(e.status)) or "") .. (e.respTrunc and "  (truncated)" or "")
            if typeof(e.respHeaders) == "table" and next(e.respHeaders) then p[#p + 1] = "-- headers: " .. (ToString.ToString(e.respHeaders, 0):gsub("%s*\n%s*", " ")) end
            if e.resp and e.resp ~= "" then p[#p + 1] = "--[==[\n" .. e.resp .. "\n]==]" end   -- long-bracket keeps the request above copy-runnable
        end
        return table.concat(p, "\n")
    end
    local function buildCurl(e)   -- replayable in a terminal (single-quote shell-escaped)
        local function q(s) return "'" .. tostring(s):gsub("'", "'\\''") .. "'" end
        local parts = { "curl -X " .. (e.method or "GET") .. " " .. q(e.url or "") }
        if typeof(e.headers) == "table" then for k, v in e.headers do parts[#parts + 1] = "-H " .. q(tostring(k) .. ": " .. tostring(v)) end end
        if e.body ~= nil and e.body ~= "" then parts[#parts + 1] = "--data " .. q(e.body) end
        return table.concat(parts, " ")
    end
    local function rb()
        return make("TextButton", { AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = "@Panel2", BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 44) }, {
            corner(9),
            make("Frame", { Name = "Tag", BackgroundColor3 = "@Http", BorderSizePixel = 0, Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(11, 9) }, { corner(4) }),
            make("TextLabel", { Name = "Title", BackgroundTransparency = 1, Font = FONT, TextSize = 13, TextColor3 = "@Text", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(26, 6), Size = UDim2.new(1, -76, 0, 16) }),
            make("TextLabel", { Name = "Sub", BackgroundTransparency = 1, Font = FONT_MONO, TextSize = 11, TextColor3 = "@Sub", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(26, 23), Size = UDim2.new(1, -76, 0, 13) }),
            make("TextLabel", { Name = "Meta", BackgroundTransparency = 1, Font = FONT_MONO, TextSize = 10, TextColor3 = "@Http", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(56, 30) }),
        })
    end
    local vlist = VirtualList(listPanel, 48, rb, function(row, e)
        row:SetAttribute("sel", e == selected)
        row.Title.Text = e.host; row.Sub.Text = e.path; row.Meta.Text = e.method or "GET"
        row.BackgroundTransparency = (e == selected) and 0.45 or 1
    end, function(e) selected = e; code.set(buildCode(e)); vlist.invalidate() end)
    local tb = make("Frame", { Parent = page, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 34) }, { hlayout(6) })
    UI.button(tb, { text = "Copy", primary = true, onClick = function() if code.Raw ~= "" then clip(code.Raw) end end }).Size = UDim2.new(0, 0, 1, 0)
    UI.button(tb, { text = "Copy cURL", onClick = function() if selected then clip(buildCurl(selected)) end end }).Size = UDim2.new(0, 0, 1, 0)
    UI.button(tb, { text = "Clear", color = "Bad", onClick = function() entries = {}; visible = {}; byId = {}; selected = nil; vlist.setItems(visible); code.set("") end }).Size = UDim2.new(0, 0, 1, 0)
    local function host(u) u = typeof(u) == "string" and u or tostring(u); return u:match("https?://([^/]+)") or u:sub(1, 30) end
    local q, qh = {}, 1
    local function push(url, method, headers, b, res)
        if paused then return end
        if (#q - qh + 1) >= 1500 then return end
        local st, rb, rh
        if type(res) == "table" then st = res.StatusCode or res.Status or res.status_code; rb = res.Body or res.body; rh = res.Headers or res.headers
        elseif type(res) == "string" then rb = res end
        if rb ~= nil and type(rb) ~= "string" then rb = tostring(rb) end
        local rt = rb ~= nil and #rb > 8000; if rt then rb = rb:sub(1, 8000) end
        q[#q + 1] = { url = typeof(url) == "string" and url or tostring(url), method = method, headers = headers, body = b, time = os.date("%H:%M:%S"), status = st, resp = rb, respTrunc = rt, respHeaders = (type(rh) == "table" and rh or nil) }
    end
    function httpTick()
        local n = #q
        if qh <= n then
            local budget = 80
            while qh <= n and budget > 0 do
                local r = q[qh]; q[qh] = nil; qh += 1; budget -= 1
                nextId += 1; r.id = nextId; r.host = host(r.url); r.path = (r.url:match("https?://[^/]+(/[^?]*)") or "/"); r.search = (r.url .. " " .. (r.method or "GET")):lower()
                entries[#entries + 1] = r; byId[r.id] = r; dirtyH = true
            end
            if qh > #q then q = {}; qh = 1 end
            if #entries > 2000 then local from = #entries - 1500 + 1; local ne = table.create(1500); byId = {}; for i = from, #entries do ne[#ne + 1] = entries[i]; byId[entries[i].id] = entries[i] end entries = ne end
        end
        if dirtyH or page:GetAttribute("dirty") then
            dirtyH = false; page:SetAttribute("dirty", nil)
            local out = {}
            for i = #entries, 1, -1 do local e = entries[i]; local ok = true; if filterText ~= "" then for term in filterText:gmatch("%S+") do local neg = term:sub(1, 1) == "-" and #term > 1; if neg then if e.search:find(term:sub(2), 1, true) then ok = false; break end elseif not e.search:find(term, 1, true) then ok = false; break end end end; if ok then out[#out + 1] = e end end
            visible = out; vlist.setItems(out)
        end
        vlist.tick()
    end
    local httprequest = fn("request") or fn("http_request") or fn("syn_request") or (typeof(env.syn) == "table" and typeof(env.syn.request) == "function" and env.syn.request or nil)
    if USE_FUNCTION_HOOKS and httprequest then pcall(function() Hooks.HookFunction(httprequest, function(old, opt, ...)
        local res = old(opt, ...)
        if typeof(opt) == "table" then push(opt.Url or opt.url, opt.Method or opt.method or "GET", opt.Headers or opt.headers, opt.Body or opt.body, res) end
        return res
    end, "request") end) end
    if USE_FUNCTION_HOOKS and not USE_NAMECALL then for _, m in { "RequestAsync", "GetAsync", "PostAsync" } do pcall(function() Hooks.HookFunction(HttpService[m], function(old, self, ...)
        local ret = table.pack(old(self, ...))   -- call first so we can capture the response too
        if self == HttpService then local a = table.pack(...); if m == "RequestAsync" and typeof(a[1]) == "table" then push(a[1].Url, a[1].Method or "GET", a[1].Headers, a[1].Body, ret[1]) elseif m == "GetAsync" then push(a[1], "GET", nil, nil, ret[1]) elseif m == "PostAsync" then push(a[1], "POST", nil, a[2], ret[1]) end end
        return table.unpack(ret, 1, ret.n)
    end, "HttpService." .. m) end) end end
    addNamecallRoute(function(self, M, ...) if self == HttpService then local a = { ... }; if M == "RequestAsync" and typeof(a[1]) == "table" then push(a[1].Url, a[1].Method or "GET", a[1].Headers, a[1].Body) elseif M == "GetAsync" then push(a[1], "GET") elseif M == "PostAsync" then push(a[1], "POST", nil, a[2]) end end return false end)
end

--==============================  Settings  ================================--

local KB = { listening = false }   -- toggle-key rebind state, shared with the keybind handler below
do
    local page = newPage("Settings")
    local scroll = make("ScrollingFrame", { Parent = page, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 4, ScrollBarImageColor3 = "@Accent", CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, { vlayout(8) })
    make("TextLabel", { Parent = scroll, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Settings", TextColor3 = "@Text", TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 0 })
    local ord = 0
    local function rowCard(label, desc)
        ord += 1
        local c = make("Frame", { Parent = scroll, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 54), LayoutOrder = ord }, { corner(10), stroke("Stroke", 1), pad(12) })
        make("TextLabel", { Parent = c, BackgroundTransparency = 1, Font = FONT, Text = label, TextColor3 = "@Text", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -180, 0, 18) })
        make("TextLabel", { Parent = c, BackgroundTransparency = 1, Font = FONT_REG, Text = desc, TextColor3 = "@Sub", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, -180, 0, 16) })
        return c
    end
    local function tog(label, desc, key) local c = rowCard(label, desc); local sw = UI.toggle(c, Settings[key], function(v) Settings[key] = v; saveSettings() end); sw.AnchorPoint = Vector2.new(1, 0.5); sw.Position = UDim2.new(1, 0, 0.5, 0) end
    local function ch(label, desc, key, opts, disp)
        local c = rowCard(label, desc)
        local dd = UI.dropdown(c, opts, disp and disp[Settings[key]] or Settings[key], function(v) if disp then for i, d in disp do if d == v then Settings[key] = i; break end end else Settings[key] = v end saveSettings() end, 170)
        dd.AnchorPoint = Vector2.new(1, 0.5); dd.Position = UDim2.new(1, 0, 0.5, 0)
    end
    local function num(label, desc, key, mn, mx)
        local c = rowCard(label, desc)
        local box = make("TextBox", { Parent = c, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(72, 28), BackgroundColor3 = "@Panel3", BorderSizePixel = 0, Font = FONT_MONO, Text = tostring(Settings[key]), TextColor3 = "@Text", TextSize = 13, ClearTextOnFocus = false }, { corner(7) })
        track(box.FocusLost:Connect(function() local n = tonumber(box.Text); if n then Settings[key] = math.clamp(math.floor(n), mn, mx); saveSettings() end box.Text = tostring(Settings[key]) end))
    end
    ch("Capture mode", "Max uses a __namecall hook (reload to apply).", "Capture_mode", { "Max (namecall + functions)", "Stealth (functions only)", "Passive (incoming only)" }, { "Max (namecall + functions)", "Stealth (functions only)", "Passive (incoming only)" })
    tog("Actor support", "Hook remotes inside Actor VMs (reload).", "Actor_support")
    tog("Group identical calls", "Collapse repeats into one row with ×count.", "Group_calls")
    tog("Ignore spammy logs", "Auto-ignore remotes firing >80/s.", "Ignore_spammy_logs")
    num("Maximum logs", "Entries kept in memory.", "Maximum_log_amount", 100, 50000)
    num("Calls per remote", "How many fires to keep per grouped remote (expand arrow / call picker).", "Calls_per_remote", 20, 5000)
    tog("Syntax highlighting", "Color generated code.", "Highlight_syntax")
    ch("Default codegen", "Inspector code style.", "Codegen_mode", Codegen.Modes)
    ch("Log which calls", "Filter captures by caller.", "Log_which_calls", { "Game only", "All calls", "Executor only" }, { "Game only", "All calls", "Executor only" })
    do
        local c = rowCard("Toggle keybind", "Key to show/hide the window. Click, then press a key (Esc cancels).")
        local kb = UI.button(c, { text = Settings.Toggle_key, autoX = false })
        kb.AnchorPoint = Vector2.new(1, 0.5); kb.Position = UDim2.new(1, 0, 0.5, 0); kb.Size = UDim2.fromOffset(150, 30)
        track(kb.MouseButton1Click:Connect(function() kb.Lbl.Text = "Press a key…"; KB.listening = true; KB.onDone = function(name) kb.Lbl.Text = name end end))
    end
    do
        local c = rowCard("Show HTTP Spy", "Adds the HTTP Spy tab to the sidebar.")
        local sw = UI.toggle(c, Settings.Show_http, function(v)
            Settings.Show_http = v; saveSettings()
            if navBtns.Http then navBtns.Http.Visible = v end
        end)
        sw.AnchorPoint = Vector2.new(1, 0.5); sw.Position = UDim2.new(1, 0, 0.5, 0)
    end
    -- Compatibility readout — surfaces the engine self-test so you KNOW which
    -- capabilities are *verified working* on your executor (not merely present).
    ord += 1
    make("TextLabel", { Parent = scroll, BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Compatibility", TextColor3 = "@Text", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = ord })
    do
        ord += 1
        local okCount = 0; for _, n in CapsOrder do if Caps[n].ok then okCount += 1 end end
        local modeName = ({ "Max (namecall + functions)", "Stealth (functions only)", "Passive (incoming only)" })[Settings.Capture_mode] or "?"
        local card = make("Frame", { Parent = scroll, BackgroundColor3 = "@Bg2", BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = ord }, { corner(10), stroke("Stroke", 1), pad(12), vlayout(5) })
        make("TextLabel", { Parent = card, BackgroundTransparency = 1, Font = FONT, Text = "Engine self-test · " .. okCount .. " / " .. #CapsOrder .. " verified working on your executor", TextColor3 = "@Text", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1 })
        make("TextLabel", { Parent = card, BackgroundTransparency = 1, Font = FONT_REG, Text = "Auto-selected capture mode: " .. modeName, TextColor3 = "@Faint", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 2 })
        for i, n in CapsOrder do
            local cap = Caps[n]
            local r = make("Frame", { Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 2 + i })
            make("Frame", { Parent = r, BackgroundColor3 = cap.ok and Theme.Good or Theme.Bad, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(8, 8) }, { corner(4) })
            make("TextLabel", { Parent = r, BackgroundTransparency = 1, Font = FONT_MONO, Text = n .. (cap.essential and "  *" or ""), TextColor3 = "@Text", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(18, 0), Size = UDim2.new(0.45, -18, 1, 0) })
            make("TextLabel", { Parent = r, BackgroundTransparency = 1, Font = FONT_REG, Text = cap.ok and "verified" or (cap.note or "unavailable"), TextColor3 = cap.ok and Theme.Good or Theme.Faint, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.55, 0, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
        end
        make("TextLabel", { Parent = card, BackgroundTransparency = 1, Font = FONT_REG, Text = "* essential for capture. Green = test passed on your executor.", TextColor3 = "@Faint", TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 998 })
    end
    make("TextLabel", { Parent = scroll, BackgroundTransparency = 1, Font = FONT_REG, Text = "Rebirth v" .. VERSION .. "  ·  premium GUI over the IxSpy engine", TextColor3 = "@Faint", TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 999 })
end

--==============================  Runtime  =================================--

local frameCount = 0
local _tickErrShown = false
track(RunService.RenderStepped:Connect(function()
    frameCount += 1
    -- guard the whole per-frame loop: if ANYTHING here ever throws, it's caught,
    -- TAGGED as Rebirth, and reported once (so it can't spam the console or be
    -- mistaken for another script's error).
    local ok, err = pcall(function()
        for _, v in AllViews do v.tick() end
        if httpTick then httpTick() end
        if explorerTick then explorerTick() end
    end)
    if not ok and not _tickErrShown then _tickErrShown = true; warn("[Rebirth] runtime error (caught, further suppressed): " .. tostring(err)) end
end))
task.spawn(function()
    while task.wait(1) do
        if not ScreenGui.Parent then break end   -- stop the per-second loop once the GUI is torn down
        table.remove(Stats.history, 1); Stats.history[60] = Stats.sec; Stats.perSec = Stats.sec; Stats.sec = 0
        if remotesView and not remotesView.paused then statusLbl.Text = "Capturing" end
        if Window.Visible then   -- topbar clock/FPS/ping only matters when the GUI is shown
            local okp, ping = pcall(function() return LocalPlayer:GetNetworkPing() * 1000 end)
            tsMeta.Text = os.date("%H:%M:%S") .. "   ·   " .. frameCount .. " FPS   ·   " .. ((okp and ping) and (math.floor(ping) .. " ms") or "— ms")
        end
        frameCount = 0
        if activePage == "Dashboard" and dashRefresh then pcall(dashRefresh) end
    end
end)
track(UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if KB.listening and i.UserInputType == Enum.UserInputType.Keyboard then   -- rebind: capture the next key (Esc cancels), never toggle on it
        KB.listening = false
        if i.KeyCode ~= Enum.KeyCode.Escape then
            local nm = i.KeyCode.Name
            if nm and nm ~= "Unknown" then Settings.Toggle_key = nm; saveSettings() end
        end
        if KB.onDone then KB.onDone(Settings.Toggle_key) end
        return
    end
    local ok, kc = pcall(function() return Enum.KeyCode[Settings.Toggle_key] end)
    if ok and kc and i.KeyCode == kc then Window.Visible = not Window.Visible end
end))

installNamecall()
selectPage("Remotes")
task.defer(function() if activePage then selectPage(activePage) end end)  -- snap nav indicator after first layout
if dashRefresh then pcall(dashRefresh) end
shared = shared or {}
shared.__IxSpyRebirth = function() if ScreenGui and ScreenGui.Parent then Window.Visible = not Window.Visible end end
print("[Rebirth] v" .. VERSION .. " loaded OK (GitHub chunk; all Rebirth errors are tagged '[Rebirth]'). If you see a '[string \"<number>\"]' error, that's a DIFFERENT script.")
Notify("Rebirth v" .. VERSION .. " ready", (HOOKS_AVAILABLE and (({ "Max", "Stealth", "Passive" })[Settings.Capture_mode] .. " capture") or "Passive · incoming only (no hooks)") .. "  ·  " .. Settings.Toggle_key .. " to toggle", "Accent", 5)




