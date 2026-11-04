-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7efea9231ad195f636b8f127a6fa02e6",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/639e00cf8b4a8c482d1bc88bcfb8810b",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/668ed3fd44ae6634ac55057aaff463f4",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/091fe607023a118a972a7c8670eeccd7",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4783833362e4e5bf7983a33c43b7450f",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d092871ab7012d92cb22cd944db2e6f4",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9a8ee29a7f4ddae84cf7396e02ea99b9",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fcf9d4cafac66280b7c836ef298ac1cb",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/abf3124a460aca6be2f96edb3cda27be",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/70cad8c078d1e4f21b88203ae63e7fe7",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/be26edff5307c00b5b919c5e54e00a45",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/005211ad99d76e9e6adeb6e6f951cdfe"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
