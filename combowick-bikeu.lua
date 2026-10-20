-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/40af144a4e51bd134e041bdab615d451",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2adc81f859ae7093706dc15d247fe09d",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/171a2847d3b2a25167b9a1f32b8fa876",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/417185d2853d02c5d09b97873bb3fefc",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1b813fac11f27d7810f7fbb25fac6b36",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ae4e5882dce82c9d53b40cb0bdf02425",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/69f1cc9fa23ded44efada464fbf57a47",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fc682f011ef0c6f836d2e4f8a0843e91",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0d4be93b1abe1c64a3c96778125572b9",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5a370e9604618b2965cb5d1803f901de",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7f56ae56c5baf80ca7ea07b1e7b5c417",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/96f241f277214d99fbb57b67b5fcfbc4"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
