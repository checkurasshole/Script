-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/065287a13177fec17e022b500aee3a34",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d40716973de55074fa9a04f35cdf23c5",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/26c7942d2f7e47510607c2bd495273fe",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e2dad1310c657e0f42211434fd99ebc2",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b908e4899c33ce86e6bd172cafcaef43",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9b75b4d88807cb1757b1ee7fdb7695bf",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/84212750e645f40525b6b68d2589effb",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7bdd8e02ce981cd2578c6d3935786c2c",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/122fe36b21eecd2e7065215b5736a209",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/255c3a35cd129d6752a3ce58ee2494bf",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/15152dff2cb009d3d2c6120dbfa0c62a",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/106bdee187a8568e140621274e52da2a"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end