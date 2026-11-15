-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ba0cc48e56601d42a7200946199ac5d6",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4d1732b33c1e6b2b18513d440bc75260",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/65641fc1e030d1a325c582d6516ade7c",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9646d321e47acb0b4bcd58a10ed6d5e6",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/07126a9f95c5fbe48c303e372ce24d9b",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7c137cc11f9e7a35951f94a90774f52b",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0ef5c2c92e67cd78fbfa6a32495e30e3",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f73e72104d36d8290875da460762cadd",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bb631a788e2d5c558a1c1bc5f1f75c57",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e69abb4efd0dea1153427fb0da101e94",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0c4e7478d7b4ed2a145091de637e6ca8",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/551e5fa3989671e56d24d30e7c35201b"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
