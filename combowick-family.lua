-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/25a55a3c3fd486058930505f62515b80",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0210ae14c0816706a1a4fd6173cc0997",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d9dea21cd065bacd1f323dbb3808d70b",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bfc9a80f323a53baea247caef026029c",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5628db8855d9b4db99854db2da988a49",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ada0ee52ff04ac2d7df9f559b79ad70d",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7b2d289c697a5d93209062fe815320a8",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7dae117a62d9558a459a98c37666a81e",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5d8a05ea9382ac7c8147213981bd5af3",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ddd570521d8a4dc5982b2d40558797fb",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5ba0fc043ff54b73805404b199227c8b",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8a7966c52656611deaed70ccf25fdca8"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
