-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0fe71c4521349e2fc867abb23d0c43fd",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/964a1898d34da74d18294a6612cc7b14",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f5a20d1eddbe8d7c7c7688385374e346",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ff24be9e9379f1f72d19ad16e61fdb35",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bfb5fda819f4257800f511f98cd6337a",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/537c4e144b758f9ee7b28569b1928956",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/075433f29708120a1d05328e59a38f21",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/860afabbcf3a6a314b270a1e66c122fe",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c93fbc558ba84a749d27a4306be7dd3f",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1a56c626b840147558437bddb759ca1d",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c5187c00a6ecc4db542ddb1a64b97756",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bd1c3598eecbdb519ed44105b304ae45"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
