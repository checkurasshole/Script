-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1c178fb8a9ec8e4a6f8cb5470478cdf8",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f8690d495603681c1e73284c4ee26942",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/16c862832fa0c92d36689592126153ec",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d98d262d7753878248661d1a485f3219",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f0fe206bac423459753334dd493ee137",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/563ac6d06e5d958eca3dd3f530f19619",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2539bf409f4ea476df2cf7522c01ab23",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9fd165a451602d399a26f67b1340cf09",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/da45e05496daf7e808b8d556afb36430",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4b0acdfc09f65d1b40f8c11d3b3ab9ed",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f223dd529491588f2781f6d3fbd7bdfb",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b0ff91c375ef7a2b5041183791a3dc26"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end