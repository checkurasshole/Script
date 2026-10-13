-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3185fb14abd59c2e2361505ae615946c",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/27b4fcff853a1d35d1dcf5d6fe338eba",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/00dd15b05c76bccf9154072ebf0094f8",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/37c761ed748d59d624b5b8ec8357beb7",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4534f4e235dbc09f1c59529376f3c222",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4b0a0d2680a7dac3e571074dd57858d3",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d3598143a57d545eb7f93fe91b4322ae",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d0b7f49add44f9bff07b29251d1b1e46",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3fb416cb471b2bb0441a613eb00fb7d8",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/43e917cd9dd0a7dc65090e675ff4d447",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bf012a78388e9ec59535e77bea365f20",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a4d37e3991af151436110de3088d3afa"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
