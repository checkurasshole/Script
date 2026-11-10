-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/94d1b34e6bdd7c85645dacd9de12a712",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/def804cc23bba9091e52bec457949e1b",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/68155841bd60bed6ee09648bcde71bf5",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3154d0f69c5b093560f035f380a52d1e",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/725281214c82eb2417991193b673b0b4",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/121c4ae8145a1f6031935642275e81d8",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f1e1bb4550f61a901b57a70c8841614b",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a9a238266222f0d91ceb8edf72c364e9",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/eabc7b67ed2c6272e38bbcbbb5116884",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4fb39c08e8396975c7df0ad2a8bef00e",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/744694efcd3014322c21b4be6e3adfd9",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8b85235d0c3b2569c7cb139bc8f61659"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
