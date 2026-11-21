-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/afe9ffa1daeb0cc576ac58c446e653a5",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/47ea842f4c5836b4981729ff03c41776",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ccf8da68c0cfd1bde2949fe546761253",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0682c56edc70f4a3e4aa6b5c154e8df8",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/efd1c63b42b603cd1016baf2d68748db",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bb3a899d143777159f898972727ab81c",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d77aa124585b2b4ab1ce61a2959d5046",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7675681a258adf84208bbe5ac380c7c8",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/983e01632dd48f240e4db1f186c6f661",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/dc6b34c3691735e625fb3cbd7b3ac37c",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/28a234df3e0ce9cee9252676ad73aac3",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1e2e89553d3f84114ad82d6db9e0e3c7"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
