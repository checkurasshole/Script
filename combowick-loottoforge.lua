-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/32ee0ed63f1dccde356d59040c654d6e",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c79e07d7085771b0ed6031bee423948d",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d9ec7e6ccd3531fd7396868e494c3696",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e4441ace4344a36f6e7839b745414425",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5418a89c879ff91da2e9f91483b2fc96",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1fe3af7c8b091f6fe6b47b11bff9ceda",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c8606d784444f5bec18ca45b8c334196",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1807edb53f30ce7a36c017a672ace747",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0a89899d0ee480c646ffdf24f1f40cd5",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/abb157ef7450ed5a72a0312927e0efd6",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d5bf3f94d0b65d28fb5d33072e8785ba",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e156521de2709db8950acea364dd42c3"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end
