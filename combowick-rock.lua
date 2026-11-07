-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e7c675ca8e6f3fd38300f55b3f5a79ec",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/373fe3842926efab2934f8ca37bfb25e",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/64c0c0830dd91168392cb7a8e120396e",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9983e60bb64bf9170fa4c37d3dc2d544",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/90ae98ef1746da1111fbbd50e114fa10",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fececc275a34edfa9d7a4cf2f843c6b4",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/05e7f12b252ad9fc4cd2afb66fbc10c6",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8f2a1c42ac55168292cec68e0869a597",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9d2e6764a64ae1eb57f77a6f818e33f5",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6f4d37a7bffc07c55e40b8bf8fa2c1c4",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cc94ac0107929be6824a5560ba874b70",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/31cc36a65955c77f22953ae1b98e0405"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
