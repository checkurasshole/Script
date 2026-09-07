-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/94cb8d3afa8ae7f64bca0940f6f40e7f",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/79b975caca615f76380ea8aa97570f66",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9f148db2f8d62e0953fef7c250175a03",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4e7c98e2422181210edc71f9771dfcde",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a1659bae26af5175530e7df011831d25",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ae1a488dc40d0b0f222fd5f4c02fe457",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3c46e74d61e3fdb2085c1f0de3c72dc8",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c4f4c23ed2cb9736930acc8816344538",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/99b66f96f8f7f009037464a971d3759f",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5ec5ef24b13313c797bf3cdcc70d8607",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9988f95d216130109f8e6633f9af7316",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/439271281dbbf38e629c3aa61d0a1cfb"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end