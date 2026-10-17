-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e47e7626a5894379312f6abe6ab61fce",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/635ef3f04f9dcdeac41cbc044be9e12e",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fe14c5ed1890699a0ffaab4dd378b72d",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ae9f94d61a211a5b08255dbcf7d5e0b2",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/21a78103f0d6d02ee48f7df08f6dc7c2",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/814262145b21475f113accbb11a76dab",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0145e910e8796a66a5ffb6b640029676",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bdb56492e20ad61e249a460045734c04",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5d85a513392629cc0c5c0c0a2686e63c",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/95e3a11e304ea42306fb8bfeccc1ca75",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/360a021eaafb98764d87e85c2b6657fd",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ef95f7770abe6d2429f63262a2d4c6b8"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
