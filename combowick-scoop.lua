-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d07ae1fd70f1a2da02e51520a2a59c4a",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/08605c29abfdba34257fa4d7cf8cc0fc",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3df513a3d75aa2ca54af4595821095f6",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ce7abef6d83188b73337d081488ebaa9",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/25767240528ddb4b7651a31ef95b160e",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2bcf6a3a5f976e5221961d9445cc68ab",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/dbe710478d369ee15fcfff27ab099e5a",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ef15b560a734c910098e97c5df2f649e",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/adf1aaabb6f1420b034b314d66c8500f",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/17eced6f31a8a692d7df510f27323bd9",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/64ad2fefe56361f6fc59078a3d31d1cf",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cecdcaa66959d2654801719dfbb72de6"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
