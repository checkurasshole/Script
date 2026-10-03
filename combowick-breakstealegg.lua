-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/73cc0057df422058eb05f62a2e31dab0",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/828f8c20a6773384acc5b5bddb1d4c20",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2a6b2be35054ffc7065f44dcb662446b",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a4886a8c89b25c58ebc66c88f0253a38",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/87fea82de24bfa6c83a3778b5fd379ce",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/527802ec306cb356167b44d9b90b286a",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ff4d4c6253062e40f8bae8fe3372e98f",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/88ce3036058eac4205ed0191eb3eb0b7",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1b954fe2d4a0f1a8c20ab695a4be0061",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/782ab8c763f96806794633eee7b7997e",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/96edc6d0bd7b7e1c400714c9bebc3ff0",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f0727bb4fceae6be902f0330606c3f9e"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
