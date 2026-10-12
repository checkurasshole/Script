-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cdea981d6a2306af261a0002a46f246f",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/938708c3e565b075d736cd004be6598d",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ede17007512239fa15e0b4b4755c472f",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9183ef84a77248752c3151fac194b0f3",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/aa2445dfba9d00799cb82d8963e464f5",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ee9401cb8d3de31aa032f7108f8488ae",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/edbd5ece2c4817ad324ea671f298051d",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c1e7870f1d960d3f9a438b7d95dd48db",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/41fcbf181cb45bc4e37ef9726dbc5f44",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3b210c43a0278c1effcf5ff450df5265",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9ce638061fe074e9107ff198b17aa47e",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5e5f4992f90c9ba0cadc042f8d420df6"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
