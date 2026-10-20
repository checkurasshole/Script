-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/21b103a7a4d4c06436bd514c3e50f33f",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8f7b7e2bd893472869fc57865977885e",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b5d55a9dadfc984cf6581308366d4741",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6d8166647fd2cdabad7345daac910d81",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e883a895962e2d674b1db17dbf9e6f39",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/da69c23fdec38e1269e8cd8bb2bffb86",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/76570b53bbf97fcf8ede09951edc396e",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d9850e0fc8083acae03cfbf86fbf0de2",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8cfc43a1d5adb2ada26e2591b660f873",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8f1c7421b1fe601507d745e2fb83e6fe",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4e819714d706dacbfabce24ff2acb107",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2d5077d2d6034f3cd190a360bec524a7"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
