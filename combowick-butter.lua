-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/227c317d13c0c9bec13f62f9db8188ad",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c815d1f4bcd82622147421e8c09bfff4",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e4473c1e8fa3202c81b5ecbf86cc40ae",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/65b01aae834b348a232971904f9683e6",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ca09b803cf39edb577ad95fc28787e65",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fdf9a61673c6c7f172e063e09888dad7",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5c1fedda0a03cad76e857c80582b5c46",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/becc966130e1a22733dfa865c1d18fa2",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/be227ed3ba4ccc9115fcd3c51062d994",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/76215c4c1774924389771da22ebd69e1",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8ec478671597eb79a9990c0a0916ff9c",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1f7d0bb732a64c43daa3d97bb7952e0d"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
