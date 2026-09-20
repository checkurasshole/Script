-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/40d2bdfc4797c8de9f29c3a2c1afef55",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5bb13e7cbffda3c287793f065f50d8b9",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fe2272dc0e997efbff419f7ea82005ff",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e32c05c2a38bd9f4fbf26d1c91f28f37",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3792f266e5c7ba90b06fedee03a6c168",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d5f15cdfa920a1cfcbb03aacc3291c1f",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7473925fd6d86437787e0b9287fcbdde",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2f48db06d5c1b32000f19a60b4c313ba",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9c32e9c227a3629fdbc8cb8800d304b0",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f4283a0ea64550d061d02cb59e07607d",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ad05bee5656b22d99dcdf4142121b256",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/50fee075fd6448d8ce93645d19909328"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
