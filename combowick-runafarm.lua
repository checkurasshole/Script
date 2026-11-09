-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/faf4cb844967cd7189575461745e60cc",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a6a94193776e14d8f9ee2535431f2977",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fd57de2c0fa9f156efeed612b7f97bea",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5cfec67afb390a8e1ce3921d95e65c32",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cd1ecd76c8f05b35cc0afd22921f413e",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/97ed4fafe6319a15c1eef8cf37ed26cd",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/87024071c24e9cec0ba509cda366f123",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0b07860cb905ad017f5de737785fbf69",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2620a1ae86ada23110926c6fcaf7caed",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/24a491d0b6a186f47559af364b6d8106",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a2dca462d00459a7c7387b2a8ae38059",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/800a0a0d186b4eccaae0114dd5bf8198"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
