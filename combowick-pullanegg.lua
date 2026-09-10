-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1a6364bf01b563c0ce61fc32f7291e73",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0d52926d1f254ea2d4d535f25b832ca6",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/26bc03dea23b79553c370a86827b113c",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/00fdf633376ca479ec08b9a673ccc313",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8f59ad407b24bbaef92a0130a4f18a2f",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e83f4b91245996ded6c99495de9d00a0",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/392a23b667def505695df771bb04817d",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3662d174da055db7d0bba872ad465e98",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7a5e2a6acdb707c926c79ce01dcb5a7f",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c1b2e4608ac564acf8a0ae974cacf3a0",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f1c6178c19f64ca906837d0f5ae1c5ae",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/69a0a6f05cded8c03cd4b6fc92fe3563"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end