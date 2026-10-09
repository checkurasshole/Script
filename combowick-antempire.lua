-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/349d66f61236978aef41216d607b8368",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9bc888b4499c4606e0ac89c1e3cb971e",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/19af8acc5015067135b56a8a47ea3e3f",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/214c3f339ef2a2fd390b6a761c5dbe6c",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9552d7ad1e6f5486a68482a422801205",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/91898f84ecc7b2234eaadf106c396c08",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/26d9b30b0c28b6a50149ac2e7036c381",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7b4b7c7ed08e980793016ce2e56cb484",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/deca2bc015d73bfa0ac0f6e0fe7f8656",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f549b29bf2047b38115dcf851c1544d8",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2cd741f7a0289fa51ad92101ba4e1591",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7ee48828b0dabb9aa79ae0058d220340"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
