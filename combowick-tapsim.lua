-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2ccc21fdc341f056d9a958172aadd954",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fa531eafd6df6678d49ae128596d3c4d",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9d359b618335b807df13839b351875f7",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/173151d8e64fc0bd15fc28df0daac194",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/997179439493d8bf52806d7c40f2f9c6",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/641177ec07687ad52bcd99f7b6f96fdf",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6a97f6ae06bce7935a9a81de64064ad7",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8ee2be88e32143494da4385bd3a4074f",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/76979553cf7ec605458695c3b38850f3",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9d8f984735a5d737a8eedbf2998f80cc",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/72ed6ca753b5234e3e64c5e807500290",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4eb6df8b4275908b21bf1da228577dd7"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
