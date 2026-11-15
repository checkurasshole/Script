-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c21511c48c09f5542c9b3060b8d534d5",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/eb3c514f3f9a78e63484c2fc7733d833",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/14944ea906b6dd6d91e13fd4f9f819fd",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2b2769e9cc5627d8f125b4d433c08503",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b52c9a213fd04b8ba03ec32db4bf95a7",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1d1d3667cace5b6beddfb0189b379881",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/91eb9ee541ccc384cad14838bf10468a",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c95dde9c029089323f4818b84c3c6536",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ab282a2b005cecf22e26997ccc63a883",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e38809cc8b3ef242ee2797adb88c7821",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f84e7b2c0e045612222d71bf7e0f4171",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c949785df165069bf96185c7184d0867"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
