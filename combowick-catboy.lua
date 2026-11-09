-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/18d93e7279f5b659849729be4721d7af",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/87e7e9900374a6e05c8ecb01e9ccc64e",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d8d89741fed8c91f46a22ed7478c4d18",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f41cc252b885ee04e41d025df263e43e",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d9176da1f25df6cb9705295aa18c831b",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d3f9c8e977b4c3c356c795d69f8ba415",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f4f3d55c4281a7d4ca89bbfa641add4e",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bb9bd71894aacf97420058e5e97029e4",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9cffe32a17c48486235b858111451e93",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9573c856b0dc1699b5079067fed86d55",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d1aa1604d86f83844de2b24a9268f24e",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/29eb359ce0295df3b1421bdade6d649d"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
