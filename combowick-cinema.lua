-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7428140545278b9b28004182b865b71e",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fa33e46a8e133cd8995475abb662a10c",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/36fad64799497d488294a15ad6835a08",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/facc1985a781d7cd7cf359379a5431a2",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ab6d3114d1cf0d61b0ca1c63c059201b",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/118d18e34b199b28ee2b7268c57912d8",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9e3b35d844236e48373352ec93377e8f",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/75e6d366e14daf17215d648208dd43f7",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/208dfb715a2f39d8a491853460124525",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c919859e33fd6d620861e789f7e4dc03",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6e0578bbe9b29ab08909418411af5eb5",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/45bfd1430fab915f4465392d62bbbd48"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
