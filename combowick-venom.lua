-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9624c8be093312fecc685eeec00cf71c",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1df91018565fb7af8c00c748b8fee85a",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a648f273a3dcb9539013464d754c7ab3",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f80b27193765fa9ff4a4fcc2152171d1",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6d9397556533eac71316503284fe61fa",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/561167e547c51e4bb2d64067fcbdd429",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/087dfb4490b8d8785e696561544bf1e6",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7e3e051b654d276437aa2c4cb7e323fe",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/dd8d85dadc782f8f052e4a135632b0c2",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/19301923b023d5092bd705a8ee3f8900",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5f8e2df58700c0284788299cbe853e6c",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9ec1405148dc9fa8230c0d8ec8c0e8b0"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
