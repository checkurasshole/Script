-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1568415387359fef915d81eed69b31e0",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9d0736b0bbfd6b46ad2bc9f64e559982",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4ecd3c386add20ab3c97bcb0ce02956d",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/98a2d163649bea50f0978bb56bd47904",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/23eedd53b8bdf1607c34ee2c200c4ece",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8e7dd5b779331f349b478a98098f60e4",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/897c70b2e7a9a71cbbafc3f1295a87a9",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/35f32026259bc11564ffeab10f34cf1f",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/259c40301bfed9e8e573d05a44766444",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7a72ea8a10258dfa1bfc27c9ca460fe0",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/77745c6be663a5ca8c2bb716d5517a7a",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5100a57ebeacbaf4a0fc638126c187cd"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
