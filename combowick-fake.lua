-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1af3cae79a131936631414bbd9746e12",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/411345388d0f039dfda5105811e0e2d5",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/98aae5113893bb6333963a64014e3871",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e197a9e77833efe71f2309078373ce7f",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6524c7225640bd01658e6e5a937eed54",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6bd9426927cfad1847aff691454d2436",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6f4e081fb07c0de23af79494d8854de3",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/578a7448c8a4c0c8f8bb61fe0ce583e1",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0e98f10b863898e453b6aa05f09981c5",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ea8b1280008c8670d92e636a3563fedb",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9d29dcceaa771181994171af8a6d796d",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d1c8dde8169dac0a01d7b1b814871c75"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
