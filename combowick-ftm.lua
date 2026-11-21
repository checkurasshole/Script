-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/51b83a91e93603808f5e8b391a39bd02",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0c0ec51cbe4bb7c86fd45bf231a45ae0",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/21bee40e1f0603a64fd2a72308760df2",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c3934875658a35243523d802fb79f04e",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9e8572192087eb0dc83a3853e50a7f68",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/46ef62331c5e521c813da8f5bee7ec4b",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/789a6b5b06373def43b253eea03edbbf",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3d4d0f2151bc1a801860d7e01c990961",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8cb855d1763ae12c4b5f41cded444224",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0ce0ae36c9b8a5a2007ea482e4ea3672",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2d707af14bc26de295032427115cfdef",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5c49d73914f98e1c88ea8dcacd4b1022"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
