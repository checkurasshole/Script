-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/71a2fe51ea34bb69d1fb09b395e72e48",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/98b739f54a4ea0040a5b5f1678b8d115",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f4cac3a4070e385d379abdd4320689ec",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/15ff68fcb2327e63f8ea85ba29ae075f",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0b760f8f216a3122dade798ab1599b79",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a13d9ce31ae739b1991743646cfb72fa",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/50ac598e001edbb790b4274bd1f826bc",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e4eb4d0dbc72fbee067894629ca99b9b",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/05994a9c8635713ac8bfbbde406b9067",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d83242d77fcf9c191a69f538c6e618b7",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c16c9f0c457048d220f929e887a55567",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c7d95afe55b78574d6cbd947ff4cc7f4"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
