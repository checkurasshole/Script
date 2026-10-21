-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/51eea556a8ad6f1e27e3f39068af3fb8",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b3560f28359db16a43acc5f53231725f",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/73bf76ecb441d1a502f59035a5191f5b",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/27befb6258327379f7bc0ae2eea3d56e",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c86f71f5347634bcc975f2f50cb8ddf7",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8908fbab4bf8e9d512ed4310ddcef69b",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b82306b87a72c044f368e1e6a3ce5960",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bb81d76c03ba2b76fcc92f533c581f65",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4280522dc6c922ebff05b03f211c8231",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a4d8d296ab1a8b4983beb8d05b518d18",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/29f6f5d4919dbe6a8306a84570cfcb04",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/25f04af2574e158ac709e54405992826"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
