-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c08616d609badcfd25c6672662169e26",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6cfff3c6588a2c94fb43d08bd2469a33",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0b2ac7a76b8bb325c15160a0d311702e",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c5f55b33524f4fe0709e3f08f1adb64b",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3e471817a1de7e5311cf26f6fb2e87a7",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9e21c0414087e726be84efd21b4fcfe5",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8768c4cb575e46f506f7c1d238821ee6",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/63d994d9a0e80499ba5196748c3058c3",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3969a2baee595a66bb2f6eb76371e665",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ce2ba72e10751a7d1ee3dc1898349105",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/89c70d2464d1fd138620997a71aa0ebb",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/41f208acce512244682374689a4f75c2"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
