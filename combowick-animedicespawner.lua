-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2cfc45b7edd8c73c73ad4ec1136b169c",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/350c2b20ea70cc056d91f6f1625fd450",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d3da0f681b51e765a092efe677f06dfe",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f3524c9c9a06e658473bf75d15c5e16c",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b261e8ad1853d53750e0cef5449d49ff",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/644b871b2e17d36a3395b8c8114cd1ec",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9807e304b888639643444574128c0e9c",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4c01e9894b1e50258438a49168574acf",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e2fddc5c6dfa8300cd67d12162c9f8b5",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bb364d4ead123cf5fbda846986234683",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/dbac1703753adea8368a39f6e3dab229",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/dbfdd2ec0a10d75b5534736abb663a83"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
