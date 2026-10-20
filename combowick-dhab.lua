-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a03e4d5c05bacc97ba8369383da3c7d0",
    ["Arabic"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d0e7b8cd1e1924f871e841e389d01109",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/261491a8ad5953f01aa16e5ba13cd0c6",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9553377a326c5d88e26d37ffb88ea218",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3cabef368c692f9e588f13ca76e6b4e3",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5a5e4339bb73450aae3eb308c72a06ed",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a734bd116f9182dee68f99050f42aa01",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3c1561abc1936b86de2b88334a5c19a9",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bff3b2364844bb799db483aeb96a4e3e",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/06f6d9ad248066fd360cb7a6c49a0466",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ff61a7718d686995ddf0bdb0df4ae12b",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a4ed258df12a19cf97c2f13186f21587",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3923e927a8f4e097a33766607c1ec041"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
