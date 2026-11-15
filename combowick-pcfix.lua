-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/20df50dedfd23e47bac7c9f581b9a24e",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d7fe31d7f7cd58cd22f7e62bbe71993d",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f20450f90c51687690913b5b0ad6805b",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e6917aa8f3f44738497d4ef8a97eb3f0",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b842df4e3401d2fe3d494440922cee5c",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0c60935fd4bec53f56174bbf4207b5cf",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d3810e7838c5e843b5448acd138fd2c4",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a33022ce186f57314c98854a5b0b81bb",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5a2e957b9cc31706c42eaf9671d3d592",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e9bf3f64f7756df5f0a0056bcccd63ce",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6920cb908c83e23fca2fa19e3a284bef",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5a4a17d7767316fe93e0a2a57b10b98e"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
