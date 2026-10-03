-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7cd694a403f7ac97ad1ec818449842a3",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0644e805015961ce8b26ac9ba076e6af",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/201ebe2a5cef00f2698096925913e82c",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3523b032b5e37b12b7daa0b2cdba006e",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/de784877f08b72d6b16bb42cd991e1d2",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4d4dcb7afc5e0cf7cdc64d273d88d86c",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/20f71dae3661deb045d0ed6875eda767",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cfe535643b5cbadba60798b21f7d41d4",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8e596850a1dd74e66d80aee17bee1d0e",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d4002309e9a2d3636573a0ca7e8d0cd0",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4d2abc793bbbc0ebb19b65dfe559b12d",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/292e57c88c9b145673a6ba213aac7dbc"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
