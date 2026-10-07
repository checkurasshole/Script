-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/39ecc0fd7779ab460a704caddce28dda",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7aa879c00518b1b77902c38d5dd999e1",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a92e30451493c4ccbb238c0356b21618",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/407fd05090aa06d329e708e4bb84ea68",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8e306566b9db1265c45bc3ba58d4fe96",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e27ed389c051783000afc83941305c6b",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c3cc57fa95eea5cfab34f255d1c919b4",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/57986b13dde27b291a97354762d2e0c8",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/18e4e3c95828923ef86c10f2c20fda7a",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/72de8cf0f2b49f81eee5dc81a738c136",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e5d869f88d0cc651cc042a4f1f5c1bab",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/22e9c69400b4f1e0bd279586af442a86"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
