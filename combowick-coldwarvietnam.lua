-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bd84417c8b09b8a94c63da9cb38a8195",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7308198a5880f75b5122112c463efacd",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2306fef6b6c516f636d9e97a1ed28e78",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6b2fa075f7e215b2f8fca5152fa9a115",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bd02c84b8ac63e858340ce71ee3e13f4",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4742e54b17833ebf35ec4f5e42b3e190",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4e43e7c6285a6e8b6f20ba7e6ab6066e",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5e3a01dcf4aad5943cbeb606871e9e97",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e4158c2bc46a923071a0bbdc4a6f8f43",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e8d2628b151098d3cf85f4ae6348e4e3",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/08396d7eff139eeccc209fac999361b2",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7940d7ad795c4c0e85b34c04aa53876b"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
