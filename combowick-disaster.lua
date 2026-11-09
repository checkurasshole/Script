-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9fdb11f57c7ff2f678fd62fe70155704",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b0e8edaa8757701b6e1b0bec3c748155",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e1b2122df8d0c44d11b1e9dd77521630",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/86a7c557a831c3964e9a12602882e7a5",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/39e75985e9da3f16d3736814cb334ee8",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3916a540ee7455325d810fc5eb6f30da",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f52a43a86739da6354bdcf893308556c",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f391349b16c332aefa473a3f0db588e1",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6093e77581756fe44f0f471df4192289",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/03999d64f2d5e139c868941a41ea60ec",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a955080aced8e58800f60d8ff52815a2",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/09ca2c9f7e40cc1e6555a3efb67b9269"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
