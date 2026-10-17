-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/997beb94afda17ee74f782aba8102877",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4003977a3c41e90e824afa8b51523a37",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/dc5bfbdacede9fd3896b76033dd19341",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9122825dd90042030bf446ba295c1925",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/83bfac1a877836b62b1cf70fb053025e",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3ca30f76857cf0f919e07fcedb1b8c2f",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bff495c353458f093f74fcc8e0628c2f",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/13fbb37dd5c03756741ea047c0bd9cfd",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6ea1d26959872385e5f4ce6ea71b2c20",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0100ee7b1c14a7d77d94a94f1518cb28",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f0cfe034d87ce69812ef1222609d3cbe",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/777506544e866a4c4c226518aa6e98f9"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
