-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a7bb7b4f7474d8f6a3a4a0fefe6dc55d",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7bee4fd45ff866f6643308b5b733cbf3",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/afe64cacd5f47bcffd4d32c17935d751",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/76af7b29fa0a2c203410ec6ea70c8b91",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/44e677436c41f78d5b75ed1028fa4bcf",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/06798db65801ec53c579d793aa487f75",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1573168e237a540145a7e70cc1798468",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/569b124d90e515e3289191bebc7e3e9f",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/91f5d66a3327080e31e4f2d4a3571922",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6191049a86779a4040c7317680a08508",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cbb6b595d60a6f811e49d1bcc7fbf81e",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/529eea78cbad383b8badfe274ab6be3f"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
