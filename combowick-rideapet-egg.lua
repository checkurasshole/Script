-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fed6d43ebeda42dca3bbf38e4accc3fc",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b72ebe3d0ba9dabd6a3122386b0f3a3a",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/12c19837ee26a8ccde851d5cb8839592",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/afb07bf7ddd57d5520c550081850010c",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9d32f8bcc7ba0ee613df0d7c44fccee5",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4f0f15feae002acb2b41bcbe2f536eb9",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/365b9a2a769da61b15756f6e0bf4ffe7",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/324698672182c62686791c463e76566c",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4cbd051575cc6fabce57ba87c60735ce",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/456e1dc0d70c136a5396b771018ced4b",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/93dd25e420b0a7912070cbc103f03bb4",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4ecc0aee3319d6698829d812cb843f2e"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end
