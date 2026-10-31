-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bc5250960d88b31da55518f93797eb2e",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6c68d4f04c5ace6b235323188de8a289",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ad3d91c9dfa424e13a695dee044f52fc",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/427e965e4ca0d5c86c15c760262b9071",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9ef127f2da959bc2ca9a58b5f4657001",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/506414042cfa48a63f901f6c04aa210c",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9e22a7d945067990a0327485dbda8b3f",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f9cb96c8ac2491c35a4a3605c3b21281",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/954e8f60529f6533fa34e2d7e2b8ce41",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7f4f0a0771cc2c50e71b50e47f8a4dd8",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8863d705e340d7abd91fed9fb1e8ca32",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/61282b2eb0034e137103ded6f92472d1"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
