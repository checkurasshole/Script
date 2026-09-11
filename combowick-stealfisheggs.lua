-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b6e258dc62bc805588b31f9383fae00b",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7e7b601f6c0635e1e4907a8384014294",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c5ad54614852bbbfeb05fb3fe884d53d",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/13e98416fee7a5ebc70e49a56c364821",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/84c9eec8bad4d8ad4b7a56a5b30bca67",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6aecddb7d65261e14883a7749f16cf70",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e56bbe848928949849ceeb5bc116defb",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/adbf23648aac70d47f3ffe20b752a908",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4bb534bcfe5144d04c9b4fcf44282013",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e0ce048ed6e89eaeffcdca66738d2309",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bf0e71ed08e9f58f6b5d1a543a68cb1e",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9aa3cc47b48ba52902de13e468ae3ec1"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end