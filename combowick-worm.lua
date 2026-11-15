-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1cbb1264bd10794022b9eca2fcb0203d",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/de434499fb0af4b0d550af76903cc356",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/807227adde07a0820c6ef01aa4d27f2b",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cad8bb2e434e912632c19198a5c5c325",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7475b22c786422bff6b59078b3fae5a8",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/731f402501e7ea6c590ee0eaf03217bf",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/37d2a8716173f89602e55132879a9e6e",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c58a635d7f84b06ce61cc26f68ba5c9a",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/58185ab5fe7ff554c3533a546ef46091",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b5b0378afbd7faf7f8dabc5ab38e56f5",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/12c73b78c968ff9e9a3d2462c6a40c04",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6bf9338f5b60261f95cb0e7ec4b249d3"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
